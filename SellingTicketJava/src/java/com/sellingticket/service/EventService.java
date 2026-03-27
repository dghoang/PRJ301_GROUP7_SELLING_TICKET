package com.sellingticket.service;

import com.sellingticket.dao.EventDAO;
import com.sellingticket.dao.TicketTypeDAO;
import com.sellingticket.dao.CategoryDAO;
import com.sellingticket.dao.EventStaffDAO;
import com.sellingticket.util.AppConstants;
import com.sellingticket.model.Event;
import com.sellingticket.model.TicketType;
import com.sellingticket.model.Category;
import com.sellingticket.model.EventStaff;
import com.sellingticket.model.PageResult;
import java.util.List;
import java.util.Map;

/**
 * EventService - Business logic layer for Event operations
 * Encapsulates complex operations and provides a clean interface for controllers
 */
public class EventService {

    private final EventDAO eventDAO;
    private final TicketTypeDAO ticketTypeDAO;
    private final CategoryDAO categoryDAO;
    private final EventStaffDAO eventStaffDAO;

    public EventService() {
        this.eventDAO = new EventDAO();
        this.ticketTypeDAO = new TicketTypeDAO();
        this.categoryDAO = new CategoryDAO();
        this.eventStaffDAO = new EventStaffDAO();
    }

    // ========================
    // READ OPERATIONS
    // ========================

    public Event getEventDetails(int eventId) {
        Event event = eventDAO.getEventById(eventId);
        if (event != null) {
            List<TicketType> tickets = ticketTypeDAO.getTicketTypesByEventId(eventId);
            event.setTicketTypes(tickets);
            // Compute aggregated ticket stats from ticket types
            int totalTickets = 0, soldTickets = 0;
            for (TicketType tt : tickets) {
                totalTickets += tt.getQuantity();
                soldTickets += tt.getSoldQuantity();
            }
            event.setTotalTickets(totalTickets);
            event.setSoldTickets(soldTickets);
            eventDAO.incrementViews(eventId);
        }
        return event;
    }

    public Event getEventBySlug(String slug) {
        Event event = eventDAO.getEventBySlug(slug);
        if (event != null) {
            List<TicketType> tickets = ticketTypeDAO.getTicketTypesByEventId(event.getEventId());
            event.setTicketTypes(tickets);
            eventDAO.incrementViews(event.getEventId());
        }
        return event;
    }

    public List<Event> getFeaturedEvents(int limit) {
        return eventDAO.getFeaturedEvents(limit);
    }

    public List<Event> getUpcomingEvents(int limit) {
        return eventDAO.getUpcomingEvents(limit);
    }

    public List<Event> searchEvents(String keyword, String category, String dateFilter, int page, int pageSize) {
        return eventDAO.searchEvents(keyword, category, dateFilter, page, pageSize);
    }

    public List<Event> getEventsByOrganizer(int organizerId) {
        return eventDAO.getEventsByOrganizer(organizerId);
    }

    public List<Event> getRelatedEvents(int categoryId, int currentEventId, int limit) {
        return eventDAO.getRelatedEvents(categoryId, currentEventId, limit);
    }

    public List<Event> getAllEvents(String status, int page, int pageSize) {
        return eventDAO.getAllEvents(status, page, pageSize);
    }

    public List<Event> getPendingEvents() {
        return eventDAO.getPendingEvents();
    }

    // ========================
    // WRITE OPERATIONS
    // ========================

    public boolean createEventWithTickets(Event event, List<TicketType> tickets) {
        return eventDAO.createEventWithTickets(event, tickets);
    }

    public boolean updateEvent(Event event) {
        return eventDAO.updateEvent(event);
    }

    public boolean deleteEvent(int eventId) {
        return eventDAO.deleteEvent(eventId);
    }

    public boolean updateEventSettings(int eventId, int maxTicketsPerOrder, int maxTotalTickets, boolean preOrderEnabled) {
        return eventDAO.updateEventSettings(eventId, maxTicketsPerOrder, maxTotalTickets, preOrderEnabled);
    }

    // ========================
    // ADMIN OPERATIONS
    // ========================

    public boolean approveEvent(int eventId) {
        return eventDAO.updateEventStatus(eventId, "approved");
    }

    /**
     * Submit a draft event for admin approval (draft → pending).
     */
    public boolean submitDraftForApproval(int eventId) {
        return eventDAO.updateEventStatus(eventId, "pending");
    }

    public boolean rejectEvent(int eventId) {
        return eventDAO.updateEventStatus(eventId, "rejected");
    }

    public boolean rejectEvent(int eventId, String reason) {
        if (reason != null && !reason.trim().isEmpty()) {
            return eventDAO.updateEventStatusWithReason(eventId, "rejected", reason);
        }
        return eventDAO.updateEventStatus(eventId, "rejected");
    }

