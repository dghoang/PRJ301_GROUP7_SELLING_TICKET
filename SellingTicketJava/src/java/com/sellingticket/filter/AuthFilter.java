package com.sellingticket.filter;

import com.sellingticket.model.User;
import com.sellingticket.service.AuthTokenService;
import static com.sellingticket.util.ServletUtil.AUTHENTICATED_USER_ATTR;
import static com.sellingticket.util.ServletUtil.getSessionUser;
import static com.sellingticket.util.ServletUtil.redirectToLogin;

import java.io.IOException;
import java.util.Set;
import java.util.logging.Level;
import java.util.logging.Logger;
import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.FilterConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

/**
 * Authentication filter — checks session first, then JWT cookies.
 *
 * <p>Role-based access:
 * <ul>
 *   <li><b>admin</b>: full access to /admin/*</li>
 *   <li><b>support_agent</b>: restricted to /admin/support and /admin/support/* only</li>
 *   <li><b>organizer</b>: /organizer/* (handled by OrganizerAccessFilter)</li>
 *   <li><b>user</b>: /checkout, /tickets, /profile, etc.</li>
 * </ul>
 */
public class AuthFilter implements Filter {

    private static final Logger LOGGER = Logger.getLogger(AuthFilter.class.getName());
    // Note: Direct .jsp access is blocked globally by SecurityHeadersFilter.
    // AuthFilter only handles clean URL authorization.

    private static final Set<String> PUBLIC_EXACT_PATHS = Set.of(
            "/", "/home", "/events", "/event-detail",
            "/categories", "/about", "/faq", "/terms",
            "/login", "/register",
            "/auth/google", "/auth/google/callback"
    );

    private final AuthTokenService authTokenService = new AuthTokenService();

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {}

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;

        User user = getSessionUser(httpRequest);
        String uri = httpRequest.getRequestURI();
        String contextPath = httpRequest.getContextPath();
        String path = uri.startsWith(contextPath) ? uri.substring(contextPath.length()) : uri;
        boolean isApiPath = path.startsWith("/api/");

        // Welcome file / root path — always allow (index.jsp forwards to /home)
        if (path.isEmpty() || "/".equals(path)) {
            chain.doFilter(request, response);
            return;
        }

        // Public routes (home, events, event detail, static pages, auth pages).
        if (isPublicRoute(path)) {
            chain.doFilter(request, response);
            return;
        }

        // --- Exempt external webhook endpoints (they use their own auth) ---
        if (path.equals("/api/seepay/webhook")) {
            chain.doFilter(request, response);
            return;
        }

        // --- API Bearer auth path (preferred for external API clients) ---
        String bearerToken = extractBearerToken(httpRequest);
        if (isApiPath && bearerToken != null) {
            User bearerUser = authTokenService.validateAccessToken(bearerToken);
            if (bearerUser != null) {
                user = bearerUser;
                httpRequest.setAttribute(AUTHENTICATED_USER_ATTR, user);
            } else {
                // Compatibility mode during migration: stale bearer headers should not break
                // existing cookie/session-authenticated web flows.
                LOGGER.log(Level.FINE, "Invalid bearer token on {0}; falling back to session/cookie auth", path);
            }
        }

        // --- Try JWT cookie restoration if session is empty ---
        if (user == null) {
            user = authTokenService.validateAccessToken(httpRequest);

            if (user == null) {
                user = authTokenService.refreshAccessToken(httpRequest, httpResponse);
            }

            if (user != null) {
                // Block deactivated/deleted users even if JWT is still valid
                if (!user.isActive()) {
                    LOGGER.log(Level.WARNING, "Blocked inactive user from JWT restore: {0}", user.getEmail());
                    authTokenService.clearAuthCookies(httpRequest, httpResponse);
                    user = null;
                } else {
                    // Prevent session fixation: invalidate old session before creating new one
                    HttpSession oldSession = httpRequest.getSession(false);
                    String csrfToken = null;
                    if (oldSession != null) {
                        csrfToken = (String) oldSession.getAttribute("csrf_token");
                        oldSession.invalidate();
                    }
                    HttpSession session = httpRequest.getSession(true);
                    session.setAttribute("user", user);
                    session.setAttribute("account", user);
                    if (csrfToken != null) {
                        // Preserve CSRF continuity when CsrfFilter ran before JWT-based session restore.
                        session.setAttribute("csrf_token", csrfToken);
                    }
                    session.setMaxInactiveInterval(3600);
                    LOGGER.log(Level.FINE, "Session restored from JWT for user: {0}", user.getEmail());
                }
            }
        }

