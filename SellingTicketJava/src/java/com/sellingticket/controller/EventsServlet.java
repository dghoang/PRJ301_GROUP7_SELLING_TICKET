package com.sellingticket.controller;

import com.sellingticket.dao.EventDAO;
import com.sellingticket.dao.CategoryDAO;
import com.sellingticket.dao.TicketTypeDAO;
import com.sellingticket.model.Event;
import com.sellingticket.model.Category;
import com.sellingticket.model.TicketType;
import java.io.IOException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(name = "EventsServlet", urlPatterns = {"/events"})
public class EventsServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        EventDAO dao = new EventDAO();
        CategoryDAO categoryDAO = new CategoryDAO();
        
        // Get filter parameters
        String category = request.getParameter("category");
        String search = request.getParameter("search");
        String pageStr = request.getParameter("page");
        
        int page = 1;
        if (pageStr != null && !pageStr.isEmpty()) {
            try {
                page = Integer.parseInt(pageStr);
            } catch (NumberFormatException e) {
                page = 1;
            }
        }
        
        int pageSize = 9; // Show 9 events per page
        
        List<Event> events = dao.searchEvents(search, category, null, page, pageSize);
        List<Category> categories = categoryDAO.getAllCategories();
        
        request.setAttribute("events", events);
        request.setAttribute("categories", categories);
        request.setAttribute("selectedCategory", category); // Keep strictly to parameter value
        request.setAttribute("searchQuery", search != null ? search : "");
        request.setAttribute("currentPage", page);
        
        request.getRequestDispatcher("events.jsp").forward(request, response);
    }
}
