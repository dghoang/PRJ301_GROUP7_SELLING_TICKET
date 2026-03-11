package com.sellingticket.controller.api;

import com.sellingticket.model.Order;
import com.sellingticket.service.OrderService;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;
import java.util.logging.Level;
import java.util.logging.Logger;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * SeepayWebhookServlet — IPN endpoint for SePay.vn bank transfer notifications.
 *
 * SePay sends a POST when money is received in the linked bank account.
 * We parse the transaction_content (which contains the order code),
 * verify the amount, and auto-confirm the order.
 *
 * Security:
 *   - Validates Authorization header with SePay API key
 *   - Deduplicates by SePay transaction ID
 *   - Verifies amount matches order total
 *
 * URL: /api/seepay/webhook
 */
@WebServlet(name = "SeepayWebhookServlet", urlPatterns = {"/api/seepay/webhook"})
public class SeepayWebhookServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(SeepayWebhookServlet.class.getName());
    private OrderService orderService;
    private String seepayApiKey;

    /** Track processed transaction IDs to prevent replay attacks. */
    private final Set<String> processedTransactions = ConcurrentHashMap.newKeySet();

    @Override
    public void init() throws ServletException {
        orderService = new OrderService();
        // Load SePay API key for webhook signature verification
        try (InputStream is = getClass().getClassLoader().getResourceAsStream("seepay.properties")) {
            if (is != null) {
                Properties props = new Properties();
                props.load(is);
                seepayApiKey = props.getProperty("seepay.api_key", "");
            }
        } catch (IOException e) {
            LOGGER.log(Level.WARNING, "Failed to load seepay.properties", e);
            seepayApiKey = "";
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        // ===== SECURITY: Verify SePay API Key from Authorization header =====
        String authHeader = request.getHeader("Authorization");
        if (seepayApiKey != null && !seepayApiKey.isEmpty()) {
            // SePay sends: Authorization: Bearer <API_KEY>
            String expectedAuth = "Bearer " + seepayApiKey;
            if (authHeader == null || !expectedAuth.equals(authHeader)) {
                LOGGER.log(Level.WARNING, "SePay webhook rejected: invalid Authorization header from {0}",
                        request.getRemoteAddr());
                response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                response.getWriter().write("{\"success\":false,\"message\":\"Unauthorized\"}");
                return;
            }
        }

        // 1. Read JSON body
        String body = readBody(request);
        LOGGER.log(Level.INFO, "SePay webhook received: {0}", body);

        try {
            // 2. Parse fields manually (avoid adding JSON lib dependency)
            String transactionContent = extractJsonString(body, "transferType");
            if (!"in".equalsIgnoreCase(transactionContent)) {
                // Only process incoming money
                response.getWriter().write("{\"success\":true,\"message\":\"Ignored: not incoming\"}");
                return;
            }

            long amount = extractJsonLong(body, "transferAmount");
            String content = extractJsonString(body, "transaction_content");
            String sepayId = extractJsonString(body, "id");
            String referenceCode = extractJsonString(body, "referenceCode");

            if (content == null || content.isEmpty()) {
                content = extractJsonString(body, "description");
            }

            // ===== SECURITY: Dedup by SePay transaction ID (prevent replay) =====
            if (sepayId != null && !sepayId.isEmpty()) {
                if (!processedTransactions.add(sepayId)) {
                    LOGGER.log(Level.INFO, "SePay IPN: Duplicate transaction ID: {0}", sepayId);
                    response.getWriter().write("{\"success\":true,\"message\":\"Duplicate ignored\"}");
                    return;
                }
            }

            LOGGER.log(Level.INFO, "SePay IPN: sepayId={0}, amount={1}, content={2}",
                    new Object[]{sepayId, amount, content});

            // 3. Extract order code from transfer content
            String orderCode = extractOrderCode(content);
            if (orderCode == null) {
                LOGGER.warning("SePay IPN: No order code found in content: " + content);
                response.getWriter().write("{\"success\":true,\"message\":\"No matching order code\"}");
                return;
            }

            // 4. Find order
            Order order = orderService.getOrderByCode(orderCode);
            if (order == null) {
                LOGGER.warning("SePay IPN: Order not found: " + orderCode);
                response.getWriter().write("{\"success\":true,\"message\":\"Order not found\"}");
                return;
            }

            // 5. Dedup: skip if already paid
            if ("paid".equals(order.getStatus())) {
                LOGGER.info("SePay IPN: Order already paid: " + orderCode);
                response.getWriter().write("{\"success\":true,\"message\":\"Already paid\"}");
                return;
            }

            // 6. Verify amount (allow ±1 VND rounding tolerance)
            long expectedAmount = (long) order.getFinalAmount();
            if (Math.abs(amount - expectedAmount) > 1) {
                LOGGER.log(Level.WARNING, "SePay IPN: Amount mismatch for {0}: expected={1}, received={2}",
                        new Object[]{orderCode, expectedAmount, amount});
                response.getWriter().write("{\"success\":true,\"message\":\"Amount mismatch\"}");
                return;
            }

            // 7. Confirm payment
            boolean updated = orderService.confirmPayment(order.getOrderId(),
                    referenceCode != null ? referenceCode : ("SEPAY-" + sepayId));

            if (updated) {
                // Also issue tickets if not yet issued
                orderService.issueTickets(order.getOrderId(), order.getBuyerName(), order.getBuyerEmail());
                LOGGER.log(Level.INFO, "SePay IPN: Order confirmed: {0}, ref={1}",
                        new Object[]{orderCode, referenceCode});
            }

            response.getWriter().write("{\"success\":true,\"message\":\"Payment confirmed\"}");

        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "SePay webhook error", e);
            response.setStatus(200); // Always 200 to prevent SePay retry storm
            response.getWriter().write("{\"success\":false,\"message\":\"Internal error\"}");
        }
    }

    /** Extract order code from transfer content (e.g. "ORD-1740740400000-ABC12345" in "chuyen khoan ORD-1740740400000-ABC12345") */
    private String extractOrderCode(String content) {
        if (content == null) return null;
        content = content.toUpperCase().trim();

        // Match pattern: ORD-{timestamp}-{UUID} (our order code format)
        java.util.regex.Matcher m = java.util.regex.Pattern
                .compile("(ORD-\\d{10,15}-[A-Z0-9]{4,8})")
                .matcher(content);
        if (m.find()) return m.group(1);

        // Fallback: try the whole content as an order code
        if (content.startsWith("ORD-")) return content;

        return null;
    }

    private String readBody(HttpServletRequest request) throws IOException {
        StringBuilder sb = new StringBuilder();
        try (BufferedReader reader = request.getReader()) {
            String line;
            while ((line = reader.readLine()) != null) {
                sb.append(line);
            }
        }
        return sb.toString();
    }

    /** Simple JSON string extractor (avoids adding json-simple dependency) */
    private String extractJsonString(String json, String key) {
        String search = "\"" + key + "\"";
        int idx = json.indexOf(search);
        if (idx < 0) return null;
        idx = json.indexOf(":", idx) + 1;
        // Skip whitespace
        while (idx < json.length() && json.charAt(idx) == ' ') idx++;
        if (idx >= json.length()) return null;

        if (json.charAt(idx) == '"') {
            int end = json.indexOf('"', idx + 1);
            return end > idx ? json.substring(idx + 1, end) : null;
        }
        // Numeric or other value
        int end = json.indexOf(',', idx);
        if (end < 0) end = json.indexOf('}', idx);
        return end > idx ? json.substring(idx, end).trim() : null;
    }

    private long extractJsonLong(String json, String key) {
        String val = extractJsonString(json, key);
        if (val == null) return 0;
        try { return Long.parseLong(val.replaceAll("[^0-9]", "")); }
        catch (NumberFormatException e) { return 0; }
    }
}
