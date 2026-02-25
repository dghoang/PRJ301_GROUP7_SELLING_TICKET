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

    /**
     * Check if a user has permission to manage an event (owner or manager/editor staff)
     */
    public boolean hasManagerPermission(int eventId, int userId) {
        Event event = eventDAO.getEventById(eventId);
        if (event == null) return false;
        
        // Owner always has permission
        if (event.getOrganizerId() == userId) return true;
        
        // Check staff table
        return eventStaffDAO.hasPermission(eventId, userId);
    }

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
