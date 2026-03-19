# 📋 BỐ CỤC BÁO CÁO CHUYÊN SÂU – ĐỒ ÁN PRJ301
## Nền tảng Bán Vé Sự Kiện Trực Tuyến (Ticketbox)

> **Môn học:** PRJ301 – Java Web Application Development  
> **Nhóm:** Group 4  
> **Công nghệ chính:** Java Servlet/JSP, SQL Server, HTML/CSS/JS  

---

## MỤC LỤC TỔNG QUAN

| Chương | Nội dung | Trang (ước tính) |
|--------|----------|-------------------|
| 1 | Giới thiệu đề tài | 3-4 |
| 2 | Phân tích yêu cầu | 5-8 |
| 3 | Thiết kế hệ thống | 9-16 |
| 4 | Thiết kế cơ sở dữ liệu | 17-22 |
| 5 | Triển khai chi tiết | 23-38 |
| 6 | Bảo mật & An toàn | 39-42 |
| 7 | Kết quả & Demo | 43-48 |
| 8 | Kết luận & Hướng phát triển | 49-50 |

---

## CHƯƠNG 1: GIỚI THIỆU ĐỀ TÀI

### 1.1. Lý do chọn đề tài
- Nhu cầu thực tế: thị trường sự kiện Việt Nam tăng trưởng mạnh
- Vấn đề hiện tại: mua bán vé thủ công, khó quản lý, thiếu minh bạch
- Cơ hội: số hóa quy trình → tăng trải nghiệm người dùng

### 1.2. Mục tiêu đồ án
- Xây dựng nền tảng **full-stack** bán vé sự kiện trực tuyến
- Hỗ trợ 4 vai trò: Khách vãng lai, Customer, Organizer, Admin
- Tích hợp thanh toán trực tuyến (SePay, MoMo, VNPay)
- Đảm bảo bảo mật (CSRF, JWT, OAuth2)

### 1.3. Phạm vi đồ án
- **Bao gồm:** Quản lý sự kiện, đặt vé, thanh toán, check-in, dashboard, chat hỗ trợ
- **Không bao gồm:** Mobile app, AI recommendation, hệ thống logistics vé cứng

### 1.4. Công nghệ sử dụng

| Layer | Công nghệ |
|-------|-----------|
| Backend | Java Servlet 4.0, JSP, JSTL |
| Database | Microsoft SQL Server |
| Frontend | HTML5, CSS3, JavaScript (Vanilla) |
| Auth | JWT + Session + Google OAuth 2.0 |
| Payment | SePay QR, MoMo, VNPay |
| Upload | Cloudinary API |
| Build | Apache Ant, NetBeans |
| Server | Apache Tomcat 9 |

---

## CHƯƠNG 2: PHÂN TÍCH YÊU CẦU

### 2.1. Danh sách tác nhân (Actors)

| Actor | Mô tả | Quyền hạn chính |
|-------|-------|-----------------|
| Khách vãng lai | Chưa đăng nhập | Xem sự kiện, tìm kiếm, đăng ký |
| Customer | Đã đăng nhập | Mua vé, xem lịch sử, quản lý profile |
| Organizer | Nhà tổ chức | Tạo/quản lý sự kiện, xem báo cáo, soát vé |
| Staff | Nhân viên BTC | Soát vé (check-in), hỗ trợ tại sự kiện |
| Admin | Quản trị viên | Phê duyệt sự kiện, quản lý user, cấu hình hệ thống |

### 2.2. Sơ đồ Use Case (Use Case Diagram)
> *Vẽ Use Case Diagram cho từng nhóm actor*

#### 2.2.1. Use Case – Module Xác thực
| UC ID | Use Case | Actor | Mô tả |
|-------|----------|-------|-------|
| UC01 | Đăng ký tài khoản | Khách | Tạo tài khoản mới (email + Google OAuth) |
| UC02 | Đăng nhập | Khách | Xác thực bằng email/password hoặc Google |
| UC03 | Đăng xuất | All | Hủy session, clear cookies |
| UC04 | Đổi mật khẩu | Customer | Thay đổi password |

