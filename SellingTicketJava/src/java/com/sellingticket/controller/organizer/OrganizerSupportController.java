package com.sellingticket.controller.organizer;

import com.sellingticket.model.SupportTicket;
import com.sellingticket.model.TicketMessage;
import com.sellingticket.model.User;
import com.sellingticket.service.SupportTicketService;
import static com.sellingticket.util.ServletUtil.*;

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
 * Organizer support center — create/view tickets to admin.
 * Organizer tickets are auto-prioritized as "urgent".
 *
 * <p>Endpoints:
 * <ul>
 *   <li>GET  /organizer/support              → list tickets</li>
 *   <li>GET  /organizer/support/ticket/{id}   → ticket detail + chat</li>
 *   <li>POST /organizer/support/create        → create ticket</li>
 *   <li>POST /organizer/support/reply         → add reply</li>
 * </ul>
 */
@WebServlet(name = "OrganizerSupportController", urlPatterns = {"/organizer/support/*"})
public class OrganizerSupportController extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(OrganizerSupportController.class.getName());
    private final SupportTicketService ticketService = new SupportTicketService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User user = getSessionUser(request);
        if (user == null) { redirectToLogin(request, response); return; }

        try {
            String path = request.getPathInfo();
            if (path == null) path = "/";

            if (path.startsWith("/ticket/")) {
                // Ticket detail + chat
                int ticketId = parseIntOrDefault(path.substring("/ticket/".length()), -1);
                SupportTicket ticket = ticketService.getById(ticketId);
                if (ticket == null || ticket.getUserId() != user.getUserId()) {
                    response.sendError(HttpServletResponse.SC_NOT_FOUND);
                    return;
                }
                List<TicketMessage> messages = ticketService.getMessages(ticketId, false);
                ticket.setMessages(messages);
                request.setAttribute("ticket", ticket);
                request.setAttribute("currentUserId", user.getUserId());
                request.getRequestDispatcher("/organizer/support-detail.jsp").forward(request, response);
            } else {
                // List organizer's tickets
                List<SupportTicket> tickets = ticketService.getByUser(user.getUserId());
                request.setAttribute("tickets", tickets);
                request.getRequestDispatcher("/organizer/support.jsp").forward(request, response);
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to load organizer support", e);
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        User user = getSessionUser(request);
        if (user == null) { redirectToLogin(request, response); return; }

        String path = request.getPathInfo();
        if (path == null) path = "/";

        String ctx = request.getContextPath();

        if (path.equals("/create")) {
            SupportTicket ticket = new SupportTicket();
            ticket.setUserId(user.getUserId());
            ticket.setCategory(request.getParameter("category"));
            ticket.setSubject(request.getParameter("subject"));
            ticket.setDescription(request.getParameter("description"));
            // Organizer tickets always routed to admin with urgent priority
            ticket.setRoutedTo("admin");
            ticket.setPriority("urgent");

            int id = ticketService.createTicket(ticket);
            if (id > 0) {
                setToast(request, "Đã gửi yêu cầu hỗ trợ! Ticket sẽ được ưu tiên xử lý.", "success");
                LOGGER.log(Level.INFO, "Organizer support ticket created: {0} by user {1}", new Object[]{id, user.getUserId()});
            } else {
                setToast(request, "Gửi yêu cầu thất bại!", "error");
            }
            response.sendRedirect(ctx + "/organizer/support");

        } else if (path.equals("/reply")) {
            int ticketId = parseIntOrDefault(request.getParameter("ticketId"), -1);
            String content = request.getParameter("content");
            if (ticketId > 0 && content != null && !content.trim().isEmpty()) {
                SupportTicket ticket = ticketService.getById(ticketId);
                if (ticket != null && ticket.getUserId() == user.getUserId()) {
                    ticketService.addReply(ticketId, user.getUserId(), content.trim(), false);
                }
            }
            response.sendRedirect(ctx + "/organizer/support/ticket/" + ticketId);

        } else {
            response.sendRedirect(ctx + "/organizer/support");
        }
    }
}
