package com.sellingticket.dao;

import com.sellingticket.model.Event;
import com.sellingticket.model.PageResult;
import com.sellingticket.model.TicketType;
import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

public class EventDAO extends BaseDAO {

    private static final Logger LOGGER = Logger.getLogger(EventDAO.class.getName());

    private Event mapResultSetToEvent(ResultSet rs) throws SQLException {
        Event event = new Event();
        event.setEventId(rs.getInt("event_id"));
        event.setOrganizerId(rs.getInt("organizer_id"));
        event.setCategoryId(rs.getInt("category_id"));
        event.setTitle(rs.getString("title"));
        event.setSlug(rs.getString("slug"));
        if (hasColumn(rs, "short_description")) {
            event.setShortDescription(rs.getString("short_description"));
        }
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
        
        // Remove exception-driven mapping (assuming SELECT e.* always includes these columns)
        event.setRejectionReason(rs.getString("rejection_reason"));
        event.setRejectedAt(rs.getTimestamp("rejected_at"));
        
        // Event ticket settings
        if (hasColumn(rs, "max_tickets_per_order")) {
            event.setMaxTicketsPerOrder(rs.getInt("max_tickets_per_order"));
        }
        if (hasColumn(rs, "max_total_tickets")) {
            event.setMaxTotalTickets(rs.getInt("max_total_tickets"));
        }
        if (hasColumn(rs, "pre_order_enabled")) {
            event.setPreOrderEnabled(rs.getBoolean("pre_order_enabled"));
        }
        
        return event;
    }

    private Event mapEventWithJoins(ResultSet rs) throws SQLException {
        Event event = mapResultSetToEvent(rs);
        event.setCategoryName(rs.getString("category_name"));
        event.setOrganizerName(rs.getString("organizer_name"));
        
        // Handle optional min_price column safely
        if (hasColumn(rs, "min_price")) {
            event.setMinPrice(rs.getDouble("min_price"));
        }
        return event;
    }
    
    // Helper to check if a column exists to prevent exceptions
    private boolean hasColumn(ResultSet rs, String columnName) throws SQLException {
        ResultSetMetaData rsmd = rs.getMetaData();
        int columns = rsmd.getColumnCount();
        for (int x = 1; x <= columns; x++) {
            if (columnName.equalsIgnoreCase(rsmd.getColumnName(x))) {
                return true;
            }
        }
        return false;
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
        try (Connection conn = getConnection()) {
            boolean hasSD = hasColumn(conn, "Events", "is_deleted");
            String sdFilter = hasSD ? " AND (e.is_deleted = 0 OR e.is_deleted IS NULL) " : " ";
            
            String where = featuredOnly
                    ? "WHERE e.status = 'approved' AND e.is_featured = 1 AND (e.end_date IS NULL OR e.end_date >= GETDATE()) " + sdFilter
                    : "WHERE e.status = 'approved' AND (e.end_date IS NULL OR e.end_date >= GETDATE()) " + sdFilter;
            
            String sql = "SELECT TOP (?) " + BASE_SELECT_WITH_JOINS.substring("SELECT ".length()) + where +
                         "ORDER BY ISNULL(e.pin_order, 0) DESC, e.start_date ASC";
            
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, limit);
                try (ResultSet rs = ps.executeQuery()) {
                    List<Event> results = new ArrayList<>();
                    while (rs.next()) {
                        results.add(mapEventWithJoins(rs));
                    }
                    return results;
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Failed to get approved events", e);
            return new ArrayList<>();
        }
    }

    public List<Event> getFeaturedEvents(int limit) {
        return getApprovedEvents(true, limit);
    }

    public List<Event> getUpcomingEvents(int limit) {
        return getApprovedEvents(false, limit);
    }

