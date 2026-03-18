package com.sellingticket.dao;

import com.sellingticket.model.PageResult;
import com.sellingticket.model.User;
import com.sellingticket.util.DBContext;
import com.sellingticket.util.PasswordUtil;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

public class UserDAO extends DBContext {

    private static final Logger LOGGER = Logger.getLogger(UserDAO.class.getName());

    private User mapResultSetToUser(ResultSet rs) throws SQLException {
        User user = new User();
        user.setUserId(rs.getInt("user_id"));
        user.setEmail(rs.getString("email"));
        user.setFullName(rs.getString("full_name"));
        user.setPhone(rs.getString("phone"));
        user.setRole(rs.getString("role"));
        user.setAvatar(rs.getString("avatar"));
        user.setActive(rs.getBoolean("is_active"));
        user.setCreatedAt(rs.getTimestamp("created_at"));
        try { user.setDeleted(rs.getBoolean("is_deleted")); } catch (SQLException ignored) {}
        if (user.isDeleted()) {
            // Deleted accounts must never be treated as active in business/UI logic.
            user.setActive(false);
        }
        try {
            String hash = rs.getString("password_hash");
            user.setOauthUser("OAUTH_NO_PASSWORD".equals(hash));
        } catch (SQLException ignored) {}
        // Extended fields (safe: skip if column doesn't exist)
        try { user.setGender(rs.getString("gender")); } catch (SQLException ignored) {}
        try { user.setDateOfBirth(rs.getDate("date_of_birth")); } catch (SQLException ignored) {}
        try { user.setBio(rs.getString("bio")); } catch (SQLException ignored) {}
        try { user.setWebsite(rs.getString("website")); } catch (SQLException ignored) {}
        try { user.setSocialFacebook(rs.getString("social_facebook")); } catch (SQLException ignored) {}
        try { user.setSocialInstagram(rs.getString("social_instagram")); } catch (SQLException ignored) {}
        try { user.setUpdatedAt(rs.getTimestamp("updated_at")); } catch (SQLException ignored) {}
        return user;
    }

