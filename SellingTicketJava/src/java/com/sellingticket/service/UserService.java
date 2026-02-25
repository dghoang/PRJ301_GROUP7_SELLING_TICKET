package com.sellingticket.service;

import com.sellingticket.dao.UserDAO;
import com.sellingticket.model.User;
import java.util.List;
import java.util.Date;

/**
 * UserService - Business logic layer for User operations
 * Handles authentication, registration, profile management
 */
public class UserService {

    private final UserDAO userDAO;

    public UserService() {
        this.userDAO = new UserDAO();
    }

    // ========================
    // AUTHENTICATION
    // ========================

    /**
     * Authenticate user with email and password
     * @return User object if successful, null otherwise
     */
    public User authenticate(String email, String password) {
        if (email == null || email.trim().isEmpty() || password == null || password.isEmpty()) {
            return null;
        }
        return userDAO.login(email.trim().toLowerCase(), password);
    }

    /**
     * Register new user (simple)
     */
    public boolean register(String email, String password, String fullName, String phone) {
        // Validate input
        if (!isValidEmail(email)) {
            return false;
        }
        if (password == null || password.length() < 6) {
            return false;
        }
        if (fullName == null || fullName.trim().isEmpty()) {
            return false;
        }
        
        // Check if email exists
        if (userDAO.isEmailExists(email.trim().toLowerCase())) {
            return false;
        }
        
        return userDAO.register(email.trim().toLowerCase(), password, fullName.trim(), phone);
    }

    /**
     * Register with full details
     */
    public boolean registerFull(String email, String password, String fullName, String phone, String gender, Date dob) {
        // Validate input
        if (!isValidEmail(email) || password == null || password.length() < 6) {
            return false;
        }
        if (userDAO.isEmailExists(email.trim().toLowerCase())) {
            return false;
        }
        return userDAO.registerFull(email.trim().toLowerCase(), password, fullName.trim(), phone, gender, dob);
    }

    /**
     * Check if email is already registered
     */
    public boolean isEmailExists(String email) {
        return userDAO.isEmailExists(email.trim().toLowerCase());
    }

    // ========================
    // PROFILE MANAGEMENT
    // ========================

    /**
     * Get user by ID
     */
    public User getUserById(int userId) {
        return userDAO.getUserById(userId);
    }

    /**
     * Update user profile
     */
    public boolean updateProfile(User user) {
        return userDAO.updateUser(user);
    }

    /**
     * Change password
     */
    public boolean changePassword(int userId, String oldPassword, String newPassword) {
        if (newPassword == null || newPassword.length() < 6) {
            return false;
        }
        // Get user and verify old password
        User user = userDAO.getUserById(userId);
        if (user == null) {
            return false;
        }
        // Note: The DAO method should verify the old password hash
        return userDAO.changePassword(userId, oldPassword, newPassword);
    }

    // ========================
    // ADMIN OPERATIONS
    // ========================

    /**
     * Get all users
     */
    public List<User> getAllUsers() {
        return userDAO.getAllUsers();
    }

    /**
     * Update user role
     */
    public boolean updateUserRole(int userId, String role) {
        return userDAO.updateUserRole(userId, role);
    }

    /**
     * Deactivate user
     */
    public boolean deactivateUser(int userId) {
        return userDAO.deactivateUser(userId);
    }

    /**
     * Search users
     */
    public List<User> searchUsers(String keyword) {
        return userDAO.searchUsers(keyword);
    }

    // ========================
    // STATISTICS
    // ========================

    /**
     * Get total user count
     */
    public int getTotalUsers() {
        return userDAO.getTotalUsers();
    }

    // ========================
    // VALIDATION HELPERS
    // ========================

    private boolean isValidEmail(String email) {
        if (email == null || email.trim().isEmpty()) {
            return false;
        }
        // Simple email validation
        return email.matches("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+$");
    }
}
