package com.sellingticket.controller.organizer;

import com.sellingticket.dao.TicketDAO;
import com.sellingticket.dto.CheckInResult;
import com.sellingticket.model.Event;
import com.sellingticket.model.Order;
import com.sellingticket.model.Ticket;
import com.sellingticket.model.User;
import com.sellingticket.service.CheckInService;
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
    private final CheckInService checkInService = new CheckInService();
    private final TicketDAO ticketDAO = new TicketDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User user = getSessionUser(request);
        if (user == null) { redirectToLogin(request, response); return; }

        try {
            List<Event> allEvents = eventService.getEventsWithPermission(user.getUserId(), user.getRole(), "checkin");
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

        CheckInResult result = null;

        // Permission check
        if (eventId > 0 && !eventService.hasCheckInPermission(eventId, user.getUserId(), user.getRole())) {
            sendJson(response, "{\"success\":false,\"message\":\"Bạn không có quyền check-in cho sự kiện này!\"" + csrfField + "}");
            return;
        }

        // PATH 1: QR Scan
        if (qrToken != null && !qrToken.isEmpty()) {
            if (looksLikeOrderCode(qrToken) || looksLikeTicketCode(qrToken)) {
                result = checkInService.handleOrderLookup(eventId, qrToken, user);
            } else {
                result = checkInService.handleQrCheckIn(eventId, qrToken, user);
            }
        } 
        // PATH 2: Manual Order Code
        else if (orderCode != null && !orderCode.isEmpty()) {
            if ("checkin".equals(action)) {
                int ticketId = parseIntOrDefault(request.getParameter("ticketId"), 0);
                result = checkInService.handleSingleTicketCheckIn(eventId, orderCode, ticketId, user);
            } else {
                result = checkInService.handleOrderLookup(eventId, orderCode, user);
            }
        }

        if (result != null) {
            String jsonResult = toJson(result);
            if (jsonResult.endsWith("}")) {
                jsonResult = jsonResult.substring(0, jsonResult.length() - 1) + csrfField + "}";
            }
            sendJson(response, jsonResult);
        } else {
            sendJson(response, "{\"success\":false,\"message\":\"Mã vé hoặc QR không được để trống\"" + csrfField + "}");
        }
    }

    private String toJson(CheckInResult res) {
        StringBuilder sb = new StringBuilder("{");
        sb.append("\"success\":").append(res.isSuccess());
        if (res.getMessage() != null) sb.append(",\"message\":\"").append(escapeJson(res.getMessage())).append("\"");
        if (res.getError() != null) sb.append(",\"message\":\"").append(escapeJson(res.getError())).append("\"");
        if (res.isAlreadyCheckedIn()) sb.append(",\"alreadyCheckedIn\":true");
        if (res.getCustomerName() != null) sb.append(",\"customerName\":\"").append(escapeJson(res.getCustomerName())).append("\"");
        if (res.getTicketCode() != null) sb.append(",\"ticketCode\":\"").append(escapeJson(res.getTicketCode())).append("\"");
        if (res.getTicketType() != null) sb.append(",\"ticketType\":\"").append(escapeJson(res.getTicketType())).append("\"");
        if (res.getAction() != null) sb.append(",\"action\":\"").append(escapeJson(res.getAction())).append("\"");
        if (res.getOrderCode() != null) sb.append(",\"orderCode\":\"").append(escapeJson(res.getOrderCode())).append("\"");
        
        if (res.getTickets() != null) {
            sb.append(",\"tickets\":[");
            for (int i = 0; i < res.getTickets().size(); i++) {
                Map<String, Object> t = res.getTickets().get(i);
                if (i > 0) sb.append(",");
                sb.append("{\"ticketId\":").append(t.get("ticketId"));
                sb.append(",\"ticketCode\":\"").append(escapeJson((String)t.get("ticketCode"))).append("\"");
                sb.append(",\"ticketType\":\"").append(escapeJson((String)t.get("ticketType"))).append("\"");
                sb.append(",\"attendeeName\":\"").append(escapeJson((String)t.get("attendeeName"))).append("\"");
                sb.append(",\"checkedIn\":").append(t.get("checkedIn")).append("}");
            }
            sb.append("]");
        }
        sb.append("}");
        return sb.toString();
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
