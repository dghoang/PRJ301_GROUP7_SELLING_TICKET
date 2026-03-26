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

    public Map<String, Object> getPublicStats() {
        try {
            return dashboardDAO.getPublicStats();
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Service error: getPublicStats", e);
            return new java.util.HashMap<>();
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

    public Map<String, Object> getDashboardStatsForEvents(List<Integer> eventIds) {
        if (eventIds == null || eventIds.isEmpty()) return new java.util.HashMap<>();
        try {
            return dashboardDAO.getDashboardStatsForEvents(eventIds);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Service error: getDashboardStatsForEvents", e);
            throw new ServiceException("DASHBOARD_ERROR", "Failed to load organizer stats", e);
        }
    }

    public List<Map<String, Object>> getEventStatsForEvents(List<Integer> eventIds) {
        if (eventIds == null || eventIds.isEmpty()) return new java.util.ArrayList<>();
        try {
            return dashboardDAO.getEventStatsForEvents(eventIds);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Service error: getEventStatsForEvents", e);
            throw new ServiceException("DASHBOARD_ERROR", "Failed to load organizer event stats", e);
        }
    }

    public List<Map<String, Object>> getRevenueByDaysForEvents(List<Integer> eventIds, int days) {
        if (eventIds == null || eventIds.isEmpty()) return new java.util.ArrayList<>();
        if (days <= 0 || days > 365) days = 7;
        try {
            return dashboardDAO.getRevenueByDaysForEvents(eventIds, days);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Service error: getRevenueByDaysForEvents", e);
            throw new ServiceException("DASHBOARD_ERROR", "Failed to load organizer revenue data", e);
        }
    }

    public List<Map<String, Object>> getTicketDistributionForEvents(List<Integer> eventIds) {
        if (eventIds == null || eventIds.isEmpty()) return new java.util.ArrayList<>();
        try {
            return dashboardDAO.getTicketDistributionForEvents(eventIds);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Service error: getTicketDistributionForEvents", e);
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

    public List<Map<String, Object>> getHourlyDistributionForEvents(List<Integer> eventIds) {
        if (eventIds == null || eventIds.isEmpty()) return new java.util.ArrayList<>();
        try {
            return dashboardDAO.getHourlyDistributionForEvents(eventIds);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Service error: getHourlyDistributionForEvents", e);
            return new java.util.ArrayList<>();
        }
    }

    // ========================
    // DASHBOARD 2.0 — NEW METRICS
    // ========================

    public List<Map<String, Object>> getEventStatusDistribution() {
        try {
            return dashboardDAO.getEventStatusDistribution();
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Service error: getEventStatusDistribution", e);
            return new java.util.ArrayList<>();
        }
    }

    public List<Map<String, Object>> getHourlyOrdersToday() {
        try {
            return dashboardDAO.getHourlyOrdersToday();
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Service error: getHourlyOrdersToday", e);
            return new java.util.ArrayList<>();
        }
    }

    public int getActiveUsersToday() {
        try {
            return dashboardDAO.getActiveUsersToday();
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Service error: getActiveUsersToday", e);
            return 0;
        }
    }

    public double getConversionRate() {
        try {
            return dashboardDAO.getConversionRate();
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Service error: getConversionRate", e);
            return 0.0;
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

    public Map<String, Object> getSettlementStatsForEvents(List<Integer> eventIds) {
        if (eventIds == null || eventIds.isEmpty()) return new java.util.HashMap<>();
        try {
            return dashboardDAO.getSettlementStatsForEvents(eventIds);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Service error: getSettlementStatsForEvents", e);
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
