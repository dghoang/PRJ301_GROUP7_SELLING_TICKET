package com.sellingticket.controller.admin;

import com.sellingticket.model.ActivityLog;
import com.sellingticket.service.ActivityLogService;

import java.io.IOException;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * Admin Activity Log — paginated audit trail with filters.
 * GET /admin/activity-log — JSP page with table, filters, pagination.
 */
@WebServlet(name = "AdminActivityLogController", urlPatterns = {"/admin/activity-log"})
public class AdminActivityLogController extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(AdminActivityLogController.class.getName());
    private static final int DEFAULT_PAGE_SIZE = 20;
    private static final int MAX_PAGE_SIZE = 200;
    private final ActivityLogService activityLogService = new ActivityLogService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            // Parse filters
            String actionFilter = request.getParameter("action");
            String entityFilter = request.getParameter("entity");
            int userIdFilter = 0;
            String userIdParam = request.getParameter("userId");
            if (userIdParam != null && !userIdParam.isEmpty()) {
                try { userIdFilter = Integer.parseInt(userIdParam); } catch (NumberFormatException ignored) {}
            }

            int page = 1;
            String pageParam = request.getParameter("page");
            if (pageParam != null) {
                try { page = Math.max(1, Integer.parseInt(pageParam)); } catch (NumberFormatException ignored) {}
            }

            int pageSize = DEFAULT_PAGE_SIZE;
            String sizeParam = request.getParameter("size");
            if (sizeParam != null) {
                try { pageSize = Math.max(1, Math.min(MAX_PAGE_SIZE, Integer.parseInt(sizeParam))); } catch (NumberFormatException ignored) {}
            }

            // Fetch data
            List<ActivityLog> logs = activityLogService.search(
                    actionFilter, userIdFilter, entityFilter, page, pageSize);
            int totalCount = activityLogService.countSearch(actionFilter, userIdFilter, entityFilter);
            int totalPages = Math.max(1, (int) Math.ceil((double) totalCount / pageSize));

            // Distinct action types for filter dropdown
            List<String> actionTypes = activityLogService.getDistinctActions();

            // Set attributes
            request.setAttribute("logs", logs);
            request.setAttribute("actionTypes", actionTypes);
            request.setAttribute("currentPage", page);
            request.setAttribute("totalPages", totalPages);
            request.setAttribute("totalCount", totalCount);
            request.setAttribute("pageSize", pageSize);
            request.setAttribute("totalRecords", totalCount);
            request.setAttribute("filterAction", actionFilter);
            request.setAttribute("filterEntity", entityFilter);
            request.setAttribute("filterUserId", userIdParam);

            request.getRequestDispatcher("/admin/activity-log.jsp").forward(request, response);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to load activity log", e);
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }
}
