package com.sellingticket.dao;

import com.sellingticket.model.PageResult;
import com.sellingticket.model.Ticket;
import com.sellingticket.util.DBContext;
import com.sellingticket.util.JwtUtil;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * TicketDAO — CRUD for individual issued tickets.
 * Handles ticket generation with JWT QR codes and check-in.
 */
public class TicketDAO extends DBContext {

    private static final Logger LOGGER = Logger.getLogger(TicketDAO.class.getName());

    /**
     * Generate individual tickets for a paid order.
     * For each OrderItem, creates N tickets (one per quantity unit),
     * each with a unique ticket_code and JWT-signed QR code.
     *
     * @return number of tickets created
     */
    public int createTicketsForOrder(int orderId, String buyerName, String buyerEmail) {
        String selectItems = "SELECT oi.order_item_id, oi.ticket_type_id, oi.quantity, "
                + "e.event_id, e.end_date "
                + "FROM OrderItems oi "
                + "JOIN TicketTypes tt ON oi.ticket_type_id = tt.ticket_type_id "
                + "JOIN Events e ON tt.event_id = e.event_id "
                + "WHERE oi.order_id = ?";

        String insertTicket = "INSERT INTO Tickets (ticket_code, order_item_id, attendee_name, attendee_email, qr_code) "
                + "VALUES (?, ?, ?, ?, ?)";

        int totalCreated = 0;

        try (Connection conn = getConnection();
             PreparedStatement psSelect = conn.prepareStatement(selectItems)) {

            psSelect.setInt(1, orderId);

            try (ResultSet rs = psSelect.executeQuery()) {
                try (PreparedStatement psInsert = conn.prepareStatement(insertTicket, Statement.RETURN_GENERATED_KEYS)) {
                    while (rs.next()) {
                        int orderItemId = rs.getInt("order_item_id");
                        int eventId = rs.getInt("event_id");
                        long expireTimeMillis = System.currentTimeMillis() + 31536000000L; // 1 year expiry
                        int quantity = rs.getInt("quantity");

                        for (int i = 0; i < quantity; i++) {
                            String ticketCode = generateTicketCode();

                            psInsert.setString(1, ticketCode);
                            psInsert.setInt(2, orderItemId);
                            psInsert.setString(3, buyerName);
                            psInsert.setString(4, buyerEmail);
                            // Temporary QR — will update after we get the ticketId
                            psInsert.setString(5, "");
                            psInsert.executeUpdate();

                            // Get generated ticketId and create JWT QR
                            try (ResultSet keys = psInsert.getGeneratedKeys()) {
                                if (keys.next()) {
                                    int ticketId = keys.getInt(1);
                                    String jwtToken = JwtUtil.generateTicketToken(ticketId, ticketCode, eventId, expireTimeMillis);
                                    updateQrCode(conn, ticketId, jwtToken);
                                    totalCreated++;
                                }
                            }
                        }
                    }
                }
            }

            LOGGER.log(Level.INFO, "Created {0} tickets for order {1}", new Object[]{totalCreated, orderId});
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to create tickets for order " + orderId, e);
        }

        return totalCreated;
    }

    private void updateQrCode(Connection conn, int ticketId, String qrCode) throws SQLException {
        try (PreparedStatement ps = conn.prepareStatement("UPDATE Tickets SET qr_code = ? WHERE ticket_id = ?")) {
            ps.setString(1, qrCode);
            ps.setInt(2, ticketId);
            ps.executeUpdate();
        }
    }

