package com.sellingticket.filter;

import com.sellingticket.model.User;
import com.sellingticket.service.AuthTokenService;
import static com.sellingticket.util.ServletUtil.getSessionUser;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
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
    "/order-confirmation", "/profile", "/change-password"
})
public class AuthFilter implements Filter {

    private static final Logger LOGGER = Logger.getLogger(AuthFilter.class.getName());
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

        // --- Try JWT cookie restoration if session is empty ---
        if (user == null) {
            user = authTokenService.validateAccessToken(httpRequest);

            if (user == null) {
                user = authTokenService.refreshAccessToken(httpRequest, httpResponse);
            }

            if (user != null) {
                HttpSession session = httpRequest.getSession(true);
                session.setAttribute("user", user);
                session.setAttribute("account", user);
                session.setMaxInactiveInterval(3600);
                LOGGER.log(Level.FINE, "Session restored from JWT for user: {0}", user.getEmail());
            }
        }

        // --- Not logged in: redirect to login with returnUrl ---
        if (user == null) {
            String returnUrl = uri;
            String queryString = httpRequest.getQueryString();
            if (queryString != null && !queryString.isEmpty()) {
                returnUrl += "?" + queryString;
            }
            String encoded = URLEncoder.encode(returnUrl, StandardCharsets.UTF_8);
            httpResponse.sendRedirect(contextPath + "/login?returnUrl=" + encoded);
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
            httpResponse.sendRedirect(contextPath + "/home?error=unauthorized");
            return;
        }

        // --- Organizer area access control ---
        if (uri.startsWith(contextPath + "/organizer")) {
            if ("support_agent".equals(role)) {
                LOGGER.log(Level.WARNING, "Support agent {0} blocked from {1}", new Object[]{user.getEmail(), uri});
                httpResponse.sendRedirect(contextPath + "/admin/chat-dashboard");
                return;
            }
        }

        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {}
}
