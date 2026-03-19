# Kiến Trúc Tổng Quan — SellingTicketJava

> **Mục tiêu tài liệu:** Giúp hiểu toàn bộ cấu trúc dự án từ tầng trình bày đến tầng dữ liệu,
> dùng để giải thích cho hội đồng bảo vệ.

---

## 1. Kiến Trúc Tổng Thể (MVC 3-Tier)

```
┌────────────────────────────────────────────────────────────────────┐
│  TẦNG TRÌNH BÀY (View)                                             │
│  src/webapp/*.jsp                                                  │
│  src/webapp/admin/*.jsp                                            │
│  src/webapp/organizer/*.jsp                                        │
│  src/webapp/assets/ (CSS + JS)                                     │
└───────────────────────────┬────────────────────────────────────────┘
                            │ HTTP Request / Forward
┌───────────────────────────▼────────────────────────────────────────┐
│  TẦNG ĐIỀU PHỐI (Filter Chain — trước khi vào controller)          │
│                                                                    │
│  SecurityHeadersFilter → CsrfFilter → AuthFilter                  │
│      (mọi request)       (POST forms)  (trang được bảo vệ)        │
└───────────────────────────┬────────────────────────────────────────┘
                            │
┌───────────────────────────▼────────────────────────────────────────┐
│  TẦNG CONTROLLER (Servlet)                                         │
│                                                                    │
│  controller/          — Public: Login, Register, Checkout...       │
│  controller/admin/    — Admin panel (10 controllers)               │
│  controller/organizer/ — Organizer panel (11 controllers)         │
│  controller/api/      — AJAX JSON endpoints + Webhook              │
└───────────────────────────┬────────────────────────────────────────┘
                            │ gọi
┌───────────────────────────▼────────────────────────────────────────┐
│  TẦNG DỊCH VỤ (Service)                                            │
│                                                                    │
│  UserService    EventService   OrderService   VoucherService       │
│  ChatService    SupportTicketService          AuthTokenService     │
│  CategoryService  MediaService  DashboardService                   │
│  payment/PaymentFactory → SeepayProvider | BankTransferProvider   │
└───────────────────────────┬────────────────────────────────────────┘
                            │ gọi
┌───────────────────────────▼────────────────────────────────────────┐
│  TẦNG DATA ACCESS (DAO)                                            │
│                                                                    │
│  BaseDAO           — kế thừa DBContext                             │
│  UserDAO           OrderDAO        EventDAO        TicketDAO       │
│  TicketTypeDAO     VoucherDAO      ChatDAO         SupportTicketDAO│
│  CategoryDAO       MediaDAO        DashboardDAO    RefreshTokenDAO │
│  EventStaffDAO     SiteSettingsDAO                                 │
└───────────────────────────┬────────────────────────────────────────┘
                            │ JDBC (Connection Pool)
┌───────────────────────────▼────────────────────────────────────────┐
│  TẦNG DỮ LIỆU                                                      │
│  SQL Server — Database: SellingTicketDB                            │
│  DBContext — Connection pool tự xây (không dùng thư viện ngoài)   │
└────────────────────────────────────────────────────────────────────┘
```

---

## 2. Sơ Đồ Package Java

```
src/java/com/sellingticket/
├── controller/                    ← Servlets nhận HTTP request
│   ├── LoginServlet.java          ← POST /login
│   ├── RegisterServlet.java       ← POST /register
│   ├── LogoutServlet.java         ← GET /logout
│   ├── CheckoutServlet.java       ← GET+POST /checkout
│   ├── EventsServlet.java         ← GET /events
│   ├── EventDetailServlet.java    ← GET /event-detail
│   ├── TicketSelectionServlet.java← GET /ticket-selection
│   ├── OrderConfirmationServlet.java← GET /order-confirmation
│   ├── ResumePaymentServlet.java  ← GET /resume-payment
│   ├── MyTicketsServlet.java      ← GET /my-tickets
│   ├── ProfileServlet.java        ← GET+POST /profile
│   ├── ChangePasswordServlet.java ← POST /change-password
│   ├── SupportTicketServlet.java  ← GET+POST /support/*
│   ├── GoogleOAuthServlet.java    ← GET /auth/google
│   ├── MediaUploadServlet.java    ← POST /media/upload
│   ├── HomeServlet.java           ← GET /home
│   ├── StaticPagesServlet.java    ← GET /about, /faq
│   ├── TermsServlet.java          ← GET /terms
│   ├── admin/                     ← 10 controllers /admin/*
│   ├── organizer/                 ← 11 controllers /organizer/*
│   └── api/                       ← JSON API + Webhook
│       ├── ChatApiServlet.java    ← GET+POST /api/chat/*
│       ├── SeepayWebhookServlet.java← POST /api/seepay/webhook
│       ├── PaymentStatusServlet.java← GET /api/payment/status
│       ├── UploadServlet.java     ← POST /api/upload
│       └── ...
├── service/                       ← Business logic
├── dao/                           ← Database access
├── model/                         ← Plain Java objects (POJO)
├── filter/                        ← Request/Response interceptors
├── security/                      ← Rate limiting
└── util/                          ← Helper utilities
```

