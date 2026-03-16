package com.sellingticket.dao;

import com.sellingticket.util.DBContext;
import java.sql.*;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * DAO for refresh token persistence using the UserSessions table.
 *
 * <p>Mapping:
 * <ul>
 *   <li>session_token ← JWT jti (unique token ID)</li>
 *   <li>device_info ← User-Agent header</li>
 *   <li>ip_address ← Client IP</li>
 *   <li>expires_at ← Token expiry timestamp</li>
 *   <li>is_active ← Used for revocation</li>
 * </ul>
 */
public class RefreshTokenDAO extends DBContext {

    private static final Logger LOGGER = Logger.getLogger(RefreshTokenDAO.class.getName());

    /** Save a new refresh token entry. */
    public boolean saveToken(int userId, String tokenId, String deviceInfo, String ip, Timestamp expiresAt) {
        String sql = "INSERT INTO UserSessions (user_id, session_token, device_info, ip_address, expires_at) "
                   + "VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setString(2, tokenId);
            ps.setString(3, truncate(deviceInfo, 255));
            ps.setString(4, ip);
            ps.setTimestamp(5, expiresAt);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to save refresh token", e);
        }
        return false;
    }

    /** Check if a refresh token is active and not expired. */
    public boolean isTokenValid(String tokenId) {
        String sql = "SELECT 1 FROM UserSessions WHERE session_token = ? AND is_active = 1 AND expires_at > GETDATE()";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, tokenId);
            return ps.executeQuery().next();
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to validate refresh token", e);
        }
        return false;
    }

    /** Resolve the owning user for an active refresh token. */
    public Integer getUserIdByActiveToken(String tokenId) {
        String sql = "SELECT user_id FROM UserSessions WHERE session_token = ? AND is_active = 1 AND expires_at > GETDATE()";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, tokenId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("user_id");
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to resolve user from refresh token", e);
        }
        return null;
    }

    /** Revoke a single refresh token. */
    public boolean revokeToken(String tokenId) {
        String sql = "UPDATE UserSessions SET is_active = 0 WHERE session_token = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, tokenId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to revoke refresh token", e);
        }
        return false;
    }

    /** Revoke all refresh tokens for a user (force logout everywhere). */
    public boolean revokeAllTokens(int userId) {
        String sql = "UPDATE UserSessions SET is_active = 0 WHERE user_id = ? AND is_active = 1";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to revoke all tokens for user: " + userId, e);
        }
        return false;
    }

    /** Update last_activity timestamp for a token. */
    public boolean updateLastActivity(String tokenId) {
        String sql = "UPDATE UserSessions SET last_activity = GETDATE() WHERE session_token = ? AND is_active = 1";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, tokenId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to update last activity", e);
        }
        return false;
    }

    /** Remove expired and revoked tokens older than 7 days. */
    public int cleanupExpired() {
        String sql = "DELETE FROM UserSessions WHERE is_active = 0 OR expires_at < DATEADD(day, -7, GETDATE())";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            return ps.executeUpdate();
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to cleanup expired tokens", e);
        }
        return 0;
    }

    private String truncate(String s, int maxLen) {
        if (s == null) return null;
        return s.length() > maxLen ? s.substring(0, maxLen) : s;
    }
}
