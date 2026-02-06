package com.sellingticket.controller;

import com.sellingticket.dao.OrderDAO;
import com.sellingticket.model.Order;
import com.sellingticket.model.OrderItem;
import com.sellingticket.model.User;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(name = "CheckoutServlet", urlPatterns = {"/checkout"})
public class CheckoutServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // In a real app, retrieve cart/selected tickets from session here to display
        request.getRequestDispatcher("checkout.jsp").forward(request, response);
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("account");
        
        if (user == null) {
            response.sendRedirect("login?redirect=checkout");
            return;
        }
        
        try {
            // Retrieve parameters from form
            int eventId = Integer.parseInt(request.getParameter("eventId"));
            double totalAmount = Double.parseDouble(request.getParameter("totalAmount"));
            String paymentMethod = request.getParameter("paymentMethod");
            String buyerName = request.getParameter("buyerName"); // from shipping info or user
            if (buyerName == null || buyerName.isEmpty()) buyerName = user.getFullName();
            
            // Create Order Object
            Order order = new Order();
            order.setOrderCode("ORD-" + System.currentTimeMillis()); // Simple code generation
            order.setUserId(user.getUserId());
            order.setEventId(eventId);
            order.setTotalAmount(totalAmount);
            order.setFinalAmount(totalAmount); // Minus discount if any
            order.setPaymentMethod(paymentMethod);
            order.setBuyerName(buyerName);
            order.setBuyerEmail(user.getEmail());
            order.setBuyerPhone(user.getPhone());
            
            // Items (Assuming passing parallel arrays or single item for simplicity of this POC)
            // In a full implementation, you'd parse JSON or multiple inputs
            List<OrderItem> items = new ArrayList<>();
            // Example for POC: 1 item type passed
            String ticketTypeIdStr = request.getParameter("ticketTypeId");
            String quantityStr = request.getParameter("quantity");
            if (ticketTypeIdStr != null) {
                OrderItem item = new OrderItem();
                item.setTicketTypeId(Integer.parseInt(ticketTypeIdStr));
                item.setQuantity(Integer.parseInt(quantityStr));
                item.setUnitPrice(totalAmount / item.getQuantity()); // Simplified
                item.setSubtotal(totalAmount);
                items.add(item);
            }
            order.setItems(items);
            
            // Save to DB
            OrderDAO orderDAO = new OrderDAO();
            int orderId = orderDAO.createOrder(order);
            
            if (orderId > 0) {
                response.sendRedirect("order-confirmation?id=" + orderId);
            } else {
                request.setAttribute("error", "Failed to create order");
                request.getRequestDispatcher("checkout.jsp").forward(request, response);
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("events"); // Fallback
        }
    }
}
