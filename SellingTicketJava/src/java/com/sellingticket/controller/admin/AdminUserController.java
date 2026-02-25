package com.sellingticket.controller.admin;

import com.sellingticket.model.User;
import com.sellingticket.service.UserService;
import static com.sellingticket.util.ServletUtil.parseIntOrDefault;

import java.io.IOException;
import java.util.List;
import java.util.Set;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(name = "AdminUserController", urlPatterns = {"/admin/users", "/admin/users/*"})
public class AdminUserController extends HttpServlet {

    private static final Set<String> VALID_ROLES = Set.of("customer", "organizer", "admin");
    private final UserService userService = new UserService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

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

        request.setAttribute("users", userService.getAllUsers());
        request.setAttribute("totalUsers", userService.getTotalUsers());
        request.getRequestDispatcher("/admin/users.jsp").forward(request, response);
    }

    private void searchUsers(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String keyword = request.getParameter("q");
        List<User> users = (keyword != null && !keyword.isEmpty())
                ? userService.searchUsers(keyword)
                : userService.getAllUsers();

        if (keyword != null) request.setAttribute("searchKeyword", keyword);
        request.setAttribute("users", users);
        request.getRequestDispatcher("/admin/users.jsp").forward(request, response);
    }

    private void viewUser(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int userId = parseIntOrDefault(request.getParameter("id"), -1);
        if (userId <= 0) {
            response.sendRedirect(request.getContextPath() + "/admin/users?error=notfound");
            return;
        }

        User user = userService.getUserById(userId);
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/admin/users?error=notfound");
            return;
        }

        request.setAttribute("user", user);
        request.getRequestDispatcher("/admin/user-detail.jsp").forward(request, response);
    }

    private void updateRole(HttpServletRequest request, HttpServletResponse response) throws IOException {
        int userId = parseIntOrDefault(request.getParameter("userId"), -1);
        String role = request.getParameter("role");

        boolean success = VALID_ROLES.contains(role) && userId > 0 && userService.updateUserRole(userId, role);
        String result = success ? "success=role_updated" : "error=update_failed";
        response.sendRedirect(request.getContextPath() + "/admin/users?" + result);
    }

    private void deactivateUser(HttpServletRequest request, HttpServletResponse response) throws IOException {
        int userId = parseIntOrDefault(request.getParameter("userId"), -1);
        String result = (userId > 0 && userService.deactivateUser(userId)) ? "success=deactivated" : "error=deactivate_failed";
        response.sendRedirect(request.getContextPath() + "/admin/users?" + result);
    }
}
