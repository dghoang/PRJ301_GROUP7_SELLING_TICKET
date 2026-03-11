package com.sellingticket.service.payment;

import com.sellingticket.model.Order;

import java.io.InputStream;
import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import java.util.Properties;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * SeepayProvider — Real VietQR bank transfer payment via SePay.vn.
 *
 * Flow:
 *   1. Build VietQR URL with bank info + order amount + order code
 *   2. Customer scans QR → transfers money
 *   3. SePay IPN webhook → SeepayWebhookServlet auto-confirms
 *
 * Config: seepay.properties (classpath)
 */
public class SeepayProvider implements PaymentProvider {

    private static final Logger LOGGER = Logger.getLogger(SeepayProvider.class.getName());

    private String bankId = "MB";
    private String accountNo = "0394497949";
    private String accountName = "DUONG MINH HOANG";
    private String qrTemplate = "compact2";
    private int timeoutMinutes = 15;

    public SeepayProvider() {
        loadConfig();
    }

    private void loadConfig() {
        try (InputStream is = getClass().getClassLoader().getResourceAsStream("seepay.properties")) {
            if (is != null) {
                Properties props = new Properties();
                props.load(is);
                bankId = props.getProperty("seepay.bank_id", "MB");
                accountNo = props.getProperty("seepay.account_no", "");
                accountName = props.getProperty("seepay.account_name", "");
                qrTemplate = props.getProperty("seepay.qr_template", "compact2");
                timeoutMinutes = Integer.parseInt(props.getProperty("seepay.payment_timeout_minutes", "15"));
                LOGGER.log(Level.INFO, "SeePay configured: bank={0}, account=***{1}",
                        new Object[]{bankId, accountNo.length() > 4 ? accountNo.substring(accountNo.length() - 4) : "????"});
            } else {
                LOGGER.warning("seepay.properties not found — using defaults.");
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to load seepay.properties", e);
        }
    }

    @Override
    public PaymentResult initiatePayment(Order order) {
        String orderCode = order.getOrderCode();
        long amount = (long) order.getFinalAmount();
        String txId = "SP-" + orderCode;

        LOGGER.log(Level.INFO, "SeePay payment: order={0}, txId={1}, amount={2}",
                new Object[]{orderCode, txId, amount});

        // Build VietQR image URL
        // Format: https://img.vietqr.io/image/{BANK_ID}-{ACCOUNT_NO}-{TEMPLATE}.png?amount=X&addInfo=Y&accountName=Z
        String qrUrl;
        try {
            qrUrl = String.format(
                "https://img.vietqr.io/image/%s-%s-%s.png?amount=%d&addInfo=%s&accountName=%s",
                bankId,
                accountNo,
                qrTemplate,
                amount,
                URLEncoder.encode(orderCode, "UTF-8"),
                URLEncoder.encode(accountName, "UTF-8")
            );
        } catch (UnsupportedEncodingException e) {
            // UTF-8 always supported
            qrUrl = String.format(
                "https://img.vietqr.io/image/%s-%s-%s.png?amount=%d&addInfo=%s",
                bankId, accountNo, qrTemplate, amount, orderCode
            );
        }

        PaymentResult result = PaymentResult.pending(txId, qrUrl,
                "Quét mã QR để chuyển khoản " + String.format("%,d", amount) + " VNĐ");
        result.setRedirectUrl(null); // QR-based, no redirect

        return result;
    }

    @Override
    public PaymentResult checkStatus(String transactionId) {
        // Status is determined by IPN webhook, not polling the upstream API
        LOGGER.log(Level.FINE, "SeePay status check: tx={0} (handled by IPN)", transactionId);
        return PaymentResult.pending(transactionId, null, "Đang chờ xác nhận thanh toán");
    }

    @Override
    public boolean supportsRefund() {
        return false; // Bank transfer refunds are manual
    }

    @Override
    public String getMethodName() {
        return "seepay";
    }

    /** Bank info getters for display on payment-pending page */
    public String getBankId() { return bankId; }
    public String getAccountNo() { return accountNo; }
    public String getAccountName() { return accountName; }
    public int getTimeoutMinutes() { return timeoutMinutes; }
}
