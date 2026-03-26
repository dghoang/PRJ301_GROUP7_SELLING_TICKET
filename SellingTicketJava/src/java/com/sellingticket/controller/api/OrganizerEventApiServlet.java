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
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
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

        // Use a single source of truth for all roles to avoid mismatch with counters in organizer/events.jsp.
        List<Event> accessible = eventService.getAccessibleEvents(user.getUserId(), role);
        List<Event> filtered = new ArrayList<>();
        for (Event e : accessible) {
            if (!matchesKeyword(e, keyword)) continue;
            if (!matchesAnyStatus(e, statuses)) continue;
            filtered.add(e);
        }

        filtered.sort((a, b) -> {
            Date da = a.getCreatedAt();
            Date db = b.getCreatedAt();
            if (da == null && db == null) return 0;
            if (da == null) return 1;
            if (db == null) return -1;
            return db.compareTo(da);
        });

        int safePage = Math.max(1, page);
        int safeSize = Math.max(1, Math.min(100, size));
        int totalItems = filtered.size();
        int from = Math.min((safePage - 1) * safeSize, totalItems);
        int to = Math.min(from + safeSize, totalItems);
        List<Event> pageItems = new ArrayList<>(filtered.subList(from, to));
        PageResult<Event> result = new PageResult<>(pageItems, totalItems, safePage, safeSize);

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
            item.append("\"title\":\"").append(JsonUtil.esc(e.getTitle())).append("\",");
            item.append("\"slug\":\"").append(JsonUtil.esc(e.getSlug())).append("\",");
            item.append("\"bannerImage\":\"").append(JsonUtil.esc(e.getBannerImage())).append("\",");
            item.append("\"location\":\"").append(JsonUtil.esc(e.getLocation())).append("\",");
            item.append("\"startDate\":\"").append(e.getStartDate() != null ? sdf.format(e.getStartDate()) : "").append("\",");
            item.append("\"endDate\":\"").append(e.getEndDate() != null ? sdf.format(e.getEndDate()) : "").append("\",");
            item.append("\"status\":\"").append(JsonUtil.esc(e.getStatus())).append("\",");
            item.append("\"categoryName\":\"").append(JsonUtil.esc(e.getCategoryName())).append("\",");
            item.append("\"soldTickets\":").append(e.getSoldTickets()).append(",");
            item.append("\"totalTickets\":").append(e.getTotalTickets()).append(",");
            item.append("\"revenue\":").append(e.getRevenue());
            item.append("}");
            json.arrayElement(item.toString());
        }
        json.endArray();
        json.send(response);
    }



    private static boolean matchesKeyword(Event event, String keyword) {
        if (keyword == null || keyword.trim().isEmpty()) return true;
        String kw = keyword.trim().toLowerCase();
        return toSafeLower(event.getTitle()).contains(kw)
                || toSafeLower(event.getDescription()).contains(kw)
                || toSafeLower(event.getLocation()).contains(kw);
    }

    private static boolean matchesAnyStatus(Event event, String[] statuses) {
        if (statuses == null || statuses.length == 0) return true;
        String eventStatus = toSafeLower(event.getStatus());
        for (String s : statuses) {
            if (s == null || s.trim().isEmpty()) continue;
            if (eventStatus.equals(s.trim().toLowerCase())) return true;
        }
        return false;
    }

    private static String toSafeLower(String value) {
        return value == null ? "" : value.toLowerCase();
    }
}
