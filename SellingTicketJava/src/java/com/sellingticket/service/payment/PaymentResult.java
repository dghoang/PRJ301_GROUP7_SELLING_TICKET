package com.sellingticket.service.payment;

/**
 * PaymentResult — DTO holding the outcome of a payment operation.
 */
public class PaymentResult {
    private boolean success;
    private String transactionId;
    private String qrCodeUrl;
    private String redirectUrl;
    private String message;

    public PaymentResult() {}

    public static PaymentResult ok(String transactionId, String message) {
        PaymentResult r = new PaymentResult();
        r.success = true;
        r.transactionId = transactionId;
        r.message = message;
        return r;
    }

    public static PaymentResult fail(String message) {
        PaymentResult r = new PaymentResult();
        r.success = false;
        r.message = message;
        return r;
    }

    public static PaymentResult pending(String transactionId, String qrCodeUrl, String message) {
        PaymentResult r = new PaymentResult();
        r.success = true;
        r.transactionId = transactionId;
        r.qrCodeUrl = qrCodeUrl;
        r.message = message;
        return r;
    }

    // Getters / Setters
    public boolean isSuccess() { return success; }
    public void setSuccess(boolean success) { this.success = success; }

    public String getTransactionId() { return transactionId; }
    public void setTransactionId(String transactionId) { this.transactionId = transactionId; }

    public String getQrCodeUrl() { return qrCodeUrl; }
    public void setQrCodeUrl(String qrCodeUrl) { this.qrCodeUrl = qrCodeUrl; }

    public String getRedirectUrl() { return redirectUrl; }
    public void setRedirectUrl(String redirectUrl) { this.redirectUrl = redirectUrl; }

    public String getMessage() { return message; }
    public void setMessage(String message) { this.message = message; }
}
