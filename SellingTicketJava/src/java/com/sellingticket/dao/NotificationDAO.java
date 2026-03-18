package com.sellingticket.dao;

import com.sellingticket.model.Notification;
import com.sellingticket.util.DBContext;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * DAO for in-app notification operations.
 */
public class NotificationDAO extends DBContext {

    private static final Logger LOGGER = Logger.getLogger(NotificationDAO.class.getName());

    /**
     * Create a new notification for a user.
     */
    public boolean create(int userId, String type, String title, String message, String link) {
        String sql = "INSERT INTO Notifications (user_id, type, title, message, link) VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setString(2, type);
            ps.setString(3, truncate(title, 200));
            ps.setString(4, truncate(message, 500));
            ps.setString(5, truncate(link, 300));
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error creating notification", e);
        }
        return false;
    }

    /**
     * Get notifications for a user (most recent first).
     */
    public List<Notification> getByUser(int userId, int limit) {
        List<Notification> list = new ArrayList<>();
        String sql = "SELECT TOP (?) * FROM Notifications WHERE user_id = ? ORDER BY created_at DESC";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, Math.min(limit, 100));
            ps.setInt(2, userId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error getting notifications for user " + userId, e);
        }
        return list;
    }

    /**
     * Count unread notifications for a user.
     */
    public int countUnread(int userId) {
        String sql = "SELECT COUNT(*) FROM Notifications WHERE user_id = ? AND is_read = 0";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error counting unread notifications", e);
        }
        return 0;
    }

    /**
     * Mark a single notification as read.
     */
    public boolean markRead(int notificationId, int userId) {
        String sql = "UPDATE Notifications SET is_read = 1 WHERE notification_id = ? AND user_id = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, notificationId);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error marking notification as read", e);
        }
        return false;
    }

    /**
     * Mark all notifications as read for a user.
     */
    public int markAllRead(int userId) {
        String sql = "UPDATE Notifications SET is_read = 1 WHERE user_id = ? AND is_read = 0";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            return ps.executeUpdate();
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error marking all notifications as read", e);
        }
        return 0;
    }

    /**
     * Delete old read notifications (cleanup, keep last N days).
     */
    public int deleteOldRead(int daysOld) {
        String sql = "DELETE FROM Notifications WHERE is_read = 1 AND created_at < DATEADD(DAY, ?, GETDATE())";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, -Math.abs(daysOld));
            return ps.executeUpdate();
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error deleting old notifications", e);
        }
        return 0;
    }

    private Notification mapRow(ResultSet rs) throws Exception {
        Notification n = new Notification();
        n.setNotificationId(rs.getInt("notification_id"));
        n.setUserId(rs.getInt("user_id"));
        n.setType(rs.getString("type"));
        n.setTitle(rs.getString("title"));
        n.setMessage(rs.getString("message"));
        n.setLink(rs.getString("link"));
        n.setRead(rs.getBoolean("is_read"));
        n.setCreatedAt(rs.getTimestamp("created_at"));
        return n;
    }

    private String truncate(String value, int maxLen) {
        if (value == null) return null;
        return value.length() > maxLen ? value.substring(0, maxLen) : value;
    }
}
