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

        // Cleanup legacy root-path cookies to avoid duplicated auth cookies in request header.
        CookieUtil.deleteCookie(response, CookieUtil.ACCESS_TOKEN_COOKIE, secure, "/");
        CookieUtil.deleteCookie(response, CookieUtil.REFRESH_TOKEN_COOKIE, secure, "/");

        // Access token
        String accessToken = JwtUtil.generateAccessToken(
                user.getUserId(), user.getEmail(), user.getRole());

        int accessMaxAge = rememberMe ? (int) JwtUtil.ACCESS_TOKEN_EXPIRY_SEC : -1;
        CookieUtil.addSecureCookie(response, CookieUtil.ACCESS_TOKEN_COOKIE,
            accessToken, accessMaxAge, secure, cookiePath);

        // Refresh token
        String[] refreshResult = JwtUtil.generateRefreshToken(user.getUserId());
        String refreshToken = refreshResult[0];
        String jti = refreshResult[1];

        int refreshMaxAge = rememberMe ? (int) JwtUtil.REFRESH_TOKEN_EXPIRY_SEC : -1;
        CookieUtil.addSecureCookie(response, CookieUtil.REFRESH_TOKEN_COOKIE,
            refreshToken, refreshMaxAge, secure, cookiePath);

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
        if (token == null) return null;

        Map<String, Object> claims = JwtUtil.verifyAuthToken(token);
        if (claims == null) return null;

        // Verify token type
        if (!"access".equals(claims.get("type"))) return null;

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
        String refreshToken = CookieUtil.getCookieValue(request, CookieUtil.REFRESH_TOKEN_COOKIE);
        if (refreshToken == null) return null;

        Map<String, Object> claims = JwtUtil.verifyAuthToken(refreshToken);
        if (claims == null) return null;

        // Verify token type
        if (!"refresh".equals(claims.get("type"))) return null;

        String jti = (String) claims.get("jti");
        if (jti == null) return null;

        // Verify refresh token is still valid in DB (not revoked)
        if (!refreshTokenDAO.isTokenValid(jti)) {
            LOGGER.log(Level.WARNING, "Refresh token revoked or expired in DB: {0}", jti);
            return null;
        }

        int userId = ((Number) claims.get("sub")).intValue();
        User user = userDAO.getUserById(userId);
        if (user == null || !user.isActive()) return null;

        // Issue new access token only (refresh token stays valid)
        String newAccessToken = JwtUtil.generateAccessToken(
                user.getUserId(), user.getEmail(), user.getRole());

        String cookiePath = resolveCookiePath(request);
        // Cleanup legacy root-path cookie copy first.
        CookieUtil.deleteCookie(response, CookieUtil.ACCESS_TOKEN_COOKIE, request.isSecure(), "/");

        // Use persistent cookie if original refresh cookie exists (user chose remember-me)
        int maxAge = (int) JwtUtil.ACCESS_TOKEN_EXPIRY_SEC;
        CookieUtil.addSecureCookie(response, CookieUtil.ACCESS_TOKEN_COOKIE,
            newAccessToken, maxAge, request.isSecure(), cookiePath);

        // Update last activity
        refreshTokenDAO.updateLastActivity(jti);

        LOGGER.log(Level.INFO, "Access token refreshed for user {0}", user.getEmail());
        return user;
    }

    /**
     * Revoke all tokens and clear cookies (logout).
     */
    public void revokeTokens(HttpServletRequest request, HttpServletResponse response) {
        boolean secure = request.isSecure();
        String cookiePath = resolveCookiePath(request);

        // Revoke refresh token in DB
        String refreshToken = CookieUtil.getCookieValue(request, CookieUtil.REFRESH_TOKEN_COOKIE);
        if (refreshToken != null) {
            Map<String, Object> claims = JwtUtil.verifyAuthToken(refreshToken);
            if (claims != null) {
                String jti = (String) claims.get("jti");
                if (jti != null) {
                    refreshTokenDAO.revokeToken(jti);
                }
            }
        }

        // Delete cookies
        CookieUtil.deleteCookie(response, CookieUtil.ACCESS_TOKEN_COOKIE, secure, cookiePath);
        CookieUtil.deleteCookie(response, CookieUtil.REFRESH_TOKEN_COOKIE, secure, cookiePath);
        // Also delete legacy root-path copies.
        CookieUtil.deleteCookie(response, CookieUtil.ACCESS_TOKEN_COOKIE, secure, "/");
        CookieUtil.deleteCookie(response, CookieUtil.REFRESH_TOKEN_COOKIE, secure, "/");
    }

    /**
     * Revoke ALL tokens for a user (password change, security event).
     */
    public void revokeAllUserTokens(int userId, HttpServletRequest request, HttpServletResponse response) {
        refreshTokenDAO.revokeAllTokens(userId);
        revokeTokens(request, response);
    }

    private String getClientIp(HttpServletRequest request) {
        String ip = request.getHeader("X-Forwarded-For");
        if (ip != null && !ip.isEmpty()) {
            return ip.split(",")[0].trim();
        }
        return request.getRemoteAddr();
    }

    private String resolveCookiePath(HttpServletRequest request) {
        String cp = request.getContextPath();
        return (cp == null || cp.isEmpty()) ? "/" : cp;
    }
}
