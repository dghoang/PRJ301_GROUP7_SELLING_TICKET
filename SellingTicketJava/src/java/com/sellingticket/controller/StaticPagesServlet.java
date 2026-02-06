package com.sellingticket.controller;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(name = "StaticPagesServlet", urlPatterns = {"/categories", "/about", "/faq"})
public class StaticPagesServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();
        
        switch (path) {
            case "/categories":
                request.getRequestDispatcher("categories.jsp").forward(request, response);
                break;
            case "/about":
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
