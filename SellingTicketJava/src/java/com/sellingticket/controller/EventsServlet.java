package com.sellingticket.controller;

import com.sellingticket.dao.CategoryDAO;
import com.sellingticket.dao.EventDAO;
import com.sellingticket.model.Category;
import com.sellingticket.model.Event;
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

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        EventDAO dao = new EventDAO();
        CategoryDAO categoryDAO = new CategoryDAO();

        String category = request.getParameter("category");
        String search = request.getParameter("search");
        int page = parseIntOrDefault(request.getParameter("page"), 1);

        List<Event> events = dao.searchEvents(search, category, null, page, PAGE_SIZE);
        List<Category> categories = categoryDAO.getAllCategories();

        request.setAttribute("events", events);
        request.setAttribute("categories", categories);
        request.setAttribute("selectedCategory", category);
        request.setAttribute("searchQuery", search != null ? search : "");
        request.setAttribute("currentPage", page);

        request.getRequestDispatcher("events.jsp").forward(request, response);
    }
}
