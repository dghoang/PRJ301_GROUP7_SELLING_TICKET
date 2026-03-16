package com.sellingticket.controller.api;

import com.sellingticket.model.PageResult;
import com.sellingticket.model.User;
import com.sellingticket.service.UserService;
import com.sellingticket.util.JsonResponse;
import static com.sellingticket.util.ServletUtil.*;

import java.io.IOException;
import java.text.SimpleDateFormat;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * Admin Users API — JSON endpoint for admin user management table.
 * Requires admin role.
 *
 * GET /api/admin/users?q=keyword&role=admin&role=organizer&isActive=true&page=1&size=20
 */
@WebServlet(name = "AdminUserApiServlet", urlPatterns = {"/api/admin/users"})
public class AdminUserApiServlet extends HttpServlet {

    private UserService userService;

    @Override
    public void init() {
        userService = new UserService();
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
        String[] roles = request.getParameterValues("role");
        String isActiveStr = request.getParameter("isActive");
        Boolean isActive = null;
        if ("true".equals(isActiveStr)) isActive = true;
        else if ("false".equals(isActiveStr)) isActive = false;

        int page = parseIntOrDefault(request.getParameter("page"), 1);
        int size = parseIntOrDefault(request.getParameter("size"), 20);

        PageResult<User> result = userService.searchUsersPaged(keyword, roles, isActive, page, size);

        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm");

        JsonResponse json = JsonResponse.ok()
                .put("totalItems", result.getTotalItems())
                .put("totalPages", result.getTotalPages())
                .put("currentPage", result.getCurrentPage())
                .put("pageSize", result.getPageSize());

        json.startArray("items");
        for (User u : result.getItems()) {
            StringBuilder item = new StringBuilder("{");
            item.append("\"userId\":").append(u.getUserId()).append(",");
            item.append("\"email\":\"").append(esc(u.getEmail())).append("\",");
            item.append("\"fullName\":\"").append(esc(u.getFullName())).append("\",");
            item.append("\"phone\":\"").append(esc(u.getPhone())).append("\",");
            item.append("\"role\":\"").append(esc(u.getRole())).append("\",");
            item.append("\"avatar\":\"").append(esc(u.getAvatar())).append("\",");
            item.append("\"isActive\":").append(u.isActive()).append(",");
            item.append("\"isDeleted\":").append(u.isDeleted()).append(",");
            item.append("\"createdAt\":\"").append(u.getCreatedAt() != null ? sdf.format(u.getCreatedAt()) : "").append("\"");
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
