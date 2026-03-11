package com.sellingticket.dao;

import com.sellingticket.model.SupportTicket;
import com.sellingticket.model.TicketMessage;
import com.sellingticket.util.DBContext;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

public class SupportTicketDAO extends DBContext {

    private static final Logger LOGGER = Logger.getLogger(SupportTicketDAO.class.getName());

    // ========================
    // CREATE
    // ========================

    public int createTicket(SupportTicket ticket) {
        String sql = "INSERT INTO SupportTickets (ticket_code, user_id, order_id, event_id, category, subject, description, priority, routed_to) "
                   + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?); SELECT SCOPE_IDENTITY();";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, ticket.getTicketCode());
            ps.setInt(2, ticket.getUserId());
            if (ticket.getOrderId() != null) ps.setInt(3, ticket.getOrderId());
            else ps.setNull(3, Types.INTEGER);
            if (ticket.getEventId() != null) ps.setInt(4, ticket.getEventId());
            else ps.setNull(4, Types.INTEGER);
            ps.setString(5, ticket.getCategory());
            ps.setString(6, ticket.getSubject());
            ps.setString(7, ticket.getDescription());
            ps.setString(8, ticket.getPriority() != null ? ticket.getPriority() : "normal");
            ps.setString(9, ticket.getRoutedTo() != null ? ticket.getRoutedTo() : "admin");
            if (ps.execute()) {
                ResultSet rs = ps.getResultSet();
                if (rs.next()) return rs.getInt(1);
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to create support ticket", e);
        }
        return 0;
    }

    public int addMessage(TicketMessage msg) {
        String sql = "INSERT INTO TicketMessages (ticket_id, sender_id, content, is_internal) VALUES (?, ?, ?, ?);"
                   + "UPDATE SupportTickets SET updated_at = GETDATE() WHERE ticket_id = ?;";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, msg.getTicketId());
            ps.setInt(2, msg.getSenderId());
            ps.setString(3, msg.getContent());
            ps.setBoolean(4, msg.isInternal());
            ps.setInt(5, msg.getTicketId());
            ps.executeUpdate();
            return 1;
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to add ticket message", e);
        }
        return 0;
    }

    // ========================
    // READ
    // ========================

    public SupportTicket getById(int ticketId) {
        String sql = "SELECT t.*, u.full_name AS user_name, u.email AS user_email, "
                   + "o.order_code, e.title AS event_title, a.full_name AS assigned_to_name "
                   + "FROM SupportTickets t "
                   + "JOIN Users u ON t.user_id = u.user_id "
                   + "LEFT JOIN Orders o ON t.order_id = o.order_id "
                   + "LEFT JOIN Events e ON t.event_id = e.event_id "
                   + "LEFT JOIN Users a ON t.assigned_to = a.user_id "
                   + "WHERE t.ticket_id = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, ticketId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return mapTicket(rs);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to get ticket by ID", e);
        }
        return null;
    }

    public SupportTicket getByCode(String ticketCode) {
        String sql = "SELECT t.*, u.full_name AS user_name, u.email AS user_email, "
                   + "o.order_code, e.title AS event_title, a.full_name AS assigned_to_name "
                   + "FROM SupportTickets t "
                   + "JOIN Users u ON t.user_id = u.user_id "
                   + "LEFT JOIN Orders o ON t.order_id = o.order_id "
                   + "LEFT JOIN Events e ON t.event_id = e.event_id "
                   + "LEFT JOIN Users a ON t.assigned_to = a.user_id "
                   + "WHERE t.ticket_code = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, ticketCode);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return mapTicket(rs);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to get ticket by code", e);
        }
        return null;
    }

    public List<SupportTicket> getByUser(int userId) {
        String sql = "SELECT t.*, u.full_name AS user_name, u.email AS user_email, "
                   + "o.order_code, e.title AS event_title, a.full_name AS assigned_to_name "
                   + "FROM SupportTickets t "
                   + "JOIN Users u ON t.user_id = u.user_id "
                   + "LEFT JOIN Orders o ON t.order_id = o.order_id "
                   + "LEFT JOIN Events e ON t.event_id = e.event_id "
                   + "LEFT JOIN Users a ON t.assigned_to = a.user_id "
                   + "WHERE t.user_id = ? ORDER BY t.created_at DESC";
        return queryList(sql, userId);
    }

    public List<SupportTicket> getByEvent(int eventId) {
        String sql = "SELECT t.*, u.full_name AS user_name, u.email AS user_email, "
                   + "o.order_code, e.title AS event_title, a.full_name AS assigned_to_name "
                   + "FROM SupportTickets t "
                   + "JOIN Users u ON t.user_id = u.user_id "
                   + "LEFT JOIN Orders o ON t.order_id = o.order_id "
                   + "LEFT JOIN Events e ON t.event_id = e.event_id "
                   + "LEFT JOIN Users a ON t.assigned_to = a.user_id "
                   + "WHERE t.event_id = ? ORDER BY t.created_at DESC";
        return queryList(sql, eventId);
    }

    public List<SupportTicket> getAll(String status, String category, int page, int pageSize) {
        StringBuilder sql = new StringBuilder(
            "SELECT t.*, u.full_name AS user_name, u.email AS user_email, "
          + "o.order_code, e.title AS event_title, a.full_name AS assigned_to_name "
          + "FROM SupportTickets t "
          + "JOIN Users u ON t.user_id = u.user_id "
          + "LEFT JOIN Orders o ON t.order_id = o.order_id "
          + "LEFT JOIN Events e ON t.event_id = e.event_id "
          + "LEFT JOIN Users a ON t.assigned_to = a.user_id WHERE 1=1 ");
        List<Object> params = new ArrayList<>();
        if (status != null && !status.isEmpty()) {
            sql.append("AND t.status = ? ");
            params.add(status);
        }
        if (category != null && !category.isEmpty()) {
            sql.append("AND t.category = ? ");
            params.add(category);
        }
        sql.append("ORDER BY t.created_at DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");
        params.add((page - 1) * pageSize);
        params.add(pageSize);

        List<SupportTicket> list = new ArrayList<>();
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                Object p = params.get(i);
                if (p instanceof String) ps.setString(i + 1, (String) p);
                else ps.setInt(i + 1, (Integer) p);
            }
            ResultSet rs = ps.executeQuery();
            while (rs.next()) list.add(mapTicket(rs));
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to list support tickets", e);
        }
        return list;
    }

    public List<TicketMessage> getMessages(int ticketId, boolean includeInternal) {
        String sql = "SELECT m.*, u.full_name AS sender_name, u.role AS sender_role, u.avatar AS sender_avatar "
                   + "FROM TicketMessages m JOIN Users u ON m.sender_id = u.user_id "
                   + "WHERE m.ticket_id = ? " + (includeInternal ? "" : "AND m.is_internal = 0 ")
                   + "ORDER BY m.created_at ASC";
        List<TicketMessage> list = new ArrayList<>();
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, ticketId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) list.add(mapMessage(rs));
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to get ticket messages", e);
        }
        return list;
    }

    // ========================
    // UPDATE
    // ========================

    public boolean updateStatus(int ticketId, String status) {
        String extra = "resolved".equals(status) ? ", resolved_at = GETDATE()" : "";
        String sql = "UPDATE SupportTickets SET status = ?, updated_at = GETDATE()" + extra + " WHERE ticket_id = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, ticketId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to update ticket status", e);
        }
        return false;
    }

    public boolean assignTicket(int ticketId, int assignedTo) {
        String sql = "UPDATE SupportTickets SET assigned_to = ?, status = 'in_progress', updated_at = GETDATE() WHERE ticket_id = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, assignedTo);
            ps.setInt(2, ticketId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to assign ticket", e);
        }
        return false;
    }

    public boolean updatePriority(int ticketId, String priority) {
        String sql = "UPDATE SupportTickets SET priority = ?, updated_at = GETDATE() WHERE ticket_id = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, priority);
            ps.setInt(2, ticketId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to update ticket priority", e);
        }
        return false;
    }

    // ========================
    // STATS
    // ========================

    public int countByStatus(String status) {
        String sql = status != null
            ? "SELECT COUNT(*) FROM SupportTickets WHERE status = ?"
            : "SELECT COUNT(*) FROM SupportTickets";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            if (status != null) ps.setString(1, status);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to count tickets", e);
        }
        return 0;
    }

    // ========================
    // MAPPERS
    // ========================

    private SupportTicket mapTicket(ResultSet rs) throws SQLException {
        SupportTicket t = new SupportTicket();
        t.setTicketId(rs.getInt("ticket_id"));
        t.setTicketCode(rs.getString("ticket_code"));
        t.setUserId(rs.getInt("user_id"));
        int oid = rs.getInt("order_id");
        t.setOrderId(rs.wasNull() ? null : oid);
        int eid = rs.getInt("event_id");
        t.setEventId(rs.wasNull() ? null : eid);
        t.setCategory(rs.getString("category"));
        t.setSubject(rs.getString("subject"));
        t.setDescription(rs.getString("description"));
        t.setStatus(rs.getString("status"));
        t.setPriority(rs.getString("priority"));
        try { t.setRoutedTo(rs.getString("routed_to")); } catch (SQLException ignored) {}
        int aid = rs.getInt("assigned_to");
        t.setAssignedTo(rs.wasNull() ? null : aid);
        t.setResolvedAt(rs.getTimestamp("resolved_at"));
        t.setCreatedAt(rs.getTimestamp("created_at"));
        t.setUpdatedAt(rs.getTimestamp("updated_at"));
        // Joined
        t.setUserName(rs.getString("user_name"));
        t.setUserEmail(rs.getString("user_email"));
        try { t.setOrderCode(rs.getString("order_code")); } catch (SQLException ignored) {}
        try { t.setEventTitle(rs.getString("event_title")); } catch (SQLException ignored) {}
        try { t.setAssignedToName(rs.getString("assigned_to_name")); } catch (SQLException ignored) {}
        try { t.setCustomerTier(rs.getString("customer_tier")); } catch (SQLException ignored) {}
        return t;
    }

    private TicketMessage mapMessage(ResultSet rs) throws SQLException {
        TicketMessage m = new TicketMessage();
        m.setMessageId(rs.getInt("message_id"));
        m.setTicketId(rs.getInt("ticket_id"));
        m.setSenderId(rs.getInt("sender_id"));
        m.setContent(rs.getString("content"));
        m.setInternal(rs.getBoolean("is_internal"));
        m.setCreatedAt(rs.getTimestamp("created_at"));
        m.setSenderName(rs.getString("sender_name"));
        m.setSenderRole(rs.getString("sender_role"));
        try { m.setSenderAvatar(rs.getString("sender_avatar")); } catch (SQLException ignored) {}
        return m;
    }

    private List<SupportTicket> queryList(String sql, int paramId) {
        List<SupportTicket> list = new ArrayList<>();
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, paramId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) list.add(mapTicket(rs));
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to query tickets", e);
        }
        return list;
    }
}
