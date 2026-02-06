package com.sellingticket.controller;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(name = "OrganizerServlet", urlPatterns = {
    "/organizer",
    "/organizer/create-event",
    "/organizer/events",
    "/organizer/orders",
    "/organizer/vouchers",
    "/organizer/statistics",
    "/organizer/check-in"
})
public class OrganizerServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();
        
        switch (path) {
            case "/organizer":
                request.getRequestDispatcher("/organizer/dashboard.jsp").forward(request, response);
                break;
            case "/organizer/create-event":
                request.getRequestDispatcher("/organizer/create-event.jsp").forward(request, response);
                break;
            case "/organizer/events":
                request.getRequestDispatcher("/organizer/events.jsp").forward(request, response);
                break;
            case "/organizer/orders":
                request.getRequestDispatcher("/organizer/orders.jsp").forward(request, response);
                break;
            case "/organizer/vouchers":
                request.getRequestDispatcher("/organizer/vouchers.jsp").forward(request, response);
                break;
            case "/organizer/statistics":
                request.getRequestDispatcher("/organizer/statistics.jsp").forward(request, response);
                break;
            case "/organizer/check-in":
                request.getRequestDispatcher("/organizer/check-in.jsp").forward(request, response);
                break;
            default:
                request.getRequestDispatcher("/organizer/dashboard.jsp").forward(request, response);
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();
        
        if ("/organizer/create-event".equals(path)) {
            // Handle event creation
            // TODO: Implement event creation logic
            response.sendRedirect(request.getContextPath() + "/organizer/events");
        }
    }
}
