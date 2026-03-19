# Phân Tích Luồng Nghiệp Vụ — SellingTicketJava

> Tài liệu này phân tích chi tiết từng luồng xử lý nghiệp vụ theo đúng code thực tế.
> Mỗi luồng ghi rõ: file nào xử lý, class nào gọi class nào, SQL nào chạy.

---

## Mục Lục

1. [Đăng Nhập (Email/Password)](#1-đăng-nhập-emailpassword)
2. [Đăng Ký Tài Khoản](#2-đăng-ký-tài-khoản)
3. [Đăng Nhập Google OAuth](#3-đăng-nhập-google-oauth)
4. [Khôi Phục Session (JWT)](#4-khôi-phục-session-jwt)
5. [Duyệt Sự Kiện](#5-duyệt-sự-kiện)
6. [Tạo Đơn Hàng (Checkout Atomic)](#6-tạo-đơn-hàng-checkout-atomic)
7. [Thanh Toán QR VietQR (SeePay)](#7-thanh-toán-qr-vietqr-seepay)
8. [Webhook IPN — Xác Nhận Tự Động](#8-webhook-ipn--xác-nhận-tự-động)
9. [Phát Vé (Ticket Issuance + JWT QR)](#9-phát-vé-ticket-issuance--jwt-qr)
10. [Check-in Cổng Sự Kiện](#10-check-in-cổng-sự-kiện)
11. [Mã Giảm Giá (Voucher)](#11-mã-giảm-giá-voucher)
12. [Admin Duyệt Sự Kiện](#12-admin-duyệt-sự-kiện)
13. [Organizer Tạo Sự Kiện](#13-organizer-tạo-sự-kiện)
14. [Chat Hỗ Trợ Realtime](#14-chat-hỗ-trợ-realtime)
15. [Support Ticket (Hỗ Trợ Email)](#15-support-ticket-hỗ-trợ-email)

---

## 1. Đăng Nhập (Email/Password)

### File liên quan
| File | Vai trò |
|------|---------|
| `controller/LoginServlet.java` | Nhận POST /login, điều phối toàn bộ |
| `security/LoginAttemptTracker.java` | Rate limiter (Singleton) |
| `service/UserService.java` | Gọi `authenticate()` |
| `dao/UserDAO.java` | Truy vấn DB, BCrypt verify |
| `util/PasswordUtil.java` | `BCrypt.checkpw()` |
| `service/AuthTokenService.java` | Phát JWT access + refresh token |
| `util/JwtUtil.java` | Tạo và ký JWT bằng HMAC-SHA256 |
| `util/CookieUtil.java` | Đặt cookie HttpOnly |
| `dao/RefreshTokenDAO.java` | Lưu refresh token vào DB (bảng UserSessions) |

### Luồng Chi Tiết

```
POST /login (email, password, remember)
    │
    ▼ LoginServlet.doPost()
    ├─ [1] Validate đầu vào: null check, length ≤ 255/128, email regex
    ├─ [2] Normalize: trim + toLowerCase(email)
    ├─ [3] Rate limit: LoginAttemptTracker.isIpBlocked(ip)
    │       → isBlocked(email, ip)
    │       → Nếu bị khóa: showError("Tài khoản tạm khóa...") STOP
    ├─ [4] Thời gian bắt đầu: startTime = System.nanoTime()
    ├─ [5] UserService.authenticate(email, password)
    │       → UserDAO.login(email, password)
    │           → SQL: SELECT * FROM Users WHERE email = ? AND is_active = 1
    │           → PasswordUtil.checkPassword(plain, hash)
    │               → BCrypt.checkpw(plain, hash)  // Cost factor 12
    │           → return User | null
    ├─ [6] enforceMinimumDelay(startTime, 200ms)  // chống timing attack
    ├─ [7] Nếu user == null:
    │       → tracker.recordFailure(email, ip)
    │       → showError("Email hoặc mật khẩu không đúng!")  STOP
    ├─ [8] Nếu !user.isActive():
    │       → showError("Tài khoản bị khóa")  STOP
    ├─ [9] tracker.reset(email, ip)
    ├─ [10] userService.updateLastLogin(userId, ip)
    ├─ [11] Session fixation protection:
    │       → oldSession.invalidate()  // Hủy session cũ
    │       → request.getSession(true) // Tạo session ID mới
    │       → session.setAttribute("user", user)
    │       → session.setAttribute("account", user)
    │       → session.setMaxInactiveInterval(3600)
    ├─ [12] authTokenService.issueTokens(response, user, request, rememberMe)
    │       → JwtUtil.generateAccessToken(userId, email, role)
    │           → JWT { sub: userId, email, role, type:"access", exp: +7d }
    │           → Ký bằng HMAC-SHA256
    │       → JwtUtil.generateRefreshToken(userId)
    │           → JWT { sub: userId, jti: UUID, type:"refresh", exp: +30d }
    │       → RefreshTokenDAO.saveToken(userId, jti, userAgent, ip, expiresAt)
    │           → INSERT INTO UserSessions (...)
    │       → CookieUtil.addSecureCookie("st_access", token, maxAge, secure)
    │       → CookieUtil.addSecureCookie("st_refresh", token, maxAge, secure)
    └─ [13] Redirect: returnUrl | /organizer/dashboard | /admin/dashboard | /home
```

### Tại Sao BCrypt Cost 12?
BCrypt cost 12 = mất ~300ms/hash → brute-force cần hàng nghìn năm với hardware thông thường.

### Tại Sao Cần 200ms Delay Tối Thiểu?
Nếu email không tồn tại: trả về ngay (rất nhanh). Nếu sai mật khẩu: BCrypt mất 300ms. Kẻ tấn công đo thời gian phản hồi biết email có tồn tại không. Delay tối thiểu 200ms loại bỏ thông tin này.

---

## 2. Đăng Ký Tài Khoản

### File liên quan
| File | Vai trò |
|------|---------|
| `controller/RegisterServlet.java` | Nhận POST /register |
| `service/UserService.java` | `registerFull()`, `isEmailExists()` |
| `dao/UserDAO.java` | `registerFull()` — hash pw + INSERT |
| `util/PasswordUtil.java` | `hashPassword()` — BCrypt |

### Luồng
```
POST /register (email, password, fullName, phone, gender, dob)
    │
    ▼ RegisterServlet.doPost()
    ├─ Validate: email, password strength (8 ký tự, chữ hoa, số, ký tự đặc biệt)
    ├─ UserService.isEmailExists(email) → Nếu tồn tại: showError  STOP
    ├─ UserService.registerFull(...)
    │       → UserDAO.registerFull(...)
    │           → PasswordUtil.hashPassword(password)
    │               → BCrypt.hashpw(password, BCrypt.gensalt(12))
    │           → SQL: INSERT INTO Users (email, password_hash, full_name, phone, gender, dob, role)
    │                  VALUES (?, ?, ?, ?, ?, ?, 'user')
    └─ Redirect /login (sau khi đăng ký thành công)
```

---

## 3. Đăng Nhập Google OAuth

### File liên quan
| File | Vai trò |
|------|---------|
| `controller/GoogleOAuthServlet.java` | GET /auth/google + callback |
| `service/UserService.java` | find or create user |
| `dao/UserDAO.java` | registerOAuth(), getUserByEmail() |
| `service/AuthTokenService.java` | phát JWT sau OAuth |
| `WEB-INF/google-oauth.properties` | client_id, client_secret |

### Luồng
```
GET /auth/google
    → Generate state token (chống CSRF)
    → Lưu state vào session
    → Redirect đến Google: accounts.google.com/o/oauth2/auth?...
        └─ params: client_id, redirect_uri, scope (email+profile), state

↓ Google callback: GET /auth/google?code=XXX&state=YYY
    ├─ Verify state == session state  (chống CSRF)
    ├─ Exchange code → access_token:
    │   POST https://oauth2.googleapis.com/token (code, client_id, secret)
    ├─ Fetch user info: GET https://www.googleapis.com/oauth2/v2/userinfo
    │   → { email, name, picture }
    ├─ UserService.getUserByEmail(email)
    │   → Nếu tồn tại: đăng nhập ngay (luôn "rememberMe=true")
    │   → Nếu chưa tồn tại: UserService.registerOAuth(email, name, avatar)
    │       → UserDAO.registerOAuth()
    │           → INSERT INTO Users (..., password_hash = NULL)
    ├─ Session fixation protection + tạo session mới
    ├─ authTokenService.issueTokens(response, user, request, true)
    └─ Redirect /home
```

---

## 4. Khôi Phục Session (JWT)

### File liên quan
| File | Vai trò |
|------|---------|
| `filter/AuthFilter.java` | Chính — logic khôi phục session |
| `service/AuthTokenService.java` | validateAccessToken(), refreshAccessToken() |
| `util/JwtUtil.java` | verifyAuthToken() — verify HMAC + expiry |
| `dao/RefreshTokenDAO.java` | isTokenValid(jti) — kiểm tra DB |
| `dao/UserDAO.java` | getUserById() — lấy User record |

### Khi Nào Cần?
Session Tomcat mặc định hết hạn sau **60 phút không hoạt động**. Trình duyệt vẫn còn cookie `st_access` và `st_refresh`. Thay vì bắt user đăng nhập lại → AuthFilter tự động khôi phục.

### Luồng
```
AuthFilter.doFilter()
    ├─ getSessionUser(request) → null  (session đã expire)
    ├─ authTokenService.validateAccessToken(request)
    │   ├─ Đọc cookie "st_access"
    │   ├─ JwtUtil.verifyAuthToken(token)
    │   │   ├─ Verify chữ ký HMAC-SHA256
    │   │   └─ Check exp > System.currentTimeMillis()
    │   ├─ Verify claim type == "access"
    │   └─ UserDAO.getUserById(userId) → User
    │
    ├─ Nếu access token expired hoặc null:
    │   └─ authTokenService.refreshAccessToken(request, response)
    │       ├─ Đọc cookie "st_refresh"
    │       ├─ JwtUtil.verifyAuthToken(refreshToken) → verify HMAC + expiry
    │       ├─ Extract jti (JWT ID = UUID)
    │       ├─ RefreshTokenDAO.isTokenValid(jti)
    │       │   → SELECT is_active FROM UserSessions WHERE jti = ?
    │       ├─ UserDAO.getUserById(userId) → User
    │       ├─ Phát access token mới → set cookie mới
    │       └─ Update last_activity trong DB
    │
    ├─ Nếu có User → Restore session:
    │   → oldSession.invalidate()  (session fixation protection)
    │   → newSession.setAttribute("user", user)
    └─ chain.doFilter() → request đi tiếp đến Controller
```

---

## 5. Duyệt Sự Kiện

### File liên quan
| File | Vai trò |
|------|---------|
| `controller/EventsServlet.java` | GET /events — danh sách + search |
| `controller/EventDetailServlet.java` | GET /event-detail — chi tiết |
| `controller/HomeServlet.java` | GET /home — trang chủ |
| `service/EventService.java` | searchEvents(), getEventDetails() |
| `dao/EventDAO.java` | Truy vấn với pagination + filter |
| `dao/TicketTypeDAO.java` | Lấy loại vé theo event |

### Luồng Danh Sách Sự Kiện
```
GET /events?keyword=&category=&date=&page=1
    │
    ▼ EventsServlet.doGet()
    ├─ Đọc params: keyword, category, dateFilter, page
    ├─ EventService.searchEvents(keyword, category, dateFilter, page, 12)
    │   → EventDAO.searchEvents(...)
    │       → SQL: SELECT e.*, c.name as category_name,
    │                     MIN(tt.price) as min_price,
    │                     SUM(tt.quantity) as total_tickets
    │              FROM Events e
    │              JOIN Categories c ON e.category_id = c.category_id
    │              LEFT JOIN TicketTypes tt ON e.event_id = tt.event_id
    │              WHERE e.status = 'approved'
    │                AND e.end_date >= GETDATE()  -- chỉ sự kiện chưa kết thúc
    │                AND (e.title LIKE ? OR e.description LIKE ?)  -- keyword
    │                AND c.slug = ?  -- category filter
    │              GROUP BY e.event_id ...
    │              ORDER BY e.start_date ASC
    │              OFFSET (page-1)*12 ROWS FETCH NEXT 12 ROWS ONLY
    └─ Forward /events.jsp
```

### Luồng Chi Tiết Sự Kiện
```
GET /event-detail?id=5 hoặc /event-detail?slug=rock-night-2026
    │
    ▼ EventDetailServlet.doGet()
    ├─ Đọc id hoặc slug
    ├─ EventService.getEventDetails(eventId)
    │   → EventDAO.getEventById(eventId)  -- lấy event
    │   → TicketTypeDAO.getTicketTypesByEventId(eventId)  -- lấy loại vé
    │   → Tính totalTickets, soldTickets từ ticket types
    │   → EventDAO.incrementViews(eventId)  -- +1 lượt xem
    ├─ EventService.getRelatedEvents(categoryId, eventId, 4)
    └─ Forward /event-detail.jsp
```

---

## 6. Tạo Đơn Hàng (Checkout Atomic)

**Đây là luồng quan trọng nhất** — xử lý đồng thời nhiều user mua vé cùng lúc mà không oversell.

### File liên quan
| File | Vai trò |
|------|---------|
| `controller/CheckoutServlet.java` | GET+POST /checkout — điều phối |
| `service/OrderService.java` | `createOrder()`, `generateOrderCode()` |
| `dao/OrderDAO.java` | `createOrderAtomic()` — transaction DB |
| `service/VoucherService.java` | `validateVoucher()` — kiểm tra mã giảm |
| `dao/VoucherDAO.java` | Truy vấn voucher |
| `model/Order.java` | POJO đơn hàng |
| `model/OrderItem.java` | POJO chi tiết loại vé |

### Luồng: POST /checkout
```
POST /checkout (eventId, items="typeId:qty,typeId:qty", voucherCode,
                buyerName, buyerEmail, buyerPhone, paymentMethod)
    │
    ▼ CheckoutServlet.doPost()
    ├─ [1] getSessionUser(request) → nếu null → redirect /login STOP
    ├─ [2] buildOrderFromRequest(request, user)
    │   ├─ EventService.getEventDetails(eventId)
    │   ├─ Kiểm tra: event.status == "approved" → nếu không: return null STOP
    │   ├─ Kiểm tra: event.endDate >= now → nếu qua: return null STOP
    │   ├─ Parse items param: "101:2,102:1" → [{typeId:101, qty:2}, {typeId:102, qty:1}]
    │   ├─ Với mỗi item:
    │   │   → TicketTypeDAO.getById(typeId)
    │   │   → Kiểm tra qty <= maxQtyPerOrder (event setting hoặc mặc định 10)
    │   │   → Tạo OrderItem(typeId, qty, unitPrice, subtotal)
    │   ├─ Tính totalAmount = sum(subtotal)
    │   └─ Khởi tạo Order(userId, eventId, items, totalAmount)
    │
    ├─ [3] Validate voucher (nếu có):
    │   VoucherService.validateVoucher(code, eventId, totalAmount)
    │   → Kiểm tra: tồn tại, active, chưa hết hạn, chưa hết usage_limit
    │   → Kiểm tra: event scope (0 = all, hoặc eventId cụ thể)
    │   → Kiểm tra: totalAmount >= min_order_amount
    │   → Tính discount: percentage hoặc fixed
    │   → Gắn vào order: discountAmount, finalAmount, voucherCode
    │
    ├─ [4] orderService.createOrder(order)
    │   → OrderDAO.createOrderAtomic(order)
    │       ← TRANSACTION START ─────────────────────────────────
    │       ├─ STEP 1: Lock + reserve ticket slots (atomic, ngăn oversell)
    │       │   UPDATE TicketTypes
    │       │   SET sold_quantity = sold_quantity + ?
    │       │   WHERE ticket_type_id = ?
    │       │     AND (quantity - sold_quantity) >= ?  ← KIỂM TRA CÒN ĐỦ VÉ
    │       │     AND is_active = 1
    │       │   → Nếu 0 rows updated → ROLLBACK → return 0 (vé đã hết)
    │       │
    │       ├─ STEP 1.5: Atomic voucher increment (nếu có voucher)
    │       │   UPDATE Vouchers SET used_count = used_count + 1
    │       │   WHERE code = ? AND is_active = 1
    │       │     AND (usage_limit = 0 OR used_count < usage_limit)
    │       │   → Nếu 0 rows updated → ROLLBACK → return 0
    │       │
    │       ├─ STEP 2: INSERT Orders
    │       │   INSERT INTO Orders (order_code, user_id, event_id, total_amount,
    │       │       discount_amount, final_amount, status='pending', payment_method,
    │       │       buyer_name, buyer_email, buyer_phone, notes)
    │       │   → Lấy generated order_id
    │       │
    │       ├─ STEP 3: INSERT OrderItems (batch)
    │       │   INSERT INTO OrderItems (order_id, ticket_type_id, quantity,
    │       │       unit_price, subtotal)
    │       │
    │       └─ COMMIT ────────────────────────────────────────────
    │           → return orderId
    │
    ├─ [5] Nếu orderId == 0 → showError("Vé đã hết, vui lòng chọn lại") STOP
    │
    ├─ [6] Routing theo payment method:
    │   ├─ "seepay" → orderService.processPayment(order)
    │   │   → PaymentFactory.getProvider("seepay") → SeepayProvider
    │   │   → SeepayProvider.initiatePayment(order)
    │   │       → Build VietQR URL
    │   │       → return PaymentResult{status:PENDING, qrUrl, txId}
    │   │   → Forward /payment-pending.jsp (hiển thị QR)
    │   │
    │   └─ "bank_transfer" / "cash" → issueTickets() ngay
    │       → redirect /order-confirmation?orderId=X
    └─
```

### Tại Sao Dùng Transaction Atomic?
Không dùng transaction → 2 user A và B cùng mua vé cuối cùng:
- A đọc: còn 1 vé
- B đọc: còn 1 vé
- A ghi: sold = 1 (OK)
- B ghi: sold = 2 (OVERSELL!)

Với atomic transaction: câu lệnh UPDATE có điều kiện `(quantity - sold_quantity) >= qty`. SQL Server lock record trong transaction, B phải chờ A xong. Sau khi A commit, `sold_quantity` đã = max → B nhận 0 rows updated → rollback → báo lỗi "vé đã hết". **Đây là kỹ thuật Optimistic Locking ở tầng DB.**

---

## 7. Thanh Toán QR VietQR (SeePay)

### File liên quan
| File | Vai trò |
|------|---------|
| `service/payment/PaymentFactory.java` | Factory chọn provider theo method |
| `service/payment/PaymentProvider.java` | Interface chuẩn (Strategy Pattern) |
| `service/payment/SeepayProvider.java` | Tạo VietQR URL, config từ seepay.properties |
| `service/payment/BankTransferProvider.java` | Provider chuyển khoản thủ công |
| `service/payment/PaymentResult.java` | POJO kết quả payment |
| `src/java/seepay.properties` | bank_id, account_no, api_key |
| `webapp/payment-pending.jsp` | Hiển thị QR + countdown timer |

### Factory Pattern — Cách Thêm Provider Mới
```java
// PaymentFactory.java
static {
    register(new SeepayProvider());       // seepay
    register(new BankTransferProvider()); // bank_transfer
    // Thêm mới: chỉ cần dòng này, không sửa code khác:
    // register(new VnPayProvider());
    // register(new MomoProvider());
}
```

### Strategy Pattern — PaymentProvider Interface
```java
// PaymentProvider.java (interface)
public interface PaymentProvider {
    PaymentResult initiatePayment(Order order);
    PaymentResult checkStatus(String transactionId);
    boolean supportsRefund();
    String getMethodName();
}
```

Mọi provider (SeePay, VnPay, Momo...) đều implement interface này. `OrderService` gọi `provider.initiatePayment(order)` mà không cần biết provider nào đang chạy.

### Luồng SeePay QR
```
SeepayProvider.initiatePayment(order)
    ├─ amount = (long) order.getFinalAmount()
    ├─ Build VietQR URL:
    │   https://img.vietqr.io/image/{bankId}-{accountNo}-{template}.png
    │       ?amount={amount}
    │       &addInfo={orderCode}   ← Mã đơn hàng để webhook nhận diện
    │       &accountName={name}
    └─ return PaymentResult.pending(txId, qrUrl, message)

payment-pending.jsp
    ├─ Hiển thị QR image (img.vietqr.io)
    ├─ Hiển thị: bank name, account no, số tiền, order code
    ├─ Countdown timer (15 phút)
    └─ Poll AJAX mỗi 5 giây: GET /api/payment/status?orderId=X
        → Nếu status == "paid" → redirect /order-confirmation
        → Nếu hết giờ → hiển thị "Đã hết thời gian thanh toán"
```

---

## 8. Webhook IPN — Xác Nhận Tự Động

### File liên quan
| File | Vai trò |
|------|---------|
| `controller/api/SeepayWebhookServlet.java` | POST /api/seepay/webhook |
| `service/OrderService.java` | `confirmPayment()` |
| `dao/OrderDAO.java` | `confirmPaymentAtomic()` |
| `dao/TicketDAO.java` | `createTicketsForOrder()` |

### Luồng
```
SePay gửi POST /api/seepay/webhook
    {
      "transferType": "in",
      "transferAmount": 500000,
      "content": "ORD-1741234567890-A1B2C3D4",
      "referenceCode": "FT26071234"
    }
    │
    ▼ SeepayWebhookServlet.doPost()
    ├─ [BẢOMẬT 1] Verify Authorization header:
    │   "Bearer {seepay.api_key from seepay.properties}"
    │   → Nếu sai: 401 Unauthorized STOP
    │
    ├─ [BẢOMẬT 2] Giới hạn body size: max 64KB (chống DoS)
    │
    ├─ [BẢOMẬT 3] Validate JSON format: starts with '{', ends with '}'
    │
    ├─ Parse fields: transferType, transferAmount, content, referenceCode
    │
    ├─ Nếu transferType != "in" → skip (không phải tiền vào)
    │
    ├─ Extract order code từ content:
    │   Regex: (ORD-\d{10,15}-[A-Z0-9]{4,8})
    │
    ├─ [IDEMPOTENCY] Fast-path dedup:
    │   processedTransactions.contains(referenceCode) → đã xử lý → skip
    │
    ├─ OrderDAO.getOrderByCode(orderCode)
    │
    ├─ [IDEMPOTENCY] Kiểm tra order status:
    │   order.status == "paid" → đã thanh toán → skip (không issue vé 2 lần)
    │
    ├─ Verify amount: transferAmount >= order.finalAmount
    │   → Nếu thiếu tiền: log warning + skip
    │
    ├─ orderService.confirmPayment(orderId, referenceCode)
    │   → OrderDAO.confirmPaymentAtomic(orderId, txId)
    │       → UPDATE Orders SET status='paid', payment_date=GETDATE(),
    │                transaction_id=?
    │         WHERE order_id=? AND status='pending'  ← CHỈ update nếu còn pending
    │         → Trả về true nếu 1 row updated
    │
    ├─ orderService.issueTickets(orderId, buyerName, buyerEmail)
    │   → TicketDAO.createTicketsForOrder(orderId, ...)  [xem luồng 9]
    │
    ├─ processedTransactions.add(referenceCode)  // Cache dedup
    └─ response 200: {"success": true}
```

### Tại Sao Cần Idempotency?
SePay có thể gửi webhook **nhiều lần** cho cùng một giao dịch (retry khi network lỗi). Nếu không có idempotency check → issue vé 2 lần → user có 2 bộ vé cho 1 đơn hàng. Giải pháp: 
- In-memory cache `ConcurrentHashMap` — fast-path  
- DB-level: `WHERE status='pending'` — đảm bảo an toàn kể cả sau server restart

---

## 9. Phát Vé (Ticket Issuance + JWT QR)

### File liên quan
| File | Vai trò |
|------|---------|
| `service/OrderService.java` | `issueTickets()` |
| `dao/TicketDAO.java` | `createTicketsForOrder()` |
| `util/JwtUtil.java` | `generateTicketToken()` |
| `model/Ticket.java` | POJO vé đã phát |

### Luồng
```
TicketDAO.createTicketsForOrder(orderId, buyerName, buyerEmail)
    ├─ SELECT OrderItems + TicketTypes + Events cho orderId
    ├─ Với mỗi OrderItem:
    │   quantity = 2 → tạo 2 vé riêng biệt
    │   └─ Lặp i = 0..quantity-1:
    │       ├─ ticketCode = generateTicketCode()
    │       │   → "TK-" + UUID().replace("-","").substring(0,12).toUpperCase()
    │       │   Ví dụ: "TK-A1B2C3D4E5F6"
    │       │
    │       ├─ INSERT INTO Tickets (ticket_code, order_item_id, attendee_name,
    │       │       attendee_email, qr_code="")  ← QR tạm rỗng
    │       │   → Lấy generated ticketId
    │       │
    │       └─ JwtUtil.generateTicketToken(ticketId, ticketCode, eventId, expiry)
    │           → JWT { ticketId, ticketCode, eventId, type:"ticket", exp: 1 năm }
    │           → Ký HMAC-SHA256
    │           → UPDATE Tickets SET qr_code = ? WHERE ticket_id = ?
    │
    └─ return số vé đã tạo
```

### Vé JWT QR — Chứa Gì?
```
JWT Payload (giải mã được, không thể giả mạo):
{
  "ticketId": 42,
  "ticketCode": "TK-A1B2C3D4E5F6",
  "eventId": 5,
  "type": "ticket",
  "exp": 1800000000  // Unix timestamp 1 năm
}
```
Khi check-in → scan QR → decode JWT → verify chữ ký HMAC → chứng minh vé hợp lệ và không bị làm giả.

---

## 10. Check-in Cổng Sự Kiện

### File liên quan
| File | Vai trò |
|------|---------|
| `controller/organizer/OrganizerCheckInController.java` | GET+POST /organizer/check-in |
| `dao/TicketDAO.java` | `checkInTicket()`, `getTicketByQrToken()` |
| `service/EventService.java` | `hasCheckInPermission()` |
| `util/JwtUtil.java` | verify ticket JWT token |

### Luồng — Check-in QR Scan
```
Camera scan QR (trên mobile) → decode JWT token string
    ↓
AJAX POST /organizer/check-in (qrToken=JWT..., eventId=5)
    │
    ▼ OrganizerCheckInController.doPost()
    │   → handleQrCheckIn(response, user, qrToken, eventId)
    │
    ├─ EventService.hasCheckInPermission(eventId, userId, role)
    │   → Kiểm tra: organizer của event, hoặc staff được gán, hoặc admin
    │
    ├─ JwtUtil.verifyTicketToken(qrToken)
    │   ├─ Verify HMAC-SHA256 signature
    │   ├─ Check exp > now
    │   └─ Verify type == "ticket"
    │   → Extract: ticketId, ticketCode, eventId
    │
    ├─ TicketDAO.getTicketById(ticketId)
    │   → SELECT ticket + order + event info
    │
    ├─ Kiểm tra eventId trong JWT == eventId param (chống dùng vé sự kiện khác)
    │
    ├─ Kiểm tra ticket.status:
    │   ├─ "used" → { success: false, "Vé đã được sử dụng", checkedInAt }
    │   └─ "valid" → tiếp tục
    │
    ├─ TicketDAO.checkInTicket(ticketId)
    │   → UPDATE Tickets SET status='used', checked_in_at=GETDATE()
    │      WHERE ticket_id=? AND status='valid'  ← atomic, ngăn check-in 2 lần
    │
    └─ JSON response: { success: true, ticketCode, attendeeName, ticketTypeName,
                        orderCode, checkedInAt }
```

### Luồng — Check-in Thủ Công (Order Code)
```
Nhân viên nhập tay mã đơn hàng: ORD-1741234567890-A1B2C3D4
    ↓
AJAX POST /organizer/check-in (orderCode=ORD-..., action=lookup, eventId=5)
    ├─ OrderDAO.getOrderByCode(orderCode)
    ├─ Kiểm tra order thuộc đúng eventId
    ├─ TicketDAO.getTicketsByOrderId(orderId)
    └─ Trả về danh sách vé (chưa check-in các vé status='valid')

→ Nhân viên chọn vé → click Check-in:
AJAX POST (orderCode, action=checkin, ticketId=X)
    └─ TicketDAO.checkInTicket(ticketId)  [tương tự QR ở trên]
```

---

## 11. Mã Giảm Giá (Voucher)

### File liên quan
| File | Vai trò |
|------|---------|
| `service/VoucherService.java` | `validateVoucher()` |
| `dao/VoucherDAO.java` | truy vấn voucher |
| `model/Voucher.java` | POJO voucher |
| `dao/OrderDAO.java` | atomic increment voucher trong transaction |

### Cơ Chế Chống Race Condition Voucher
Voucher có `usage_limit = 100`. Nếu 200 người dùng cùng validate cùng lúc:
- Validate tại `VoucherService` chỉ **đọc** `used_count` → không đủ tin cậy
- Increment thực sự xảy ra **bên trong transaction** tại `OrderDAO.createOrderAtomic()`:
```sql
UPDATE Vouchers SET used_count = used_count + 1
WHERE code = ? AND is_active = 1
  AND (usage_limit = 0 OR used_count < usage_limit)
-- Nếu usage_limit đã đạt → 0 rows updated → ROLLBACK toàn bộ order
```

### Luồng Validate (AJAX realtime)
```
AJAX POST /checkout?action=validate-voucher (code, eventId, amount)
    → CheckoutServlet.handleVoucherValidation()
    → VoucherService.validateVoucher(code, eventId, amount)
        ├─ Kiểm tra: tồn tại, active, chưa hết hạn
        ├─ Kiểm tra: event scope (v.eventId == 0 || v.eventId == eventId)
        ├─ Kiểm tra: amount >= minOrderAmount
        ├─ Tính discount:
        │   - type "percentage": discount = amount * value/100, cap tại maxDiscount
        │   - type "fixed": discount = value
        │   - đảm bảo discount <= amount (không trả về âm)
        └─ return { valid: true, discountAmount: 50000, message: "Giảm 10% (-50.000đ)" }

→ JSON response hiển thị realtime trên UI (không reload trang)
```

---

## 12. Admin Duyệt Sự Kiện

### File liên quan
| File | Vai trò |
|------|---------|
| `controller/admin/AdminEventApprovalController.java` | GET+POST /admin/event-approval |
| `service/EventService.java` | `approveEvent()`, `rejectEvent()` |
| `dao/EventDAO.java` | `updateEventStatus()`, reject + reason |

### Luồng
```
Admin vào /admin/event-approval
    → GET: EventService.getPendingEvents()
        → SELECT * FROM Events WHERE status='pending' ORDER BY created_at

Admin click "Approve" cho event ID=7:
    → POST /admin/event-approval (eventId=7, action=approve)
    → AdminEventApprovalController.doPost()
    → EventService.approveEvent(7)
        → EventDAO.updateEventStatus(7, "approved")
            → UPDATE Events SET status='approved' WHERE event_id=7
    → Redirect back với flash message "Đã duyệt sự kiện"

Admin click "Reject":
    → POST (eventId=7, action=reject, rejectionReason="Thông tin không đầy đủ")
    → EventService.rejectEvent(7, "Thông tin không đầy đủ")
        → EventDAO.rejectEvent(7, reason)
            → UPDATE Events SET status='rejected',
                rejection_reason=?, rejected_at=GETDATE()
              WHERE event_id=7
```

### Status Flow của Event
```
draft (organizer tạo, chưa submit)
  ↓ submit
pending (chờ admin duyệt)
  ↓ approve           ↓ reject
approved              rejected (organizer có thể edit + resubmit)
  ↓ (sau ngày kết thúc)
ended
```

---

## 13. Organizer Tạo Sự Kiện

### File liên quan
| File | Vai trò |
|------|---------|
| `controller/organizer/OrganizerEventController.java` | GET+POST /organizer/create-event |
| `service/EventService.java` | `createEventWithTickets()` |
| `dao/EventDAO.java` | `createEventWithTickets()` — transaction |
| `service/MediaService.java` | upload banner lên Cloudinary |
| `util/CloudinaryUtil.java` | Cloudinary API client |

### Luồng
```
POST /organizer/create-event (title, description, startDate, endDate,
    location, categoryId, bannerImage, ticketTypes[])
    │
    ▼ OrganizerEventController.doPost()
    ├─ Validate: title, dates, location, ≥ 1 ticket type
    ├─ MediaService.uploadBanner(fileItem)
    │   → CloudinaryUtil.upload(inputStream, "events/")
    │       → Cloudinary API: POST https://api.cloudinary.com/v1_1/.../image/upload
    │       → return secure_url (CDN URL)
    ├─ Tạo Event object + List<TicketType>
    │   (mỗi ticket type: name, price, quantity, saleStartDate, saleEndDate)
    ├─ EventService.createEventWithTickets(event, ticketTypes)
    │   → EventDAO.createEventWithTickets(event, ticketTypes)
    │       ← TRANSACTION ─────────────────────
    │       ├─ INSERT INTO Events (..., status='pending')
    │       │   → Lấy generated event_id
    │       └─ INSERT INTO TicketTypes (event_id, name, price, quantity, ...)
    │           BATCH insert tất cả ticket types
    │           → COMMIT
    └─ Redirect /organizer/events (kèm flash "Đã tạo, chờ admin duyệt")
```

---

## 14. Chat Hỗ Trợ Realtime

### File liên quan
| File | Vai trò |
|------|---------|
| `controller/api/ChatApiServlet.java` | GET+POST /api/chat/* |
| `service/ChatService.java` | Logic anti-spam, session management |
| `dao/ChatDAO.java` | CRUD messages + sessions |
| `dao/SiteSettingsDAO.java` | Cấu hình chat (enabled, auto_accept, cooldown) |
| `model/ChatSession.java` | POJO session |
| `model/ChatMessage.java` | POJO message |

### Long Polling thay vì WebSocket
```
// JS front-end: poll mỗi 3 giây
function pollMessages() {
    fetch("/api/chat/messages?sessionId=X&afterMessageId=Y")
        .then(r => r.json())
        .then(data => { /* render messages */ })
    setTimeout(pollMessages, 3000);
}
```

### Luồng Tạo Session Chat
```
Customer POST /api/chat/start (eventId=5)
    │
    ▼ ChatApiServlet → ChatService.getOrCreateSession(customerId, eventId)
    ├─ Kiểm tra: SiteSettingsDAO.getBoolean("chat_enabled")
    │   → Nếu false: return { blocked: "chat_disabled" }
    ├─ Kiểm tra: countActiveSessionsByCustomer(customerId) > 0
    │   → Nếu có session đang mở: return { session: existing }
    ├─ Kiểm tra cooldown: dao.getCooldownMinutesRemaining(customerId, 30min)
    │   → Nếu trong cooldown: return { blocked: "cooldown", retryAfter: N }
    ├─ dao.createSession(customerId, eventId)
    │   → INSERT INTO ChatSessions (customer_id, event_id, status='waiting')
    │   → Nếu autoAccept: dao.autoActivateSession(id)
    │       → UPDATE ChatSessions SET status='active', started_at=GETDATE()
    └─ return { session: ChatSession }
```

### Luồng Gửi/Nhận Tin Nhắn
```
POST /api/chat/send (sessionId, content)
    → ChatService.sendMessage(sessionId, senderId, content)
    → ChatDAO.sendMessage()
        → INSERT INTO ChatMessages (session_id, sender_id, content, sent_at)

GET /api/chat/messages?sessionId=X&after=Y
    → ChatService.getMessages(sessionId, afterMessageId)
    → ChatDAO.getMessages(sessionId, afterId)
        → SELECT * FROM ChatMessages
          WHERE session_id=? AND message_id > ?
          ORDER BY sent_at ASC
    → return JSON array
```

---

## 15. Support Ticket (Hỗ Trợ Email)

### File liên quan
| File | Vai trò |
|------|---------|
| `controller/SupportTicketServlet.java` | GET+POST /support/* |
| `service/SupportTicketService.java` | logic tạo, reply, đóng |
| `dao/SupportTicketDAO.java` | CRUD tickets + messages |
| `model/SupportTicket.java` | POJO ticket |
| `model/TicketMessage.java` | POJO message trong ticket |

### Phân Biệt Ticket Loại Hỗ Trợ
- **Support Ticket** (`/support/*`) — khiếu nại, hỗ trợ chung, admin/support_agent xử lý
- **Chat** (`/api/chat/*`) — live chat realtime, organizer + admin/support xử lý

### Status Flow Support Ticket
```
open → in_progress → resolved (hoặc) closed
  ↑
  └─ (user reply có thể reopen)
```

---

## 16. Phân Tích Bảo Mật Tổng Hợp

### Các Lớp Bảo Vệ

```
┌─────────────────────────────────────────────────────────────────┐
│ LỚP 1: SecurityHeadersFilter (mọi request)                      │
│  X-Content-Type-Options: nosniff                                │
│  X-Frame-Options: SAMEORIGIN                                    │
│  Strict-Transport-Security: max-age=31536000 (HTTPS 1 năm)      │
│  Referrer-Policy: strict-origin-when-cross-origin               │
│  Permissions-Policy: camera=(), microphone=(), geolocation=()   │
└─────────────────────────────────────────────────────────────────┘
┌─────────────────────────────────────────────────────────────────┐
│ LỚP 2: CsrfFilter (POST requests quan trọng)                    │
│  Mỗi form có hidden field: <input name="_csrf" value="...">     │
│  Token lưu trong session, validate trước khi xử lý              │
│  Chống: Cross-Site Request Forgery                              │
└─────────────────────────────────────────────────────────────────┘
┌─────────────────────────────────────────────────────────────────┐
│ LỚP 3: AuthFilter (route protection)                            │
│  Session check → JWT access token → JWT refresh token           │
│  Role check: admin / organizer / user                           │
│  Block direct URL access đến *.jsp protected                    │
└─────────────────────────────────────────────────────────────────┘
┌─────────────────────────────────────────────────────────────────┐
│ LỚP 4: LoginAttemptTracker (brute-force protection)             │
│  Per email+IP: khóa sau 5 lần sai                               │
│  Per IP: khóa sau 30 lần sai (credential stuffing)             │
│  Constant-time response (anti timing attack)                    │
└─────────────────────────────────────────────────────────────────┘
┌─────────────────────────────────────────────────────────────────┐
│ LỚP 5: Input Validation                                         │
│  SQL Injection: 100% dùng PreparedStatement, không concatenate  │
│  XSS: escape output trong JSP (JSTL c:out, fn:escapeXml)        │
│  Length limits: email ≤255, password ≤128, body size khi upload │
└─────────────────────────────────────────────────────────────────┘
┌─────────────────────────────────────────────────────────────────┐
│ LỚP 6: Webhook Security (SeePay IPN)                            │
│  Authorization header Bearer token verification                 │
│  Body size limit 64KB (DoS protection)                          │
│  JSON format validation trước khi parse                         │
│  Idempotency: in-memory + DB-level duplicate prevention         │
└─────────────────────────────────────────────────────────────────┘
```

---

## Câu Hỏi Thường Gặp Ở Hội Đồng

**H: Tại sao dùng Servlet thay vì Spring MVC?**
> Servlet là nền tảng của Jakarta EE. Spring MVC thực chất cũng build trên Servlet. Dùng Servlet thuần giúp hiểu rõ cơ chế request/response, session, filter — kiến thức nền tảng. Project này theo hướng học các concept cốt lõi.

**H: Tại sao không dùng connection pool có sẵn như HikariCP?**
> DBContext tự implement connection pool dùng `LinkedBlockingQueue` và `Proxy` để intercept `close()`. Đây là bài học về design pattern (Proxy) và concurrency. Trong production thực tế, HikariCP là lựa chọn tốt hơn, nhưng project này demonstrate khả năng implement từ đầu.

**H: Transaction checkout bảo vệ gì cụ thể?**
> Ngăn overselling vé. Câu UPDATE với điều kiện `(quantity - sold_quantity) >= qty` vừa kiểm tra vừa cập nhật trong 1 atomic operation. SQL Server sẽ lock row trong transaction, các request đồng thời phải chờ. Sau khi commit, nếu hết vé → request tiếp theo nhận 0 rows updated → rollback → báo lỗi.

**H: JWT ticket QR có thể làm giả không?**
> Không. JWT được ký HMAC-SHA256 với secret key chỉ server biết. Nếu sửa payload (ticketId, eventId) → chữ ký không còn hợp lệ → server từ chối. Kẻ giả mạo cần biết secret key mới tạo được JWT hợp lệ.

**H: Idempotency webhook hoạt động thế nào?**
> SePay có thể gửi lại webhook nhiều lần. Nếu không có idempotency → issue vé 2 lần. Giải pháp 2 tầng: (1) in-memory `ConcurrentHashMap` lưu referenceCode đã xử lý — fast path; (2) DB: `WHERE status='pending'` trong UPDATE — đảm bảo kể cả sau server restart.
