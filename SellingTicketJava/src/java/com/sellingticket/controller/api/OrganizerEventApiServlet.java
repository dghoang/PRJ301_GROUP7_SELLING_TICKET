package com.sellingticket.controller.api;

import com.sellingticket.model.Event;
import com.sellingticket.model.PageResult;
import com.sellingticket.model.User;
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
 * Organizer Events API — JSON endpoint for organizer's event management.
 * Requires organizer role. Only returns events owned by the current user.
 *
 * GET /api/organizer/events?q=keyword&status=approved&status=pending&page=1&size=12
 */
@WebServlet(name = "OrganizerEventApiServlet", urlPatterns = {"/api/organizer/events"})
public class OrganizerEventApiServlet extends HttpServlet {

    private EventService eventService;

    @Override
    public void init() {
        eventService = new EventService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        User user = getSessionUser(request);
        if (user == null) {
            JsonResponse.unauthorized().send(response);
            return;
        }
        String role = user.getRole();
        // Allow admin, organizer, and customer (customer may own draft events)
        if (!"organizer".equals(role) && !"admin".equals(role) && !"customer".equals(role)) {
            JsonResponse.unauthorized().send(response);
            return;
        }

        String keyword = request.getParameter("q");
        String[] statuses = request.getParameterValues("status");
        int page = parseIntOrDefault(request.getParameter("page"), 1);
        int size = parseIntOrDefault(request.getParameter("size"), 12);

        PageResult<Event> result;
        if ("admin".equals(role)) {
            // Admin sees all events across all organizers
            result = eventService.getAllEventsPaged(keyword, statuses, null, page, size);
        } else {
            // organizer and customer: only see their own events
            result = eventService.getEventsByOrganizerPaged(
                    user.getUserId(), keyword, statuses, page, size);
        }

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
            item.append("\"title\":\"").append(esc(e.getTitle())).append("\",");
            item.append("\"slug\":\"").append(esc(e.getSlug())).append("\",");
            item.append("\"bannerImage\":\"").append(esc(e.getBannerImage())).append("\",");
            item.append("\"location\":\"").append(esc(e.getLocation())).append("\",");
            item.append("\"startDate\":\"").append(e.getStartDate() != null ? sdf.format(e.getStartDate()) : "").append("\",");
            item.append("\"endDate\":\"").append(e.getEndDate() != null ? sdf.format(e.getEndDate()) : "").append("\",");
            item.append("\"status\":\"").append(esc(e.getStatus())).append("\",");
            item.append("\"categoryName\":\"").append(esc(e.getCategoryName())).append("\",");
            item.append("\"soldTickets\":").append(e.getSoldTickets()).append(",");
            item.append("\"totalTickets\":").append(e.getTotalTickets()).append(",");
            item.append("\"revenue\":").append(e.getRevenue());
            item.append("}");
            json.arrayElement(item.toString());
        }
        json.endArray();
        json.send(response);
    }

    private static String esc(String v) {
        if (v == null) return "";
        return v.replace("\\", "\\\\").replace("\"", "\\\"")
                .replace("\n", "\\n").replace("\r", "\\r");
    }
}
