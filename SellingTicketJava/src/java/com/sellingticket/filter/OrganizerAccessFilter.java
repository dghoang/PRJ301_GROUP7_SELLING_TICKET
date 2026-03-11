package com.sellingticket.filter;

import com.sellingticket.model.User;
import com.sellingticket.service.EventService;
import static com.sellingticket.util.ServletUtil.getSessionUser;

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

/**
 * OrganizerAccessFilter
 * Blocks access to operational organizer pages (Orders, Tickets, Check-in, Vouchers, Statistics, Team)
 * if the user does not have any approved events. Protects /organizer/*
 */
@WebFilter(filterName = "OrganizerAccessFilter", urlPatterns = {"/organizer/*", "/organizer"})
public class OrganizerAccessFilter implements Filter {

    private EventService eventService;

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        eventService = new EventService();
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;

        User user = getSessionUser(httpRequest);
        if (user == null) {
            // Let AuthFilter handle login redirect
            chain.doFilter(request, response);
            return;
        }

        String pathInfo = httpRequest.getRequestURI().substring(httpRequest.getContextPath().length());
        
        int totalEvents = eventService.getEventsByOrganizer(user.getUserId()).size();
        
        // 1. Dashboard Lockout: If the user has 0 events, lock them out of the dashboard
        boolean isDashboard = pathInfo.equals("/organizer") || 
                              pathInfo.equals("/organizer/") || 
                              pathInfo.startsWith("/organizer/dashboard");
                              
        if (isDashboard && totalEvents == 0) {
            httpResponse.sendRedirect(httpRequest.getContextPath() + "/organizer/events?error=no_events");
            return;
        }

        // 2. Operational Lockout: Allowed paths that don't require an approved event
        boolean isExempt = isDashboard ||
                           pathInfo.startsWith("/organizer/events") ||
                           pathInfo.startsWith("/organizer/create-event") ||
                           pathInfo.startsWith("/organizer/settings") ||
                           pathInfo.startsWith("/organizer/chat");
                           
        if (!isExempt) {
            boolean hasApproved = eventService.hasApprovedEvents(user.getUserId(), user.getRole());
            if (!hasApproved) {
                httpResponse.sendRedirect(httpRequest.getContextPath() + "/organizer/events?error=unapproved_events");
                return;
            }
        }

        // 3. Event-Based Permission: If URL targets a specific event, verify ownership
        if (!"admin".equals(user.getRole())) {
            int eventId = extractEventId(pathInfo, httpRequest);
            if (eventId > 0) {
                boolean hasAccess = eventService.hasCheckInPermission(eventId, user.getUserId(), user.getRole());
                if (!hasAccess) {
                    httpResponse.sendRedirect(httpRequest.getContextPath() + "/organizer/events?error=no_permission");
                    return;
                }
            }
        }

        chain.doFilter(request, response);
    }

    /**
     * Extract eventId from URL path (e.g. /organizer/events/5/edit)
     * or from query parameters (e.g. ?eventId=5).
     */
    private int extractEventId(String pathInfo, HttpServletRequest request) {
        // Try URL path: /organizer/events/{id}/...
        if (pathInfo.startsWith("/organizer/events/")) {
            String rest = pathInfo.substring("/organizer/events/".length());
            String[] parts = rest.split("/");
            if (parts.length > 0) {
                try { return Integer.parseInt(parts[0]); } catch (NumberFormatException ignored) {}
            }
        }
        // Try query parameter
        String param = request.getParameter("eventId");
        if (param != null) {
            try { return Integer.parseInt(param); } catch (NumberFormatException ignored) {}
        }
        return 0;
    }

    @Override
    public void destroy() {}
}
