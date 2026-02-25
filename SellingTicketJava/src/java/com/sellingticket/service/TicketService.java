package com.sellingticket.service;

import com.sellingticket.dao.TicketTypeDAO;
import com.sellingticket.model.TicketType;
import java.util.List;

/**
 * TicketService - Business logic layer for TicketType operations
 * Handles ticket inventory, availability, and pricing
 */
public class TicketService {

    private final TicketTypeDAO ticketTypeDAO;

    public TicketService() {
        this.ticketTypeDAO = new TicketTypeDAO();
    }

    // ========================
    // READ OPERATIONS
    // ========================

    /**
     * Get all ticket types for an event
     */
    public List<TicketType> getTicketsByEvent(int eventId) {
        return ticketTypeDAO.getTicketTypesByEventId(eventId);
    }

    /**
     * Get ticket type by ID
     */
    public TicketType getTicketTypeById(int ticketTypeId) {
        return ticketTypeDAO.getTicketTypeById(ticketTypeId);
    }

    /**
     * Get minimum price for an event
     */
    public double getMinPriceByEvent(int eventId) {
        return ticketTypeDAO.getMinPriceByEventId(eventId);
    }

    // ========================
    // AVAILABILITY
    // ========================

    /**
     * Check if tickets are available
     */
    public boolean checkAvailability(int ticketTypeId, int quantity) {
        return ticketTypeDAO.checkAvailability(ticketTypeId, quantity);
    }

    /**
     * Get available quantity for a ticket type
     */
    public int getAvailableQuantity(int ticketTypeId) {
        TicketType ticket = ticketTypeDAO.getTicketTypeById(ticketTypeId);
        if (ticket != null) {
            return ticket.getQuantity() - ticket.getSoldQuantity();
        }
        return 0;
    }

    // ========================
    // WRITE OPERATIONS
    // ========================

    /**
     * Create new ticket type
     */
    public boolean createTicketType(TicketType ticketType) {
        return ticketTypeDAO.createTicketType(ticketType);
    }

    /**
     * Update ticket type
     */
    public boolean updateTicketType(TicketType ticketType) {
        return ticketTypeDAO.updateTicketType(ticketType);
    }

    /**
     * Delete ticket type (soft delete)
     */
    public boolean deleteTicketType(int ticketTypeId) {
        return ticketTypeDAO.deleteTicketType(ticketTypeId);
    }

    /**
     * Update sold quantity after purchase
     */
    public boolean updateSoldQuantity(int ticketTypeId, int quantity) {
        return ticketTypeDAO.updateSoldQuantity(ticketTypeId, quantity);
    }

    // ========================
    // BULK OPERATIONS
    // ========================

    /**
     * Create multiple ticket types for an event
     */
    public boolean createTicketTypesForEvent(int eventId, List<TicketType> tickets) {
        boolean allSuccess = true;
        for (TicketType ticket : tickets) {
            ticket.setEventId(eventId);
            if (!ticketTypeDAO.createTicketType(ticket)) {
                allSuccess = false;
            }
        }
        return allSuccess;
    }
}
