package com.sellingticket.controller.admin;

import com.sellingticket.model.Event;
import com.sellingticket.service.DashboardService;
import com.sellingticket.service.EventService;
import static com.sellingticket.util.ServletUtil.sendJson;

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
 * Admin dashboard — displays stats + provides JSON API for chart data.
 * Uses DashboardService (not DAO directly).
 *
 * <p>Endpoints:
 * <ul>
 *   <li>GET /admin/dashboard — JSP page with stats</li>
 *   <li>GET /admin/dashboard/chart-data?type=revenue&days=7 — JSON chart data</li>
 *   <li>GET /admin/dashboard/chart-data?type=category — JSON category distribution</li>
 * </ul>
 */
@WebServlet(name = "AdminDashboardController", urlPatterns = {"/admin/dashboard", "/admin/dashboard/chart-data"})
public class AdminDashboardController extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(AdminDashboardController.class.getName());
    private final DashboardService dashboardService = new DashboardService();
    private final EventService eventService = new EventService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String uri = request.getRequestURI();

        // --- JSON API endpoint for chart data ---
        if (uri.endsWith("/chart-data")) {
            handleChartDataApi(request, response);
            return;
        }

        // --- JSP page with dashboard stats ---
        try {
            Map<String, Object> stats = dashboardService.getAdminDashboardStats();
            for (Map.Entry<String, Object> entry : stats.entrySet()) {
                request.setAttribute(entry.getKey(), entry.getValue());
            }

            List<Event> pendingEvents = eventService.getPendingEvents();
            request.setAttribute("pendingEventsList", pendingEvents);

            request.getRequestDispatcher("/admin/dashboard.jsp").forward(request, response);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to load admin dashboard", e);
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }

    /**
     * JSON API: returns chart data based on type parameter.
     */
    private void handleChartDataApi(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
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
                    List<Map<String, Object>> data = dashboardService.getRevenueByDays(days);
                    sendJson(response, buildJsonArray(data));
                    break;
                }
                case "category": {
                    List<Map<String, Object>> data = dashboardService.getCategoryDistribution();
                    sendJson(response, buildJsonArray(data));
                    break;
                }
                default:
                    sendJson(response, 400, "{\"error\":\"Invalid type parameter\"}");
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to load chart data: " + type, e);
            sendJson(response, 500, "{\"error\":\"Internal server error\"}");
        }
    }

    /**
     * Simple JSON array builder from list of maps (no external lib needed).
     */
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
        return s.replace("\\", "\\\\").replace("\"", "\\\"");
    }
}
