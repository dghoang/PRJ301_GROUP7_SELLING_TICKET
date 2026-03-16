package com.sellingticket.service;

import com.sellingticket.dao.RefreshTokenDAO;
import com.sellingticket.dao.UserDAO;
import com.sellingticket.model.User;
import com.sellingticket.util.CookieUtil;
import com.sellingticket.util.JwtUtil;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.sql.Timestamp;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Coordinates JWT token issuance, validation, refresh, and revocation.
 *
 * <p>Token lifecycle:
 * <ol>
 *   <li>Login → issue access + refresh tokens, save refresh in DB</li>
 *   <li>Request → AuthFilter reads access token from cookie</li>
 *   <li>Access expired → use refresh token to get new access token</li>
 *   <li>Logout → revoke refresh token, delete cookies</li>
 * </ol>
 */
public class AuthTokenService {

    private static final Logger LOGGER = Logger.getLogger(AuthTokenService.class.getName());

    private final RefreshTokenDAO refreshTokenDAO = new RefreshTokenDAO();
    private final UserDAO userDAO = new UserDAO();

    /**
     * Issue access + refresh tokens for a user and set them as cookies.
     *
     * @param rememberMe true = persistent cookies (7d/30d), false = session cookies
     */
    public void issueTokens(HttpServletResponse response, User user,
                            HttpServletRequest request, boolean rememberMe) {

        boolean secure = request.isSecure();
        String cookiePath = resolveCookiePath(request);

        clearAuthCookies(response, secure, cookiePath);

        // Keep only one compact refresh cookie for web flows.
        String jti = JwtUtil.generateRefreshTokenId();

        int refreshMaxAge = rememberMe ? (int) JwtUtil.REFRESH_TOKEN_EXPIRY_SEC : -1;
        CookieUtil.addSecureCookie(response, CookieUtil.REFRESH_TOKEN_COOKIE,
            jti, refreshMaxAge, secure, cookiePath);

        // Save refresh token in DB
        long expiresMs = System.currentTimeMillis() + (JwtUtil.REFRESH_TOKEN_EXPIRY_SEC * 1000);
        String userAgent = request.getHeader("User-Agent");
        String ip = getClientIp(request);

        refreshTokenDAO.saveToken(user.getUserId(), jti, userAgent, ip, new Timestamp(expiresMs));

        LOGGER.log(Level.INFO, "Tokens issued for user {0} (remember={1})",
                new Object[]{user.getEmail(), rememberMe});
    }

    /**
     * Validate the access token from cookie and return the user.
     * Does NOT hit the database — uses claims from the JWT directly.
     *
     * @return User object (lightweight, from JWT claims) or null
     */
    public User validateAccessToken(HttpServletRequest request) {
        String token = CookieUtil.getCookieValue(request, CookieUtil.ACCESS_TOKEN_COOKIE);
        return validateAccessToken(token);
    }

    /**
     * Validate a raw access token value and return the current user.
     */
    public User validateAccessToken(String token) {
        if (token == null || token.trim().isEmpty()) return null;

        Map<String, Object> claims = JwtUtil.verifyAuthToken(token);
        if (claims == null) return null;

        // Verify token type
        if (!"access".equals(claims.get("type"))) return null;

        return buildUserFromClaims(claims);
    }

    private User buildUserFromClaims(Map<String, Object> claims) {
        int userId = ((Number) claims.get("sub")).intValue();

        // Load full user from DB (ensures latest role/active status)
        return userDAO.getUserById(userId);
    }

    /**
     * Attempt to refresh the access token using the refresh token cookie.
     * If successful, sets a new access token cookie and returns the user.
     *
     * @return User object or null if refresh fails
     */
    public User refreshAccessToken(HttpServletRequest request, HttpServletResponse response) {
        RefreshCookieData refreshCookie = parseRefreshCookie(request);
        if (refreshCookie == null) return null;

        Integer tokenUserId = refreshTokenDAO.getUserIdByActiveToken(refreshCookie.tokenId);
        if (tokenUserId == null) {
            LOGGER.log(Level.WARNING, "Refresh token revoked or expired in DB: {0}", refreshCookie.tokenId);
            return null;
        }

        if (refreshCookie.userId != null && refreshCookie.userId.intValue() != tokenUserId.intValue()) {
            LOGGER.log(Level.WARNING, "Refresh token user mismatch for token {0}", refreshCookie.tokenId);
            return null;
        }

        User user = userDAO.getUserById(tokenUserId);
        if (user == null || !user.isActive()) return null;

        // Cleanup legacy access-cookie copies so future requests stay below Tomcat's header limit.
        clearAccessCookies(response, request.isSecure(), resolveCookiePath(request));

        // Update last activity
        refreshTokenDAO.updateLastActivity(refreshCookie.tokenId);

        LOGGER.log(Level.INFO, "Session restored from refresh token for user {0}", user.getEmail());
        return user;
    }

