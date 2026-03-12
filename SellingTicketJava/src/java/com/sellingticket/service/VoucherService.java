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

    public List<Voucher> getSystemVouchers() {
        return voucherDAO.getSystemVouchers();
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
            return VoucherResult.invalid("Vui lòng nhập mã giảm giá");
        }

        Voucher v = voucherDAO.getVoucherByCode(code.trim());
        if (v == null) {
            return VoucherResult.invalid("Mã giảm giá không tồn tại");
        }
        if (!v.isActive()) {
            return VoucherResult.invalid("Mã giảm giá đã bị vô hiệu hóa");
        }
        if (v.isExpired()) {
            return VoucherResult.invalid("Mã giảm giá đã hết hạn");
        }
        if (v.getUsageLimit() > 0 && v.getUsedCount() >= v.getUsageLimit()) {
            return VoucherResult.invalid("Mã giảm giá đã hết lượt sử dụng");
        }

        // Event voucher must match event; system voucher (eventId <= 0) applies to all events.
        boolean isSystemVoucher = v.getEventId() <= 0;
        if (!isSystemVoucher && v.getEventId() != eventId) {
            return VoucherResult.invalid("Mã giảm giá không áp dụng cho sự kiện này");
        }

        if (v.getMinOrderAmount() > 0 && orderAmount < v.getMinOrderAmount()) {
            return VoucherResult.invalid("Đơn hàng tối thiểu " + String.format("%,.0f", v.getMinOrderAmount()) + "đ");
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
        discount = Math.min(discount, orderAmount);

        double eventDiscount = isSystemVoucher ? 0 : discount;
        double systemDiscount = isSystemVoucher ? discount : 0;
        String scope = isSystemVoucher ? "SYSTEM" : "EVENT";
        String source = isSystemVoucher ? "SYSTEM" : "ORGANIZER";

        String msg = "Giảm " + String.format("%,.0f", discount) + "đ";
        if ("percentage".equals(v.getDiscountType())) {
            msg = "Giảm " + (int) v.getDiscountValue() + "% (-" + String.format("%,.0f", discount) + "đ)";
        }

        return new VoucherResult(true, v.getVoucherId(), scope, source,
                discount, eventDiscount, systemDiscount, msg);
    }

    /** Result holder for voucher validation + settlement split. */
    public static class VoucherResult {
        public final boolean valid;
        public final Integer voucherId;
        public final String voucherScope;
        public final String fundSource;
        public final double discountAmount;
        public final double eventDiscountAmount;
        public final double systemDiscountAmount;
        public final String message;

        public VoucherResult(boolean valid, Integer voucherId, String voucherScope, String fundSource,
                double discountAmount, double eventDiscountAmount, double systemDiscountAmount, String message) {
            this.valid = valid;
            this.voucherId = voucherId;
            this.voucherScope = voucherScope;
            this.fundSource = fundSource;
            this.discountAmount = discountAmount;
            this.eventDiscountAmount = eventDiscountAmount;
            this.systemDiscountAmount = systemDiscountAmount;
            this.message = message;
        }

        public static VoucherResult invalid(String message) {
            return new VoucherResult(false, null, "NONE", "NONE", 0, 0, 0, message);
        }
    }
}
