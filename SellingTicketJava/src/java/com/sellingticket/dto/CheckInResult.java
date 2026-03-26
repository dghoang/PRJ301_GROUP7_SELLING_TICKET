package com.sellingticket.dto;

import java.io.Serializable;
import java.util.List;
import java.util.Map;

/**
 * Data Transfer Object for Check-in Results.
 */
public class CheckInResult implements Serializable {
    private boolean success;
    private String message;
    private String error;
    private boolean alreadyCheckedIn;
    
    // For ticket details
    private String ticketCode;
    private Integer ticketId;
    private String customerName;
    private String ticketType;

    // For order lookup action
    private String action; // "lookup" or "checkin"
    private String orderCode;
    private List<Map<String, Object>> tickets;

    public CheckInResult() {}

    public static CheckInResult success(String message) {
        CheckInResult res = new CheckInResult();
        res.setSuccess(true);
        res.setMessage(message);
        return res;
    }

    public static CheckInResult error(String error) {
        CheckInResult res = new CheckInResult();
        res.setSuccess(false);
        res.setError(error);
        return res;
    }

    // Getters and Setters
    public boolean isSuccess() { return success; }
    public void setSuccess(boolean success) { this.success = success; }

    public String getMessage() { return message; }
    public void setMessage(String message) { this.message = message; }

    public String getError() { return error; }
    public void setError(String error) { this.error = error; }

    public boolean isAlreadyCheckedIn() { return alreadyCheckedIn; }
    public void setAlreadyCheckedIn(boolean alreadyCheckedIn) { this.alreadyCheckedIn = alreadyCheckedIn; }

    public String getTicketCode() { return ticketCode; }
    public void setTicketCode(String ticketCode) { this.ticketCode = ticketCode; }

    public Integer getTicketId() { return ticketId; }
    public void setTicketId(Integer ticketId) { this.ticketId = ticketId; }

    public String getCustomerName() { return customerName; }
    public void setCustomerName(String customerName) { this.customerName = customerName; }

    public String getTicketType() { return ticketType; }
    public void setTicketType(String ticketType) { this.ticketType = ticketType; }

    public String getAction() { return action; }
    public void setAction(String action) { this.action = action; }

    public String getOrderCode() { return orderCode; }
    public void setOrderCode(String orderCode) { this.orderCode = orderCode; }

    public List<Map<String, Object>> getTickets() { return tickets; }
    public void setTickets(List<Map<String, Object>> tickets) { this.tickets = tickets; }
}