    /**
     * Revoke all tokens and clear cookies (logout).
     */
    public void revokeTokens(HttpServletRequest request, HttpServletResponse response) {
        boolean secure = request.isSecure();
        String cookiePath = resolveCookiePath(request);

        // Revoke refresh token in DB
        RefreshCookieData refreshCookie = parseRefreshCookie(request);
        if (refreshCookie != null) {
            refreshTokenDAO.revokeToken(refreshCookie.tokenId);
        }

        clearAuthCookies(response, secure, cookiePath);
    }

    /**
     * Revoke ALL tokens for a user (password change, security event).
     */
    public void revokeAllUserTokens(int userId, HttpServletRequest request, HttpServletResponse response) {
        refreshTokenDAO.revokeAllTokens(userId);
        revokeTokens(request, response);
    }

    /** Remove legacy access-cookie copies when the browser still sends them. */
    public void cleanupLegacyAccessCookie(HttpServletRequest request, HttpServletResponse response) {
        if (CookieUtil.getCookieValue(request, CookieUtil.ACCESS_TOKEN_COOKIE) == null) {
            return;
        }
        clearAccessCookies(response, request.isSecure(), resolveCookiePath(request));
    }

    private String getClientIp(HttpServletRequest request) {
        String ip = request.getHeader("X-Forwarded-For");
        if (ip != null && !ip.isEmpty()) {
            return ip.split(",")[0].trim();
        }
        return request.getRemoteAddr();
    }

    private RefreshCookieData parseRefreshCookie(HttpServletRequest request) {
        String rawRefreshCookie = CookieUtil.getCookieValue(request, CookieUtil.REFRESH_TOKEN_COOKIE);
        if (rawRefreshCookie == null || rawRefreshCookie.trim().isEmpty()) {
            return null;
        }

        String value = rawRefreshCookie.trim();
        if (!value.contains(".")) {
            return new RefreshCookieData(value, null);
        }

        Map<String, Object> claims = JwtUtil.verifyAuthToken(value);
        if (claims == null || !"refresh".equals(claims.get("type"))) {
            return null;
        }

        String jti = (String) claims.get("jti");
        if (jti == null || jti.trim().isEmpty()) {
            return null;
        }

        Number sub = (Number) claims.get("sub");
        Integer userId = sub == null ? null : sub.intValue();
        return new RefreshCookieData(jti, userId);
    }

    private void clearAuthCookies(HttpServletResponse response, boolean secure, String cookiePath) {
        clearAccessCookies(response, secure, cookiePath);
        clearRefreshCookies(response, secure, cookiePath);
    }

    private void clearAccessCookies(HttpServletResponse response, boolean secure, String cookiePath) {
        CookieUtil.deleteCookie(response, CookieUtil.ACCESS_TOKEN_COOKIE, secure, cookiePath);
        CookieUtil.deleteCookie(response, CookieUtil.ACCESS_TOKEN_COOKIE, secure, "/");
    }

    private void clearRefreshCookies(HttpServletResponse response, boolean secure, String cookiePath) {
        CookieUtil.deleteCookie(response, CookieUtil.REFRESH_TOKEN_COOKIE, secure, cookiePath);
        CookieUtil.deleteCookie(response, CookieUtil.REFRESH_TOKEN_COOKIE, secure, "/");
    }

    private String resolveCookiePath(HttpServletRequest request) {
        String cp = request.getContextPath();
        return (cp == null || cp.isEmpty()) ? "/" : cp;
    }

    private static final class RefreshCookieData {
        private final String tokenId;
        private final Integer userId;

        private RefreshCookieData(String tokenId, Integer userId) {
            this.tokenId = tokenId;
            this.userId = userId;
        }
    }
}
