package com.sellingticket.controller;

import com.sellingticket.model.Event;
import com.sellingticket.model.TicketType;
import com.sellingticket.service.EventService;
import com.sellingticket.service.TicketService;
import static com.sellingticket.util.ServletUtil.parseIntOrDefault;

import java.io.IOException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(name = "TicketSelectionServlet", urlPatterns = {"/tickets"})
public class TicketSelectionServlet extends HttpServlet {

    private EventService eventService;
    private TicketService ticketService;

    @Override
    public void init() throws ServletException {
        eventService = new EventService();
        ticketService = new TicketService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int eventId = parseIntOrDefault(request.getParameter("eventId"), -1);
        if (eventId <= 0) {
            response.sendRedirect("events");
            return;
        }

        Event event = eventService.getEventDetails(eventId);
        if (event == null) {
            response.sendRedirect("events");
            return;
        }

        // Block ticket selection for past events
        if (event.getEndDate() != null && event.getEndDate().before(new java.util.Date())) {
            request.setAttribute("error", "Sự kiện đã kết thúc, không thể mua vé.");
            request.setAttribute("event", event);
            request.setAttribute("ticketTypes", java.util.Collections.emptyList());
            request.getRequestDispatcher("ticket-selection.jsp").forward(request, response);
            return;
        }

        List<TicketType> ticketTypes = ticketService.getTicketsByEvent(eventId);

        // Check pre-order mode: mark tickets as pre-order if sale hasn't started
        java.util.Date now = new java.util.Date();
        boolean isPreOrder = false;
        for (TicketType tt : ticketTypes) {
            if (tt.getSaleStart() != null && tt.getSaleStart().after(now)) {
                if (event.isPreOrderEnabled()) {
                    isPreOrder = true;
                }
            }
        }
        request.setAttribute("isPreOrder", isPreOrder);
        request.setAttribute("preOrderEnabled", event.isPreOrderEnabled());
        request.setAttribute("maxTicketsPerOrder", event.getMaxTicketsPerOrder() > 0 ? event.getMaxTicketsPerOrder() : 10);

        request.setAttribute("event", event);
        request.setAttribute("ticketTypes", ticketTypes);
        request.getRequestDispatcher("ticket-selection.jsp").forward(request, response);
    }
}
