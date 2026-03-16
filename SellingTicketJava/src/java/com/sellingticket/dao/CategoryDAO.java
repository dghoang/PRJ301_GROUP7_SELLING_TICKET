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

    private boolean hasColumn(Connection conn, String tableName, String columnName) {
        String sql = "SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(?) AND name = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, tableName);
            ps.setString(2, columnName);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (Exception e) {
            LOGGER.log(Level.WARNING, "Failed to check column metadata: {0}.{1}", new Object[]{tableName, columnName});
            return false;
        }
    }

    private Category mapCategory(ResultSet rs) throws SQLException {
        Category cat = new Category();
        cat.setCategoryId(rs.getInt("category_id"));
        cat.setName(rs.getString("name"));
        cat.setSlug(rs.getString("slug"));
        cat.setIcon(rs.getString("icon"));
        cat.setDescription(rs.getString("description"));
        cat.setDisplayOrder(rs.getInt("display_order"));
        cat.setEventCount(rs.getInt("event_count"));
        return cat;
    }

    public List<Category> getAllCategories() {
        List<Category> categories = new ArrayList<>();
        try (Connection conn = getConnection()) {
            boolean hasCategorySoftDelete = hasColumn(conn, "Categories", "is_deleted");
            boolean hasCategoryDisplayOrder = hasColumn(conn, "Categories", "display_order");
            boolean hasEventSoftDelete = hasColumn(conn, "Events", "is_deleted");

            String eventCountExpr = hasEventSoftDelete
                    ? "(SELECT COUNT(*) FROM Events e WHERE e.category_id = c.category_id AND e.status = 'approved' AND (e.is_deleted = 0 OR e.is_deleted IS NULL))"
                    : "(SELECT COUNT(*) FROM Events e WHERE e.category_id = c.category_id AND e.status = 'approved')";
            String orderExpr = hasCategoryDisplayOrder ? "ISNULL(c.display_order, 0)" : "0";

            StringBuilder sql = new StringBuilder();
            sql.append("SELECT c.category_id, c.name, c.slug, c.icon, c.description, ")
               .append(orderExpr).append(" AS display_order, ")
               .append(eventCountExpr).append(" AS event_count ")
               .append("FROM Categories c ");
            if (hasCategorySoftDelete) {
                sql.append("WHERE (c.is_deleted = 0 OR c.is_deleted IS NULL) ");
            }
            if (hasCategoryDisplayOrder) {
                sql.append("ORDER BY ISNULL(c.display_order, 0), c.name");
            } else {
                sql.append("ORDER BY c.name");
            }

            try (PreparedStatement ps = conn.prepareStatement(sql.toString());
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    categories.add(mapCategory(rs));
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Database error in CategoryDAO", e);
        }
        return categories;
    }

    public Category getCategoryBySlug(String slug) {
        try (Connection conn = getConnection()) {
            boolean hasCategorySoftDelete = hasColumn(conn, "Categories", "is_deleted");
            boolean hasCategoryDisplayOrder = hasColumn(conn, "Categories", "display_order");

            String orderExpr = hasCategoryDisplayOrder ? "ISNULL(c.display_order, 0)" : "0";
            StringBuilder sql = new StringBuilder();
            sql.append("SELECT c.category_id, c.name, c.slug, c.icon, c.description, ")
               .append(orderExpr).append(" AS display_order, 0 AS event_count ")
               .append("FROM Categories c WHERE c.slug = ? ");
            if (hasCategorySoftDelete) {
                sql.append("AND (c.is_deleted = 0 OR c.is_deleted IS NULL)");
            }

            try (PreparedStatement ps = conn.prepareStatement(sql.toString())) {
                ps.setString(1, slug);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        return mapCategory(rs);
                    }
                }
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
        try (Connection conn = getConnection()) {
            boolean hasCategorySoftDelete = hasColumn(conn, "Categories", "is_deleted");
            boolean hasCategoryDisplayOrder = hasColumn(conn, "Categories", "display_order");
            boolean hasEventSoftDelete = hasColumn(conn, "Events", "is_deleted");

            String eventCountExpr = hasEventSoftDelete
                    ? "(SELECT COUNT(*) FROM Events e WHERE e.category_id = c.category_id AND e.status = 'approved' AND (e.is_deleted = 0 OR e.is_deleted IS NULL))"
                    : "(SELECT COUNT(*) FROM Events e WHERE e.category_id = c.category_id AND e.status = 'approved')";
            String orderExpr = hasCategoryDisplayOrder ? "ISNULL(c.display_order, 0)" : "0";

            StringBuilder sql = new StringBuilder();
            sql.append("SELECT c.category_id, c.name, c.slug, c.icon, c.description, ")
               .append(orderExpr).append(" AS display_order, ")
               .append(eventCountExpr).append(" AS event_count ")
               .append("FROM Categories c WHERE c.category_id = ? ");
            if (hasCategorySoftDelete) {
                sql.append("AND (c.is_deleted = 0 OR c.is_deleted IS NULL)");
            }

            try (PreparedStatement ps = conn.prepareStatement(sql.toString())) {
                ps.setInt(1, categoryId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        return mapCategory(rs);
                    }
                }
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
        try (Connection conn = getConnection()) {
            boolean hasCategoryDisplayOrder = hasColumn(conn, "Categories", "display_order");
            String sql = hasCategoryDisplayOrder
                    ? "INSERT INTO Categories (name, slug, icon, description, display_order) VALUES (?, ?, ?, ?, ?)"
                    : "INSERT INTO Categories (name, slug, icon, description) VALUES (?, ?, ?, ?)";

            try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
                ps.setString(1, category.getName());
                ps.setString(2, category.getSlug());
                ps.setString(3, category.getIcon());
                ps.setString(4, category.getDescription());
                if (hasCategoryDisplayOrder) {
                    ps.setInt(5, category.getDisplayOrder());
                }
                int rows = ps.executeUpdate();
                if (rows > 0) {
                    try (ResultSet keys = ps.getGeneratedKeys()) {
                        if (keys.next()) {
                            category.setCategoryId(keys.getInt(1));
                        }
                    }
                    return true;
                }
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
        try (Connection conn = getConnection()) {
            boolean hasCategoryDisplayOrder = hasColumn(conn, "Categories", "display_order");
            String sql = hasCategoryDisplayOrder
                    ? "UPDATE Categories SET name = ?, slug = ?, icon = ?, description = ?, display_order = ? WHERE category_id = ?"
                    : "UPDATE Categories SET name = ?, slug = ?, icon = ?, description = ? WHERE category_id = ?";

            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, category.getName());
                ps.setString(2, category.getSlug());
                ps.setString(3, category.getIcon());
                ps.setString(4, category.getDescription());
                if (hasCategoryDisplayOrder) {
                    ps.setInt(5, category.getDisplayOrder());
                    ps.setInt(6, category.getCategoryId());
                } else {
                    ps.setInt(5, category.getCategoryId());
                }
                return ps.executeUpdate() > 0;
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Database error in CategoryDAO", e);
        }
        return false;
    }

    /**
     * Soft-delete a category (only if no active events are linked)
     */
    public boolean deleteCategory(int categoryId) {
        try (Connection conn = getConnection()) {
            boolean hasCategorySoftDelete = hasColumn(conn, "Categories", "is_deleted");
            boolean hasEventSoftDelete = hasColumn(conn, "Events", "is_deleted");

            String checkSql = hasEventSoftDelete
                    ? "SELECT COUNT(*) FROM Events WHERE category_id = ? AND (is_deleted = 0 OR is_deleted IS NULL)"
                    : "SELECT COUNT(*) FROM Events WHERE category_id = ?";
            String deleteSql = hasCategorySoftDelete
                    ? "UPDATE Categories SET is_deleted = 1 WHERE category_id = ?"
                    : "DELETE FROM Categories WHERE category_id = ?";

            try (PreparedStatement checkPs = conn.prepareStatement(checkSql)) {
                checkPs.setInt(1, categoryId);
                try (ResultSet rs = checkPs.executeQuery()) {
                    if (rs.next() && rs.getInt(1) > 0) {
                        return false; // Cannot delete — active events exist
                    }
                }
            }

            try (PreparedStatement deletePs = conn.prepareStatement(deleteSql)) {
                deletePs.setInt(1, categoryId);
                return deletePs.executeUpdate() > 0;
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error deleting category", e);
        }
        return false;
    }
}
