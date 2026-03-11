package com.sellingticket.filter;

import java.io.IOException;
import java.util.UUID;
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
 * CsrfFilter - Protects against Cross-Site Request Forgery attacks.
 * 
 * <p>Generates a unique token per session and validates it on every POST request.
 * JSP forms must include: {@code <input type="hidden" name="csrf_token" value="${csrf_token}"/>}</p>
 */
public class CsrfFilter implements Filter {

    private static final Logger LOGGER = Logger.getLogger(CsrfFilter.class.getName());
    private static final String TOKEN_NAME = "csrf_token";

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        LOGGER.info("CsrfFilter initialized");
    }

    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest request = (HttpServletRequest) req;
        HttpServletResponse response = (HttpServletResponse) res;
        HttpSession session = request.getSession(true);

        // Generate token if not present
        String sessionToken = (String) session.getAttribute(TOKEN_NAME);
        if (sessionToken == null) {
            sessionToken = UUID.randomUUID().toString();
            session.setAttribute(TOKEN_NAME, sessionToken);
        }

        // Make token available to JSP
        request.setAttribute(TOKEN_NAME, sessionToken);

        // Validate on POST
        if ("POST".equalsIgnoreCase(request.getMethod())) {
            String contentType = request.getContentType();
            String uri = request.getRequestURI();

            boolean isApiEndpoint = uri.contains("/api/") || uri.contains("/media/upload");
            boolean isMultipart = contentType != null && contentType.startsWith("multipart/");

            // Only skip CSRF for API endpoints that handle their own auth
            if (isApiEndpoint) {
                chain.doFilter(request, response);
                return;
            }

            // For multipart forms, check CSRF token from query parameter (since body is not parsed)
            String submittedToken;
            if (isMultipart) {
                submittedToken = request.getParameter(TOKEN_NAME);
                if (submittedToken == null) {
                    // Fallback: check query string for multipart forms
                    String qs = request.getQueryString();
                    if (qs != null) {
                        for (String param : qs.split("&")) {
                            String[] kv = param.split("=", 2);
                            if (kv.length == 2 && TOKEN_NAME.equals(kv[0])) {
                                submittedToken = java.net.URLDecoder.decode(kv[1], java.nio.charset.StandardCharsets.UTF_8);
                                break;
                            }
                        }
                    }
                }
            } else {
                submittedToken = request.getParameter(TOKEN_NAME);
            }

            if (submittedToken == null || !submittedToken.equals(sessionToken)) {
                LOGGER.warning("CSRF validation failed for " + uri
                        + " from " + request.getRemoteAddr());
                response.sendError(HttpServletResponse.SC_FORBIDDEN,
                        "Invalid or missing CSRF token. Please refresh the page and try again.");
                return;
            }

            // Rotate token after successful validation
            String newToken = UUID.randomUUID().toString();
            session.setAttribute(TOKEN_NAME, newToken);
            request.setAttribute(TOKEN_NAME, newToken);
        }

        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {
        // No cleanup needed
    }
}
