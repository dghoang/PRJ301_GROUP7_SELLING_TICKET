package com.sellingticket.controller;

import com.sellingticket.model.Category;
import com.sellingticket.model.Event;
import com.sellingticket.service.EventService;
import static com.sellingticket.util.ServletUtil.parseIntOrDefault;

import java.io.IOException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(name = "EventsServlet", urlPatterns = {"/events"})
public class EventsServlet extends HttpServlet {

    private static final int PAGE_SIZE = 9;
    private final EventService eventService = new EventService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String category = request.getParameter("category");
        String search = request.getParameter("search");
        String dateFilter = request.getParameter("date");
        int page = parseIntOrDefault(request.getParameter("page"), 1);

        List<Event> events = eventService.searchEvents(search, category, dateFilter, page, PAGE_SIZE);
        List<Category> categories = eventService.getAllCategories();
        int totalResults = eventService.countSearchEvents(search, category, dateFilter);
        int totalPages = (int) Math.ceil((double) totalResults / PAGE_SIZE);

        request.setAttribute("events", events);
        request.setAttribute("categories", categories);
        request.setAttribute("selectedCategory", category);
        request.setAttribute("searchQuery", search != null ? search : "");
        request.setAttribute("currentPage", page);
        request.setAttribute("totalResults", totalResults);
        request.setAttribute("totalPages", totalPages);

        request.getRequestDispatcher("events.jsp").forward(request, response);
    }
}
