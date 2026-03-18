package com.sellingticket.controller;

import com.sellingticket.model.Notification;
import com.sellingticket.model.User;
import com.sellingticket.service.NotificationService;
import static com.sellingticket.util.ServletUtil.sendJson;

import java.io.IOException;
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
 * Universal Notification Center — accessible by ALL authenticated users.
 * GET  /notifications        → notification page (role-adaptive)
 * GET  /notifications/count  → JSON {unread: N}
 * POST /notifications/read   → mark single read (AJAX)
 * POST /notifications/read-all → mark all read (AJAX)
 */
@WebServlet(name = "NotificationController", urlPatterns = {"/notifications", "/notifications/*"})
public class NotificationController extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(NotificationController.class.getName());
    private final NotificationService notifService = new NotificationService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = (User) request.getSession().getAttribute("account");
        if (user == null) {
            user = (User) request.getSession().getAttribute("user");
        }
        if (user == null) { response.sendError(401); return; }

        String path = request.getPathInfo();

        // JSON count endpoint
        if ("/count".equals(path)) {
            int count = notifService.countUnread(user.getUserId());
            Map<String, Object> data = new HashMap<>();
            data.put("unread", count);
            sendJson(response, data);
            return;
        }

        // Default: show notifications page
        List<Notification> notifications = notifService.getByUser(user.getUserId(), 50);
        int unreadCount = notifService.countUnread(user.getUserId());

        request.setAttribute("notifications", notifications);
        request.setAttribute("unreadCount", unreadCount);
        request.setAttribute("userRole", user.getRole());
        request.getRequestDispatcher("/notifications.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = (User) request.getSession().getAttribute("account");
        if (user == null) {
            user = (User) request.getSession().getAttribute("user");
        }
        if (user == null) { response.sendError(401); return; }

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
                result.put("error", "Unknown action");
            }
        } catch (Exception e) {
            LOGGER.log(Level.WARNING, "Notification action failed", e);
            result.put("success", false);
        }
        sendJson(response, result);
    }
}
