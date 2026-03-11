package com.sellingticket.dao;

import com.sellingticket.model.ChatMessage;
import com.sellingticket.model.ChatSession;
import com.sellingticket.util.DBContext;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

public class ChatDAO extends DBContext {

    private static final Logger LOGGER = Logger.getLogger(ChatDAO.class.getName());
    private static final int MAX_MESSAGES_PER_POLL = 50;
    private static final int COOLDOWN_MINUTES = 30;

    // ========================
    // SESSION
    // ========================

    public int createSession(int customerId, Integer eventId) {
        String sql = "INSERT INTO ChatSessions (customer_id, event_id) VALUES (?, ?); SELECT SCOPE_IDENTITY();";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            if (eventId != null) ps.setInt(2, eventId);
            else ps.setNull(2, Types.INTEGER);
            if (ps.execute()) {
                ResultSet rs = ps.getResultSet();
                if (rs.next()) return rs.getInt(1);
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to create chat session", e);
        }
        return 0;
    }

    public ChatSession getSession(int sessionId) {
        String sql = SESSION_SELECT + "WHERE s.session_id = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, sessionId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return mapSession(rs);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to get chat session", e);
        }
        return null;
    }

    public ChatSession findActiveSession(int customerId, Integer eventId) {
        String sql = "SELECT TOP 1 " + SESSION_COLS + " " + SESSION_FROM
                   + "WHERE s.customer_id = ? AND s.status IN ('waiting','active') "
                   + (eventId != null ? "AND s.event_id = ? " : "AND s.event_id IS NULL ")
                   + "ORDER BY s.created_at DESC";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            if (eventId != null) ps.setInt(2, eventId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return mapSession(rs);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to find active session", e);
        }
        return null;
    }

    /**
     * Get active sessions with customer VIP tier calculated from order stats.
     * Sorted by priority_score DESC (VIPs first), then created_at ASC (FIFO within tier).
     */
    public List<ChatSession> getActiveSessions(String type) {
        String eventFilter = "system".equals(type) ? "AND s.event_id IS NULL"
                           : "event".equals(type) ? "AND s.event_id IS NOT NULL" : "";
        String sql = "SELECT " + SESSION_COLS + ", "
                   + "ISNULL(os.total_spent, 0) AS total_spent, ISNULL(os.order_count, 0) AS order_count, "
                   + "CASE "
                   + "  WHEN ISNULL(os.total_spent, 0) >= 5000000 THEN 100 "
                   + "  WHEN ISNULL(os.order_count, 0) >= 5 OR ISNULL(os.total_spent, 0) >= 2000000 THEN 80 "
                   + "  WHEN ISNULL(os.order_count, 0) >= 1 THEN 50 "
                   + "  ELSE 20 END AS priority_score "
                   + SESSION_FROM
                   + "LEFT JOIN (SELECT user_id, SUM(total_amount) AS total_spent, COUNT(*) AS order_count "
                   + "  FROM Orders WHERE status = 'paid' GROUP BY user_id) os ON os.user_id = s.customer_id "
                   + "WHERE s.status IN ('waiting','active') " + eventFilter + " "
                   + "ORDER BY priority_score DESC, s.created_at ASC";
        List<ChatSession> list = new ArrayList<>();
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                ChatSession sess = mapSession(rs);
                sess.setPriorityScore(rs.getInt("priority_score"));
                sess.setCustomerTier(computeTierFromScore(rs.getInt("priority_score")));
                list.add(sess);
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to get active sessions", e);
        }
        return list;
    }

    public boolean acceptSession(int sessionId, int agentId) {
        String sql = "UPDATE ChatSessions SET agent_id = ?, status = 'active' WHERE session_id = ? AND status = 'waiting'";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, agentId);
            ps.setInt(2, sessionId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to accept session", e);
        }
        return false;
    }

    public boolean closeSession(int sessionId) {
        String sql = "UPDATE ChatSessions SET status = 'closed', closed_at = GETDATE() WHERE session_id = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, sessionId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to close session", e);
        }
        return false;
    }

    // ========================
    // ANTI-SPAM
    // ========================

    /** Count active or waiting sessions for a customer. Max 1 allowed. */
    public int countActiveSessionsByCustomer(int customerId) {
        String sql = "SELECT COUNT(*) FROM ChatSessions WHERE customer_id = ? AND status IN ('waiting','active')";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to count active sessions", e);
        }
        return 0;
    }

    /** Returns minutes remaining in cooldown, or 0 if no cooldown. */
    public int getCooldownMinutesRemaining(int customerId) {
        String sql = "SELECT TOP 1 DATEDIFF(MINUTE, closed_at, GETDATE()) AS mins_since "
                   + "FROM ChatSessions WHERE customer_id = ? AND status = 'closed' AND closed_at IS NOT NULL "
                   + "ORDER BY closed_at DESC";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                int minsSince = rs.getInt("mins_since");
                if (minsSince < COOLDOWN_MINUTES) return COOLDOWN_MINUTES - minsSince;
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to check cooldown", e);
        }
        return 0;
    }

    // ========================
    // MESSAGES — Cursor Pagination
    // ========================

    /** Send a message — allowed when session is waiting or active. */
    public boolean sendMessage(int sessionId, int senderId, String content) {
        String sql = "INSERT INTO ChatMessages (session_id, sender_id, content) "
                   + "SELECT ?, ?, ? WHERE EXISTS (SELECT 1 FROM ChatSessions WHERE session_id = ? AND status IN ('waiting','active'))";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, sessionId);
            ps.setInt(2, senderId);
            ps.setString(3, content.length() > 500 ? content.substring(0, 500) : content);
            ps.setInt(4, sessionId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to send chat message", e);
        }
        return false;
    }

    /** Poll new messages after a cursor ID. Capped at MAX_MESSAGES_PER_POLL. */
    public List<ChatMessage> getMessages(int sessionId, int afterMessageId) {
        String sql = "SELECT TOP " + MAX_MESSAGES_PER_POLL + " m.*, u.full_name AS sender_name, u.role AS sender_role "
                   + "FROM ChatMessages m JOIN Users u ON m.sender_id = u.user_id "
                   + "WHERE m.session_id = ? AND m.message_id > ? ORDER BY m.created_at ASC";
        return queryMessages(sql, sessionId, afterMessageId);
    }

    /** Load older messages BEFORE a cursor ID (for "load more" scrollback). */
    public List<ChatMessage> getHistory(int sessionId, int beforeMessageId, int limit) {
        int cap = Math.min(limit, MAX_MESSAGES_PER_POLL);
        String sql = "SELECT * FROM (SELECT TOP " + cap + " m.*, u.full_name AS sender_name, u.role AS sender_role "
                   + "FROM ChatMessages m JOIN Users u ON m.sender_id = u.user_id "
                   + "WHERE m.session_id = ? AND m.message_id < ? ORDER BY m.message_id DESC) sub ORDER BY sub.message_id ASC";
        return queryMessages(sql, sessionId, beforeMessageId);
    }

    /** Load last N messages for initial session open. */
    public List<ChatMessage> getRecentMessages(int sessionId, int limit) {
        int cap = Math.min(limit, MAX_MESSAGES_PER_POLL);
        String sql = "SELECT * FROM (SELECT TOP " + cap + " m.*, u.full_name AS sender_name, u.role AS sender_role "
                   + "FROM ChatMessages m JOIN Users u ON m.sender_id = u.user_id "
                   + "WHERE m.session_id = ? ORDER BY m.message_id DESC) sub ORDER BY sub.message_id ASC";
        List<ChatMessage> list = new ArrayList<>();
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, sessionId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) list.add(mapMessage(rs));
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to get recent messages", e);
        }
        return list;
    }

    // ========================
    // MAPPERS / HELPERS
    // ========================

    private static final String SESSION_COLS =
        "s.*, c.full_name AS customer_name, a.full_name AS agent_name, e.title AS event_title";
    private static final String SESSION_FROM =
        "FROM ChatSessions s JOIN Users c ON s.customer_id = c.user_id "
      + "LEFT JOIN Users a ON s.agent_id = a.user_id "
      + "LEFT JOIN Events e ON s.event_id = e.event_id ";
    private static final String SESSION_SELECT = "SELECT " + SESSION_COLS + " " + SESSION_FROM;

    private ChatSession mapSession(ResultSet rs) throws SQLException {
        ChatSession s = new ChatSession();
        s.setSessionId(rs.getInt("session_id"));
        s.setCustomerId(rs.getInt("customer_id"));
        int aid = rs.getInt("agent_id");
        s.setAgentId(rs.wasNull() ? null : aid);
        int eid = rs.getInt("event_id");
        s.setEventId(rs.wasNull() ? null : eid);
        s.setStatus(rs.getString("status"));
        s.setCreatedAt(rs.getTimestamp("created_at"));
        s.setClosedAt(rs.getTimestamp("closed_at"));
        s.setCustomerName(rs.getString("customer_name"));
        try { s.setAgentName(rs.getString("agent_name")); } catch (SQLException ignored) {}
        try { s.setEventTitle(rs.getString("event_title")); } catch (SQLException ignored) {}
        return s;
    }

    private ChatMessage mapMessage(ResultSet rs) throws SQLException {
        ChatMessage m = new ChatMessage();
        m.setMessageId(rs.getInt("message_id"));
        m.setSessionId(rs.getInt("session_id"));
        m.setSenderId(rs.getInt("sender_id"));
        m.setContent(rs.getString("content"));
        m.setCreatedAt(rs.getTimestamp("created_at"));
        m.setSenderName(rs.getString("sender_name"));
        m.setSenderRole(rs.getString("sender_role"));
        return m;
    }

    private List<ChatMessage> queryMessages(String sql, int sessionId, int cursorId) {
        List<ChatMessage> list = new ArrayList<>();
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, sessionId);
            ps.setInt(2, cursorId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) list.add(mapMessage(rs));
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to query messages", e);
        }
        return list;
    }

    private String computeTierFromScore(int score) {
        if (score >= 100) return "vip_special";
        if (score >= 80) return "vip";
        if (score >= 50) return "regular";
        return "registered";
    }
}
