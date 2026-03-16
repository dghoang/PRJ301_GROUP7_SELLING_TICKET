package com.sellingticket.dao;

import com.sellingticket.util.DBContext;
import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * DashboardDAO — Retrieves all dashboard statistics.
 * Uses single-query aggregation to minimize DB round-trips.
 * All ResultSets use try-with-resources to prevent leaks.
 */
public class DashboardDAO extends DBContext {

    private static final Logger LOGGER = Logger.getLogger(DashboardDAO.class.getName());

    /**
     * Get all admin dashboard statistics in a single query.
     */
    public Map<String, Object> getAdminDashboardStats() {
        Map<String, Object> stats = new HashMap<>();

        String sql = "SELECT " +
                "(SELECT COUNT(*) FROM Events) as total_events, " +
                "(SELECT COUNT(*) FROM Events WHERE status = 'pending') as pending_events, " +
                "(SELECT COUNT(*) FROM Events WHERE status = 'approved') as approved_events, " +
                "(SELECT COUNT(*) FROM Users) as total_users, " +
                "(SELECT ISNULL(SUM(final_amount), 0) FROM Orders WHERE status = 'paid') as total_revenue, " +
                "(SELECT COUNT(*) FROM Orders WHERE status = 'pending') as pending_orders, " +
                "(SELECT COUNT(*) FROM Orders WHERE status = 'paid') as paid_orders, " +
                "(SELECT COUNT(*) FROM Orders WHERE status = 'cancelled') as cancelled_orders, " +
                "(SELECT COUNT(*) FROM Orders) as total_orders";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                stats.put("totalEvents", rs.getInt("total_events"));
                stats.put("pendingEvents", rs.getInt("pending_events"));
                stats.put("approvedEvents", rs.getInt("approved_events"));
                stats.put("totalUsers", rs.getInt("total_users"));
                stats.put("totalRevenue", rs.getDouble("total_revenue"));
                stats.put("pendingOrders", rs.getInt("pending_orders"));
                stats.put("paidOrders", rs.getInt("paid_orders"));
                stats.put("cancelledOrders", rs.getInt("cancelled_orders"));
                stats.put("totalOrders", rs.getInt("total_orders"));
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to load admin dashboard stats", e);
        }

