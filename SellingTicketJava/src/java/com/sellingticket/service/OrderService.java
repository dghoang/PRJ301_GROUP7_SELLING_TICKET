package com.sellingticket.service;

import com.sellingticket.dao.OrderDAO;
import com.sellingticket.dao.TicketTypeDAO;
import com.sellingticket.model.Order;
import com.sellingticket.model.OrderItem;
import java.util.List;

/**
 * OrderService - Business logic layer for Order operations
 * Handles order creation, payment processing, and ticket inventory management
 */
public class OrderService {

    private final OrderDAO orderDAO;
    private final TicketTypeDAO ticketTypeDAO;

    public OrderService() {
        this.orderDAO = new OrderDAO();
        this.ticketTypeDAO = new TicketTypeDAO();
    }

    // ========================
    // ORDER CREATION
    // ========================

    /**
     * Create a new order with validation and ticket reservation
     * @return order ID if successful, 0 if failed
     */
    public int createOrder(Order order) {
        // Validate ticket availability first
        for (OrderItem item : order.getItems()) {
            if (!ticketTypeDAO.checkAvailability(item.getTicketTypeId(), item.getQuantity())) {
                return 0; // Tickets not available
            }
        }
        
        // Create order
        int orderId = orderDAO.createOrder(order);
        
        if (orderId > 0) {
            // Update sold quantities
            for (OrderItem item : order.getItems()) {
                ticketTypeDAO.updateSoldQuantity(item.getTicketTypeId(), item.getQuantity());
            }
        }
        
        return orderId;
    }

    /**
     * Generate unique order code
     */
    public String generateOrderCode() {
        return "ORD-" + System.currentTimeMillis() + "-" + (int)(Math.random() * 1000);
    }

    // ========================
    // READ OPERATIONS
    // ========================

    /**
     * Get order by ID
     */
    public Order getOrderById(int orderId) {
        return orderDAO.getOrderById(orderId);
    }

    /**
     * Get order by code
     */
    public Order getOrderByCode(String orderCode) {
        return orderDAO.getOrderByCode(orderCode);
    }

    /**
     * Get orders for a user (profile page)
     */
    public List<Order> getOrdersByUser(int userId, int page, int pageSize) {
        return orderDAO.getOrdersByUser(userId, page, pageSize);
    }

    /**
     * Get orders for an event (organizer view)
     */
    public List<Order> getOrdersByEvent(int eventId, int page, int pageSize) {
        return orderDAO.getOrdersByEvent(eventId, page, pageSize);
    }

    /**
     * Get all orders (admin view)
     */
    public List<Order> getAllOrders(String status, int page, int pageSize) {
        return orderDAO.getAllOrders(status, page, pageSize);
    }

    // ========================
    // PAYMENT OPERATIONS
    // ========================

    /**
     * Process payment (simulated)
     * In production, this would integrate with a payment gateway
     * @return true if payment successful
     */
    public boolean processPayment(int orderId, String paymentMethod) {
        // Simulate payment processing
        // In real implementation: call VNPay, Momo, Stripe, etc.
        
        // For simulation, always succeed
        boolean paymentSuccess = true;
        
        if (paymentSuccess) {
            return orderDAO.updateOrderStatus(orderId, "paid");
        }
        return false;
    }

    /**
     * Mark order as paid (for admin/manual confirmation)
     */
    public boolean markAsPaid(int orderId) {
        return orderDAO.updateOrderStatus(orderId, "paid");
    }

    /**
     * Cancel order and restore tickets
     */
    public boolean cancelOrder(int orderId) {
        return orderDAO.cancelOrder(orderId);
    }

    /**
     * Request refund
     */
    public boolean requestRefund(int orderId) {
        return orderDAO.updateOrderStatus(orderId, "refund_requested");
    }

    /**
     * Approve refund
     */
    public boolean approveRefund(int orderId) {
        return orderDAO.updateOrderStatus(orderId, "refunded");
    }

    // ========================
    // STATISTICS
    // ========================

    /**
     * Get total revenue
     */
    public double getTotalRevenue() {
        return orderDAO.getTotalRevenue();
    }

    /**
     * Count orders by status
     */
    public int countOrdersByStatus(String status) {
        return orderDAO.countOrdersByStatus(status);
    }
}
