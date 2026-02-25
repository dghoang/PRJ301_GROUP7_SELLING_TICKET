package com.sellingticket.controller.admin;

import com.sellingticket.service.EventService;
import com.sellingticket.service.OrderService;
import com.sellingticket.service.UserService;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * AdminDashboardController - Handles admin dashboard with statistics
 */
@WebServlet(name = "AdminDashboardController", urlPatterns = {"/admin", "/admin/dashboard"})
public class AdminDashboardController extends HttpServlet {

    private final EventService eventService = new EventService();
    private final OrderService orderService = new OrderService();
    private final UserService userService = new UserService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Load dashboard statistics
        int totalEvents = eventService.getTotalEvents();
        int pendingEvents = eventService.countEventsByStatus("pending");
        int totalUsers = userService.getTotalUsers();
        double totalRevenue = orderService.getTotalRevenue();
        int pendingOrders = orderService.countOrdersByStatus("pending");
        int paidOrders = orderService.countOrdersByStatus("paid");
        
        // Set attributes for JSP
        request.setAttribute("totalEvents", totalEvents);
        request.setAttribute("pendingEvents", pendingEvents);
        request.setAttribute("totalUsers", totalUsers);
        request.setAttribute("totalRevenue", totalRevenue);
        request.setAttribute("pendingOrders", pendingOrders);
        request.setAttribute("paidOrders", paidOrders);
        
        // Load recent pending events for quick action
        request.setAttribute("pendingEventsList", eventService.getPendingEvents());
        
        request.getRequestDispatcher("/admin/dashboard.jsp").forward(request, response);
    }
}
