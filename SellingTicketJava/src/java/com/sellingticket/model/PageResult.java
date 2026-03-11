package com.sellingticket.model;

import java.util.List;

/**
 * Generic wrapper for paginated query results.
 * Contains both the data items and pagination metadata.
 *
 * @param <T> the type of items in the result set
 */
public class PageResult<T> {

    private final List<T> items;
    private final int totalItems;
    private final int totalPages;
    private final int currentPage;
    private final int pageSize;

    public PageResult(List<T> items, int totalItems, int currentPage, int pageSize) {
        this.items = items;
        this.totalItems = totalItems;
        this.currentPage = currentPage;
        this.pageSize = pageSize;
        this.totalPages = pageSize > 0 ? (int) Math.ceil((double) totalItems / pageSize) : 0;
    }

    public List<T> getItems() { return items; }
    public int getTotalItems() { return totalItems; }
    public int getTotalPages() { return totalPages; }
    public int getCurrentPage() { return currentPage; }
    public int getPageSize() { return pageSize; }

    public boolean hasNext() { return currentPage < totalPages; }
    public boolean hasPrevious() { return currentPage > 1; }
}
