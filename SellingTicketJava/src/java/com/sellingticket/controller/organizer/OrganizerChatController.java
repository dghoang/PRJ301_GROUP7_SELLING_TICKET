package com.sellingticket.controller.organizer;

import com.sellingticket.model.User;

import java.io.IOException;
import java.util.logging.Level;
import java.util.logging.Logger;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(name = "OrganizerChatController", urlPatterns = {"/organizer/chat"})
public class OrganizerChatController extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(OrganizerChatController.class.getName());

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            User user = (User) request.getSession().getAttribute("user");
            if (user == null) {
                response.sendRedirect(request.getContextPath() + "/login");
                return;
            }
            
            com.sellingticket.service.EventService eventService = new com.sellingticket.service.EventService();
            // Use "edit" scope: allows admin/owner/manager/staff (not scanner-only)
            java.util.List<com.sellingticket.model.Event> allowedEvents = eventService.getEventsWithPermission(user.getUserId(), user.getRole(), "edit");
            if (allowedEvents.isEmpty()) {
                com.sellingticket.util.ServletUtil.setToast(request, "Bạn không có quyền truy cập chức năng này!", "error");
                response.sendRedirect(request.getContextPath() + "/organizer/events");
                return;
            }
            request.getRequestDispatcher("/organizer/chat.jsp").forward(request, response);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to load organizer chat", e);
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }
}
