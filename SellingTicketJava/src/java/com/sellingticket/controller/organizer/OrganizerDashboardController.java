package com.sellingticket.controller.organizer;

import com.sellingticket.dao.DashboardDAO;
import com.sellingticket.model.Event;
import com.sellingticket.model.User;
import com.sellingticket.service.EventService;
import static com.sellingticket.util.ServletUtil.*;

import java.io.IOException;
import java.util.List;
import java.util.Map;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * Organizer dashboard — aggregate overview of events, revenue, and tickets.
 * <ul>
 *   <li>GET /organizer           — show dashboard</li>
 *   <li>GET /organizer/dashboard — alias for the same view</li>
 * </ul>
 */
@WebServlet(name = "OrganizerDashboardController", urlPatterns = {"/organizer", "/organizer/dashboard"})
public class OrganizerDashboardController extends HttpServlet {

    private final EventService eventService = new EventService();
    private final DashboardDAO dashboardDAO = new DashboardDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User user = getSessionUser(request);
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        List<Event> myEvents = eventService.getEventsByOrganizer(user.getUserId());

        // Dashboard Lockout: redirect to events page when user has 0 events
        if (myEvents.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/organizer/events?error=no_events");
            return;
        }

        Map<String, Object> stats = dashboardDAO.getOrganizerDashboardStats(user.getUserId());

        request.setAttribute("totalEvents", stats.getOrDefault("myEvents", 0));
        request.setAttribute("approvedEvents", stats.getOrDefault("approvedEvents", 0));
        request.setAttribute("pendingEvents", stats.getOrDefault("pendingEvents", 0));
        request.setAttribute("totalRevenue", stats.getOrDefault("myRevenue", 0.0));

        int totalTicketsSold = 0;
        for (Event event : myEvents) {
            totalTicketsSold += event.getSoldTickets();
        }

        request.setAttribute("myEvents", myEvents);
        request.setAttribute("recentEvents", myEvents);
        request.setAttribute("totalTicketsSold", totalTicketsSold);

        request.getRequestDispatcher("/organizer/dashboard.jsp").forward(request, response);
    }
}
