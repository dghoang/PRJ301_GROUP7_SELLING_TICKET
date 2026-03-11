package com.sellingticket.dao;

import com.sellingticket.util.DBContext;
import java.sql.*;
import java.util.HashMap;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * DAO for SiteSettings — simple key-value store for admin configuration.
 * Thread-safe with in-memory cache refreshed on write.
 */
public class SiteSettingsDAO extends DBContext {

    private static final Logger LOGGER = Logger.getLogger(SiteSettingsDAO.class.getName());
    private static volatile Map<String, String> cache = null;
    private static final Object LOCK = new Object();

    /** Get a setting value, with fallback default if key missing. */
    public String get(String key, String defaultValue) {
        Map<String, String> all = getAllCached();
        return all.getOrDefault(key, defaultValue);
    }

    public boolean getBoolean(String key, boolean defaultValue) {
        String val = get(key, null);
        if (val == null) return defaultValue;
        return "true".equalsIgnoreCase(val) || "1".equals(val);
    }

    public int getInt(String key, int defaultValue) {
        String val = get(key, null);
        if (val == null) return defaultValue;
        try { return Integer.parseInt(val); } catch (NumberFormatException e) { return defaultValue; }
    }

    /** Set a setting value (upsert). Clears cache. */
    public boolean set(String key, String value) {
        String sql = "MERGE SiteSettings AS target "
                   + "USING (SELECT ? AS setting_key) AS source ON target.setting_key = source.setting_key "
                   + "WHEN MATCHED THEN UPDATE SET setting_value = ?, updated_at = GETDATE() "
                   + "WHEN NOT MATCHED THEN INSERT (setting_key, setting_value) VALUES (?, ?);";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, key);
            ps.setString(2, value);
            ps.setString(3, key);
            ps.setString(4, value);
            ps.executeUpdate();
            clearCache();
            return true;
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to set setting: " + key, e);
        }
        return false;
    }

    /** Batch update multiple settings in one transaction. */
    public boolean setAll(Map<String, String> settings) {
        String sql = "MERGE SiteSettings AS target "
                   + "USING (SELECT ? AS setting_key) AS source ON target.setting_key = source.setting_key "
                   + "WHEN MATCHED THEN UPDATE SET setting_value = ?, updated_at = GETDATE() "
                   + "WHEN NOT MATCHED THEN INSERT (setting_key, setting_value) VALUES (?, ?);";
        try (Connection conn = getConnection()) {
            conn.setAutoCommit(false);
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                for (Map.Entry<String, String> entry : settings.entrySet()) {
                    ps.setString(1, entry.getKey());
                    ps.setString(2, entry.getValue());
                    ps.setString(3, entry.getKey());
                    ps.setString(4, entry.getValue());
                    ps.addBatch();
                }
                ps.executeBatch();
            }
            conn.commit();
            conn.setAutoCommit(true);
            clearCache();
            return true;
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to batch set settings", e);
        }
        return false;
    }

    /** Get all settings (cached). */
    public Map<String, String> getAllCached() {
        if (cache != null) return cache;
        synchronized (LOCK) {
            if (cache != null) return cache;
            Map<String, String> map = new HashMap<>();
            String sql = "SELECT setting_key, setting_value FROM SiteSettings";
            try (Connection conn = getConnection();
                 PreparedStatement ps = conn.prepareStatement(sql);
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    map.put(rs.getString("setting_key"), rs.getString("setting_value"));
                }
            } catch (Exception e) {
                LOGGER.log(Level.WARNING, "SiteSettings table may not exist yet — using defaults", e);
            }
            cache = map;
            return cache;
        }
    }

    public static void clearCache() {
        synchronized (LOCK) {
            cache = null;
        }
    }
}
