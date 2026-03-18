package com.sellingticket.service;

import com.sellingticket.dao.ActivityLogDAO;
import com.sellingticket.model.ActivityLog;
import com.sellingticket.model.User;
import jakarta.servlet.http.HttpServletRequest;

import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Service layer for activity logging. Provides convenience methods that
 * extract IP from request and handle nulls gracefully.
 */
public class ActivityLogService {

    private static final Logger LOGGER = Logger.getLogger(ActivityLogService.class.getName());
    private final ActivityLogDAO activityLogDAO = new ActivityLogDAO();

    /**
     * Log an action with full context from HTTP request.
     */
    public void logAction(User user, String action, String entityType, int entityId,
                          String details, HttpServletRequest request) {
        if (user == null) return;
        String ip = getClientIP(request);
        try {
            activityLogDAO.log(user.getUserId(), action, entityType, entityId, details, ip);
        } catch (Exception e) {
            // Never let logging failure break the main flow
            LOGGER.log(Level.WARNING, "Failed to log activity: " + action, e);
        }
    }

    /**
     * Log an action without HTTP request context.
     */
    public void logAction(int userId, String action, String entityType, int entityId, String details) {
        try {
            activityLogDAO.log(userId, action, entityType, entityId, details, null);
        } catch (Exception e) {
            LOGGER.log(Level.WARNING, "Failed to log activity: " + action, e);
        }
    }

    /** Get recent activity log entries for dashboard. */
    public List<ActivityLog> getRecent(int limit) {
        return activityLogDAO.getRecent(limit);
    }

    /** Search with filters and pagination. */
    public List<ActivityLog> search(String action, int userId, String entityType,
                                    int page, int pageSize) {
        return activityLogDAO.search(action, userId, entityType, page, pageSize);
    }

    /** Count matching entries for pagination. */
    public int countSearch(String action, int userId, String entityType) {
        return activityLogDAO.countSearch(action, userId, entityType);
    }

    /** Get distinct action types for filter UI. */
    public List<String> getDistinctActions() {
        return activityLogDAO.getDistinctActions();
    }

    /**
     * Extract client IP address, respecting proxy headers.
     */
    private String getClientIP(HttpServletRequest request) {
        if (request == null) return null;
        String ip = request.getHeader("X-Forwarded-For");
        if (ip != null && !ip.isEmpty()) {
            return ip.split(",")[0].trim();
        }
        ip = request.getHeader("X-Real-IP");
        if (ip != null && !ip.isEmpty()) return ip;
        return request.getRemoteAddr();
    }
}
