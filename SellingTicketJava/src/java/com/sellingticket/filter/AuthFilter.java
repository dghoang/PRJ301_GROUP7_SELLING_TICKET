package com.sellingticket.filter;

import com.sellingticket.model.User;
import com.sellingticket.service.AuthTokenService;
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
import jakarta.servlet.annotation.WebFilter;
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
@WebFilter(filterName = "AuthFilter", urlPatterns = {
    "/organizer/*", "/admin/*",
    "/checkout", "/tickets", "/my-tickets",
    "/order-confirmation", "/profile", "/change-password",
    "/resume-payment", "/support/*",
    "/api/admin/*", "/api/organizer/*", "/api/my-tickets", "/api/my-orders",
    "/api/chat/*", "/api/payment/*", "/api/voucher/*", "/api/upload",
    "/media/upload", "*.jsp"
})
public class AuthFilter implements Filter {

    private static final Logger LOGGER = Logger.getLogger(AuthFilter.class.getName());
    private static final Set<String> PROTECTED_ROOT_JSP = Set.of(
            "/checkout.jsp",
            "/my-support-tickets.jsp",
            "/my-tickets.jsp",
            "/order-confirmation.jsp",
            "/payment-pending.jsp",
            "/profile.jsp",
            "/support-ticket.jsp",
            "/support-ticket-detail.jsp",
            "/ticket-selection.jsp"
    );

    /** Public root JSPs that do NOT require authentication. */
    private static final Set<String> PUBLIC_ROOT_JSP = Set.of(
            "/index.jsp", "/home.jsp", "/events.jsp", "/event-detail.jsp",
            "/categories.jsp", "/about.jsp", "/faq.jsp", "/terms.jsp",
            "/login.jsp", "/register.jsp",
            "/header.jsp", "/footer.jsp",
            "/404.jsp", "/500.jsp"
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

        // Hardening: protected JSPs must never be accessed directly via URL.
        if (isProtectedJsp(path)) {
            LOGGER.log(Level.WARNING, "Blocked direct access to protected JSP: {0}", path);
            httpResponse.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        // Public JSPs (home, events, etc.) — skip auth, let them through.
        if (isPublicJsp(path)) {
            chain.doFilter(request, response);
            return;
        }

        // --- Exempt external webhook endpoints (they use their own auth) ---
        if (path.equals("/api/seepay/webhook")) {
            chain.doFilter(request, response);
            return;
        }

        // --- Try JWT cookie restoration if session is empty ---
        if (user == null) {
            user = authTokenService.validateAccessToken(httpRequest);

            if (user == null) {
                user = authTokenService.refreshAccessToken(httpRequest, httpResponse);
            }

            if (user != null) {
                // Prevent session fixation: invalidate old session before creating new one
                HttpSession oldSession = httpRequest.getSession(false);
                if (oldSession != null) {
                    oldSession.invalidate();
                }
                HttpSession session = httpRequest.getSession(true);
                session.setAttribute("user", user);
                session.setAttribute("account", user);
                session.setMaxInactiveInterval(3600);
                LOGGER.log(Level.FINE, "Session restored from JWT for user: {0}", user.getEmail());
            }
        }

        // --- Not logged in: redirect to login with returnUrl ---
        if (user == null) {
            // For API endpoints, return 401 JSON instead of redirect
            if (path.startsWith("/api/")) {
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
            if ("support_agent".equals(role)) {
                // Support agent: only /admin/support and /admin/chat-dashboard
                String adminPath = uri.substring((contextPath + "/admin").length());
                if (adminPath.equals("/support") || adminPath.startsWith("/support/") ||
                    adminPath.equals("/support-detail") || adminPath.startsWith("/support-detail/") ||
                    adminPath.equals("/chat-dashboard") || adminPath.startsWith("/chat-dashboard/")) {
                    chain.doFilter(request, response);
                    return;
                }
                // Block all other admin pages
                LOGGER.log(Level.WARNING, "Support agent {0} blocked from {1}", new Object[]{user.getEmail(), uri});
                httpResponse.sendRedirect(contextPath + "/admin/chat-dashboard");
                return;
            }
            // All other roles: no admin access
            httpResponse.sendRedirect(contextPath + "/home?msg=B%E1%BA%A1n+kh%C3%B4ng+c%C3%B3+quy%E1%BB%81n+truy+c%E1%BA%ADp+trang+n%C3%A0y&msgType=error");
            return;
        }

        // --- Organizer area access control ---
        if (uri.startsWith(contextPath + "/organizer")) {
            if ("support_agent".equals(role)) {
                LOGGER.log(Level.WARNING, "Support agent {0} blocked from {1}", new Object[]{user.getEmail(), uri});
                httpResponse.sendRedirect(contextPath + "/admin/chat-dashboard");
                return;
            }

            // Customer role: allow only create-event and events list (to view approval status)
            if ("customer".equals(role)) {
                String orgPath = uri.substring((contextPath + "/organizer").length());
                boolean allowedForCustomer =
                        orgPath.equals("/create-event") || orgPath.startsWith("/create-event/") ||
                        orgPath.equals("/events") || orgPath.startsWith("/events?") ||
                        orgPath.equals("/settings") || orgPath.startsWith("/settings/");
                if (!allowedForCustomer) {
                    httpResponse.sendRedirect(contextPath + "/organizer/events?msg=B%E1%BA%A1n+c%E1%BA%A7n+c%C3%B3+s%E1%BB%B1+ki%E1%BB%87n+%C4%91%C6%B0%E1%BB%A3c+duy%E1%BB%87t+%C4%91%E1%BB%83+truy+c%E1%BA%ADp+trang+n%C3%A0y&msgType=warning");
                    return;
                }
            } else if (!"organizer".equals(role) && !"admin".equals(role)) {
                // Unknown roles: block entirely
                httpResponse.sendRedirect(contextPath + "/home?msg=B%E1%BA%A1n+kh%C3%B4ng+c%C3%B3+quy%E1%BB%81n+truy+c%E1%BA%ADp+trang+n%C3%A0y&msgType=error");
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
            if (!"organizer".equals(role) && !"admin".equals(role)) {
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

    private boolean isProtectedJsp(String path) {
        if (!path.endsWith(".jsp")) {
            return false;
        }
        if (path.startsWith("/admin/") || path.startsWith("/organizer/")) {
            return true;
        }
        return PROTECTED_ROOT_JSP.contains(path);
    }

    private boolean isPublicJsp(String path) {
        return path.endsWith(".jsp") && PUBLIC_ROOT_JSP.contains(path);
    }
}
