package com.sellingticket.service;

import com.sellingticket.dao.NotificationDAO;
import com.sellingticket.dao.UserDAO;
import com.sellingticket.model.Notification;
import com.sellingticket.model.User;

import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Service layer for in-app notifications. Provides methods to send
 * notifications to specific users or all admins.
 */
public class NotificationService {

    private static final Logger LOGGER = Logger.getLogger(NotificationService.class.getName());
    private final NotificationDAO notificationDAO = new NotificationDAO();
    private final UserDAO userDAO = new UserDAO();

    /**
     * Send a notification to a specific user.
     */
    public boolean notify(int userId, String type, String title, String message, String link) {
        try {
            return notificationDAO.create(userId, type, title, message, link);
        } catch (Exception e) {
            LOGGER.log(Level.WARNING, "Failed to create notification for user " + userId, e);
        }
        return false;
    }

    /**
     * Send a notification to ALL admin users.
     */
    public void notifyAllAdmins(String type, String title, String message, String link) {
        try {
            List<User> admins = userDAO.getUsersByRole("admin");
            for (User admin : admins) {
                notificationDAO.create(admin.getUserId(), type, title, message, link);
            }
        } catch (Exception e) {
            LOGGER.log(Level.WARNING, "Failed to notify admins: " + title, e);
        }
    }

    /** Get notifications for a user (recent first). */
    public List<Notification> getByUser(int userId, int limit) {
        return notificationDAO.getByUser(userId, limit);
    }

    /** Count unread notifications. */
    public int countUnread(int userId) {
        return notificationDAO.countUnread(userId);
    }

    /** Mark a single notification as read. */
    public boolean markRead(int notificationId, int userId) {
        return notificationDAO.markRead(notificationId, userId);
    }

    /** Mark all notifications as read. */
    public int markAllRead(int userId) {
        return notificationDAO.markAllRead(userId);
    }

    /** Delete old read notifications (housekeeping). */
    public int cleanupRead(int daysOld) {
        return notificationDAO.deleteOldRead(daysOld);
    }
}