#### 2.2.2. Use Case – Module Sự kiện
| UC ID | Use Case | Actor | Mô tả |
|-------|----------|-------|-------|
| UC05 | Xem danh sách sự kiện | All | Duyệt sự kiện với filter/search |
| UC06 | Xem chi tiết sự kiện | All | Xem thông tin + loại vé |
| UC07 | Tạo sự kiện | Organizer | Tạo event mới (multi-step form) |
| UC08 | Chỉnh sửa sự kiện | Organizer | Cập nhật thông tin event |
| UC09 | Phê duyệt sự kiện | Admin | Approve/Reject event submissions |

#### 2.2.3. Use Case – Module Đặt vé & Thanh toán
| UC ID | Use Case | Actor | Mô tả |
|-------|----------|-------|-------|
| UC10 | Chọn vé | Customer | Chọn loại vé + số lượng |
| UC11 | Thanh toán (Checkout) | Customer | Nhập thông tin, chọn phương thức |
| UC12 | Xác nhận đơn hàng | Customer | Nhận vé điện tử + QR code |
| UC13 | Xem vé của tôi | Customer | Danh sách vé đã mua |

#### 2.2.4. Use Case – Module Quản trị
| UC ID | Use Case | Actor | Mô tả |
|-------|----------|-------|-------|
| UC14 | Quản lý User | Admin | CRUD user, assign roles |
| UC15 | Quản lý danh mục | Admin | CRUD categories |
| UC16 | Dashboard thống kê | Admin | Xem báo cáo tổng hợp |
| UC17 | Quản lý voucher hệ thống | Admin | Tạo/quản lý mã giảm giá |
| UC18 | Quản lý đơn hàng | Admin | Xem, xác nhận thanh toán |
| UC19 | Cài đặt hệ thống | Admin | Cấu hình site settings |

#### 2.2.5. Use Case – Module Organizer
| UC ID | Use Case | Actor | Mô tả |
|-------|----------|-------|-------|
| UC20 | Dashboard BTC | Organizer | Thống kê doanh thu, vé bán |
| UC21 | Quản lý team | Organizer | Thêm/xóa nhân viên |
| UC22 | Soát vé (Check-in) | Organizer/Staff | Quét QR, xác nhận check-in |
| UC23 | Quản lý voucher | Organizer | Tạo mã giảm giá cho sự kiện |
| UC24 | Chat hỗ trợ | Organizer | Chat với khách hàng |

### 2.3. Ma trận phân quyền (Permission Matrix)
> *Bảng chi tiết quyền truy cập của từng role đối với mỗi chức năng*

### 2.4. Yêu cầu phi chức năng
- **Hiệu năng:** Tải trang < 3s, hỗ trợ 100+ concurrent users
- **Bảo mật:** CSRF protection, SQL Injection prevention, XSS filtering
- **Khả dụng:** Responsive design, hỗ trợ đa ngôn ngữ (i18n: vi, en)
- **Tương thích:** Chrome, Firefox, Safari, Edge

---

## CHƯƠNG 3: THIẾT KẾ HỆ THỐNG

### 3.1. Kiến trúc tổng quan (System Architecture)

```
┌──────────────────────────────────────────────────┐
│                   CLIENT LAYER                    │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐         │
│  │  Browser │ │ Mobile   │ │ API      │         │
│  │  (JSP)   │ │ Browser  │ │ Client   │         │
│  └────┬─────┘ └────┬─────┘ └────┬─────┘         │
└───────┼─────────────┼────────────┼───────────────┘
        │             │            │
        ▼             ▼            ▼
┌──────────────────────────────────────────────────┐
│              WEB SERVER (Tomcat 9)                │
│  ┌───────────────────────────────────────────┐   │
│  │          FILTER CHAIN                      │   │
│  │  SecurityHeaders → CSRF → Auth → Cache    │   │
│  └───────────────────────────────────────────┘   │
│  ┌───────────────────────────────────────────┐   │
│  │          CONTROLLER LAYER                  │   │
│  │  Servlets (Web) │ API Servlets (REST)     │   │
│  └───────────────────────────────────────────┘   │
│  ┌───────────────────────────────────────────┐   │
│  │          SERVICE LAYER                     │   │
│  │  Business Logic, Validation, Payment      │   │
│  └───────────────────────────────────────────┘   │
│  ┌───────────────────────────────────────────┐   │
│  │          DAO LAYER                         │   │
│  │  Data Access Objects (JDBC + SQL Server)  │   │
│  └───────────────────────────────────────────┘   │
└───────────────────────┬──────────────────────────┘
                        │
                        ▼
┌──────────────────────────────────────────────────┐
│           EXTERNAL SERVICES                       │
│  ┌──────┐ ┌──────┐ ┌──────┐ ┌──────────────┐   │
│  │SePay │ │Google│ │Cloud-│ │ SQL Server   │   │
│  │API   │ │OAuth │ │inary │ │ Database     │   │
│  └──────┘ └──────┘ └──────┘ └──────────────┘   │
└──────────────────────────────────────────────────┘
```

