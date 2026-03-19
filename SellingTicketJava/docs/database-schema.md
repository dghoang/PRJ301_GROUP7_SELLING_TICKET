# Phân Tích Database Schema — SellingTicketDB

> Tài liệu mô tả cấu trúc 21 bảng, quan hệ giữa các bảng, và lý do thiết kế.

---

## 1. Sơ Đồ Quan Hệ Tổng Thể (ERD)

```
Users ──────────────────────────────────────────────────────────┐
  │ (organizer_id)                                              │
  │                                                             │
  ├──(1:N)── Events ──(1:N)── TicketTypes ──(1:N)── OrderItems │
  │            │                   │ (sold_quantity)            │
  │            │               (quantity)                       │
  │            │                                    │           │
  │            └──(1:N)── Vouchers             OrderItems       │
  │                                                 │           │
  ├──(1:N)── Orders ──────────────────────(1:N)─────┘           │
  │            │                                                │
  │            └──(1:N)── Tickets (vé đã phát với JWT QR)       │
  │                                                             │
  ├──(1:N)── UserSessions (JWT refresh tokens)                  │
  ├──(1:N)── ChatSessions ──(1:N)── ChatMessages                │
  ├──(1:N)── SupportTickets ──(1:N)── TicketMessages            │
  ├──(1:N)── EventStaff (gán nhân viên kiểm vé)                 │
  ├──(1:N)── Media (Cloudinary URLs)                            │
  └──(N:M)── RolePermissions ← Permissions                     │
                                                                │
Users ──────────────────────────────────────────────────────────┘
     (user_id FK trong Orders, Tickets, Chat, Support...)
```

---

## 2. Mô Tả Các Bảng

### 2.1 Users — Người Dùng
```sql
Users (
    user_id     INT IDENTITY PRIMARY KEY,
    email       NVARCHAR(255) UNIQUE NOT NULL,
    password_hash NVARCHAR(255),           -- NULL nếu là OAuth user
    full_name   NVARCHAR(100) NOT NULL,
    phone       NVARCHAR(20),
    gender      NVARCHAR(10),
    date_of_birth DATE,
    role        NVARCHAR(20) DEFAULT 'customer'
                CHECK (role IN ('customer', 'organizer', 'admin')),
    avatar      NVARCHAR(500),             -- URL Cloudinary
    is_active   BIT DEFAULT 1,
    -- Organizer profile:
    bio, website, social_facebook, social_instagram,
    -- Security audit:
    last_login_at, last_login_ip, password_changed_at,
    email_verified, email_verified_at
)
```
**Lưu ý thiết kế:**
- `password_hash = NULL` → OAuth user (đăng nhập Google, không có password)
- 3 role: `customer`, `organizer`, `admin` — có `support_agent` trong migration
- `is_active = 0` → tài khoản bị khóa, không thể đăng nhập

---

### 2.2 Categories — Danh Mục Sự Kiện
```sql
Categories (
    category_id INT IDENTITY PRIMARY KEY,
    name    NVARCHAR(100) NOT NULL,
    slug    NVARCHAR(100) UNIQUE NOT NULL,  -- "am-nhac", "the-thao"
    icon    NVARCHAR(50),                   -- CSS class icon
    description NVARCHAR(500)
)
```

---

### 2.3 Events — Sự Kiện
```sql
Events (
    event_id    INT IDENTITY PRIMARY KEY,
    organizer_id INT → Users(user_id),
    category_id  INT → Categories(category_id),
    title       NVARCHAR(255) NOT NULL,
    slug        NVARCHAR(255) UNIQUE,  -- URL-friendly: "rock-night-2026"
    description NVARCHAR(MAX),         -- HTML rich content
    banner_image NVARCHAR(500),        -- Cloudinary URL
    location    NVARCHAR(255),
    address     NVARCHAR(500),
    start_date  DATETIME NOT NULL,
    end_date    DATETIME,
    status      NVARCHAR(20) DEFAULT 'draft'
        CHECK (status IN ('draft','pending','approved','rejected','cancelled','completed')),
    is_featured BIT DEFAULT 0,
    is_private  BIT DEFAULT 0,
    views       INT DEFAULT 0,
    -- Event-level ticket settings (từ migration):
    max_tickets_per_order INT DEFAULT 0,  -- 0 = dùng default hệ thống (10)
    max_total_tickets INT DEFAULT 0,       -- 0 = unlimited
    pre_order_enabled BIT DEFAULT 0,
    -- Rejection tracking:
    rejection_reason NVARCHAR(500),
    rejected_at DATETIME
)
```
**Status flow:**
```
draft → pending → approved → (sau ngày kết thúc) → ended/completed
                  ↘ rejected → (edit) → pending (resubmit)
```

