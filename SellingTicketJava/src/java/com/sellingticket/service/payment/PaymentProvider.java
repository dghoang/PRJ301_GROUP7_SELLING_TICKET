package com.sellingticket.service.payment;

import com.sellingticket.model.Order;

/**
 * PaymentProvider — Strategy interface for payment methods.
 * Each payment gateway implements this interface.
 * Enables easy plug-in of new providers (SeePay, VNPay, Momo, etc.)
 */
public interface PaymentProvider {

    /** Initiate a payment for the given order. */
    PaymentResult initiatePayment(Order order);

    /** Check the status of a previously initiated payment. */
    PaymentResult checkStatus(String transactionId);

    /** Whether this provider supports automated refunds. */
    boolean supportsRefund();

    /** Get the provider's identifier string (matches DB payment_method column). */
    String getMethodName();
}
