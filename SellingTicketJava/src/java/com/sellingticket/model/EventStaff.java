package com.sellingticket.model;

import java.util.Date;

public class EventStaff {
    private int staffId;
    private int eventId;
    private int userId;
    private String role; // manager, editor, checkin
    private int grantedBy;
    private Date createdAt;
    
    // Extra fields for UI
    private String userEmail;
    private String fullName;

    public EventStaff() {}

    public int getStaffId() { return staffId; }
    public void setStaffId(int staffId) { this.staffId = staffId; }

    public int getEventId() { return eventId; }
    public void setEventId(int eventId) { this.eventId = eventId; }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }

    public int getGrantedBy() { return grantedBy; }
    public void setGrantedBy(int grantedBy) { this.grantedBy = grantedBy; }

    public Date getCreatedAt() { return createdAt; }
    public void setCreatedAt(Date createdAt) { this.createdAt = createdAt; }

    public String getUserEmail() { return userEmail; }
    public void setUserEmail(String userEmail) { this.userEmail = userEmail; }

    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }
}
