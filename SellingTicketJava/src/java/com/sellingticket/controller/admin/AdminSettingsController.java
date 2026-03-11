package com.sellingticket.controller.admin;

import com.sellingticket.service.DashboardService;
import java.io.IOException;
import java.util.logging.Level;
import java.util.logging.Logger;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * Admin settings — site configuration.
 */
@WebServlet(name = "AdminSettingsController", urlPatterns = {"/admin/settings"})
public class AdminSettingsController extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(AdminSettingsController.class.getName());
    private final DashboardService dashboardService = new DashboardService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            request.setAttribute("pendingCount", dashboardService.getPendingEventsCount());
            request.getRequestDispatcher("/admin/settings.jsp").forward(request, response);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to load admin settings", e);
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        // Future: save site-wide settings (site name, logo, maintenance mode, etc.)
        request.getSession().setAttribute("toastMessage", "Cài đặt đã được lưu thành công!");
        request.getSession().setAttribute("toastType", "success");
        response.sendRedirect(request.getContextPath() + "/admin/settings");
    }
}
