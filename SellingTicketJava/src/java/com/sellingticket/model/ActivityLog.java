package com.sellingticket.model;

import java.util.Date;

/**
 * Represents an audit trail entry for admin/system actions.
 */
public class ActivityLog {

    private int logId;
    private int userId;
    private String action;
    private String entityType;
    private int entityId;
    private String details;
    private String ipAddress;
    private Date createdAt;

    // Joined fields
    private String userEmail;
    private String userName;

    public ActivityLog() {}

    // Getters and Setters
    public int getLogId() { return logId; }
    public void setLogId(int logId) { this.logId = logId; }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public String getAction() { return action; }
    public void setAction(String action) { this.action = action; }

    public String getEntityType() { return entityType; }
    public void setEntityType(String entityType) { this.entityType = entityType; }

    public int getEntityId() { return entityId; }
    public void setEntityId(int entityId) { this.entityId = entityId; }

    public String getDetails() { return details; }
    public void setDetails(String details) { this.details = details; }

    public String getIpAddress() { return ipAddress; }
    public void setIpAddress(String ipAddress) { this.ipAddress = ipAddress; }

    public Date getCreatedAt() { return createdAt; }
    public void setCreatedAt(Date createdAt) { this.createdAt = createdAt; }

    public String getUserEmail() { return userEmail; }
    public void setUserEmail(String userEmail) { this.userEmail = userEmail; }

    public String getUserName() { return userName; }
    public void setUserName(String userName) { this.userName = userName; }

    @Override
    public String toString() {
        return "ActivityLog{id=" + logId + ", action='" + action + "', entity=" + entityType + "#" + entityId + "}";
    }
}
