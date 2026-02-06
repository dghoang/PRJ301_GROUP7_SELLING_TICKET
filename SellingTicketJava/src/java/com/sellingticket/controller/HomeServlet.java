package com.sellingticket.controller;

import com.sellingticket.dao.EventDAO;
import com.sellingticket.dao.CategoryDAO;
import com.sellingticket.model.Event;
import com.sellingticket.model.Category;
import java.io.IOException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(name = "HomeServlet", urlPatterns = {"/home"})
public class HomeServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        try {
            EventDAO eventDAO = new EventDAO();
            CategoryDAO categoryDAO = new CategoryDAO();
            
            List<Event> featuredEvents = eventDAO.getFeaturedEvents(6);
            List<Event> upcomingEvents = eventDAO.getUpcomingEvents(8);
            List<Category> categories = categoryDAO.getAllCategories();
            
            request.setAttribute("featuredEvents", featuredEvents);
            request.setAttribute("upcomingEvents", upcomingEvents);
            request.setAttribute("categories", categories);
        } catch (Exception e) {
            e.printStackTrace(); // Log error for debugging
            // Continue rendering home page even if data fails (empty lists will be handled by JSP)
            // Or set an error attribute
            request.setAttribute("error", "System error: " + e.getMessage());
        }
        
        request.getRequestDispatcher("home.jsp").forward(request, response);
    }
}
