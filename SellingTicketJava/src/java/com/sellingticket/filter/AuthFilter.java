package com.sellingticket.filter;

import com.sellingticket.model.User;
import static com.sellingticket.util.ServletUtil.getSessionUser;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.FilterConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * Authentication filter — redirects unauthenticated users to login page.
 * Saves the original URL as returnUrl so the user returns after login.
 *
 * <p>Protected URL patterns:
 * <ul>
 *   <li>/organizer/* — organizer dashboard, events, statistics</li>
 *   <li>/admin/* — admin dashboard, user management</li>
 *   <li>/checkout — purchase flow</li>
 *   <li>/tickets, /my-tickets — user ticket list</li>
 *   <li>/order-confirmation — post-purchase page</li>
 *   <li>/profile — user profile</li>
 *   <li>/change-password — password change</li>
 * </ul>
 */
@WebFilter(filterName = "AuthFilter", urlPatterns = {
    "/organizer/*", "/admin/*",
    "/checkout", "/tickets", "/my-tickets",
    "/order-confirmation", "/profile", "/change-password"
})
public class AuthFilter implements Filter {

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

        // --- Admin-only area ---
        if (uri.startsWith(contextPath + "/admin") && !"admin".equals(role)) {
            httpResponse.sendRedirect(contextPath + "/home?error=unauthorized");
            return;
        }

        // --- Organizer area: allow organizer + admin ---
        if (uri.startsWith(contextPath + "/organizer")
                && !"organizer".equals(role) && !"admin".equals(role)) {
            httpResponse.sendRedirect(contextPath + "/home?error=unauthorized");
            return;
        }

        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {}
}