---

### 2.4 TicketTypes — Loại Vé
```sql
TicketTypes (
    ticket_type_id INT IDENTITY PRIMARY KEY,
    event_id    INT → Events(event_id) ON DELETE CASCADE,
    name        NVARCHAR(100) NOT NULL,  -- "VIP", "Standard", "Early Bird"
    description NVARCHAR(500),
    price       DECIMAL(18,2) NOT NULL,
    quantity    INT NOT NULL,            -- Tổng số vé phát hành
    sold_quantity INT DEFAULT 0,         -- ← CỘT QUAN TRỌNG: luôn cập nhật atomic
    sale_start  DATETIME,
    sale_end    DATETIME,
    is_active   BIT DEFAULT 1
)
```
**Cột quan trọng nhất:** `sold_quantity` — được cập nhật trong **transaction atomic** khi có order mới, ngăn overselling.

Công thức còn vé: `quantity - sold_quantity`

---

### 2.5 Orders — Đơn Hàng
```sql
Orders (
    order_id    INT IDENTITY PRIMARY KEY,
    order_code  NVARCHAR(50) UNIQUE NOT NULL,  -- "ORD-1741234567890-A1B2C3D4"
    user_id     INT → Users(user_id),
    event_id    INT → Events(event_id),
    total_amount    DECIMAL(18,2),  -- Trước giảm giá
    discount_amount DECIMAL(18,2) DEFAULT 0,
    final_amount    DECIMAL(18,2), -- Sau giảm giá = số tiền cần thanh toán
    status      NVARCHAR(20) DEFAULT 'pending'
        CHECK (status IN ('pending','paid','cancelled','refunded',
                          'refund_requested','checked_in')),
    payment_method  NVARCHAR(30)
        CHECK (payment_method IN ('seepay','bank_transfer','cash')),
    payment_date DATETIME,
    buyer_name  NVARCHAR(100),    -- Có thể khác tên tài khoản
    buyer_email NVARCHAR(255),
    buyer_phone NVARCHAR(20),
    voucher_code NVARCHAR(50),    -- Mã giảm giá đã dùng
    transaction_id NVARCHAR(100), -- SeePay reference code (idempotency)
    notes       NVARCHAR(500)
)
```
**Cấu trúc order code:** `ORD-{timestamp13chữ số}-{UUID8ký tự}`  
Ví dụ: `ORD-1741234567890-A1B2C3D4`

---

### 2.6 OrderItems — Chi Tiết Đơn Hàng
```sql
OrderItems (
    order_item_id   INT IDENTITY PRIMARY KEY,
    order_id        INT → Orders(order_id) ON DELETE CASCADE,
    ticket_type_id  INT → TicketTypes(ticket_type_id),
    quantity        INT NOT NULL,
    unit_price      DECIMAL(18,2) NOT NULL,  -- Giá tại thời điểm mua (không đổi sau)
    subtotal        DECIMAL(18,2) NOT NULL   -- unit_price * quantity
)
```
**Lưu ý:** `unit_price` được snapshot tại thời điểm mua. Dù sau đó giá TicketType thay đổi → price trong order vẫn giữ nguyên.

---

### 2.7 Tickets — Vé Đã Phát (Vật Lý)
```sql
Tickets (
    ticket_id       INT IDENTITY PRIMARY KEY,
    ticket_code     NVARCHAR(50) UNIQUE NOT NULL,  -- "TK-A1B2C3D4E5F6"
    order_item_id   INT → OrderItems(order_item_id) ON DELETE CASCADE,
    attendee_name   NVARCHAR(100),
    attendee_email  NVARCHAR(255),
    qr_code         NVARCHAR(500),    -- JWT token (không phải URL)
    is_checked_in   BIT DEFAULT 0,
    checked_in_at   DATETIME,
    checked_in_by   INT → Users(user_id)
)
```
**QR Code là JWT thực sự:** `qr_code` chứa JWT string được ký HMAC-SHA256, không phải URL.  
Khi scan QR → app decode JWT → verify chữ ký → extract ticketId + eventId → check-in.

**Quan hệ:** 1 OrderItem (qty=3) → 3 Tickets riêng biệt

---

