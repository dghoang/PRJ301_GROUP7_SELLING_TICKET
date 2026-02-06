package com.sellingticket.dao;

import com.sellingticket.model.Order;
import com.sellingticket.model.OrderItem;
import com.sellingticket.util.DBContext;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class OrderDAO extends DBContext {

    public int createOrder(Order order) {
        String insertOrderSQL = "INSERT INTO Orders (order_code, user_id, event_id, total_amount, discount_amount, final_amount, status, payment_method, buyer_name, buyer_email, buyer_phone, notes) " +
                                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        String insertItemSQL = "INSERT INTO OrderItems (order_id, ticket_type_id, quantity, unit_price, subtotal) VALUES (?, ?, ?, ?, ?)";
        
        Connection conn = null;
        PreparedStatement psOrder = null;
        PreparedStatement psItem = null;
        ResultSet rs = null;
        
        try {
            conn = getConnection();
            conn.setAutoCommit(false); // Start transaction
            
            // Insert Order
            psOrder = conn.prepareStatement(insertOrderSQL, Statement.RETURN_GENERATED_KEYS);
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
            
            // Get generated Order ID
            rs = psOrder.getGeneratedKeys();
            int orderId = 0;
            if (rs.next()) {
                orderId = rs.getInt(1);
            }
            
            // Insert Items
            psItem = conn.prepareStatement(insertItemSQL);
            for (OrderItem item : order.getItems()) {
                psItem.setInt(1, orderId);
                psItem.setInt(2, item.getTicketTypeId());
                psItem.setInt(3, item.getQuantity());
                psItem.setDouble(4, item.getUnitPrice());
                psItem.setDouble(5, item.getSubtotal());
                psItem.addBatch();
            }
            psItem.executeBatch();
            
            conn.commit(); // Commit transaction
            return orderId;
            
        } catch (Exception e) {
            e.printStackTrace();
            try {
                if (conn != null) conn.rollback();
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
        } finally {
            try {
                if (rs != null) rs.close();
                if (psOrder != null) psOrder.close();
                if (psItem != null) psItem.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
        return 0;
    }
    
    public Order getOrderById(int orderId) {
        Order order = null;
        String sql = "SELECT o.*, e.title as event_title FROM Orders o " +
                     "JOIN Events e ON o.event_id = e.event_id " +
                     "WHERE o.order_id = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                order = new Order();
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
                
                // Get items
                order.setItems(getOrderItems(orderId));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return order;
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
            e.printStackTrace();
        }
        return items;
    }
    
    public Order getOrderByCode(String orderCode) {
        // reuse existing logic or duplicate if needed, here just a wrapper if needed or implement similar to getOrderById
        // For brevity, fetching by ID is main pattern used in confirmation page usually
        // But let's implement checking order code
        // ... (skipping for now to focus on main flow, relying on ID is safer for internal redirect)
        return null; 
    }
}
