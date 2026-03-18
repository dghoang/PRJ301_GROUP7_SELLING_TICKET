package com.sellingticket.controller.admin;

import com.sellingticket.model.User;
import com.sellingticket.service.ActivityLogService;
import com.sellingticket.service.DashboardService;
import com.sellingticket.service.UserService;
import com.sellingticket.util.AppConstants;
import com.sellingticket.util.FlashUtil;
import static com.sellingticket.util.ServletUtil.parseIntOrDefault;

import java.io.IOException;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
import java.util.Set;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(name = "AdminUserController", urlPatterns = {"/admin/users", "/admin/users/*"})
public class AdminUserController extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(AdminUserController.class.getName());
    private static final Set<String> VALID_ROLES = Set.of("customer", "admin", "support_agent");
    private final UserService userService = new UserService();
    private final DashboardService dashboardService = new DashboardService();
    private final ActivityLogService activityLog = new ActivityLogService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        FlashUtil.apply(request);
        String action = getAction(request.getPathInfo());

        switch (action) {
            case "search": searchUsers(request, response); break;
            case "view":   viewUser(request, response); break;
            default:       listUsers(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = getAction(request.getPathInfo());

        switch (action) {
            case "update-role": updateRole(request, response); break;
            case "deactivate":  deactivateUser(request, response); break;
            case "activate":    activateUser(request, response); break;
            default: response.sendRedirect(request.getContextPath() + "/admin/users");
        }
    }

    private String getAction(String pathInfo) {
        if (pathInfo == null || pathInfo.equals("/")) return "list";
        String action = pathInfo.substring(1);
        return action.matches("\\d+") ? "view" : action;
    }

    private void listUsers(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            String filter = request.getParameter("filter");
            List<User> allUsers = userService.getAllUsers();
            List<User> users = new java.util.ArrayList<>(allUsers);

            if ("active".equals(filter)) {
                users.removeIf(u -> !u.isActive());
            } else if ("locked".equals(filter)) {
                users.removeIf(User::isActive);
            } else if ("support_agent".equals(filter)) {
                users.removeIf(u -> !"SUPPORT_AGENT".equalsIgnoreCase(u.getRole()));
            }

            request.setAttribute("users", users);
            request.setAttribute("totalUsers", allUsers.size());
            request.setAttribute("currentFilter", filter);
            request.setAttribute("pendingCount", dashboardService.getPendingEventsCount());

            int active = 0, supportAgents = 0, locked = 0;
            for (User u : allUsers) {
                if (u.isActive()) active++; else locked++;
                if ("SUPPORT_AGENT".equalsIgnoreCase(u.getRole())) supportAgents++;
            }
            request.setAttribute("activeUsers", active);
            request.setAttribute("supportAgentCount", supportAgents);
            request.setAttribute("lockedUsers", locked);

            request.getRequestDispatcher("/admin/users.jsp").forward(request, response);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to load users", e);
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }

    private void searchUsers(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            String keyword = request.getParameter("q");
            List<User> users = (keyword != null && !keyword.isEmpty())
                    ? userService.searchUsers(keyword)
                    : userService.getAllUsers();

            if (keyword != null) request.setAttribute("searchKeyword", keyword);
            request.setAttribute("users", users);
            request.getRequestDispatcher("/admin/users.jsp").forward(request, response);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to search users", e);
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }

    private void viewUser(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int userId = getUserIdFromPath(request.getPathInfo());
        if (userId <= 0) {
            FlashUtil.error(request, "Không tìm thấy người dùng!");
            response.sendRedirect(request.getContextPath() + "/admin/users");
            return;
        }

        User user = userService.getUserById(userId);
        if (user == null) {
            FlashUtil.error(request, "Không tìm thấy người dùng!");
            response.sendRedirect(request.getContextPath() + "/admin/users");
            return;
        }

        request.setAttribute("user", user);
        request.getRequestDispatcher("/admin/user-detail.jsp").forward(request, response);
    }

    private int getUserIdFromPath(String pathInfo) {
        if (pathInfo == null) {
            return -1;
        }
        String trimmed = pathInfo.startsWith("/") ? pathInfo.substring(1) : pathInfo;
        if (!trimmed.matches("\\d+")) {
            return -1;
        }
        return parseIntOrDefault(trimmed, -1);
    }

    private void updateRole(HttpServletRequest request, HttpServletResponse response) throws IOException {
        int userId = parseIntOrDefault(request.getParameter("userId"), -1);
        String role = request.getParameter("role");

        if (!VALID_ROLES.contains(role) || userId <= 0) {
            FlashUtil.error(request, "Cập nhật vai trò thất bại!");
            response.sendRedirect(request.getContextPath() + "/admin/users");
            return;
        }

        if ("admin".equals(role)) {
            String privateKey = request.getParameter("adminKey");
            if (privateKey == null || !privateKey.equals(AppConstants.ADMIN_PRIVATE_KEY)) {
                FlashUtil.error(request, "Mật khẩu admin không đúng!");
                response.sendRedirect(request.getContextPath() + "/admin/users");
                return;
            }
        }

        boolean success = userService.updateUserRole(userId, role);
        if (success) {
            FlashUtil.success(request, "Cập nhật vai trò thành công!");
            User admin = (User) request.getSession().getAttribute("user");
            activityLog.logAction(admin, "user_role_updated", "user", userId,
                    "Cập nhật vai trò user #" + userId + " → " + role, request);
        } else {
            FlashUtil.error(request, "Cập nhật vai trò thất bại!");
        }
        response.sendRedirect(request.getContextPath() + "/admin/users");
    }

    private void deactivateUser(HttpServletRequest request, HttpServletResponse response) throws IOException {
        int userId = parseIntOrDefault(request.getParameter("userId"), -1);
        if (userId > 0 && userService.deactivateUser(userId)) {
            FlashUtil.success(request, "Người dùng đã bị khóa!");
            User admin = (User) request.getSession().getAttribute("user");
            activityLog.logAction(admin, "user_deactivated", "user", userId,
                    "Khóa tài khoản user #" + userId, request);
        } else {
            FlashUtil.error(request, "Khóa tài khoản thất bại!");
        }
        response.sendRedirect(request.getContextPath() + "/admin/users");
    }

    private void activateUser(HttpServletRequest request, HttpServletResponse response) throws IOException {
        int userId = parseIntOrDefault(request.getParameter("userId"), -1);
        if (userId > 0 && userService.activateUser(userId)) {
            FlashUtil.success(request, "Người dùng đã được mở khóa!");
            User admin = (User) request.getSession().getAttribute("user");
            activityLog.logAction(admin, "user_activated", "user", userId,
                    "Mở khóa tài khoản user #" + userId, request);
        } else {
            FlashUtil.error(request, "Mở khóa tài khoản thất bại!");
        }
        response.sendRedirect(request.getContextPath() + "/admin/users");
    }
}