    public boolean setFeatured(int eventId, boolean featured) {
        Event event = eventDAO.getEventById(eventId);
        if (event != null) {
            event.setFeatured(featured);
            return eventDAO.updateEvent(event);
        }
        return false;
    }

    public boolean pinEvent(int eventId, int pinOrder) {
        return eventDAO.pinEvent(eventId, pinOrder);
    }

    public boolean unpinEvent(int eventId) {
        return eventDAO.unpinEvent(eventId);
    }

    // ========================
    // STATISTICS
    // ========================

    public int countEventsByStatus(String status) {
        return eventDAO.countEventsByStatus(status);
    }

    public int countSearchEvents(String keyword, String category, String dateFilter) {
        return eventDAO.countSearchEvents(keyword, category, dateFilter);
    }

    public Map<String, Integer> getAdminEventStatusCounts(String keyword, String category) {
        return eventDAO.getAdminEventStatusCounts(keyword, category);
    }

    // ========================
    // PAGED SEARCH OPERATIONS
    // ========================

    public PageResult<Event> searchEventsPaged(String keyword, String category,
            String dateFrom, String dateTo, Double priceMin, Double priceMax,
            String sort, int page, int pageSize) {
        return eventDAO.searchEventsPaged(keyword, category, dateFrom, dateTo,
                priceMin, priceMax, sort, page, pageSize);
    }

    public PageResult<Event> getAllEventsPaged(String keyword, String[] statuses,
            String category, int page, int pageSize) {
        return eventDAO.getAllEventsPaged(keyword, statuses, category, page, pageSize);
    }

    public PageResult<Event> getEventsByOrganizerPaged(int organizerId, String keyword,
            String[] statuses, int page, int pageSize) {
        return eventDAO.getEventsByOrganizerPaged(organizerId, keyword, statuses, page, pageSize);
    }

    public int getTotalEvents() {
        return eventDAO.getTotalEvents();
    }

    public List<Category> getAllCategories() {
        return categoryDAO.getAllCategories();
    }

    public boolean canUserCreateEvent(int userId) {
        return eventDAO.countPendingEventsByOrganizer(userId) < 3;
    }

    // ========================
    // PERMISSION ENGINE
    // ========================

    public String getUserEventRole(int eventId, int userId, String userRole) {
        if ("admin".equals(userRole)) return "admin";
        Event event = eventDAO.getEventById(eventId);
        return getUserEventRole(event, userId, userRole);
    }

    public String getUserEventRole(Event event, int userId, String userRole) {
        if ("admin".equals(userRole)) return "admin";
        
        if (event == null) return null;
        if (event.getOrganizerId() == userId) return "owner";

        String staffRole = eventStaffDAO.getStaffRole(event.getEventId(), userId);
        return AppConstants.normalizeEventStaffRole(staffRole); // "manager", "staff", "scanner", or null
    }

    public boolean hasManagerPermission(int eventId, int userId) {
        return hasManagerPermission(eventId, userId, null);
    }

    public boolean hasManagerPermission(int eventId, int userId, String userRole) {
        String role = getUserEventRole(eventId, userId, userRole);
        if (role == null) return false;
        return "admin".equals(role) || "owner".equals(role) || "manager".equals(role);
    }

    public boolean hasManagerPermission(Event event, int userId, String userRole) {
        String role = getUserEventRole(event, userId, userRole);
        if (role == null) return false;
        return "admin".equals(role) || "owner".equals(role) || "manager".equals(role);
    }

    public boolean hasEditPermission(int eventId, int userId, String userRole) {
        String role = getUserEventRole(eventId, userId, userRole);
        if (role == null) return false;
        return "admin".equals(role) || "owner".equals(role)
                || "manager".equals(role) || "staff".equals(role);
    }

    public boolean hasEditPermission(Event event, int userId, String userRole) {
        String role = getUserEventRole(event, userId, userRole);
        if (role == null) return false;
        return "admin".equals(role) || "owner".equals(role)
                || "manager".equals(role) || "staff".equals(role);
    }

    public boolean hasCheckInPermission(int eventId, int userId, String userRole) {
        String role = getUserEventRole(eventId, userId, userRole);
        if (role == null) return false;
        return "admin".equals(role) || "owner".equals(role)
                || "manager".equals(role) || "staff".equals(role) || "scanner".equals(role);
    }

    public boolean hasCheckInPermission(Event event, int userId, String userRole) {
        String role = getUserEventRole(event, userId, userRole);
        if (role == null) return false;
        return "admin".equals(role) || "owner".equals(role)
                || "manager".equals(role) || "staff".equals(role) || "scanner".equals(role);
    }

    public boolean hasDeletePermission(int eventId, int userId, String userRole) {
        String role = getUserEventRole(eventId, userId, userRole);
        return "admin".equals(role) || "owner".equals(role);
    }

    public boolean hasDeletePermission(Event event, int userId, String userRole) {
        String role = getUserEventRole(event, userId, userRole);
        return "admin".equals(role) || "owner".equals(role);
    }

