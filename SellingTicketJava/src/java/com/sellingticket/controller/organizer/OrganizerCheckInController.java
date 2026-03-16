package com.sellingticket.controller.organizer;

import com.sellingticket.dao.TicketDAO;
import com.sellingticket.model.Event;
import com.sellingticket.model.Order;
import com.sellingticket.model.Ticket;
import com.sellingticket.model.User;
import com.sellingticket.service.EventService;
import com.sellingticket.service.OrderService;
import com.sellingticket.util.JwtUtil;
import static com.sellingticket.util.ServletUtil.*;

import java.io.IOException;
import java.net.InetAddress;
import java.net.NetworkInterface;
import java.net.URI;
import java.util.ArrayList;
import java.util.Enumeration;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * Check-in controller for organizer event gate.
 * Supports both:
 *   1. JWT Token verification (from QR scan) — anti-forgery
 *   2. Legacy order code input (manual fallback)
 */
@WebServlet(name = "OrganizerCheckInController", urlPatterns = {"/organizer/check-in"})
public class OrganizerCheckInController extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(OrganizerCheckInController.class.getName());
    private final EventService eventService = new EventService();
    private final OrderService orderService = new OrderService();
    private final TicketDAO ticketDAO = new TicketDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User user = getSessionUser(request);
        if (user == null) { redirectToLogin(request, response); return; }

        try {
            List<Event> allEvents = eventService.getAccessibleEvents(user.getUserId(), user.getRole());
            // Filter: only show upcoming/active events for check-in (not expired)
            java.util.Date now = new java.util.Date();
            List<Event> events = new ArrayList<>();
            for (Event e : allEvents) {
                boolean isApproved = "approved".equals(e.getStatus()) || "ended".equals(e.getStatus());
                boolean isNotExpired = e.getEndDate() == null || !e.getEndDate().before(now);
                if (isApproved && isNotExpired) {
                    events.add(e);
                }
            }
            request.setAttribute("events", events);

            int eventId = parseIntOrDefault(request.getParameter("eventId"), 0);
            if (eventId > 0 && eventService.hasCheckInPermission(eventId, user.getUserId(), user.getRole())) {
                Event event = eventService.getEventDetails(eventId);
                if (event != null) {
                    // Block check-in for expired events
                    if (event.getEndDate() != null && event.getEndDate().before(new java.util.Date())) {
                        request.setAttribute("eventExpired", true);
                        request.setAttribute("expiredMessage", "Sự kiện đã kết thúc, không thể check-in.");
                    }
                    request.setAttribute("event", event);
                    int totalTickets = ticketDAO.countIssuedByEvent(eventId);
                    int checkedIn = ticketDAO.countCheckedInByEvent(eventId);
                    request.setAttribute("totalTickets", totalTickets);
                    request.setAttribute("checkedInCount", checkedIn);
                }
            }

            // Detect server LAN IPs for mobile access
            request.setAttribute("serverIPs", getLocalIPs());
            request.setAttribute("serverPort", request.getServerPort());
            request.setAttribute("contextPath", request.getContextPath());

            request.getRequestDispatcher("/organizer/check-in.jsp").forward(request, response);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to load check-in page", e);
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }

    /**
     * AJAX check-in endpoint.
     * Accepts either a qrToken (from QR scan) or an orderCode (manual input).
     * For orderCode: action=lookup returns ticket list, action=checkin checks in one ticket.
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User user = getSessionUser(request);
        if (user == null) { sendJson(response, 401, "{\"success\":false,\"message\":\"Unauthorized\"}"); return; }

        // Get the new CSRF token (rotated by CsrfFilter after validation)
        String newCsrf = (String) request.getAttribute("csrf_token");
        String csrfField = newCsrf != null ? ",\"csrfToken\":\"" + escapeJson(newCsrf) + "\"" : "";

        String qrToken = normalizeScannedValue(request.getParameter("qrToken"));
        String orderCode = normalizeScannedValue(request.getParameter("orderCode"));
        String action = request.getParameter("action");
        int eventId = parseIntOrDefault(request.getParameter("eventId"), 0);

        // PATH 1: QR Scan — always uses qrToken param
        if (qrToken != null && !qrToken.isEmpty()) {
            // Compatibility: some old QR payloads contain raw order/ticket codes instead of JWT token.
            if (looksLikeOrderCode(qrToken) || looksLikeTicketCode(qrToken)) {
                handleOrderLookup(response, user, qrToken, eventId, csrfField);
                return;
            }
            handleQrCheckIn(response, user, qrToken, eventId, csrfField);
            return;
        }

        // PATH 2: Manual Order Code
        if (orderCode != null && !orderCode.isEmpty()) {
            if ("checkin".equals(action)) {
                // Check-in a specific ticket by ID
                int ticketId = parseIntOrDefault(request.getParameter("ticketId"), 0);
                handleSingleTicketCheckIn(response, user, orderCode, ticketId, eventId, csrfField);
            } else {
                // Default: lookup tickets for this order
                handleOrderLookup(response, user, orderCode, eventId, csrfField);
            }
            return;
        }

        sendJson(response, "{\"success\":false,\"message\":\"Mã vé hoặc QR không được để trống\"" + csrfField + "}");
    }

    /**
     * QR-based check-in: verify token, validate event, mark ticket as checked-in.
     */
    private void handleQrCheckIn(HttpServletResponse response, User user, String token, int eventId, String csrfField)
            throws IOException {

        LOGGER.log(Level.INFO, "QR Check-in attempt: token length={0}, starts={1}",
                new Object[]{token.length(), token.substring(0, Math.min(20, token.length()))});

        Map<String, Object> claims = JwtUtil.verifyTicketToken(token);
        if (claims == null) {
            LOGGER.log(Level.WARNING, "QR verification failed for token (len={0}): {1}...",
                    new Object[]{token.length(), token.substring(0, Math.min(40, token.length()))});
            sendJson(response, "{\"success\":false,\"message\":\"QR không hợp lệ hoặc đã hết hạn\"" + csrfField + "}");
            return;
        }

        String ticketCode = (String) claims.get("sub");
        int tokenEventId = ((Number) claims.get("eid")).intValue();
        int ticketId = ((Number) claims.get("tid")).intValue();

        // Cross-event check — DOES NOT cancel or modify the ticket
        if (eventId > 0 && tokenEventId != eventId) {
            sendJson(response, "{\"success\":false,\"ticketCode\":\"" + escapeJson(ticketCode) + "\",\"message\":\"Vé không thuộc sự kiện này! Vé vẫn còn hiệu lực.\"" + csrfField + "}");
            return;
        }

        // Permission check
        if (!eventService.hasCheckInPermission(tokenEventId, user.getUserId(), user.getRole())) {
            sendJson(response, "{\"success\":false,\"message\":\"Bạn không có quyền check-in cho sự kiện này!\"" + csrfField + "}");
            return;
        }

        // Load ticket from DB to verify it exists and get current state
        Ticket ticket = ticketDAO.getTicketById(ticketId);
        if (ticket == null || !ticket.getTicketCode().equals(ticketCode)) {
            sendJson(response, "{\"success\":false,\"message\":\"Vé không tồn tại trong hệ thống\"" + csrfField + "}");
            return;
        }

        // Verify parent order state from joined ticket query (avoids extra DB round-trip).
        String orderStatus = ticket.getOrderStatus();
        if ("cancelled".equals(orderStatus) || "refunded".equals(orderStatus)) {
            sendJson(response, "{\"success\":false,\"ticketCode\":\"" + escapeJson(ticketCode)
                    + "\",\"message\":\"Đơn hàng đã bị huỷ/hoàn tiền — vé không hợp lệ\"" + csrfField + "}");
            return;
        }
        if (!("paid".equals(orderStatus) || "checked_in".equals(orderStatus))) {
            sendJson(response, "{\"success\":false,\"ticketCode\":\"" + escapeJson(ticketCode)
                    + "\",\"message\":\"Đơn hàng chưa thanh toán — không thể check-in\"" + csrfField + "}");
            return;
        }

        if (ticket.isCheckedIn()) {
            sendJson(response, "{\"success\":false,\"alreadyCheckedIn\":true,\"ticketCode\":\""
                    + escapeJson(ticketCode) + "\",\"customerName\":\""
                    + escapeJson(ticket.getAttendeeName()) + "\",\"message\":\"Vé đã được sử dụng trước đó!\"" + csrfField + "}");
            return;
        }

        // Check if event is expired
        Event event = eventService.getEventDetails(tokenEventId);
        boolean isExpired = (event != null && event.getEndDate() != null && event.getEndDate().before(new java.util.Date()));
        String warnMsg = isExpired ? " (Sự kiện đã kết thúc)" : "";

        // Execute check-in
        if (ticketDAO.checkInTicket(ticketId, user.getUserId())) {
            LOGGER.log(Level.INFO, "QR Check-in OK: ticket={0} by user {1}", new Object[]{ticketCode, user.getUserId()});
            sendJson(response, "{\"success\":true,\"ticketCode\":\"" + escapeJson(ticketCode)
                    + "\",\"customerName\":\"" + escapeJson(ticket.getAttendeeName())
                    + "\",\"ticketType\":\"" + escapeJson(ticket.getTicketTypeName() + warnMsg)
                    + "\",\"method\":\"qr\"" + csrfField + "}");
        } else {
            sendJson(response, "{\"success\":false,\"message\":\"Lỗi hệ thống khi check-in\"" + csrfField + "}");
        }
    }

    /**
     * Lookup tickets for an order code. Returns ticket list with statuses.
     */
    private void handleOrderLookup(HttpServletResponse response, User user, String orderCode, int eventId, String csrfField)
            throws IOException {

        Order order = orderService.getOrderByCode(orderCode);
        if (order == null && looksLikeTicketCode(orderCode)) {
            // Reverse lookup: allow entering/scanning ticket code (TIX-...) in manual flow.
            Ticket ticket = ticketDAO.getTicketByCode(orderCode);
            if (ticket != null && ticket.getOrderCode() != null) {
                order = orderService.getOrderByCode(ticket.getOrderCode());
                if (order != null) {
                    orderCode = order.getOrderCode();
                }
            }
        }
        if (order == null) {
            sendJson(response, "{\"success\":false,\"message\":\"Không tìm thấy đơn hàng\"" + csrfField + "}");
            return;
        }

        if (eventId > 0 && order.getEventId() != eventId) {
            sendJson(response, "{\"success\":false,\"message\":\"Mã không thuộc sự kiện này! Vé vẫn còn hiệu lực.\"" + csrfField + "}");
            return;
        }

        if (!eventService.hasCheckInPermission(order.getEventId(), user.getUserId(), user.getRole())) {
            sendJson(response, "{\"success\":false,\"message\":\"Bạn không có quyền check-in cho sự kiện này!\"" + csrfField + "}");
            return;
        }

        if ("cancelled".equals(order.getStatus()) || "refunded".equals(order.getStatus())) {
            sendJson(response, "{\"success\":false,\"message\":\"Đơn hàng đã bị huỷ/hoàn tiền — không thể check-in\"" + csrfField + "}");
            return;
        }

        if (!("paid".equals(order.getStatus()) || "checked_in".equals(order.getStatus()))) {
            sendJson(response, "{\"success\":false,\"message\":\"Đơn hàng chưa thanh toán (trạng thái: "
                    + escapeJson(order.getStatus()) + ")\"" + csrfField + "}");
            return;
        }

        List<Ticket> tickets = ticketDAO.getTicketsByOrder(order.getOrderId());
        if (tickets.isEmpty()) {
            sendJson(response, "{\"success\":false,\"message\":\"Đơn hàng chưa được phát vé\"" + csrfField + "}");
            return;
        }

        // Build JSON ticket array
        StringBuilder json = new StringBuilder("{\"success\":true,\"action\":\"lookup\",\"customerName\":\"");
        json.append(escapeJson(order.getBuyerName())).append("\",\"orderCode\":\"").append(escapeJson(orderCode));
        json.append("\",\"tickets\":[");
        for (int i = 0; i < tickets.size(); i++) {
            Ticket t = tickets.get(i);
            if (i > 0) json.append(",");
            json.append("{\"ticketId\":").append(t.getTicketId());
            json.append(",\"ticketCode\":\"").append(escapeJson(t.getTicketCode())).append("\"");
            json.append(",\"ticketType\":\"").append(escapeJson(t.getTicketTypeName())).append("\"");
            json.append(",\"attendeeName\":\"").append(escapeJson(t.getAttendeeName())).append("\"");
            json.append(",\"checkedIn\":").append(t.isCheckedIn()).append("}");
        }
        json.append("]").append(csrfField).append("}");
        sendJson(response, json.toString());
    }

    /**
     * Check in a single ticket by ID (from the ticket picker UI).
     */
    private void handleSingleTicketCheckIn(HttpServletResponse response, User user, String orderCode, int ticketId, int eventId, String csrfField)
            throws IOException {

        if (ticketId <= 0) {
            sendJson(response, "{\"success\":false,\"message\":\"Vui lòng chọn vé cần check-in\"" + csrfField + "}");
            return;
        }

        Ticket ticket = ticketDAO.getTicketById(ticketId);
        if (ticket == null || !orderCode.equals(ticket.getOrderCode())) {
            sendJson(response, "{\"success\":false,\"message\":\"Vé không hợp lệ\"" + csrfField + "}");
            return;
        }

        if (eventId > 0 && ticket.getEventId() != eventId) {
            sendJson(response, "{\"success\":false,\"message\":\"Vé không thuộc sự kiện này!\"" + csrfField + "}");
            return;
        }

        if (!eventService.hasCheckInPermission(ticket.getEventId(), user.getUserId(), user.getRole())) {
            sendJson(response, "{\"success\":false,\"message\":\"Bạn không có quyền check-in!\"" + csrfField + "}");
            return;
        }

        if (ticket.isCheckedIn()) {
            sendJson(response, "{\"success\":false,\"alreadyCheckedIn\":true,\"customerName\":\""
                    + escapeJson(ticket.getAttendeeName()) + "\",\"message\":\"Vé đã check-in rồi\"" + csrfField + "}");
            return;
        }

        String orderStatus = ticket.getOrderStatus();
        if ("cancelled".equals(orderStatus) || "refunded".equals(orderStatus)) {
            sendJson(response, "{\"success\":false,\"message\":\"Đơn hàng đã bị huỷ/hoàn tiền — không thể check-in\"" + csrfField + "}");
            return;
        }
        if (!("paid".equals(orderStatus) || "checked_in".equals(orderStatus))) {
            sendJson(response, "{\"success\":false,\"message\":\"Đơn hàng chưa thanh toán — không thể check-in\"" + csrfField + "}");
            return;
        }

        // Check if event is expired
        Event eventObj = eventService.getEventDetails(ticket.getEventId());
        boolean isExpired = (eventObj != null && eventObj.getEndDate() != null && eventObj.getEndDate().before(new java.util.Date()));
        String warnMsg = isExpired ? " (Sự kiện đã kết thúc)" : "";

        if (ticketDAO.checkInTicket(ticketId, user.getUserId())) {
            LOGGER.log(Level.INFO, "Ticket Check-in OK: ticket={0} order={1} by user {2}",
                    new Object[]{ticket.getTicketCode(), orderCode, user.getUserId()});
            sendJson(response, "{\"success\":true,\"customerName\":\"" + escapeJson(ticket.getAttendeeName())
                    + "\",\"ticketType\":\"" + escapeJson(ticket.getTicketTypeName() + warnMsg)
                    + "\",\"method\":\"manual\"" + csrfField + "}");
        } else {
            sendJson(response, "{\"success\":false,\"message\":\"Lỗi hệ thống khi check-in\"" + csrfField + "}");
        }
    }

    /** Escape double quotes and backslashes for safe JSON string embedding. */
    private String escapeJson(String value) {
        if (value == null) return "";
        return value.replace("\\", "\\\\").replace("\"", "\\\"");
    }

    private String normalizeScannedValue(String raw) {
        if (raw == null) return null;
        String value = raw.trim();
        if (value.isEmpty()) return "";

        // Strip wrapping quotes from scanners that include JSON-like payload wrappers.
        if (value.length() >= 2 && ((value.startsWith("\"") && value.endsWith("\""))
                || (value.startsWith("'") && value.endsWith("'")))) {
            value = value.substring(1, value.length() - 1).trim();
        }

        // Decode percent-encoded payload (once is enough for our QR formats).
        if (value.contains("%")) {
            try {
                value = java.net.URLDecoder.decode(value, "UTF-8").trim();
            } catch (Exception ignored) {
                // Keep original value when decode fails.
            }
        }

        // Accept deep links: extract known query params when full URL is scanned.
        if (value.startsWith("http://") || value.startsWith("https://")) {
            try {
                URI uri = URI.create(value);
                String query = uri.getRawQuery();
                String[] keys = new String[]{"qrToken", "token", "code", "orderCode", "ticketCode"};
                for (String key : keys) {
                    String found = extractQueryParam(query, key);
                    if (found != null && !found.trim().isEmpty()) {
                        return found.trim();
                    }
                }

                String path = uri.getPath();
                if (path != null && !path.isEmpty()) {
                    String[] parts = path.split("/");
                    String tail = parts.length > 0 ? parts[parts.length - 1] : "";
                    if (looksLikeOrderCode(tail) || looksLikeTicketCode(tail)) {
                        return tail;
                    }
                }
            } catch (Exception ignored) {
                // Fallback to raw value.
            }
        }

        return value;
    }

    private String extractQueryParam(String rawQuery, String key) {
        if (rawQuery == null || rawQuery.trim().isEmpty()) return null;
        String[] pairs = rawQuery.split("&");
        for (String pair : pairs) {
            int idx = pair.indexOf('=');
            String k = idx >= 0 ? pair.substring(0, idx) : pair;
            if (!key.equals(k)) continue;
            String v = idx >= 0 ? pair.substring(idx + 1) : "";
            try {
                return java.net.URLDecoder.decode(v, "UTF-8");
            } catch (Exception ignored) {
                return v;
            }
        }
        return null;
    }

    private boolean looksLikeOrderCode(String value) {
        if (value == null) return false;
        return value.trim().toUpperCase(Locale.ROOT).matches("^ORD-[A-Z0-9-]{6,}$");
    }

    private boolean looksLikeTicketCode(String value) {
        if (value == null) return false;
        return value.trim().toUpperCase(Locale.ROOT).matches("^TIX-[A-Z0-9-]{6,}$");
    }

    /** Get all non-loopback IPv4 addresses for LAN access. */
    private List<String> getLocalIPs() {
        List<String> ips = new ArrayList<>();
        try {
            Enumeration<NetworkInterface> interfaces = NetworkInterface.getNetworkInterfaces();
            while (interfaces.hasMoreElements()) {
                NetworkInterface ni = interfaces.nextElement();
                if (ni.isLoopback() || !ni.isUp()) continue;
                Enumeration<InetAddress> addresses = ni.getInetAddresses();
                while (addresses.hasMoreElements()) {
                    InetAddress addr = addresses.nextElement();
                    if (addr instanceof java.net.Inet4Address) {
                        ips.add(addr.getHostAddress());
                    }
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.WARNING, "Failed to detect local IPs", e);
        }
        return ips;
    }
}
