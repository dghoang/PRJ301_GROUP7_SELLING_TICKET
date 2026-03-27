package com.sellingticket.controller.organizer;

import com.sellingticket.model.Event;
import com.sellingticket.model.User;
import com.sellingticket.service.EventService;
import static com.sellingticket.util.ServletUtil.*;

import java.io.IOException;
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
 * Organizer dashboard — aggregate overview of events, revenue, and tickets.
 * <ul>
 *   <li>GET /organizer           — show dashboard</li>
 *   <li>GET /organizer/dashboard — show dashboard</li>
 * </ul>
 */
@WebServlet(name = "OrganizerDashboardController", urlPatterns = {"/organizer", "/organizer/dashboard"})
public class OrganizerDashboardController extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(OrganizerDashboardController.class.getName());
    private final EventService eventService = new EventService();
    private final com.sellingticket.service.DashboardService dashboardService = new com.sellingticket.service.DashboardService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User user = getSessionUser(request);
        if (user == null) {
            redirectToLogin(request, response);
            return;
        }

        try {
            List<Event> myEvents = eventService.getEventsWithPermission(user.getUserId(), user.getRole(), "stats");

            // Dashboard Lockout: redirect to events page when user has 0 events
            if (myEvents.isEmpty()) {
                com.sellingticket.util.ServletUtil.setToast(request, "Bạn chưa có sự kiện nào. Hãy tạo sự kiện mới!", "warning");
                response.sendRedirect(request.getContextPath() + "/organizer/events");
                return;
            }

            int selectedEventId = parseIntOrDefault(request.getParameter("eventId"), 0);
            List<Integer> eventIds = new java.util.ArrayList<>();
            int totalTicketsSold = 0;

            for (Event e : myEvents) {
                if (selectedEventId <= 0 || e.getEventId() == selectedEventId) {
                    eventIds.add(e.getEventId());
                    totalTicketsSold += e.getSoldTickets();
                }
            }

            // Fallback if staff tries to select an event they don't have access to
            if (selectedEventId > 0 && eventIds.isEmpty()) {
                selectedEventId = 0;
                totalTicketsSold = 0;
                for (Event e : myEvents) {
                    eventIds.add(e.getEventId());
                    totalTicketsSold += e.getSoldTickets();
                }
            }

            Map<String, Object> stats = dashboardService.getDashboardStatsForEvents(eventIds);

            request.setAttribute("totalEvents", stats.getOrDefault("myEvents", 0));
            request.setAttribute("approvedEvents", stats.getOrDefault("approvedEvents", 0));
            request.setAttribute("pendingEvents", stats.getOrDefault("pendingEvents", 0));
            request.setAttribute("totalRevenue", stats.getOrDefault("myRevenue", 0.0));
            request.setAttribute("totalTicketsSold", totalTicketsSold);
            request.setAttribute("selectedEventId", selectedEventId);

            request.setAttribute("myEvents", myEvents);
            request.setAttribute("recentEvents", myEvents);

            request.getRequestDispatcher("/organizer/dashboard.jsp").forward(request, response);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to load organizer dashboard", e);
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }
}
