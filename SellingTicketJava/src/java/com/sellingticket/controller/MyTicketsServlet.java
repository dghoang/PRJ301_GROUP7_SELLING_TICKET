package com.sellingticket.controller;

import com.sellingticket.model.User;
import static com.sellingticket.util.ServletUtil.getSessionUser;
import static com.sellingticket.util.ServletUtil.redirectToLogin;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * Displays the logged-in user's ticket/order history.
 * Loads individual tickets with QR codes for each order.
 */
@WebServlet(name = "MyTicketsServlet", urlPatterns = {"/my-tickets"})
public class MyTicketsServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User user = getSessionUser(request);
        if (user == null) {
            redirectToLogin(request, response);
            return;
        }

        // JSP uses AJAX calls to /api/my-tickets and /api/my-orders for data loading.
        // No need to pre-load data here.
        request.getRequestDispatcher("my-tickets.jsp").forward(request, response);
    }
}
