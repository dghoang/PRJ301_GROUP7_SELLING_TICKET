package com.sellingticket.service;

import com.sellingticket.dao.DashboardDAO;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * DashboardService — Business logic layer wrapping DashboardDAO.
 * Controllers should use this service instead of calling DAO directly.
 */
public class DashboardService {

    private static final Logger LOGGER = Logger.getLogger(DashboardService.class.getName());
    private final DashboardDAO dashboardDAO;

    public DashboardService() {
        this.dashboardDAO = new DashboardDAO();
    }

    // ========================
    // ADMIN STATS
    // ========================

    public Map<String, Object> getAdminDashboardStats() {
        try {
            return dashboardDAO.getAdminDashboardStats();
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Service error: getAdminDashboardStats", e);
            throw new ServiceException("DASHBOARD_ERROR", "Failed to load admin dashboard stats", e);
        }
    }

    public List<Map<String, Object>> getCategoryDistribution() {
        try {
            return dashboardDAO.getCategoryDistribution();
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Service error: getCategoryDistribution", e);
            throw new ServiceException("DASHBOARD_ERROR", "Failed to load category distribution", e);
        }
    }

    public List<Map<String, Object>> getRevenueByDays(int days) {
        if (days <= 0 || days > 365) days = 7;
        try {
            return dashboardDAO.getRevenueByDays(days);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Service error: getRevenueByDays", e);
            throw new ServiceException("DASHBOARD_ERROR", "Failed to load revenue data", e);
        }
    }

    // ========================
    // ORGANIZER STATS
    // ========================

    public Map<String, Object> getOrganizerDashboardStats(int organizerId) {
        try {
            return dashboardDAO.getOrganizerDashboardStats(organizerId);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Service error: getOrganizerDashboardStats", e);
            throw new ServiceException("DASHBOARD_ERROR", "Failed to load organizer stats", e);
        }
    }

    public List<Map<String, Object>> getOrganizerEventStats(int organizerId) {
        try {
            return dashboardDAO.getOrganizerEventStats(organizerId);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Service error: getOrganizerEventStats", e);
            throw new ServiceException("DASHBOARD_ERROR", "Failed to load organizer event stats", e);
        }
    }

    public List<Map<String, Object>> getOrganizerRevenueByDays(int organizerId, int days) {
        if (days <= 0 || days > 365) days = 7;
        try {
            return dashboardDAO.getOrganizerRevenueByDays(organizerId, days);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Service error: getOrganizerRevenueByDays", e);
            throw new ServiceException("DASHBOARD_ERROR", "Failed to load organizer revenue data", e);
        }
    }

    public List<Map<String, Object>> getOrganizerTicketDistribution(int organizerId) {
        try {
            return dashboardDAO.getOrganizerTicketDistribution(organizerId);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Service error: getOrganizerTicketDistribution", e);
            throw new ServiceException("DASHBOARD_ERROR", "Failed to load organizer ticket distribution", e);
        }
    }

    public List<Map<String, Object>> getTopEventsByRevenue(int limit) {
        try {
            return dashboardDAO.getTopEventsByRevenue(limit);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Service error: getTopEventsByRevenue", e);
            return new java.util.ArrayList<>();
        }
    }

    public int getPendingEventsCount() {
        try {
            return dashboardDAO.getPendingEventsCount();
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Service error: getPendingEventsCount", e);
            return 0;
        }
    }

    public List<Map<String, Object>> getOrganizerHourlyDistribution(int organizerId) {
        try {
            return dashboardDAO.getOrganizerHourlyDistribution(organizerId);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Service error: getOrganizerHourlyDistribution", e);
            return new java.util.ArrayList<>();
        }
    }

    // ========================
    // EVENT-SPECIFIC STATS
    // ========================

    public Map<String, Object> getEventSpecificStats(int eventId) {
        try {
            return dashboardDAO.getEventSpecificStats(eventId);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Service error: getEventSpecificStats", e);
            return new java.util.HashMap<>();
        }
    }

    public List<Map<String, Object>> getEventRevenueByDays(int eventId, int days) {
        if (days <= 0 || days > 365) days = 7;
        try {
            return dashboardDAO.getEventRevenueByDays(eventId, days);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Service error: getEventRevenueByDays", e);
            return new java.util.ArrayList<>();
        }
    }

    // ========================
    // VOUCHER SETTLEMENT REPORTS
    // ========================

    public Map<String, Object> getVoucherSettlementStats() {
        try {
            return dashboardDAO.getVoucherSettlementStats();
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Service error: getVoucherSettlementStats", e);
            return new java.util.HashMap<>();
        }
    }

    public Map<String, Object> getOrganizerSettlementStats(int organizerId) {
        try {
            return dashboardDAO.getOrganizerSettlementStats(organizerId);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Service error: getOrganizerSettlementStats", e);
            return new java.util.HashMap<>();
        }
    }

    public List<Map<String, Object>> getEventSettlementBreakdown(int limit) {
        try {
            return dashboardDAO.getEventSettlementBreakdown(limit);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Service error: getEventSettlementBreakdown", e);
            return new java.util.ArrayList<>();
        }
    }
}
