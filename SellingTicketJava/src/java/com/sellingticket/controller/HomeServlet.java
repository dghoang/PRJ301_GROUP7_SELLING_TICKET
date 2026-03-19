package com.sellingticket.controller;

import com.sellingticket.model.Event;
import com.sellingticket.model.Category;
import com.sellingticket.service.DashboardService;
import com.sellingticket.service.EventService;
import java.io.IOException;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(name = "HomeServlet", urlPatterns = {"/home"})
public class HomeServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(HomeServlet.class.getName());
    private final EventService eventService = new EventService();
    private final DashboardService dashboardService = new DashboardService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            List<Event> featuredEvents = eventService.getFeaturedEvents(6);
            List<Event> upcomingEvents = eventService.getUpcomingEvents(8);
            List<Category> categories = eventService.getAllCategories();

            request.setAttribute("featuredEvents", featuredEvents);
            request.setAttribute("upcomingEvents", upcomingEvents);
            request.setAttribute("categories", categories);

            // Public stats for hero section (real data)
            Map<String, Object> publicStats = dashboardService.getPublicStats();
            request.setAttribute("publicStats", publicStats);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error loading home page data", e);
            request.setAttribute("featuredEvents", Collections.emptyList());
            request.setAttribute("upcomingEvents", Collections.emptyList());
            request.setAttribute("categories", Collections.emptyList());
            request.setAttribute("publicStats", Collections.emptyMap());
        }

        request.getRequestDispatcher("home.jsp").forward(request, response);
    }
}
