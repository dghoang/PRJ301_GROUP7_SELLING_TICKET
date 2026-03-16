package com.sellingticket.controller.organizer;

import com.sellingticket.model.Event;
import com.sellingticket.model.EventStaff;
import com.sellingticket.model.User;
import com.sellingticket.service.EventService;
import com.sellingticket.util.AppConstants;
import com.sellingticket.util.InputValidator;
import com.sellingticket.util.PermissionCache;
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
            // Load organizer's events for event picker
            List<Event> events = eventService.getAccessibleEvents(user.getUserId(), user.getRole());
            request.setAttribute("events", events);

            // If an event is selected, load its staff
            int eventId = parseIntOrDefault(request.getParameter("eventId"), 0);
            if (eventId > 0) {
                // Verify permission via cached check
                if (!PermissionCache.hasPermission(request.getSession(), eventId, user.getUserId())
                    && !isOwner(user.getUserId(), eventId, events)
                    && !"admin".equals(user.getRole())) {
                    setToast(request, "Bạn không có quyền quản lý sự kiện này", "error");
                    response.sendRedirect(request.getContextPath() + "/organizer/team");
                    return;
                }

                List<EventStaff> staffList = eventService.getEventStaff(eventId);
                request.setAttribute("staffList", staffList);
                request.setAttribute("selectedEventId", eventId);

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
            // Permission check
            List<Event> events = eventService.getAccessibleEvents(user.getUserId(), user.getRole());
            if (!hasManagerAccess(user, eventId, events)) {
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
                    PermissionCache.invalidate(request.getSession());
                }
            } else if ("remove".equals(action)) {
                int staffUserId = parseIntOrDefault(request.getParameter("userId"), 0);
                if (staffUserId > 0) {
                    eventService.removeEventStaff(eventId, staffUserId);
                    setToast(request, "Đã xóa thành viên", "success");
                    PermissionCache.invalidate(request.getSession());
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error in OrganizerTeamController.doPost", e);
            setToast(request, "Đã xảy ra lỗi, vui lòng thử lại", "error");
        }

        response.sendRedirect(request.getContextPath() + "/organizer/team?eventId=" + eventId);
    }

    private boolean isOwner(int userId, int eventId, List<Event> events) {
        return events.stream().anyMatch(e -> e.getEventId() == eventId && e.getOrganizerId() == userId);
    }

    private boolean hasManagerAccess(User user, int eventId, List<Event> events) {
        if ("admin".equals(user.getRole())) return true;
        if (isOwner(user.getUserId(), eventId, events)) return true;
        return eventService.hasManagerPermission(eventId, user.getUserId(), user.getRole());
    }
}
