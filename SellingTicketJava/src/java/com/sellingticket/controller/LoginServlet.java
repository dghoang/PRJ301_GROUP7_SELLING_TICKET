package com.sellingticket.controller;

import com.sellingticket.model.User;
import com.sellingticket.security.LoginAttemptTracker;
import com.sellingticket.service.UserService;
import java.io.IOException;
import java.util.logging.Level;
import java.util.logging.Logger;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(name = "LoginServlet", urlPatterns = {"/login"})
public class LoginServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(LoginServlet.class.getName());
    private final UserService userService = new UserService();
    private final LoginAttemptTracker tracker = LoginAttemptTracker.getInstance();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String clientIp = getClientIp(request);

        // Input validation
        if (email == null || email.trim().isEmpty()
                || password == null || password.isEmpty()) {
            request.setAttribute("error", "Vui lòng nhập email và mật khẩu!");
            request.getRequestDispatcher("login.jsp").forward(request, response);
            return;
        }

        email = email.trim().toLowerCase();

        // Rate limiting: check if blocked
        if (tracker.isBlocked(email, clientIp)) {
            int remaining = tracker.getRemainingLockSeconds(email, clientIp);
            String timeStr = formatLockTime(remaining);
            LOGGER.log(Level.WARNING, "Blocked login attempt: {0} from {1}", new Object[]{email, clientIp});
            request.setAttribute("error",
                    "Tài khoản đã bị tạm khóa do đăng nhập sai quá nhiều lần. Vui lòng thử lại sau " + timeStr + ".");
            request.getRequestDispatcher("login.jsp").forward(request, response);
            return;
        }

        User user = userService.authenticate(email, password);

        if (user == null) {
            // Record failure + show remaining attempts
            tracker.recordFailure(email, clientIp);
            int count = tracker.getAttemptCount(email, clientIp);
            int remaining = 5 - count;

            LOGGER.log(Level.WARNING, "Failed login: {0} from {1} (attempt #{2})",
                    new Object[]{email, clientIp, count});

            String errorMsg = "Email hoặc mật khẩu không đúng!";
            if (remaining > 0 && count >= 3) {
                errorMsg += " Còn " + remaining + " lần thử trước khi bị khóa.";
            } else if (remaining <= 0) {
                int lockSec = tracker.getRemainingLockSeconds(email, clientIp);
                errorMsg = "Tài khoản đã bị khóa tạm thời. Thử lại sau " + formatLockTime(lockSec) + ".";
            }

            request.setAttribute("error", errorMsg);
            request.getRequestDispatcher("login.jsp").forward(request, response);
            return;
        }

        // Success: clear attempts + session fixation protection
        tracker.reset(email, clientIp);

        LOGGER.log(Level.INFO, "User logged in: {0} (role={1})",
                new Object[]{user.getEmail(), user.getRole()});

        HttpSession oldSession = request.getSession(false);
        if (oldSession != null) {
            oldSession.invalidate();
        }
        HttpSession session = request.getSession(true);
        session.setAttribute("user", user);
        session.setAttribute("account", user);
        session.setMaxInactiveInterval(3600);

        // Toast notification
        session.setAttribute("toastMessage", "Đăng nhập thành công! Chào mừng " + user.getFullName());
        session.setAttribute("toastType", "success");

        // Redirect: check both returnUrl (from AuthFilter) and redirect (legacy)
        String returnUrl = request.getParameter("returnUrl");
        if (returnUrl == null || returnUrl.trim().isEmpty()) {
            returnUrl = request.getParameter("redirect");
        }
        String redirect = sanitizeRedirect(returnUrl);
        response.sendRedirect(request.getContextPath() + redirect);
    }

    private String sanitizeRedirect(String redirect) {
        if (redirect == null || redirect.trim().isEmpty()) return "/home";
        redirect = redirect.trim();
        if (redirect.startsWith("//") || redirect.contains("://")
                || redirect.toLowerCase().startsWith("javascript:")) {
            LOGGER.log(Level.WARNING, "Blocked open redirect: {0}", redirect);
            return "/home";
        }
        return redirect.startsWith("/") ? redirect : "/home";
    }

    private String getClientIp(HttpServletRequest request) {
        String ip = request.getHeader("X-Forwarded-For");
        if (ip != null && !ip.isEmpty()) {
            return ip.split(",")[0].trim();
        }
        return request.getRemoteAddr();
    }

    private String formatLockTime(int seconds) {
        if (seconds >= 60) {
            int min = seconds / 60;
            return min + " phút";
        }
        return seconds + " giây";
    }
}
