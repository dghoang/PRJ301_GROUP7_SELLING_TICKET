package com.sellingticket.controller.admin;

import com.sellingticket.model.Category;
import com.sellingticket.service.CategoryService;
import static com.sellingticket.util.ServletUtil.parseIntOrDefault;

import java.io.IOException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(name = "AdminCategoryController", urlPatterns = {"/admin/categories", "/admin/categories/*"})
public class AdminCategoryController extends HttpServlet {

    private final CategoryService categoryService = new CategoryService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        listCategories(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = getAction(request.getPathInfo());

        switch (action) {
            case "create": createCategory(request, response); break;
            case "update": updateCategory(request, response); break;
            case "delete": deleteCategory(request, response); break;
            default: response.sendRedirect(request.getContextPath() + "/admin/categories");
        }
    }

    private String getAction(String pathInfo) {
        if (pathInfo == null || pathInfo.equals("/")) return "list";
        return pathInfo.substring(1);
    }

    private void listCategories(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        List<Category> categories = categoryService.getAllCategories();
        request.setAttribute("categories", categories);

        String editId = request.getParameter("edit");
        if (editId != null) {
            int categoryId = parseIntOrDefault(editId, -1);
            if (categoryId > 0) {
                request.setAttribute("editCategory", categoryService.getCategoryById(categoryId));
            }
        }

        request.getRequestDispatcher("/admin/categories.jsp").forward(request, response);
    }

    private void createCategory(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String name = request.getParameter("name");
        if (name == null || name.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/categories?error=create_failed");
            return;
        }

        Category category = new Category();
        category.setName(name);
        category.setIcon(request.getParameter("icon"));
        category.setDescription(request.getParameter("description"));

        String result = categoryService.createCategory(category) ? "success=created" : "error=create_failed";
        response.sendRedirect(request.getContextPath() + "/admin/categories?" + result);
    }

    private void updateCategory(HttpServletRequest request, HttpServletResponse response) throws IOException {
        int categoryId = parseIntOrDefault(request.getParameter("categoryId"), -1);
        String name = request.getParameter("name");

        if (categoryId <= 0 || name == null || name.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/categories?error=update_failed");
            return;
        }

        Category category = new Category();
        category.setCategoryId(categoryId);
        category.setName(name);
        category.setSlug(request.getParameter("slug"));
        category.setIcon(request.getParameter("icon"));
        category.setDescription(request.getParameter("description"));

        String result = categoryService.updateCategory(category) ? "success=updated" : "error=update_failed";
        response.sendRedirect(request.getContextPath() + "/admin/categories?" + result);
    }

    private void deleteCategory(HttpServletRequest request, HttpServletResponse response) throws IOException {
        int categoryId = parseIntOrDefault(request.getParameter("categoryId"), -1);
        if (categoryId <= 0) {
            response.sendRedirect(request.getContextPath() + "/admin/categories?error=delete_failed");
            return;
        }

        String result = categoryService.deleteCategory(categoryId) ? "success=deleted" : "error=has_events";
        response.sendRedirect(request.getContextPath() + "/admin/categories?" + result);
    }
}
