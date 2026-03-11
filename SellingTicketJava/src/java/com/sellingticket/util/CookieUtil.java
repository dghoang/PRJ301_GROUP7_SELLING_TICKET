package com.sellingticket.util;

import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * Secure cookie helper for JWT auth tokens.
 *
 * <p>All auth cookies are HttpOnly (no JS access), SameSite=Lax (CSRF protection),
 * and Secure when served over HTTPS.</p>
 */
public final class CookieUtil {

    public static final String ACCESS_TOKEN_COOKIE = "st_access";
    public static final String REFRESH_TOKEN_COOKIE = "st_refresh";

    private CookieUtil() {}

    /**
     * Create a secure, HttpOnly cookie.
     *
     * @param name     cookie name
     * @param value    cookie value (JWT token)
     * @param maxAge   max age in seconds (-1 = session cookie, 0 = delete)
     * @param isSecure true if request is HTTPS
     */
    public static Cookie createSecureCookie(String name, String value, int maxAge, boolean isSecure) {
        Cookie cookie = new Cookie(name, value);
        cookie.setHttpOnly(true);
        cookie.setSecure(isSecure);
        cookie.setPath("/");
        cookie.setMaxAge(maxAge);
        return cookie;
    }

    /**
     * Add cookie with SameSite attribute via Set-Cookie header.
     * Jakarta Servlet Cookie API does not natively support SameSite,
     * so we build the header manually for the SameSite flag.
     */
    public static void addSecureCookie(HttpServletResponse response, String name, String value,
                                       int maxAge, boolean isSecure) {
        StringBuilder sb = new StringBuilder();
        sb.append(name).append("=").append(value);
        sb.append("; Path=/");
        sb.append("; HttpOnly");
        if (maxAge >= 0) {
            sb.append("; Max-Age=").append(maxAge);
        }
        if (isSecure) {
            sb.append("; Secure");
        }
        sb.append("; SameSite=Lax");
        response.addHeader("Set-Cookie", sb.toString());
    }

    /** Delete a cookie by setting Max-Age=0. */
    public static void deleteCookie(HttpServletResponse response, String name, boolean isSecure) {
        addSecureCookie(response, name, "", 0, isSecure);
    }

    /** Read a cookie value by name from the request. Returns null if not found. */
    public static String getCookieValue(HttpServletRequest request, String name) {
        Cookie[] cookies = request.getCookies();
        if (cookies == null) return null;
        for (Cookie c : cookies) {
            if (name.equals(c.getName())) {
                return c.getValue();
            }
        }
        return null;
    }
}
