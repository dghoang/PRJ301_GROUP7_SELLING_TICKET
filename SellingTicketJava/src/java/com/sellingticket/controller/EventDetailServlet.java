package com.sellingticket.controller;

import com.sellingticket.model.Event;
import com.sellingticket.model.TicketType;
import com.sellingticket.service.EventService;
import com.sellingticket.service.TicketService;
import static com.sellingticket.util.ServletUtil.parseIntOrDefault;

import java.io.IOException;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(name = "EventDetailServlet", urlPatterns = {"/event-detail"})
public class EventDetailServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(EventDetailServlet.class.getName());
    private final EventService eventService = new EventService();
    private final TicketService ticketService = new TicketService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int eventId = parseIntOrDefault(request.getParameter("id"), -1);
        if (eventId <= 0) {
            response.sendRedirect("events");
            return;
        }

        try {
            Event event = eventService.getEventDetails(eventId);

            if (event == null) {
                response.sendRedirect("events");
                return;
            }

            // Ticket types are already loaded by getEventDetails()
            List<TicketType> ticketTypes = event.getTicketTypes();
            List<Event> relatedEvents = eventService.getRelatedEvents(
                    event.getCategoryId(), eventId, 3);

            request.setAttribute("event", event);
            request.setAttribute("ticketTypes", ticketTypes);
            request.setAttribute("relatedEvents", relatedEvents);

            request.getRequestDispatcher("event-detail.jsp").forward(request, response);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error loading event detail for id=" + eventId, e);
            response.sendRedirect("events");
        }
    }
}
