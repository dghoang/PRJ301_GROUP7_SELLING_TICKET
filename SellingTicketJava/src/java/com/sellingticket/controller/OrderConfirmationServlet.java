package com.sellingticket.controller;

import com.sellingticket.dao.TicketDAO;
import com.sellingticket.model.Order;
import com.sellingticket.model.Ticket;
import com.sellingticket.model.User;
import com.sellingticket.service.OrderService;
import static com.sellingticket.util.ServletUtil.*;

import java.io.IOException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * Order Confirmation page — shows real order data + issued tickets with JWT QR codes.
 * Prevents IDOR by verifying the order belongs to the logged-in user.
 */
@WebServlet(name = "OrderConfirmationServlet", urlPatterns = {"/order-confirmation"})
public class OrderConfirmationServlet extends HttpServlet {

    private OrderService orderService;
    private TicketDAO ticketDAO;

    @Override
    public void init() throws ServletException {
        orderService = new OrderService();
        ticketDAO = new TicketDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User user = getSessionUser(request);

        int orderId = parseIntOrDefault(request.getParameter("id"), -1);
        if (orderId > 0 && user != null) {
            Order order = orderService.getOrderById(orderId);

            // Verify order belongs to logged-in user (prevent IDOR)
            if (order != null && order.getUserId() == user.getUserId()) {
                request.setAttribute("order", order);

                // Load issued tickets with JWT QR codes
                List<Ticket> tickets = ticketDAO.getTicketsByOrder(orderId);
                request.setAttribute("tickets", tickets);
            }
        }

        request.getRequestDispatcher("order-confirmation.jsp").forward(request, response);
    }
}
