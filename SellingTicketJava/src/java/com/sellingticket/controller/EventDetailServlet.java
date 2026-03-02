package com.sellingticket.controller;

import com.sellingticket.model.Event;
import com.sellingticket.model.TicketType;
import com.sellingticket.service.EventService;
import com.sellingticket.service.TicketService;

import java.io.IOException;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
import java.util.regex.Pattern;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * Event detail page — now uses slug-based URLs for security and SEO.
 *
 * <p>Routes:
 * <ul>
 *   <li>{@code /event/my-event-slug} → loads by slug (primary)</li>
 *   <li>{@code /event-detail?id=5} → legacy redirect to slug URL</li>
 * </ul>
 */
@WebServlet(name = "EventDetailServlet", urlPatterns = {"/event/*", "/event-detail"})
public class EventDetailServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(EventDetailServlet.class.getName());
    private static final Pattern SLUG_PATTERN = Pattern.compile("^[a-z0-9][a-z0-9\\-]{1,200}$");

    private final EventService eventService = new EventService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String uri = request.getRequestURI();
        String contextPath = request.getContextPath();

        // --- Legacy ?id= support: redirect to slug URL ---
        if (uri.endsWith("/event-detail")) {
            handleLegacyRedirect(request, response, contextPath);
            return;
        }

        // --- Slug-based: /event/{slug} ---
        String pathInfo = request.getPathInfo();
        if (pathInfo == null || pathInfo.length() < 2) {
            response.sendRedirect(contextPath + "/events");
            return;
        }

        String slug = pathInfo.substring(1); // strip leading /
        if (!SLUG_PATTERN.matcher(slug).matches()) {
            response.sendRedirect(contextPath + "/events");
            return;
        }

        try {
            Event event = eventService.getEventBySlug(slug);
            if (event == null) {
                response.sendRedirect(contextPath + "/events");
                return;
            }

            List<TicketType> ticketTypes = event.getTicketTypes();
            List<Event> relatedEvents = eventService.getRelatedEvents(
                    event.getCategoryId(), event.getEventId(), 3);

            request.setAttribute("event", event);
            request.setAttribute("ticketTypes", ticketTypes);
            request.setAttribute("relatedEvents", relatedEvents);

            request.getRequestDispatcher("/event-detail.jsp").forward(request, response);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error loading event by slug: " + slug, e);
            response.sendRedirect(contextPath + "/events");
        }
    }

    /**
     * Legacy support: /event-detail?id=5 → 301 redirect to /event/{slug}
     */
    private void handleLegacyRedirect(HttpServletRequest request,
                                       HttpServletResponse response,
                                       String contextPath) throws IOException {
        String idParam = request.getParameter("id");
        if (idParam == null) {
            response.sendRedirect(contextPath + "/events");
            return;
        }
        try {
            int eventId = Integer.parseInt(idParam);
            Event event = eventService.getEventDetails(eventId);
            if (event != null && event.getSlug() != null) {
                response.setStatus(HttpServletResponse.SC_MOVED_PERMANENTLY);
                response.setHeader("Location", contextPath + "/event/" + event.getSlug());
            } else {
                response.sendRedirect(contextPath + "/events");
            }
        } catch (NumberFormatException e) {
            response.sendRedirect(contextPath + "/events");
        }
    }
}
