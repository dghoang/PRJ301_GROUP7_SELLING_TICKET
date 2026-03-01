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
 * <p>Flow:
 * <ol>
 *   <li>Check session for logged-in user</li>
 *   <li>If no session → try access token from HttpOnly cookie</li>
 *   <li>If access token expired → try refresh via refresh token cookie</li>
 *   <li>If JWT restored → recreate session automatically</li>
 *   <li>If all fail → redirect to login with returnUrl</li>
 * </ol>
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
                // Access token expired or missing — try refresh
                user = authTokenService.refreshAccessToken(httpRequest, httpResponse);
            }

            if (user != null) {
                // Restore session from JWT
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

        // --- Admin-only area ---
        if (uri.startsWith(contextPath + "/admin") && !"admin".equals(role)) {
            httpResponse.sendRedirect(contextPath + "/home?error=unauthorized");
            return;
        }

        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {}
}

