# 12. Concurrency Ticket Locking

## Hệ thống trừ vé ở đâu
- `OrderDAO.createOrderAtomic()`
- Query chính:
```sql
UPDATE TicketTypes WITH (UPDLOCK, HOLDLOCK)
SET sold_quantity = sold_quantity + ?
WHERE ticket_type_id = ? AND (quantity - sold_quantity) >= ? AND is_active = 1
```

## Vì sao tốt
- Đây là atomic reservation bằng SQL Server lock hint.
- Nếu 2 người mua cùng lúc, một bên sẽ giữ lock và bên còn lại phải chờ hoặc fail theo điều kiện update.
- Nếu update không thành công, transaction rollback.

## Có transaction không
- Có. `conn.setAutoCommit(false)` và `commit/rollback`.

## Rủi ro còn lại
- Nếu có route khác cập nhật `sold_quantity` không đi qua cùng cơ chế atomic, vẫn có thể lệch.
- Nếu retry webhook/payment không idempotent, có thể bị phát vé/giao dịch lặp.
- `countUserTicketsForEvent()` là pre-check; pre-check riêng không đủ nếu không có lock ở bước cuối. Source đã có lock cuối nên khá ổn.

## Có thể bán vượt không
- Với đường checkout chính đã đọc, nguy cơ giảm mạnh.
- Nhưng vẫn cần kiểm tra mọi đường tạo đơn/giảm vé khác trong source.

## Gợi ý production
- Giữ atomic update như hiện tại.
- Thêm idempotency key cho checkout/payment.
- Cân nhắc unique constraint hoặc reservation table nếu muốn giữ vé tạm thời.

## Tóm tắt dễ nhớ
Chống oversell chính nằm ở SQL atomic update + transaction, không phải chỉ ở validate trong Java.

## File nên mở tiếp theo
- `/D:/GITHUB/PRJ301_GROUP4_SELLING_TICKET/SellingTicketJava/docss/13_PERFORMANCE_CODE_QUALITY.md`

## Điểm người mới hay nhầm
- Nghĩ check `available >= qty` trong Java là đủ. Không đủ nếu không lock tại DB.
