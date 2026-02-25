package com.sellingticket.controller;

import com.sellingticket.model.Order;
import com.sellingticket.model.User;
import com.sellingticket.service.OrderService;
import static com.sellingticket.util.ServletUtil.*;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(name = "OrderConfirmationServlet", urlPatterns = {"/order-confirmation"})
public class OrderConfirmationServlet extends HttpServlet {

    private OrderService orderService;

    @Override
    public void init() throws ServletException {
        orderService = new OrderService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User user = getSessionUser(request);

        int orderId = parseIntOrDefault(request.getParameter("id"), -1);
        if (orderId > 0) {
            Order order = orderService.getOrderById(orderId);

            // Verify order belongs to logged-in user (prevent IDOR)
            if (order != null && user != null && order.getUserId() == user.getUserId()) {
                request.setAttribute("order", order);
            }
        }

        request.getRequestDispatcher("order-confirmation.jsp").forward(request, response);
    }
}
