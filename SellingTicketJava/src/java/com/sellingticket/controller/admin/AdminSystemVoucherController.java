package com.sellingticket.controller.admin;

import com.sellingticket.model.User;
import com.sellingticket.model.Voucher;
import com.sellingticket.service.VoucherService;
import com.sellingticket.util.InputValidator;
import static com.sellingticket.util.ServletUtil.*;

import java.io.IOException;
import java.util.Date;
import java.util.logging.Level;
import java.util.logging.Logger;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * Dedicated Admin module for system/global vouchers.
 * Completely separated from organizer voucher pages.
 */
@WebServlet(name = "AdminSystemVoucherController", urlPatterns = {"/admin/system-vouchers", "/admin/system-vouchers/*"})
public class AdminSystemVoucherController extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(AdminSystemVoucherController.class.getName());
    private final VoucherService voucherService = new VoucherService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User user = getSessionUser(request);
        if (user == null || !"admin".equals(user.getRole())) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        try {
            String pathInfo = request.getPathInfo();
            if (pathInfo == null || "/".equals(pathInfo)) {
                request.setAttribute("vouchers", voucherService.getSystemVouchers());
                request.getRequestDispatcher("/admin/system-vouchers.jsp").forward(request, response);
                return;
            }

            if ("/create".equals(pathInfo)) {
                request.getRequestDispatcher("/admin/system-voucher-form.jsp").forward(request, response);
                return;
            }

            if (pathInfo.startsWith("/edit/")) {
                int id = parseIntOrDefault(pathInfo.substring(6), 0);
                Voucher v = voucherService.getVoucherById(id);
                if (v == null || v.getEventId() > 0) {
                    response.sendError(HttpServletResponse.SC_NOT_FOUND);
                    return;
                }
                request.setAttribute("voucher", v);
                request.getRequestDispatcher("/admin/system-voucher-form.jsp").forward(request, response);
                return;
            }

            response.sendError(HttpServletResponse.SC_NOT_FOUND);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to load admin system vouchers", e);
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User user = getSessionUser(request);
        if (user == null || !"admin".equals(user.getRole())) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");

        try {
            switch (action != null ? action : "") {
                case "create" -> createSystemVoucher(request, user);
                case "update" -> updateSystemVoucher(request, user);
                case "delete" -> deleteSystemVoucher(request);
                default -> setToast(request, "Hành động không hợp lệ", "error");
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Admin system voucher action failed", e);
            setToast(request, "Đã xảy ra lỗi hệ thống", "error");
        }

        response.sendRedirect(request.getContextPath() + "/admin/system-vouchers");
    }

    private void createSystemVoucher(HttpServletRequest request, User user) {
        Voucher v = buildVoucherFromRequest(request);
        if (!validateVoucher(v, request)) return;

        v.setEventId(0);
        v.setOrganizerId(user.getUserId());
        v.setVoucherScope("SYSTEM");
        v.setFundSource("SYSTEM");

        boolean ok = voucherService.createVoucher(v);
        setToast(request, ok ? "Tạo voucher hệ thống thành công" : "Tạo voucher hệ thống thất bại", ok ? "success" : "error");
    }

    private void updateSystemVoucher(HttpServletRequest request, User user) {
        int voucherId = parseIntOrDefault(request.getParameter("voucherId"), 0);
        Voucher existing = voucherService.getVoucherById(voucherId);
        if (existing == null || existing.getEventId() > 0) {
            setToast(request, "Không tìm thấy voucher hệ thống", "error");
            return;
        }

        Voucher v = buildVoucherFromRequest(request);
        if (!validateVoucher(v, request)) return;

        v.setVoucherId(voucherId);
        v.setEventId(0);
        v.setOrganizerId(existing.getOrganizerId());
        v.setVoucherScope("SYSTEM");
        v.setFundSource("SYSTEM");
        v.setActive("on".equals(request.getParameter("isActive")));

        boolean ok = voucherService.updateVoucher(v);
        setToast(request, ok ? "Cập nhật voucher hệ thống thành công" : "Cập nhật voucher thất bại", ok ? "success" : "error");
    }

    private void deleteSystemVoucher(HttpServletRequest request) {
        int voucherId = parseIntOrDefault(request.getParameter("voucherId"), 0);
        Voucher existing = voucherService.getVoucherById(voucherId);
        if (existing == null || existing.getEventId() > 0) {
            setToast(request, "Không tìm thấy voucher hệ thống", "error");
            return;
        }
        boolean ok = voucherService.deleteVoucher(voucherId);
        setToast(request, ok ? "Đã xóa voucher hệ thống" : "Xóa voucher thất bại", ok ? "success" : "error");
    }

    private Voucher buildVoucherFromRequest(HttpServletRequest request) {
        Voucher v = new Voucher();
        v.setCode(request.getParameter("code"));
        v.setDiscountType(request.getParameter("discountType"));
        v.setDiscountValue(parseDoubleOrDefault(request.getParameter("discountValue"), 0));
        v.setMinOrderAmount(parseDoubleOrDefault(request.getParameter("minOrderAmount"), 0));
        v.setMaxDiscount(parseDoubleOrDefault(request.getParameter("maxDiscount"), 0));
        v.setUsageLimit(parseIntOrDefault(request.getParameter("usageLimit"), 0));
        v.setStartDate(parseDateOrNull(request.getParameter("startDate")));
        v.setEndDate(parseDateOrNull(request.getParameter("endDate")));
        return v;
    }

    private boolean validateVoucher(Voucher v, HttpServletRequest request) {
        if (!InputValidator.isValidVoucherCode(v.getCode())) {
            setToast(request, "Mã voucher không hợp lệ (1-50 ký tự, chữ/số/gạch ngang)", "error");
            return false;
        }
        if (!InputValidator.isOneOf(v.getDiscountType(), "percentage", "fixed")) {
            setToast(request, "Loại giảm giá không hợp lệ", "error");
            return false;
        }
        if (!InputValidator.isPositive(v.getDiscountValue())) {
            setToast(request, "Giá trị giảm phải > 0", "error");
            return false;
        }
        if (v.getStartDate() == null || v.getEndDate() == null) {
            setToast(request, "Vui lòng nhập ngày bắt đầu và kết thúc", "error");
            return false;
        }
        if (v.getEndDate().before(v.getStartDate())) {
            setToast(request, "Ngày kết thúc phải sau ngày bắt đầu", "error");
            return false;
        }
        if (v.getEndDate().before(new Date())) {
            setToast(request, "Ngày kết thúc không được trong quá khứ", "error");
            return false;
        }
        return true;
    }
}
