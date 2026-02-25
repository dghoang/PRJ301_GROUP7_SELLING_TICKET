package com.sellingticket.controller;

import com.sellingticket.model.User;
import com.sellingticket.service.UserService;
import static com.sellingticket.util.ServletUtil.getSessionUser;
import java.io.IOException;
import java.util.logging.Level;
import java.util.logging.Logger;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(name = "ProfileServlet", urlPatterns = {"/profile"})
public class ProfileServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(ProfileServlet.class.getName());
    private final UserService userService = new UserService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User user = getSessionUser(request);
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login?redirect=/profile");
            return;
        }

        // Load fresh user data from DB
        User freshUser = userService.getUserById(user.getUserId());
        if (freshUser != null) {
            request.setAttribute("userProfile", freshUser);
        }

        request.getRequestDispatcher("profile.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        User user = getSessionUser(request);
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String fullName = sanitize(request.getParameter("fullName"));
        String phone = sanitize(request.getParameter("phone"));

        // Validate fullName
        if (fullName == null || fullName.isEmpty()) {
            request.getSession().setAttribute("error", "Họ tên không được để trống!");
            response.sendRedirect(request.getContextPath() + "/profile");
            return;
        }
        if (fullName.length() > 100) {
            request.getSession().setAttribute("error", "Họ tên tối đa 100 ký tự!");
            response.sendRedirect(request.getContextPath() + "/profile");
            return;
        }

        // Validate phone
        if (phone != null && !phone.isEmpty() && !phone.matches("^0[0-9]{9}$")) {
            request.getSession().setAttribute("error", "Số điện thoại không hợp lệ!");
            response.sendRedirect(request.getContextPath() + "/profile");
            return;
        }

        // Update user object
        user.setFullName(fullName);
        user.setPhone(phone);

        boolean success = userService.updateProfile(user);

        if (success) {
            // Refresh session user
            request.getSession().setAttribute("user", user);
            request.getSession().setAttribute("account", user);
            request.getSession().setAttribute("success", "Cập nhật thông tin thành công!");
            LOGGER.log(Level.INFO, "Profile updated for user: {0}", user.getEmail());
        } else {
            request.getSession().setAttribute("error", "Cập nhật thất bại. Vui lòng thử lại.");
            LOGGER.log(Level.WARNING, "Profile update failed for user: {0}", user.getEmail());
        }

        response.sendRedirect(request.getContextPath() + "/profile");
    }

    private String sanitize(String s) {
        return s == null ? null : s.trim();
    }
}