### 3.2. Kiến trúc MVC (Model-View-Controller)
> Giải thích pattern MVC áp dụng trong dự án

| Thành phần | Vai trò | Vị trí trong project |
|------------|---------|---------------------|
| **Model** | 17 Java classes | `com.sellingticket.model.*` |
| **View** | 60+ JSP pages | `src/webapp/**/*.jsp` |
| **Controller** | 60+ Servlets | `com.sellingticket.controller.*` |

### 3.3. Sơ đồ lớp (Class Diagram)
> *Vẽ class diagram cho các package chính*

#### 3.3.1. Package `model` (17 classes)
- `User`, `Event`, `TicketType`, `Ticket`, `Order`, `OrderItem`
- `Category`, `Voucher`, `Notification`, `Media`, `ActivityLog`
- `ChatMessage`, `ChatSession`, `SupportTicket`, `TicketMessage`
- `EventStaff`, `PageResult`

#### 3.3.2. Package `dao` (18 classes)
- `BaseDAO` (abstract base)
- Domain-specific: `UserDAO`, `EventDAO`, `OrderDAO`, `TicketDAO`, `TicketTypeDAO`
- Supporting: `CategoryDAO`, `VoucherDAO`, `MediaDAO`, `ChatDAO`, `NotificationDAO`
- Security: `RefreshTokenDAO`, `SeepayWebhookDedupDAO`
- Admin: `DashboardDAO`, `SiteSettingsDAO`, `ActivityLogDAO`

#### 3.3.3. Package `service` (20 classes)
- Core: `UserService`, `EventService`, `OrderService`, `TicketService`
- Support: `ChatService`, `NotificationService`, `VoucherService`
- Payment: `PaymentFactory`, `PaymentProvider` (interface), `SeepayProvider`, `BankTransferProvider`
- Security: `AuthTokenService`

### 3.4. Sơ đồ tuần tự (Sequence Diagram)
> *Vẽ cho các luồng nghiệp vụ chính*

#### 3.4.1. Luồng đăng ký/đăng nhập
#### 3.4.2. Luồng mua vé
#### 3.4.3. Luồng thanh toán SePay
#### 3.4.4. Luồng check-in sự kiện
#### 3.4.5. Luồng phê duyệt sự kiện

### 3.5. Sơ đồ hoạt động (Activity Diagram)
> *Vẽ cho quy trình thanh toán và check-in*

### 3.6. Thiết kế giao diện (UI/UX Wireframe)
> *Screenshot/mockup các trang chính*

---

## CHƯƠNG 4: THIẾT KẾ CƠ SỞ DỮ LIỆU

### 4.1. Sơ đồ ERD (Entity Relationship Diagram)
> *Vẽ đầy đủ quan hệ giữa các bảng*

### 4.2. Danh sách bảng dữ liệu

