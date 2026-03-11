package com.sellingticket.filter;

import java.io.IOException;
import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.FilterConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.http.HttpServletResponse;

/**
 * CacheFilter - Applies HTTP cache-control headers to static assets.
 */
public class CacheFilter implements Filter {

    private long maxAge = 31536000L; // 1 year default

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        String maxAgeParam = filterConfig.getInitParameter("maxAge");
        if (maxAgeParam != null) {
            try {
                this.maxAge = Long.parseLong(maxAgeParam);
            } catch (NumberFormatException e) {
                // ignore, use default
            }
        }
    }

    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
            throws IOException, ServletException {
        HttpServletResponse response = (HttpServletResponse) res;
        
        // Tells browser to cache the file. 'public' means CDNs can also cache it.
        response.setHeader("Cache-Control", "public, max-age=" + maxAge + ", immutable");
        
        chain.doFilter(req, res);
    }

    @Override
    public void destroy() {
    }
}
