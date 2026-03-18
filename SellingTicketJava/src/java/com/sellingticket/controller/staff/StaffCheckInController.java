package com.sellingticket.controller.staff;

import com.sellingticket.dao.EventStaffDAO;
import com.sellingticket.dao.TicketDAO;
import com.sellingticket.model.Ticket;
import com.sellingticket.model.User;
import com.sellingticket.service.EventService;
import static com.sellingticket.util.ServletUtil.getSessionUser;
import static com.sellingticket.util.ServletUtil.parseIntOrDefault;
import static com.sellingticket.util.ServletUtil.sendJson;

import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

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
    private final TicketDAO ticketDAO = new TicketDAO();
    private final EventService eventService = new EventService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = getSessionUser(request);
        if (user == null) { response.sendError(401); return; }

        int eventId = parseIntOrDefault(request.getParameter("eventId"), 0);

        if (eventId <= 0) {
            // No event selected — load assigned events list for selector
            List<Map<String, Object>> events = eventStaffDAO.getAssignedEventsWithDetails(user.getUserId());
            request.setAttribute("assignedEvents", events);
            request.setAttribute("noEventSelected", true);
            // Set highest role for sidebar badge
            request.setAttribute("staffHighestRole", computeHighestRole(events));
            request.getRequestDispatcher("/staff/check-in.jsp").forward(request, response);
            return;
        }

        // Verify access
        if (!eventService.hasCheckInPermission(eventId, user.getUserId(), user.getRole())) {
            response.sendRedirect(request.getContextPath() + "/staff/dashboard?error=no_access");
            return;
        }

        // Load event details for display
        List<Map<String, Object>> allEvents = eventStaffDAO.getAssignedEventsWithDetails(user.getUserId());
        Map<String, Object> selectedEvent = null;
        for (Map<String, Object> ev : allEvents) {
            if ((int) ev.get("eventId") == eventId) {
                selectedEvent = ev;
                break;
            }
        }

        request.setAttribute("eventId", eventId);
        request.setAttribute("selectedEvent", selectedEvent);
        request.setAttribute("assignedEvents", allEvents);
        request.setAttribute("noEventSelected", false);
        request.setAttribute("staffHighestRole", computeHighestRole(allEvents));
        request.getRequestDispatcher("/staff/check-in.jsp").forward(request, response);
    }

    private String computeHighestRole(List<Map<String, Object>> events) {
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

        String ticketCode = request.getParameter("ticketCode");
        int eventId = parseIntOrDefault(request.getParameter("eventId"), 0);
        Map<String, Object> result = new HashMap<>();

        try {
            if (ticketCode == null || ticketCode.trim().isEmpty()) {
                result.put("success", false);
                result.put("error", "Mã vé không hợp lệ");
            } else if (eventId <= 0) {
                result.put("success", false);
                result.put("error", "Không xác định sự kiện");
            } else if (!eventService.hasCheckInPermission(eventId, user.getUserId(), user.getRole())) {
                result.put("success", false);
                result.put("error", "Bạn không có quyền check-in sự kiện này");
            } else {
                Ticket ticket = ticketDAO.getTicketByCode(ticketCode.trim());
                if (ticket == null) {
                    result.put("success", false);
                    result.put("error", "Không tìm thấy vé với mã này");
                } else if (ticket.isCheckedIn()) {
                    result.put("success", false);
                    result.put("error", "Vé đã được check-in trước đó");
                } else {
                    boolean ok = ticketDAO.checkInTicket(ticket.getTicketId(), user.getUserId());
                    result.put("success", ok);
                    if (!ok) {
                        result.put("error", "Không thể check-in vé. Vui lòng thử lại.");
                    } else {
                        result.put("message", "Check-in thành công!");
                        result.put("ticketCode", ticketCode.trim());
                        result.put("ticketId", ticket.getTicketId());
                    }
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.WARNING, "Check-in error", e);
            result.put("success", false);
            result.put("error", "Lỗi hệ thống");
        }

        sendJson(response, result);
    }
}