| # | Tên bảng | Mô tả | Số cột |
|---|----------|-------|--------|
| 1 | `Users` | Thông tin người dùng | 8 |
| 2 | `Organizers` | Nhà tổ chức sự kiện | 5 |
| 3 | `EventCategories` | Danh mục sự kiện | 4 |
| 4 | `Events` | Sự kiện | 12+ |
| 5 | `TicketTypes` | Loại vé | 6 |
| 6 | `Orders` | Đơn hàng | 7 |
| 7 | `OrderItems` | Chi tiết đơn hàng | 5 |
| 8 | `Tickets` | Vé điện tử | 5 |
| 9 | `Vouchers` | Mã giảm giá | 10+ |
| 10 | `Notifications` | Thông báo | 6+ |
| 11 | `Media` | Media/hình ảnh sự kiện | 5+ |
| 12 | `ChatSessions` | Phiên chat | 5+ |
| 13 | `ChatMessages` | Tin nhắn chat | 5+ |
| 14 | `SupportTickets` | Phiếu hỗ trợ | 7+ |
| 15 | `TicketMessages` | Tin nhắn hỗ trợ | 4+ |
| 16 | `EventStaff` | Nhân viên BTC | 4+ |
| 17 | `ActivityLog` | Nhật ký hoạt động | 6+ |
| 18 | `SiteSettings` | Cài đặt hệ thống | 3+ |
| 19 | `RefreshTokens/UserSessions` | Session management | 5+ |
| 20 | `SeepayWebhookDedup` | Chống duplicate webhook | 3+ |
| 21 | `PaymentTransactions` | Lịch sử giao dịch | 5+ |

### 4.3. Chi tiết từng bảng (DDL)
> *Liệt kê CREATE TABLE statement cho mỗi bảng*

### 4.4. Quan hệ giữa các bảng
> *Mô tả FK constraints, relationship cardinality*

### 4.5. Indexing Strategy
> *Các index quan trọng cho performance*

---

## CHƯƠNG 5: TRIỂN KHAI CHI TIẾT

### 5.1. Cấu trúc dự án

```
SellingTicketJava/
├── src/
│   ├── java/com/sellingticket/
│   │   ├── controller/          # 60+ Servlets
│   │   │   ├── admin/           # 13 Admin controllers
│   │   │   ├── api/             # 17 REST API servlets
│   │   │   └── organizer/       # 10 Organizer controllers
│   │   ├── dao/                 # 18 Data Access Objects
│   │   ├── model/               # 17 Entity models
│   │   ├── service/             # 20 Business services
│   │   │   └── payment/         # Payment providers
│   │   ├── filter/              # 7 Security filters
│   │   ├── util/                # 12 Utility classes
│   │   ├── security/            # Login attempt tracker
│   │   └── exception/           # 2 Custom exceptions
│   └── webapp/
│       ├── *.jsp                # 24 Public pages
│       ├── admin/               # 18 Admin pages
│       ├── organizer/           # 19 Organizer pages
│       ├── staff/               # 3 Staff pages
│       └── assets/              # CSS, JS, i18n
├── database/
│   ├── schema/                  # DDL scripts
│   ├── migrations/              # Migration SQL files
│   └── seeds/                   # Seed data
└── conf/                        # Configuration
```

### 5.2. Module Xác thực (Authentication)

#### 5.2.1. Đăng ký (RegisterServlet)
- Validation: email format, password strength, phone
- Password hashing: BCrypt
- Auto-login sau đăng ký

#### 5.2.2. Đăng nhập (LoginServlet)
- Session-based authentication
- Brute-force protection: `LoginAttemptTracker`
- Remember me: Compact refresh token (`st_refresh` cookie)

#### 5.2.3. Google OAuth 2.0 (GoogleOAuthServlet)
- OAuth flow: Authorization Code Grant
- Auto-create user nếu chưa tồn tại
- Link Google account với tài khoản hiện có

#### 5.2.4. Auth Filter Chain
```
Request → SecurityHeadersFilter → CsrfFilter → AuthFilter → Controller
```

### 5.3. Module Quản lý Sự kiện

#### 5.3.1. Tạo sự kiện (Multi-step Form)
- Step 1: Thông tin cơ bản (title, description, category)
- Step 2: Địa điểm & thời gian
- Step 3: Hình ảnh & media (upload via Cloudinary)
- Step 4: Thiết lập loại vé & giá
- Step 5: Review & Submit

