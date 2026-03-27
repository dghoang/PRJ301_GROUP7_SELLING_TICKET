package com.sellingticket.controller.api;

import com.sellingticket.model.Event;
import com.sellingticket.model.PageResult;
import com.sellingticket.model.User;
import com.sellingticket.service.EventService;
import com.sellingticket.util.JsonResponse;
import com.sellingticket.util.JsonUtil;
import static com.sellingticket.util.ServletUtil.*;

import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Map;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * Admin Events API — JSON endpoint for admin event management table.
 * Requires admin role (enforced by AuthFilter on /api/admin/*).
 *
 * GET /api/admin/events?q=keyword&status=pending&status=approved&category=music&page=1&size=20
 */
@WebServlet(name = "AdminEventApiServlet", urlPatterns = {"/api/admin/events"})
public class AdminEventApiServlet extends HttpServlet {

    private EventService eventService;

    @Override
    public void init() {
        eventService = new EventService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        User user = getSessionUser(request);
        if (user == null || !"admin".equals(user.getRole())) {
            JsonResponse.unauthorized().send(response);
            return;
        }

        String keyword = request.getParameter("q");
        String[] statuses = request.getParameterValues("status");
        String category = request.getParameter("category");
        int page = Math.max(1, parseIntOrDefault(request.getParameter("page"), 1));
        int size = Math.max(1, Math.min(100, parseIntOrDefault(request.getParameter("size"), 20)));

        PageResult<Event> result = eventService.getAllEventsPaged(keyword, statuses, category, page, size);
        Map<String, Integer> statusCounts = eventService.getAdminEventStatusCounts(keyword, category);
        int pendingCount = statusCounts.getOrDefault("pending", 0);
        int approvedCount = statusCounts.getOrDefault("approved", 0);
        int endedCount = statusCounts.getOrDefault("ended", 0);
        int rejectedCount = statusCounts.getOrDefault("rejected", 0);

        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm");

        JsonResponse json = JsonResponse.ok()
                .put("totalItems", result.getTotalItems())
                .put("totalPages", result.getTotalPages())
                .put("currentPage", result.getCurrentPage())
            .put("pageSize", result.getPageSize())
            .put("pendingCount", pendingCount)
            .put("approvedCount", approvedCount)
            .put("endedCount", endedCount)
            .put("rejectedCount", rejectedCount)
            .put("statusTotal", pendingCount + approvedCount + endedCount + rejectedCount);

        json.startArray("items");
        for (Event e : result.getItems()) {
            StringBuilder item = new StringBuilder("{");
            item.append("\"eventId\":").append(e.getEventId()).append(",");
            item.append("\"title\":\"").append(JsonUtil.esc(e.getTitle())).append("\",");
            item.append("\"slug\":\"").append(JsonUtil.esc(e.getSlug())).append("\",");
            item.append("\"bannerImage\":\"").append(JsonUtil.esc(e.getBannerImage())).append("\",");
            item.append("\"location\":\"").append(JsonUtil.esc(e.getLocation())).append("\",");
            item.append("\"startDate\":\"").append(e.getStartDate() != null ? sdf.format(e.getStartDate()) : "").append("\",");
            item.append("\"endDate\":\"").append(e.getEndDate() != null ? sdf.format(e.getEndDate()) : "").append("\",");
            item.append("\"status\":\"").append(JsonUtil.esc(e.getStatus())).append("\",");
            item.append("\"categoryName\":\"").append(JsonUtil.esc(e.getCategoryName())).append("\",");
            item.append("\"organizerName\":\"").append(JsonUtil.esc(e.getOrganizerName())).append("\",");
            item.append("\"soldTickets\":").append(e.getSoldTickets()).append(",");
            item.append("\"totalTickets\":").append(e.getTotalTickets()).append(",");
            item.append("\"revenue\":").append(e.getRevenue()).append(",");
            item.append("\"isFeatured\":").append(e.isFeatured());
            item.append("}");
            json.arrayElement(item.toString());
        }
        json.endArray();
        json.send(response);
    }


}
