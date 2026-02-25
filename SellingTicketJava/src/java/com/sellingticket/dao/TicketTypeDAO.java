package com.sellingticket.dao;

import com.sellingticket.model.TicketType;
import com.sellingticket.util.DBContext;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class TicketTypeDAO extends DBContext {

    public List<TicketType> getTicketTypesByEventId(int eventId) {
        List<TicketType> ticketTypes = new ArrayList<>();
        String sql = "SELECT * FROM TicketTypes WHERE event_id = ? AND is_active = 1 ORDER BY price ASC";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, eventId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                TicketType tt = new TicketType();
                tt.setTicketTypeId(rs.getInt("ticket_type_id"));
                tt.setEventId(rs.getInt("event_id"));
                tt.setName(rs.getString("name"));
                tt.setDescription(rs.getString("description"));
                tt.setPrice(rs.getDouble("price"));
                tt.setQuantity(rs.getInt("quantity"));
                tt.setSoldQuantity(rs.getInt("sold_quantity"));
                tt.setSaleStart(rs.getTimestamp("sale_start"));
                tt.setSaleEnd(rs.getTimestamp("sale_end"));
                tt.setActive(rs.getBoolean("is_active"));
                tt.setCreatedAt(rs.getTimestamp("created_at"));
                ticketTypes.add(tt);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return ticketTypes;
    }

    public TicketType getTicketTypeById(int ticketTypeId) {
        String sql = "SELECT * FROM TicketTypes WHERE ticket_type_id = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, ticketTypeId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                TicketType tt = new TicketType();
                tt.setTicketTypeId(rs.getInt("ticket_type_id"));
                tt.setEventId(rs.getInt("event_id"));
                tt.setName(rs.getString("name"));
                tt.setDescription(rs.getString("description"));
                tt.setPrice(rs.getDouble("price"));
                tt.setQuantity(rs.getInt("quantity"));
                tt.setSoldQuantity(rs.getInt("sold_quantity"));
                tt.setActive(rs.getBoolean("is_active"));
                return tt;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean createTicketType(TicketType ticketType) {
        String sql = "INSERT INTO TicketTypes (event_id, name, description, price, quantity, sale_start, sale_end) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, ticketType.getEventId());
            ps.setString(2, ticketType.getName());
            ps.setString(3, ticketType.getDescription());
            ps.setDouble(4, ticketType.getPrice());
            ps.setInt(5, ticketType.getQuantity());
            ps.setTimestamp(6, ticketType.getSaleStart() != null ? new Timestamp(ticketType.getSaleStart().getTime()) : null);
            ps.setTimestamp(7, ticketType.getSaleEnd() != null ? new Timestamp(ticketType.getSaleEnd().getTime()) : null);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean updateSoldQuantity(int ticketTypeId, int quantity) {
        String sql = "UPDATE TicketTypes SET sold_quantity = sold_quantity + ? WHERE ticket_type_id = ? " +
                     "AND (quantity - sold_quantity) >= ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, quantity);
            ps.setInt(2, ticketTypeId);
            ps.setInt(3, quantity);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public double getMinPriceByEventId(int eventId) {
        String sql = "SELECT MIN(price) as min_price FROM TicketTypes WHERE event_id = ? AND is_active = 1";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, eventId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getDouble("min_price");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    // ========================
    // NEW CRUD METHODS
    // ========================

    /**
     * Update an existing ticket type
     */
    public boolean updateTicketType(TicketType ticketType) {
        String sql = "UPDATE TicketTypes SET name = ?, description = ?, price = ?, quantity = ?, " +
                     "sale_start = ?, sale_end = ?, is_active = ? WHERE ticket_type_id = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, ticketType.getName());
            ps.setString(2, ticketType.getDescription());
            ps.setDouble(3, ticketType.getPrice());
            ps.setInt(4, ticketType.getQuantity());
            ps.setTimestamp(5, ticketType.getSaleStart() != null ? new Timestamp(ticketType.getSaleStart().getTime()) : null);
            ps.setTimestamp(6, ticketType.getSaleEnd() != null ? new Timestamp(ticketType.getSaleEnd().getTime()) : null);
            ps.setBoolean(7, ticketType.isActive());
            ps.setInt(8, ticketType.getTicketTypeId());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Soft delete a ticket type (set is_active = false)
     */
    public boolean deleteTicketType(int ticketTypeId) {
        String sql = "UPDATE TicketTypes SET is_active = 0 WHERE ticket_type_id = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, ticketTypeId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Check ticket availability
     */
    public boolean checkAvailability(int ticketTypeId, int requestedQuantity) {
        String sql = "SELECT (quantity - sold_quantity) as available FROM TicketTypes WHERE ticket_type_id = ? AND is_active = 1";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, ticketTypeId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt("available") >= requestedQuantity;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }
}