#### 5.3.2. Quy trình duyệt sự kiện
```
Draft → Pending Review → Approved / Rejected → Published
```

#### 5.3.3. Quản lý team BTC (EventStaff)
- Roles: manager, staff, scanner
- Permission-based access control

### 5.4. Module Đặt vé & Thanh toán

#### 5.4.1. Luồng đặt vé
```
Chọn vé → Checkout Form → Áp dụng Voucher → Thanh toán → Xác nhận → Nhận vé (QR Code)
```

#### 5.4.2. Payment Gateway Integration
- **SePay:** QR code payment + Webhook callback
- **MoMo/VNPay:** Redirect flow (chuẩn bị tích hợp)

#### 5.4.3. Webhook Security (SePay)
- API key validation
- Body size cap
- Amount mismatch rejection
- Idempotency: `SeepayWebhookDedup` table
- Atomic order confirmation

#### 5.4.4. Ticket Generation
- Unique ticket code per ticket
- QR code generation
- Status lifecycle: valid → used → cancelled

### 5.5. Module Check-in

#### 5.5.1. QR Code Scanning
- Camera-based QR reader (JavaScript)
- Real-time validation against server

#### 5.5.2. Manual Check-in
- Search by ticket code / order code
- Bulk check-in support

### 5.6. Module Chat & Hỗ trợ

#### 5.6.1. Live Chat (Organizer ↔ Customer)
- Real-time messaging
- Chat session management

#### 5.6.2. Support Ticket System
- Ticket creation → Assignment → Resolution
- Threaded messages

### 5.7. Module Dashboard & Thống kê

#### 5.7.1. Admin Dashboard
- Tổng quan hệ thống: users, events, orders, revenue
- Charts & Graphs (biểu đồ doanh thu, phân bố sự kiện)

#### 5.7.2. Organizer Dashboard
- Doanh thu theo sự kiện
- Số vé đã bán / còn lại
- Tỷ lệ check-in

### 5.8. Đa ngôn ngữ (Internationalization)
- JSON-based i18n: `vi.json`, `en.json`
- Client-side language switching
- Dynamic text rendering via `i18n.js`

---

## CHƯƠNG 6: BẢO MẬT & AN TOÀN

### 6.1. Filter Chain Architecture

| # | Filter | Vai trò |
|---|--------|---------|
| 1 | `SecurityHeadersFilter` | HTTP security headers (X-Frame-Options, CSP, etc.) |
| 2 | `CsrfFilter` | CSRF token validation |
| 3 | `AuthFilter` | Authentication & session management |
| 4 | `CacheFilter` | Response caching control |
| 5 | `OrganizerAccessFilter` | Organizer role authorization |
| 6 | `StaffAccessFilter` | Staff role authorization |
| 7 | `ProtectedJspAccessFilter` | Direct JSP access prevention |

### 6.2. Các biện pháp bảo mật

| Threat | Giải pháp | Implementation |
|--------|-----------|----------------|
| SQL Injection | PreparedStatement | Toàn bộ DAO layer |
| XSS | Input validation + Output encoding | `InputValidator`, JSP escaping |
| CSRF | Double-submit token | `CsrfFilter` + hidden form field |
| Brute Force | Rate limiting | `LoginAttemptTracker` |
| Session Hijacking | HttpOnly + Secure cookies | `CookieUtil` |
| Unauthorized Access | Role-based filters | Auth/Organizer/Staff filters |

### 6.3. Authentication Flow
> *Sơ đồ chi tiết: Session → JWT → Refresh Token → Google OAuth*

### 6.4. Payment Security
> *Webhook validation, idempotency, atomic transactions*

---

## CHƯƠNG 7: KẾT QUẢ & DEMO

### 7.1. Screenshot các trang chính

#### Giao diện người mua (24 trang)
- Trang chủ, danh sách sự kiện, chi tiết sự kiện
- Checkout, thanh toán, xác nhận đơn hàng
- Trang profile, vé của tôi, hỗ trợ

#### Giao diện Organizer (19 trang)
- Dashboard, tạo sự kiện, quản lý sự kiện
- Check-in, thống kê, quản lý team
- Chat, voucher, settings

