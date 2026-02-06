package com.sellingticket.controller;

import com.sellingticket.dao.EventDAO;
import com.sellingticket.dao.TicketTypeDAO;
import com.sellingticket.model.Event;
import com.sellingticket.model.TicketType;
import java.util.List;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(name = "EventDetailServlet", urlPatterns = {"/event"})
public class EventDetailServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String idStr = request.getParameter("id");
        if (idStr == null || idStr.isEmpty()) {
            response.sendRedirect("events");
            return;
        }
        
        try {
            int eventId = Integer.parseInt(idStr);
            
            EventDAO eventDAO = new EventDAO();
            TicketTypeDAO ticketTypeDAO = new TicketTypeDAO();
            
            Event event = eventDAO.getEventById(eventId);
            
            if (event == null) {
                response.sendRedirect("events");
                return;
            }
            
            // Increment views
            eventDAO.incrementViews(eventId);
            
            // Get ticket types
            List<TicketType> ticketTypes = ticketTypeDAO.getTicketTypesByEventId(eventId);
            
            request.setAttribute("event", event);
            request.setAttribute("ticketTypes", ticketTypes);
            request.getRequestDispatcher("event-detail.jsp").forward(request, response);
            
        } catch (NumberFormatException e) {
            response.sendRedirect("events");
        }
    }
}
