package com.sellingticket.controller.organizer;

import com.sellingticket.model.Event;
import com.sellingticket.model.User;
import com.sellingticket.service.DashboardService;
import com.sellingticket.service.EventService;
import static com.sellingticket.util.ServletUtil.*;

import java.io.IOException;
import java.util.ArrayList;
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
 * Organizer statistics — revenue, ticket sales, event performance.
 *
 * <p>Endpoints:
 * <ul>
 *   <li>GET /organizer/statistics — JSP page</li>
 *   <li>GET /organizer/statistics/api — JSON stats summary</li>
 *   <li>GET /organizer/statistics/chart-data?type=revenue&days=7 — revenue chart</li>
 *   <li>GET /organizer/statistics/chart-data?type=tickets — ticket distribution</li>
 * </ul>
 */
@WebServlet(name = "OrganizerStatisticsController",
        urlPatterns = {"/organizer/statistics", "/organizer/statistics/*"})
public class OrganizerStatisticsController extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(OrganizerStatisticsController.class.getName());
    private final EventService eventService = new EventService();
    private final DashboardService dashboardService = new DashboardService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User user = getSessionUser(request);
        if (user == null) {
            redirectToLogin(request, response);
            return;
        }

        String pathInfo = request.getPathInfo();

        if ("/api".equals(pathInfo)) {
            serveJsonSummary(request, response, user);
        } else if ("/chart-data".equals(pathInfo)) {
            serveChartData(request, response, user);
        } else if ("/event-stats".equals(pathInfo)) {
            serveEventStats(request, response, user);
        } else {
            serveJsp(request, response, user);
        }
    }

    private void serveJsp(HttpServletRequest request, HttpServletResponse response, User user)
            throws ServletException, IOException {
        try {
            StatsData data = buildStatsData(request, user);

            request.setAttribute("myEvents", data.myEvents);
            request.setAttribute("selectedEventId", data.selectedEventId);
            request.setAttribute("events", data.events);
            request.setAttribute("eventStats", data.eventStats);
            request.setAttribute("totalRevenue", data.totalRevenue);
            request.setAttribute("totalOrders", data.totalOrders);
            request.setAttribute("totalEvents", data.events.size());
            // Settlement breakdown for organizer
            if (data.settlement != null) {
                request.setAttribute("totalFaceValue", data.settlement.getOrDefault("totalFaceValue", 0.0));
                request.setAttribute("totalEventDiscount", data.settlement.getOrDefault("totalEventDiscount", 0.0));
                request.setAttribute("totalSystemDiscount", data.settlement.getOrDefault("totalSystemDiscount", 0.0));
                request.setAttribute("totalPlatformFee", data.settlement.getOrDefault("totalPlatformFee", 0.0));
                request.setAttribute("totalPayout", data.settlement.getOrDefault("totalPayout", 0.0));
            }
            request.getRequestDispatcher("/organizer/statistics.jsp").forward(request, response);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to load organizer statistics", e);
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }

    /** Serve JSON summary for AJAX. */
    private void serveJsonSummary(HttpServletRequest request, HttpServletResponse response, User user) throws IOException {
        try {
            StatsData data = buildStatsData(request, user);
            StringBuilder json = new StringBuilder("{");
            json.append("\"totalRevenue\":").append(data.totalRevenue).append(",");
            json.append("\"totalOrders\":").append(data.totalOrders).append(",");
            json.append("\"totalEvents\":").append(data.events.size()).append(",");
            json.append("\"events\":[");

            for (int i = 0; i < data.eventStats.size(); i++) {
                if (i > 0) json.append(",");
                Map<String, Object> stat = data.eventStats.get(i);
                Event e = (Event) stat.get("event");
                json.append("{\"name\":\"").append(escapeJson(e.getTitle())).append("\",");
                json.append("\"revenue\":").append(stat.get("revenue")).append(",");
                json.append("\"orders\":").append(stat.get("orderCount")).append("}");
            }

            json.append("]}");
            sendJson(response, json.toString());
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to serve organizer stats JSON", e);
            sendJson(response, 500, "{\"error\":\"Internal server error\"}");
        }
    }

    /** Serve chart data JSON based on type parameter. Supports eventId filter. */
    private void serveChartData(HttpServletRequest request, HttpServletResponse response, User user)
            throws IOException {
        String type = request.getParameter("type");
        if (type == null) type = "revenue";

        // Security & Isolation: build allowed eventIds
        List<Event> myEvents = eventService.getEventsWithPermission(user.getUserId(), user.getRole(), "stats");
        int selectedEventId = parseIntOrDefault(request.getParameter("eventId"), 0);
        List<Integer> eventIds = new ArrayList<>();
        
        for (Event e : myEvents) {
            if (selectedEventId <= 0 || e.getEventId() == selectedEventId) {
                eventIds.add(e.getEventId());
            }
        }
        if (selectedEventId > 0 && eventIds.isEmpty()) {
            selectedEventId = 0;
            for (Event e : myEvents) {
                eventIds.add(e.getEventId());
            }
        }

        try {
            switch (type) {
                case "revenue": {
                    int days = parseIntOrDefault(request.getParameter("days"), 7);
                    List<Map<String, Object>> data = dashboardService.getRevenueByDaysForEvents(eventIds, days);
                    sendJson(response, buildJsonArray(data));
                    break;
                }
                case "tickets": {
                    List<Map<String, Object>> data = dashboardService.getTicketDistributionForEvents(eventIds);
                    sendJson(response, buildJsonArray(data));
                    break;
                }
                case "hourly": {
                    List<Map<String, Object>> data = dashboardService.getHourlyDistributionForEvents(eventIds);
                    sendJson(response, buildJsonArray(data));
                    break;
                }
                default:
                    sendJson(response, 400, "{\"error\":\"Invalid type\"}");
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to load organizer chart data: " + type, e);
            sendJson(response, 500, "{\"error\":\"Internal server error\"}");
        }
    }

    /** Serve stats for a single event as JSON. */
    private void serveEventStats(HttpServletRequest request, HttpServletResponse response, User user)
            throws IOException {
        int eventId = parseIntOrDefault(request.getParameter("eventId"), 0);
        if (eventId <= 0) {
            sendJson(response, 400, "{\"error\":\"Missing eventId\"}");
            return;
        }
        // SECURITY: Verify organizer has access to the requested event
        if (!eventService.hasStatsPermission(eventId, user.getUserId(), user.getRole())) {
            sendJson(response, 403, "{\"error\":\"Access denied\"}");
            return;
        }
        try {
            Map<String, Object> stats = dashboardService.getEventSpecificStats(eventId);
            StringBuilder json = new StringBuilder("{");
            json.append("\"revenue\":").append(stats.getOrDefault("revenue", 0.0)).append(",");
            json.append("\"totalOrders\":").append(stats.getOrDefault("totalOrders", 0)).append(",");
            json.append("\"paidOrders\":").append(stats.getOrDefault("paidOrders", 0)).append(",");
            json.append("\"totalTickets\":").append(stats.getOrDefault("totalTickets", 0)).append(",");
            json.append("\"checkedIn\":").append(stats.getOrDefault("checkedIn", 0));
            json.append("}");
            sendJson(response, json.toString());
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to serve event stats for eventId=" + eventId, e);
            sendJson(response, 500, "{\"error\":\"Internal server error\"}");
        }
    }

    /** Build statistics data shared by JSP and JSON. */
    private StatsData buildStatsData(HttpServletRequest request, User user) {
        List<Event> myEvents = eventService.getEventsWithPermission(user.getUserId(), user.getRole(), "stats");
        
        int selectedEventId = parseIntOrDefault(request.getParameter("eventId"), 0);
        List<Integer> eventIds = new ArrayList<>();
        
        for (Event e : myEvents) {
            if (selectedEventId <= 0 || e.getEventId() == selectedEventId) {
                eventIds.add(e.getEventId());
            }
        }
        
        if (selectedEventId > 0 && eventIds.isEmpty()) {
            selectedEventId = 0;
            for (Event e : myEvents) {
                eventIds.add(e.getEventId());
            }
        }

        Map<String, Object> stats = dashboardService.getDashboardStatsForEvents(eventIds);
        List<Map<String, Object>> perEventStats = dashboardService.getEventStatsForEvents(eventIds);
        Map<String, Object> settlement = dashboardService.getSettlementStatsForEvents(eventIds);

        Map<Integer, Map<String, Object>> statsLookup = new HashMap<>();
        for (Map<String, Object> row : perEventStats) {
            statsLookup.put((Integer) row.get("eventId"), row);
        }

        List<Event> filteredEvents = new ArrayList<>();
        List<Map<String, Object>> eventStats = new ArrayList<>();

        for (Event event : myEvents) {
            if (selectedEventId > 0 && event.getEventId() != selectedEventId) continue;
            filteredEvents.add(event);
            Map<String, Object> lookup = statsLookup.getOrDefault(event.getEventId(), Map.of());
            Map<String, Object> stat = new HashMap<>();
            stat.put("event", event);
            stat.put("revenue", ((Number) lookup.getOrDefault("revenue", 0.0)).doubleValue());
            stat.put("orderCount", ((Number) lookup.getOrDefault("orderCount", 0)).intValue());
            eventStats.add(stat);
        }

        StatsData data = new StatsData();
        data.myEvents = myEvents;
        data.selectedEventId = selectedEventId;
        data.events = filteredEvents;
        data.eventStats = eventStats;
        data.totalRevenue = ((Number) stats.getOrDefault("myRevenue", 0.0)).doubleValue();
        data.totalOrders = ((Number) stats.getOrDefault("myTotalOrders", 0)).intValue();
        data.settlement = settlement;
        return data;
    }

    private String buildJsonArray(List<Map<String, Object>> list) {
        StringBuilder sb = new StringBuilder("[");
        for (int i = 0; i < list.size(); i++) {
            if (i > 0) sb.append(",");
            sb.append("{");
            int j = 0;
            for (Map.Entry<String, Object> e : list.get(i).entrySet()) {
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

    private String escapeJson(String value) {
        if (value == null) return "";
        return value.replace("\\", "\\\\").replace("\"", "\\\"");
    }

    private static class StatsData {
        List<Event> myEvents;
        int selectedEventId;
        List<Event> events;
        List<Map<String, Object>> eventStats;
        double totalRevenue;
        int totalOrders;
        Map<String, Object> settlement;
    }
}
