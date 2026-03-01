package com.sellingticket.service;

import com.sellingticket.dao.EventDAO;
import com.sellingticket.dao.TicketTypeDAO;
import com.sellingticket.dao.CategoryDAO;
import com.sellingticket.dao.EventStaffDAO;
import com.sellingticket.model.Event;
import com.sellingticket.model.TicketType;
import com.sellingticket.model.Category;
import com.sellingticket.model.EventStaff;
import java.util.List;

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

    /**
     * Get event with all related data (tickets, category info)
     */
    public Event getEventDetails(int eventId) {
        Event event = eventDAO.getEventById(eventId);
        if (event != null) {
            List<TicketType> tickets = ticketTypeDAO.getTicketTypesByEventId(eventId);
            event.setTicketTypes(tickets);
            eventDAO.incrementViews(eventId);
        }
        return event;
    }

    /**
     * Get featured events for homepage
     */
    public List<Event> getFeaturedEvents(int limit) {
        return eventDAO.getFeaturedEvents(limit);
    }

    /**
     * Get upcoming events
     */
    public List<Event> getUpcomingEvents(int limit) {
        return eventDAO.getUpcomingEvents(limit);
    }

    /**
     * Search events with filters
     */
    public List<Event> searchEvents(String keyword, String category, String dateFilter, int page, int pageSize) {
        return eventDAO.searchEvents(keyword, category, dateFilter, page, pageSize);
    }

    /**
     * Get events by organizer
     */
    public List<Event> getEventsByOrganizer(int organizerId) {
        return eventDAO.getEventsByOrganizer(organizerId);
    }

    /**
     * Get related events (same category, excluding current)
     */
    public List<Event> getRelatedEvents(int categoryId, int currentEventId, int limit) {
        return eventDAO.getRelatedEvents(categoryId, currentEventId, limit);
    }

    /**
     * Get all events with pagination (for admin)
     */
    public List<Event> getAllEvents(String status, int page, int pageSize) {
        return eventDAO.getAllEvents(status, page, pageSize);
    }

    /**
     * Get pending events for approval
     */
    public List<Event> getPendingEvents() {
        return eventDAO.getPendingEvents();
    }

    // ========================
    // WRITE OPERATIONS
    // ========================

    /**
     * Create event with associated ticket types
     */
    public boolean createEventWithTickets(Event event, List<TicketType> tickets) {
        boolean eventCreated = eventDAO.createEvent(event);
        if (eventCreated && tickets != null && !tickets.isEmpty()) {
            for (TicketType ticket : tickets) {
                ticket.setEventId(event.getEventId());
                ticketTypeDAO.createTicketType(ticket);
            }
        }
        return eventCreated;
    }

    /**
     * Update event
     */
    public boolean updateEvent(Event event) {
        return eventDAO.updateEvent(event);
    }

    /**
     * Delete event (soft delete)
     */
    public boolean deleteEvent(int eventId) {
        return eventDAO.deleteEvent(eventId);
    }

    // ========================
    // ADMIN OPERATIONS
    // ========================

    /**
     * Approve an event
     */
    public boolean approveEvent(int eventId) {
        return eventDAO.updateEventStatus(eventId, "approved");
    }

    /**
     * Reject an event
     */
    public boolean rejectEvent(int eventId) {
        return eventDAO.updateEventStatus(eventId, "rejected");
    }

    /**
     * Reject an event with rich-HTML reason
     */
    public boolean rejectEvent(int eventId, String reason) {
        if (reason != null && !reason.trim().isEmpty()) {
            return eventDAO.updateEventStatusWithReason(eventId, "rejected", reason);
        }
        return eventDAO.updateEventStatus(eventId, "rejected");
    }

    /**
     * Toggle featured status
     */
    public boolean setFeatured(int eventId, boolean featured) {
        Event event = eventDAO.getEventById(eventId);
        if (event != null) {
            event.setFeatured(featured);
            return eventDAO.updateEvent(event);
        }
        return false;
    }

    /** Pin event to homepage with given priority. */
    public boolean pinEvent(int eventId, int pinOrder) {
        return eventDAO.pinEvent(eventId, pinOrder);
    }

    /** Unpin event from homepage. */
    public boolean unpinEvent(int eventId) {
        return eventDAO.unpinEvent(eventId);
    }

    // ========================
    // STATISTICS
    // ========================

    /**
     * Get event counts by status
     */
    public int countEventsByStatus(String status) {
        return eventDAO.countEventsByStatus(status);
    }

    /**
     * Count total search results for pagination.
     */
    public int countSearchEvents(String keyword, String category, String dateFilter) {
        return eventDAO.countSearchEvents(keyword, category, dateFilter);
    }

    /**
     * Get total approved events
     */
    public int getTotalEvents() {
        return eventDAO.getTotalEvents();
    }

    /**
     * Get all categories
     */
    public List<Category> getAllCategories() {
        return categoryDAO.getAllCategories();
    }

    /**
     * Check if a user can create more events (limit: 3 pending events)
     */
    public boolean canUserCreateEvent(int userId) {
        return eventDAO.countPendingEventsByOrganizer(userId) < 3;
    }

    // ========================
    // PERMISSION ENGINE
    // ========================

    /**
     * Returns the user's effective role for an event.
     * Priority: owner > staff role > null
     * Admin users get "admin" role for any event.
     */
    public String getUserEventRole(int eventId, int userId, String userRole) {
        if ("admin".equals(userRole)) return "admin";

        Event event = eventDAO.getEventById(eventId);
        if (event == null) return null;
        if (event.getOrganizerId() == userId) return "owner";

        String staffRole = eventStaffDAO.getStaffRole(eventId, userId);
        return staffRole; // "manager", "editor", "checkin", or null
    }

    /** Owner + any staff + admin can view event details. */
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

    /** Owner + manager + editor + admin can edit event info and tickets. */
    public boolean hasEditPermission(int eventId, int userId, String userRole) {
        String role = getUserEventRole(eventId, userId, userRole);
        if (role == null) return false;
        return "admin".equals(role) || "owner".equals(role)
                || "manager".equals(role) || "editor".equals(role);
    }

    /** Owner + manager + checkin + admin can perform check-in. */
    public boolean hasCheckInPermission(int eventId, int userId, String userRole) {
        String role = getUserEventRole(eventId, userId, userRole);
        if (role == null) return false;
        return "admin".equals(role) || "owner".equals(role)
                || "manager".equals(role) || "checkin".equals(role);
    }

    /** Only owner + admin can delete events. */
    public boolean hasDeletePermission(int eventId, int userId, String userRole) {
        String role = getUserEventRole(eventId, userId, userRole);
        return "admin".equals(role) || "owner".equals(role);
    }

    /** Owner + manager + admin can manage vouchers and staff. */
    public boolean hasVoucherPermission(int eventId, int userId, String userRole) {
        String role = getUserEventRole(eventId, userId, userRole);
        if (role == null) return false;
        return "admin".equals(role) || "owner".equals(role) || "manager".equals(role);
    }

    /** Owner + manager + editor + admin can view statistics. */
    public boolean hasStatsPermission(int eventId, int userId, String userRole) {
        return hasEditPermission(eventId, userId, userRole);
    }

    /**
     * Checks if the user is associated with any approved events (as owner or staff).
     * Used to block operational features if the user doesn't have an approved roster.
     */
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

    /**
     * Returns all events a user can access:
     * - Admin: ALL events in the system
     * - Others: own events + events where assigned as staff
     */
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

        for (int staffEventId : staffEventIds) {
            if (!ownIds.contains(staffEventId)) {
                Event staffEvent = eventDAO.getEventById(staffEventId);
                if (staffEvent != null) ownEvents.add(staffEvent);
            }
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
