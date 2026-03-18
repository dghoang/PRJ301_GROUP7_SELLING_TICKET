package com.sellingticket.controller.staff;

import com.sellingticket.dao.EventStaffDAO;
import com.sellingticket.model.User;
import static com.sellingticket.util.ServletUtil.getSessionUser;

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
 * Staff Portal dashboard. Displays all events assigned to the current user
 * with ticket stats and quick-action links (check-in, details).
 */
@WebServlet(name = "StaffDashboardController", urlPatterns = {"/staff/dashboard", "/staff", "/staff/"})
public class StaffDashboardController extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(StaffDashboardController.class.getName());
    private final EventStaffDAO eventStaffDAO = new EventStaffDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = getSessionUser(request);
        if (user == null) { response.sendError(401); return; }

        try {
            List<Map<String, Object>> events = eventStaffDAO.getAssignedEventsWithDetails(user.getUserId());

            // Summary stats
            int totalEvents = events.size();
            int totalSold = events.stream().mapToInt(e -> (int) e.getOrDefault("ticketsSold", 0)).sum();
            int totalChecked = events.stream().mapToInt(e -> (int) e.getOrDefault("ticketsChecked", 0)).sum();

            request.setAttribute("assignedEvents", events);
            request.setAttribute("totalAssignedEvents", totalEvents);
            request.setAttribute("totalTicketsSold", totalSold);
            request.setAttribute("totalTicketsChecked", totalChecked);

            // Determine highest staff role across all assignments for sidebar badge
            String highestRole = "staff";
            for (Map<String, Object> ev : events) {
                String role = String.valueOf(ev.getOrDefault("staffRole", "staff"));
                if ("manager".equals(role)) { highestRole = "manager"; break; }
                if ("scanner".equals(role)) { highestRole = "scanner"; }
            }
            request.setAttribute("staffHighestRole", highestRole);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error loading staff dashboard", e);
        }

        request.getRequestDispatcher("/staff/dashboard.jsp").forward(request, response);
    }
}
