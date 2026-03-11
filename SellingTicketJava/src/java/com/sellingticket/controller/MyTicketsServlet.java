package com.sellingticket.controller;

import com.sellingticket.dao.TicketDAO;
import com.sellingticket.model.Order;
import com.sellingticket.model.Ticket;
import com.sellingticket.model.User;
import com.sellingticket.service.OrderService;
import static com.sellingticket.util.ServletUtil.getSessionUser;
import static com.sellingticket.util.ServletUtil.redirectToLogin;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Logger;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * Displays the logged-in user's ticket/order history.
 * Loads individual tickets with QR codes for each order.
 */
@WebServlet(name = "MyTicketsServlet", urlPatterns = {"/my-tickets"})
public class MyTicketsServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(MyTicketsServlet.class.getName());
    private final OrderService orderService = new OrderService();
    private final TicketDAO ticketDAO = new TicketDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User user = getSessionUser(request);
        if (user == null) {
            redirectToLogin(request, response);
            return;
        }

        int page = parseIntOrDefault(request.getParameter("page"), 1);
        int pageSize = 10;
        String filter = request.getParameter("filter");

        List<Order> orders = orderService.getOrdersByUser(user.getUserId(), page, pageSize);

        // Load individual tickets for each order (with JWT QR codes)
        List<Ticket> allTickets = new ArrayList<>();
        for (Order order : orders) {
            List<Ticket> orderTickets = ticketDAO.getTicketsByOrder(order.getOrderId());
            allTickets.addAll(orderTickets);
        }

        request.setAttribute("orders", orders);
        request.setAttribute("allTickets", allTickets);
        request.setAttribute("currentPage", page);
        request.setAttribute("filter", filter != null ? filter : "all");
        request.getRequestDispatcher("my-tickets.jsp").forward(request, response);
    }

    private int parseIntOrDefault(String val, int defaultVal) {
        try { return Integer.parseInt(val); }
        catch (Exception e) { return defaultVal; }
    }
}
