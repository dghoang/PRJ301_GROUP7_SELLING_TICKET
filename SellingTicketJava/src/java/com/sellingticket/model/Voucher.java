package com.sellingticket.model;

import java.util.Date;

/**
 * Voucher model — discount codes for events.
 */
public class Voucher {
    private int voucherId;
    private int eventId; // <=0 means system/global scope
    private int organizerId;
    private String code;
    private String discountType; // "percentage" or "fixed"
    private double discountValue;
    private double minOrderAmount;
    private double maxDiscount;
    private int usageLimit;
    private int usedCount;
    private Date startDate;
    private Date endDate;
    private boolean isActive;
    private Date createdAt;

    // Scope/funding metadata
    private String voucherScope;      // EVENT | SYSTEM
    private String fundSource;        // ORGANIZER | SYSTEM

    // Joined fields (not stored directly)
    private String eventName;

    public Voucher() {}

    // Getters and Setters
    public int getVoucherId() { return voucherId; }
    public void setVoucherId(int voucherId) { this.voucherId = voucherId; }

    public int getEventId() { return eventId; }
    public void setEventId(int eventId) { this.eventId = eventId; }

    public int getOrganizerId() { return organizerId; }
    public void setOrganizerId(int organizerId) { this.organizerId = organizerId; }

    public String getCode() { return code; }
    public void setCode(String code) { this.code = code; }

    public String getDiscountType() { return discountType; }
    public void setDiscountType(String discountType) { this.discountType = discountType; }

    public double getDiscountValue() { return discountValue; }
    public void setDiscountValue(double discountValue) { this.discountValue = discountValue; }

    public double getMinOrderAmount() { return minOrderAmount; }
    public void setMinOrderAmount(double minOrderAmount) { this.minOrderAmount = minOrderAmount; }

    public double getMaxDiscount() { return maxDiscount; }
    public void setMaxDiscount(double maxDiscount) { this.maxDiscount = maxDiscount; }

    public int getUsageLimit() { return usageLimit; }
    public void setUsageLimit(int usageLimit) { this.usageLimit = usageLimit; }

    public int getUsedCount() { return usedCount; }
    public void setUsedCount(int usedCount) { this.usedCount = usedCount; }

    public Date getStartDate() { return startDate; }
    public void setStartDate(Date startDate) { this.startDate = startDate; }

    public Date getEndDate() { return endDate; }
    public void setEndDate(Date endDate) { this.endDate = endDate; }

    public boolean isActive() { return isActive; }
    public void setActive(boolean active) { isActive = active; }

    public Date getCreatedAt() { return createdAt; }
    public void setCreatedAt(Date createdAt) { this.createdAt = createdAt; }

    public String getVoucherScope() { return voucherScope; }
    public void setVoucherScope(String voucherScope) { this.voucherScope = voucherScope; }

    public String getFundSource() { return fundSource; }
    public void setFundSource(String fundSource) { this.fundSource = fundSource; }

    public String getEventName() { return eventName; }
    public void setEventName(String eventName) { this.eventName = eventName; }

    public boolean isExpired() {
        return endDate != null && endDate.before(new Date());
    }

    public boolean isUsable() {
        return isActive && !isExpired() && (usageLimit == 0 || usedCount < usageLimit);
    }
}
