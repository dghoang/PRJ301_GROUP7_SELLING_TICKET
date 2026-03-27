package com.sellingticket.controller.organizer;

import com.sellingticket.dao.DashboardDAO;
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
 *   <li>GET /organizer/dashboard/chart-data — JSON API for charts</li>
 * </ul>
 */
@WebServlet(name = "OrganizerDashboardController", urlPatterns = {"/organizer", "/organizer/dashboard", "/organizer/dashboard/chart-data"})
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
            String uri = request.getRequestURI();
            List<Event> myEvents = eventService.getEventsWithPermission(user.getUserId(), user.getRole(), "stats");

            if (uri.endsWith("/chart-data")) {
                handleChartDataApi(request, response, myEvents);
                return;
            }

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

    private void handleChartDataApi(HttpServletRequest request, HttpServletResponse response, List<Event> myEvents)
            throws IOException {
        int selectedEventId = parseIntOrDefault(request.getParameter("eventId"), 0);
        List<Integer> eventIds = new java.util.ArrayList<>();
        
        for (Event e : myEvents) {
            if (selectedEventId <= 0 || e.getEventId() == selectedEventId) {
                eventIds.add(e.getEventId());
            }
        }
        
        // Fallback for unauthorized/invalid selection
        if (selectedEventId > 0 && eventIds.isEmpty()) {
            for (Event e : myEvents) {
                eventIds.add(e.getEventId());
            }
        }

        if (eventIds.isEmpty()) {
            sendJson(response, 200, "[]");
            return;
        }

        String type = request.getParameter("type");
        if (type == null) type = "revenue";

        try {
            switch (type) {
                case "revenue": {
                    int days = 7;
                    String daysParam = request.getParameter("days");
                    if (daysParam != null) {
                        try { days = Integer.parseInt(daysParam); } catch (NumberFormatException ignored) {}
                    }
                    List<Map<String, Object>> data = dashboardService.getRevenueByDaysForEvents(eventIds, days);
                    sendJson(response, buildJsonArray(data));
                    break;
                }
                case "tickets": {
                    List<Map<String, Object>> data = dashboardService.getTicketDistributionForEvents(eventIds);
                    sendJson(response, buildJsonArray(data));
                    break;
                }
                default:
                    sendJson(response, 400, "{\"error\":\"Invalid type parameter\"}");
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to load organizer chart data: " + type, e);
            sendJson(response, 500, "{\"error\":\"Internal server error\"}");
        }
    }

    private String buildJsonArray(List<Map<String, Object>> list) {
        StringBuilder sb = new StringBuilder("[");
        for (int i = 0; i < list.size(); i++) {
            if (i > 0) sb.append(",");
            sb.append("{");
            Map<String, Object> map = list.get(i);
            int j = 0;
            for (Map.Entry<String, Object> e : map.entrySet()) {
                if (j > 0) sb.append(",");
                sb.append("\"").append(e.getKey()).append("\":");
                Object val = e.getValue();
                if (val instanceof String) {
                    sb.append("\"").append(escapeJson((String) val)).append("\"");
                } else {
                    sb.append(val);
                }
                j++;
            }
            sb.append("}");
        }
        sb.append("]");
        return sb.toString();
    }

    private String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"")
                .replace("\n", "\\n").replace("\r", "\\r").replace("\t", "\\t");
    }
}
