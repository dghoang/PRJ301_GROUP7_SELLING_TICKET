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
import java.util.regex.Pattern;

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
 *   - Body size limit (64KB DoS protection)
 *   - JSON format validation before parsing
 *   - Escaped-char-aware JSON field extractor
 *   - DB-level idempotency via transaction_id column (survives restarts)
 *   - In-memory dedup as fast-path (ConcurrentHashMap with eviction)
 *   - Order-level dedup (skip if already paid)
 *   - Amount verification
 *
 * URL: /api/seepay/webhook
 */
@WebServlet(name = "SeepayWebhookServlet", urlPatterns = {"/api/seepay/webhook"})
public class SeepayWebhookServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(SeepayWebhookServlet.class.getName());
    private static final int MAX_BODY_SIZE = 65_536; // 64KB max body size (DoS protection)
    private static final int MAX_DEDUP_CACHE_SIZE = 10_000; // Evict when cache grows too large
    private static final Pattern ORDER_CODE_PATTERN =
            Pattern.compile("(ORD-\\d{10,15}-[A-Z0-9]{4,8})");

    private OrderService orderService;
    private String seepayApiKey;

    /** In-memory fast-path dedup. Falls through to DB check if miss. */
    private final Set<String> processedTransactions = ConcurrentHashMap.newKeySet();

    @Override
    public void init() throws ServletException {
        orderService = new OrderService();
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
            String expectedAuth = "Bearer " + seepayApiKey;
            if (authHeader == null || !expectedAuth.equals(authHeader)) {
                LOGGER.log(Level.WARNING, "SePay webhook rejected: invalid auth from {0}",
                        request.getRemoteAddr());
                response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                response.getWriter().write("{\"success\":false,\"message\":\"Unauthorized\"}");
                return;
            }
        }

        // ===== V1 FIX: Read body with size limit (DoS protection) =====
        String body = readBodyLimited(request, MAX_BODY_SIZE);
        if (body == null) {
            LOGGER.warning("SePay webhook: body too large or empty");
            response.setStatus(HttpServletResponse.SC_REQUEST_ENTITY_TOO_LARGE);
            response.getWriter().write("{\"success\":false,\"message\":\"Body too large\"}");
            return;
        }

        // ===== V1 FIX: Validate JSON format before parsing =====
        body = body.trim();
        if (!body.startsWith("{") || !body.endsWith("}")) {
            LOGGER.warning("SePay webhook: invalid JSON format");
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"success\":false,\"message\":\"Invalid JSON\"}");
            return;
        }

        LOGGER.log(Level.INFO, "SePay webhook received: {0}",
                body.length() > 500 ? body.substring(0, 500) + "..." : body);

        try {
            // 2. Parse fields with safe extractor (V2 FIX)
            String transferType = extractJsonStringSafe(body, "transferType");
            if (!"in".equalsIgnoreCase(transferType)) {
                response.getWriter().write("{\"success\":true,\"message\":\"Ignored: not incoming\"}");
                return;
            }

            long amount = extractJsonLong(body, "transferAmount");
            String content = extractJsonStringSafe(body, "transaction_content");
            String sepayId = extractJsonStringSafe(body, "id");
            String referenceCode = extractJsonStringSafe(body, "referenceCode");

            if (content == null || content.isEmpty()) {
                content = extractJsonStringSafe(body, "description");
            }

            // ===== V8 FIX: Multi-layer idempotency =====
            // Layer 1: In-memory fast-path (evict if too large)
            if (processedTransactions.size() > MAX_DEDUP_CACHE_SIZE) {
                processedTransactions.clear();
                LOGGER.info("SePay dedup cache evicted (exceeded " + MAX_DEDUP_CACHE_SIZE + ")");
            }
            if (sepayId != null && !sepayId.isEmpty()) {
                if (!processedTransactions.add(sepayId)) {
                    LOGGER.log(Level.INFO, "SePay IPN: Duplicate txn (memory): {0}", sepayId);
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

            // 5. Order-level dedup: skip if already paid (V8/V10 FIX)
            if (!"pending".equals(order.getStatus())) {
                LOGGER.info("SePay IPN: Order not pending (status=" + order.getStatus() + "): " + orderCode);
                response.getWriter().write("{\"success\":true,\"message\":\"Order not pending\"}");
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

            // 7. Confirm payment (DB-level; confirmPayment checks status atomically)
            String txRef = referenceCode != null ? referenceCode : ("SEPAY-" + sepayId);
            boolean updated = orderService.confirmPayment(order.getOrderId(), txRef);

            if (updated) {
                orderService.issueTickets(order.getOrderId(), order.getBuyerName(), order.getBuyerEmail());
                LOGGER.log(Level.INFO, "SePay IPN: Order confirmed: {0}, ref={1}",
                        new Object[]{orderCode, txRef});
            } else {
                // confirmPayment returned false = order was already processed (race condition handled)
                LOGGER.log(Level.INFO, "SePay IPN: confirmPayment returned false (concurrent): {0}", orderCode);
            }

            response.getWriter().write("{\"success\":true,\"message\":\"Payment confirmed\"}");

        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "SePay webhook error", e);
            response.setStatus(200); // Always 200 to prevent SePay retry storm
            response.getWriter().write("{\"success\":false,\"message\":\"Internal error\"}");
        }
    }

    /** Extract order code from transfer content. */
    private String extractOrderCode(String content) {
        if (content == null) return null;
        content = content.toUpperCase().trim();

        java.util.regex.Matcher m = ORDER_CODE_PATTERN.matcher(content);
        if (m.find()) return m.group(1);

        if (content.startsWith("ORD-")) return content;

        return null;
    }

    /**
     * Read request body with size limit (V1 FIX: DoS protection).
     * Returns null if body exceeds maxSize.
     */
    private String readBodyLimited(HttpServletRequest request, int maxSize) throws IOException {
        StringBuilder sb = new StringBuilder(1024);
        int totalRead = 0;
        try (BufferedReader reader = request.getReader()) {
            char[] buffer = new char[1024];
            int len;
            while ((len = reader.read(buffer)) != -1) {
                totalRead += len;
                if (totalRead > maxSize) {
                    return null; // Body too large
                }
                sb.append(buffer, 0, len);
            }
        }
        return sb.length() == 0 ? null : sb.toString();
    }

    /**
     * Safe JSON string extractor (V2 FIX).
     * Handles escaped quotes, escaped backslashes, null values, and numeric values.
     * Does NOT evaluate Unicode escapes or process nested objects.
     */
    private String extractJsonStringSafe(String json, String key) {
        if (json == null || key == null) return null;

        String search = "\"" + key + "\"";
        int idx = json.indexOf(search);
        if (idx < 0) return null;

        // Find the colon after the key
        idx = json.indexOf(':', idx + search.length());
        if (idx < 0) return null;
        idx++; // skip colon

        // Skip whitespace
        while (idx < json.length() && Character.isWhitespace(json.charAt(idx))) idx++;
        if (idx >= json.length()) return null;

        char c = json.charAt(idx);

        // Handle null literal
        if (c == 'n' && json.startsWith("null", idx)) return null;

        // Handle string value with escaped char awareness
        if (c == '"') {
            StringBuilder result = new StringBuilder();
            idx++; // skip opening quote
            while (idx < json.length()) {
                char ch = json.charAt(idx);
                if (ch == '\\' && idx + 1 < json.length()) {
                    // Escaped character — skip the backslash, take next char literally
                    char next = json.charAt(idx + 1);
                    switch (next) {
                        case '"': result.append('"'); break;
                        case '\\': result.append('\\'); break;
                        case '/': result.append('/'); break;
                        case 'n': result.append('\n'); break;
                        case 'r': result.append('\r'); break;
                        case 't': result.append('\t'); break;
                        default: result.append(next); break;
                    }
                    idx += 2;
                } else if (ch == '"') {
                    break; // End of string
                } else {
                    result.append(ch);
                    idx++;
                }
            }
            return result.toString();
        }

        // Handle numeric or boolean value
        int end = idx;
        while (end < json.length() && json.charAt(end) != ',' && json.charAt(end) != '}' && json.charAt(end) != ']') {
            end++;
        }
        return json.substring(idx, end).trim();
    }

    private long extractJsonLong(String json, String key) {
        String val = extractJsonStringSafe(json, key);
        if (val == null) return 0;
        try { return Long.parseLong(val.replaceAll("[^0-9]", "")); }
        catch (NumberFormatException e) { return 0; }
    }
}
