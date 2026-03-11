package com.sellingticket.controller.admin;

import java.io.IOException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * Legacy redirect — event approval is now merged into /admin/events.
 */
@WebServlet(name = "AdminEventApprovalController", urlPatterns = {"/admin/event-approval"})
public class AdminEventApprovalController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.sendRedirect(request.getContextPath() + "/admin/events?status=pending");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.sendRedirect(request.getContextPath() + "/admin/events?status=pending");
    }
}
