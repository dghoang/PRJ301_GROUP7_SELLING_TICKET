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

@WebServlet(name = "TicketSelectionServlet", urlPatterns = {"/tickets"})
public class TicketSelectionServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int eventId = parseIntOrDefault(request.getParameter("eventId"), -1);
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

        List<TicketType> ticketTypes = new TicketTypeDAO().getTicketTypesByEventId(eventId);

        request.setAttribute("event", event);
        request.setAttribute("ticketTypes", ticketTypes);
        request.getRequestDispatcher("ticket-selection.jsp").forward(request, response);
    }
}
