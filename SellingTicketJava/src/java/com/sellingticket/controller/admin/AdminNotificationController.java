package com.sellingticket.controller.admin;

import com.sellingticket.model.User;
import com.sellingticket.service.NotificationService;
import static com.sellingticket.util.ServletUtil.sendJson;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * Admin Notification Controller — backward-compatible redirect.
 * GET  /admin/notifications       → redirect to /notifications
 * GET  /admin/notifications/count → JSON (kept for cached JS)
 * POST /admin/notifications/read  → redirect to /notifications/read
 * POST /admin/notifications/read-all → redirect to /notifications/read-all
 */
@WebServlet(name = "AdminNotificationController", urlPatterns = {"/admin/notifications", "/admin/notifications/*"})
public class AdminNotificationController extends HttpServlet {

    private final NotificationService notifService = new NotificationService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = (User) request.getSession().getAttribute("user");
        if (user == null) user = (User) request.getSession().getAttribute("account");

        String path = request.getPathInfo();

        // JSON count — keep working directly for cached scripts
        if ("/count".equals(path) && user != null) {
            int count = notifService.countUnread(user.getUserId());
            Map<String, Object> data = new HashMap<>();
            data.put("unread", count);
            sendJson(response, data);
            return;
        }

        // All other GET requests: redirect to universal notifications
        response.sendRedirect(request.getContextPath() + "/notifications");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = (User) request.getSession().getAttribute("user");
        if (user == null) user = (User) request.getSession().getAttribute("account");
        if (user == null) { response.sendError(401); return; }

        // Forward POST actions to universal controller
        String path = request.getPathInfo();
        Map<String, Object> result = new HashMap<>();

        try {
            if ("/read".equals(path)) {
                int notifId = Integer.parseInt(request.getParameter("id"));
                boolean ok = notifService.markRead(notifId, user.getUserId());
                result.put("success", ok);
            } else if ("/read-all".equals(path)) {
                int updated = notifService.markAllRead(user.getUserId());
                result.put("success", true);
                result.put("updated", updated);
            } else {
                result.put("success", false);
            }
        } catch (Exception e) {
            result.put("success", false);
        }
        sendJson(response, result);
    }
}
