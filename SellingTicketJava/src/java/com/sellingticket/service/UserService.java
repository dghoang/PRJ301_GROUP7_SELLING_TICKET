package com.sellingticket.service;

import com.sellingticket.dao.UserDAO;
import com.sellingticket.model.PageResult;
import com.sellingticket.model.User;
import java.util.List;
import java.util.Date;
import java.time.LocalDate;
import java.time.ZoneId;

/**
 * UserService - Business logic layer for User operations
 * Handles authentication, registration, profile management
 */
public class UserService {

    private static final int MIN_REGISTER_AGE = 16;
    private static final ZoneId ZONE_VN = ZoneId.of("Asia/Ho_Chi_Minh");

    private final UserDAO userDAO;

    public UserService() {
        this.userDAO = new UserDAO();
    }

    // ========================
    // AUTHENTICATION
    // ========================

    public User authenticate(String email, String password) {
        if (email == null || email.trim().isEmpty() || password == null || password.isEmpty()) {
            return null;
        }
        return userDAO.login(email.trim().toLowerCase(), password);
    }

    /** Update last login timestamp and IP. Call after successful login. */
    public void updateLastLogin(int userId, String ip) {
        userDAO.updateLastLogin(userId, ip);
    }

    // ========================
    // REGISTRATION
    // ========================

    public boolean register(String email, String password, String fullName, String phone) {
        if (!isValidEmail(email) || !isValidPassword(password)) {
            return false;
        }
        if (fullName == null || fullName.trim().isEmpty()) {
            return false;
        }
        if (userDAO.isEmailExists(email.trim().toLowerCase())) {
            return false;
        }
        return userDAO.register(email.trim().toLowerCase(), password, fullName.trim(), phone);
    }

    public boolean registerFull(String email, String password, String fullName, String phone, String gender, Date dob) {
        if (!isValidEmail(email) || !isValidPassword(password)) {
            return false;
        }
        if (!isValidDateOfBirth(dob)) {
            return false;
        }
        if (userDAO.isEmailExists(email.trim().toLowerCase())) {
            return false;
        }
        return userDAO.registerFull(email.trim().toLowerCase(), password, fullName.trim(), phone, gender, dob);
    }

    /**
     * Register a user from OAuth provider (Google).
     * Bypasses password validation — OAuth users authenticate via provider, not password.
     */
    public boolean registerOAuth(String email, String fullName, String avatar) {
        if (!isValidEmail(email)) return false;
        if (fullName == null || fullName.trim().isEmpty()) return false;
        if (userDAO.isEmailExists(email.trim().toLowerCase())) return false;
        return userDAO.registerOAuth(email.trim().toLowerCase(), fullName.trim(), avatar);
    }

    public boolean isEmailExists(String email) {
        if (email == null || email.trim().isEmpty()) return false;
        return userDAO.isEmailExists(email.trim().toLowerCase());
    }

    // ========================
    // PROFILE MANAGEMENT
    // ========================

    public User getUserById(int userId) {
        return userDAO.getUserById(userId);
    }

    public User getUserByEmail(String email) {
        if (email == null || email.trim().isEmpty()) return null;
        return userDAO.getUserByEmail(email);
    }

    /** Get user by email regardless of active status (for OAuth deactivation check). */
    public User getUserByEmailAny(String email) {
        if (email == null || email.trim().isEmpty()) return null;
        return userDAO.getUserByEmailAny(email);
    }

    /** Check if user is an OAuth-only user (no password set). */
    public boolean isOAuthUser(int userId) {
        User user = userDAO.getUserById(userId);
        return user != null && user.isOauthUser();
    }

    public boolean updateProfile(User user) {
        return userDAO.updateUser(user);
    }

    public boolean updateOrganizerProfile(User user) {
        return userDAO.updateOrganizerProfile(user);
    }

    public boolean changePassword(int userId, String oldPassword, String newPassword) {
        if (!isValidPassword(newPassword)) {
            return false;
        }
        return userDAO.changePassword(userId, oldPassword, newPassword);
    }

    // ========================
    // ADMIN OPERATIONS
    // ========================

    public List<User> getAllUsers() {
        return userDAO.getAllUsers();
    }

    public boolean updateUserRole(int userId, String role) {
        return userDAO.updateUserRole(userId, role);
    }

    public boolean deactivateUser(int userId) {
        return userDAO.deactivateUser(userId);
    }

    public boolean activateUser(int userId) {
        return userDAO.activateUser(userId);
    }

    public List<User> searchUsers(String keyword) {
        return userDAO.searchUsers(keyword);
    }

    /**
     * Paginated user search with keyword, role filter, and active status.
     */
    public PageResult<User> searchUsersPaged(String keyword, String[] roles,
            Boolean isActive, int page, int pageSize) {
        return userDAO.searchUsersPaged(keyword, roles, isActive, page, pageSize);
    }

    // ========================
    // STATISTICS
    // ========================

    public int getTotalUsers() {
        return userDAO.getTotalUsers();
    }

    public int countActive() {
        return userDAO.countActive();
    }

    public int countLocked() {
        return userDAO.countLocked();
    }

    public int countByRole(String role) {
        return userDAO.countByRole(role);
    }

    // ========================
    // VALIDATION HELPERS
    // ========================

    private boolean isValidEmail(String email) {
        if (email == null || email.trim().isEmpty() || email.length() > 255) {
            return false;
        }
        return email.matches("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$");
    }

    private boolean isValidPassword(String password) {
        if (password == null || password.length() < 8 || password.length() > 128) {
            return false;
        }
        // At least 1 uppercase, 1 digit, and 1 special character
        return password.matches(".*[A-Z].*")
                && password.matches(".*[0-9].*")
                && password.matches(".*[^a-zA-Z0-9\\s].*");
    }

    private boolean isValidDateOfBirth(Date dob) {
        if (dob == null) {
            return false;
        }
        LocalDate birthDate = dob.toInstant().atZone(ZONE_VN).toLocalDate();
        LocalDate today = LocalDate.now(ZONE_VN);
        if (birthDate.isAfter(today) || birthDate.isBefore(LocalDate.of(1900, 1, 1))) {
            return false;
        }
        return !birthDate.isAfter(today.minusYears(MIN_REGISTER_AGE));
    }
}