    /**
     * Find a ticket by its unique code.
     */
    public Ticket getTicketByCode(String ticketCode) {
        String sql = "SELECT t.*, tt.name as ticket_type_name, e.title as event_title, e.event_id, o.order_code, o.status as order_status "
                + "FROM Tickets t "
                + "JOIN OrderItems oi ON t.order_item_id = oi.order_item_id "
                + "JOIN TicketTypes tt ON oi.ticket_type_id = tt.ticket_type_id "
                + "JOIN Events e ON tt.event_id = e.event_id "
                + "JOIN Orders o ON oi.order_id = o.order_id "
                + "WHERE t.ticket_code = ?";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, ticketCode);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapTicket(rs);
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to find ticket by code: " + ticketCode, e);
        }
        return null;
    }

    /**
     * Find a ticket by its ID.
     */
    public Ticket getTicketById(int ticketId) {
        String sql = "SELECT t.*, tt.name as ticket_type_name, e.title as event_title, e.event_id, o.order_code, o.status as order_status "
                + "FROM Tickets t "
                + "JOIN OrderItems oi ON t.order_item_id = oi.order_item_id "
                + "JOIN TicketTypes tt ON oi.ticket_type_id = tt.ticket_type_id "
                + "JOIN Events e ON tt.event_id = e.event_id "
                + "JOIN Orders o ON oi.order_id = o.order_id "
                + "WHERE t.ticket_id = ?";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, ticketId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapTicket(rs);
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to find ticket by id: " + ticketId, e);
        }
        return null;
    }

    /**
     * Get all tickets for a given order.
     */
    public List<Ticket> getTicketsByOrder(int orderId) {
        String sql = "SELECT t.*, tt.name as ticket_type_name, e.title as event_title, e.event_id, o.order_code, o.status as order_status "
                + "FROM Tickets t "
                + "JOIN OrderItems oi ON t.order_item_id = oi.order_item_id "
                + "JOIN TicketTypes tt ON oi.ticket_type_id = tt.ticket_type_id "
                + "JOIN Events e ON tt.event_id = e.event_id "
                + "JOIN Orders o ON oi.order_id = o.order_id "
                + "WHERE o.order_id = ? "
                + "ORDER BY t.ticket_id";

        List<Ticket> tickets = new ArrayList<>();
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    tickets.add(mapTicket(rs));
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to get tickets for order " + orderId, e);
        }
        return tickets;
    }

    /**
     * Mark a ticket as checked in.
     */
    public boolean checkInTicket(int ticketId, int checkedInBy) {
        String markTicketSql = "UPDATE Tickets SET is_checked_in = 1, checked_in_at = GETDATE(), checked_in_by = ? "
                + "WHERE ticket_id = ? AND is_checked_in = 0";
        String markOrderCheckedInSql =
                "UPDATE o SET o.status = 'checked_in' "
                + "FROM Orders o "
                + "JOIN OrderItems oi ON oi.order_id = o.order_id "
                + "JOIN Tickets t ON t.order_item_id = oi.order_item_id "
                + "WHERE t.ticket_id = ? AND o.status = 'paid' "
                + "AND NOT EXISTS ("
                + "    SELECT 1 FROM OrderItems oi2 "
                + "    JOIN Tickets t2 ON t2.order_item_id = oi2.order_item_id "
                + "    WHERE oi2.order_id = o.order_id AND t2.is_checked_in = 0"
                + ")";

        try (Connection conn = getConnection()) {
            conn.setAutoCommit(false);
            try (PreparedStatement markTicketPs = conn.prepareStatement(markTicketSql);
                 PreparedStatement markOrderPs = conn.prepareStatement(markOrderCheckedInSql)) {
                markTicketPs.setInt(1, checkedInBy);
                markTicketPs.setInt(2, ticketId);
                int rows = markTicketPs.executeUpdate();
                if (rows <= 0) {
                    conn.rollback();
                    return false;
                }

                // Promote order status once all tickets in the order are checked in.
                markOrderPs.setInt(1, ticketId);
                markOrderPs.executeUpdate();

                conn.commit();
                return true;
            } catch (Exception e) {
                conn.rollback();
                throw e;
            } finally {
                conn.setAutoCommit(true);
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to check in ticket " + ticketId, e);
        }
        return false;
    }

    /**
     * Count checked-in tickets for an event.
     */
    public int countCheckedInByEvent(int eventId) {
        String sql = "SELECT COUNT(*) FROM Tickets t "
                + "JOIN OrderItems oi ON t.order_item_id = oi.order_item_id "
                + "JOIN TicketTypes tt ON oi.ticket_type_id = tt.ticket_type_id "
                + "WHERE tt.event_id = ? AND t.is_checked_in = 1";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, eventId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to count checked-in for event " + eventId, e);
        }
        return 0;
    }

    /**
     * Count total issued tickets for an event.
     */
    public int countIssuedByEvent(int eventId) {
        String sql = "SELECT COUNT(*) FROM Tickets t "
                + "JOIN OrderItems oi ON t.order_item_id = oi.order_item_id "
                + "JOIN TicketTypes tt ON oi.ticket_type_id = tt.ticket_type_id "
                + "WHERE tt.event_id = ?";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, eventId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to count issued tickets for event " + eventId, e);
        }
        return 0;
    }

    private String generateTicketCode() {
        String uuid = UUID.randomUUID().toString().replace("-", "").substring(0, 10).toUpperCase();
        return "TIX-" + uuid;
    }

    private Ticket mapTicket(ResultSet rs) throws SQLException {
        Ticket t = new Ticket();
        t.setTicketId(rs.getInt("ticket_id"));
        t.setTicketCode(rs.getString("ticket_code"));
        t.setOrderItemId(rs.getInt("order_item_id"));
        t.setAttendeeName(rs.getString("attendee_name"));
        t.setAttendeeEmail(rs.getString("attendee_email"));
        t.setQrCode(rs.getString("qr_code"));
        t.setCheckedIn(rs.getBoolean("is_checked_in"));
        t.setCheckedInAt(rs.getTimestamp("checked_in_at"));
        int checkedBy = rs.getInt("checked_in_by");
        t.setCheckedInBy(rs.wasNull() ? null : checkedBy);
        t.setCreatedAt(rs.getTimestamp("created_at"));

        // Joined fields
        t.setTicketTypeName(rs.getString("ticket_type_name"));
        t.setEventTitle(rs.getString("event_title"));
        t.setEventId(rs.getInt("event_id"));
        t.setOrderCode(rs.getString("order_code"));

        // order_status is only available in paged queries
        try {
            t.setOrderStatus(rs.getString("order_status"));
        } catch (SQLException ignored) {
            // Column not present in non-paged queries
        }
        try {
            t.setOrderId(rs.getInt("order_order_id"));
        } catch (SQLException ignored) {
            // Column not present in non-paged queries
        }
        // Event schedule & venue (only in paged queries)
        try {
            t.setEventStartDate(rs.getTimestamp("event_start"));
            t.setEventEndDate(rs.getTimestamp("event_end"));
            t.setVenue(rs.getString("venue"));
        } catch (SQLException ignored) {
        }

        return t;
    }

    // ========================
    // PAGED SEARCH
    // ========================

    /**
     * Get user's tickets with pagination, keyword search, and check-in filter.
     */
    public PageResult<Ticket> getTicketsByUserPaged(int userId, String keyword,
            Boolean isCheckedIn, int page, int pageSize) {

        String baseJoin = "FROM Tickets t "
                + "JOIN OrderItems oi ON t.order_item_id = oi.order_item_id "
                + "JOIN TicketTypes tt ON oi.ticket_type_id = tt.ticket_type_id "
                + "JOIN Events e ON tt.event_id = e.event_id "
                + "JOIN Orders o ON oi.order_id = o.order_id ";

        StringBuilder where = new StringBuilder("WHERE o.user_id = ? AND o.status NOT IN ('cancelled', 'refunded') AND (o.is_deleted = 0 OR o.is_deleted IS NULL) ");
        List<Object> params = new ArrayList<>();

        if (keyword != null && !keyword.trim().isEmpty()) {
            where.append("AND (e.title LIKE ? OR t.ticket_code LIKE ? OR tt.name LIKE ?) ");
            String kw = "%" + keyword.trim() + "%";
            params.add(kw); params.add(kw); params.add(kw);
        }
        if (isCheckedIn != null) {
            where.append("AND t.is_checked_in = ? ");
            params.add(isCheckedIn ? 1 : 0);
        }

        String countSql = "SELECT COUNT(*) " + baseJoin + where.toString();
        String dataSql = "SELECT t.*, tt.name as ticket_type_name, e.title as event_title, "
                + "e.event_id, e.event_start, e.event_end, e.venue, o.order_code, o.status as order_status, o.order_id as order_order_id "
                + baseJoin + where.toString()
                + "ORDER BY t.created_at DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";

        int totalItems = 0;
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(countSql)) {
            int idx = 1;
            ps.setInt(idx++, userId);
            for (Object p : params) {
                if (p instanceof String) ps.setString(idx++, (String) p);
                else if (p instanceof Integer) ps.setInt(idx++, (Integer) p);
            }
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) totalItems = rs.getInt(1);
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to count user tickets", e);
        }

        int safePage = Math.max(1, page);
        int safeSize = Math.max(1, Math.min(100, pageSize));
        List<Ticket> items = new ArrayList<>();
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(dataSql)) {
            int idx = 1;
            ps.setInt(idx++, userId);
            for (Object p : params) {
                if (p instanceof String) ps.setString(idx++, (String) p);
                else if (p instanceof Integer) ps.setInt(idx++, (Integer) p);
            }
            ps.setInt(idx++, (safePage - 1) * safeSize);
            ps.setInt(idx, safeSize);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    items.add(mapTicket(rs));
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to get user tickets paged", e);
        }

        return new PageResult<>(items, totalItems, safePage, safeSize);
    }
}
