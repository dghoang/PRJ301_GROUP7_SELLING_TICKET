package com.sellingticket.controller.api;

import com.sellingticket.model.Event;
import com.sellingticket.model.PageResult;
import com.sellingticket.service.EventService;
import com.sellingticket.util.JsonResponse;
import static com.sellingticket.util.ServletUtil.*;

import java.io.IOException;
import java.text.SimpleDateFormat;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * Public Events API — JSON endpoint for AJAX search/filter/pagination.
 * No authentication required (shows only approved events).
 *
 * GET /api/events?q=keyword&category=slug&dateFrom=2024-01-01&dateTo=2024-12-31
 *     &priceRange=lt500|500to1000|gt1000&sort=date_asc&page=1&size=12
 */
@WebServlet(name = "EventApiServlet", urlPatterns = {"/api/events"})
public class EventApiServlet extends HttpServlet {

    private EventService eventService;

    @Override
    public void init() {
        eventService = new EventService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        String keyword = request.getParameter("q");
        String category = request.getParameter("category");
        String dateFrom = request.getParameter("dateFrom");
        String dateTo = request.getParameter("dateTo");
        String sort = request.getParameter("sort");
        int page = parseIntOrDefault(request.getParameter("page"), 1);
        int size = parseIntOrDefault(request.getParameter("size"), 12);

        Double priceMin = null, priceMax = null;
        String priceRange = request.getParameter("priceRange");
        if (priceRange != null && !priceRange.isEmpty()) {
            switch (priceRange) {
                case "lt500":
                    priceMax = 499999.99;
                    break;
                case "500to1000":
                    priceMin = 500000.0;
                    priceMax = 1000000.0;
                    break;
                case "gt1000":
                    priceMin = 1000000.01;
                    break;
                default:
                    break;
            }
        } else {
            // Backward compatibility: support legacy priceMin/priceMax params if provided.
            String priceMinStr = request.getParameter("priceMin");
            String priceMaxStr = request.getParameter("priceMax");
            if (priceMinStr != null && !priceMinStr.isEmpty()) {
                priceMin = parseDoubleOrDefault(priceMinStr, 0);
            }
            if (priceMaxStr != null && !priceMaxStr.isEmpty()) {
                priceMax = parseDoubleOrDefault(priceMaxStr, 0);
            }
        }

        PageResult<Event> result = eventService.searchEventsPaged(
                keyword, category, dateFrom, dateTo, priceMin, priceMax, sort, page, size);

        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm");

        JsonResponse json = JsonResponse.ok()
                .put("totalItems", result.getTotalItems())
                .put("totalPages", result.getTotalPages())
                .put("currentPage", result.getCurrentPage())
                .put("pageSize", result.getPageSize());

        json.startArray("items");
        for (Event e : result.getItems()) {
            StringBuilder item = new StringBuilder("{");
            item.append("\"eventId\":").append(e.getEventId()).append(",");
            item.append("\"title\":\"").append(escapeJsonValue(e.getTitle())).append("\",");
            item.append("\"slug\":\"").append(escapeJsonValue(e.getSlug())).append("\",");
            item.append("\"bannerImage\":\"").append(escapeJsonValue(e.getBannerImage() != null ? e.getBannerImage() : "")).append("\",");
            item.append("\"location\":\"").append(escapeJsonValue(e.getLocation() != null ? e.getLocation() : "")).append("\",");
            item.append("\"address\":\"").append(escapeJsonValue(e.getAddress() != null ? e.getAddress() : "")).append("\",");
            item.append("\"startDate\":\"").append(e.getStartDate() != null ? sdf.format(e.getStartDate()) : "").append("\",");
            item.append("\"endDate\":\"").append(e.getEndDate() != null ? sdf.format(e.getEndDate()) : "").append("\",");
            item.append("\"status\":\"").append(escapeJsonValue(e.getStatus())).append("\",");
            item.append("\"categoryName\":\"").append(escapeJsonValue(e.getCategoryName() != null ? e.getCategoryName() : "")).append("\",");
            item.append("\"organizerName\":\"").append(escapeJsonValue(e.getOrganizerName() != null ? e.getOrganizerName() : "")).append("\",");
            item.append("\"minPrice\":").append(e.getMinPrice()).append(",");
            item.append("\"views\":").append(e.getViews()).append(",");
            item.append("\"isFeatured\":").append(e.isFeatured());
            item.append("}");
            json.arrayElement(item.toString());
        }
        json.endArray();
        json.send(response);
    }

    private static String escapeJsonValue(String value) {
        if (value == null) return "";
        return value.replace("\\", "\\\\")
                     .replace("\"", "\\\"")
                     .replace("\n", "\\n")
                     .replace("\r", "\\r")
                     .replace("\t", "\\t");
    }
}
