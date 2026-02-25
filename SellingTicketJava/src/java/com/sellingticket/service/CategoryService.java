package com.sellingticket.service;

import com.sellingticket.dao.CategoryDAO;
import com.sellingticket.model.Category;
import java.util.List;

/**
 * CategoryService - Business logic layer for Category operations
 */
public class CategoryService {

    private final CategoryDAO categoryDAO;

    public CategoryService() {
        this.categoryDAO = new CategoryDAO();
    }

    // ========================
    // READ OPERATIONS
    // ========================

    /**
     * Get all categories with event count
     */
    public List<Category> getAllCategories() {
        return categoryDAO.getAllCategories();
    }

    /**
     * Get category by ID
     */
    public Category getCategoryById(int categoryId) {
        return categoryDAO.getCategoryById(categoryId);
    }

    /**
     * Get category by slug (for URL routing)
     */
    public Category getCategoryBySlug(String slug) {
        return categoryDAO.getCategoryBySlug(slug);
    }

    // ========================
    // WRITE OPERATIONS
    // ========================

    /**
     * Create new category
     */
    public boolean createCategory(Category category) {
        // Generate slug from name if not provided
        if (category.getSlug() == null || category.getSlug().isEmpty()) {
            category.setSlug(generateSlug(category.getName()));
        }
        return categoryDAO.createCategory(category);
    }

    /**
     * Update category
     */
    public boolean updateCategory(Category category) {
        return categoryDAO.updateCategory(category);
    }

    /**
     * Delete category (only if no events linked)
     */
    public boolean deleteCategory(int categoryId) {
        return categoryDAO.deleteCategory(categoryId);
    }

    // ========================
    // HELPERS
    // ========================

    /**
     * Generate URL-friendly slug from name
     */
    private String generateSlug(String name) {
        if (name == null) return "";
        return name.toLowerCase()
                   .replaceAll("[^a-z0-9\\s-]", "")
                   .replaceAll("\\s+", "-")
                   .replaceAll("-+", "-")
                   .trim();
    }
}
