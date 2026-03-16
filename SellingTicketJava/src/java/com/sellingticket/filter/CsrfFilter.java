package com.sellingticket.filter;

import com.sellingticket.util.JwtUtil;
import java.io.IOException;
import java.util.Map;
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
    private static final String PREV_TOKEN_NAME = "csrf_token_prev";

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
        String previousToken = (String) session.getAttribute(PREV_TOKEN_NAME);
        if (sessionToken == null) {
            sessionToken = UUID.randomUUID().toString();
            session.setAttribute(TOKEN_NAME, sessionToken);
            session.removeAttribute(PREV_TOKEN_NAME);
            previousToken = null;
        }

        // Make token available to JSP
        request.setAttribute(TOKEN_NAME, sessionToken);

        // Validate on POST
        if ("POST".equalsIgnoreCase(request.getMethod())) {
            String contentType = request.getContentType();
            String uri = request.getRequestURI();

            boolean isApiEndpoint = uri.contains("/api/") || uri.contains("/media/upload");
            boolean isSeepayWebhook = uri.contains("/api/seepay/webhook");
            boolean isMultipart = contentType != null && contentType.startsWith("multipart/");

            // External payment webhook uses API key auth and is exempt from CSRF.
            if (isSeepayWebhook) {
                chain.doFilter(request, response);
                return;
            }

            // API transition mode:
            // - If request uses a valid Bearer access token, CSRF is not required.
            // - Otherwise (session/cookie auth), CSRF token is required.
            if (isApiEndpoint) {
                String bearerToken = extractBearerToken(request);
                if (bearerToken != null) {
                    if (isValidAccessToken(bearerToken)) {
                        chain.doFilter(request, response);
                        return;
                    }

                    HttpSession existingSession = request.getSession(false);
                    boolean hasSessionUser = existingSession != null
                            && (existingSession.getAttribute("user") != null
                            || existingSession.getAttribute("account") != null);
                    if (!hasSessionUser) {
                        response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Invalid bearer token");
                        return;
                    }

                    LOGGER.fine("Invalid bearer token with active session; falling back to CSRF validation");
                }
            }

            // For multipart forms, check CSRF token from query parameter (since body is not parsed)
            String submittedToken;
            if (isApiEndpoint) {
                submittedToken = request.getHeader("X-CSRF-Token");
                if (submittedToken == null || submittedToken.isEmpty()) {
                    // Backward-compatible fallback while frontend migrates to header-based CSRF.
                    submittedToken = request.getParameter(TOKEN_NAME);
                }
            } else if (isMultipart) {
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

            boolean csrfValid = submittedToken != null
                    && (submittedToken.equals(sessionToken)
                    || (previousToken != null && submittedToken.equals(previousToken)));

            if (!csrfValid) {
                LOGGER.warning("CSRF validation failed for " + uri
                        + " from " + request.getRemoteAddr()
                        + " (submitted=" + (submittedToken != null ? "present" : "null")
                        + ", session=" + (sessionToken != null ? "present" : "null") + ")");

                // For login/register pages, redirect back to the GET form instead of raw 403
                // This handles edge cases: expired session, back-button resubmit, token desync
                String ctxPath = request.getContextPath();
                if (uri.endsWith("/login") || uri.endsWith("/register")) {
                    session.removeAttribute(TOKEN_NAME); // force fresh token on next GET
                    response.sendRedirect(ctxPath + (uri.endsWith("/login") ? "/login" : "/register")
                            + "?error=csrf");
                    return;
                }

                response.sendError(HttpServletResponse.SC_FORBIDDEN,
                        "Invalid or missing CSRF token. Please refresh the page and try again.");
                return;
            }

            // For API calls we keep a stable per-session token to support repeated AJAX POSTs
            // (chat polling/send would otherwise fail after the first request).
            // For normal web form POSTs, rotate token with one-step grace.
            if (!isApiEndpoint) {
                String newToken = UUID.randomUUID().toString();
                session.setAttribute(PREV_TOKEN_NAME, sessionToken);
                session.setAttribute(TOKEN_NAME, newToken);
                request.setAttribute(TOKEN_NAME, newToken);
            }
        }

        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {
        // No cleanup needed
    }

    private String extractBearerToken(HttpServletRequest request) {
        String authHeader = request.getHeader("Authorization");
        if (authHeader == null) return null;
        String prefix = "Bearer ";
        if (!authHeader.regionMatches(true, 0, prefix, 0, prefix.length())) {
            return null;
        }
        String token = authHeader.substring(prefix.length()).trim();
        return token.isEmpty() ? null : token;
    }

    private boolean isValidAccessToken(String token) {
        Map<String, Object> claims = JwtUtil.verifyAuthToken(token);
        return claims != null && "access".equals(claims.get("type"));
    }
}
