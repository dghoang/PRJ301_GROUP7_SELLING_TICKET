package com.sellingticket.controller.organizer;

import com.sellingticket.model.Event;
import com.sellingticket.model.EventStaff;
import com.sellingticket.model.User;
import com.sellingticket.service.EventService;
import com.sellingticket.util.AppConstants;
import com.sellingticket.util.InputValidator;
import static com.sellingticket.util.ServletUtil.*;

import java.io.IOException;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * Organizer team management — CRUD for event staff members.
 *
 * <p>GET: list events + staff for selected event
 * <p>POST: add/remove staff members
 */
@WebServlet(name = "OrganizerTeamController", urlPatterns = {"/organizer/team"})
public class OrganizerTeamController extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(OrganizerTeamController.class.getName());
    private final EventService eventService = new EventService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User user = getSessionUser(request);
        if (user == null) { redirectToLogin(request, response); return; }

        try {
            // Load organizer's events for event picker (with pagination)
            List<Event> allEvents = eventService.getEventsWithPermission(user.getUserId(), user.getRole(), "manager");

            int eventPage = Math.max(1, parseIntOrDefault(request.getParameter("eventPage"), 1));
            int eventSize = Math.max(1, Math.min(200, parseIntOrDefault(request.getParameter("eventSize"), 20)));
            int totalEvents = allEvents.size();
            int totalEventPages = Math.max(1, (int) Math.ceil((double) totalEvents / eventSize));
            eventPage = Math.min(eventPage, totalEventPages);
            int evFrom = (eventPage - 1) * eventSize;
            int evTo = Math.min(evFrom + eventSize, totalEvents);
            List<Event> events = (evFrom < totalEvents)
                    ? allEvents.subList(evFrom, evTo)
                    : java.util.Collections.emptyList();

            request.setAttribute("events", events);
            request.setAttribute("eventCurrentPage", eventPage);
            request.setAttribute("eventTotalPages", totalEventPages);
            request.setAttribute("eventPageSize", eventSize);
            request.setAttribute("totalEvents", totalEvents);

            // If an event is selected, load its staff
            int eventId = parseIntOrDefault(request.getParameter("eventId"), 0);
            if (eventId > 0) {
                // Verify manager-level permission via EventService (source of truth)
                if (!eventService.hasManagerPermission(eventId, user.getUserId(), user.getRole())) {
                    setToast(request, "Bạn không có quyền quản lý sự kiện này", "error");
                    response.sendRedirect(request.getContextPath() + "/organizer/team");
                    return;
                }

                List<EventStaff> allStaff = eventService.getEventStaff(eventId);

                // In-memory pagination for staff list
                int page = Math.max(1, parseIntOrDefault(request.getParameter("page"), 1));
                int size = Math.max(1, Math.min(200, parseIntOrDefault(request.getParameter("size"), 20)));
                int totalRecords = allStaff.size();
                int totalPages = Math.max(1, (int) Math.ceil((double) totalRecords / size));
                page = Math.min(page, totalPages);
                int fromIndex = (page - 1) * size;
                int toIndex = Math.min(fromIndex + size, totalRecords);
                List<EventStaff> pagedStaff = (fromIndex < totalRecords)
                        ? allStaff.subList(fromIndex, toIndex)
                        : java.util.Collections.emptyList();

                request.setAttribute("staffList", pagedStaff);
                request.setAttribute("selectedEventId", eventId);
                request.setAttribute("currentPage", page);
                request.setAttribute("totalPages", totalPages);
                request.setAttribute("pageSize", size);
                request.setAttribute("totalRecords", totalRecords);

                // Find event title
                events.stream()
                      .filter(e -> e.getEventId() == eventId)
                      .findFirst()
                      .ifPresent(e -> request.setAttribute("selectedEventTitle", e.getTitle()));
            }

            request.getRequestDispatcher("/organizer/team.jsp").forward(request, response);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to load organizer team", e);
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User user = getSessionUser(request);
        if (user == null) { redirectToLogin(request, response); return; }

        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");
        int eventId = parseIntOrDefault(request.getParameter("eventId"), 0);

        if (eventId <= 0) {
            response.sendRedirect(request.getContextPath() + "/organizer/team");
            return;
        }

        try {
            // Permission check via EventService (source of truth)
            if (!eventService.hasManagerPermission(eventId, user.getUserId(), user.getRole())) {
                setToast(request, "Không có quyền", "error");
                response.sendRedirect(request.getContextPath() + "/organizer/team?eventId=" + eventId);
                return;
            }

            if ("add".equals(action)) {
                String email = request.getParameter("email");
                String role = AppConstants.normalizeEventStaffRole(request.getParameter("role"));
                if (!InputValidator.isValidEmail(email)) {
                    setToast(request, "Email không hợp lệ", "error");
                } else if (role == null) {
                    setToast(request, "Vai trò không hợp lệ", "error");
                } else {
                    boolean ok = eventService.addEventStaff(eventId, email.trim(), role, user.getUserId());
                    setToast(request, ok ? "Đã thêm thành viên!" : "Email không tồn tại hoặc đã là thành viên", ok ? "success" : "error");
                }
            } else if ("remove".equals(action)) {
                int staffUserId = parseIntOrDefault(request.getParameter("userId"), 0);
                if (staffUserId > 0) {
                    eventService.removeEventStaff(eventId, staffUserId);
                    setToast(request, "Đã xóa thành viên", "success");
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error in OrganizerTeamController.doPost", e);
            setToast(request, "Đã xảy ra lỗi, vui lòng thử lại", "error");
        }

        response.sendRedirect(request.getContextPath() + "/organizer/team?eventId=" + eventId);
    }

}
