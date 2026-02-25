package com.sellingticket.controller;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * OrganizerServlet - Handles organizer routes not covered by specific controllers.
 * Routes /organizer, /organizer/events, /organizer/orders, /organizer/create-event
 * are handled by OrganizerDashboardController, OrganizerEventController, OrganizerOrderController.
 */
@WebServlet(name = "OrganizerServlet", urlPatterns = {
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
                response.sendRedirect(request.getContextPath() + "/organizer/dashboard");
        }
    }
}