### 2.8 Vouchers — Mã Giảm Giá
```sql
Vouchers (
    voucher_id      INT IDENTITY PRIMARY KEY,
    organizer_id    INT → Users(user_id),
    event_id        INT → Events(event_id),  -- NULL = áp dụng mọi event
    code            NVARCHAR(50) UNIQUE NOT NULL,
    discount_type   NVARCHAR(20) CHECK (discount_type IN ('percentage','fixed')),
    discount_value  DECIMAL(18,2) NOT NULL,
    min_order_amount DECIMAL(18,2) DEFAULT 0,
    max_discount    DECIMAL(18,2),  -- Cap giảm tối đa (cho loại percentage)
    usage_limit     INT DEFAULT 0,  -- 0 = không giới hạn
    used_count      INT DEFAULT 0,
    start_date      DATETIME,
    end_date        DATETIME,
    is_active       BIT DEFAULT 1
)
```

---

### 2.9 UserSessions — JWT Refresh Tokens
```sql
UserSessions (
    session_id      INT IDENTITY PRIMARY KEY,
    user_id         INT → Users(user_id) ON DELETE CASCADE,
    jti             NVARCHAR(100) UNIQUE,  -- JWT ID (UUID) để revoke từng token
    device_info     NVARCHAR(255),          -- User-Agent
    ip_address      NVARCHAR(45),
    expires_at      DATETIME NOT NULL,
    is_active       BIT DEFAULT 1,         -- 0 = revoked (logout)
    last_activity   DATETIME
)
```
**Mục đích:** Khi user đăng xuất hoặc đổi mật khẩu → `is_active = 0` cho tất cả sessions → refresh token không còn hợp lệ kể cả chưa hết hạn.

---

### 2.10 ChatSessions + ChatMessages — Live Chat
```sql
ChatSessions (
    session_id  INT IDENTITY PRIMARY KEY,
    customer_id INT → Users(user_id),
    agent_id    INT → Users(user_id),  -- NULL nếu chưa có agent nhận
    event_id    INT → Events(event_id),
    status      NVARCHAR(20) CHECK (status IN ('waiting','active','closed')),
    created_at, started_at, closed_at
)

ChatMessages (
    message_id  INT IDENTITY PRIMARY KEY,
    session_id  INT → ChatSessions(session_id) ON DELETE CASCADE,
    sender_id   INT → Users(user_id),
    content     NVARCHAR(MAX) NOT NULL,
    sent_at     DATETIME DEFAULT GETDATE(),
    is_read     BIT DEFAULT 0
)
```

---

### 2.11 SupportTickets + TicketMessages — Hỗ Trợ
```sql
SupportTickets (
    ticket_id   INT IDENTITY PRIMARY KEY,
    user_id     INT → Users(user_id),
    assigned_to INT → Users(user_id),  -- Agent được gán
    subject     NVARCHAR(255) NOT NULL,
    category    NVARCHAR(50),
    priority    NVARCHAR(20) DEFAULT 'medium',
    status      NVARCHAR(20) DEFAULT 'open',
    event_id    INT → Events(event_id)  -- Nếu liên quan sự kiện cụ thể
)

TicketMessages (
    message_id  INT IDENTITY PRIMARY KEY,
    ticket_id   INT → SupportTickets(ticket_id) ON DELETE CASCADE,
    sender_id   INT → Users(user_id),
    content     NVARCHAR(MAX),
    is_staff_reply BIT DEFAULT 0,  -- Staff hay customer gửi
    created_at  DATETIME
)
```

---

### 2.12 EventStaff — Nhân Viên Kiểm Vé
```sql
EventStaff (
    staff_id    INT IDENTITY PRIMARY KEY,
    event_id    INT → Events(event_id),
    user_id     INT → Users(user_id),
    role        NVARCHAR(50),  -- "checker", "manager"
    added_by    INT → Users(user_id),
    added_at    DATETIME DEFAULT GETDATE()
)
```
**Dùng để:** Organizer giao quyền check-in cho nhân viên mà không cần tài khoản organizer.

---

### 2.13 SiteSettings — Cấu Hình Hệ Thống
```sql
SiteSettings (
    setting_id  INT IDENTITY PRIMARY KEY,
    setting_key NVARCHAR(100) UNIQUE NOT NULL,
    value       NVARCHAR(MAX),
    data_type   NVARCHAR(20)  -- 'string', 'boolean', 'integer', 'json'
)
```
Các key quan trọng:
| Key | Type | Mô tả |
|-----|------|-------|
| `chat_enabled` | boolean | Bật/tắt live chat |
| `chat_auto_accept` | boolean | Auto accept session (không cần agent nhận) |
| `chat_cooldown_minutes` | integer | Thời gian chờ giữa 2 session |
| `site_name` | string | Tên website |
| `maintenance_mode` | boolean | Chế độ bảo trì |

