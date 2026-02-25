package com.sellingticket.controller.organizer;

import com.sellingticket.model.Event;
import com.sellingticket.model.User;
import com.sellingticket.service.EventService;
import com.sellingticket.service.OrderService;
import static com.sellingticket.util.ServletUtil.getSessionUser;

import java.io.IOException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(name = "OrganizerDashboardController", urlPatterns = {"/organizer", "/organizer/dashboard"})
public class OrganizerDashboardController extends HttpServlet {

    private final EventService eventService = new EventService();
    private final OrderService orderService = new OrderService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User user = getSessionUser(request);
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        List<Event> myEvents = eventService.getEventsByOrganizer(user.getUserId());

        int approvedEvents = 0;
        int pendingEvents = 0;
        int totalTicketsSold = 0;

        for (Event event : myEvents) {
            if ("approved".equals(event.getStatus())) approvedEvents++;
            if ("pending".equals(event.getStatus())) pendingEvents++;
            totalTicketsSold += event.getSoldTickets();
        }

        request.setAttribute("myEvents", myEvents);
        request.setAttribute("totalEvents", myEvents.size());
        request.setAttribute("approvedEvents", approvedEvents);
        request.setAttribute("pendingEvents", pendingEvents);
        request.setAttribute("totalTicketsSold", totalTicketsSold);

        request.getRequestDispatcher("/organizer/dashboard.jsp").forward(request, response);
    }
}
