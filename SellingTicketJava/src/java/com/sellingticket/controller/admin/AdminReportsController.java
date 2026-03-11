package com.sellingticket.controller.admin;

import com.sellingticket.service.DashboardService;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * Admin reports — uses DashboardService for all stats.
 * Endpoints:
 *   GET /admin/reports         — JSP page with KPIs, top events, chart
 *   GET /admin/reports/export  — CSV download of summary stats
 */
@WebServlet(name = "AdminReportsController", urlPatterns = {"/admin/reports", "/admin/reports/*"})
public class AdminReportsController extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(AdminReportsController.class.getName());
    private final DashboardService dashboardService = new DashboardService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String pathInfo = request.getPathInfo();
        if ("/export".equals(pathInfo)) {
            exportCsv(request, response);
            return;
        }

        try {
            Map<String, Object> stats = dashboardService.getAdminDashboardStats();

            request.setAttribute("totalRevenue", stats.getOrDefault("totalRevenue", 0.0));
            request.setAttribute("totalUsers", stats.getOrDefault("totalUsers", 0));
            request.setAttribute("totalPaidOrders", stats.getOrDefault("paidOrders", 0));
            request.setAttribute("totalPendingOrders", stats.getOrDefault("pendingOrders", 0));
            request.setAttribute("totalCancelledOrders", stats.getOrDefault("cancelledOrders", 0));
            request.setAttribute("totalEvents", stats.getOrDefault("totalEvents", 0));

            // Top events for reports table
            List<Map<String, Object>> topEvents = dashboardService.getTopEventsByRevenue(8);
            request.setAttribute("topEvents", topEvents);

            // Sidebar badge
            int pendingCount = (int) stats.getOrDefault("pendingEvents", 0);
            request.setAttribute("pendingCount", pendingCount);

            request.getRequestDispatcher("/admin/reports.jsp").forward(request, response);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to load admin reports", e);
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }

    private void exportCsv(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("text/csv; charset=UTF-8");
        response.setHeader("Content-Disposition", "attachment; filename=\"admin-report.csv\"");

        try {
            Map<String, Object> stats = dashboardService.getAdminDashboardStats();
            List<Map<String, Object>> topEvents = dashboardService.getTopEventsByRevenue(20);

            PrintWriter pw = response.getWriter();
            pw.println("Chỉ số,Giá trị");
            pw.println("Tổng doanh thu (VND)," + stats.getOrDefault("totalRevenue", 0));
            pw.println("Tổng người dùng," + stats.getOrDefault("totalUsers", 0));
            pw.println("Đơn đã thanh toán," + stats.getOrDefault("paidOrders", 0));
            pw.println("Đơn chờ xử lý," + stats.getOrDefault("pendingOrders", 0));
            pw.println("Đơn đã hủy," + stats.getOrDefault("cancelledOrders", 0));
            pw.println("Tổng sự kiện," + stats.getOrDefault("totalEvents", 0));
            pw.println();
            pw.println("STT,Tên sự kiện,Organizer,Trạng thái,Doanh thu (VND),Số đơn");
            int i = 1;
            for (Map<String, Object> ev : topEvents) {
                String title = String.valueOf(ev.getOrDefault("title", "")).replace(",", " ");
                String org = String.valueOf(ev.getOrDefault("organizerName", "")).replace(",", " ");
                pw.println(i++ + "," + title + "," + org + "," + ev.getOrDefault("status", "") +
                        "," + ev.getOrDefault("revenue", 0) + "," + ev.getOrDefault("orderCount", 0));
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to export CSV report", e);
        }
    }
}
