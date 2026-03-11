package com.sellingticket.controller;

import com.sellingticket.model.User;
import com.sellingticket.service.AuthTokenService;
import com.sellingticket.service.UserService;
import static com.sellingticket.util.ServletUtil.getSessionUser;
import static com.sellingticket.util.ServletUtil.redirectToLogin;
import java.io.IOException;
import java.util.logging.Level;
import java.util.logging.Logger;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(name = "ChangePasswordServlet", urlPatterns = {"/change-password"})
public class ChangePasswordServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(ChangePasswordServlet.class.getName());
    private final UserService userService = new UserService();
    private final AuthTokenService authTokenService = new AuthTokenService();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        User user = getSessionUser(request);
        if (user == null) {
            redirectToLogin(request, response);
            return;
        }

        String oldPassword = request.getParameter("oldPassword");
        String newPassword = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmNewPassword");

        // Block OAuth users from changing password
        if (userService.isOAuthUser(user.getUserId())) {
            redirectWithError(request, response, "Tài khoản Google không hỗ trợ đổi mật khẩu tại đây.");
            return;
        }

        // Validate required fields
        if (isBlank(oldPassword) || isBlank(newPassword) || isBlank(confirmPassword)) {
            redirectWithError(request, response, "Vui lòng điền đầy đủ thông tin!");
            return;
        }

        // Password strength: min 8 chars, 1 uppercase, 1 digit
        if (newPassword.length() < 8) {
            redirectWithError(request, response, "Mật khẩu mới phải có ít nhất 8 ký tự!");
            return;
        }
        if (!newPassword.matches(".*[A-Z].*")) {
            redirectWithError(request, response, "Mật khẩu mới phải có ít nhất 1 chữ hoa!");
            return;
        }
        if (!newPassword.matches(".*[0-9].*")) {
            redirectWithError(request, response, "Mật khẩu mới phải có ít nhất 1 chữ số!");
            return;
        }

        // Password match
        if (!newPassword.equals(confirmPassword)) {
            redirectWithError(request, response, "Mật khẩu mới không khớp!");
            return;
        }

        // Prevent reuse of old password
        if (oldPassword.equals(newPassword)) {
            redirectWithError(request, response, "Mật khẩu mới không được trùng mật khẩu cũ!");
            return;
        }

        boolean success = userService.changePassword(user.getUserId(), oldPassword, newPassword);

        if (success) {
            LOGGER.log(Level.INFO, "Password changed for user: {0}", user.getEmail());
            // Revoke all tokens (force re-login on all devices)
            authTokenService.revokeAllUserTokens(user.getUserId(), request, response);
            request.getSession().setAttribute("success", "Đổi mật khẩu thành công!");
            response.sendRedirect(request.getContextPath() + "/profile");
        } else {
            LOGGER.log(Level.WARNING, "Password change failed for user: {0}", user.getEmail());
            redirectWithError(request, response, "Mật khẩu hiện tại không đúng!");
        }
    }

    private void redirectWithError(HttpServletRequest request, HttpServletResponse response, String message)
            throws IOException {
        request.getSession().setAttribute("passwordError", message);
        response.sendRedirect(request.getContextPath() + "/profile");
    }

    private boolean isBlank(String s) {
        return s == null || s.trim().isEmpty();
    }
}
