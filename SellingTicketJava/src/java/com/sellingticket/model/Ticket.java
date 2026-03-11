package com.sellingticket.model;

import java.util.Date;

/**
 * Ticket — Individual issued ticket linked to an OrderItem.
 * Maps to the Tickets table in the database.
 * Each OrderItem with quantity N generates N individual Ticket rows, each with a unique QR code.
 */
public class Ticket {
    private int ticketId;
    private String ticketCode;
    private int orderItemId;
    private String attendeeName;
    private String attendeeEmail;
    private String qrCode;
    private boolean isCheckedIn;
    private Date checkedInAt;
    private Integer checkedInBy;
    private Date createdAt;

    // Joined fields for display
    private String eventTitle;
    private int eventId;
    private String ticketTypeName;
    private String orderCode;

    public Ticket() {}

    // Getters and Setters
    public int getTicketId() { return ticketId; }
    public void setTicketId(int ticketId) { this.ticketId = ticketId; }

    public String getTicketCode() { return ticketCode; }
    public void setTicketCode(String ticketCode) { this.ticketCode = ticketCode; }

    public int getOrderItemId() { return orderItemId; }
    public void setOrderItemId(int orderItemId) { this.orderItemId = orderItemId; }

    public String getAttendeeName() { return attendeeName; }
    public void setAttendeeName(String attendeeName) { this.attendeeName = attendeeName; }

    public String getAttendeeEmail() { return attendeeEmail; }
    public void setAttendeeEmail(String attendeeEmail) { this.attendeeEmail = attendeeEmail; }

    public String getQrCode() { return qrCode; }
    public void setQrCode(String qrCode) { this.qrCode = qrCode; }

    public boolean isCheckedIn() { return isCheckedIn; }
    public void setCheckedIn(boolean checkedIn) { isCheckedIn = checkedIn; }

    public Date getCheckedInAt() { return checkedInAt; }
    public void setCheckedInAt(Date checkedInAt) { this.checkedInAt = checkedInAt; }

    public Integer getCheckedInBy() { return checkedInBy; }
    public void setCheckedInBy(Integer checkedInBy) { this.checkedInBy = checkedInBy; }

    public Date getCreatedAt() { return createdAt; }
    public void setCreatedAt(Date createdAt) { this.createdAt = createdAt; }

    public String getEventTitle() { return eventTitle; }
    public void setEventTitle(String eventTitle) { this.eventTitle = eventTitle; }

    public int getEventId() { return eventId; }
    public void setEventId(int eventId) { this.eventId = eventId; }

    public String getTicketTypeName() { return ticketTypeName; }
    public void setTicketTypeName(String ticketTypeName) { this.ticketTypeName = ticketTypeName; }

    public String getOrderCode() { return orderCode; }
    public void setOrderCode(String orderCode) { this.orderCode = orderCode; }

    @Override
    public String toString() {
        return "Ticket{id=" + ticketId + ", code='" + ticketCode + "', checkedIn=" + isCheckedIn + "}";
    }
}
