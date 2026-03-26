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

        // Admins and Support Agents always pass globally
        if ("admin".equals(user.getRole()) || "support_agent".equals(user.getRole())) {
            chain.doFilter(request, response);
            return;
        }

        // Check if user is assigned to any event as staff OR owns any event
        List<Integer> assignedEvents = eventStaffDAO.getEventsWhereStaff(user.getUserId());

        // Also check if user is an event owner (organizer_id)
        com.sellingticket.dao.EventDAO eventDAO = new com.sellingticket.dao.EventDAO();
        List<com.sellingticket.model.Event> ownedEvents = eventDAO.getEventsByOrganizer(user.getUserId());
        java.util.Set<Integer> allEventIds = new java.util.LinkedHashSet<>(assignedEvents);
        for (com.sellingticket.model.Event e : ownedEvents) {
            allEventIds.add(e.getEventId());
        }

        if (allEventIds.isEmpty()) {
            com.sellingticket.util.ServletUtil.setToast(httpReq, "Tài khoản của bạn chưa được phân công sự kiện nào!", "error");
            httpRes.sendRedirect(httpReq.getContextPath() + "/home");
            return;
        }

        httpReq.setAttribute("staffAssignedEvents", new java.util.ArrayList<>(allEventIds));
        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {}
}