        if (user != null) {
            httpRequest.setAttribute(AUTHENTICATED_USER_ATTR, user);
            authTokenService.cleanupLegacyAccessCookie(httpRequest, httpResponse);
        }

        // --- Not logged in: redirect to login with returnUrl ---
        if (user == null) {
            // For API endpoints, return 401 JSON instead of redirect
            if (isApiPath) {
                httpResponse.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                httpResponse.setContentType("application/json");
                httpResponse.setCharacterEncoding("UTF-8");
                httpResponse.getWriter().write("{\"error\":\"Unauthorized\"}");
                return;
            }
            redirectToLogin(httpRequest, httpResponse);
            return;
        }

        String role = user.getRole();

        // --- Admin area access control ---
        if (uri.startsWith(contextPath + "/admin")) {
            if ("admin".equals(role)) {
                // Admin has full access
                chain.doFilter(request, response);
                return;
            }

            // All other roles: no admin access
            com.sellingticket.util.ServletUtil.setToast(httpRequest, "Bạn không có quyền truy cập trang này!", "error");
                httpResponse.sendRedirect(contextPath + "/home");
            return;
        }

        // --- Organizer area access control ---
        if (uri.startsWith(contextPath + "/organizer")) {


            // Allow all authenticated users into /organizer area so that staff/support/customer
            // can create and manage their own events as an organizer.
            // Specific event ownership controls are handled by OrganizerAccessFilter and specific controllers.
            boolean allowedRole = "organizer".equals(role) || "admin".equals(role) 
                               || "customer".equals(role) || "support_agent".equals(role) 
                               || "staff".equals(role);
            if (!allowedRole) {
                com.sellingticket.util.ServletUtil.setToast(httpRequest, "Bạn không có quyền truy cập trang này!", "error");
                httpResponse.sendRedirect(contextPath + "/home");
                return;
            }
        }

        // --- API access control ---
        if (uri.startsWith(contextPath + "/api/admin/")) {
            if (!"admin".equals(role)) {
                httpResponse.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                httpResponse.setContentType("application/json");
                httpResponse.getWriter().write("{\"error\":\"Unauthorized\"}");
                return;
            }
        }
        if (uri.startsWith(contextPath + "/api/organizer/")) {
            // customer, support_agent, staff are also allowed – they may have their own events
            boolean allowedApiRole = "organizer".equals(role) || "admin".equals(role) 
                                  || "customer".equals(role) || "support_agent".equals(role) 
                                  || "staff".equals(role);
            if (!allowedApiRole) {
                httpResponse.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                httpResponse.setContentType("application/json");
                httpResponse.getWriter().write("{\"error\":\"Unauthorized\"}");
                return;
            }
        }

        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {}



    private boolean isPublicRoute(String path) {
        if (PUBLIC_EXACT_PATHS.contains(path)) {
            return true;
        }
        return path.startsWith("/event/");
    }

    private String extractBearerToken(HttpServletRequest request) {
        String authHeader = request.getHeader("Authorization");
        if (authHeader == null) {
            return null;
        }
        String prefix = "Bearer ";
        if (!authHeader.regionMatches(true, 0, prefix, 0, prefix.length())) {
            return null;
        }
        String token = authHeader.substring(prefix.length()).trim();
        return token.isEmpty() ? null : token;
    }
}
