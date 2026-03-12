package com.sellingticket.controller.organizer;

import com.sellingticket.model.Event;
import com.sellingticket.model.User;
import com.sellingticket.model.Voucher;
import com.sellingticket.service.EventService;
import com.sellingticket.service.VoucherService;
import com.sellingticket.util.InputValidator;
import static com.sellingticket.util.ServletUtil.*;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * CRUD controller for organizer vouchers (discount codes).
 * GET  — list all vouchers, show create/edit forms.
 * POST — create, update, or delete a voucher.
 */
@WebServlet(name = "OrganizerVoucherController", urlPatterns = {"/organizer/vouchers", "/organizer/vouchers/*"})
public class OrganizerVoucherController extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(OrganizerVoucherController.class.getName());
    private final VoucherService voucherService = new VoucherService();
    private final EventService eventService = new EventService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User user = getSessionUser(request);
        if (user == null) { redirectToLogin(request, response); return; }

        try {
            String pathInfo = request.getPathInfo();

            if (pathInfo == null || "/".equals(pathInfo)) {
                listVouchers(request, response, user);
            } else if ("/create".equals(pathInfo)) {
                showForm(request, response, user, null);
            } else if (pathInfo.startsWith("/edit/")) {
                int id = parseIntOrDefault(pathInfo.substring(6), 0);
                Voucher voucher = voucherService.getVoucherById(id);
                if (voucher == null) {
                    response.sendError(404);
                    return;
                }
                if (!canManageVoucher(voucher, user)) {
                    setToast(request, "Bạn không có quyền sửa mã giảm giá này", "error");
                    response.sendRedirect(request.getContextPath() + "/organizer/vouchers");
                    return;
                }
                showForm(request, response, user, voucher);
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to load organizer vouchers", e);
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User user = getSessionUser(request);
        if (user == null) { redirectToLogin(request, response); return; }

        try {
            request.setCharacterEncoding("UTF-8");
            String action = request.getParameter("action");

            switch (action != null ? action : "") {
                case "create" -> createVoucher(request, user);
                case "update" -> updateVoucher(request, user);
                case "delete" -> deleteVoucher(request, user);
                default -> setToast(request, "Hành động không hợp lệ", "error");
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error in OrganizerVoucherController.doPost", e);
            setToast(request, "Đã xảy ra lỗi, vui lòng thử lại", "error");
        }

        response.sendRedirect(request.getContextPath() + "/organizer/vouchers");
    }

    // ========================
    // GET HANDLERS
    // ========================

    private void listVouchers(HttpServletRequest request, HttpServletResponse response, User user)
            throws ServletException, IOException {
        boolean isAdmin = isSystemAdmin(user);
        request.setAttribute("vouchers", isAdmin
                ? voucherService.getAllVouchers()
                : voucherService.getVouchersByOrganizer(user.getUserId()));
        request.setAttribute("events", getVoucherManageableEvents(user));
        request.setAttribute("isSystemAdmin", isAdmin);
        request.getRequestDispatcher("/organizer/vouchers.jsp").forward(request, response);
    }

    private void showForm(HttpServletRequest request, HttpServletResponse response, User user, Voucher voucher)
            throws ServletException, IOException {
        if (voucher != null) request.setAttribute("voucher", voucher);
        request.setAttribute("events", getVoucherManageableEvents(user));
        request.setAttribute("isSystemAdmin", isSystemAdmin(user));
        request.getRequestDispatcher("/organizer/voucher-form.jsp").forward(request, response);
    }

    // ========================
    // POST HANDLERS
    // ========================

    private void createVoucher(HttpServletRequest request, User user) {
        Voucher v = buildVoucherFromRequest(request);

        if (!InputValidator.isValidVoucherCode(v.getCode())) {
            setToast(request, "Mã giảm giá không hợp lệ (1-50 ký tự, chữ/số/gạch ngang)", "error"); return;
        }
        if (!InputValidator.isOneOf(v.getDiscountType(), "percentage", "fixed")) {
            setToast(request, "Loại giảm giá không hợp lệ", "error"); return;
        }
        if (!InputValidator.isPositive(v.getDiscountValue())) {
            setToast(request, "Giá trị giảm giá phải > 0", "error"); return;
        }
        if (v.getStartDate() == null || v.getEndDate() == null) {
            setToast(request, "Vui lòng nhập ngày bắt đầu và ngày kết thúc", "error"); return;
        }
        if (v.getEndDate().before(v.getStartDate())) {
            setToast(request, "Ngày kết thúc phải sau ngày bắt đầu", "error"); return;
        }
        if (v.getEndDate().before(new Date())) {
            setToast(request, "Ngày kết thúc không được trong quá khứ", "error"); return;
        }

        // Only admin can create system/global vouchers.
        if (v.getEventId() <= 0 && !isSystemAdmin(user)) {
            setToast(request, "Chỉ Admin hệ thống mới được tạo mã giảm giá toàn hệ thống", "error");
            return;
        }

        if (v.getEventId() > 0 && !eventService.hasVoucherPermission(v.getEventId(), user.getUserId(), user.getRole())) {
            setToast(request, "Bạn chỉ có thể tạo mã cho sự kiện mà bạn là owner/manager", "error");
            return;
        }
        v.setOrganizerId(user.getUserId());
        boolean ok = voucherService.createVoucher(v);
        setToast(request, ok ? "Tạo mã giảm giá thành công!" : "Tạo mã thất bại!", ok ? "success" : "error");
    }

    private void updateVoucher(HttpServletRequest request, User user) {
        int voucherId = parseIntOrDefault(request.getParameter("voucherId"), 0);
        Voucher existing = voucherService.getVoucherById(voucherId);
        
        if (existing == null) {
            setToast(request, "Không tìm thấy mã giảm giá", "error");
            return;
        }

        // --- SECURITY PATCH: CRITICAL CROSS-EVENT BYPASS FIX ---
        // Validate against the eventId stored in the database, NOT the one from the request parameter.
        if (!eventService.hasVoucherPermission(existing.getEventId(), user.getUserId(), user.getRole())) {
            setToast(request, "Bạn không có quyền sửa mã giảm giá gốc này", "error");
            return;
        }

        Voucher v = buildVoucherFromRequest(request);
        // Force the eventId to remain the same as the original to prevent cross-event transferring
        v.setEventId(existing.getEventId()); 
        v.setVoucherId(voucherId);
        // Keep the original organizer ID intact (don't overwrite with current user's ID)
        v.setOrganizerId(existing.getOrganizerId()); 
        if (v.getStartDate() == null || v.getEndDate() == null || v.getEndDate().before(v.getStartDate())) {
            setToast(request, "Khoảng thời gian mã giảm giá không hợp lệ", "error");
            return;
        }
        
        v.setActive("on".equals(request.getParameter("isActive")));
        boolean ok = voucherService.updateVoucher(v);
        setToast(request, ok ? "Cập nhật mã giảm giá thành công!" : "Cập nhật thất bại!", ok ? "success" : "error");
    }

    private void deleteVoucher(HttpServletRequest request, User user) {
        int id = parseIntOrDefault(request.getParameter("voucherId"), 0);
        Voucher voucher = voucherService.getVoucherById(id);
        if (voucher != null) {
            if (!eventService.hasVoucherPermission(voucher.getEventId(), user.getUserId(), user.getRole())) {
                setToast(request, "Bạn không có quyền xóa mã giảm giá này", "error");
                return;
            }
            voucherService.deleteVoucher(id); 
            setToast(request, "Đã xóa mã giảm giá!", "success");
        } else {
            setToast(request, "Không tìm thấy mã giảm giá", "error");
        }
    }

    /** Extract voucher fields from form parameters. */
    private Voucher buildVoucherFromRequest(HttpServletRequest request) {
        Voucher v = new Voucher();
        v.setEventId(parseIntOrDefault(request.getParameter("eventId"), 0));
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

    private boolean isSystemAdmin(User user) {
        return user != null && "admin".equals(user.getRole());
    }

    private boolean canManageVoucher(Voucher voucher, User user) {
        if (voucher == null || user == null) return false;
        return eventService.hasVoucherPermission(voucher.getEventId(), user.getUserId(), user.getRole());
    }

    /**
     * Return only events where current user can manage vouchers.
     * Prevents selecting unrelated events in UI.
     */
    private List<Event> getVoucherManageableEvents(User user) {
        List<Event> candidates = eventService.getAccessibleEvents(user.getUserId(), user.getRole());
        List<Event> allowed = new ArrayList<>();
        for (Event e : candidates) {
            if (eventService.hasVoucherPermission(e.getEventId(), user.getUserId(), user.getRole())) {
                allowed.add(e);
            }
        }
        return allowed;
    }
}
