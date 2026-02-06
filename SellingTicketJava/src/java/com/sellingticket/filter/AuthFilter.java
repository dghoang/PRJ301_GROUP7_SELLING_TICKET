package com.sellingticket.filter;

import com.sellingticket.model.User;
import java.io.IOException;
import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.FilterConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

/**
 * Authorization Filter - Phân quyền người dùng theo nghiệp vụ
 * Role: customer, organizer, admin
 */
@WebFilter(filterName = "AuthFilter", urlPatterns = {"/organizer/*", "/admin/*", "/checkout", "/tickets", "/order-confirmation"})
public class AuthFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        // Initialization
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;
        HttpSession session = httpRequest.getSession(false);
        
        String uri = httpRequest.getRequestURI();
        String contextPath = httpRequest.getContextPath();
        
        // Check if user is logged in
        User user = null;
        if (session != null) {
            user = (User) session.getAttribute("account");
        }
        
        // If not logged in, redirect to login
        if (user == null) {
            httpResponse.sendRedirect(contextPath + "/login?redirect=" + uri);
            return;
        }
        
        String role = user.getRole();
        
        // Check authorization based on URI and role
        if (uri.startsWith(contextPath + "/admin")) {
            // Only admin can access /admin/*
            if (!"admin".equals(role)) {
                httpResponse.sendRedirect(contextPath + "/home?error=unauthorized");
                return;
            }
        } else if (uri.startsWith(contextPath + "/organizer")) {
            // Only organizer or admin can access /organizer/*
            if (!"organizer".equals(role) && !"admin".equals(role)) {
                httpResponse.sendRedirect(contextPath + "/home?error=unauthorized");
                return;
            }
        }
        // For /checkout, /tickets, /order-confirmation - any logged-in user can access
        
        // User is authorized, continue
        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {
        // Cleanup
    }
}
