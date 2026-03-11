package com.sellingticket.controller;

import com.sellingticket.model.SupportTicket;
import com.sellingticket.model.TicketMessage;
import com.sellingticket.model.User;
import com.sellingticket.service.SupportTicketService;
import static com.sellingticket.util.ServletUtil.getSessionUser;
import static com.sellingticket.util.ServletUtil.parseIntOrDefault;
import static com.sellingticket.util.ServletUtil.redirectToLogin;

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
 * Customer-facing support ticket controller.
 * - GET /support/new?orderId=X      → ticket creation form
 * - POST /support/create            → save ticket
 * - GET /support/my-tickets         → list customer's tickets
 * - GET /support/ticket/{id}        → ticket detail + messages
 * - POST /support/reply             → add reply
 */
@WebServlet(name = "SupportTicketServlet", urlPatterns = {"/support/*"})
public class SupportTicketServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(SupportTicketServlet.class.getName());
    private final SupportTicketService ticketService = new SupportTicketService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User user = getSessionUser(request);
        if (user == null) {
            redirectToLogin(request, response);
            return;
        }

        String path = request.getPathInfo();
        if (path == null) path = "/";

        if (path.equals("/new")) {
            // Show form
            request.setAttribute("orderId", request.getParameter("orderId"));
            request.setAttribute("eventId", request.getParameter("eventId"));
            request.getRequestDispatcher("/support-ticket.jsp").forward(request, response);

        } else if (path.equals("/my-tickets")) {
            List<SupportTicket> tickets = ticketService.getByUser(user.getUserId());
            request.setAttribute("tickets", tickets);
            request.getRequestDispatcher("/my-support-tickets.jsp").forward(request, response);

        } else if (path.startsWith("/ticket/")) {
            int ticketId = parseIntOrDefault(path.substring("/ticket/".length()), -1);
            SupportTicket ticket = ticketService.getById(ticketId);
            if (ticket == null || ticket.getUserId() != user.getUserId()) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
                return;
            }
            List<TicketMessage> messages = ticketService.getMessages(ticketId, false);
            ticket.setMessages(messages);
            request.setAttribute("ticket", ticket);
            request.getRequestDispatcher("/support-ticket-detail.jsp").forward(request, response);

        } else {
            response.sendRedirect(request.getContextPath() + "/support/my-tickets");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        User user = getSessionUser(request);
        if (user == null) {
            redirectToLogin(request, response);
            return;
        }

        String path = request.getPathInfo();
        if (path == null) path = "/";

        if (path.equals("/create")) {
            SupportTicket ticket = new SupportTicket();
            ticket.setUserId(user.getUserId());
            ticket.setCategory(request.getParameter("category"));
            ticket.setSubject(request.getParameter("subject"));
            ticket.setDescription(request.getParameter("description"));
            String orderId = request.getParameter("orderId");
            if (orderId != null && !orderId.isEmpty()) {
                ticket.setOrderId(parseIntOrDefault(orderId, null));
            }
            String eventId = request.getParameter("eventId");
            if (eventId != null && !eventId.isEmpty()) {
                ticket.setEventId(parseIntOrDefault(eventId, null));
            }

            int id = ticketService.createTicket(ticket);
            if (id > 0) {
                response.sendRedirect(request.getContextPath() + "/support/my-tickets?success=created");
            } else {
                response.sendRedirect(request.getContextPath() + "/support/new?error=failed");
            }

        } else if (path.equals("/reply")) {
            int ticketId = parseIntOrDefault(request.getParameter("ticketId"), -1);
            String content = request.getParameter("content");
            if (ticketId > 0 && content != null && !content.trim().isEmpty()) {
                // Verify ownership
                SupportTicket ticket = ticketService.getById(ticketId);
                if (ticket != null && ticket.getUserId() == user.getUserId()) {
                    ticketService.addReply(ticketId, user.getUserId(), content.trim(), false);
                }
            }
            response.sendRedirect(request.getContextPath() + "/support/ticket/" + ticketId);

        } else {
            response.sendRedirect(request.getContextPath() + "/support/my-tickets");
        }
    }

    private Integer parseIntOrDefault(String s, Integer def) {
        if (s == null || s.isEmpty()) return def;
        try { return Integer.parseInt(s); } catch (NumberFormatException e) { return def; }
    }
}
