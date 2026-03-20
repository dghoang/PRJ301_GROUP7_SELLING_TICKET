package com.sellingticket.dao;

import com.sellingticket.model.EventStaff;
import com.sellingticket.util.AppConstants;
import com.sellingticket.util.DBContext;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

public class EventStaffDAO extends DBContext {
    private static final Logger LOGGER = Logger.getLogger(EventStaffDAO.class.getName());

    public boolean hasPermission(int eventId, int userId) {
        String sql = "SELECT 1 FROM EventStaff WHERE event_id = ? AND user_id = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, eventId);
            ps.setInt(2, userId);
            ResultSet rs = ps.executeQuery();
            return rs.next();
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error checking event staff permission", e);
        }
        return false;
    }

    public List<EventStaff> getStaffByEvent(int eventId) {
        List<EventStaff> staffList = new ArrayList<>();
        String sql = "SELECT es.*, u.email, u.full_name FROM EventStaff es " +
                     "JOIN Users u ON es.user_id = u.user_id " +
                     "WHERE es.event_id = ? ORDER BY es.created_at DESC";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, eventId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                EventStaff es = new EventStaff();
                es.setStaffId(rs.getInt("staff_id"));
                es.setEventId(rs.getInt("event_id"));
                es.setUserId(rs.getInt("user_id"));
                es.setRole(AppConstants.normalizeEventStaffRole(rs.getString("role")));
                es.setGrantedBy(rs.getInt("granted_by"));
                es.setCreatedAt(rs.getTimestamp("created_at"));
                es.setUserEmail(rs.getString("email"));
                es.setFullName(rs.getString("full_name"));
                staffList.add(es);
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error getting event staff", e);
        }
        return staffList;
    }

    public boolean addStaffByEmail(int eventId, String email, String role, int grantedBy) {
        String normalizedRole = AppConstants.normalizeEventStaffRole(role);
        if (normalizedRole == null || email == null || email.trim().isEmpty()) {
            return false;
        }

        String sql = "INSERT INTO EventStaff (event_id, user_id, role, granted_by) " +
                     "SELECT ?, user_id, ?, ? FROM Users WHERE email = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, eventId);
            ps.setString(2, normalizedRole);
            ps.setInt(3, grantedBy);
            ps.setString(4, email.trim());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error adding event staff", e);
        }
        return false;
    }

    /** Returns the staff role for a user on an event, or null if not staff. */
    public String getStaffRole(int eventId, int userId) {
        String sql = "SELECT role FROM EventStaff WHERE event_id = ? AND user_id = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, eventId);
            ps.setInt(2, userId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return AppConstants.normalizeEventStaffRole(rs.getString("role"));
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error getting staff role", e);
        }
        return null;
    }

    /** Returns event IDs where user is assigned as staff. */
    public List<Integer> getEventsWhereStaff(int userId) {
        List<Integer> ids = new ArrayList<>();
        String sql = "SELECT event_id FROM EventStaff WHERE user_id = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) ids.add(rs.getInt("event_id"));
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error getting staff events", e);
        }
        return ids;
    }

    public boolean removeStaff(int eventId, int userId) {
        String sql = "DELETE FROM EventStaff WHERE event_id = ? AND user_id = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, eventId);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error removing event staff", e);
        }
        return false;
    }

    /**
     * Returns assigned events with full details for staff dashboard.
     * Each row: event_id, event_name, start_date, end_date, venue, status, role, tickets_sold, tickets_checked
     */
    public List<java.util.Map<String, Object>> getAssignedEventsWithDetails(int userId) {
        List<java.util.Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT e.event_id, e.title AS event_name, e.start_date, e.end_date, e.location AS venue, e.status, " +
                     "es.role AS staff_role, " +
                     "(SELECT COUNT(*) FROM OrderItems oi JOIN TicketTypes tt ON oi.ticket_type_id = tt.ticket_type_id WHERE tt.event_id = e.event_id) AS tickets_sold, " +
                     "(SELECT COUNT(*) FROM Tickets tk JOIN OrderItems oi2 ON tk.order_item_id = oi2.order_item_id JOIN TicketTypes tt2 ON oi2.ticket_type_id = tt2.ticket_type_id WHERE tt2.event_id = e.event_id AND tk.is_checked_in = 1) AS tickets_checked " +
                     "FROM EventStaff es JOIN Events e ON es.event_id = e.event_id " +
                     "WHERE es.user_id = ? ORDER BY e.start_date DESC";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                java.util.Map<String, Object> row = new java.util.LinkedHashMap<>();
                row.put("eventId", rs.getInt("event_id"));
                row.put("eventName", rs.getString("event_name"));
                row.put("startDate", rs.getTimestamp("start_date"));
                row.put("endDate", rs.getTimestamp("end_date"));
                row.put("venue", rs.getString("venue"));
                row.put("status", rs.getString("status"));
                row.put("staffRole", rs.getString("staff_role"));
                row.put("ticketsSold", rs.getInt("tickets_sold"));
                row.put("ticketsChecked", rs.getInt("tickets_checked"));
                list.add(row);
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error loading assigned events with details", e);
        }
        return list;
    }
}
