package com.sellingticket.controller;

import com.sellingticket.model.User;
import com.sellingticket.security.LoginAttemptTracker;
import com.sellingticket.service.AuthTokenService;
import com.sellingticket.service.UserService;
import java.io.IOException;
import java.util.UUID;
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
    private static final int MAX_EMAIL_LENGTH = 255;
    private static final int MAX_PASSWORD_LENGTH = 128;

    private final UserService userService = new UserService();
    private final AuthTokenService authTokenService = new AuthTokenService();
    private final LoginAttemptTracker tracker = LoginAttemptTracker.getInstance();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Anti-cache: prevent browser from caching the login page with credentials
        setNoCacheHeaders(response);
        request.getRequestDispatcher("login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        setNoCacheHeaders(response);
        request.setCharacterEncoding("UTF-8");

        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String clientIp = getClientIp(request);

        // === INPUT VALIDATION ===
        if (email == null || email.trim().isEmpty()
                || password == null || password.isEmpty()) {
            showError(request, response, "Vui lòng nhập email và mật khẩu!");
            return;
        }

        // Length limits — prevent DoS via oversized payloads
        if (email.length() > MAX_EMAIL_LENGTH) {
            showError(request, response, "Email không hợp lệ!");
            return;
        }
        if (password.length() > MAX_PASSWORD_LENGTH) {
            showError(request, response, "Mật khẩu quá dài!");
            return;
        }

        email = email.trim().toLowerCase();

        // Email format check (prevents malformed input from reaching DB)
        if (!email.matches("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$")) {
            showError(request, response, "Email không hợp lệ!");
            return;
        }

        // === RATE LIMITING ===
        // Check IP-only block (defense against distributed attacks on different emails)
        if (tracker.isIpBlocked(clientIp)) {
            LOGGER.log(Level.WARNING, "IP blocked: {0}", clientIp);
            showError(request, response,
                    "Quá nhiều lần đăng nhập từ địa chỉ IP này. Vui lòng thử lại sau.");
            return;
        }

        // Check email+IP block
        if (tracker.isBlocked(email, clientIp)) {
            int remaining = tracker.getRemainingLockSeconds(email, clientIp);
            String timeStr = formatLockTime(remaining);
            LOGGER.log(Level.WARNING, "Blocked login attempt: {0} from {1}", new Object[]{email, clientIp});
            showError(request, response,
                    "Tài khoản đã bị tạm khóa do đăng nhập sai quá nhiều lần. Vui lòng thử lại sau " + timeStr + ".");
            return;
        }

        // === AUTHENTICATION ===
        long startTime = System.nanoTime();
        User user = userService.authenticate(email, password);

        // Constant-time delay: ensure failed and successful logins take ~same time
        // Prevents timing attacks that reveal whether an email exists
        enforceMinimumDelay(startTime, 200);

        if (user == null) {
            tracker.recordFailure(email, clientIp);
            int count = tracker.getAttemptCount(email, clientIp);
            int remaining = 5 - count;

            LOGGER.log(Level.WARNING, "Failed login: {0} from {1} (attempt #{2})",
                    new Object[]{email, clientIp, count});

            // Generic error message — do NOT reveal if email exists
            String errorMsg = "Email hoặc mật khẩu không đúng!";
            if (remaining > 0 && count >= 3) {
                errorMsg += " Còn " + remaining + " lần thử trước khi bị khóa.";
            } else if (remaining <= 0) {
                int lockSec = tracker.getRemainingLockSeconds(email, clientIp);
                errorMsg = "Tài khoản đã bị khóa tạm thời. Thử lại sau " + formatLockTime(lockSec) + ".";
            }

            showError(request, response, errorMsg);
            return;
        }

        // Check if user account is active
        if (!user.isActive()) {
            LOGGER.log(Level.WARNING, "Login attempt to deactivated account: {0}", email);
            showError(request, response,
                    "Tài khoản đã bị khóa. Vui lòng liên hệ quản trị viên.");
            return;
        }

        // === SUCCESS ===
        tracker.reset(email, clientIp);
        boolean rememberMe = "on".equals(request.getParameter("remember"));

        // Record last login IP + timestamp for audit
        userService.updateLastLogin(user.getUserId(), clientIp);

        LOGGER.log(Level.INFO, "User logged in: {0} (role={1}, remember={2})",
                new Object[]{user.getEmail(), user.getRole(), rememberMe});

        // Session fixation protection
        HttpSession oldSession = request.getSession(false);
        if (oldSession != null) {
            oldSession.invalidate();
        }
        HttpSession session = request.getSession(true);
        session.setAttribute("user", user);
        session.setAttribute("account", user);
        if (session.getAttribute("csrf_token") == null) {
            session.setAttribute("csrf_token", UUID.randomUUID().toString());
            session.removeAttribute("csrf_token_prev");
        }
        session.setMaxInactiveInterval(3600);

        // Issue JWT tokens (access + refresh) as HttpOnly cookies
        authTokenService.issueTokens(response, user, request, rememberMe);

        // Toast notification
        session.setAttribute("toastMessage", "Đăng nhập thành công! Chào mừng " + user.getFullName());
        session.setAttribute("toastType", "success");

        // Redirect: check returnUrl (from AuthFilter) and redirect (legacy)
        String returnUrl = request.getParameter("returnUrl");
        if (returnUrl == null || returnUrl.trim().isEmpty()) {
            returnUrl = request.getParameter("redirect");
        }
        if (returnUrl == null || returnUrl.trim().isEmpty()) {
            HttpSession currentSession = request.getSession(false);
            if (currentSession != null) {
                Object stored = currentSession.getAttribute("redirectAfterLogin");
                if (stored instanceof String) {
                    returnUrl = (String) stored;
                }
                currentSession.removeAttribute("redirectAfterLogin");
            }
        }
        String redirect = sanitizeRedirect(request, returnUrl);
        response.sendRedirect(request.getContextPath() + redirect);
    }

    // ========================
    // HELPERS
    // ========================

    private void showError(HttpServletRequest request, HttpServletResponse response, String message)
            throws ServletException, IOException {
        request.setAttribute("error", message);
        request.getRequestDispatcher("login.jsp").forward(request, response);
    }

    private String sanitizeRedirect(HttpServletRequest request, String redirect) {
        if (redirect == null || redirect.trim().isEmpty()) return "/home";
        redirect = redirect.trim();

        String contextPath = request.getContextPath();
        if (!contextPath.isEmpty()) {
            if (redirect.equals(contextPath)) {
                redirect = "/";
            } else if (redirect.startsWith(contextPath + "/")) {
                redirect = redirect.substring(contextPath.length());
            }
        }

        // Block open redirect attacks
        if (redirect.startsWith("//") || redirect.contains("://")
                || redirect.toLowerCase().startsWith("javascript:")
                || redirect.contains("\r") || redirect.contains("\n")
                || redirect.contains("%0d") || redirect.contains("%0a")) {
            LOGGER.log(Level.WARNING, "Blocked malicious redirect: {0}", redirect);
            return "/home";
        }
        return redirect.startsWith("/") ? redirect : "/home";
    }

    /** Prevent browser from caching login page or form response. */
    private void setNoCacheHeaders(HttpServletResponse response) {
        response.setHeader("Cache-Control", "no-store, no-cache, must-revalidate, max-age=0");
        response.setHeader("Pragma", "no-cache");
        response.setDateHeader("Expires", 0);
    }

    /** Ensure minimum processing time to prevent timing attacks. */
    private void enforceMinimumDelay(long startNanos, long minMs) {
        long elapsed = (System.nanoTime() - startNanos) / 1_000_000;
        if (elapsed < minMs) {
            try {
                Thread.sleep(minMs - elapsed);
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
            }
        }
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

