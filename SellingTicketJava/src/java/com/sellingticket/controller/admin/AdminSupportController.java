package com.sellingticket.controller.admin;

import com.sellingticket.model.SupportTicket;
import com.sellingticket.model.TicketMessage;
import com.sellingticket.model.User;
import com.sellingticket.service.DashboardService;
import com.sellingticket.service.SupportTicketService;
import com.sellingticket.util.FlashUtil;
import static com.sellingticket.util.ServletUtil.parseIntOrDefault;

import java.io.IOException;
import java.util.List;
import java.util.Set;
import java.util.logging.Level;
import java.util.logging.Logger;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * Admin support ticket management — list, detail, reply, assign, status change.
 */
@WebServlet(name = "AdminSupportController", urlPatterns = {"/admin/support", "/admin/support/*"})
public class AdminSupportController extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(AdminSupportController.class.getName());
    private static final Set<String> VALID_STATUSES = Set.of("open", "in_progress", "resolved", "closed");
    private static final Set<String> VALID_PRIORITIES = Set.of("low", "medium", "high", "urgent");
    private static final int MAX_REPLY_LENGTH = 5000;
    private final SupportTicketService ticketService = new SupportTicketService();
    private final DashboardService dashboardService = new DashboardService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            FlashUtil.apply(request);
            String path = request.getPathInfo();

            // Sidebar badge
            request.setAttribute("pendingCount", dashboardService.getPendingEventsCount());
            request.setAttribute("openTickets", ticketService.countOpen());

            if (path != null && path.matches("/\\d+")) {
                // Ticket detail
                int ticketId = parseIntOrDefault(path.substring(1), -1);
                SupportTicket ticket = ticketService.getById(ticketId);
                if (ticket == null) {
                    response.sendError(HttpServletResponse.SC_NOT_FOUND);
                    return;
                }
                List<TicketMessage> messages = ticketService.getMessages(ticketId, true);
                ticket.setMessages(messages);
                request.setAttribute("ticket", ticket);
                request.getRequestDispatcher("/admin/support-detail.jsp").forward(request, response);
            } else {
                // List
                String status = request.getParameter("status");
                String category = request.getParameter("category");
                int page = parseIntOrDefault(request.getParameter("page"), 1);

                List<SupportTicket> tickets = ticketService.getAll(status, category, page, 20);
                request.setAttribute("tickets", tickets);
                request.setAttribute("currentPage", page);
                request.setAttribute("statusFilter", status);
                request.setAttribute("categoryFilter", category);

                // Stats
                request.setAttribute("totalTickets", ticketService.countByStatus(null));
                request.setAttribute("openCount", ticketService.countByStatus("open"));
                request.setAttribute("inProgressCount", ticketService.countByStatus("in_progress"));
                request.setAttribute("resolvedCount", ticketService.countByStatus("resolved"));

                request.getRequestDispatcher("/admin/support.jsp").forward(request, response);
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to load admin support", e);
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String path = request.getPathInfo();
        if (path == null) path = "/";

        User admin = (User) request.getSession().getAttribute("user");
        int ticketId = parseIntOrDefault(request.getParameter("ticketId"), -1);

        if (ticketId <= 0) {
            FlashUtil.error(request, "Dữ liệu không hợp lệ!");
            response.sendRedirect(request.getContextPath() + "/admin/support");
            return;
        }

        switch (path) {
            case "/reply": {
                String content = request.getParameter("content");
                boolean isInternal = "on".equals(request.getParameter("internal"));
                if (content != null && !content.trim().isEmpty()) {
                    // Truncate to max length to prevent abuse
                    String trimmed = content.trim();
                    if (trimmed.length() > MAX_REPLY_LENGTH) {
                        trimmed = trimmed.substring(0, MAX_REPLY_LENGTH);
                    }
                    ticketService.addReply(ticketId, admin.getUserId(), trimmed, isInternal);
                }
                break;
            }
            case "/status": {
                String status = request.getParameter("status");
                if (status != null && VALID_STATUSES.contains(status)) {
                    ticketService.updateStatus(ticketId, status);
                }
                break;
            }
            case "/assign": {
                ticketService.assignTicket(ticketId, admin.getUserId());
                break;
            }
            case "/priority": {
                String priority = request.getParameter("priority");
                if (priority != null && VALID_PRIORITIES.contains(priority)) {
                    ticketService.updatePriority(ticketId, priority);
                }
                break;
            }
        }

        response.sendRedirect(request.getContextPath() + "/admin/support/" + ticketId);
    }
}
