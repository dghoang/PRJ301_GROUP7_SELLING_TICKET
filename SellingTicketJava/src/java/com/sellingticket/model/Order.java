package com.sellingticket.model;

import java.util.Date;
import java.util.List;

public class Order {
    private int orderId;
    private String orderCode;
    private int userId;
    private int eventId;
    private double totalAmount;          // Face value (gia ve goc)
    private double discountAmount;       // Total discount (event + system)
    private double finalAmount;          // Customer paid
    private String status;
    private String paymentMethod;
    private Date paymentDate;
    private String buyerName;
    private String buyerEmail;
    private String buyerPhone;
    private String notes;
    private String voucherCode;
    private Date createdAt;

    // Voucher/settlement tracking (for reconcile)
    private Integer voucherId;
    private String voucherScope;         // NONE | EVENT | SYSTEM
    private String voucherFundSource;    // NONE | ORGANIZER | SYSTEM
    private double eventDiscountAmount;  // deducted from organizer revenue
    private double systemDiscountAmount; // platform subsidy
    private double platformFeeAmount;    // platform fee (if any)
    private double organizerGrossAmount; // totalAmount - eventDiscountAmount
    private double organizerPayoutAmount;// organizerGrossAmount - platformFeeAmount

    // Joined fields
    private String eventTitle;
    private List<OrderItem> items;

    public Order() {}

    // Getters and Setters
    public int getOrderId() { return orderId; }
    public void setOrderId(int orderId) { this.orderId = orderId; }

    public String getOrderCode() { return orderCode; }
    public void setOrderCode(String orderCode) { this.orderCode = orderCode; }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public int getEventId() { return eventId; }
    public void setEventId(int eventId) { this.eventId = eventId; }

    public double getTotalAmount() { return totalAmount; }
    public void setTotalAmount(double totalAmount) { this.totalAmount = totalAmount; }

    public double getDiscountAmount() { return discountAmount; }
    public void setDiscountAmount(double discountAmount) { this.discountAmount = discountAmount; }

    public double getFinalAmount() { return finalAmount; }
    public void setFinalAmount(double finalAmount) { this.finalAmount = finalAmount; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getPaymentMethod() { return paymentMethod; }
    public void setPaymentMethod(String paymentMethod) { this.paymentMethod = paymentMethod; }

    public Date getPaymentDate() { return paymentDate; }
    public void setPaymentDate(Date paymentDate) { this.paymentDate = paymentDate; }

    public String getBuyerName() { return buyerName; }
    public void setBuyerName(String buyerName) { this.buyerName = buyerName; }

    public String getBuyerEmail() { return buyerEmail; }
    public void setBuyerEmail(String buyerEmail) { this.buyerEmail = buyerEmail; }

    public String getBuyerPhone() { return buyerPhone; }
    public void setBuyerPhone(String buyerPhone) { this.buyerPhone = buyerPhone; }

    public String getNotes() { return notes; }
    public void setNotes(String notes) { this.notes = notes; }

    public String getVoucherCode() { return voucherCode; }
    public void setVoucherCode(String voucherCode) { this.voucherCode = voucherCode; }

    public Date getCreatedAt() { return createdAt; }
    public void setCreatedAt(Date createdAt) { this.createdAt = createdAt; }

    public Integer getVoucherId() { return voucherId; }
    public void setVoucherId(Integer voucherId) { this.voucherId = voucherId; }

    public String getVoucherScope() { return voucherScope; }
    public void setVoucherScope(String voucherScope) { this.voucherScope = voucherScope; }

    public String getVoucherFundSource() { return voucherFundSource; }
    public void setVoucherFundSource(String voucherFundSource) { this.voucherFundSource = voucherFundSource; }

    public double getEventDiscountAmount() { return eventDiscountAmount; }
    public void setEventDiscountAmount(double eventDiscountAmount) { this.eventDiscountAmount = eventDiscountAmount; }

    public double getSystemDiscountAmount() { return systemDiscountAmount; }
    public void setSystemDiscountAmount(double systemDiscountAmount) { this.systemDiscountAmount = systemDiscountAmount; }

    public double getPlatformFeeAmount() { return platformFeeAmount; }
    public void setPlatformFeeAmount(double platformFeeAmount) { this.platformFeeAmount = platformFeeAmount; }

    public double getOrganizerGrossAmount() { return organizerGrossAmount; }
    public void setOrganizerGrossAmount(double organizerGrossAmount) { this.organizerGrossAmount = organizerGrossAmount; }

    public double getOrganizerPayoutAmount() { return organizerPayoutAmount; }
    public void setOrganizerPayoutAmount(double organizerPayoutAmount) { this.organizerPayoutAmount = organizerPayoutAmount; }

    public String getEventTitle() { return eventTitle; }
    public void setEventTitle(String eventTitle) { this.eventTitle = eventTitle; }

    public List<OrderItem> getItems() { return items; }
    public void setItems(List<OrderItem> items) { this.items = items; }

    @Override
    public String toString() {
        return "Order{id=" + orderId + ", code='" + orderCode + "', status='" + status + "', amount=" + finalAmount + "}";
    }
}
