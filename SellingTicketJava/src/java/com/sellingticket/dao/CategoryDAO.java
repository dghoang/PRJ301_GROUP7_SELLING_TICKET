package com.sellingticket.dao;

import com.sellingticket.model.Category;
import com.sellingticket.util.DBContext;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class CategoryDAO extends DBContext {

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
            e.printStackTrace();
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
            e.printStackTrace();
        }
        return null;
    }
}
