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
}
