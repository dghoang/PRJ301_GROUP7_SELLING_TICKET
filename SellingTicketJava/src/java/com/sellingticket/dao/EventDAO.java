package com.sellingticket.dao;

import com.sellingticket.model.Event;
import com.sellingticket.util.DBContext;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

public class EventDAO extends DBContext {

    private static final Logger LOGGER = Logger.getLogger(EventDAO.class.getName());

    private Event mapResultSetToEvent(ResultSet rs) throws SQLException {
        Event event = new Event();
        event.setEventId(rs.getInt("event_id"));
        event.setOrganizerId(rs.getInt("organizer_id"));
        event.setCategoryId(rs.getInt("category_id"));
        event.setTitle(rs.getString("title"));
        event.setSlug(rs.getString("slug"));
        event.setDescription(rs.getString("description"));
        event.setBannerImage(rs.getString("banner_image"));
        event.setLocation(rs.getString("location"));
        event.setAddress(rs.getString("address"));
        event.setStartDate(rs.getTimestamp("start_date"));
        event.setEndDate(rs.getTimestamp("end_date"));
        
        String dbStatus = rs.getString("status");
        if ("approved".equals(dbStatus) && event.getEndDate() != null && event.getEndDate().before(new java.util.Date())) {
            event.setStatus("ended");
        } else {
            event.setStatus(dbStatus);
        }
        event.setFeatured(rs.getBoolean("is_featured"));
        event.setPrivate(rs.getBoolean("is_private"));
        event.setViews(rs.getInt("views"));
        event.setCreatedAt(rs.getTimestamp("created_at"));
        try { event.setRejectionReason(rs.getString("rejection_reason")); } catch (SQLException ignored) {}
        try { event.setRejectedAt(rs.getTimestamp("rejected_at")); } catch (SQLException ignored) {}
        return event;
    }

    private void enrichWithJoinedFields(Event event, ResultSet rs) throws SQLException {
        event.setCategoryName(rs.getString("category_name"));
        event.setOrganizerName(rs.getString("organizer_name"));
        event.setMinPrice(rs.getDouble("min_price"));
    }

    private static final String BASE_SELECT_WITH_JOINS =
            "SELECT e.*, c.name as category_name, u.full_name as organizer_name, " +
            "ISNULL(tp.min_price, 0) as min_price " +
            "FROM Events e " +
            "JOIN Categories c ON e.category_id = c.category_id " +
            "JOIN Users u ON e.organizer_id = u.user_id " +
            "LEFT JOIN (SELECT event_id, MIN(price) as min_price FROM TicketTypes GROUP BY event_id) tp " +
            "ON tp.event_id = e.event_id ";

