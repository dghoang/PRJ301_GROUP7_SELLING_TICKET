package com.sellingticket.controller;

import com.sellingticket.service.DashboardService;
import java.io.IOException;
import java.util.Map;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(name = "StaticPagesServlet", urlPatterns = {"/categories", "/about", "/faq"})
public class StaticPagesServlet extends HttpServlet {

    private final DashboardService dashboardService = new DashboardService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();
        
        switch (path) {
            case "/categories":
                request.getRequestDispatcher("categories.jsp").forward(request, response);
                break;
            case "/about":
                try {
                    Map<String, Object> stats = dashboardService.getAdminDashboardStats();
                    request.setAttribute("totalEvents", stats.getOrDefault("totalEvents", 0));
                    request.setAttribute("totalUsers", stats.getOrDefault("totalUsers", 0));
                } catch (Exception ignored) {}
                request.getRequestDispatcher("about.jsp").forward(request, response);
                break;
            case "/faq":
                request.getRequestDispatcher("faq.jsp").forward(request, response);
                break;
            default:
                response.sendRedirect(request.getContextPath() + "/home");
        }
    }
}
