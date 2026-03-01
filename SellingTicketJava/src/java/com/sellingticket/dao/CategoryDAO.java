package com.sellingticket.dao;

import com.sellingticket.model.Category;
import com.sellingticket.util.DBContext;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

public class CategoryDAO extends DBContext {

    private static final Logger LOGGER = Logger.getLogger(CategoryDAO.class.getName());

    public List<Category> getAllCategories() {
        List<Category> categories = new ArrayList<>();
        String sql = "SELECT c.*, " +
                     "(SELECT COUNT(*) FROM Events WHERE category_id = c.category_id AND status = 'approved') as event_count " +
                     "FROM Categories c ORDER BY c.name";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Category cat = new Category();
                cat.setCategoryId(rs.getInt("category_id"));
                cat.setName(rs.getString("name"));
                cat.setSlug(rs.getString("slug"));
                cat.setIcon(rs.getString("icon"));
                cat.setDescription(rs.getString("description"));
                cat.setEventCount(rs.getInt("event_count"));
                categories.add(cat);
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Database error in CategoryDAO", e);
        }
        return categories;
    }

    public Category getCategoryBySlug(String slug) {
        String sql = "SELECT * FROM Categories WHERE slug = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, slug);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                Category cat = new Category();
                cat.setCategoryId(rs.getInt("category_id"));
                cat.setName(rs.getString("name"));
                cat.setSlug(rs.getString("slug"));
                cat.setIcon(rs.getString("icon"));
                cat.setDescription(rs.getString("description"));
                return cat;
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Database error in CategoryDAO", e);
        }
        return null;
    }

    // ========================
    // NEW CRUD METHODS
    // ========================

    /**
     * Get category by ID
     */
    public Category getCategoryById(int categoryId) {
        String sql = "SELECT c.*, " +
                     "(SELECT COUNT(*) FROM Events WHERE category_id = c.category_id AND status = 'approved') as event_count " +
                     "FROM Categories c WHERE c.category_id = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, categoryId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                Category cat = new Category();
                cat.setCategoryId(rs.getInt("category_id"));
                cat.setName(rs.getString("name"));
                cat.setSlug(rs.getString("slug"));
                cat.setIcon(rs.getString("icon"));
                cat.setDescription(rs.getString("description"));
                cat.setEventCount(rs.getInt("event_count"));
                return cat;
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Database error in CategoryDAO", e);
        }
        return null;
    }

    /**
     * Create a new category
     */
    public boolean createCategory(Category category) {
        String sql = "INSERT INTO Categories (name, slug, icon, description) VALUES (?, ?, ?, ?)";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, category.getName());
            ps.setString(2, category.getSlug());
            ps.setString(3, category.getIcon());
            ps.setString(4, category.getDescription());
            int rows = ps.executeUpdate();
            if (rows > 0) {
                ResultSet keys = ps.getGeneratedKeys();
                if (keys.next()) {
                    category.setCategoryId(keys.getInt(1));
                }
                return true;
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Database error in CategoryDAO", e);
        }
        return false;
    }

    /**
     * Update an existing category
     */
    public boolean updateCategory(Category category) {
        String sql = "UPDATE Categories SET name = ?, slug = ?, icon = ?, description = ? WHERE category_id = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, category.getName());
            ps.setString(2, category.getSlug());
            ps.setString(3, category.getIcon());
            ps.setString(4, category.getDescription());
            ps.setInt(5, category.getCategoryId());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Database error in CategoryDAO", e);
        }
        return false;
    }

    /**
     * Soft-delete a category (only if no active events are linked)
     */
    public boolean deleteCategory(int categoryId) {
        String checkSql = "SELECT COUNT(*) FROM Events WHERE category_id = ? AND (is_deleted = 0 OR is_deleted IS NULL)";
        String softDeleteSql = "UPDATE Categories SET is_deleted = 1 WHERE category_id = ?";
        try (Connection conn = getConnection()) {
            try (PreparedStatement checkPs = conn.prepareStatement(checkSql)) {
                checkPs.setInt(1, categoryId);
                ResultSet rs = checkPs.executeQuery();
                if (rs.next() && rs.getInt(1) > 0) {
                    return false; // Cannot delete — active events exist
                }
            }
            try (PreparedStatement deletePs = conn.prepareStatement(softDeleteSql)) {
                deletePs.setInt(1, categoryId);
                return deletePs.executeUpdate() > 0;
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error soft-deleting category", e);
        }
        return false;
    }
}
