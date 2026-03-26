package com.sellingticket.controller.admin;

import com.sellingticket.model.Category;
import com.sellingticket.service.CategoryService;
import com.sellingticket.service.DashboardService;
import com.sellingticket.util.InputValidator;
import static com.sellingticket.util.ServletUtil.parseIntOrDefault;
import com.sellingticket.util.FlashUtil;

import java.io.IOException;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(name = "AdminCategoryController", urlPatterns = {"/admin/categories", "/admin/categories/*"})
public class AdminCategoryController extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(AdminCategoryController.class.getName());

    private final CategoryService categoryService = new CategoryService();
    private final DashboardService dashboardService = new DashboardService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        FlashUtil.apply(request);
        listCategories(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            String action = getAction(request.getPathInfo());

            switch (action) {
                case "create": createCategory(request, response); break;
                case "update": updateCategory(request, response); break;
                case "delete": deleteCategory(request, response); break;
                default: response.sendRedirect(request.getContextPath() + "/admin/categories");
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error in AdminCategoryController.doPost", e);
            FlashUtil.error(request, "Đã xảy ra lỗi, vui lòng thử lại");
            response.sendRedirect(request.getContextPath() + "/admin/categories");
        }
    }

    private String getAction(String pathInfo) {
        if (pathInfo == null || pathInfo.equals("/")) return "list";
        return pathInfo.substring(1);
    }

    private void listCategories(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            List<Category> allCategories = categoryService.getAllCategories();
            if (allCategories == null) allCategories = java.util.Collections.emptyList();

            int page = parseIntOrDefault(request.getParameter("page"), 1);
            int size = parseIntOrDefault(request.getParameter("size"), 20);
            size = Math.max(1, Math.min(200, size));
            page = Math.max(1, page);

            int total = allCategories.size();
            int totalPages = Math.max(1, (int) Math.ceil((double) total / size));
            if (page > totalPages) page = totalPages;
            int fromIdx = (page - 1) * size;
            int toIdx = Math.min(fromIdx + size, total);
            List<Category> categories = allCategories.subList(fromIdx, toIdx);

            request.setAttribute("categories", categories);
            request.setAttribute("allCategories", allCategories);
            request.setAttribute("currentPage", page);
            request.setAttribute("totalPages", totalPages);
            request.setAttribute("pageSize", size);
            request.setAttribute("totalRecords", total);
            request.setAttribute("pendingCount", dashboardService.getPendingEventsCount());

            String editId = request.getParameter("edit");
            if (editId != null) {
                int categoryId = parseIntOrDefault(editId, -1);
                if (categoryId > 0) {
                    request.setAttribute("editCategory", categoryService.getCategoryById(categoryId));
                }
            }

            request.getRequestDispatcher("/admin/categories.jsp").forward(request, response);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to load categories", e);
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }

    private void createCategory(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String name = request.getParameter("name");
        int displayOrder = Math.max(0, parseIntOrDefault(request.getParameter("displayOrder"), 0));
        if (!InputValidator.isValidCategoryName(name)) {
            FlashUtil.error(request, "Tên danh mục phải từ 1-100 ký tự!");
            response.sendRedirect(request.getContextPath() + "/admin/categories");
            return;
        }

        Category category = new Category();
        category.setName(name);
        category.setIcon(InputValidator.truncate(request.getParameter("icon"), 500));
        category.setDescription(InputValidator.truncate(request.getParameter("description"), 1000));
        category.setDisplayOrder(displayOrder);

        if (categoryService.createCategory(category)) {
            FlashUtil.success(request, "Danh mục đã được tạo!");
        } else {
            FlashUtil.error(request, "Tạo danh mục thất bại!");
        }
        response.sendRedirect(request.getContextPath() + "/admin/categories");
    }

    private void updateCategory(HttpServletRequest request, HttpServletResponse response) throws IOException {
        int categoryId = parseIntOrDefault(request.getParameter("categoryId"), -1);
        String name = request.getParameter("name");
        int displayOrder = Math.max(0, parseIntOrDefault(request.getParameter("displayOrder"), 0));

        if (categoryId <= 0 || !InputValidator.isValidCategoryName(name)) {
            FlashUtil.error(request, "Tên danh mục phải từ 1-100 ký tự!");
            response.sendRedirect(request.getContextPath() + "/admin/categories");
            return;
        }

        Category category = new Category();
        category.setCategoryId(categoryId);
        category.setName(name);
        category.setSlug(request.getParameter("slug"));
        category.setIcon(InputValidator.truncate(request.getParameter("icon"), 500));
        category.setDescription(InputValidator.truncate(request.getParameter("description"), 1000));
        category.setDisplayOrder(displayOrder);

        if (categoryService.updateCategory(category)) {
            FlashUtil.success(request, "Danh mục đã được cập nhật!");
        } else {
            FlashUtil.error(request, "Cập nhật danh mục thất bại!");
        }
        response.sendRedirect(request.getContextPath() + "/admin/categories");
    }

    private void deleteCategory(HttpServletRequest request, HttpServletResponse response) throws IOException {
        int categoryId = parseIntOrDefault(request.getParameter("categoryId"), -1);
        if (categoryId <= 0) {
            FlashUtil.error(request, "Xóa danh mục thất bại!");
            response.sendRedirect(request.getContextPath() + "/admin/categories");
            return;
        }

        if (categoryService.deleteCategory(categoryId)) {
            FlashUtil.success(request, "Danh mục đã được xóa!");
        } else {
            FlashUtil.error(request, "Không thể xóa danh mục đang có sự kiện!");
        }
        response.sendRedirect(request.getContextPath() + "/admin/categories");
    }
}
