package com.sellingticket.filter;

import com.sellingticket.dao.EventStaffDAO;
import com.sellingticket.model.User;
import static com.sellingticket.util.ServletUtil.getSessionUser;

import java.io.IOException;
import java.util.List;
import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.FilterConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * StaffAccessFilter - Protects /staff/* routes.
 * Only users who appear in the EventStaff table (or are admin) may access the staff portal.
 */
@WebFilter(filterName = "StaffAccessFilter", urlPatterns = {"/staff/*", "/staff"})
public class StaffAccessFilter implements Filter {

    private EventStaffDAO eventStaffDAO;

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        eventStaffDAO = new EventStaffDAO();
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest httpReq = (HttpServletRequest) request;
        HttpServletResponse httpRes = (HttpServletResponse) response;

        User user = getSessionUser(httpReq);
        if (user == null) {
            // Let AuthFilter redirect to login
            chain.doFilter(request, response);
            return;
        }

        // Admins always pass
        if ("admin".equals(user.getRole())) {
            chain.doFilter(request, response);
            return;
        }

        // Check if user is assigned to any event as staff
        List<Integer> assignedEvents = eventStaffDAO.getEventsWhereStaff(user.getUserId());
        if (assignedEvents.isEmpty()) {
            httpRes.sendRedirect(httpReq.getContextPath() + "/?error=no_staff_access");
            return;
        }

        httpReq.setAttribute("staffAssignedEvents", assignedEvents);
        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {}
}
