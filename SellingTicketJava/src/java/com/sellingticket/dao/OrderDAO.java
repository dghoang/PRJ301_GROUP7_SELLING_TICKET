package com.sellingticket.dao;

import com.sellingticket.model.Order;
import com.sellingticket.model.OrderItem;
import com.sellingticket.util.DBContext;
import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;
import java.util.stream.Collectors;

public class OrderDAO extends DBContext {

    private static final Logger LOGGER = Logger.getLogger(OrderDAO.class.getName());

    /**
     * Create order with atomic ticket reservation.
     * All operations (availability check + ticket update + order insert + items insert)
     * happen in a single transaction to prevent race conditions (overselling).
     *
     * @return order ID if successful, 0 if tickets unavailable or error
     */
    public int createOrderAtomic(Order order) {
        String reserveTicketSQL =
                "UPDATE TicketTypes SET sold_quantity = sold_quantity + ? " +
                "WHERE ticket_type_id = ? AND (quantity - sold_quantity) >= ? AND is_active = 1";
        String insertOrderSQL =
                "INSERT INTO Orders (order_code, user_id, event_id, total_amount, discount_amount, " +
                "final_amount, status, payment_method, buyer_name, buyer_email, buyer_phone, notes) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        String insertItemSQL =
                "INSERT INTO OrderItems (order_id, ticket_type_id, quantity, unit_price, subtotal) " +
                "VALUES (?, ?, ?, ?, ?)";

        Connection conn = null;
        try {
            conn = getConnection();
            conn.setAutoCommit(false);

            // Step 1: Atomically reserve tickets (DB-level check prevents overselling)
            try (PreparedStatement psReserve = conn.prepareStatement(reserveTicketSQL)) {
                for (OrderItem item : order.getItems()) {
                    psReserve.setInt(1, item.getQuantity());
                    psReserve.setInt(2, item.getTicketTypeId());
                    psReserve.setInt(3, item.getQuantity());
                    int updated = psReserve.executeUpdate();
                    if (updated == 0) {
                        // Ticket not available — rollback all reservations
                        conn.rollback();
                        LOGGER.log(Level.INFO, "Ticket unavailable: ticketTypeId={0}, qty={1}",
                                new Object[]{item.getTicketTypeId(), item.getQuantity()});
                        return 0;
                    }
                }
            }

            // Step 2: Insert order
            int orderId;
            try (PreparedStatement psOrder = conn.prepareStatement(insertOrderSQL, Statement.RETURN_GENERATED_KEYS)) {
                psOrder.setString(1, order.getOrderCode());
                psOrder.setInt(2, order.getUserId());
                psOrder.setInt(3, order.getEventId());
                psOrder.setDouble(4, order.getTotalAmount());
                psOrder.setDouble(5, order.getDiscountAmount());
                psOrder.setDouble(6, order.getFinalAmount());
                psOrder.setString(7, "pending");
                psOrder.setString(8, order.getPaymentMethod());
                psOrder.setString(9, order.getBuyerName());
                psOrder.setString(10, order.getBuyerEmail());
                psOrder.setString(11, order.getBuyerPhone());
                psOrder.setString(12, order.getNotes());
                psOrder.executeUpdate();

                ResultSet rs = psOrder.getGeneratedKeys();
                if (rs.next()) {
                    orderId = rs.getInt(1);
                } else {
                    conn.rollback();
                    return 0;
                }
            }

            // Step 3: Insert order items
            try (PreparedStatement psItem = conn.prepareStatement(insertItemSQL)) {
                for (OrderItem item : order.getItems()) {
                    psItem.setInt(1, orderId);
                    psItem.setInt(2, item.getTicketTypeId());
                    psItem.setInt(3, item.getQuantity());
                    psItem.setDouble(4, item.getUnitPrice());
                    psItem.setDouble(5, item.getSubtotal());
                    psItem.addBatch();
                }
                psItem.executeBatch();
            }

            conn.commit();
            LOGGER.log(Level.INFO, "Order created atomically: id={0}, code={1}",
                    new Object[]{orderId, order.getOrderCode()});
            return orderId;

        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to create order: " + order.getOrderCode(), e);
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) {
                    LOGGER.log(Level.SEVERE, "Rollback failed", ex);
                }
            }
        } finally {
            if (conn != null) {
                try { conn.close(); } catch (SQLException ignored) {}
            }
        }
        return 0;
    }

    /**
     * @deprecated Use {@link #createOrderAtomic(Order)} instead. This method has a race condition.
     */
    @Deprecated
    public int createOrder(Order order) {
        return createOrderAtomic(order);
    }

    public Order getOrderById(int orderId) {
        String sql = "SELECT o.*, e.title as event_title FROM Orders o " +
                     "JOIN Events e ON o.event_id = e.event_id WHERE o.order_id = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                Order order = mapResultSetToOrder(rs);
                order.setItems(getOrderItems(orderId));
                return order;
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to get order id=" + orderId, e);
        }
        return null;
    }

    private List<OrderItem> getOrderItems(int orderId) {
        List<OrderItem> items = new ArrayList<>();
        String sql = "SELECT oi.*, t.name as ticket_name FROM OrderItems oi " +
                     "JOIN TicketTypes t ON oi.ticket_type_id = t.ticket_type_id " +
                     "WHERE oi.order_id = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                OrderItem item = new OrderItem();
                item.setOrderItemId(rs.getInt("order_item_id"));
                item.setOrderId(rs.getInt("order_id"));
                item.setTicketTypeId(rs.getInt("ticket_type_id"));
                item.setQuantity(rs.getInt("quantity"));
                item.setUnitPrice(rs.getDouble("unit_price"));
                item.setSubtotal(rs.getDouble("subtotal"));
                item.setTicketTypeName(rs.getString("ticket_name"));
                items.add(item);
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to get order items for orderId=" + orderId, e);
        }
        return items;
    }

    /**
     * Batch-load order items for multiple orders in a single query.
     * Eliminates N+1 problem when loading order lists.
     */
    private void loadOrderItemsBatch(List<Order> orders) {
        if (orders.isEmpty()) return;

        String placeholders = orders.stream()
                .map(o -> "?")
                .collect(Collectors.joining(","));
        String sql = "SELECT oi.*, t.name as ticket_name FROM OrderItems oi " +
                     "JOIN TicketTypes t ON oi.ticket_type_id = t.ticket_type_id " +
                     "WHERE oi.order_id IN (" + placeholders + ")";

        Map<Integer, List<OrderItem>> itemsByOrderId = new HashMap<>();
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            for (int i = 0; i < orders.size(); i++) {
                ps.setInt(i + 1, orders.get(i).getOrderId());
            }
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                OrderItem item = new OrderItem();
                item.setOrderItemId(rs.getInt("order_item_id"));
                item.setOrderId(rs.getInt("order_id"));
                item.setTicketTypeId(rs.getInt("ticket_type_id"));
                item.setQuantity(rs.getInt("quantity"));
                item.setUnitPrice(rs.getDouble("unit_price"));
                item.setSubtotal(rs.getDouble("subtotal"));
                item.setTicketTypeName(rs.getString("ticket_name"));
                itemsByOrderId.computeIfAbsent(item.getOrderId(), k -> new ArrayList<>()).add(item);
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to batch-load order items", e);
        }

        for (Order order : orders) {
            order.setItems(itemsByOrderId.getOrDefault(order.getOrderId(), new ArrayList<>()));
        }
    }

    public Order getOrderByCode(String orderCode) {
        String sql = "SELECT o.*, e.title as event_title FROM Orders o " +
                     "JOIN Events e ON o.event_id = e.event_id WHERE o.order_code = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, orderCode);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                Order order = mapResultSetToOrder(rs);
                order.setItems(getOrderItems(order.getOrderId()));
                return order;
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to get order by code=" + orderCode, e);
        }
        return null;
    }

    private Order mapResultSetToOrder(ResultSet rs) throws SQLException {
        Order order = new Order();
        order.setOrderId(rs.getInt("order_id"));
        order.setOrderCode(rs.getString("order_code"));
        order.setUserId(rs.getInt("user_id"));
        order.setEventId(rs.getInt("event_id"));
        order.setTotalAmount(rs.getDouble("total_amount"));
        order.setDiscountAmount(rs.getDouble("discount_amount"));
        order.setFinalAmount(rs.getDouble("final_amount"));
        order.setStatus(rs.getString("status"));
        order.setPaymentMethod(rs.getString("payment_method"));
        order.setPaymentDate(rs.getTimestamp("payment_date"));
        order.setBuyerName(rs.getString("buyer_name"));
        order.setBuyerEmail(rs.getString("buyer_email"));
        order.setBuyerPhone(rs.getString("buyer_phone"));
        order.setNotes(rs.getString("notes"));
        order.setCreatedAt(rs.getTimestamp("created_at"));
        order.setEventTitle(rs.getString("event_title"));
        return order;
    }

    public boolean updateOrderStatus(int orderId, String status) {
        String sql = "UPDATE Orders SET status = ?, updated_at = GETDATE()";
        if ("paid".equals(status)) {
            sql += ", payment_date = GETDATE()";
        }
        sql += " WHERE order_id = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, orderId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to update order status: id=" + orderId + ", status=" + status, e);
        }
        return false;
    }

    /** Store bank transaction reference from payment gateway webhook. */
    public boolean updateTransactionId(int orderId, String transactionId) {
        String sql = "UPDATE Orders SET transaction_id = ?, updated_at = GETDATE() WHERE order_id = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, transactionId);
            ps.setInt(2, orderId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to update transaction_id: id=" + orderId, e);
        }
        return false;
    }

    /**
     * Cancel an order and atomically restore ticket quantities.
     */
    public boolean cancelOrder(int orderId) {
        Connection conn = null;
        try {
            conn = getConnection();
            conn.setAutoCommit(false);

            // Restore ticket quantities
            String restoreSql = "UPDATE TicketTypes SET sold_quantity = sold_quantity - oi.quantity " +
                               "FROM TicketTypes tt " +
                               "JOIN OrderItems oi ON tt.ticket_type_id = oi.ticket_type_id " +
                               "WHERE oi.order_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(restoreSql)) {
                ps.setInt(1, orderId);
                ps.executeUpdate();
            }

            // Update order status
            String updateSql = "UPDATE Orders SET status = 'cancelled', updated_at = GETDATE() WHERE order_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(updateSql)) {
                ps.setInt(1, orderId);
                ps.executeUpdate();
            }

            conn.commit();
            LOGGER.log(Level.INFO, "Order cancelled: id={0}", orderId);
            return true;
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to cancel order id=" + orderId, e);
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) {
                    LOGGER.log(Level.SEVERE, "Rollback failed", ex);
                }
            }
        } finally {
            if (conn != null) {
                try { conn.close(); } catch (SQLException ignored) {}
            }
        }
        return false;
    }

    public List<Order> getOrdersByUser(int userId, int page, int pageSize) {
        List<Order> orders = new ArrayList<>();
        String sql = "SELECT o.*, e.title as event_title FROM Orders o " +
                     "JOIN Events e ON o.event_id = e.event_id " +
                     "WHERE o.user_id = ? AND (o.is_deleted = 0 OR o.is_deleted IS NULL) ORDER BY o.created_at DESC " +
                     "OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, (page - 1) * pageSize);
            ps.setInt(3, pageSize);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                orders.add(mapResultSetToOrder(rs));
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to get orders for userId=" + userId, e);
        }
        // Batch-load items in a single query instead of N+1
        if (!orders.isEmpty()) {
            loadOrderItemsBatch(orders);
        }
        return orders;
    }

    public List<Order> getOrdersByEvent(int eventId, int page, int pageSize) {
        List<Order> orders = new ArrayList<>();
        String sql = "SELECT o.*, e.title as event_title FROM Orders o " +
                     "JOIN Events e ON o.event_id = e.event_id " +
                     "WHERE o.event_id = ? AND (o.is_deleted = 0 OR o.is_deleted IS NULL) ORDER BY o.created_at DESC " +
                     "OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, eventId);
            ps.setInt(2, (page - 1) * pageSize);
            ps.setInt(3, pageSize);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                orders.add(mapResultSetToOrder(rs));
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to get orders for eventId=" + eventId, e);
        }
        return orders;
    }

    public List<Order> getAllOrders(String status, int page, int pageSize) {
        List<Order> orders = new ArrayList<>();
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT o.*, e.title as event_title FROM Orders o ");
        sql.append("JOIN Events e ON o.event_id = e.event_id ");
        boolean hasStatus = status != null && !status.trim().isEmpty();
        if (hasStatus) {
            sql.append("WHERE o.status = ? ");
        }
        sql.append("ORDER BY o.created_at DESC ");
        sql.append("OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            int paramIndex = 1;
            if (hasStatus) {
                ps.setString(paramIndex++, status);
            }
            ps.setInt(paramIndex++, (page - 1) * pageSize);
            ps.setInt(paramIndex, pageSize);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                orders.add(mapResultSetToOrder(rs));
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to get all orders", e);
        }
        return orders;
    }

    public double getTotalRevenue() {
        String sql = "SELECT COALESCE(SUM(final_amount), 0) FROM Orders WHERE status = 'paid'";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getDouble(1);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to get total revenue", e);
        }
        return 0;
    }

    public int countOrdersByStatus(String status) {
        String sql = "SELECT COUNT(*) FROM Orders WHERE status = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to count orders by status=" + status, e);
        }
        return 0;
    }

    /** Count checked-in orders for a specific event. */
    public int countCheckedInByEvent(int eventId) {
        String sql = "SELECT COUNT(*) FROM Orders WHERE event_id = ? AND status = 'checked_in'";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, eventId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to count checked-in orders for event=" + eventId, e);
        }
        return 0;
    }
}
