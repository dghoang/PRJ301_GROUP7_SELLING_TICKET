package com.sellingticket.model;

import java.util.Date;

public class Category {
    private int categoryId;
    private String name;
    private String slug;
    private String icon;
    private String description;
    private Date createdAt;
    
    // Computed field
    private int eventCount;

    public Category() {}

    // Getters and Setters
    public int getCategoryId() { return categoryId; }
    public void setCategoryId(int categoryId) { this.categoryId = categoryId; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getSlug() { return slug; }
    public void setSlug(String slug) { this.slug = slug; }

    public String getIcon() { return icon; }
    public void setIcon(String icon) { this.icon = icon; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public Date getCreatedAt() { return createdAt; }
    public void setCreatedAt(Date createdAt) { this.createdAt = createdAt; }

    public int getEventCount() { return eventCount; }
    public void setEventCount(int eventCount) { this.eventCount = eventCount; }

    @Override
    public String toString() {
        return "Category{id=" + categoryId + ", name='" + name + "', slug='" + slug + "', eventCount=" + eventCount + "}";
    }
}