    public boolean hasVoucherPermission(int eventId, int userId, String userRole) {
        if (eventId <= 0) return "admin".equals(userRole);
        String role = getUserEventRole(eventId, userId, userRole);
        if (role == null) return false;
        return "admin".equals(role) || "owner".equals(role) || "manager".equals(role);
    }

    public boolean hasVoucherPermission(Event event, int userId, String userRole) {
        if (event == null || event.getEventId() <= 0) return "admin".equals(userRole);
        String role = getUserEventRole(event, userId, userRole);
        if (role == null) return false;
        return "admin".equals(role) || "owner".equals(role) || "manager".equals(role);
    }

    public boolean hasStatsPermission(int eventId, int userId, String userRole) {
        return hasEditPermission(eventId, userId, userRole);
    }

    public boolean hasStatsPermission(Event event, int userId, String userRole) {
        return hasEditPermission(event, userId, userRole);
    }

    public boolean hasApprovedEvents(int userId, String role) {
        if ("admin".equals(role)) return true;
        if (eventDAO.countApprovedEventsForUser(userId) > 0) return true;
        // Staff members have access if they are assigned to ANY approved event
        java.util.List<com.sellingticket.model.Event> accessible = getAccessibleEvents(userId, role);
        for (com.sellingticket.model.Event e : accessible) {
            String s = e.getStatus();
            if ("approved".equals(s) || "completed".equals(s) || "cancelled".equals(s)) return true;
        }
        return false;
    }

    public List<Event> getAccessibleEvents(int userId, String userRole) {
        if ("admin".equals(userRole)) {
            return eventDAO.getAllEventsWithStats();
        }

        List<Event> ownEvents = eventDAO.getEventsByOrganizer(userId);
        List<Integer> staffEventIds = eventStaffDAO.getEventsWhereStaff(userId);

        if (staffEventIds.isEmpty()) return ownEvents;

        // Merge: add staff events that aren't already in own list
        java.util.Set<Integer> ownIds = new java.util.HashSet<>();
        for (Event e : ownEvents) ownIds.add(e.getEventId());

        // Batch-fetch missing staff events (avoids N+1 queries)
        List<Integer> missingIds = new java.util.ArrayList<>();
        for (int staffEventId : staffEventIds) {
            if (!ownIds.contains(staffEventId)) missingIds.add(staffEventId);
        }
        if (!missingIds.isEmpty()) {
            List<Event> staffEvents = eventDAO.getEventsByIds(missingIds);
            ownEvents.addAll(staffEvents);
        }
        return ownEvents;
    }

    public PageResult<Event> getAccessibleEventsPaged(int userId, String userRole, int page, int pageSize) {
        List<Event> allEvents = getAccessibleEvents(userId, userRole);
        int totalItems = allEvents.size();
        int totalPages = (int) Math.ceil((double) totalItems / pageSize);
        if (totalPages == 0) totalPages = 1;
        
        int start = (page - 1) * pageSize;
        int end = Math.min(start + pageSize, totalItems);
        
        List<Event> pagedList = new java.util.ArrayList<>();
        if (start < totalItems) {
            pagedList = allEvents.subList(start, end);
        }
        
        return new PageResult<>(pagedList, totalItems, totalPages, page);
    }

    // ========================
    // EVENT STAFF MANAGEMENT
    // ========================

    public List<EventStaff> getEventStaff(int eventId) {
        return eventStaffDAO.getStaffByEvent(eventId);
    }

    public boolean addEventStaff(int eventId, String email, String role, int grantedBy) {
        return eventStaffDAO.addStaffByEmail(eventId, email, role, grantedBy);
    }

    public boolean removeEventStaff(int eventId, int userId) {
        return eventStaffDAO.removeStaff(eventId, userId);
    }

    // ========================
    // PERMISSION FILTERING
    // ========================

    /**
     * Filters accessible events down to only those where the user holds a specific permission.
     * Allowed permission types: "stats", "manager", "edit", "voucher", "checkin"
     */
    public List<Event> getEventsWithPermission(int userId, String userRole, String permissionType) {
        List<Event> all = getAccessibleEvents(userId, userRole);
        if ("admin".equals(userRole)) return all;

        List<Event> filtered = new java.util.ArrayList<>();
        for (Event e : all) {
            boolean hasAccess = false;
            switch(permissionType) {
                case "stats" -> hasAccess = hasStatsPermission(e, userId, userRole);
                case "manager" -> hasAccess = hasManagerPermission(e, userId, userRole);
                case "edit" -> hasAccess = hasEditPermission(e, userId, userRole);
                case "voucher" -> hasAccess = hasVoucherPermission(e, userId, userRole);
                case "checkin" -> hasAccess = hasCheckInPermission(e, userId, userRole);
                default -> hasAccess = false;
            }
            if (hasAccess) filtered.add(e);
        }
        return filtered;
    }
}
