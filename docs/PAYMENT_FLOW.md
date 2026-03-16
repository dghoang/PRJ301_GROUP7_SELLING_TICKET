# Payment Flow (Current)

## Supported Checkout Methods

UI currently allows:
- seepay
- momo
- vnpay

Backend behavior:
- seepay: pending payment with QR flow + webhook confirmation
- non-seepay methods: immediate markAsPaid flow in current implementation

## SeePay Flow

1. POST /checkout creates order with status pending
2. SeepayProvider builds VietQR payment URL
3. payment-pending.jsp polls /api/payment/status
4. SePay sends POST /api/seepay/webhook
5. Webhook validates API key, amount, order code
6. Order is atomically confirmed (pending -> paid)
7. Tickets are issued once payment is confirmed

## Webhook Idempotency

- In-memory fast-path cache (bounded)
- Persistent dedup table SeepayWebhookDedup (source of truth)
- Duplicate transaction IDs are ignored safely

## Security Controls in Webhook

- Authorization header check against configured SePay API key
- Body size cap
- JSON shape validation
- Strict order-code extraction
- Amount mismatch rejection
- Atomic payment update to prevent race double-processing

## Database Pieces

- Orders.status includes pending/paid/cancelled/refunded/refund_requested/checked_in
- PaymentTransactions stores gateway transaction history
- SeepayWebhookDedup stores processed webhook IDs

## Related Files

- SellingTicketJava/src/java/com/sellingticket/controller/CheckoutServlet.java
- SellingTicketJava/src/java/com/sellingticket/controller/api/SeepayWebhookServlet.java
- SellingTicketJava/src/java/com/sellingticket/service/payment/SeepayProvider.java
- SellingTicketJava/src/java/com/sellingticket/dao/OrderDAO.java
- SellingTicketJava/src/java/com/sellingticket/dao/SeepayWebhookDedupDAO.java
- SellingTicketJava/database/migrations/migration_seepay_webhook_dedup.sql