---

### 2.14 Media — File Upload (Cloudinary Polymorphic)
```sql
Media (
    media_id        INT IDENTITY PRIMARY KEY,
    uploader_id     INT → Users(user_id),
    cloudinary_url  NVARCHAR(500) NOT NULL,        -- CDN URL
    cloudinary_public_id NVARCHAR(255) NOT NULL,   -- Để xóa file
    file_size       INT CHECK (file_size <= 52428800),  -- Max 50MB
    media_type      NVARCHAR(10) CHECK (IN ('image','video')),
    entity_type     NVARCHAR(20) CHECK (IN ('user','event','ticket_type')),
    entity_id       INT NOT NULL,
    media_purpose   NVARCHAR(20) CHECK (IN ('avatar','banner','gallery','inline','ticket_design'))
)
```
**Polymorphic relationship:** 1 bảng Media phục vụ nhiều loại entity (user avatar, event banner, etc.) thay vì tạo nhiều bảng riêng.

---

## 3. Các Index Quan Trọng

```sql
-- Tìm event theo organizer (organizer dashboard)
IX_Events_OrganizerID ON Events(organizer_id)

-- Filter event theo status + date (admin approval, public listings)
IX_Events_Status ON Events(status)

-- Lookup order theo code (checkout confirmation, webhook)
IX_Orders_OrderCode ON Orders(order_code)

-- Lookup orders của user (my tickets page)
IX_Orders_UserID ON Orders(user_id)

-- Lookup ticket theo code (check-in)
IX_Tickets_TicketCode ON Tickets(ticket_code)

-- Đăng nhập (truy vấn theo email)
IX_Users_Email ON Users(email)

-- Filter voucher theo event + organizer
IX_Vouchers_EventID ON Vouchers(event_id)
IX_Vouchers_OrganizerID ON Vouchers(organizer_id)
```

---

## 4. Quan Hệ Bảng Trong Luồng Mua Vé

```
Khi user mua vé cho Event "Rock Night":

TicketTypes
  event_id = 5 (Rock Night)
  ticket_type_id = 101 → name="VIP", price=500000, quantity=100, sold_quantity=45

                    ↓ Sau khi order tạo atomic:
                    sold_quantity = 47  (mua thêm 2)

Orders
  order_id = 99
  order_code = "ORD-1741234567890-A1B2C3D4"
  user_id = 12
  event_id = 5
  total_amount = 1000000
  final_amount = 900000 (sau voucher)
  status = "pending" → "paid"

OrderItems
  order_item_id = 150
  order_id = 99
  ticket_type_id = 101
  quantity = 2
  unit_price = 500000
  subtotal = 1000000

                    ↓ Sau khi payment confirmed (webhook):
Tickets
  ticket_id = 201
  ticket_code = "TK-A1B2C3D4E5F6"
  order_item_id = 150
  qr_code = "eyJhbGci..."  ← JWT signed token
  is_checked_in = 0

  ticket_id = 202
  ticket_code = "TK-B2C3D4E5F6A7"
  order_item_id = 150
  qr_code = "eyJhbGci..."
  is_checked_in = 0
```

---

## 5. Ghi Chú Thiết Kế Đáng Chú Ý

### Không Dùng Foreign Key CASCADE Toàn Bộ
Chỉ một số bảng dùng `ON DELETE CASCADE`:
- `OrderItems → Orders` (xóa order → xóa items)
- `Tickets → OrderItems` (xóa item → xóa tickets)
- `UserSessions → Users` (xóa user → xóa sessions)

Các bảng khác (Events, Vouchers) **không** cascade để tránh mất dữ liệu lịch sử khi xóa organizer.

### Snapshot Price
`OrderItems.unit_price` snapshot giá tại thời điểm mua. Dù organizer sau đó thay đổi giá TicketType → lịch sử đơn hàng vẫn chính xác.

### Voucher Atomic
`Vouchers.used_count` chỉ được tăng trong transaction của `OrderDAO.createOrderAtomic()`, không tăng tại validate time → tránh race condition khi nhiều user dùng cùng voucher.

### Idempotency Column
`Orders.transaction_id` (SeePay reference code) — unique index ngăn confirm 2 lần từ cùng 1 webhook.
