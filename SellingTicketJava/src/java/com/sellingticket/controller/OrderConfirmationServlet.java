package com.sellingticket.controller;

import com.sellingticket.dao.OrderDAO;
import com.sellingticket.model.Order;
import static com.sellingticket.util.ServletUtil.parseIntOrDefault;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(name = "OrderConfirmationServlet", urlPatterns = {"/order-confirmation"})
public class OrderConfirmationServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int orderId = parseIntOrDefault(request.getParameter("id"), -1);
        if (orderId > 0) {
            Order order = new OrderDAO().getOrderById(orderId);
            request.setAttribute("order", order);
        }

        request.getRequestDispatcher("order-confirmation.jsp").forward(request, response);
    }
}