        return stats;
    }

    /**
     * Get category distribution for pie/doughnut chart.
     * Returns list of {name, count} maps.
     */
    public List<Map<String, Object>> getCategoryDistribution() {
        List<Map<String, Object>> result = new ArrayList<>();
        String sql = "SELECT c.name, COUNT(e.event_id) as event_count " +
                "FROM Categories c LEFT JOIN Events e ON c.category_id = e.category_id " +
                "GROUP BY c.name ORDER BY event_count DESC";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("name", rs.getString("name"));
                row.put("count", rs.getInt("event_count"));
                result.add(row);
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to load category distribution", e);
        }
        return result;
    }

    /**
     * Get daily revenue for the last N days (for admin revenue chart).
     */
    public List<Map<String, Object>> getRevenueByDays(int days) {
        List<Map<String, Object>> result = new ArrayList<>();
        String sql = "SELECT CONVERT(date, o.created_at) as order_date, " +
                "ISNULL(SUM(CASE WHEN o.status = 'paid' THEN o.final_amount ELSE 0 END), 0) as revenue, " +
                "COUNT(CASE WHEN o.status = 'paid' THEN 1 END) as ticket_count " +
                "FROM Orders o " +
                "WHERE o.created_at >= DATEADD(day, -?, GETDATE()) " +
                "GROUP BY CONVERT(date, o.created_at) " +
                "ORDER BY order_date";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, days);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new HashMap<>();
                    row.put("date", rs.getString("order_date"));
                    row.put("revenue", rs.getDouble("revenue"));
                    row.put("ticketCount", rs.getInt("ticket_count"));
                    result.add(row);
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to load revenue by days", e);
        }
        return result;
    }

    /**
     * Get organizer-specific dashboard stats.
     */
    public Map<String, Object> getOrganizerDashboardStats(int organizerId) {
        Map<String, Object> stats = new HashMap<>();

        String sql = "SELECT " +
                "(SELECT COUNT(*) FROM Events WHERE organizer_id = ?) as my_events, " +
                "(SELECT COUNT(*) FROM Events WHERE organizer_id = ? AND status = 'approved') as approved_events, " +
                "(SELECT COUNT(*) FROM Events WHERE organizer_id = ? AND status = 'pending') as pending_events, " +
                "(SELECT ISNULL(SUM(o.final_amount), 0) FROM Orders o JOIN Events e ON o.event_id = e.event_id " +
                "   WHERE e.organizer_id = ? AND o.status = 'paid') as my_revenue, " +
                "(SELECT COUNT(*) FROM Orders o JOIN Events e ON o.event_id = e.event_id " +
                "   WHERE e.organizer_id = ?) as my_total_orders";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            for (int i = 1; i <= 5; i++) {
                ps.setInt(i, organizerId);
            }
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    stats.put("myEvents", rs.getInt("my_events"));
                    stats.put("approvedEvents", rs.getInt("approved_events"));
                    stats.put("pendingEvents", rs.getInt("pending_events"));
                    stats.put("myRevenue", rs.getDouble("my_revenue"));
                    stats.put("myTotalOrders", rs.getInt("my_total_orders"));
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to load organizer dashboard stats for id=" + organizerId, e);
        }

        return stats;
    }

    /**
     * Get per-event stats for an organizer.
     */
    public List<Map<String, Object>> getOrganizerEventStats(int organizerId) {
        List<Map<String, Object>> result = new ArrayList<>();

        String sql = "SELECT e.event_id, " +
                "COUNT(o.order_id) as order_count, " +
                "ISNULL(SUM(CASE WHEN o.status = 'paid' THEN o.final_amount ELSE 0 END), 0) as revenue " +
                "FROM Events e LEFT JOIN Orders o ON e.event_id = o.event_id " +
                "WHERE e.organizer_id = ? GROUP BY e.event_id";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, organizerId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new HashMap<>();
                    row.put("eventId", rs.getInt("event_id"));
                    row.put("orderCount", rs.getInt("order_count"));
                    row.put("revenue", rs.getDouble("revenue"));
                    result.add(row);
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to load organizer event stats for id=" + organizerId, e);
        }

        return result;
    }

    /**
     * Get daily revenue for a specific organizer (for organizer revenue chart).
     */
    public List<Map<String, Object>> getOrganizerRevenueByDays(int organizerId, int days) {
        List<Map<String, Object>> result = new ArrayList<>();
        String sql = "SELECT CONVERT(date, o.created_at) as order_date, " +
                "ISNULL(SUM(CASE WHEN o.status = 'paid' THEN o.final_amount ELSE 0 END), 0) as revenue, " +
                "COUNT(CASE WHEN o.status = 'paid' THEN 1 END) as ticket_count " +
                "FROM Orders o JOIN Events e ON o.event_id = e.event_id " +
                "WHERE e.organizer_id = ? AND o.created_at >= DATEADD(day, -?, GETDATE()) " +
                "GROUP BY CONVERT(date, o.created_at) " +
                "ORDER BY order_date";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, organizerId);
            ps.setInt(2, days);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new HashMap<>();
                    row.put("date", rs.getString("order_date"));
                    row.put("revenue", rs.getDouble("revenue"));
                    row.put("ticketCount", rs.getInt("ticket_count"));
                    result.add(row);
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to load organizer revenue by days", e);
        }
        return result;
    }

    /**
     * Get top N events by revenue (for admin reports).
     */
    public List<Map<String, Object>> getTopEventsByRevenue(int limit) {
        List<Map<String, Object>> result = new ArrayList<>();
        String sql = "SELECT TOP (?) e.event_id, e.title, e.status, " +
                "u.full_name as organizer_name, " +
                "ISNULL(SUM(CASE WHEN o.status = 'paid' THEN o.final_amount ELSE 0 END), 0) as revenue, " +
                "COUNT(CASE WHEN o.status = 'paid' THEN o.order_id END) as order_count " +
                "FROM Events e " +
                "LEFT JOIN Orders o ON e.event_id = o.event_id " +
                "LEFT JOIN Users u ON e.organizer_id = u.user_id " +
                "GROUP BY e.event_id, e.title, e.status, u.full_name " +
                "ORDER BY revenue DESC";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new HashMap<>();
                    row.put("eventId", rs.getInt("event_id"));
                    row.put("title", rs.getString("title"));
                    row.put("status", rs.getString("status"));
                    row.put("organizerName", rs.getString("organizer_name"));
                    row.put("revenue", rs.getDouble("revenue"));
                    row.put("orderCount", rs.getInt("order_count"));
                    result.add(row);
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to load top events by revenue", e);
        }
        return result;
    }

    /**
     * Fast count of pending events — for sidebar badge across all admin pages.
     */
    public int getPendingEventsCount() {
        String sql = "SELECT COUNT(*) FROM Events WHERE status = 'pending'";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getInt(1);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to get pending events count", e);
        }
        return 0;
    }

    /**
     * Get ticket type distribution for a specific organizer.
     */
    public List<Map<String, Object>> getOrganizerTicketDistribution(int organizerId) {
        List<Map<String, Object>> result = new ArrayList<>();
        String sql = "SELECT tt.name, COUNT(oi.order_item_id) as sold_count " +
                "FROM TicketTypes tt " +
                "JOIN OrderItems oi ON tt.ticket_type_id = oi.ticket_type_id " +
                "JOIN Events e ON tt.event_id = e.event_id " +
                "WHERE e.organizer_id = ? " +
                "GROUP BY tt.name ORDER BY sold_count DESC";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, organizerId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new HashMap<>();
                    row.put("name", rs.getString("name"));
                    row.put("count", rs.getInt("sold_count"));
                    result.add(row);
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to load organizer ticket distribution", e);
        }
        return result;
    }

    /**
     * Get hourly order distribution for a specific organizer.
     * Returns order counts grouped by hour of day (0-23).
     */
    public List<Map<String, Object>> getOrganizerHourlyDistribution(int organizerId) {
        List<Map<String, Object>> result = new ArrayList<>();
        String sql = "SELECT DATEPART(hour, o.created_at) as order_hour, COUNT(*) as order_count " +
                "FROM Orders o JOIN Events e ON o.event_id = e.event_id " +
                "WHERE e.organizer_id = ? AND o.status = 'paid' " +
                "GROUP BY DATEPART(hour, o.created_at) ORDER BY order_hour";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, organizerId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new HashMap<>();
                    row.put("hour", rs.getInt("order_hour"));
                    row.put("count", rs.getInt("order_count"));
                    result.add(row);
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to load organizer hourly distribution", e);
        }
        return result;
    }

    /**
     * Get stats for a single event: revenue, order count, ticket count, check-in count.
     */
    public Map<String, Object> getEventSpecificStats(int eventId) {
        Map<String, Object> stats = new HashMap<>();
        String sql = "SELECT " +
                "(SELECT ISNULL(SUM(final_amount), 0) FROM Orders WHERE event_id = ? AND status = 'paid') as revenue, " +
                "(SELECT COUNT(*) FROM Orders WHERE event_id = ?) as total_orders, " +
                "(SELECT COUNT(*) FROM Orders WHERE event_id = ? AND status = 'paid') as paid_orders, " +
                "(SELECT COUNT(*) " +
                "   FROM Tickets t " +
                "   JOIN OrderItems oi ON t.order_item_id = oi.order_item_id " +
                "   JOIN Orders o ON oi.order_id = o.order_id " +
                "  WHERE o.event_id = ?) as total_tickets, " +
                "(SELECT COUNT(*) " +
                "   FROM Tickets t " +
                "   JOIN OrderItems oi ON t.order_item_id = oi.order_item_id " +
                "   JOIN Orders o ON oi.order_id = o.order_id " +
                "  WHERE o.event_id = ? AND t.is_checked_in = 1) as checked_in";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            for (int i = 1; i <= 5; i++) ps.setInt(i, eventId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    stats.put("revenue", rs.getDouble("revenue"));
                    stats.put("totalOrders", rs.getInt("total_orders"));
                    stats.put("paidOrders", rs.getInt("paid_orders"));
                    stats.put("totalTickets", rs.getInt("total_tickets"));
                    stats.put("checkedIn", rs.getInt("checked_in"));
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to load event-specific stats for eventId=" + eventId, e);
        }
        return stats;
    }

    /**
     * Get daily revenue for a specific event (for event-scoped chart).
     */
    public List<Map<String, Object>> getEventRevenueByDays(int eventId, int days) {
        List<Map<String, Object>> result = new ArrayList<>();
        String sql = "SELECT CONVERT(date, o.created_at) as order_date, " +
                "ISNULL(SUM(CASE WHEN o.status = 'paid' THEN o.final_amount ELSE 0 END), 0) as revenue, " +
                "COUNT(CASE WHEN o.status = 'paid' THEN 1 END) as ticket_count " +
                "FROM Orders o " +
                "WHERE o.event_id = ? AND o.created_at >= DATEADD(day, -?, GETDATE()) " +
                "GROUP BY CONVERT(date, o.created_at) " +
                "ORDER BY order_date";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, eventId);
            ps.setInt(2, days);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new HashMap<>();
                    row.put("date", rs.getString("order_date"));
                    row.put("revenue", rs.getDouble("revenue"));
                    row.put("ticketCount", rs.getInt("ticket_count"));
                    result.add(row);
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to load event revenue by days for eventId=" + eventId, e);
        }
        return result;
    }

    // ================================================================
    // VOUCHER SETTLEMENT REPORTS
    // ================================================================

    /**
     * Admin: get totals for voucher subsidy reporting.
     * Returns: totalCustomerPaid, totalSystemSubsidy, totalEventDiscount,
     *          totalPlatformFee, totalOrganizerPayout, systemVoucherCount
     */
    public Map<String, Object> getVoucherSettlementStats() {
        Map<String, Object> stats = new HashMap<>();
        String sql = "SELECT " +
            "ISNULL(SUM(CASE WHEN status='paid' THEN final_amount ELSE 0 END), 0) as total_customer_paid, " +
            "ISNULL(SUM(CASE WHEN status='paid' THEN system_discount_amount ELSE 0 END), 0) as total_system_subsidy, " +
            "ISNULL(SUM(CASE WHEN status='paid' THEN event_discount_amount ELSE 0 END), 0) as total_event_discount, " +
            "ISNULL(SUM(CASE WHEN status='paid' THEN platform_fee_amount ELSE 0 END), 0) as total_platform_fee, " +
            "ISNULL(SUM(CASE WHEN status='paid' THEN organizer_payout_amount ELSE 0 END), 0) as total_organizer_payout, " +
            "COUNT(CASE WHEN status='paid' AND voucher_scope='SYSTEM' THEN 1 END) as system_voucher_count, " +
            "COUNT(CASE WHEN status='paid' AND voucher_scope='EVENT' THEN 1 END) as event_voucher_count " +
            "FROM Orders";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                stats.put("totalCustomerPaid", rs.getDouble("total_customer_paid"));
                stats.put("totalSystemSubsidy", rs.getDouble("total_system_subsidy"));
                stats.put("totalEventDiscount", rs.getDouble("total_event_discount"));
                stats.put("totalPlatformFee", rs.getDouble("total_platform_fee"));
                stats.put("totalOrganizerPayout", rs.getDouble("total_organizer_payout"));
                stats.put("systemVoucherCount", rs.getInt("system_voucher_count"));
                stats.put("eventVoucherCount", rs.getInt("event_voucher_count"));
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to load voucher settlement stats", e);
        }
        return stats;
    }

    /**
     * Organizer: get settlement breakdown for a specific organizer's events.
     * Shows face-value revenue, event discounts, system discounts, payout.
     */
    public Map<String, Object> getOrganizerSettlementStats(int organizerId) {
        Map<String, Object> stats = new HashMap<>();
        String sql = "SELECT " +
            "ISNULL(SUM(CASE WHEN o.status='paid' THEN o.total_amount ELSE 0 END), 0) as total_face_value, " +
            "ISNULL(SUM(CASE WHEN o.status='paid' THEN o.event_discount_amount ELSE 0 END), 0) as total_event_discount, " +
            "ISNULL(SUM(CASE WHEN o.status='paid' THEN o.system_discount_amount ELSE 0 END), 0) as total_system_discount, " +
            "ISNULL(SUM(CASE WHEN o.status='paid' THEN o.platform_fee_amount ELSE 0 END), 0) as total_platform_fee, " +
            "ISNULL(SUM(CASE WHEN o.status='paid' THEN o.organizer_payout_amount ELSE 0 END), 0) as total_payout " +
            "FROM Orders o JOIN Events e ON o.event_id = e.event_id " +
            "WHERE e.organizer_id = ?";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, organizerId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    stats.put("totalFaceValue", rs.getDouble("total_face_value"));
                    stats.put("totalEventDiscount", rs.getDouble("total_event_discount"));
                    stats.put("totalSystemDiscount", rs.getDouble("total_system_discount"));
                    stats.put("totalPlatformFee", rs.getDouble("total_platform_fee"));
                    stats.put("totalPayout", rs.getDouble("total_payout"));
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to load organizer settlement stats for id=" + organizerId, e);
        }
        return stats;
    }

    /**
     * Admin: per-event settlement breakdown for reports table.
     */
    public List<Map<String, Object>> getEventSettlementBreakdown(int limit) {
        List<Map<String, Object>> result = new ArrayList<>();
        String sql = "SELECT TOP (?) e.event_id, e.title, u.full_name as organizer_name, " +
            "ISNULL(SUM(CASE WHEN o.status='paid' THEN o.total_amount ELSE 0 END), 0) as face_value, " +
            "ISNULL(SUM(CASE WHEN o.status='paid' THEN o.final_amount ELSE 0 END), 0) as customer_paid, " +
            "ISNULL(SUM(CASE WHEN o.status='paid' THEN o.system_discount_amount ELSE 0 END), 0) as system_subsidy, " +
            "ISNULL(SUM(CASE WHEN o.status='paid' THEN o.event_discount_amount ELSE 0 END), 0) as event_discount, " +
            "ISNULL(SUM(CASE WHEN o.status='paid' THEN o.organizer_payout_amount ELSE 0 END), 0) as organizer_payout, " +
            "COUNT(CASE WHEN o.status='paid' THEN 1 END) as paid_orders " +
            "FROM Events e LEFT JOIN Orders o ON e.event_id = o.event_id " +
            "LEFT JOIN Users u ON e.organizer_id = u.user_id " +
            "GROUP BY e.event_id, e.title, u.full_name " +
            "ORDER BY face_value DESC";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new HashMap<>();
                    row.put("eventId", rs.getInt("event_id"));
                    row.put("title", rs.getString("title"));
                    row.put("organizerName", rs.getString("organizer_name"));
                    row.put("faceValue", rs.getDouble("face_value"));
                    row.put("customerPaid", rs.getDouble("customer_paid"));
                    row.put("systemSubsidy", rs.getDouble("system_subsidy"));
                    row.put("eventDiscount", rs.getDouble("event_discount"));
                    row.put("organizerPayout", rs.getDouble("organizer_payout"));
                    row.put("paidOrders", rs.getInt("paid_orders"));
                    result.add(row);
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to load event settlement breakdown", e);
        }
        return result;
    }
}
