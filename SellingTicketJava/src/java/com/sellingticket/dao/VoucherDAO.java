package com.sellingticket.dao;

import com.sellingticket.model.Voucher;
import com.sellingticket.util.DBContext;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * VoucherDAO — full CRUD for event vouchers/discount codes.
 */
public class VoucherDAO extends DBContext {

    private static final Logger LOGGER = Logger.getLogger(VoucherDAO.class.getName());

    private Voucher mapResultSetToVoucher(ResultSet rs) throws SQLException {
        Voucher v = new Voucher();
        v.setVoucherId(rs.getInt("voucher_id"));
        v.setEventId(rs.getInt("event_id"));
        v.setOrganizerId(rs.getInt("organizer_id"));
        v.setCode(rs.getString("code"));
        v.setDiscountType(rs.getString("discount_type"));
        v.setDiscountValue(rs.getDouble("discount_value"));
        v.setMinOrderAmount(rs.getDouble("min_order_amount"));
        v.setMaxDiscount(rs.getDouble("max_discount"));
        v.setUsageLimit(rs.getInt("usage_limit"));
        v.setUsedCount(rs.getInt("used_count"));
        v.setStartDate(rs.getTimestamp("start_date"));
        v.setEndDate(rs.getTimestamp("end_date"));
        v.setActive(rs.getBoolean("is_active"));
        v.setCreatedAt(rs.getTimestamp("created_at"));
        try { v.setVoucherScope(rs.getString("voucher_scope")); } catch (SQLException ignored) {}
        try { v.setFundSource(rs.getString("fund_source")); } catch (SQLException ignored) {}
        try { v.setEventName(rs.getString("event_name")); } catch (SQLException ignored) {}
        return v;
    }

    public List<Voucher> getVouchersByOrganizer(int organizerId) {
        List<Voucher> vouchers = new ArrayList<>();
        String sql = "SELECT v.*, e.title as event_name FROM Vouchers v " +
                     "LEFT JOIN Events e ON v.event_id = e.event_id " +
                     "WHERE v.organizer_id = ? AND v.event_id IS NOT NULL AND v.event_id > 0 " +
                     "AND (v.is_deleted = 0 OR v.is_deleted IS NULL) ORDER BY v.created_at DESC";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, organizerId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) vouchers.add(mapResultSetToVoucher(rs));
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error getting vouchers by organizer", e);
        }
        return vouchers;
    }

    /**
     * Admin: get all system vouchers only (global scope).
     */
    public List<Voucher> getSystemVouchers() {
        List<Voucher> vouchers = new ArrayList<>();
        String sql = "SELECT v.*, e.title as event_name FROM Vouchers v " +
                     "LEFT JOIN Events e ON v.event_id = e.event_id " +
                     "WHERE (v.event_id IS NULL OR v.event_id <= 0) " +
                     "AND (v.is_deleted = 0 OR v.is_deleted IS NULL) ORDER BY v.created_at DESC";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ResultSet rs = ps.executeQuery();
            while (rs.next()) vouchers.add(mapResultSetToVoucher(rs));
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error getting system vouchers", e);
        }
        return vouchers;
    }

    public Voucher getVoucherById(int voucherId) {
        String sql = "SELECT v.*, e.title as event_name FROM Vouchers v " +
                     "LEFT JOIN Events e ON v.event_id = e.event_id " +
                     "WHERE v.voucher_id = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, voucherId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return mapResultSetToVoucher(rs);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error getting voucher by id", e);
        }
        return null;
    }

    public Voucher getVoucherByCode(String code) {
        String sql = "SELECT v.*, e.title as event_name FROM Vouchers v " +
                     "LEFT JOIN Events e ON v.event_id = e.event_id " +
                     "WHERE v.code = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, code.toUpperCase().trim());
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return mapResultSetToVoucher(rs);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error getting voucher by code", e);
        }
        return null;
    }

    public boolean createVoucher(Voucher v) {
        String sql = "INSERT INTO Vouchers (event_id, organizer_id, code, discount_type, discount_value, " +
                     "min_order_amount, max_discount, usage_limit, start_date, end_date, voucher_scope, fund_source) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            if (v.getEventId() > 0) {
                ps.setInt(1, v.getEventId());
            } else {
                ps.setNull(1, Types.INTEGER);
            }
            ps.setInt(2, v.getOrganizerId());
            ps.setString(3, v.getCode().toUpperCase().trim());
            ps.setString(4, v.getDiscountType());
            ps.setDouble(5, v.getDiscountValue());
            ps.setDouble(6, v.getMinOrderAmount());
            ps.setDouble(7, v.getMaxDiscount());
            ps.setInt(8, v.getUsageLimit());
            ps.setTimestamp(9, v.getStartDate() != null ? new Timestamp(v.getStartDate().getTime()) : null);
            ps.setTimestamp(10, v.getEndDate() != null ? new Timestamp(v.getEndDate().getTime()) : null);
            ps.setString(11, v.getVoucherScope() != null ? v.getVoucherScope() : (v.getEventId() > 0 ? "EVENT" : "SYSTEM"));
            ps.setString(12, v.getFundSource() != null ? v.getFundSource() : (v.getEventId() > 0 ? "ORGANIZER" : "SYSTEM"));
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error creating voucher", e);
        }
        return false;
    }

    public boolean updateVoucher(Voucher v) {
        String sql = "UPDATE Vouchers SET code = ?, discount_type = ?, discount_value = ?, " +
                     "min_order_amount = ?, max_discount = ?, usage_limit = ?, " +
                     "start_date = ?, end_date = ?, is_active = ? WHERE voucher_id = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, v.getCode().toUpperCase().trim());
            ps.setString(2, v.getDiscountType());
            ps.setDouble(3, v.getDiscountValue());
            ps.setDouble(4, v.getMinOrderAmount());
            ps.setDouble(5, v.getMaxDiscount());
            ps.setInt(6, v.getUsageLimit());
            ps.setTimestamp(7, v.getStartDate() != null ? new Timestamp(v.getStartDate().getTime()) : null);
            ps.setTimestamp(8, v.getEndDate() != null ? new Timestamp(v.getEndDate().getTime()) : null);
            ps.setBoolean(9, v.isActive());
            ps.setInt(10, v.getVoucherId());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error updating voucher", e);
        }
        return false;
    }

    public boolean deleteVoucher(int voucherId) {
        String sql = "UPDATE Vouchers SET is_deleted = 1, is_active = 0 WHERE voucher_id = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, voucherId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error soft-deleting voucher", e);
        }
        return false;
    }

    public boolean incrementUsedCount(int voucherId) {
        String sql = "UPDATE Vouchers SET used_count = used_count + 1 WHERE voucher_id = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, voucherId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error incrementing used count", e);
        }
        return false;
    }
}
