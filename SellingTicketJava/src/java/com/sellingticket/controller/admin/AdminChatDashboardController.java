package com.sellingticket.controller.admin;

import com.sellingticket.service.DashboardService;
import com.sellingticket.service.SupportTicketService;

import java.io.IOException;
import java.util.logging.Level;
import java.util.logging.Logger;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(name = "AdminChatDashboardController", urlPatterns = {"/admin/chat-dashboard"})
public class AdminChatDashboardController extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(AdminChatDashboardController.class.getName());
    private final DashboardService dashboardService = new DashboardService();
    private final SupportTicketService ticketService = new SupportTicketService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            request.setAttribute("pendingCount", dashboardService.getPendingEventsCount());
            try { request.setAttribute("openTickets", ticketService.countOpen()); }
            catch (Exception ignored) { request.setAttribute("openTickets", 0); }
            request.getRequestDispatcher("/admin/chat-dashboard.jsp").forward(request, response);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to load chat dashboard", e);
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }
}
