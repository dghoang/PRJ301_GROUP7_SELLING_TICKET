package com.sellingticket.dao;

import com.sellingticket.model.ActivityLog;
import com.sellingticket.util.DBContext;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * DAO for audit trail operations. Records and retrieves admin/system actions.
 */
public class ActivityLogDAO extends DBContext {

    private static final Logger LOGGER = Logger.getLogger(ActivityLogDAO.class.getName());

    /**
     * Insert an activity log entry.
     */
    public boolean log(int userId, String action, String entityType, int entityId,
                       String details, String ipAddress) {
        String sql = "INSERT INTO ActivityLog (user_id, action, entity_type, entity_id, details, ip_address) "
                   + "VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setString(2, action);
            ps.setString(3, entityType);
            ps.setInt(4, entityId);
            ps.setString(5, truncate(details, 500));
            ps.setString(6, ipAddress);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error logging activity", e);
        }
        return false;
    }

    /**
     * Get recent activity log entries (for dashboard feed).
     */
    public List<ActivityLog> getRecent(int limit) {
        List<ActivityLog> list = new ArrayList<>();
        String sql = "SELECT TOP (?) al.*, u.email, u.full_name "
                   + "FROM ActivityLog al "
                   + "JOIN Users u ON al.user_id = u.user_id "
                   + "ORDER BY al.created_at DESC";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, Math.min(limit, 100));
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error getting recent activity logs", e);
        }
        return list;
    }

    /**
     * Search activity logs with filters and pagination.
     *
     * @param action     filter by action type (null = all)
     * @param userId     filter by user (0 = all)
     * @param entityType filter by entity type (null = all)
     * @param page       1-based page number
     * @param pageSize   items per page
     * @return list of matching activity logs
     */
    public List<ActivityLog> search(String action, int userId, String entityType,
                                    int page, int pageSize) {
        List<ActivityLog> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT al.*, u.email, u.full_name FROM ActivityLog al "
          + "JOIN Users u ON al.user_id = u.user_id WHERE 1=1 ");

        List<Object> params = new ArrayList<>();

        if (action != null && !action.isEmpty()) {
            sql.append("AND al.action = ? ");
            params.add(action);
        }
        if (userId > 0) {
            sql.append("AND al.user_id = ? ");
            params.add(userId);
        }
        if (entityType != null && !entityType.isEmpty()) {
            sql.append("AND al.entity_type = ? ");
            params.add(entityType);
        }

        sql.append("ORDER BY al.created_at DESC ");
        sql.append("OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");

        int offset = (Math.max(page, 1) - 1) * pageSize;
        params.add(offset);
        params.add(pageSize);

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                Object p = params.get(i);
                if (p instanceof String) ps.setString(i + 1, (String) p);
                else ps.setInt(i + 1, (int) p);
            }
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error searching activity logs", e);
        }
        return list;
    }

    /**
     * Count total activity logs matching filters (for pagination).
     */
    public int countSearch(String action, int userId, String entityType) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM ActivityLog al WHERE 1=1 ");
        List<Object> params = new ArrayList<>();

        if (action != null && !action.isEmpty()) {
            sql.append("AND al.action = ? ");
            params.add(action);
        }
        if (userId > 0) {
            sql.append("AND al.user_id = ? ");
            params.add(userId);
        }
        if (entityType != null && !entityType.isEmpty()) {
            sql.append("AND al.entity_type = ? ");
            params.add(entityType);
        }

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                Object p = params.get(i);
                if (p instanceof String) ps.setString(i + 1, (String) p);
                else ps.setInt(i + 1, (int) p);
            }
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error counting activity logs", e);
        }
        return 0;
    }

    /**
     * Get distinct action types (for filter dropdown).
     */
    public List<String> getDistinctActions() {
        List<String> actions = new ArrayList<>();
        String sql = "SELECT DISTINCT action FROM ActivityLog ORDER BY action";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                actions.add(rs.getString("action"));
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error getting distinct actions", e);
        }
        return actions;
    }

    private ActivityLog mapRow(ResultSet rs) throws Exception {
        ActivityLog log = new ActivityLog();
        log.setLogId(rs.getInt("log_id"));
        log.setUserId(rs.getInt("user_id"));
        log.setAction(rs.getString("action"));
        log.setEntityType(rs.getString("entity_type"));
        log.setEntityId(rs.getInt("entity_id"));
        log.setDetails(rs.getString("details"));
        log.setIpAddress(rs.getString("ip_address"));
        log.setCreatedAt(rs.getTimestamp("created_at"));
        log.setUserEmail(rs.getString("email"));
        log.setUserName(rs.getString("full_name"));
        return log;
    }

    private String truncate(String value, int maxLen) {
        if (value == null) return null;
        return value.length() > maxLen ? value.substring(0, maxLen) : value;
    }
}
