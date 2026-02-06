package com.sellingticket.controller;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(name = "AdminServlet", urlPatterns = {"/admin", "/admin/events", "/admin/users", "/admin/reports"})
public class AdminServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();
        
        switch (path) {
            case "/admin":
                request.getRequestDispatcher("/admin/dashboard.jsp").forward(request, response);
                break;
            case "/admin/events":
                request.getRequestDispatcher("/admin/events.jsp").forward(request, response);
                break;
            case "/admin/users":
                request.getRequestDispatcher("/admin/users.jsp").forward(request, response);
                break;
            case "/admin/reports":
                request.getRequestDispatcher("/admin/reports.jsp").forward(request, response);
                break;
            default:
                request.getRequestDispatcher("/admin/dashboard.jsp").forward(request, response);
        }
    }
}
