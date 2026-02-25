package com.sellingticket.controller;

import com.sellingticket.dao.EventDAO;
import com.sellingticket.dao.TicketTypeDAO;
import com.sellingticket.model.Event;
import com.sellingticket.model.TicketType;
import static com.sellingticket.util.ServletUtil.parseIntOrDefault;

import java.io.IOException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(name = "EventDetailServlet", urlPatterns = {"/event-detail"})
public class EventDetailServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int eventId = parseIntOrDefault(request.getParameter("id"), -1);
        if (eventId <= 0) {
            response.sendRedirect("events");
            return;
        }

        EventDAO eventDAO = new EventDAO();
        Event event = eventDAO.getEventById(eventId);

        if (event == null) {
            response.sendRedirect("events");
            return;
        }

        eventDAO.incrementViews(eventId);

        TicketTypeDAO ticketTypeDAO = new TicketTypeDAO();
        List<TicketType> ticketTypes = ticketTypeDAO.getTicketTypesByEventId(eventId);
        List<Event> relatedEvents = eventDAO.getRelatedEvents(event.getCategoryId(), eventId, 3);

        request.setAttribute("event", event);
        request.setAttribute("ticketTypes", ticketTypes);
        request.setAttribute("relatedEvents", relatedEvents);

        request.getRequestDispatcher("event-detail.jsp").forward(request, response);
    }
}
