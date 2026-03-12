package com.sellingticket.service;

import com.sellingticket.dao.VoucherDAO;
import com.sellingticket.model.Voucher;
import java.util.List;

/**
 * VoucherService — business logic for voucher/discount code operations.
 */
public class VoucherService {

    private final VoucherDAO voucherDAO;

    public VoucherService() {
        this.voucherDAO = new VoucherDAO();
    }

    public List<Voucher> getVouchersByOrganizer(int organizerId) {
        return voucherDAO.getVouchersByOrganizer(organizerId);
    }

    public List<Voucher> getAllVouchers() {
        return voucherDAO.getAllVouchers();
    }

    public Voucher getVoucherById(int voucherId) {
        return voucherDAO.getVoucherById(voucherId);
    }

    public Voucher getVoucherByCode(String code) {
        if (code == null || code.trim().isEmpty()) return null;
        return voucherDAO.getVoucherByCode(code);
    }

    public boolean createVoucher(Voucher voucher) {
        return voucherDAO.createVoucher(voucher);
    }

    public boolean updateVoucher(Voucher voucher) {
        return voucherDAO.updateVoucher(voucher);
    }

    public boolean deleteVoucher(int voucherId) {
        return voucherDAO.deleteVoucher(voucherId);
    }

    public boolean applyVoucher(String code) {
        Voucher v = voucherDAO.getVoucherByCode(code);
        if (v == null || !v.isUsable()) return false;
        return voucherDAO.incrementUsedCount(v.getVoucherId());
    }

    /**
     * Validate a voucher code for a specific event and order amount.
     * Returns a result with validity, discount amount, and user message.
     */
    public VoucherResult validateVoucher(String code, int eventId, double orderAmount) {
        if (code == null || code.trim().isEmpty()) {
            return new VoucherResult(false, 0, "Vui lòng nhập mã giảm giá");
        }

        Voucher v = voucherDAO.getVoucherByCode(code.trim());
        if (v == null) {
            return new VoucherResult(false, 0, "Mã giảm giá không tồn tại");
        }
        if (!v.isActive()) {
            return new VoucherResult(false, 0, "Mã giảm giá đã bị vô hiệu hóa");
        }
        if (v.isExpired()) {
            return new VoucherResult(false, 0, "Mã giảm giá đã hết hạn");
        }
        if (v.getUsageLimit() > 0 && v.getUsedCount() >= v.getUsageLimit()) {
            return new VoucherResult(false, 0, "Mã giảm giá đã hết lượt sử dụng");
        }
        // Check event scope (0 = all events)
        if (v.getEventId() > 0 && v.getEventId() != eventId) {
            return new VoucherResult(false, 0, "Mã giảm giá không áp dụng cho sự kiện này");
        }
        if (v.getMinOrderAmount() > 0 && orderAmount < v.getMinOrderAmount()) {
            return new VoucherResult(false, 0,
                    "Đơn hàng tối thiểu " + String.format("%,.0f", v.getMinOrderAmount()) + "đ");
        }

        // Calculate discount
        double discount;
        if ("percentage".equals(v.getDiscountType())) {
            discount = orderAmount * v.getDiscountValue() / 100.0;
            if (v.getMaxDiscount() > 0 && discount > v.getMaxDiscount()) {
                discount = v.getMaxDiscount();
            }
        } else {
            discount = v.getDiscountValue();
        }
        discount = Math.min(discount, orderAmount); // cannot exceed order

        String msg = "Giảm " + String.format("%,.0f", discount) + "đ";
        if ("percentage".equals(v.getDiscountType())) {
            msg = "Giảm " + (int) v.getDiscountValue() + "% (-" + String.format("%,.0f", discount) + "đ)";
        }
        return new VoucherResult(true, discount, msg);
    }

    /** Simple result holder for voucher validation. */
    public static class VoucherResult {
        public final boolean valid;
        public final double discountAmount;
        public final String message;

        public VoucherResult(boolean valid, double discountAmount, String message) {
            this.valid = valid;
            this.discountAmount = discountAmount;
            this.message = message;
        }
    }
}
