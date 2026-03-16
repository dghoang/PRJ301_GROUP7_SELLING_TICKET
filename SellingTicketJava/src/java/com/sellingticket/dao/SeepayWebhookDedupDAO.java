package com.sellingticket.dao;

import com.sellingticket.util.DBContext;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Persistent idempotency store for SePay webhook transaction IDs.
 */
public class SeepayWebhookDedupDAO extends DBContext {

    private static final Logger LOGGER = Logger.getLogger(SeepayWebhookDedupDAO.class.getName());

    public boolean isProcessed(String sepayTransactionId) {
        String sql = "SELECT 1 FROM SeepayWebhookDedup WHERE sepay_transaction_id = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, sepayTransactionId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to check SePay dedup key", e);
        }
        return false;
    }

    /**
     * Insert transaction ID if it does not exist.
     *
     * @return true if inserted, false if already exists or failed
     */
    public boolean markProcessed(String sepayTransactionId, String orderCode, String processResult) {
        String sql = "INSERT INTO SeepayWebhookDedup (sepay_transaction_id, order_code, process_result) VALUES (?, ?, ?)";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, sepayTransactionId);
            ps.setString(2, orderCode);
            ps.setString(3, processResult);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            // Duplicate key is expected on replay; treat as already processed.
            String msg = e.getMessage();
            if (msg != null && msg.toLowerCase().contains("duplicate")) {
                return false;
            }
            LOGGER.log(Level.SEVERE, "Failed to mark SePay dedup key", e);
            return false;
        }
    }
}