---

## 3. Các Design Pattern Được Dùng

| Pattern | Áp dụng ở đâu | Mục đích |
|---------|---------------|----------|
| **MVC** | Toàn dự án | Tách biệt View / Controller / Model |
| **DAO (Data Access Object)** | `dao/*.java` | Ẩn SQL khỏi business logic |
| **Service Layer** | `service/*.java` | Tập trung nghiệp vụ, controller gọi service |
| **Factory** | `payment/PaymentFactory.java` | Chọn payment provider theo phương thức |
| **Strategy** | `PaymentProvider` interface | Cho phép thêm provider mới không sửa code cũ |
| **Proxy** | `DBContext.wrapConnection()` | Connection pool — intercept close() trả về pool |
| **Singleton** | `LoginAttemptTracker.getInstance()` | Rate limiter chia sẻ toàn ứng dụng |
| **Filter Chain** | `filter/*.java` | Security middleware xử lý theo thứ tự |
| **Template Method** | `BaseDAO` | DAO kế thừa logic kết nối chung |

---

## 4. Luồng Request Qua Filter Chain

```
Browser gửi request
        ↓
[SecurityHeadersFilter]  →  Gắn headers bảo mật cho mọi response
        ↓
[CacheFilter]            →  Cache tĩnh (CSS/JS/img) hoặc no-cache (login)
        ↓
[CsrfFilter]             →  POST /login, /register, /checkout, /organizer/*, /admin/*
    Validate CSRF token
        ↓
[AuthFilter]             →  Kiểm tra phiên đăng nhập hoặc JWT cookie
    ├─ Session hợp lệ → đi tiếp
    ├─ Session rỗng, có JWT cookie → khôi phục session (validateAccessToken)
    ├─ Access token hết hạn → dùng refresh token (refreshAccessToken)
    └─ Không có token → redirect /login?returnUrl=...
        ↓
[OrganizerAccessFilter]  →  /organizer/* kiểm tra role organizer/admin
        ↓
[Controller / Servlet]   →  Xử lý nghiệp vụ
        ↓
[JSP View]               →  Render HTML trả về browser
```

---

## 5. Cấu Trúc Thư Mục Webapp (JSP)

```
src/webapp/
├── *.jsp             ← Trang public (home, events, login, register, checkout...)
├── admin/            ← Trang quản trị (11 trang)
├── organizer/        ← Trang organizer (17 trang)
├── assets/
│   ├── css/main.css  ← Style chính (single file)
│   └── js/           ← JS modules (animations, checkout, chat...)
├── WEB-INF/
│   ├── web.xml       ← Cấu hình filter, session, error pages
│   ├── google-oauth.properties
│   └── lib/          ← JAR dependencies
└── META-INF/
    └── context.xml   ← Datasource context (optional)
```

---

## 6. Cấu Hình Kỹ Thuật

| Thành phần | Giá trị |
|-----------|---------|
| Java | 17 |
| Servlet API | Jakarta EE 6.0 (jakarta.servlet) |
| Server | Apache Tomcat 10.1 |
| Database | SQL Server (mssql-jdbc 12.4.2) |
| Password Hash | BCrypt cost factor 12 (jbcrypt-0.4) |
| JWT | HMAC-SHA256 (tự implement, không thư viện) |
| Image Upload | Cloudinary API (cloudinary-core 1.39.0) |
| Payment | VietQR / SePay.vn |
| Build Tool | Apache Ant (NetBeans) |

---

## 7. Tóm Tắt Vai Trò Từng Class Quan Trọng

### Utility Classes

| Class | File | Vai trò |
|-------|------|---------|
| `DBContext` | `util/DBContext.java` | Connection pool tự xây, đọc `db.properties` |
| `JwtUtil` | `util/JwtUtil.java` | Tạo/xác minh JWT bằng HMAC-SHA256 |
| `PasswordUtil` | `util/PasswordUtil.java` | BCrypt hash + verify |
| `CookieUtil` | `util/CookieUtil.java` | Tạo cookie HttpOnly, SameSite, Secure |
| `ServletUtil` | `util/ServletUtil.java` | Helper lấy session user, redirect login |
| `FlashUtil` | `util/FlashUtil.java` | Toast notification qua session |
| `AppConstants` | `util/AppConstants.java` | JWT secret từ env var |

### Security Classes

| Class | File | Vai trò |
|-------|------|---------|
| `LoginAttemptTracker` | `security/LoginAttemptTracker.java` | Rate limiting email+IP, IP-only |
| `AuthFilter` | `filter/AuthFilter.java` | Kiểm tra authn cho mọi route protected |
| `CsrfFilter` | `filter/CsrfFilter.java` | CSRF token validate POST |
| `SecurityHeadersFilter` | `filter/SecurityHeadersFilter.java` | X-Frame, HSTS, CSP, Referrer-Policy |
| `AuthTokenService` | `service/AuthTokenService.java` | JWT issue / validate / refresh / revoke |
