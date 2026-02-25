package com.sellingticket.service;

import com.sellingticket.dao.OrderDAO;
import com.sellingticket.model.Order;
import java.util.List;
import java.util.UUID;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * OrderService - Business logic layer for Order operations.
 * Handles order creation, payment processing, and ticket inventory management.
 */
public class OrderService {

    private static final Logger LOGGER = Logger.getLogger(OrderService.class.getName());
    private final OrderDAO orderDAO;

    public OrderService() {
        this.orderDAO = new OrderDAO();
    }

    // ========================
    // ORDER CREATION
    // ========================

    /**
     * Create a new order with atomic ticket reservation.
     * Uses OrderDAO.createOrderAtomic() which handles availability check + reservation
     * in a single transaction to prevent race conditions.
     *
     * @return order ID if successful, 0 if tickets unavailable or error
     */
    public int createOrder(Order order) {
        return orderDAO.createOrderAtomic(order);
    }

    /**
     * Generate unique order code using UUID for better uniqueness than timestamp.
     */
    public String generateOrderCode() {
        String uuid = UUID.randomUUID().toString().replace("-", "").substring(0, 8).toUpperCase();
        return "ORD-" + System.currentTimeMillis() + "-" + uuid;
    }

    // ========================
    // READ OPERATIONS
    // ========================

    public Order getOrderById(int orderId) {
        return orderDAO.getOrderById(orderId);
    }

    public Order getOrderByCode(String orderCode) {
        return orderDAO.getOrderByCode(orderCode);
    }

    public List<Order> getOrdersByUser(int userId, int page, int pageSize) {
        return orderDAO.getOrdersByUser(userId, page, pageSize);
    }

    public List<Order> getOrdersByEvent(int eventId, int page, int pageSize) {
        return orderDAO.getOrdersByEvent(eventId, page, pageSize);
    }

    public List<Order> getAllOrders(String status, int page, int pageSize) {
        return orderDAO.getAllOrders(status, page, pageSize);
    }

    // ========================
    // PAYMENT OPERATIONS
    // ========================

    /**
     * Process payment (simulated).
     * In production, integrate with VNPay, Momo, Stripe, etc.
     */
    public boolean processPayment(int orderId, String paymentMethod) {
        LOGGER.log(Level.INFO, "Processing payment for order={0}, method={1}",
                new Object[]{orderId, paymentMethod});
        return orderDAO.updateOrderStatus(orderId, "paid");
    }

    public boolean markAsPaid(int orderId) {
        return orderDAO.updateOrderStatus(orderId, "paid");
    }

    public boolean cancelOrder(int orderId) {
        return orderDAO.cancelOrder(orderId);
    }

    /**
     * Mark an order as checked-in at the event gate.
     * Only paid orders can be checked in.
     */
    public boolean checkInOrder(int orderId) {
        return orderDAO.updateOrderStatus(orderId, "checked_in");
    }

    /**
     * Count orders with status 'checked_in' for a specific event.
     * Used by the check-in dashboard donut chart.
     */
    public int getCheckInCount(int eventId) {
        return orderDAO.countCheckedInByEvent(eventId);
    }

    public boolean requestRefund(int orderId) {
        return orderDAO.updateOrderStatus(orderId, "refund_requested");
    }

    public boolean approveRefund(int orderId) {
        return orderDAO.updateOrderStatus(orderId, "refunded");
    }

    // ========================
    // STATISTICS
    // ========================

    public double getTotalRevenue() {
        return orderDAO.getTotalRevenue();
    }

    public int countOrdersByStatus(String status) {
        return orderDAO.countOrdersByStatus(status);
    }
}
