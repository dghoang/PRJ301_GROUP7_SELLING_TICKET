package com.sellingticket.controller.organizer;

import com.sellingticket.model.Event;
import com.sellingticket.model.TicketType;
import com.sellingticket.model.User;
import com.sellingticket.service.CategoryService;
import com.sellingticket.service.EventService;
import com.sellingticket.service.TicketService;
import static com.sellingticket.util.ServletUtil.*;

import java.io.IOException;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(name = "OrganizerEventController", urlPatterns = {
    "/organizer/events", "/organizer/events/*", "/organizer/create-event"
})
public class OrganizerEventController extends HttpServlet {

    private final EventService eventService = new EventService();
    private final CategoryService categoryService = new CategoryService();
    private final TicketService ticketService = new TicketService();
    private final SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm");

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User user = getSessionUser(request);
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String path = request.getServletPath();
        String pathInfo = request.getPathInfo();

        if ("/organizer/create-event".equals(path)) {
            showCreateForm(request, response);
        } else if (pathInfo != null && pathInfo.matches("/\\d+/edit")) {
            showEditForm(request, response, user);
        } else if (pathInfo != null && pathInfo.matches("/\\d+")) {
            viewEvent(request, response, user);
        } else {
            listEvents(request, response, user);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User user = getSessionUser(request);
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String path = request.getServletPath();
        String pathInfo = request.getPathInfo();

        if ("/organizer/create-event".equals(path)) {
            createEvent(request, response, user);
        } else if ("/update".equals(pathInfo)) {
            updateEvent(request, response, user);
        } else if ("/delete".equals(pathInfo)) {
            deleteEvent(request, response, user);
        } else {
            response.sendRedirect(request.getContextPath() + "/organizer/events");
        }
    }

    private void listEvents(HttpServletRequest request, HttpServletResponse response, User user)
            throws ServletException, IOException {

        request.setAttribute("events", eventService.getEventsByOrganizer(user.getUserId()));
        request.getRequestDispatcher("/organizer/events.jsp").forward(request, response);
    }

    private void viewEvent(HttpServletRequest request, HttpServletResponse response, User user)
            throws ServletException, IOException {

        Event event = getOwnedEvent(request.getPathInfo(), user);
        if (event == null) {
            response.sendRedirect(request.getContextPath() + "/organizer/events?error=notfound");
            return;
        }

        request.setAttribute("event", event);
        request.getRequestDispatcher("/organizer/event-detail.jsp").forward(request, response);
    }

