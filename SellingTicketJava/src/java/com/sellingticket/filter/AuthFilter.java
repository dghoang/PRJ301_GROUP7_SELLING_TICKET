package com.sellingticket.filter;

import com.sellingticket.model.User;
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

@WebFilter(filterName = "AuthFilter", urlPatterns = {"/organizer/*", "/admin/*", "/checkout", "/tickets", "/order-confirmation"})
public class AuthFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {}

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;

        User user = getSessionUser(httpRequest);
        String uri = httpRequest.getRequestURI();
        String contextPath = httpRequest.getContextPath();

        if (user == null) {
            httpResponse.sendRedirect(contextPath + "/login?redirect=" + uri);
            return;
        }

        String role = user.getRole();

        if (uri.startsWith(contextPath + "/admin") && !"admin".equals(role)) {
            httpResponse.sendRedirect(contextPath + "/home?error=unauthorized");
            return;
        }

        if (uri.startsWith(contextPath + "/organizer") && !"organizer".equals(role) && !"admin".equals(role)) {
            httpResponse.sendRedirect(contextPath + "/home?error=unauthorized");
            return;
        }

        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {}
}
