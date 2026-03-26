package com.sellingticket.service;

import com.sellingticket.dao.SupportTicketDAO;
import com.sellingticket.model.SupportTicket;
import com.sellingticket.model.TicketMessage;

import java.util.List;
import java.util.UUID;

public class SupportTicketService {

    private final SupportTicketDAO dao = new SupportTicketDAO();
    private final CustomerTierService tierService = new CustomerTierService();

    public String generateTicketCode() {
        return "TK-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase();
    }

    /**
     * Create ticket with auto-routing and VIP-based priority.
     */
    public int createTicket(SupportTicket ticket) {
        if (ticket.getTicketCode() == null) {
            ticket.setTicketCode(generateTicketCode());
        }

        // Auto-route: organizer for event issues, admin for system issues
        if (ticket.getRoutedTo() == null) {
            ticket.setRoutedTo(SupportTicket.computeRoutedTo(ticket.getCategory(), ticket.getEventId()));
        }

        // Auto-priority from customer VIP tier
        if (ticket.getPriority() == null || ticket.getPriority().isEmpty()) {
            CustomerTierService.TierInfo tier = tierService.getTier(ticket.getUserId());
            ticket.setPriority(CustomerTierService.tierToPriority(tier.tier));
        }

        return dao.createTicket(ticket);
    }

    public SupportTicket getById(int ticketId) {
        return dao.getById(ticketId);
    }

    public SupportTicket getByCode(String code) {
        return dao.getByCode(code);
    }

    public List<SupportTicket> getByUser(int userId) {
        return dao.getByUser(userId);
    }

    public List<SupportTicket> getByEvent(int eventId) {
        return dao.getByEvent(eventId);
    }

    /**
     * Get support tickets for events managed by a staff member.
     * Enables staff-level support routing instead of admin-only.
     */
    public List<SupportTicket> getTicketsForStaffEvents(List<Integer> eventIds) {
        return dao.getByEventIds(eventIds);
    }

    public List<SupportTicket> getAll(String status, String category, int page, int pageSize) {
        return dao.getAll(status, category, page, pageSize);
    }

    public List<TicketMessage> getMessages(int ticketId, boolean includeInternal) {
        return dao.getMessages(ticketId, includeInternal);
    }

    public boolean addReply(int ticketId, int senderId, String content, boolean isInternal) {
        TicketMessage msg = new TicketMessage();
        msg.setTicketId(ticketId);
        msg.setSenderId(senderId);
        msg.setContent(content);
        msg.setInternal(isInternal);
        return dao.addMessage(msg) > 0;
    }

    public boolean updateStatus(int ticketId, String status) {
        return dao.updateStatus(ticketId, status);
    }

    public boolean assignTicket(int ticketId, int assignedTo) {
        return dao.assignTicket(ticketId, assignedTo);
    }

    public boolean updatePriority(int ticketId, String priority) {
        return dao.updatePriority(ticketId, priority);
    }

    public int countByStatus(String status) {
        return dao.countByStatus(status);
    }

    public int countOpen() {
        return dao.countByStatus("open");
    }

    /** Status distribution for dashboard chart. */
    public java.util.List<java.util.Map<String, Object>> getStatusDistribution() {
        return dao.getStatusDistribution();
    }

    /** Agent workload for dashboard chart. */
    public java.util.List<java.util.Map<String, Object>> getAgentWorkload() {
        return dao.getAgentWorkload();
    }
}
