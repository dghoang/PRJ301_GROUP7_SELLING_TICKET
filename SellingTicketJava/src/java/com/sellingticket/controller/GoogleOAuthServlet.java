package com.sellingticket.controller;

import com.sellingticket.model.User;
import com.sellingticket.service.AuthTokenService;
import com.sellingticket.service.UserService;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.Properties;
import java.util.UUID;
import java.util.logging.Level;
import java.util.logging.Logger;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

/**
 * Google OAuth 2.0 Authentication.
 *
 * Flow:
 * 1. GET /auth/google → redirect user to Google consent screen
 * 2. Google redirects back to /auth/google/callback with ?code=...
 * 3. Exchange code for access_token
 * 4. Use access_token to get user info (email, name, picture)
 * 5. If email exists → login. If new → auto-register + login.
 */
@WebServlet(name = "GoogleOAuthServlet", urlPatterns = {"/auth/google", "/auth/google/callback"})
public class GoogleOAuthServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(GoogleOAuthServlet.class.getName());
    private static final String AUTH_URL = "https://accounts.google.com/o/oauth2/v2/auth";
    private static final String TOKEN_URL = "https://oauth2.googleapis.com/token";
    private static final String USERINFO_URL = "https://www.googleapis.com/oauth2/v2/userinfo";

    private String clientId;
    private String clientSecret;
    private String redirectUri;
    private final UserService userService = new UserService();
    private final AuthTokenService authTokenService = new AuthTokenService();

    @Override
    public void init() throws ServletException {
        try (InputStream is = getServletContext().getResourceAsStream("/WEB-INF/google-oauth.properties")) {
            if (is == null) {
                LOGGER.warning("google-oauth.properties not found. Google login disabled.");
                return;
            }
            Properties props = new Properties();
            props.load(is);
            clientId = props.getProperty("client_id", "");
            clientSecret = props.getProperty("client_secret", "");
            redirectUri = props.getProperty("redirect_uri", "");
            LOGGER.info("Google OAuth initialized. client_id=" + (clientId.startsWith("YOUR_") ? "NOT_CONFIGURED" : "OK"));
        } catch (IOException e) {
            LOGGER.log(Level.SEVERE, "Failed to load Google OAuth config", e);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String path = request.getServletPath();

        if ("/auth/google".equals(path)) {
            handleRedirectToGoogle(request, response);
        } else if ("/auth/google/callback".equals(path)) {
            handleCallback(request, response);
        }
    }

    /**
     * Step 1: Redirect to Google consent screen.
     */
    private void handleRedirectToGoogle(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        if (clientId == null || clientId.startsWith("YOUR_")) {
            request.getSession().setAttribute("toastMessage", "Google OAuth chưa được cấu hình. Liên hệ admin.");
            request.getSession().setAttribute("toastType", "error");
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // Generate state token to prevent CSRF
        String state = UUID.randomUUID().toString();
        request.getSession().setAttribute("oauth_state", state);

        String authUrl = AUTH_URL
                + "?client_id=" + URLEncoder.encode(clientId, StandardCharsets.UTF_8)
                + "&redirect_uri=" + URLEncoder.encode(redirectUri, StandardCharsets.UTF_8)
                + "&response_type=code"
                + "&scope=" + URLEncoder.encode("email profile", StandardCharsets.UTF_8)
                + "&state=" + URLEncoder.encode(state, StandardCharsets.UTF_8)
                + "&access_type=online"
                + "&prompt=select_account";

        response.sendRedirect(authUrl);
    }

    /**
     * Step 2-5: Handle Google callback, exchange code, get user info, login/register.
     */
    private void handleCallback(HttpServletRequest request, HttpServletResponse response)
            throws IOException, ServletException {

        String code = request.getParameter("code");
        String state = request.getParameter("state");
        String error = request.getParameter("error");

        // Check for errors (user denied access, etc.)
        if (error != null || code == null) {
            LOGGER.warning("OAuth error or no code: " + error);
            request.getSession().setAttribute("toastMessage", "Đăng nhập Google đã bị hủy.");
            request.getSession().setAttribute("toastType", "error");
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // Verify state to prevent CSRF
        String savedState = (String) request.getSession().getAttribute("oauth_state");
        if (savedState == null || !savedState.equals(state)) {
            LOGGER.warning("OAuth state mismatch. Possible CSRF attack.");
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Invalid OAuth state");
            return;
        }
        request.getSession().removeAttribute("oauth_state");

        // Exchange code for access token
        String accessToken = exchangeCodeForToken(code);
        if (accessToken == null) {
            request.getSession().setAttribute("toastMessage", "Không thể xác thực với Google. Vui lòng thử lại.");
            request.getSession().setAttribute("toastType", "error");
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // Get user info from Google
        GoogleUserInfo userInfo = getUserInfo(accessToken);
        if (userInfo == null || userInfo.email == null) {
            request.getSession().setAttribute("toastMessage", "Không thể lấy thông tin từ Google.");
            request.getSession().setAttribute("toastType", "error");
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // Check if user already exists (active)
        User user = userService.getUserByEmail(userInfo.email);

        if (user == null) {
            // Check if a deactivated account exists with this email
            User existing = userService.getUserByEmailAny(userInfo.email);
            if (existing != null && !existing.isActive()) {
                // Deactivated account — block login with clear message
                request.getSession().setAttribute("toastMessage",
                        "Tài khoản của bạn đã bị vô hiệu hóa. Vui lòng liên hệ quản trị viên.");
                request.getSession().setAttribute("toastType", "error");
                response.sendRedirect(request.getContextPath() + "/login");
                return;
            }

            // Auto-register with Google info (no password needed for OAuth users)
            boolean registered = userService.registerOAuth(
                    userInfo.email, userInfo.name, userInfo.picture);

            if (!registered) {
                request.getSession().setAttribute("toastMessage", "Đăng ký tài khoản thất bại.");
                request.getSession().setAttribute("toastType", "error");
                response.sendRedirect(request.getContextPath() + "/login");
                return;
            }

            user = userService.getUserByEmail(userInfo.email);
            LOGGER.log(Level.INFO, "Auto-registered Google user: {0}", userInfo.email);
        }

        // Login: session fixation protection
        HttpSession oldSession = request.getSession(false);
        if (oldSession != null) oldSession.invalidate();

        HttpSession session = request.getSession(true);
        session.setAttribute("user", user);
        session.setAttribute("account", user);
        session.setMaxInactiveInterval(3600);

        // Issue JWT tokens (OAuth users always get persistent remember-me)
        authTokenService.issueTokens(response, user, request, true);

        session.setAttribute("toastMessage", "Đăng nhập Google thành công! Chào " + user.getFullName());
        session.setAttribute("toastType", "success");

        LOGGER.log(Level.INFO, "Google OAuth login: {0}", user.getEmail());
        response.sendRedirect(request.getContextPath() + "/home");
    }

    /**
     * Exchange authorization code for access token.
     */
    private String exchangeCodeForToken(String code) {
        try {
            URL url = new URL(TOKEN_URL);
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("POST");
            conn.setDoOutput(true);
            conn.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");

            String params = "code=" + URLEncoder.encode(code, StandardCharsets.UTF_8)
                    + "&client_id=" + URLEncoder.encode(clientId, StandardCharsets.UTF_8)
                    + "&client_secret=" + URLEncoder.encode(clientSecret, StandardCharsets.UTF_8)
                    + "&redirect_uri=" + URLEncoder.encode(redirectUri, StandardCharsets.UTF_8)
                    + "&grant_type=authorization_code";

            try (OutputStream os = conn.getOutputStream()) {
                os.write(params.getBytes(StandardCharsets.UTF_8));
            }

            String responseBody = readResponse(conn);
            conn.disconnect();

            // Simple JSON parse for access_token (avoid external JSON library)
            return extractJsonValue(responseBody, "access_token");
        } catch (IOException e) {
            LOGGER.log(Level.SEVERE, "Failed to exchange code for token", e);
            return null;
        }
    }

    /**
     * Get user info from Google using access token.
     */
    private GoogleUserInfo getUserInfo(String accessToken) {
        try {
            URL url = new URL(USERINFO_URL);
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestProperty("Authorization", "Bearer " + accessToken);

            String responseBody = readResponse(conn);
            conn.disconnect();

            GoogleUserInfo info = new GoogleUserInfo();
            info.email = extractJsonValue(responseBody, "email");
            info.name = extractJsonValue(responseBody, "name");
            info.picture = extractJsonValue(responseBody, "picture");
            return info;
        } catch (IOException e) {
            LOGGER.log(Level.SEVERE, "Failed to get user info from Google", e);
            return null;
        }
    }

    private String readResponse(HttpURLConnection conn) throws IOException {
        InputStream is = conn.getResponseCode() < 400 ? conn.getInputStream() : conn.getErrorStream();
        try (BufferedReader br = new BufferedReader(new InputStreamReader(is, StandardCharsets.UTF_8))) {
            StringBuilder sb = new StringBuilder();
            String line;
            while ((line = br.readLine()) != null) {
                sb.append(line);
            }
            return sb.toString();
        }
    }

    /**
     * Simple JSON value extractor (no external library needed).
     * Extracts value for "key":"value" pattern.
     */
    private String extractJsonValue(String json, String key) {
        String search = "\"" + key + "\"";
        int idx = json.indexOf(search);
        if (idx < 0) return null;

        int colonIdx = json.indexOf(':', idx + search.length());
        if (colonIdx < 0) return null;

        int startQuote = json.indexOf('"', colonIdx + 1);
        if (startQuote < 0) return null;

        int endQuote = json.indexOf('"', startQuote + 1);
        if (endQuote < 0) return null;

        return json.substring(startQuote + 1, endQuote);
    }

    private static class GoogleUserInfo {
        String email;
        String name;
        String picture;
    }
}
