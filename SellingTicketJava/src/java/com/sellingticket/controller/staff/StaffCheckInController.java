package com.sellingticket.controller.staff;

import com.sellingticket.dao.EventStaffDAO;
import com.sellingticket.dto.CheckInResult;
import com.sellingticket.model.Event;
import com.sellingticket.model.Ticket;
import com.sellingticket.model.User;
import com.sellingticket.service.CheckInService;
import com.sellingticket.service.EventService;
import static com.sellingticket.util.ServletUtil.getSessionUser;
import static com.sellingticket.util.ServletUtil.parseIntOrDefault;
import static com.sellingticket.util.ServletUtil.sendJson;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

/**
 * Staff Check-in Controller.
 * GET  /staff/check-in            → Event selector (when no eventId)
 * GET  /staff/check-in?eventId=X  → Check-in page for a specific event
 * POST /staff/check-in            → Validate ticket code via AJAX
 */
@WebServlet(name = "StaffCheckInController", urlPatterns = {"/staff/check-in"})
public class StaffCheckInController extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(StaffCheckInController.class.getName());
    private final EventStaffDAO eventStaffDAO = new EventStaffDAO();
    private final EventService eventService = new EventService();
    private final CheckInService checkInService = new CheckInService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = getSessionUser(request);
        if (user == null) { response.sendError(401); return; }

        int eventId = parseIntOrDefault(request.getParameter("eventId"), 0);

        List<Map<String, Object>> events = new ArrayList<>();
        if ("admin".equals(user.getRole())) {
            List<Event> all = eventService.getAccessibleEvents(user.getUserId(), user.getRole());
            for (Event e : all) {
                Map<String, Object> m = new LinkedHashMap<>();
                m.put("eventId", e.getEventId());
                m.put("eventName", e.getTitle());
                m.put("startDate", e.getStartDate());
                m.put("endDate", e.getEndDate());
                m.put("venue", e.getLocation());
                m.put("status", e.getStatus());
                m.put("staffRole", "admin"); // Support acts as admin/manager
                events.add(m);
            }
        } else {
            events = eventStaffDAO.getAssignedEventsWithDetails(user.getUserId());
        }

        if (eventId <= 0) {
            // No event selected — load assigned events list for selector
            request.setAttribute("assignedEvents", events);
            request.setAttribute("noEventSelected", true);
            request.setAttribute("staffHighestRole", computeHighestRole(events, user.getRole()));
            request.getRequestDispatcher("/staff/check-in.jsp").forward(request, response);
            return;
        }

        // Verify access
        if (!eventService.hasCheckInPermission(eventId, user.getUserId(), user.getRole())) {
            com.sellingticket.util.ServletUtil.setToast(request, "Bạn không có quyền thao tác trên sự kiện này!", "error");
            response.sendRedirect(request.getContextPath() + "/staff/dashboard");
            return;
        }

        // Load event details for display
        Map<String, Object> selectedEvent = null;
        for (Map<String, Object> ev : events) {
            if ((int) ev.get("eventId") == eventId) {
                selectedEvent = ev;
                break;
            }
        }

        request.setAttribute("eventId", eventId);
        request.setAttribute("selectedEvent", selectedEvent);
        request.setAttribute("assignedEvents", events);
        request.setAttribute("noEventSelected", false);
        request.setAttribute("staffHighestRole", computeHighestRole(events, user.getRole()));
        request.getRequestDispatcher("/staff/check-in.jsp").forward(request, response);
    }

    private String computeHighestRole(List<Map<String, Object>> events, String userRole) {
        String highest = "staff";
        for (Map<String, Object> ev : events) {
            String role = String.valueOf(ev.getOrDefault("staffRole", "staff"));
            if ("manager".equals(role)) return "manager";
            if ("scanner".equals(role)) highest = "scanner";
        }
        return highest;
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = getSessionUser(request);
        if (user == null) { response.sendError(401); return; }

        String qrToken = request.getParameter("qrToken");
        String ticketCode = request.getParameter("ticketCode");
        String orderCode = request.getParameter("orderCode");
        String action = request.getParameter("action");
        int eventId = parseIntOrDefault(request.getParameter("eventId"), 0);

        // Permission check
        if (eventId > 0 && !eventService.hasCheckInPermission(eventId, user.getUserId(), user.getRole())) {
            sendJson(response, "{\"success\":false,\"message\":\"Bạn không có quyền check-in cho sự kiện này!\"}");
            return;
        }

        CheckInResult result = null;

        // PATH 1: QR Scan (Token)
        if (qrToken != null && !qrToken.trim().isEmpty()) {
            result = checkInService.handleQrCheckIn(eventId, qrToken, user);
        }
        // PATH 2: Manual Check-in (Ticket Code)
        else if (ticketCode != null && !ticketCode.trim().isEmpty()) {
            result = checkInService.handleSingleTicketCheckIn(eventId, null, 0, user);
            // need handleSingleTicketCheckIn by code if not working
        }
        // PATH 3: Order Lookup or Lookup Selection
        else if (orderCode != null && !orderCode.trim().isEmpty()) {
            if ("checkin".equals(action)) {
                int ticketId = parseIntOrDefault(request.getParameter("ticketId"), 0);
                result = checkInService.handleSingleTicketCheckIn(eventId, orderCode, ticketId, user);
            } else {
                result = checkInService.handleOrderLookup(eventId, orderCode, user);
            }
        }

        if (result != null) {
            sendJson(response, toJson(result));
        } else {
            sendJson(response, "{\"success\":false,\"message\":\"Không có dữ liệu check-in\"}");
        }
    }

    private String toJson(CheckInResult res) {
        StringBuilder sb = new StringBuilder("{");
        sb.append("\"success\":").append(res.isSuccess());
        if (res.getMessage() != null) sb.append(",\"message\":\"").append(escapeJson(res.getMessage())).append("\"");
        if (res.getError() != null) sb.append(",\"error\":\"").append(escapeJson(res.getError())).append("\"");
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

    private String escapeJson(String value) {
        if (value == null) return "";
        return value.replace("\\", "\\\\").replace("\"", "\\\"");
    }
}
