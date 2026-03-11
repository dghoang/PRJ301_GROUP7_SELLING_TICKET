package com.sellingticket.service.payment;

import com.sellingticket.model.Order;

import java.util.UUID;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * BankTransferProvider — Generates a reference code for manual bank transfer.
 * Order stays "pending" until organizer/admin confirms payment.
 */
public class BankTransferProvider implements PaymentProvider {

    private static final Logger LOGGER = Logger.getLogger(BankTransferProvider.class.getName());

    @Override
    public PaymentResult initiatePayment(Order order) {
        String refCode = "BT-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase();
        LOGGER.log(Level.INFO, "Bank transfer initiated for order {0}, ref={1}", 
                new Object[]{order.getOrderCode(), refCode});

        return PaymentResult.pending(refCode, null,
                "Vui lòng chuyển khoản " + (long) order.getFinalAmount() + " VNĐ với nội dung: " + refCode);
    }

    @Override
    public PaymentResult checkStatus(String transactionId) {
        // Bank transfers are confirmed manually by organizer/admin
        return PaymentResult.pending(transactionId, null, "Đang chờ xác nhận chuyển khoản");
    }

    @Override
    public boolean supportsRefund() {
        return false; // Manual refund
    }

    @Override
    public String getMethodName() {
        return "bank_transfer";
    }
}
