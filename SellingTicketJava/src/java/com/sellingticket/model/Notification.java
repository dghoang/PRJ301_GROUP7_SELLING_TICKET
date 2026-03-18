package com.sellingticket.model;

import java.util.Date;

/**
 * Represents an in-app notification for a user.
 */
public class Notification {

    private int notificationId;
    private int userId;
    private String type;
    private String title;
    private String message;
    private String link;
    private boolean read;
    private Date createdAt;

    public Notification() {}

    // Getters and Setters
    public int getNotificationId() { return notificationId; }
    public void setNotificationId(int notificationId) { this.notificationId = notificationId; }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public String getType() { return type; }
    public void setType(String type) { this.type = type; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getMessage() { return message; }
    public void setMessage(String message) { this.message = message; }

    public String getLink() { return link; }
    public void setLink(String link) { this.link = link; }

    public boolean isRead() { return read; }
    public void setRead(boolean read) { this.read = read; }

    public Date getCreatedAt() { return createdAt; }
    public void setCreatedAt(Date createdAt) { this.createdAt = createdAt; }

    @Override
    public String toString() {
        return "Notification{id=" + notificationId + ", type='" + type + "', title='" + title + "'}";
    }
}
