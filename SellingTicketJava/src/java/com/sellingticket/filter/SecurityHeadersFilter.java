package com.sellingticket.filter;

import java.io.IOException;
import java.util.Map;
import java.util.logging.Logger;
import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.FilterConfig;
import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * SecurityHeadersFilter — Adds security response headers + blocks direct JSP access.
 *
 * <p>Security headers protect against:
 * <ul>
 *   <li>XSS (X-XSS-Protection)</li>
 *   <li>Clickjacking (X-Frame-Options)</li>
 *   <li>MIME sniffing (X-Content-Type-Options)</li>
 * </ul>
 *
 * <p>JSP access hardening:
 * <ul>
 *   <li>ALL .jsp files are blocked from direct browser access</li>
 *   <li>Only internal forwards/includes from servlets can render JSPs</li>
 *   <li>Known JSPs with servlet mappings redirect to their clean URL</li>
 *   <li>Exception: index.jsp (Tomcat welcome file)</li>
 * </ul>
 */
public class SecurityHeadersFilter implements Filter {

    private static final Logger LOGGER = Logger.getLogger(SecurityHeadersFilter.class.getName());

    /**
     * JSPs that have a servlet mapping — redirect to clean URL instead of 404.
     * This ensures bookmarks and old links still work gracefully.
     */
    private static final Map<String, String> JSP_REDIRECT_MAP = Map.ofEntries(
            // Public pages
            Map.entry("/home.jsp", "/home"),
            Map.entry("/events.jsp", "/events"),
            Map.entry("/event-detail.jsp", "/event-detail"),
            Map.entry("/categories.jsp", "/categories"),
            Map.entry("/about.jsp", "/about"),
            Map.entry("/faq.jsp", "/faq"),
            Map.entry("/terms.jsp", "/terms"),
            Map.entry("/login.jsp", "/login"),
            Map.entry("/register.jsp", "/register"),
            // Protected user pages
            Map.entry("/checkout.jsp", "/checkout"),
            Map.entry("/my-tickets.jsp", "/my-tickets"),
            Map.entry("/my-support-tickets.jsp", "/my-support-tickets"),
            Map.entry("/profile.jsp", "/profile"),
            Map.entry("/notifications.jsp", "/notifications"),
            Map.entry("/order-confirmation.jsp", "/order-confirmation"),
            Map.entry("/ticket-selection.jsp", "/tickets")
    );

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        LOGGER.info("SecurityHeadersFilter initialized — all direct .jsp access blocked");
    }

    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
            throws IOException, ServletException {

        HttpServletResponse response = (HttpServletResponse) res;
        HttpServletRequest httpReq = (HttpServletRequest) req;
        String contextPath = httpReq.getContextPath();
        String uri = httpReq.getRequestURI();
        String path = uri.startsWith(contextPath) ? uri.substring(contextPath.length()) : uri;

        // === BLOCK ALL DIRECT .JSP ACCESS ===
        // Only internal forwards/includes from servlets may render JSPs.
        // Exception: /index.jsp is allowed as Tomcat welcome file (it just forwards to /home).
        if (path.endsWith(".jsp") && !"/index.jsp".equals(path)) {
            boolean isForwarded = httpReq.getAttribute(RequestDispatcher.FORWARD_REQUEST_URI) != null;
            boolean isIncluded = httpReq.getAttribute(RequestDispatcher.INCLUDE_REQUEST_URI) != null;

            if (!isForwarded && !isIncluded) {
                // Try redirect to clean URL first (graceful handling)
                String redirectUrl = JSP_REDIRECT_MAP.get(path);
                if (redirectUrl != null) {
                    response.sendRedirect(contextPath + redirectUrl);
                    return;
                }
                // No known mapping → 404
                LOGGER.warning("Blocked direct JSP access: " + path + " from " + httpReq.getRemoteAddr());
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
                return;
            }
        }

        // === SECURITY RESPONSE HEADERS ===

        // Prevent MIME type sniffing
        response.setHeader("X-Content-Type-Options", "nosniff");

        // Prevent clickjacking
        response.setHeader("X-Frame-Options", "SAMEORIGIN");

        // Enable browser XSS protection
        response.setHeader("X-XSS-Protection", "1; mode=block");

        // Referrer policy — don't leak full URL to external sites
        response.setHeader("Referrer-Policy", "strict-origin-when-cross-origin");

        // Permissions policy — camera allowed ONLY on check-in page for QR scanning
        if (uri.contains("/organizer/check-in") || uri.contains("/staff/check-in")) {
            response.setHeader("Permissions-Policy", "camera=(self), microphone=(), geolocation=()");
        } else {
            response.setHeader("Permissions-Policy", "camera=(), microphone=(), geolocation=()");
        }

        chain.doFilter(req, res);
    }

    @Override
    public void destroy() {
        // No cleanup needed
    }
}
