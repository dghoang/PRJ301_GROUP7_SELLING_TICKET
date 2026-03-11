package com.sellingticket.filter;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.FilterConfig;
import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.Set;
import java.util.logging.Logger;

/**
 * Blocks direct browser access to protected JSP files.
 * Protected JSPs must be rendered through a servlet forward/include flow.
 */
public class ProtectedJspAccessFilter implements Filter {

    private static final Logger LOGGER = Logger.getLogger(ProtectedJspAccessFilter.class.getName());

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
        LOGGER.info("ProtectedJspAccessFilter initialized");
    }

    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest request = (HttpServletRequest) req;
        HttpServletResponse response = (HttpServletResponse) res;

        String contextPath = request.getContextPath();
        String uri = request.getRequestURI();
        String path = uri.startsWith(contextPath) ? uri.substring(contextPath.length()) : uri;

        if (!path.endsWith(".jsp") || !isProtectedJsp(path)) {
            chain.doFilter(req, res);
            return;
        }

        boolean isForwarded = request.getAttribute(RequestDispatcher.FORWARD_REQUEST_URI) != null;
        boolean isIncluded = request.getAttribute(RequestDispatcher.INCLUDE_REQUEST_URI) != null;

        // Allow JSP rendering only when entered through servlet forward/include.
        if (isForwarded || isIncluded) {
            chain.doFilter(req, res);
            return;
        }

        LOGGER.warning("Blocked direct access to protected JSP: " + path + " from " + request.getRemoteAddr());
        response.sendError(HttpServletResponse.SC_NOT_FOUND);
    }

    private boolean isProtectedJsp(String path) {
        if (path.startsWith("/admin/") || path.startsWith("/organizer/")) {
            return true;
        }
        return PROTECTED_ROOT_JSP.contains(path);
    }

    @Override
    public void destroy() {
        // No cleanup required.
    }
}
