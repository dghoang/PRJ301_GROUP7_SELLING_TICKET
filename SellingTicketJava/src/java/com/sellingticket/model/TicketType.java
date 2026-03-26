package com.sellingticket.model;

import java.util.Date;

public class TicketType {
    private int ticketTypeId;
    private int eventId;
    private String name;
    private String description;
    private double price;
    private int quantity;
    private int soldQuantity;
    private Date saleStart;
    private Date saleEnd;
    private boolean isActive;
    private Date createdAt;

    // Transient field — populated by controller, not persisted
    private String eventTitle;

    public TicketType() {}

    // Getters and Setters
    public int getTicketTypeId() { return ticketTypeId; }
    public void setTicketTypeId(int ticketTypeId) { this.ticketTypeId = ticketTypeId; }

    public int getEventId() { return eventId; }
    public void setEventId(int eventId) { this.eventId = eventId; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    /** JSP EL alias: ${tt.typeName} resolves to getName() */
    public String getTypeName() { return name; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public double getPrice() { return price; }
    public void setPrice(double price) { this.price = price; }

    public int getQuantity() { return quantity; }
    public void setQuantity(int quantity) { this.quantity = quantity; }

    public int getSoldQuantity() { return soldQuantity; }
    public void setSoldQuantity(int soldQuantity) { this.soldQuantity = soldQuantity; }

    /** JSP EL alias: ${tt.soldCount} resolves to getSoldQuantity() */
    public int getSoldCount() { return soldQuantity; }

    public Date getSaleStart() { return saleStart; }
    public void setSaleStart(Date saleStart) { this.saleStart = saleStart; }

    public Date getSaleEnd() { return saleEnd; }
    public void setSaleEnd(Date saleEnd) { this.saleEnd = saleEnd; }

    public boolean isActive() { return isActive; }
    public void setActive(boolean active) { isActive = active; }

    public Date getCreatedAt() { return createdAt; }
    public void setCreatedAt(Date createdAt) { this.createdAt = createdAt; }

    public String getEventTitle() { return eventTitle; }
    public void setEventTitle(String eventTitle) { this.eventTitle = eventTitle; }
    
    public int getAvailableQuantity() {
        return quantity - soldQuantity;
    }

    @Override
    public String toString() {
        return "TicketType{id=" + ticketTypeId + ", name='" + name + "', price=" + price + ", available=" + getAvailableQuantity() + "}";
    }
}