    public List<Event> getApprovedEvents(boolean featuredOnly, int limit) {
        List<Event> events = new ArrayList<>();
        String where = featuredOnly
                ? "WHERE e.status = 'approved' AND e.is_featured = 1 AND (e.end_date IS NULL OR e.end_date >= GETDATE()) AND (e.is_deleted = 0 OR e.is_deleted IS NULL) "
                : "WHERE e.status = 'approved' AND (e.end_date IS NULL OR e.end_date >= GETDATE()) AND (e.is_deleted = 0 OR e.is_deleted IS NULL) ";
        String sql = "SELECT TOP (?) " + BASE_SELECT_WITH_JOINS.substring("SELECT ".length()) + where +
                     "ORDER BY ISNULL(e.pin_order, 0) DESC, e.start_date ASC";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, limit);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Event event = mapResultSetToEvent(rs);
                enrichWithJoinedFields(event, rs);
                events.add(event);
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Database error in EventDAO", e);
        }
        return events;
    }

    public List<Event> getFeaturedEvents(int limit) {
        return getApprovedEvents(true, limit);
    }

    public List<Event> getUpcomingEvents(int limit) {
        return getApprovedEvents(false, limit);
    }

    public List<Event> searchEvents(String keyword, String category, String dateFilter, int page, int pageSize) {
        List<Event> events = new ArrayList<>();
        StringBuilder sql = new StringBuilder(BASE_SELECT_WITH_JOINS);
        sql.append("WHERE e.status = 'approved' AND (e.is_deleted = 0 OR e.is_deleted IS NULL) ");

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append("AND (e.title LIKE ? OR e.description LIKE ?) ");
        }
        if (category != null && !category.trim().isEmpty()) {
            sql.append("AND c.slug = ? ");
        }
        appendDateFilter(sql, dateFilter);

        sql.append("ORDER BY e.start_date ASC ");
        sql.append("OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            int idx = 1;
            if (keyword != null && !keyword.trim().isEmpty()) {
                ps.setString(idx++, "%" + keyword + "%");
                ps.setString(idx++, "%" + keyword + "%");
            }
            if (category != null && !category.trim().isEmpty()) {
                ps.setString(idx++, category);
            }
            ps.setInt(idx++, (page - 1) * pageSize);
            ps.setInt(idx, pageSize);

            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Event event = mapResultSetToEvent(rs);
                enrichWithJoinedFields(event, rs);
                events.add(event);
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Database error in EventDAO", e);
        }
        return events;
    }

    private void appendDateFilter(StringBuilder sql, String dateFilter) {
        if ("today".equals(dateFilter)) {
            sql.append("AND CAST(e.start_date AS DATE) = CAST(GETDATE() AS DATE) ");
        } else if ("week".equals(dateFilter)) {
            sql.append("AND e.start_date BETWEEN GETDATE() AND DATEADD(DAY, 7, GETDATE()) ");
        } else if ("month".equals(dateFilter)) {
            sql.append("AND e.start_date BETWEEN GETDATE() AND DATEADD(MONTH, 1, GETDATE()) ");
        }
    }

    public Event getEventById(int eventId) {
        String sql = BASE_SELECT_WITH_JOINS + "WHERE e.event_id = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, eventId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                Event event = mapResultSetToEvent(rs);
                enrichWithJoinedFields(event, rs);
                return event;
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Database error in EventDAO", e);
        }
        return null;
    }

    public Event getEventBySlug(String slug) {
        String sql = BASE_SELECT_WITH_JOINS + "WHERE e.slug = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, slug);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                Event event = mapResultSetToEvent(rs);
                enrichWithJoinedFields(event, rs);
                return event;
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Database error in getEventBySlug", e);
        }
        return null;
    }

    public List<Event> getEventsByOrganizer(int organizerId) {
        List<Event> events = new ArrayList<>();
        String sql = "SELECT e.*, c.name as category_name, " +
                     "ISNULL(ts.sold_tickets, 0) as sold_tickets, " +
                     "ISNULL(ts.total_tickets, 0) as total_tickets, " +
                     "ISNULL(rev.revenue, 0) as revenue " +
                     "FROM Events e " +
                     "JOIN Categories c ON e.category_id = c.category_id " +
                     "LEFT JOIN (SELECT event_id, SUM(sold_quantity) as sold_tickets, SUM(quantity) as total_tickets " +
                     "           FROM TicketTypes GROUP BY event_id) ts ON ts.event_id = e.event_id " +
                     "LEFT JOIN (SELECT tt.event_id, SUM(oi.quantity * oi.unit_price) as revenue " +
                     "           FROM OrderItems oi " +
                     "           JOIN TicketTypes tt ON oi.ticket_type_id = tt.ticket_type_id " +
                     "           JOIN Orders o ON oi.order_id = o.order_id " +
                     "           WHERE o.status = 'completed' " +
                     "           GROUP BY tt.event_id) rev ON rev.event_id = e.event_id " +
                     "WHERE e.organizer_id = ? ORDER BY e.created_at DESC";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, organizerId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Event event = mapResultSetToEvent(rs);
                event.setCategoryName(rs.getString("category_name"));
                event.setSoldTickets(rs.getInt("sold_tickets"));
                event.setTotalTickets(rs.getInt("total_tickets"));
                event.setRevenue(rs.getDouble("revenue"));
                events.add(event);
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Database error in EventDAO", e);
        }
        return events;
    }

    /** Admin view: all events with stats and organizer info. */
    public List<Event> getAllEventsWithStats() {
        List<Event> events = new ArrayList<>();
        String sql = "SELECT e.*, c.name as category_name, u.full_name as organizer_name, " +
                     "ISNULL(ts.sold_tickets, 0) as sold_tickets, " +
                     "ISNULL(ts.total_tickets, 0) as total_tickets, " +
                     "ISNULL(rev.revenue, 0) as revenue " +
                     "FROM Events e " +
                     "JOIN Categories c ON e.category_id = c.category_id " +
                     "JOIN Users u ON e.organizer_id = u.user_id " +
                     "LEFT JOIN (SELECT event_id, SUM(sold_quantity) as sold_tickets, SUM(quantity) as total_tickets " +
                     "           FROM TicketTypes GROUP BY event_id) ts ON ts.event_id = e.event_id " +
                     "LEFT JOIN (SELECT tt.event_id, SUM(oi.quantity * oi.unit_price) as revenue " +
                     "           FROM OrderItems oi " +
                     "           JOIN TicketTypes tt ON oi.ticket_type_id = tt.ticket_type_id " +
                     "           JOIN Orders o ON oi.order_id = o.order_id " +
                     "           WHERE o.status = 'completed' " +
                     "           GROUP BY tt.event_id) rev ON rev.event_id = e.event_id " +
                     "ORDER BY e.created_at DESC";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Event event = mapResultSetToEvent(rs);
                event.setCategoryName(rs.getString("category_name"));
                event.setOrganizerName(rs.getString("organizer_name"));
                event.setSoldTickets(rs.getInt("sold_tickets"));
                event.setTotalTickets(rs.getInt("total_tickets"));
                event.setRevenue(rs.getDouble("revenue"));
                events.add(event);
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Database error in EventDAO.getAllEventsWithStats", e);
        }
        return events;
    }

    public List<Event> getPendingEvents() {
        List<Event> events = new ArrayList<>();
        String sql = "SELECT e.*, c.name as category_name, u.full_name as organizer_name " +
                     "FROM Events e " +
                     "JOIN Categories c ON e.category_id = c.category_id " +
                     "JOIN Users u ON e.organizer_id = u.user_id " +
                     "WHERE e.status = 'pending' ORDER BY e.created_at DESC";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Event event = mapResultSetToEvent(rs);
                event.setCategoryName(rs.getString("category_name"));
                event.setOrganizerName(rs.getString("organizer_name"));
                events.add(event);
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Database error in EventDAO", e);
        }
        return events;
    }

    public boolean createEvent(Event event) {
        String sql = "INSERT INTO Events (organizer_id, category_id, title, slug, description, banner_image, " +
                     "location, address, start_date, end_date, status, is_featured, is_private) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, event.getOrganizerId());
            ps.setInt(2, event.getCategoryId());
            ps.setString(3, event.getTitle());
            ps.setString(4, event.getSlug());
            ps.setString(5, event.getDescription());
            ps.setString(6, event.getBannerImage());
            ps.setString(7, event.getLocation());
            ps.setString(8, event.getAddress());
            ps.setTimestamp(9, new Timestamp(event.getStartDate().getTime()));
            ps.setTimestamp(10, event.getEndDate() != null ? new Timestamp(event.getEndDate().getTime()) : null);
            ps.setString(11, event.getStatus());
            ps.setBoolean(12, event.isFeatured());
            ps.setBoolean(13, event.isPrivate());

            int rows = ps.executeUpdate();
            if (rows > 0) {
                ResultSet keys = ps.getGeneratedKeys();
                if (keys.next()) {
                    event.setEventId(keys.getInt(1));
                }
                return true;
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Database error in EventDAO", e);
        }
        return false;
    }

    public boolean updateEventStatus(int eventId, String status) {
        String sql = "UPDATE Events SET status = ?, updated_at = GETDATE() WHERE event_id = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, eventId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Database error in EventDAO", e);
        }
        return false;
    }

    /** Reject event with a rich-HTML reason. */
    public boolean updateEventStatusWithReason(int eventId, String status, String reason) {
        String sql = "UPDATE Events SET status = ?, rejection_reason = ?, rejected_at = GETDATE(), updated_at = GETDATE() WHERE event_id = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setString(2, reason);
            ps.setInt(3, eventId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Database error in EventDAO.updateEventStatusWithReason", e);
        }
        return false;
    }

    public void incrementViews(int eventId) {
        String sql = "UPDATE Events SET views = views + 1 WHERE event_id = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, eventId);
            ps.executeUpdate();
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Database error in EventDAO", e);
        }
    }

    public int getTotalEvents() {
        String sql = "SELECT COUNT(*) FROM Events WHERE status = 'approved'";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getInt(1);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Database error in EventDAO", e);
        }
        return 0;
    }

    public List<Event> getRelatedEvents(int categoryId, int currentEventId, int limit) {
        List<Event> events = new ArrayList<>();
        String sql = "SELECT TOP (?) " + BASE_SELECT_WITH_JOINS.substring("SELECT ".length()) +
                     "WHERE e.status = 'approved' AND e.category_id = ? AND e.event_id != ? AND (e.end_date IS NULL OR e.end_date >= GETDATE()) " +
                     "ORDER BY e.start_date ASC";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, limit);
            ps.setInt(2, categoryId);
            ps.setInt(3, currentEventId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Event event = mapResultSetToEvent(rs);
                enrichWithJoinedFields(event, rs);
                events.add(event);
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Database error in EventDAO", e);
        }
        return events;
    }

    public boolean updateEvent(Event event) {
        String sql = "UPDATE Events SET " +
                     "category_id = ?, title = ?, slug = ?, description = ?, banner_image = ?, " +
                     "location = ?, address = ?, start_date = ?, end_date = ?, " +
                     "is_featured = ?, is_private = ?, updated_at = GETDATE() " +
                     "WHERE event_id = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, event.getCategoryId());
            ps.setString(2, event.getTitle());
            ps.setString(3, event.getSlug());
            ps.setString(4, event.getDescription());
            ps.setString(5, event.getBannerImage());
            ps.setString(6, event.getLocation());
            ps.setString(7, event.getAddress());
            ps.setTimestamp(8, new Timestamp(event.getStartDate().getTime()));
            ps.setTimestamp(9, event.getEndDate() != null ? new Timestamp(event.getEndDate().getTime()) : null);
            ps.setBoolean(10, event.isFeatured());
            ps.setBoolean(11, event.isPrivate());
            ps.setInt(12, event.getEventId());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Database error in EventDAO", e);
        }
        return false;
    }

    public boolean deleteEvent(int eventId) {
        String sql = "UPDATE Events SET is_deleted = 1, status = 'cancelled', updated_at = GETDATE() WHERE event_id = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, eventId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error soft-deleting event " + eventId, e);
        }
        return false;
    }

    public List<Event> getAllEvents(String status, int page, int pageSize) {
        List<Event> events = new ArrayList<>();
        StringBuilder sql = new StringBuilder(BASE_SELECT_WITH_JOINS);

        boolean hasStatus = status != null && !status.trim().isEmpty();
        if (hasStatus) sql.append("WHERE e.status = ? ");
        sql.append("ORDER BY e.created_at DESC ");
        sql.append("OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            int idx = 1;
            if (hasStatus) ps.setString(idx++, status);
            ps.setInt(idx++, (page - 1) * pageSize);
            ps.setInt(idx, pageSize);

            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Event event = mapResultSetToEvent(rs);
                enrichWithJoinedFields(event, rs);
                events.add(event);
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Database error in EventDAO", e);
        }
        return events;
    }

    public int countEventsByStatus(String status) {
        String sql = "SELECT COUNT(*) FROM Events WHERE status = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Database error in EventDAO", e);
        }
        return 0;
    }

    public int countPendingEventsByOrganizer(int organizerId) {
        String sql = "SELECT COUNT(*) FROM Events WHERE organizer_id = ? AND status = 'pending'";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, organizerId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Database error in EventDAO", e);
        }
        return 0;
    }

    /**
     * Count total search results for pagination.
     * Mirrors the WHERE clause logic of searchEvents() without OFFSET/FETCH.
     */
    public int countSearchEvents(String keyword, String category, String dateFilter) {
        StringBuilder sql = new StringBuilder(
                "SELECT COUNT(*) FROM Events e " +
                "JOIN Categories c ON e.category_id = c.category_id " +
                "WHERE e.status = 'approved' ");

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append("AND (e.title LIKE ? OR e.description LIKE ?) ");
        }
        if (category != null && !category.trim().isEmpty()) {
            sql.append("AND c.slug = ? ");
        }
        appendDateFilter(sql, dateFilter);

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            int idx = 1;
            if (keyword != null && !keyword.trim().isEmpty()) {
                ps.setString(idx++, "%" + keyword + "%");
                ps.setString(idx++, "%" + keyword + "%");
            }
            if (category != null && !category.trim().isEmpty()) {
                ps.setString(idx++, category);
            }
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Database error in EventDAO.countSearchEvents", e);
        }
        return 0;
    }

    /** Pin event to homepage with given priority. Higher = more visible. */
    public boolean pinEvent(int eventId, int pinOrder) {
        String sql = "UPDATE Events SET pin_order = ?, updated_at = GETDATE() WHERE event_id = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, pinOrder);
            ps.setInt(2, eventId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error pinning event " + eventId, e);
        }
        return false;
    }

    /** Unpin event from homepage. */
    public boolean unpinEvent(int eventId) {
        return pinEvent(eventId, 0);
    }
}
