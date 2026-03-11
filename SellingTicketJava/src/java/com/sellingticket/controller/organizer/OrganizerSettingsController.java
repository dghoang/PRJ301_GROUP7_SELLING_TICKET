package com.sellingticket.controller.organizer;

import com.sellingticket.model.User;
import com.sellingticket.service.SupportTicketService;
import com.sellingticket.service.UserService;
import static com.sellingticket.util.ServletUtil.*;

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
import jakarta.servlet.http.HttpSession;

/**
 * Organizer settings controller.
 * Handles profile, event config, notification prefs, and support link.
 */
@WebServlet(name = "OrganizerSettingsController", urlPatterns = {"/organizer/settings"})
public class OrganizerSettingsController extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(OrganizerSettingsController.class.getName());
    private final UserService userService = new UserService();
    private final SupportTicketService ticketService = new SupportTicketService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User user = getSessionUser(request);
        if (user == null) { redirectToLogin(request, response); return; }

        try {
            User organizer = userService.getUserById(user.getUserId());
            if (organizer == null) {
                // Fallback: use session user if DB lookup fails
                organizer = user;
            }
            request.setAttribute("organizer", organizer);

            // Load notification/event preferences from session
            HttpSession session = request.getSession();
            @SuppressWarnings("unchecked")
            Map<String, String> prefs = (Map<String, String>) session.getAttribute("orgPrefs");
            if (prefs == null) {
                prefs = getDefaultPrefs();
                session.setAttribute("orgPrefs", prefs);
            }
            request.setAttribute("orgPrefs", prefs);

            // Count open support tickets for this organizer
            try {
                int ticketCount = ticketService.getByUser(user.getUserId()).size();
                request.setAttribute("orgTicketCount", ticketCount);
            } catch (Exception ignored) {
                request.setAttribute("orgTicketCount", 0);
            }

            request.getRequestDispatcher("/organizer/settings.jsp").forward(request, response);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to load organizer settings", e);
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                    "Không thể tải trang cài đặt. Vui lòng thử lại.");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User user = getSessionUser(request);
        if (user == null) { redirectToLogin(request, response); return; }

        request.setCharacterEncoding("UTF-8");

        // 1. Update profile fields
        User updated = userService.getUserById(user.getUserId());
        updated.setFullName(trim(request.getParameter("fullName")));
        updated.setPhone(trim(request.getParameter("phone")));
        updated.setBio(trim(request.getParameter("bio")));
        updated.setWebsite(trim(request.getParameter("website")));
        updated.setSocialFacebook(trim(request.getParameter("socialFacebook")));
        updated.setSocialInstagram(trim(request.getParameter("socialInstagram")));

        boolean profileOk = userService.updateOrganizerProfile(updated);

        // 2. Save notification & event config preferences in session
        Map<String, String> prefs = new HashMap<>();
        prefs.put("notifyNewOrder", request.getParameter("notifyNewOrder") != null ? "true" : "false");
        prefs.put("notifyTicketIssue", request.getParameter("notifyTicketIssue") != null ? "true" : "false");
        prefs.put("notifyCheckin", request.getParameter("notifyCheckin") != null ? "true" : "false");
        prefs.put("notifyDailyReport", request.getParameter("notifyDailyReport") != null ? "true" : "false");
        prefs.put("defaultMaxTickets", trim(request.getParameter("defaultMaxTickets")));
        prefs.put("paymentTimeout", trim(request.getParameter("paymentTimeout")));
        prefs.put("allowEarlyCheckin", request.getParameter("allowEarlyCheckin") != null ? "true" : "false");
        prefs.put("allowTicketTransfer", request.getParameter("allowTicketTransfer") != null ? "true" : "false");
        prefs.put("staffCanCancel", request.getParameter("staffCanCancel") != null ? "true" : "false");
        prefs.put("staffCanViewRevenue", request.getParameter("staffCanViewRevenue") != null ? "true" : "false");

        HttpSession session = request.getSession();
        session.setAttribute("orgPrefs", prefs);

        if (profileOk) {
            session.setAttribute("account", updated);
            session.setAttribute("user", updated);
            setToast(request, "Cập nhật cài đặt thành công!", "success");
            LOGGER.log(Level.INFO, "Organizer settings updated: {0}", user.getUserId());
        } else {
            setToast(request, "Cập nhật thất bại!", "error");
        }

        response.sendRedirect(request.getContextPath() + "/organizer/settings");
    }

    private Map<String, String> getDefaultPrefs() {
        Map<String, String> prefs = new HashMap<>();
        prefs.put("notifyNewOrder", "true");
        prefs.put("notifyTicketIssue", "true");
        prefs.put("notifyCheckin", "false");
        prefs.put("notifyDailyReport", "false");
        prefs.put("defaultMaxTickets", "10");
        prefs.put("paymentTimeout", "15");
        prefs.put("allowEarlyCheckin", "false");
        prefs.put("allowTicketTransfer", "false");
        prefs.put("staffCanCancel", "false");
        prefs.put("staffCanViewRevenue", "false");
        return prefs;
    }

    private String trim(String s) {
        return s == null ? null : s.trim();
    }
}