    public User getUserByEmail(String email) {
        String sql = "SELECT * FROM Users WHERE email = ? AND is_active = 1 AND (is_deleted = 0 OR is_deleted IS NULL)";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email.toLowerCase().trim());
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return mapResultSetToUser(rs);
        } catch (Exception e) {
            LOGGER.log(Level.WARNING, "Database error in UserDAO.getUserByEmail", e);
        }
        return null;
    }

    public User login(String email, String password) {
        String sql = "SELECT * FROM Users WHERE email = ? AND is_active = 1 AND (is_deleted = 0 OR is_deleted IS NULL)";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                String hash = rs.getString("password_hash");
                if (PasswordUtil.checkPassword(password, hash)) {
                    return mapResultSetToUser(rs);
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.WARNING, "Database error in UserDAO.login", e);
        }
        return null;
    }

    /** Update last login timestamp and IP address for audit/security. */
    public boolean updateLastLogin(int userId, String ip) {
        String sql = "UPDATE Users SET last_login_at = GETDATE(), last_login_ip = ? WHERE user_id = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, ip);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            LOGGER.log(Level.WARNING, "Failed to update last login for userId: " + userId, e);
        }
        return false;
    }

    public boolean register(String email, String password, String fullName, String phone) {
        String sql = "INSERT INTO Users (email, password_hash, full_name, phone, role) VALUES (?, ?, ?, ?, 'customer')";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            ps.setString(2, PasswordUtil.hashPassword(password));
            ps.setString(3, fullName);
            ps.setString(4, phone);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Database error in UserDAO.register", e);
        }
        return false;
    }

    public boolean registerFull(String email, String password, String fullName, String phone, String gender, java.util.Date dob) {
        String sql = "INSERT INTO Users (email, password_hash, full_name, phone, gender, date_of_birth, role) VALUES (?, ?, ?, ?, ?, ?, 'customer')";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            ps.setString(2, PasswordUtil.hashPassword(password));
            ps.setString(3, fullName);
            ps.setString(4, phone);
            ps.setString(5, gender);
            ps.setDate(6, dob != null ? new java.sql.Date(dob.getTime()) : null);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Database error in UserDAO.registerFull", e);
        }
        return false;
    }

    /**
     * Register a user from OAuth provider (Google).
     * No password required — stores a non-matchable placeholder hash.
     */
    public boolean registerOAuth(String email, String fullName, String avatar) {
        String sql = "INSERT INTO Users (email, password_hash, full_name, avatar, role) VALUES (?, ?, ?, ?, 'customer')";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            ps.setString(2, "OAUTH_NO_PASSWORD");
            ps.setString(3, fullName);
            ps.setString(4, avatar);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Database error in UserDAO.registerOAuth", e);
        }
        return false;
    }

    public boolean isEmailExists(String email) {
        String sql = "SELECT 1 FROM Users WHERE email = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Database error in UserDAO.isEmailExists", e);
        }
        return false;
    }

    /** Get user by email regardless of active status (for OAuth deactivation check). */
    public User getUserByEmailAny(String email) {
        String sql = "SELECT * FROM Users WHERE email = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email.toLowerCase().trim());
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return mapResultSetToUser(rs);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Database error in UserDAO.getUserByEmailAny", e);
        }
        return null;
    }

    public User getUserById(int userId) {
        String sql = "SELECT * FROM Users WHERE user_id = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return mapResultSetToUser(rs);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Database error in UserDAO.getUserById", e);
        }
        return null;
    }

    /**
     * Get all users ordered by creation date (newest first).
     */
    public List<User> getAllUsers() {
        List<User> users = new ArrayList<>();
        String sql = "SELECT * FROM Users ORDER BY created_at DESC";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                users.add(mapResultSetToUser(rs));
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to get all users", e);
        }
        return users;
    }

    /**
     * Get all active users with a specific role.
     */
    public List<User> getUsersByRole(String role) {
        List<User> users = new ArrayList<>();
        String sql = "SELECT * FROM Users WHERE role = ? AND is_active = 1 AND (is_deleted = 0 OR is_deleted IS NULL) ORDER BY created_at DESC";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, role);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                users.add(mapResultSetToUser(rs));
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to get users by role: " + role, e);
        }
        return users;
    }

    public boolean updateUser(User user) {
        String sql = "UPDATE Users SET full_name = ?, phone = ?, gender = ?, date_of_birth = ?, avatar = ?, updated_at = GETDATE() WHERE user_id = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, user.getFullName());
            ps.setString(2, user.getPhone());
            ps.setString(3, user.getGender());
            if (user.getDateOfBirth() != null) {
                ps.setDate(4, new java.sql.Date(user.getDateOfBirth().getTime()));
            } else {
                ps.setNull(4, Types.DATE);
            }
            ps.setString(5, user.getAvatar());
            ps.setInt(6, user.getUserId());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to update user: " + user.getUserId(), e);
        }
        return false;
    }

    public boolean updateOrganizerProfile(User user) {
        String sql = "UPDATE Users SET full_name = ?, phone = ?, bio = ?, website = ?, " +
                     "social_facebook = ?, social_instagram = ?, avatar = ?, updated_at = GETDATE() WHERE user_id = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, user.getFullName());
            ps.setString(2, user.getPhone());
            ps.setString(3, user.getBio());
            ps.setString(4, user.getWebsite());
            ps.setString(5, user.getSocialFacebook());
            ps.setString(6, user.getSocialInstagram());
            ps.setString(7, user.getAvatar());
            ps.setInt(8, user.getUserId());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to update organizer profile: " + user.getUserId(), e);
        }
        return false;
    }

    public boolean changePassword(int userId, String oldPassword, String newPassword) {
        String currentHash = getUserPasswordHash(userId);
        if (currentHash == null || !PasswordUtil.checkPassword(oldPassword, currentHash)) {
            return false;
        }
        String sql = "UPDATE Users SET password_hash = ?, password_changed_at = GETDATE(), updated_at = GETDATE() " +
                     "WHERE user_id = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, PasswordUtil.hashPassword(newPassword));
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to change password for user: " + userId, e);
        }
        return false;
    }

    private String getUserPasswordHash(int userId) {
        String sql = "SELECT password_hash FROM Users WHERE user_id = ? AND is_active = 1 AND (is_deleted = 0 OR is_deleted IS NULL)";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getString("password_hash");
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to get password hash for user: " + userId, e);
        }
        return null;
    }

    public int getTotalUsers() {
        String sql = "SELECT COUNT(*) FROM Users";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getInt(1);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to get total users count", e);
        }
        return 0;
    }

    public boolean updateUserRole(int userId, String role) {
        String sql = "UPDATE Users SET role = ?, updated_at = GETDATE() WHERE user_id = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, role);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to update role for user: " + userId, e);
        }
        return false;
    }

    public boolean deactivateUser(int userId) {
        String sql = "UPDATE Users SET is_active = 0, updated_at = GETDATE() WHERE user_id = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to deactivate user: " + userId, e);
        }
        return false;
    }

    public boolean activateUser(int userId) {
        String sql = "UPDATE Users SET is_active = 1, updated_at = GETDATE() WHERE user_id = ? AND (is_deleted = 0 OR is_deleted IS NULL)";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to activate user: " + userId, e);
        }
        return false;
    }

    /**
     * Search users by keyword across name, email and phone.
     * Uses parameterized query — safe from SQL injection.
     */
    public List<User> searchUsers(String keyword) {
        List<User> users = new ArrayList<>();
        String sql = "SELECT * FROM Users WHERE (full_name LIKE ? OR email LIKE ? OR phone LIKE ?) ORDER BY created_at DESC";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            String pattern = "%" + keyword + "%";
            ps.setString(1, pattern);
            ps.setString(2, pattern);
            ps.setString(3, pattern);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    users.add(mapResultSetToUser(rs));
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to search users with keyword: " + keyword, e);
        }
        return users;
    }

    // ========================
    // PAGED SEARCH
    // ========================

    /**
     * Search users with pagination, keyword, role filter, and active status.
     * Supports multi-role checkbox filter.
     */
    public PageResult<User> searchUsersPaged(String keyword, String[] roles,
            Boolean isActive, int page, int pageSize) {

        StringBuilder where = new StringBuilder("WHERE 1=1 ");
        List<Object> params = new ArrayList<>();

        if (keyword != null && !keyword.trim().isEmpty()) {
            where.append("AND (full_name LIKE ? OR email LIKE ? OR phone LIKE ?) ");
            String kw = "%" + keyword.trim() + "%";
            params.add(kw); params.add(kw); params.add(kw);
        }
        if (roles != null && roles.length > 0) {
            where.append("AND role IN (");
            for (int i = 0; i < roles.length; i++) {
                where.append(i > 0 ? ",?" : "?");
                params.add(roles[i]);
            }
            where.append(") ");
        }
        if (isActive != null) {
            where.append("AND is_active = ? ");
            params.add(isActive ? 1 : 0);
        }

        String dataSql = "SELECT * FROM Users " + where.toString() +
                "ORDER BY created_at DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";
        String countSql = "SELECT COUNT(*) FROM Users " + where.toString();

        // Execute count query
        int totalItems = 0;
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(countSql)) {
            int idx = 1;
            for (Object p : params) {
                if (p instanceof String) ps.setString(idx++, (String) p);
                else if (p instanceof Integer) ps.setInt(idx++, (Integer) p);
            }
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) totalItems = rs.getInt(1);
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to count users", e);
        }

        // Execute data query
        int safePage = Math.max(1, page);
        int safeSize = Math.max(1, Math.min(100, pageSize));
        List<User> items = new ArrayList<>();
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(dataSql)) {
            int idx = 1;
            for (Object p : params) {
                if (p instanceof String) ps.setString(idx++, (String) p);
                else if (p instanceof Integer) ps.setInt(idx++, (Integer) p);
            }
            ps.setInt(idx++, (safePage - 1) * safeSize);
            ps.setInt(idx, safeSize);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    items.add(mapResultSetToUser(rs));
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to search users paged", e);
        }

        return new PageResult<>(items, totalItems, safePage, safeSize);
    }
}