    public List<Event> searchEvents(String keyword, String category, String dateFilter, int page, int pageSize) {
        try (Connection conn = getConnection()) {
            boolean hasSD = hasColumn(conn, "Events", "is_deleted");
            String sdFilter = hasSD ? " AND (e.is_deleted = 0 OR e.is_deleted IS NULL) " : " ";

            StringBuilder sql = new StringBuilder(BASE_SELECT_WITH_JOINS);
            sql.append("WHERE e.status = 'approved' ").append(sdFilter);

            if (keyword != null && !keyword.trim().isEmpty()) {
                sql.append("AND (e.title LIKE ? OR e.description LIKE ?) ");
            }
            if (category != null && !category.trim().isEmpty()) {
                sql.append("AND c.slug = ? ");
            }
            appendDateFilter(sql, dateFilter);

            sql.append("ORDER BY e.start_date ASC ");
            sql.append("OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");

            try (PreparedStatement ps = conn.prepareStatement(sql.toString())) {
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

                try (ResultSet rs = ps.executeQuery()) {
                    List<Event> results = new ArrayList<>();
                    while (rs.next()) {
                        results.add(mapEventWithJoins(rs));
                    }
                    return results;
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Failed to search events", e);
            return new ArrayList<>();
        }
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
        return querySingle(sql, ps -> ps.setInt(1, eventId), this::mapEventWithJoins);
    }

    /**
     * Batch-fetch events by a list of IDs (single query with IN clause).
     * Eliminates N+1 queries when merging staff events.
     */
    public List<Event> getEventsByIds(List<Integer> ids) {
        if (ids == null || ids.isEmpty()) return new ArrayList<>();

        // Build parameterized IN clause: WHERE e.event_id IN (?,?,?)
        StringBuilder placeholders = new StringBuilder();
        for (int i = 0; i < ids.size(); i++) {
            if (i > 0) placeholders.append(',');
            placeholders.append('?');
        }
        String sql = BASE_SELECT_WITH_JOINS + "WHERE e.event_id IN (" + placeholders + ")";

        return queryList(sql, ps -> {
            for (int i = 0; i < ids.size(); i++) {
                ps.setInt(i + 1, ids.get(i));
            }
        }, this::mapEventWithJoins);
    }

    public Event getEventBySlug(String slug) {
        String sql = BASE_SELECT_WITH_JOINS + "WHERE e.slug = ?";
        return querySingle(sql, ps -> ps.setString(1, slug), this::mapEventWithJoins);
    }

    public List<Event> getEventsByOrganizer(int organizerId) {
        try (Connection conn = getConnection()) {
            boolean hasSD = hasColumn(conn, "Events", "is_deleted");
            String sdFilter = hasSD ? " AND (e.is_deleted = 0 OR e.is_deleted IS NULL) " : " ";

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
                         "           WHERE o.status IN ('paid','completed') " +
                         "           GROUP BY tt.event_id) rev ON rev.event_id = e.event_id " +
                         "WHERE e.organizer_id = ? " + sdFilter + " ORDER BY e.created_at DESC";

            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, organizerId);
                try (ResultSet rs = ps.executeQuery()) {
                    List<Event> results = new ArrayList<>();
                    while (rs.next()) {
                        Event event = mapResultSetToEvent(rs);
                        event.setCategoryName(rs.getString("category_name"));
                        event.setSoldTickets(rs.getInt("sold_tickets"));
                        event.setTotalTickets(rs.getInt("total_tickets"));
                        event.setRevenue(rs.getDouble("revenue"));
                        results.add(event);
                    }
                    return results;
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Failed to get events by organizer", e);
            return new ArrayList<>();
        }
    }

    public int countApprovedEventsForUser(int userId) {
        try (Connection conn = getConnection()) {
            boolean hasSD = hasColumn(conn, "Events", "is_deleted");
            String sdFilter = hasSD ? " AND (is_deleted = 0 OR is_deleted IS NULL)" : "";
            
            String sql = "SELECT COUNT(*) FROM Events WHERE " +
                         "(organizer_id = ? OR event_id IN (SELECT event_id FROM EventStaff WHERE user_id = ?)) " +
                         "AND status IN ('approved', 'ended', 'completed', 'cancelled') " + sdFilter;
            
            return queryScalar(sql, ps -> {
                ps.setInt(1, userId);
                ps.setInt(2, userId);
            }, 0);
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Failed to count approved events", e);
            return 0;
        }
    }

    public List<Event> getAllEventsWithStats() {
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
                     "           WHERE o.status IN ('paid','completed') " +
                     "           GROUP BY tt.event_id) rev ON rev.event_id = e.event_id " +
                     "ORDER BY e.created_at DESC";
                     
        return queryList(sql, NO_PARAMS, rs -> {
            Event event = mapResultSetToEvent(rs);
            event.setCategoryName(rs.getString("category_name"));
            event.setOrganizerName(rs.getString("organizer_name"));
            event.setSoldTickets(rs.getInt("sold_tickets"));
            event.setTotalTickets(rs.getInt("total_tickets"));
            event.setRevenue(rs.getDouble("revenue"));
            return event;
        });
    }

    public List<Event> getPendingEvents() {
        try (Connection conn = getConnection()) {
            boolean hasSD = hasColumn(conn, "Events", "is_deleted");
            String sdFilter = hasSD ? " AND (e.is_deleted = 0 OR e.is_deleted IS NULL) " : " ";

            String sql = "SELECT e.*, c.name as category_name, u.full_name as organizer_name " +
                         "FROM Events e " +
                         "JOIN Categories c ON e.category_id = c.category_id " +
                         "JOIN Users u ON e.organizer_id = u.user_id " +
                         "WHERE e.status = 'pending' " + sdFilter + "ORDER BY e.created_at DESC";
                         
            return queryList(sql, NO_PARAMS, rs -> {
                Event event = mapResultSetToEvent(rs);
                event.setCategoryName(rs.getString("category_name"));
                event.setOrganizerName(rs.getString("organizer_name"));
                return event;
            });
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Failed to get pending events", e);
            return new ArrayList<>();
        }
    }

    public boolean createEvent(Event event) {
        String sql = "INSERT INTO Events (organizer_id, category_id, title, slug, short_description, description, banner_image, " +
                     "location, address, start_date, end_date, status, is_featured, is_private, " +
                     "max_tickets_per_order, max_total_tickets, pre_order_enabled) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
                     
        int newId = executeInsertReturnKey(sql, ps -> {
            ps.setInt(1, event.getOrganizerId());
            ps.setInt(2, event.getCategoryId());
            ps.setString(3, event.getTitle());
            ps.setString(4, event.getSlug());
            ps.setString(5, event.getShortDescription());
            ps.setString(6, event.getDescription());
            ps.setString(7, event.getBannerImage());
            ps.setString(8, event.getLocation());
            ps.setString(9, event.getAddress());
            ps.setTimestamp(10, new Timestamp(event.getStartDate().getTime()));
            ps.setTimestamp(11, event.getEndDate() != null ? new Timestamp(event.getEndDate().getTime()) : null);
            ps.setString(12, event.getStatus());
            ps.setBoolean(13, event.isFeatured());
            ps.setBoolean(14, event.isPrivate());
            ps.setInt(15, event.getMaxTicketsPerOrder());
            ps.setInt(16, event.getMaxTotalTickets());
            ps.setBoolean(17, event.isPreOrderEnabled());
        });
        
        if (newId > 0) {
            event.setEventId(newId);
            return true;
        }
        return false;
    }

    public boolean createEventWithTickets(Event event, List<TicketType> tickets) {
        if (event == null || event.getStartDate() == null) {
            return false;
        }
        if (tickets == null || tickets.isEmpty()) {
            return false;
        }

        String eventSql = "INSERT INTO Events (organizer_id, category_id, title, slug, short_description, description, banner_image, " +
                "location, address, start_date, end_date, status, is_featured, is_private, " +
                "max_tickets_per_order, max_total_tickets, pre_order_enabled) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        String ticketSql = "INSERT INTO TicketTypes (event_id, name, description, price, quantity, sale_start, sale_end) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?)";

        Connection conn = null;
        try {
            conn = getConnection();
            conn.setAutoCommit(false);

            int eventId;
            try (PreparedStatement eventPs = conn.prepareStatement(eventSql, Statement.RETURN_GENERATED_KEYS)) {
                eventPs.setInt(1, event.getOrganizerId());
                eventPs.setInt(2, event.getCategoryId());
                eventPs.setString(3, event.getTitle());
                eventPs.setString(4, event.getSlug());
                eventPs.setString(5, event.getShortDescription());
                eventPs.setString(6, event.getDescription());
                eventPs.setString(7, event.getBannerImage());
                eventPs.setString(8, event.getLocation());
                eventPs.setString(9, event.getAddress());
                eventPs.setTimestamp(10, new Timestamp(event.getStartDate().getTime()));
                eventPs.setTimestamp(11, event.getEndDate() != null ? new Timestamp(event.getEndDate().getTime()) : null);
                eventPs.setString(12, event.getStatus());
                eventPs.setBoolean(13, event.isFeatured());
                eventPs.setBoolean(14, event.isPrivate());
                eventPs.setInt(15, event.getMaxTicketsPerOrder());
                eventPs.setInt(16, event.getMaxTotalTickets());
                eventPs.setBoolean(17, event.isPreOrderEnabled());

                int inserted = eventPs.executeUpdate();
                if (inserted <= 0) {
                    conn.rollback();
                    return false;
                }

                try (ResultSet rs = eventPs.getGeneratedKeys()) {
                    if (!rs.next()) {
                        conn.rollback();
                        return false;
                    }
                    eventId = rs.getInt(1);
                }
            }

            try (PreparedStatement ticketPs = conn.prepareStatement(ticketSql)) {
                for (TicketType ticket : tickets) {
                    if (!isValidTicketType(ticket)) {
                        conn.rollback();
                        return false;
                    }
                    ticketPs.setInt(1, eventId);
                    ticketPs.setString(2, ticket.getName().trim());
                    ticketPs.setString(3, ticket.getDescription());
                    ticketPs.setDouble(4, ticket.getPrice());
                    ticketPs.setInt(5, ticket.getQuantity());
                    ticketPs.setTimestamp(6, ticket.getSaleStart() != null ? new Timestamp(ticket.getSaleStart().getTime()) : null);
                    ticketPs.setTimestamp(7, ticket.getSaleEnd() != null ? new Timestamp(ticket.getSaleEnd().getTime()) : null);
                    ticketPs.addBatch();
                }

                int[] batchResult = ticketPs.executeBatch();
                for (int affected : batchResult) {
                    if (affected == Statement.EXECUTE_FAILED) {
                        conn.rollback();
                        return false;
                    }
                }
            }

            conn.commit();
            event.setEventId(eventId);
            return true;
        } catch (SQLException e) {
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException rollbackEx) {
                    LOGGER.log(Level.SEVERE, "Failed to rollback event creation transaction", rollbackEx);
                }
            }
            LOGGER.log(Level.SEVERE, "Failed to create event with tickets transactionally", e);
            return false;
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                } catch (SQLException e) {
                    LOGGER.log(Level.WARNING, "Failed to reset auto-commit", e);
                }
                try {
                    conn.close();
                } catch (SQLException e) {
                    LOGGER.log(Level.WARNING, "Failed to close connection", e);
                }
            }
        }
    }

    private boolean isValidTicketType(TicketType ticket) {
        if (ticket == null) return false;
        if (ticket.getName() == null || ticket.getName().trim().isEmpty()) return false;
        if (ticket.getName().trim().length() > 100) return false;
        if (ticket.getPrice() < 0) return false;
        return ticket.getQuantity() > 0;
    }

    public boolean updateEventStatus(int eventId, String status) {
        try (Connection conn = getConnection()) {
            boolean hasSD = hasColumn(conn, "Events", "is_deleted");
            String sdFilter = hasSD ? " AND (is_deleted = 0 OR is_deleted IS NULL)" : "";
            
            String sql = "UPDATE Events " +
                         "SET status = ?, rejection_reason = NULL, rejected_at = NULL, updated_at = GETDATE() " +
                         "WHERE event_id = ? AND status IN ('pending', 'draft')" + sdFilter;
            
            return executeUpdate(sql, ps -> {
                ps.setString(1, status);
                ps.setInt(2, eventId);
            }) > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Failed to update event status", e);
            return false;
        }
    }

    public boolean updateEventStatusWithReason(int eventId, String status, String reason) {
        try (Connection conn = getConnection()) {
            boolean hasSD = hasColumn(conn, "Events", "is_deleted");
            String sdFilter = hasSD ? " AND (is_deleted = 0 OR is_deleted IS NULL)" : "";

            String sql = "UPDATE Events " +
                         "SET status = ?, rejection_reason = ?, rejected_at = GETDATE(), updated_at = GETDATE() " +
                         "WHERE event_id = ? AND status IN ('pending', 'draft')" + sdFilter;
            
            return executeUpdate(sql, ps -> {
                ps.setString(1, status);
                ps.setString(2, reason);
                ps.setInt(3, eventId);
            }) > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Failed to update event status with reason", e);
            return false;
        }
    }

    public void incrementViews(int eventId) {
        String sql = "UPDATE Events SET views = views + 1 WHERE event_id = ?";
        executeUpdate(sql, ps -> ps.setInt(1, eventId));
    }

    public int getTotalEvents() {
        String sql = "SELECT COUNT(*) FROM Events WHERE status = 'approved'";
        return queryScalar(sql, NO_PARAMS, 0);
    }

    public List<Event> getRelatedEvents(int categoryId, int currentEventId, int limit) {
        try (Connection conn = getConnection()) {
            boolean hasSD = hasColumn(conn, "Events", "is_deleted");
            String sdFilter = hasSD ? " AND (e.is_deleted = 0 OR e.is_deleted IS NULL) " : " ";

            String sql = "SELECT TOP (?) " + BASE_SELECT_WITH_JOINS.substring("SELECT ".length()) +
                         "WHERE e.status = 'approved' AND e.category_id = ? AND e.event_id != ? AND (e.end_date IS NULL OR e.end_date >= GETDATE()) " +
                         sdFilter + "ORDER BY e.start_date ASC";
            
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, limit);
                ps.setInt(2, categoryId);
                ps.setInt(3, currentEventId);
                try (ResultSet rs = ps.executeQuery()) {
                    List<Event> results = new ArrayList<>();
                    while (rs.next()) {
                        results.add(mapEventWithJoins(rs));
                    }
                    return results;
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Failed to get related events", e);
            return new ArrayList<>();
        }
    }

    public boolean updateEvent(Event event) {
        try (Connection conn = getConnection()) {
            boolean hasSD = hasColumn(conn, "Events", "is_deleted");
            String sdFilter = hasSD ? " AND (is_deleted = 0 OR is_deleted IS NULL)" : "";

            String sql = "UPDATE Events SET " +
                         "category_id = ?, title = ?, slug = ?, short_description = ?, description = ?, banner_image = ?, " +
                         "location = ?, address = ?, start_date = ?, end_date = ?, " +
                         "status = ?, is_featured = ?, is_private = ?, " +
                         "max_tickets_per_order = ?, max_total_tickets = ?, pre_order_enabled = ?, " +
                         "updated_at = GETDATE() " +
                         "WHERE event_id = ?" + sdFilter;
            
            return executeUpdate(sql, ps -> {
                ps.setInt(1, event.getCategoryId());
                ps.setString(2, event.getTitle());
                ps.setString(3, event.getSlug());
                ps.setString(4, event.getShortDescription());
                ps.setString(5, event.getDescription());
                ps.setString(6, event.getBannerImage());
                ps.setString(7, event.getLocation());
                ps.setString(8, event.getAddress());
                ps.setTimestamp(9, new Timestamp(event.getStartDate().getTime()));
                ps.setTimestamp(10, event.getEndDate() != null ? new Timestamp(event.getEndDate().getTime()) : null);
                String normalizedStatus = "ended".equalsIgnoreCase(event.getStatus()) ? "approved" : event.getStatus();
                ps.setString(11, normalizedStatus);
                ps.setBoolean(12, event.isFeatured());
                ps.setBoolean(13, event.isPrivate());
                ps.setInt(14, event.getMaxTicketsPerOrder());
                ps.setInt(15, event.getMaxTotalTickets());
                ps.setBoolean(16, event.isPreOrderEnabled());
                ps.setInt(17, event.getEventId());
            }) > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Failed to update event", e);
            return false;
        }
    }

    public boolean deleteEvent(int eventId) {
        try (Connection conn = getConnection()) {
            boolean hasSD = hasColumn(conn, "Events", "is_deleted");
            if (hasSD) {
                String sql = "UPDATE Events SET is_deleted = 1, status = 'cancelled', updated_at = GETDATE() " +
                             "WHERE event_id = ? AND (is_deleted = 0 OR is_deleted IS NULL)";
                return executeUpdate(sql, ps -> ps.setInt(1, eventId)) > 0;
            } else {
                String sql = "UPDATE Events SET status = 'cancelled', updated_at = GETDATE() WHERE event_id = ?";
                return executeUpdate(sql, ps -> ps.setInt(1, eventId)) > 0;
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Failed to delete event", e);
            return false;
        }
    }

    public boolean updateEventSettings(int eventId, int maxTicketsPerOrder, int maxTotalTickets, boolean preOrderEnabled) {
        String sql = "UPDATE Events SET max_tickets_per_order = ?, max_total_tickets = ?, pre_order_enabled = ?, "
                   + "updated_at = GETDATE() WHERE event_id = ?";
        return executeUpdate(sql, ps -> {
            ps.setInt(1, maxTicketsPerOrder);
            ps.setInt(2, maxTotalTickets);
            ps.setBoolean(3, preOrderEnabled);
            ps.setInt(4, eventId);
        }) > 0;
    }

    public List<Event> getAllEvents(String status, int page, int pageSize) {
        try (Connection conn = getConnection()) {
            boolean hasSD = hasColumn(conn, "Events", "is_deleted");
            String sdFilter = hasSD ? " (e.is_deleted = 0 OR e.is_deleted IS NULL) " : " (1=1) ";

            StringBuilder sql = new StringBuilder(BASE_SELECT_WITH_JOINS);
            sql.append("WHERE ").append(sdFilter);

            boolean hasStatus = status != null && !status.trim().isEmpty();
            if (hasStatus) sql.append("AND e.status = ? ");
            sql.append("ORDER BY e.created_at DESC ");
            sql.append("OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");

            try (PreparedStatement ps = conn.prepareStatement(sql.toString())) {
                int idx = 1;
                if (hasStatus) ps.setString(idx++, status);
                ps.setInt(idx++, (page - 1) * pageSize);
                ps.setInt(idx, pageSize);
                
                try (ResultSet rs = ps.executeQuery()) {
                    List<Event> results = new ArrayList<>();
                    while (rs.next()) {
                        results.add(mapEventWithJoins(rs));
                    }
                    return results;
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Failed to get all events", e);
            return new ArrayList<>();
        }
    }

    public int countEventsByStatus(String status) {
        try (Connection conn = getConnection()) {
            boolean hasSD = hasColumn(conn, "Events", "is_deleted");
            String sdFilter = hasSD ? " AND (is_deleted = 0 OR is_deleted IS NULL)" : "";
            
            String sql = "SELECT COUNT(*) FROM Events WHERE status = ?" + sdFilter;
            return queryScalar(sql, ps -> ps.setString(1, status), 0);
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Failed to count events by status", e);
            return 0;
        }
    }

    public int countPendingEventsByOrganizer(int organizerId) {
        try (Connection conn = getConnection()) {
            boolean hasSD = hasColumn(conn, "Events", "is_deleted");
            String sdFilter = hasSD ? " AND (is_deleted = 0 OR is_deleted IS NULL)" : "";
            
            String sql = "SELECT COUNT(*) FROM Events WHERE organizer_id = ? AND status = 'pending' " + sdFilter;
            return queryScalar(sql, ps -> ps.setInt(1, organizerId), 0);
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Failed to count pending events", e);
            return 0;
        }
    }

    public int countSearchEvents(String keyword, String category, String dateFilter) {
        try (Connection conn = getConnection()) {
            boolean hasSD = hasColumn(conn, "Events", "is_deleted");
            String sdFilter = hasSD ? " AND (e.is_deleted = 0 OR e.is_deleted IS NULL) " : " ";

            StringBuilder sql = new StringBuilder(
                    "SELECT COUNT(*) FROM Events e " +
                    "JOIN Categories c ON e.category_id = c.category_id " +
                "WHERE e.status = 'approved' ").append(sdFilter);

            if (keyword != null && !keyword.trim().isEmpty()) {
                sql.append("AND (e.title LIKE ? OR e.description LIKE ?) ");
            }
            if (category != null && !category.trim().isEmpty()) {
                sql.append("AND c.slug = ? ");
            }
            appendDateFilter(sql, dateFilter);

            try (PreparedStatement ps = conn.prepareStatement(sql.toString())) {
                int idx = 1;
                if (keyword != null && !keyword.trim().isEmpty()) {
                    ps.setString(idx++, "%" + keyword + "%");
                    ps.setString(idx++, "%" + keyword + "%");
                }
                if (category != null && !category.trim().isEmpty()) {
                    ps.setString(idx++, category);
                }
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) return rs.getInt(1);
                    return 0;
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Failed to count search events", e);
            return 0;
        }
    }

    public Map<String, Integer> getAdminEventStatusCounts(String keyword, String category) {
        Map<String, Integer> counts = new HashMap<>();
        counts.put("pending", 0);
        counts.put("approved", 0);
        counts.put("rejected", 0);

        try (Connection conn = getConnection()) {
            boolean hasSD = hasColumn(conn, "Events", "is_deleted");
            String sdFilter = hasSD ? " AND (e.is_deleted = 0 OR e.is_deleted IS NULL) " : " ";

            StringBuilder sql = new StringBuilder(
                    "SELECT e.status, COUNT(*) AS total " +
                    "FROM Events e " +
                    "JOIN Categories c ON e.category_id = c.category_id " +
                    "WHERE (1=1) ").append(sdFilter);

            List<Object> params = new ArrayList<>();
            if (keyword != null && !keyword.trim().isEmpty()) {
                sql.append("AND (e.title LIKE ? OR e.description LIKE ?) ");
                String kw = "%" + keyword.trim() + "%";
                params.add(kw);
                params.add(kw);
            }
            if (category != null && !category.trim().isEmpty()) {
                sql.append("AND c.slug = ? ");
                params.add(category.trim());
            }

            sql.append("GROUP BY e.status");

            try (PreparedStatement ps = conn.prepareStatement(sql.toString())) {
                int idx = 1;
                for (Object param : params) {
                    ps.setString(idx++, (String) param);
                }
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        String status = rs.getString("status");
                        if (counts.containsKey(status)) {
                            counts.put(status, rs.getInt("total"));
                        }
                    }
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Failed to get admin event status counts", e);
        }
        return counts;
    }

    public boolean pinEvent(int eventId, int pinOrder) {
        String sql = "UPDATE Events SET pin_order = ?, updated_at = GETDATE() WHERE event_id = ?";
        return executeUpdate(sql, ps -> {
            ps.setInt(1, pinOrder);
            ps.setInt(2, eventId);
        }) > 0;
    }

    public boolean unpinEvent(int eventId) {
        return pinEvent(eventId, 0);
    }

    // ========================
    // PAGED SEARCH METHODS
    // ========================

    // Advanced paginated search for public events page
    public PageResult<Event> searchEventsPaged(String keyword, String category,
            String dateFrom, String dateTo, Double priceMin, Double priceMax,
            String sort, int page, int pageSize) {

        try (Connection conn = getConnection()) {
            boolean hasSD = hasColumn(conn, "Events", "is_deleted");
            String sdFilter = hasSD ? " AND (e.is_deleted = 0 OR e.is_deleted IS NULL) " : " ";

            StringBuilder where = new StringBuilder();
            where.append("WHERE e.status = 'approved' ").append(sdFilter);
            where.append("AND (e.end_date IS NULL OR e.end_date >= GETDATE()) ");

            List<Object> params = new ArrayList<>();

            if (keyword != null && !keyword.trim().isEmpty()) {
                where.append("AND (e.title LIKE ? OR e.description LIKE ? OR e.location LIKE ?) ");
                String kw = "%" + keyword.trim() + "%";
                params.add(kw); params.add(kw); params.add(kw);
            }
            if (category != null && !category.trim().isEmpty()) {
                where.append("AND c.slug = ? ");
                params.add(category.trim());
            }
            if (dateFrom != null && !dateFrom.trim().isEmpty()) {
                where.append("AND CAST(e.start_date AS DATE) >= ? ");
                params.add(dateFrom.trim());
            }
            if (dateTo != null && !dateTo.trim().isEmpty()) {
                where.append("AND CAST(e.start_date AS DATE) <= ? ");
                params.add(dateTo.trim());
            }
            if (priceMin != null) {
                where.append("AND ISNULL(tp.min_price, 0) >= ? ");
                params.add(priceMin);
            }
            if (priceMax != null) {
                where.append("AND ISNULL(tp.min_price, 0) <= ? ");
                params.add(priceMax);
            }

            String orderBy;
            switch (sort != null ? sort : "date_asc") {
                case "date_desc": orderBy = "ORDER BY e.start_date DESC "; break;
                case "price_asc": orderBy = "ORDER BY ISNULL(tp.min_price, 0) ASC "; break;
                case "price_desc": orderBy = "ORDER BY ISNULL(tp.min_price, 0) DESC "; break;
                case "popular": orderBy = "ORDER BY e.views DESC "; break;
                case "newest": orderBy = "ORDER BY e.created_at DESC "; break;
                default: orderBy = "ORDER BY e.start_date ASC "; break;
            }

            String dataSql = BASE_SELECT_WITH_JOINS + where.toString() + orderBy + "OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";
            String countSql = "SELECT COUNT(*) FROM Events e " +
                    "JOIN Categories c ON e.category_id = c.category_id " +
                    "LEFT JOIN (SELECT event_id, MIN(price) as min_price FROM TicketTypes GROUP BY event_id) tp ON tp.event_id = e.event_id " +
                    where.toString();

            int totalItems = 0;
            try (PreparedStatement ps = conn.prepareStatement(countSql)) {
                int idx = 1;
                for (Object p : params) {
                    if (p instanceof String) ps.setString(idx++, (String) p);
                    else if (p instanceof Double) ps.setDouble(idx++, (Double) p);
                    else if (p instanceof Integer) ps.setInt(idx++, (Integer) p);
                }
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) totalItems = rs.getInt(1);
                }
            }

            List<Event> items = new ArrayList<>();
            try (PreparedStatement ps = conn.prepareStatement(dataSql)) {
                int idx = 1;
                for (Object p : params) {
                    if (p instanceof String) ps.setString(idx++, (String) p);
                    else if (p instanceof Double) ps.setDouble(idx++, (Double) p);
                    else if (p instanceof Integer) ps.setInt(idx++, (Integer) p);
                }
                ps.setInt(idx++, (page - 1) * pageSize);
                ps.setInt(idx, pageSize);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        items.add(mapEventWithJoins(rs));
                    }
                }
            }
            return new PageResult<>(items, totalItems, page, pageSize);
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Failed searchEventsPaged", e);
            return new PageResult<>(new ArrayList<>(), 0, page, pageSize);
        }
    }

    // Paginated search for admin event management
    public PageResult<Event> getAllEventsPaged(String keyword, String[] statuses,
            String category, int page, int pageSize) {

        try (Connection conn = getConnection()) {
            boolean hasSD = hasColumn(conn, "Events", "is_deleted");
            String sdFilter = hasSD ? " WHERE (e.is_deleted = 0 OR e.is_deleted IS NULL) " : " WHERE (1=1) ";
            List<Object> params = new ArrayList<>();

            StringBuilder where = new StringBuilder(sdFilter);

            if (keyword != null && !keyword.trim().isEmpty()) {
                where.append("AND (e.title LIKE ? OR e.description LIKE ?) ");
                String kw = "%" + keyword.trim() + "%";
                params.add(kw); params.add(kw);
            }
            if (statuses != null && statuses.length > 0) {
                where.append("AND e.status IN (");
                for (int i = 0; i < statuses.length; i++) {
                    where.append(i > 0 ? ",?" : "?");
                    params.add(statuses[i]);
                }
                where.append(") ");
            }
            if (category != null && !category.trim().isEmpty()) {
                where.append("AND c.slug = ? ");
                params.add(category.trim());
            }

            String baseSql = "SELECT e.*, c.name as category_name, u.full_name as organizer_name, " +
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
                    "           WHERE o.status IN ('paid','completed') " +
                    "           GROUP BY tt.event_id) rev ON rev.event_id = e.event_id ";

            String dataSql = baseSql + where.toString() + "ORDER BY e.created_at DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";
            String countSql = "SELECT COUNT(*) FROM Events e " +
                    "JOIN Categories c ON e.category_id = c.category_id " + where.toString();

            int totalItems = 0;
            try (PreparedStatement ps = conn.prepareStatement(countSql)) {
                int idx = 1;
                for (Object p : params) {
                    ps.setString(idx++, (String) p);
                }
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) totalItems = rs.getInt(1);
                }
            }

            List<Event> items = new ArrayList<>();
            try (PreparedStatement ps = conn.prepareStatement(dataSql)) {
                int idx = 1;
                for (Object p : params) {
                    ps.setString(idx++, (String) p);
                }
                ps.setInt(idx++, (page - 1) * pageSize);
                ps.setInt(idx, pageSize);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Event event = mapResultSetToEvent(rs);
                        event.setCategoryName(rs.getString("category_name"));
                        event.setOrganizerName(rs.getString("organizer_name"));
                        event.setSoldTickets(rs.getInt("sold_tickets"));
                        event.setTotalTickets(rs.getInt("total_tickets"));
                        event.setRevenue(rs.getDouble("revenue"));
                        items.add(event);
                    }
                }
            }
            return new PageResult<>(items, totalItems, page, pageSize);
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Failed getAllEventsPaged", e);
            return new PageResult<>(new ArrayList<>(), 0, page, pageSize);
        }
    }

    // Paginated search for organizer's own events
    public PageResult<Event> getEventsByOrganizerPaged(int organizerId, String keyword,
            String[] statuses, int page, int pageSize) {

        try (Connection conn = getConnection()) {
            boolean hasSD = hasColumn(conn, "Events", "is_deleted");
            String sdFilter = hasSD ? " AND (e.is_deleted = 0 OR e.is_deleted IS NULL) " : " ";

            StringBuilder where = new StringBuilder(
                "WHERE (e.organizer_id = ? OR EXISTS (" +
                "SELECT 1 FROM EventStaff es WHERE es.event_id = e.event_id AND es.user_id = ?" +
                ")) ").append(sdFilter);
            
            List<Object> params = new ArrayList<>();
            params.add(organizerId);
            params.add(organizerId);

            if (keyword != null && !keyword.trim().isEmpty()) {
                where.append("AND (e.title LIKE ? OR e.description LIKE ?) ");
                String kw = "%" + keyword.trim() + "%";
                params.add(kw); params.add(kw);
            }
            if (statuses != null && statuses.length > 0) {
                List<String> statusClauses = new ArrayList<>();
                for (String raw : statuses) {
                    if (raw == null || raw.trim().isEmpty()) continue;
                    String status = raw.trim().toLowerCase();
                    switch (status) {
                        case "ended":
                            statusClauses.add("(e.status = 'approved' AND e.end_date IS NOT NULL AND e.end_date < GETDATE())");
                            break;
                        case "approved":
                            statusClauses.add("(e.status = 'approved' AND (e.end_date IS NULL OR e.end_date >= GETDATE()))");
                            break;
                        default:
                            statusClauses.add("e.status = ?");
                            params.add(status);
                            break;
                    }
                }
                if (!statusClauses.isEmpty()) {
                    where.append("AND (").append(String.join(" OR ", statusClauses)).append(") ");
                }
            }

            String baseSql = "SELECT e.*, c.name as category_name, " +
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
                    "           WHERE o.status IN ('paid','completed') " +
                    "           GROUP BY tt.event_id) rev ON rev.event_id = e.event_id ";

            String dataSql = baseSql + where.toString() + "ORDER BY e.created_at DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";
            String countSql = "SELECT COUNT(*) FROM Events e " +
                    "JOIN Categories c ON e.category_id = c.category_id " + where.toString();

            int totalItems = 0;
            try (PreparedStatement ps = conn.prepareStatement(countSql)) {
                int idx = 1;
                for (Object p : params) {
                    if (p instanceof Integer) ps.setInt(idx++, (Integer) p);
                    else if (p instanceof String) ps.setString(idx++, (String) p);
                }
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) totalItems = rs.getInt(1);
                }
            }

            List<Event> items = new ArrayList<>();
            try (PreparedStatement ps = conn.prepareStatement(dataSql)) {
                int idx = 1;
                for (Object p : params) {
                    if (p instanceof Integer) ps.setInt(idx++, (Integer) p);
                    else if (p instanceof String) ps.setString(idx++, (String) p);
                }
                ps.setInt(idx++, (page - 1) * pageSize);
                ps.setInt(idx, pageSize);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Event event = mapResultSetToEvent(rs);
                        event.setCategoryName(rs.getString("category_name"));
                        event.setSoldTickets(rs.getInt("sold_tickets"));
                        event.setTotalTickets(rs.getInt("total_tickets"));
                        event.setRevenue(rs.getDouble("revenue"));
                        items.add(event);
                    }
                }
            }
            return new PageResult<>(items, totalItems, page, pageSize);
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Failed getEventsByOrganizerPaged", e);
            return new PageResult<>(new ArrayList<>(), 0, page, pageSize);
        }
    }
}
