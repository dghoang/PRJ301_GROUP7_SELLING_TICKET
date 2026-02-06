package com.sellingticket.controller;

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
        String idStr = request.getParameter("id");
        if (idStr != null && !idStr.isEmpty()) {
            try {
                int orderId = Integer.parseInt(idStr);
                com.sellingticket.dao.OrderDAO orderDAO = new com.sellingticket.dao.OrderDAO();
                com.sellingticket.model.Order order = orderDAO.getOrderById(orderId);
                request.setAttribute("order", order);
            } catch (NumberFormatException e) {
                // Ignore
            }
        }
        request.getRequestDispatcher("order-confirmation.jsp").forward(request, response);
    }
}
