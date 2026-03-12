package com.sellingticket.controller.api;

import com.sellingticket.model.User;
import com.sellingticket.service.EventService;
import com.sellingticket.util.JsonResponse;
import static com.sellingticket.util.ServletUtil.*;

import java.io.IOException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * Admin Event Feature Toggle API — AJAX endpoint for toggling event featured status.
 * Bypasses CsrfFilter via /api/ prefix since it uses session auth.
 *
 * POST /api/admin/events/feature
 * Body: eventId=123&featured=true
 */
@WebServlet(name = "AdminEventFeatureApiServlet", urlPatterns = {"/api/admin/events/feature"})
public class AdminEventFeatureApiServlet extends HttpServlet {

    private EventService eventService;

    @Override
    public void init() {
        eventService = new EventService();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        User user = getSessionUser(request);
        if (user == null || !"admin".equals(user.getRole())) {
            JsonResponse.forbidden("Admin access required").send(response);
            return;
        }

        int eventId = parseIntOrDefault(request.getParameter("eventId"), -1);
        boolean featured = "true".equals(request.getParameter("featured"));

        if (eventId <= 0) {
            JsonResponse.badRequest("Invalid eventId").send(response);
            return;
        }

        boolean ok = eventService.setFeatured(eventId, featured);
        if (ok) {
            JsonResponse.ok().put("message", featured ? "Đã ghim nổi bật" : "Đã bỏ ghim nổi bật").send(response);
        } else {
            JsonResponse.error(400, "Cập nhật thất bại").send(response);
        }
    }
}
