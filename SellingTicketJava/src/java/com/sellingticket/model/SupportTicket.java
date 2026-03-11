package com.sellingticket.model;

import java.util.Date;
import java.util.List;

public class SupportTicket {
    private int ticketId;
    private String ticketCode;
    private int userId;
    private Integer orderId;
    private Integer eventId;
    private String category;
    private String subject;
    private String description;
    private String status;
    private String priority;
    private String routedTo; // 'admin' or 'organizer'
    private Integer assignedTo;
    private Date resolvedAt;
    private Date createdAt;
    private Date updatedAt;

    // Joined fields
    private String userName;
    private String userEmail;
    private String orderCode;
    private String eventTitle;
    private String assignedToName;
    private String customerTier;
    private List<TicketMessage> messages;

    public SupportTicket() {}

    public int getTicketId() { return ticketId; }
    public void setTicketId(int ticketId) { this.ticketId = ticketId; }

    public String getTicketCode() { return ticketCode; }
    public void setTicketCode(String ticketCode) { this.ticketCode = ticketCode; }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public Integer getOrderId() { return orderId; }
    public void setOrderId(Integer orderId) { this.orderId = orderId; }

    public Integer getEventId() { return eventId; }
    public void setEventId(Integer eventId) { this.eventId = eventId; }

    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }

    public String getSubject() { return subject; }
    public void setSubject(String subject) { this.subject = subject; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getPriority() { return priority; }
    public void setPriority(String priority) { this.priority = priority; }

    public String getRoutedTo() { return routedTo; }
    public void setRoutedTo(String routedTo) { this.routedTo = routedTo; }

    public Integer getAssignedTo() { return assignedTo; }
    public void setAssignedTo(Integer assignedTo) { this.assignedTo = assignedTo; }

    public Date getResolvedAt() { return resolvedAt; }
    public void setResolvedAt(Date resolvedAt) { this.resolvedAt = resolvedAt; }

    public Date getCreatedAt() { return createdAt; }
    public void setCreatedAt(Date createdAt) { this.createdAt = createdAt; }

    public Date getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Date updatedAt) { this.updatedAt = updatedAt; }

    public String getUserName() { return userName; }
    public void setUserName(String userName) { this.userName = userName; }

    public String getUserEmail() { return userEmail; }
    public void setUserEmail(String userEmail) { this.userEmail = userEmail; }

    public String getOrderCode() { return orderCode; }
    public void setOrderCode(String orderCode) { this.orderCode = orderCode; }

    public String getEventTitle() { return eventTitle; }
    public void setEventTitle(String eventTitle) { this.eventTitle = eventTitle; }

    public String getAssignedToName() { return assignedToName; }
    public void setAssignedToName(String assignedToName) { this.assignedToName = assignedToName; }

    public String getCustomerTier() { return customerTier; }
    public void setCustomerTier(String customerTier) { this.customerTier = customerTier; }

    public List<TicketMessage> getMessages() { return messages; }
    public void setMessages(List<TicketMessage> messages) { this.messages = messages; }

    public String getCategoryLabel() {
        switch (category != null ? category : "") {
            case "payment_error": return "Lỗi thanh toán";
            case "missing_ticket": return "Không nhận được vé";
            case "cancellation": return "Yêu cầu hủy vé";
            case "refund": return "Yêu cầu hoàn tiền";
            case "event_issue": return "Vấn đề sự kiện";
            case "account_issue": return "Vấn đề tài khoản";
            case "technical": return "Lỗi kỹ thuật";
            case "feedback": return "Góp ý / Phản hồi";
            default: return "Khác";
        }
    }

    public String getStatusLabel() {
        switch (status != null ? status : "") {
            case "open": return "Mở";
            case "in_progress": return "Đang xử lý";
            case "resolved": return "Đã giải quyết";
            case "closed": return "Đã đóng";
            default: return status;
        }
    }

    public String getRoutedToLabel() {
        return "organizer".equals(routedTo) ? "Ban tổ chức" : "Admin hệ thống";
    }

    /** Determine routing based on category. */
    public static String computeRoutedTo(String category, Integer eventId) {
        if (eventId != null && ("missing_ticket".equals(category)
                || "cancellation".equals(category)
                || "event_issue".equals(category))) {
            return "organizer";
        }
        return "admin";
    }
}
