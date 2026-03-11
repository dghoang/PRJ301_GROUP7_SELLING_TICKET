package com.sellingticket.service;

import com.sellingticket.util.DBContext;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Computes customer VIP tier from order history.
 * 
 * Tiers:
 *   vip_special  (💎) — Total spending ≥ 5,000,000₫ — priority 100
 *   vip          (🥇) — ≥5 paid orders OR spending ≥ 2,000,000₫ — priority 80
 *   regular      (🥈) — ≥1 paid order — priority 50
 *   registered   (🥉) — Account exists, 0 paid orders — priority 20
 *   guest        (👤) — Not logged in — priority 0
 */
public class CustomerTierService extends DBContext {

    private static final Logger LOGGER = Logger.getLogger(CustomerTierService.class.getName());

    public static class TierInfo {
        public final String tier;
        public final int priorityScore;
        public final long totalSpent;
        public final int orderCount;

        public TierInfo(String tier, int priorityScore, long totalSpent, int orderCount) {
            this.tier = tier;
            this.priorityScore = priorityScore;
            this.totalSpent = totalSpent;
            this.orderCount = orderCount;
        }
    }

    public TierInfo getTier(int userId) {
        String sql = "SELECT ISNULL(SUM(total_amount), 0) AS total_spent, COUNT(*) AS order_count "
                   + "FROM Orders WHERE user_id = ? AND status = 'paid'";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                long totalSpent = rs.getLong("total_spent");
                int orderCount = rs.getInt("order_count");
                return computeTier(totalSpent, orderCount);
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to compute customer tier", e);
        }
        return new TierInfo("registered", 20, 0, 0);
    }

    private TierInfo computeTier(long totalSpent, int orderCount) {
        if (totalSpent >= 5_000_000) return new TierInfo("vip_special", 100, totalSpent, orderCount);
        if (orderCount >= 5 || totalSpent >= 2_000_000) return new TierInfo("vip", 80, totalSpent, orderCount);
        if (orderCount >= 1) return new TierInfo("regular", 50, totalSpent, orderCount);
        return new TierInfo("registered", 20, totalSpent, orderCount);
    }

    public static String getTierLabel(String tier) {
        switch (tier != null ? tier : "") {
            case "vip_special": return "💎 VIP Đặc biệt";
            case "vip": return "🥇 VIP";
            case "regular": return "🥈 Khách thường";
            case "registered": return "🥉 Đã đăng ký";
            default: return "👤 Khách";
        }
    }

    public static String getTierBadgeStyle(String tier) {
        switch (tier != null ? tier : "") {
            case "vip_special": return "background:linear-gradient(135deg,#f59e0b,#f97316);color:white;";
            case "vip": return "background:linear-gradient(135deg,#3b82f6,#6366f1);color:white;";
            case "regular": return "background:linear-gradient(135deg,#10b981,#06b6d4);color:white;";
            default: return "background:rgba(0,0,0,0.05);color:#666;";
        }
    }

    /** Map VIP tier to default ticket priority. */
    public static String tierToPriority(String tier) {
        switch (tier != null ? tier : "") {
            case "vip_special": return "urgent";
            case "vip": return "high";
            case "regular": return "normal";
            default: return "low";
        }
    }
}
