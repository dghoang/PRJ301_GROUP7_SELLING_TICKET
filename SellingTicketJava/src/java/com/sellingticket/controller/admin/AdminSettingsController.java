package com.sellingticket.controller.admin;

import com.sellingticket.dao.SiteSettingsDAO;
import com.sellingticket.service.DashboardService;
import com.sellingticket.util.InputValidator;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * Admin settings — site configuration persisted to SiteSettings table.
 */
@WebServlet(name = "AdminSettingsController", urlPatterns = {"/admin/settings"})
public class AdminSettingsController extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(AdminSettingsController.class.getName());
    private final DashboardService dashboardService = new DashboardService();
    private final SiteSettingsDAO settingsDAO = new SiteSettingsDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            request.setAttribute("pendingCount", dashboardService.getPendingEventsCount());
            // Load current settings for JSP
            request.setAttribute("settings", settingsDAO.getAllCached());
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

        Map<String, String> updates = new HashMap<>();
        updates.put("chat_enabled", request.getParameter("chatEnabled") != null ? "true" : "false");
        updates.put("chat_auto_accept", request.getParameter("chatAutoAccept") != null ? "true" : "false");
        updates.put("chat_cooldown_minutes", String.valueOf(
                InputValidator.parseIntInRange(request.getParameter("chatCooldown"), 1, 1440, 30)));
        updates.put("require_event_approval", request.getParameter("requireApproval") != null ? "true" : "false");
        updates.put("allow_organizer_registration", request.getParameter("allowOrganizerReg") != null ? "true" : "false");

        settingsDAO.setAll(updates);

        request.getSession().setAttribute("toastMessage", "Cài đặt đã được lưu thành công!");
        request.getSession().setAttribute("toastType", "success");
        response.sendRedirect(request.getContextPath() + "/admin/settings");
    }

    private String getParamOrDefault(HttpServletRequest request, String name, String defaultVal) {
        String val = request.getParameter(name);
        return (val != null && !val.isEmpty()) ? val : defaultVal;
    }
}
