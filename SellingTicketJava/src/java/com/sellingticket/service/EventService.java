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
        if (event == null) return null;
        if (event.getOrganizerId() == userId) return "owner";

        String staffRole = eventStaffDAO.getStaffRole(eventId, userId);
        return AppConstants.normalizeEventStaffRole(staffRole); // "manager", "staff", "scanner", or null
    }

    public boolean hasManagerPermission(int eventId, int userId) {
        return hasManagerPermission(eventId, userId, null);
    }

    public boolean hasManagerPermission(int eventId, int userId, String userRole) {
        if ("admin".equals(userRole)) return true;
        Event event = eventDAO.getEventById(eventId);
        if (event == null) return false;
        if (event.getOrganizerId() == userId) return true;
        return eventStaffDAO.hasPermission(eventId, userId);
    }

    public boolean hasEditPermission(int eventId, int userId, String userRole) {
        String role = getUserEventRole(eventId, userId, userRole);
        if (role == null) return false;
        return "admin".equals(role) || "owner".equals(role)
                || "manager".equals(role) || "staff".equals(role);
    }

    public boolean hasCheckInPermission(int eventId, int userId, String userRole) {
        String role = getUserEventRole(eventId, userId, userRole);
        if (role == null) return false;
        return "admin".equals(role) || "owner".equals(role)
                || "manager".equals(role) || "scanner".equals(role);
    }

    public boolean hasDeletePermission(int eventId, int userId, String userRole) {
        String role = getUserEventRole(eventId, userId, userRole);
        return "admin".equals(role) || "owner".equals(role);
    }

    public boolean hasVoucherPermission(int eventId, int userId, String userRole) {
        // Global/system vouchers (eventId <= 0) are reserved for system admins only.
        if (eventId <= 0) {
            return "admin".equals(userRole);
        }
        String role = getUserEventRole(eventId, userId, userRole);
        if (role == null) return false;
        return "admin".equals(role) || "owner".equals(role) || "manager".equals(role);
    }

    public boolean hasStatsPermission(int eventId, int userId, String userRole) {
        return hasEditPermission(eventId, userId, userRole);
    }

    public boolean hasApprovedEvents(int userId, String role) {
        if ("admin".equals(role)) return true;
        List<Event> accessibleEvents = getAccessibleEvents(userId, role);
        for (Event event : accessibleEvents) {
            if ("approved".equals(event.getStatus())) {
                return true;
            }
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
}