    private void showCreateForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setAttribute("categories", categoryService.getAllCategories());
        request.getRequestDispatcher("/organizer/create-event.jsp").forward(request, response);
    }

    private void showEditForm(HttpServletRequest request, HttpServletResponse response, User user)
            throws ServletException, IOException {

        Event event = getOwnedEvent(request.getPathInfo(), user);
        if (event == null) {
            response.sendRedirect(request.getContextPath() + "/organizer/events?error=access_denied");
            return;
        }

        request.setAttribute("event", event);
        request.setAttribute("categories", categoryService.getAllCategories());
        request.getRequestDispatcher("/organizer/edit-event.jsp").forward(request, response);
    }

    private void createEvent(HttpServletRequest request, HttpServletResponse response, User user)
            throws ServletException, IOException {

        try {
            Event event = buildEventFromRequest(request, user);
            event.setStatus("pending");
            event.setFeatured(false);

            List<TicketType> tickets = parseTicketTypes(request);

            if (eventService.createEventWithTickets(event, tickets)) {
                response.sendRedirect(request.getContextPath() + "/organizer/events?success=created");
            } else {
                request.setAttribute("error", "Failed to create event");
                showCreateForm(request, response);
            }
        } catch (ParseException e) {
            request.setAttribute("error", "Invalid date format");
            showCreateForm(request, response);
        } catch (NumberFormatException e) {
            request.setAttribute("error", "Invalid category");
            showCreateForm(request, response);
        }
    }

    private void updateEvent(HttpServletRequest request, HttpServletResponse response, User user)
            throws IOException {

        int eventId = parseIntOrDefault(request.getParameter("eventId"), -1);
        if (eventId <= 0) {
            response.sendRedirect(request.getContextPath() + "/organizer/events?error=update_failed");
            return;
        }

        Event existing = eventService.getEventDetails(eventId);
        if (existing == null || existing.getOrganizerId() != user.getUserId()) {
            response.sendRedirect(request.getContextPath() + "/organizer/events?error=update_failed");
            return;
        }

        try {
            existing.setCategoryId(Integer.parseInt(request.getParameter("categoryId")));
            existing.setTitle(request.getParameter("title"));
            existing.setDescription(request.getParameter("description"));
            existing.setBannerImage(request.getParameter("bannerImage"));
            existing.setLocation(request.getParameter("location"));
            existing.setAddress(request.getParameter("address"));
            existing.setStartDate(dateFormat.parse(request.getParameter("startDate")));

            String endDateStr = request.getParameter("endDate");
            if (endDateStr != null && !endDateStr.isEmpty()) {
                existing.setEndDate(dateFormat.parse(endDateStr));
            }

            if (eventService.updateEvent(existing)) {
                response.sendRedirect(request.getContextPath() + "/organizer/events?success=updated");
                return;
            }
        } catch (ParseException e) {
            // fall through to error
        }

        response.sendRedirect(request.getContextPath() + "/organizer/events?error=update_failed");
    }

    private void deleteEvent(HttpServletRequest request, HttpServletResponse response, User user)
            throws IOException {

        int eventId = parseIntOrDefault(request.getParameter("eventId"), -1);
        if (eventId <= 0) {
            response.sendRedirect(request.getContextPath() + "/organizer/events?error=delete_failed");
            return;
        }

        Event existing = eventService.getEventDetails(eventId);
        if (existing != null && existing.getOrganizerId() == user.getUserId() && eventService.deleteEvent(eventId)) {
            response.sendRedirect(request.getContextPath() + "/organizer/events?success=deleted");
            return;
        }

        response.sendRedirect(request.getContextPath() + "/organizer/events?error=delete_failed");
    }

    private Event getOwnedEvent(String pathInfo, User user) {
        int eventId = getIdFromPath(pathInfo);
        if (eventId <= 0) return null;

        Event event = eventService.getEventDetails(eventId);
        if (event == null || event.getOrganizerId() != user.getUserId()) return null;
        return event;
    }

    private Event buildEventFromRequest(HttpServletRequest request, User user) throws ParseException {
        Event event = new Event();
        event.setOrganizerId(user.getUserId());
        event.setCategoryId(Integer.parseInt(request.getParameter("categoryId")));
        event.setTitle(request.getParameter("title"));
        event.setSlug(generateSlug(request.getParameter("title")));
        event.setDescription(request.getParameter("description"));
        event.setBannerImage(request.getParameter("bannerImage"));
        event.setLocation(request.getParameter("location"));
        event.setAddress(request.getParameter("address"));
        event.setStartDate(dateFormat.parse(request.getParameter("startDate")));
        event.setPrivate("on".equals(request.getParameter("isPrivate")));

        String endDateStr = request.getParameter("endDate");
        if (endDateStr != null && !endDateStr.isEmpty()) {
            event.setEndDate(dateFormat.parse(endDateStr));
        }
        return event;
    }

    private String generateSlug(String title) {
        if (title == null) return "";
        return title.toLowerCase()
                .replaceAll("[^a-z0-9\\s-]", "")
                .replaceAll("\\s+", "-")
                .replaceAll("-+", "-")
                + "-" + System.currentTimeMillis();
    }

    private List<TicketType> parseTicketTypes(HttpServletRequest request) {
        List<TicketType> tickets = new ArrayList<>();

        String[] names = request.getParameterValues("ticketName[]");
        String[] prices = request.getParameterValues("ticketPrice[]");
        String[] quantities = request.getParameterValues("ticketQuantity[]");

        if (names == null || prices == null || quantities == null) return tickets;

        for (int i = 0; i < names.length; i++) {
            if (names[i] == null || names[i].isEmpty()) continue;
            TicketType ticket = new TicketType();
            ticket.setName(names[i]);
            ticket.setPrice(Double.parseDouble(prices[i]));
            ticket.setQuantity(Integer.parseInt(quantities[i]));
            tickets.add(ticket);
        }

        return tickets;
    }
}
