package com.sellingticket.controller.organizer;

import com.sellingticket.model.Event;
import com.sellingticket.model.User;
import com.sellingticket.service.DashboardService;
import com.sellingticket.service.EventService;
import static com.sellingticket.util.ServletUtil.getSessionUser;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Provides JSON data for organizer dashboard charts.
 * <ul>
 *   <li>GET /organizer/dashboard/chart-data?type=revenue</li>
 *   <li>GET /organizer/dashboard/chart-data?type=tickets</li>
 * </ul>
 */
@WebServlet(name = "OrganizerDashboardChartDataController", urlPatterns = {"/organizer/dashboard/chart-data"})
public class OrganizerDashboardChartDataController extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(OrganizerDashboardChartDataController.class.getName());
    private final DashboardService dashboardService = new DashboardService();
    private final EventService eventService = new EventService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User user = getSessionUser(request);
        if (user == null) {
            sendJson(response, 401, "{\"error\":\"Unauthorized\"}");
            return;
        }

        String type = request.getParameter("type");
        if (type == null || type.isEmpty()) {
            sendJson(response, 400, "{\"error\":\"Missing type parameter\"}");
            return;
        }

        try {
            List<Event> myEvents = eventService.getEventsWithPermission(user.getUserId(), user.getRole(), "stats");
            if (myEvents.isEmpty()) {
                sendJson(response, 200, "[]");
                return;
            }

            int selectedEventId = 0;
            String eventIdParam = request.getParameter("eventId");
            if (eventIdParam != null && !eventIdParam.isEmpty()) {
                try {
                    selectedEventId = Integer.parseInt(eventIdParam);
                } catch (NumberFormatException ignored) {}
            }

            List<Integer> eventIds = new ArrayList<>();
            for (Event e : myEvents) {
                if (selectedEventId <= 0 || e.getEventId() == selectedEventId) {
                    eventIds.add(e.getEventId());
                }
            }

            if (eventIds.isEmpty()) {
                sendJson(response, 200, "[]");
                return;
            }

            switch (type) {
                case "revenue": {
                    int days = 7;
                    String daysParam = request.getParameter("days");
                    if (daysParam != null) {
                        try { days = Integer.parseInt(daysParam); } catch (NumberFormatException ignored) {}
                    }
                    List<Map<String, Object>> data = dashboardService.getRevenueByDaysForEvents(eventIds, days);
                    sendJson(response, 200, buildJsonArray(data));
                    break;
                }
                case "tickets": {
                    List<Map<String, Object>> data = dashboardService.getTicketDistributionForEvents(eventIds);
                    sendJson(response, 200, buildJsonArray(data));
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

    private void sendJson(HttpServletResponse response, int status, String json) throws IOException {
        response.setStatus(status);
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        try (PrintWriter out = response.getWriter()) {
            out.print(json);
            out.flush();
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
        return s.replace("\\", "\\\\").replace("\"", "\\\"");
    }
}
