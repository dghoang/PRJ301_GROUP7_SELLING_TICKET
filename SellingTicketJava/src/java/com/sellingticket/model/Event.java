package com.sellingticket.model;

import java.util.Date;
import java.util.List;

public class Event {
    private int eventId;
    private int organizerId;
    private int categoryId;
    private String title;
    private String slug;
    private String description;
    private String bannerImage;
    private String location;
    private String address;
    private Date startDate;
    private Date endDate;
    private String status;
    private boolean isFeatured;
    private boolean isPrivate;
    private int views;
    private Date createdAt;
    
    // Joined fields
    private String categoryName;
    private String organizerName;
    private double minPrice;
    private int totalTickets;
    private int soldTickets;
    private double revenue;
    
    // Rejection info
    private String rejectionReason;
    private Date rejectedAt;
    
    // Associated ticket types (for event detail view)
    private List<TicketType> ticketTypes;

    public Event() {}

    // Getters and Setters
    public int getEventId() { return eventId; }
    public void setEventId(int eventId) { this.eventId = eventId; }

    public int getOrganizerId() { return organizerId; }
    public void setOrganizerId(int organizerId) { this.organizerId = organizerId; }

    public int getCategoryId() { return categoryId; }
    public void setCategoryId(int categoryId) { this.categoryId = categoryId; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getSlug() { return slug; }
    public void setSlug(String slug) { this.slug = slug; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getBannerImage() { return bannerImage; }
    public void setBannerImage(String bannerImage) { this.bannerImage = bannerImage; }

    public String getLocation() { return location; }
    public void setLocation(String location) { this.location = location; }

    public String getAddress() { return address; }
    public void setAddress(String address) { this.address = address; }

    public Date getStartDate() { return startDate; }
    public void setStartDate(Date startDate) { this.startDate = startDate; }

    public Date getEndDate() { return endDate; }
    public void setEndDate(Date endDate) { this.endDate = endDate; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public boolean isFeatured() { return isFeatured; }
    public void setFeatured(boolean featured) { isFeatured = featured; }

    public boolean isPrivate() { return isPrivate; }
    public void setPrivate(boolean aPrivate) { isPrivate = aPrivate; }

    public int getViews() { return views; }
    public void setViews(int views) { this.views = views; }

    public Date getCreatedAt() { return createdAt; }
    public void setCreatedAt(Date createdAt) { this.createdAt = createdAt; }

    public String getCategoryName() { return categoryName; }
    public void setCategoryName(String categoryName) { this.categoryName = categoryName; }

    public String getOrganizerName() { return organizerName; }
    public void setOrganizerName(String organizerName) { this.organizerName = organizerName; }

    public double getMinPrice() { return minPrice; }
    public void setMinPrice(double minPrice) { this.minPrice = minPrice; }

    public int getTotalTickets() { return totalTickets; }
    public void setTotalTickets(int totalTickets) { this.totalTickets = totalTickets; }

    public int getSoldTickets() { return soldTickets; }
    public void setSoldTickets(int soldTickets) { this.soldTickets = soldTickets; }

    public double getRevenue() { return revenue; }
    public void setRevenue(double revenue) { this.revenue = revenue; }

    public String getRejectionReason() { return rejectionReason; }
    public void setRejectionReason(String rejectionReason) { this.rejectionReason = rejectionReason; }

    public Date getRejectedAt() { return rejectedAt; }
    public void setRejectedAt(Date rejectedAt) { this.rejectedAt = rejectedAt; }
    
    public List<TicketType> getTicketTypes() { return ticketTypes; }
    public void setTicketTypes(List<TicketType> ticketTypes) { this.ticketTypes = ticketTypes; }

    @Override
    public String toString() {
        return "Event{id=" + eventId + ", title='" + title + "', status='" + status + "', location='" + location + "'}";
    }
}
