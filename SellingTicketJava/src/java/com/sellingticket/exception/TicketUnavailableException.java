package com.sellingticket.exception;

/**
 * Thrown when a ticket type is sold out or unavailable for purchase.
 */
public class TicketUnavailableException extends RuntimeException {

    private final int ticketTypeId;

    public TicketUnavailableException(int ticketTypeId) {
        super("Ticket type " + ticketTypeId + " is unavailable");
        this.ticketTypeId = ticketTypeId;
    }

    public TicketUnavailableException(int ticketTypeId, String message) {
        super(message);
        this.ticketTypeId = ticketTypeId;
    }

    public int getTicketTypeId() {
        return ticketTypeId;
    }
}
