package com.sellingticket.filter;

import java.io.IOException;
import java.util.Set;
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
 * SecurityHeadersFilter - Adds security response headers to every response.
 * 
 * <p>Protects against:
 * <ul>
 *   <li>XSS (X-XSS-Protection, Content-Security-Policy)</li>
 *   <li>Clickjacking (X-Frame-Options)</li>
 *   <li>MIME sniffing (X-Content-Type-Options)</li>
 * </ul>
 */
public class SecurityHeadersFilter implements Filter {

    private static final Logger LOGGER = Logger.getLogger(SecurityHeadersFilter.class.getName());
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

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        LOGGER.info("SecurityHeadersFilter initialized");
    }

    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
            throws IOException, ServletException {

        HttpServletResponse response = (HttpServletResponse) res;
        HttpServletRequest httpReq = (HttpServletRequest) req;
        String contextPath = httpReq.getContextPath();
        String uri = httpReq.getRequestURI();
        String path = uri.startsWith(contextPath) ? uri.substring(contextPath.length()) : uri;

        // Hardening: block direct browser access to protected JSPs.
        if (isProtectedJsp(path)) {
            boolean isForwarded = httpReq.getAttribute(RequestDispatcher.FORWARD_REQUEST_URI) != null;
            boolean isIncluded = httpReq.getAttribute(RequestDispatcher.INCLUDE_REQUEST_URI) != null;
            if (!isForwarded && !isIncluded) {
                LOGGER.warning("Blocked direct access to protected JSP: " + path + " from " + httpReq.getRemoteAddr());
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
                return;
            }
        }

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

        // HSTS is removed for local development to allow HTTP access via LAN IP
        
        chain.doFilter(req, res);
    }

    @Override
    public void destroy() {
        // No cleanup needed
    }

    private boolean isProtectedJsp(String path) {
        if (!path.endsWith(".jsp")) {
            return false;
        }
        if (path.startsWith("/admin/") || path.startsWith("/organizer/")) {
            return true;
        }
        return PROTECTED_ROOT_JSP.contains(path);
    }
}
