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
import java.util.Set;
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
@WebServlet(name = "SupportTicketServlet", urlPatterns = {"/support/*", "/my-support-tickets"})
public class SupportTicketServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(SupportTicketServlet.class.getName());
    private static final Set<String> VALID_CATEGORIES = Set.of(
            "order", "payment", "refund", "event", "account", "technical", "other");
    private static final int MAX_SUBJECT_LENGTH = 200;
    private static final int MAX_DESCRIPTION_LENGTH = 5000;
    private static final int MAX_REPLY_LENGTH = 5000;
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

        // Backward compatibility for legacy route /my-support-tickets.
        if ("/my-support-tickets".equals(request.getServletPath())) {
            response.sendRedirect(request.getContextPath() + "/support/my-tickets");
            return;
        }

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
            String category = request.getParameter("category");
            String subject = request.getParameter("subject");
            String description = request.getParameter("description");

            // Validate required fields
            if (subject == null || subject.trim().isEmpty() ||
                description == null || description.trim().isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/support/new?error=missing_fields");
                return;
            }

            // Validate category (whitelist) — allow null/empty (defaults to "other")
            if (category == null || !VALID_CATEGORIES.contains(category.trim().toLowerCase())) {
                category = "other";
            }

            // Enforce length limits
            subject = subject.trim();
            if (subject.length() > MAX_SUBJECT_LENGTH) {
                subject = subject.substring(0, MAX_SUBJECT_LENGTH);
            }
            description = description.trim();
            if (description.length() > MAX_DESCRIPTION_LENGTH) {
                description = description.substring(0, MAX_DESCRIPTION_LENGTH);
            }

            SupportTicket ticket = new SupportTicket();
            ticket.setUserId(user.getUserId());
            ticket.setCategory(category.trim().toLowerCase());
            ticket.setSubject(subject);
            ticket.setDescription(description);
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
                // Enforce length limit
                String trimmed = content.trim();
                if (trimmed.length() > MAX_REPLY_LENGTH) {
                    trimmed = trimmed.substring(0, MAX_REPLY_LENGTH);
                }
                // Verify ownership
                SupportTicket ticket = ticketService.getById(ticketId);
                if (ticket != null && ticket.getUserId() == user.getUserId()) {
                    ticketService.addReply(ticketId, user.getUserId(), trimmed, false);
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