#### Giao diện Admin (18 trang)
- Dashboard, quản lý user, phê duyệt sự kiện
- Quản lý đơn hàng, reports, settings
- Chat dashboard, activity log

#### Giao diện Staff (3 trang)
- Dashboard, check-in, sidebar

### 7.2. Bảng tính năng đã hoàn thành

| Module | Tính năng | Trạng thái |
|--------|-----------|------------|
| Auth | Đăng ký, đăng nhập, Google OAuth | ✅ |
| Events | CRUD, search, filter, categories | ✅ |
| Booking | Chọn vé, checkout, thanh toán | ✅ |
| Payment | SePay QR, webhook | ✅ |
| Check-in | QR scan, manual check-in | ✅ |
| Admin | Dashboard, user mgmt, reports | ✅ |
| Chat | Live chat, support tickets | ✅ |
| i18n | Tiếng Việt, English | ✅ |
| Voucher | System + Organizer vouchers | ✅ |
| Notification | In-app notifications | ✅ |

### 7.3. Thống kê code

| Metric | Giá trị |
|--------|---------|
| Tổng số Java classes | ~130+ |
| Controllers/Servlets | 60+ |
| DAO classes | 18 |
| Model classes | 17 |
| Service classes | 20 |
| Filter classes | 7 |
| JSP pages | 64+ |
| Database tables | 20+ |

---

## CHƯƠNG 8: KẾT LUẬN & HƯỚNG PHÁT TRIỂN

### 8.1. Kết quả đạt được
- Xây dựng thành công nền tảng bán vé sự kiện đầy đủ chức năng
- Áp dụng kiến trúc MVC chuẩn, phân tầng rõ ràng
- Tích hợp thanh toán thực tế (SePay)
- Bảo mật đa lớp (7 security filters)

### 8.2. Hạn chế
- Chưa có unit test tự động
- Chưa tối ưu cho mobile native
- Thanh toán MoMo/VNPay chưa hoàn thiện
- Chưa có caching layer (Redis)

### 8.3. Hướng phát triển
- Mobile app (React Native / Flutter)
- AI-powered event recommendation
- Real-time analytics dashboard
- Microservices architecture
- CI/CD pipeline automation
- CDN cho static assets

---

## PHỤ LỤC

### A. Cấu hình môi trường phát triển
- JDK, Tomcat, SQL Server setup
- Environment variables ([.env.example](file:///d:/GITHUB/PRJ301_GROUP4_SELLING_TICKET/SellingTicketJava/.env.example))

### B. Script cơ sở dữ liệu
- [full_reset_seed.sql](file:///d:/GITHUB/PRJ301_GROUP4_SELLING_TICKET/SellingTicketJava/database/full_reset_seed.sql) – Full database schema + seed data
- Migration scripts

### C. API Reference
- REST API endpoints documentation
- Request/Response format

### D. Hướng dẫn cài đặt & triển khai
- Build steps
- Deployment guide

---

## GHI CHÚ CHO TỪNG THÀNH VIÊN NHÓM

> **Gợi ý phân chia viết báo cáo:**

| Thành viên | Phần phụ trách | Chương |
|------------|---------------|--------|
| TV1 | Giới thiệu + Phân tích yêu cầu | Ch.1 + Ch.2 |
| TV2 | Thiết kế hệ thống (kiến trúc, class diagram) | Ch.3 |
| TV3 | Thiết kế CSDL + Triển khai backend core | Ch.4 + Ch.5.1-5.4 |
| TV4 | Triển khai modules phụ + Bảo mật + Demo | Ch.5.5-5.8 + Ch.6 + Ch.7 |
| Cả nhóm | Kết luận + Review | Ch.8 |

---

> **📌 Lưu ý quan trọng:**
> - Mỗi phần cần có **sơ đồ/hình ảnh minh họa** (Use Case, Sequence, ERD, Screenshot)
> - Sử dụng **Mermaid** hoặc **draw.io** để vẽ diagram
> - Các đoạn code mẫu cần **có chú thích** và **giải thích logic**
> - Viết **tiếng Việt**, code/tên biến giữ **tiếng Anh**
