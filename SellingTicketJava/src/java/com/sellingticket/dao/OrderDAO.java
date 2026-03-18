package com.sellingticket.dao;

import com.sellingticket.model.Order;
import com.sellingticket.model.OrderItem;
import com.sellingticket.model.PageResult;
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
                "UPDATE TicketTypes WITH (UPDLOCK, HOLDLOCK) SET sold_quantity = sold_quantity + ? " +
                "WHERE ticket_type_id = ? AND (quantity - sold_quantity) >= ? AND is_active = 1";
        String insertOrderSQL =
                "INSERT INTO Orders (order_code, user_id, event_id, total_amount, discount_amount, " +
                "final_amount, status, payment_method, buyer_name, buyer_email, buyer_phone, notes, " +
                "voucher_id, voucher_scope, voucher_fund_source, event_discount_amount, system_discount_amount, " +
                "platform_fee_amount, organizer_payout_amount) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
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

            // Step 1.5: Atomically increment voucher usage if applicable
            if (order.getVoucherCode() != null && !order.getVoucherCode().isEmpty()) {
                String updateVoucherSQL = "UPDATE Vouchers SET used_count = used_count + 1 " +
                                          "WHERE code = ? AND is_active = 1 AND (is_deleted = 0 OR is_deleted IS NULL) " +
                                          "AND (usage_limit = 0 OR used_count < usage_limit)";
                try (PreparedStatement psVoucher = conn.prepareStatement(updateVoucherSQL)) {
                    psVoucher.setString(1, order.getVoucherCode());
                    int updated = psVoucher.executeUpdate();
                    if (updated == 0) {
                        // Voucher unavailable, inactive, deleted, or limit reached
                        conn.rollback();
                        LOGGER.log(Level.INFO, "Voucher atomic update failed: {0}", order.getVoucherCode());
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
                // Settlement fields
                if (order.getVoucherId() != null) {
                    psOrder.setInt(13, order.getVoucherId());
                } else {
                    psOrder.setNull(13, Types.INTEGER);
                }
                psOrder.setString(14, order.getVoucherScope() != null ? order.getVoucherScope() : "NONE");
                psOrder.setString(15, order.getVoucherFundSource() != null ? order.getVoucherFundSource() : "NONE");
                psOrder.setDouble(16, order.getEventDiscountAmount());
                psOrder.setDouble(17, order.getSystemDiscountAmount());
                psOrder.setDouble(18, order.getPlatformFeeAmount());
                psOrder.setDouble(19, order.getOrganizerPayoutAmount());
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
     * Count total tickets a user has purchased for a specific event
     * (only from non-cancelled/non-refunded orders).
     */
    public int countUserTicketsForEvent(int userId, int eventId) {
        String sql = "SELECT COALESCE(SUM(oi.quantity), 0) as total " +
                     "FROM Orders o JOIN OrderItems oi ON o.order_id = oi.order_id " +
                     "WHERE o.user_id = ? AND o.event_id = ? " +
                     "AND o.status NOT IN ('cancelled', 'refunded') " +
                     "AND (o.is_deleted = 0 OR o.is_deleted IS NULL)";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, eventId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt("total");
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed countUserTicketsForEvent", e);
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
        // Settlement fields (graceful if columns don't exist yet)
        try {
            int vid = rs.getInt("voucher_id");
            order.setVoucherId(rs.wasNull() ? null : vid);
        } catch (SQLException ignored) {}
        try { order.setVoucherScope(rs.getString("voucher_scope")); } catch (SQLException ignored) {}
        try { order.setVoucherFundSource(rs.getString("voucher_fund_source")); } catch (SQLException ignored) {}
        try { order.setEventDiscountAmount(rs.getDouble("event_discount_amount")); } catch (SQLException ignored) {}
        try { order.setSystemDiscountAmount(rs.getDouble("system_discount_amount")); } catch (SQLException ignored) {}
        try { order.setPlatformFeeAmount(rs.getDouble("platform_fee_amount")); } catch (SQLException ignored) {}
        try { order.setOrganizerPayoutAmount(rs.getDouble("organizer_payout_amount")); } catch (SQLException ignored) {}
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

    /**
     * V10 FIX: Atomically confirm payment — only succeeds if order is still 'pending'.
     * Prevents duplicate payment processing and race conditions between concurrent webhooks.
     * Also stores the transaction reference in a single atomic UPDATE.
     *
     * @return true if this call actually updated the order, false if already processed
     */
    public boolean confirmPaymentAtomic(int orderId, String transactionId) {
        // V11 FIX: Removed reference to non-existent transaction_id column in Orders table.
        // Transaction tracking lives in PaymentTransactions table (separate from Orders).
        String sql = "UPDATE Orders SET status = 'paid', payment_date = GETDATE(), " +
                     "updated_at = GETDATE() " +
                     "WHERE order_id = ? AND status = 'pending'";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            int rows = ps.executeUpdate();
            if (rows > 0) {
                LOGGER.log(Level.INFO, "Payment confirmed atomically: orderId={0}, txRef={1}",
                        new Object[]{orderId, transactionId});
                return true;
            }
            LOGGER.log(Level.INFO, "Payment confirm skipped (not pending): orderId={0}", orderId);
            return false;
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to confirm payment: id=" + orderId, e);
        }
        return false;
    }

    /**
     * Store bank transaction reference from payment gateway webhook.
     * Records into PaymentTransactions table (Orders table has no transaction_id column).
     */
    public boolean updateTransactionId(int orderId, String transactionId) {
        String sql = "INSERT INTO PaymentTransactions (order_id, payment_method, seepay_transaction_id, " +
                     "amount, status, initiated_at, completed_at) " +
                     "SELECT order_id, payment_method, ?, final_amount, 'completed', GETDATE(), GETDATE() " +
                     "FROM Orders WHERE order_id = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, transactionId);
            ps.setInt(2, orderId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to record transaction: orderId=" + orderId, e);
        }
        return false;
    }

    /**
     * Cancel an order and atomically restore ticket quantities.
     * Only cancels orders in 'pending' or 'paid' status (not already cancelled/refunded/checked_in).
     */
    public boolean cancelOrder(int orderId) {
        Connection conn = null;
        try {
            conn = getConnection();
            conn.setAutoCommit(false);

            // Step 1: FIRST check + update status atomically.
            // This prevents a race condition where concurrent cancels could
            // restore ticket quantities multiple times.
            String updateSql = "UPDATE Orders SET status = 'cancelled', updated_at = GETDATE() " +
                              "WHERE order_id = ? AND status IN ('pending', 'paid', 'refund_requested')";
            int rows;
            try (PreparedStatement ps = conn.prepareStatement(updateSql)) {
                ps.setInt(1, orderId);
                rows = ps.executeUpdate();
            }

            if (rows == 0) {
                conn.rollback();
                LOGGER.log(Level.INFO, "Cancel skipped (invalid status): orderId={0}", orderId);
                return false;
            }

            // Step 2: THEN restore ticket quantities (safe: status was confirmed first)
            String restoreSql = "UPDATE TicketTypes SET sold_quantity = sold_quantity - oi.quantity " +
                               "FROM TicketTypes tt " +
                               "JOIN OrderItems oi ON tt.ticket_type_id = oi.ticket_type_id " +
                               "WHERE oi.order_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(restoreSql)) {
                ps.setInt(1, orderId);
                ps.executeUpdate();
            }

            conn.commit();
            LOGGER.log(Level.INFO, "Order cancelled: id={0}", orderId);
            return true;
        } catch (SQLException e) {
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

    // ========================
    // PAGED SEARCH METHODS
    // ========================

    /**
     * Admin: Search orders with pagination, keyword, status filter, date range.
     */
    public PageResult<Order> searchOrdersPaged(String keyword, String[] statuses,
            String dateFrom, String dateTo, int page, int pageSize) {

        StringBuilder where = new StringBuilder("WHERE (o.is_deleted = 0 OR o.is_deleted IS NULL) ");
        List<Object> params = new ArrayList<>();

        if (keyword != null && !keyword.trim().isEmpty()) {
            where.append("AND (o.order_code LIKE ? OR o.buyer_name LIKE ? OR o.buyer_email LIKE ?) ");
            String kw = "%" + keyword.trim() + "%";
            params.add(kw); params.add(kw); params.add(kw);
        }
        if (statuses != null && statuses.length > 0) {
            where.append("AND o.status IN (");
            for (int i = 0; i < statuses.length; i++) {
                where.append(i > 0 ? ",?" : "?");
                params.add(statuses[i]);
            }
            where.append(") ");
        }
        if (dateFrom != null && !dateFrom.trim().isEmpty()) {
            where.append("AND CAST(o.created_at AS DATE) >= ? ");
            params.add(dateFrom.trim());
        }
        if (dateTo != null && !dateTo.trim().isEmpty()) {
            where.append("AND CAST(o.created_at AS DATE) <= ? ");
            params.add(dateTo.trim());
        }

        String dataSql = "SELECT o.*, e.title as event_title FROM Orders o " +
                "JOIN Events e ON o.event_id = e.event_id " +
                where.toString() + "ORDER BY o.created_at DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";
        String countSql = "SELECT COUNT(*) FROM Orders o " + where.toString();

        // Execute count
        int totalItems = 0;
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(countSql)) {
            int idx = 1;
            for (Object p : params) ps.setString(idx++, (String) p);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) totalItems = rs.getInt(1);
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to count orders", e);
        }

        int safePage = Math.max(1, page);
        int safeSize = Math.max(1, Math.min(100, pageSize));
        List<Order> items = new ArrayList<>();
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(dataSql)) {
            int idx = 1;
            for (Object p : params) ps.setString(idx++, (String) p);
            ps.setInt(idx++, (safePage - 1) * safeSize);
            ps.setInt(idx, safeSize);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                items.add(mapResultSetToOrder(rs));
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to search orders paged", e);
        }

        if (!items.isEmpty()) loadOrderItemsBatch(items);
        return new PageResult<>(items, totalItems, safePage, safeSize);
    }

    /**
     * User: Get own orders with pagination and keyword search.
     */
    public PageResult<Order> getOrdersByUserPaged(int userId, String keyword,
            String[] statuses, int page, int pageSize) {

        StringBuilder where = new StringBuilder("WHERE o.user_id = ? AND (o.is_deleted = 0 OR o.is_deleted IS NULL) ");
        List<Object> params = new ArrayList<>();

        if (keyword != null && !keyword.trim().isEmpty()) {
            where.append("AND (o.order_code LIKE ? OR e.title LIKE ?) ");
            String kw = "%" + keyword.trim() + "%";
            params.add(kw); params.add(kw);
        }
        if (statuses != null && statuses.length > 0) {
            where.append("AND o.status IN (");
            for (int i = 0; i < statuses.length; i++) {
                where.append(i > 0 ? ",?" : "?");
                params.add(statuses[i]);
            }
            where.append(") ");
        }

        String dataSql = "SELECT o.*, e.title as event_title FROM Orders o " +
                "JOIN Events e ON o.event_id = e.event_id " +
                where.toString() + "ORDER BY o.created_at DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";
        String countSql = "SELECT COUNT(*) FROM Orders o " +
                "JOIN Events e ON o.event_id = e.event_id " + where.toString();

        int totalItems = 0;
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(countSql)) {
            int idx = 1;
            ps.setInt(idx++, userId);
            for (Object p : params) ps.setString(idx++, (String) p);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) totalItems = rs.getInt(1);
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to count user orders", e);
        }

        int safePage = Math.max(1, page);
        int safeSize = Math.max(1, Math.min(100, pageSize));
        List<Order> items = new ArrayList<>();
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(dataSql)) {
            int idx = 1;
            ps.setInt(idx++, userId);
            for (Object p : params) ps.setString(idx++, (String) p);
            ps.setInt(idx++, (safePage - 1) * safeSize);
            ps.setInt(idx, safeSize);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                items.add(mapResultSetToOrder(rs));
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to get user orders paged", e);
        }

        if (!items.isEmpty()) loadOrderItemsBatch(items);
        return new PageResult<>(items, totalItems, safePage, safeSize);
    }
}
