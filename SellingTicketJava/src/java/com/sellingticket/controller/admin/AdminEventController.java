package com.sellingticket.controller.admin;

import com.sellingticket.model.Event;
import com.sellingticket.service.CategoryService;
import com.sellingticket.service.EventService;
import static com.sellingticket.util.ServletUtil.*;

import java.io.IOException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(name = "AdminEventController", urlPatterns = {"/admin/events", "/admin/events/*"})
public class AdminEventController extends HttpServlet {

    private final EventService eventService = new EventService();
    private final CategoryService categoryService = new CategoryService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = getAction(request.getPathInfo());

        switch (action) {
            case "pending": listPendingEvents(request, response); break;
            case "view":    viewEvent(request, response); break;
            default:        listEvents(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = getAction(request.getPathInfo());

        switch (action) {
            case "approve": approveEvent(request, response); break;
            case "reject":  rejectEvent(request, response); break;
            case "delete":  deleteEvent(request, response); break;
            case "feature": toggleFeatured(request, response); break;
            default: response.sendRedirect(request.getContextPath() + "/admin/events");
        }
    }

    private String getAction(String pathInfo) {
        if (pathInfo == null || pathInfo.equals("/")) return "list";
        String action = pathInfo.substring(1);
        return action.matches("\\d+") ? "view" : action;
    }

    private void listEvents(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String status = request.getParameter("status");
        int page = parseIntOrDefault(request.getParameter("page"), 1);

        List<Event> events = eventService.getAllEvents(status, page, 20);

        request.setAttribute("events", events);
        request.setAttribute("currentPage", page);
        request.setAttribute("statusFilter", status);
        request.setAttribute("categories", categoryService.getAllCategories());
        request.setAttribute("approvedCount", eventService.countEventsByStatus("approved"));
        request.setAttribute("pendingCount", eventService.countEventsByStatus("pending"));
        request.setAttribute("rejectedCount", eventService.countEventsByStatus("rejected"));

        request.getRequestDispatcher("/admin/events.jsp").forward(request, response);
    }

    private void listPendingEvents(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setAttribute("events", eventService.getPendingEvents());
        request.setAttribute("statusFilter", "pending");
        request.getRequestDispatcher("/admin/events.jsp").forward(request, response);
    }

    private void viewEvent(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int eventId = getIdFromPath(request.getPathInfo());
        if (eventId < 0) {
            eventId = parseIntOrDefault(request.getParameter("id"), -1);
        }

        if (eventId > 0) {
            Event event = eventService.getEventDetails(eventId);
            if (event != null) {
                request.setAttribute("event", event);
                request.getRequestDispatcher("/admin/event-detail.jsp").forward(request, response);
                return;
            }
        }

        response.sendRedirect(request.getContextPath() + "/admin/events?error=notfound");
    }

    private void approveEvent(HttpServletRequest request, HttpServletResponse response) throws IOException {
        int eventId = parseIntOrDefault(request.getParameter("eventId"), -1);
        String result = (eventId > 0 && eventService.approveEvent(eventId)) ? "success=approved" : "error=approve_failed";
        response.sendRedirect(request.getContextPath() + "/admin/events?" + result);
    }

    private void rejectEvent(HttpServletRequest request, HttpServletResponse response) throws IOException {
        int eventId = parseIntOrDefault(request.getParameter("eventId"), -1);
        String result = (eventId > 0 && eventService.rejectEvent(eventId)) ? "success=rejected" : "error=reject_failed";
        response.sendRedirect(request.getContextPath() + "/admin/events?" + result);
    }

    private void deleteEvent(HttpServletRequest request, HttpServletResponse response) throws IOException {
        int eventId = parseIntOrDefault(request.getParameter("eventId"), -1);
        String result = (eventId > 0 && eventService.deleteEvent(eventId)) ? "success=deleted" : "error=delete_failed";
        response.sendRedirect(request.getContextPath() + "/admin/events?" + result);
    }

    private void toggleFeatured(HttpServletRequest request, HttpServletResponse response) throws IOException {
        int eventId = parseIntOrDefault(request.getParameter("eventId"), -1);
        boolean featured = "true".equals(request.getParameter("featured"));
        String result = (eventId > 0 && eventService.setFeatured(eventId, featured)) ? "success=updated" : "error=update_failed";
        response.sendRedirect(request.getContextPath() + "/admin/events?" + result);
    }
}
