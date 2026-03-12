package com.sellingticket.controller.organizer;

import com.sellingticket.model.User;
import com.sellingticket.service.SupportTicketService;
import com.sellingticket.service.UserService;
import com.sellingticket.util.InputValidator;
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

        // 1. Update profile fields (with validation)
        User updated = userService.getUserById(user.getUserId());
        String fullName = trim(request.getParameter("fullName"));
        String phone = trim(request.getParameter("phone"));

        if (!InputValidator.isValidFullName(fullName)) {
            setToast(request, "Họ tên phải từ 2-100 ký tự", "error");
            response.sendRedirect(request.getContextPath() + "/organizer/settings");
            return;
        }
        if (!InputValidator.isValidPhone(phone)) {
            setToast(request, "Số điện thoại không hợp lệ", "error");
            response.sendRedirect(request.getContextPath() + "/organizer/settings");
            return;
        }

        String website = trim(request.getParameter("website"));
        if (website != null && !website.isEmpty() && !InputValidator.isValidUrl(website)) {
            setToast(request, "URL website không hợp lệ (phải bắt đầu bằng http:// hoặc https://)", "error");
            response.sendRedirect(request.getContextPath() + "/organizer/settings");
            return;
        }

        updated.setFullName(fullName);
        updated.setPhone(phone);
        updated.setBio(InputValidator.truncate(trim(request.getParameter("bio")), 2000));
        updated.setWebsite(InputValidator.truncate(website, 2000));
        updated.setSocialFacebook(InputValidator.truncate(trim(request.getParameter("socialFacebook")), 2000));
        updated.setSocialInstagram(InputValidator.truncate(trim(request.getParameter("socialInstagram")), 2000));

        boolean profileOk = userService.updateOrganizerProfile(updated);

        // 2. Save notification & event config preferences in session
        Map<String, String> prefs = new HashMap<>();
        prefs.put("notifyNewOrder", request.getParameter("notifyNewOrder") != null ? "true" : "false");
        prefs.put("notifyTicketIssue", request.getParameter("notifyTicketIssue") != null ? "true" : "false");
        prefs.put("notifyCheckin", request.getParameter("notifyCheckin") != null ? "true" : "false");
        prefs.put("notifyDailyReport", request.getParameter("notifyDailyReport") != null ? "true" : "false");
        prefs.put("defaultMaxTickets", String.valueOf(
                InputValidator.parseIntInRange(request.getParameter("defaultMaxTickets"), 1, 10000, 10)));
        prefs.put("paymentTimeout", String.valueOf(
                InputValidator.parseIntInRange(request.getParameter("paymentTimeout"), 1, 480, 60)));
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
