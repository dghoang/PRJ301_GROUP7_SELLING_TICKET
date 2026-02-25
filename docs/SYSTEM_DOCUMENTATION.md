# 📋 TÀI LIỆU HỆ THỐNG TICKETBOX
### Nền tảng bán vé sự kiện trực tuyến | PRJ301 - Nhóm 4

---

## 1. TỔNG QUAN HỆ THỐNG

### 1.1 Mô tả dự án
TicketBox là nền tảng bán vé sự kiện trực tuyến cho phép:
- **Khách hàng (Customer):** duyệt, tìm kiếm và mua vé sự kiện
- **Nhà tổ chức (Organizer):** tạo và quản lý sự kiện, theo dõi đơn hàng
- **Quản trị viên (Admin):** phê duyệt sự kiện, quản lý người dùng, xem thống kê

### 1.2 Tech Stack

| Thành phần | Công nghệ | Phiên bản |
|------------|-----------|-----------|
| **Backend** | Java Servlet (Jakarta EE) | Jakarta EE 10 |
| **Web Server** | Apache Tomcat | 10.x |
| **Database** | Microsoft SQL Server | 2019+ |
| **View Engine** | JSP + JSTL | 3.0 |
| **Password Hashing** | jBCrypt | 0.4 |
| **Media Storage** | Cloudinary SDK | 1.39.0 |
| **HTTP Client** | Apache HttpClient | 4.5.14 |
| **Build Tool** | Apache Ant (NetBeans) | NetBeans 21+ |
| **Java** | JDK | 17 |

### 1.3 Kiến trúc tổng quan

```
┌─────────────────────────────────────────────────────────────────┐
│                        BROWSER (Client)                         │
│                   HTML / CSS / JavaScript                        │
└────────────────────────┬────────────────────────────────────────┘
                         │ HTTP Request
┌────────────────────────▼────────────────────────────────────────┐
│                    APACHE TOMCAT 10.x                            │
│  ┌──────────────┐  ┌──────────────────┐  ┌───────────────────┐  │
│  │  AuthFilter   │→│    Servlets       │→│   JSP Views        │  │
│  │  (RBAC)       │  │  (Controllers)   │  │  (Presentation)   │  │
│  └──────────────┘  └────────┬─────────┘  └───────────────────┘  │
│                             │                                    │
│                    ┌────────▼─────────┐                          │
│                    │    Services       │                          │
│                    │ (Business Logic)  │                          │
│                    └────────┬─────────┘                          │
│                             │                                    │
│                    ┌────────▼─────────┐                          │
│                    │      DAOs         │                          │
│                    │ (Data Access)     │                          │
│                    └────────┬─────────┘                          │
│                             │                                    │
│                    ┌────────▼─────────┐  ┌───────────────────┐  │
│                    │    DBContext      │  │  CloudinaryUtil    │  │
│                    │ (SQL Server)      │  │  (Media CDN)       │  │
│                    └──────────────────┘  └───────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
           │                                     │
    ┌──────▼──────┐                      ┌───────▼───────┐
    │  SQL Server  │                      │  Cloudinary   │
    │  Database    │                      │  CDN          │
    └─────────────┘                      └───────────────┘
```

---

## 2. CẤU TRÚC THƯ MỤC DỰ ÁN

```
SellingTicketJava/
├── database/
│   ├── ticketbox_schema.sql          # Schema V3.0 (15 bảng)
│   └── mock_data.sql                 # Dữ liệu mẫu
├── nbproject/                        # NetBeans project config
│   └── project.properties            # Classpath & JARs
├── src/
│   ├── java/
│   │   ├── cloudinary.properties     # Cấu hình Cloudinary (không commit)
│   │   └── com/sellingticket/
│   │       ├── model/                # 7 Model classes
│   │       │   ├── User.java
│   │       │   ├── Event.java
│   │       │   ├── Category.java
│   │       │   ├── TicketType.java
│   │       │   ├── Order.java
│   │       │   ├── OrderItem.java
│   │       │   └── Media.java
│   │       ├── dao/                  # 6 DAO classes
│   │       │   ├── UserDAO.java
│   │       │   ├── EventDAO.java
│   │       │   ├── CategoryDAO.java
│   │       │   ├── TicketTypeDAO.java
│   │       │   ├── OrderDAO.java
│   │       │   └── MediaDAO.java
│   │       ├── service/              # 6 Service classes
│   │       │   ├── UserService.java
│   │       │   ├── EventService.java
│   │       │   ├── CategoryService.java
│   │       │   ├── TicketService.java
│   │       │   ├── OrderService.java
│   │       │   └── MediaService.java
│   │       ├── controller/           # 13 Public Servlets
│   │       │   ├── HomeServlet.java
│   │       │   ├── LoginServlet.java
│   │       │   ├── RegisterServlet.java
│   │       │   ├── LogoutServlet.java
│   │       │   ├── EventsServlet.java
│   │       │   ├── EventDetailServlet.java
│   │       │   ├── TicketSelectionServlet.java
│   │       │   ├── CheckoutServlet.java
│   │       │   ├── OrderConfirmationServlet.java
│   │       │   ├── ProfileServlet.java
│   │       │   ├── StaticPagesServlet.java
│   │       │   ├── OrganizerServlet.java
│   │       │   ├── MediaUploadServlet.java
│   │       │   ├── admin/            # 4 Admin Controllers
│   │       │   │   ├── AdminDashboardController.java
│   │       │   │   ├── AdminEventController.java
│   │       │   │   ├── AdminUserController.java
│   │       │   │   └── AdminCategoryController.java
│   │       │   └── organizer/        # 3 Organizer Controllers
│   │       │       ├── OrganizerDashboardController.java
│   │       │       ├── OrganizerEventController.java
│   │       │       └── OrganizerOrderController.java
│   │       ├── filter/
│   │       │   └── AuthFilter.java   # RBAC Authentication Filter
│   │       └── util/
│   │           ├── DBContext.java     # Database connection base
│   │           ├── PasswordUtil.java  # BCrypt hashing
│   │           ├── ServletUtil.java   # Common servlet helpers
│   │           └── CloudinaryUtil.java# Cloudinary SDK wrapper
│   └── webapp/
│       ├── WEB-INF/
│       │   ├── web.xml               # Jakarta EE 10 deployment descriptor
│       │   └── lib/                  # 13 JAR dependencies
│       ├── assets/
│       │   ├── css/main.css          # Global stylesheet
│       │   └── js/                   # animations.js, toast.js
│       ├── index.jsp                 # Welcome page (redirect)
│       ├── home.jsp                  # Landing page
│       ├── login.jsp / register.jsp  # Authentication pages
│       ├── events.jsp                # Event listing
│       ├── event-detail.jsp          # Event detail view
│       ├── ticket-selection.jsp      # Ticket picker
│       ├── checkout.jsp              # Payment form
│       ├── order-confirmation.jsp    # Order success
│       ├── profile.jsp               # User profile
│       ├── categories.jsp            # Category listing
│       ├── about.jsp / faq.jsp       # Static pages
│       ├── header.jsp / footer.jsp   # Shared layout
│       ├── 404.jsp                   # Error page
│       ├── admin/                    # 8 Admin JSPs
│       │   ├── dashboard.jsp
│       │   ├── events.jsp / event-approval.jsp
│       │   ├── users.jsp
│       │   ├── categories.jsp
│       │   ├── reports.jsp / settings.jsp
│       │   └── sidebar.jsp
│       └── organizer/                # 10 Organizer JSPs
│           ├── dashboard.jsp
│           ├── events.jsp / create-event.jsp
│           ├── orders.jsp / tickets.jsp
│           ├── statistics.jsp / vouchers.jsp
│           ├── check-in.jsp / team.jsp / settings.jsp
│           └── sidebar.jsp
```

---

## 3. CƠ SỞ DỮ LIỆU

### 3.1 Sơ đồ ERD (Entity Relationship Diagram)

```mermaid
erDiagram
    Users ||--o{ Events : "organizes"
    Users ||--o{ Orders : "places"
    Categories ||--o{ Events : "categorizes"
    Events ||--o{ TicketTypes : "has"
    Events ||--o{ Orders : "sells_through"
    Events ||--o{ EventSchedules : "schedules"
    Events ||--o{ Vouchers : "discounts"
    Orders ||--o{ OrderItems : "contains"
    TicketTypes ||--o{ OrderItems : "purchased_as"
    Orders ||--o| Payments : "paid_via"
    Orders ||--o| Refunds : "refunded_via"
    Users ||--o{ Media : "uploads"
    Events ||--o{ Media : "has_media"

    Users {
        int user_id PK
        nvarchar email UK
        nvarchar password_hash
        nvarchar full_name
        nvarchar phone
        nvarchar role "customer|organizer|admin"
        nvarchar avatar_url
        bit is_active
        nvarchar organization_name
        nvarchar organization_desc
        nvarchar tax_code
        nvarchar bank_account
        nvarchar bank_name
    }

    Categories {
        int category_id PK
        nvarchar name UK
        nvarchar slug UK
        nvarchar icon
        nvarchar description
    }

    Events {
        int event_id PK
        int organizer_id FK
        int category_id FK
        nvarchar title
        nvarchar slug UK
        ntext description
        nvarchar venue_name
        nvarchar venue_address
        datetime start_date
        datetime end_date
        nvarchar banner_image
        nvarchar status "draft|pending|approved|rejected|cancelled"
        bit is_featured
        bit is_online
        int max_capacity
    }

    TicketTypes {
        int ticket_type_id PK
        int event_id FK
        nvarchar name
        float price
        int quantity
        int sold_quantity
        datetime sale_start
        datetime sale_end
        bit is_active
    }

    Orders {
        int order_id PK
        nvarchar order_code UK
        int user_id FK
        int event_id FK
        float total_amount
        float discount_amount
        float final_amount
        nvarchar status "pending|paid|cancelled|refunded"
        nvarchar payment_method
        datetime payment_date
        nvarchar buyer_name
        nvarchar buyer_email
        nvarchar buyer_phone
    }

    OrderItems {
        int order_item_id PK
        int order_id FK
        int ticket_type_id FK
        int quantity
        float unit_price
        float subtotal
    }

    Media {
        int media_id PK
        nvarchar entity_type "user|event|ticket_type"
        int entity_id
        nvarchar media_purpose
        nvarchar cloudinary_url
        nvarchar cloudinary_public_id
        nvarchar file_name
        nvarchar file_type
        bigint file_size
        int sort_order
    }
```

### 3.2 Danh sách 15 bảng

| # | Bảng | Mô tả | Quan hệ chính |
|---|------|-------|----------------|
| 1 | **Users** | Người dùng (customer, organizer, admin) | → Events, Orders, Media |
| 2 | **Categories** | Danh mục sự kiện (Âm nhạc, Thể thao...) | → Events |
| 3 | **Events** | Sự kiện | → Users, Categories, TicketTypes, Orders |
| 4 | **EventSchedules** | Lịch trình sự kiện (multi-day) | → Events |
| 5 | **TicketTypes** | Loại vé (VIP, Standard, Early Bird) | → Events, OrderItems |
| 6 | **Orders** | Đơn hàng | → Users, Events, OrderItems |
| 7 | **OrderItems** | Chi tiết đơn hàng (từng loại vé) | → Orders, TicketTypes |
| 8 | **Payments** | Thanh toán (VNPay, Momo, bank_transfer) | → Orders |
| 9 | **Refunds** | Hoàn tiền | → Orders |
| 10 | **Vouchers** | Mã giảm giá | → Events |
| 11 | **VoucherUsage** | Lịch sử dùng voucher | → Vouchers, Users, Orders |
| 12 | **Reviews** | Đánh giá sự kiện | → Users, Events |
| 13 | **Notifications** | Thông báo | → Users |
| 14 | **AuditLog** | Nhật ký hoạt động | → Users |
| 15 | **Media** | Tệp media (Cloudinary) | → polymorphic (Users, Events, TicketTypes) |

---

## 4. KIẾN TRÚC PHẦN MỀM

### 4.1 Design Pattern: 4-Tier MVC

```mermaid
graph TD
    subgraph "View Layer (JSP + JSTL)"
        V1["35 JSP Pages"]
        V2["header.jsp / footer.jsp (Shared Layout)"]
        V3["main.css + JS (Assets)"]
    end

    subgraph "Controller Layer (Servlets)"
        C1["13 Public Servlets"]
        C2["4 Admin Controllers"]
        C3["3 Organizer Controllers"]
        C4["AuthFilter (RBAC)"]
    end

    subgraph "Service Layer (Business Logic)"
        S1["UserService"]
        S2["EventService"]
        S3["CategoryService"]
        S4["TicketService"]
        S5["OrderService"]
        S6["MediaService"]
    end

    subgraph "Data Access Layer (DAO)"
        D1["UserDAO"]
        D2["EventDAO"]
        D3["CategoryDAO"]
        D4["TicketTypeDAO"]
        D5["OrderDAO"]
        D6["MediaDAO"]
    end

    subgraph "Infrastructure"
        I1["DBContext (SQL Server Connection)"]
        I2["PasswordUtil (BCrypt)"]
        I3["CloudinaryUtil (Media CDN)"]
        I4["ServletUtil (Helpers)"]
    end

    V1 --> C1
    C4 --> C1
    C4 --> C2
    C4 --> C3
    C1 --> S1 & S2 & S3 & S4 & S5
    C2 --> S1 & S2 & S3 & S5
    C3 --> S2 & S5
    S1 --> D1
    S2 --> D2
    S3 --> D3
    S4 --> D4
    S5 --> D5
    S6 --> D6 & I3
    D1 & D2 & D3 & D4 & D5 & D6 --> I1
```

### 4.2 Phân tầng chi tiết

| Tầng | Package | Vai trò | Quy tắc |
|------|---------|---------|---------|
| **Model** | `com.sellingticket.model` | POJO với getter/setter | Không chứa logic, chỉ dữ liệu |
| **DAO** | `com.sellingticket.dao` | SQL CRUD trực tiếp | Extends `DBContext`, JDBC PreparedStatement |
| **Service** | `com.sellingticket.service` | Validation + Business rules | Gọi DAO, xử lý lỗi, phối hợp nhiều DAO |
| **Controller** | `com.sellingticket.controller` | Nhận HTTP, parse params, trả JSP | Gọi Service, forward/redirect |
| **Filter** | `com.sellingticket.filter` | Intercept request | Kiểm tra session, role |
| **Util** | `com.sellingticket.util` | Shared utilities | Static methods, singleton |

---

## 5. HỆ THỐNG PHÂN QUYỀN (RBAC)

### 5.1 Ba vai trò

```mermaid
graph LR
    subgraph "Customer"
        CU1["Duyệt sự kiện"]
        CU2["Mua vé"]
        CU3["Xem đơn hàng"]
        CU4["Cập nhật profile"]
    end

    subgraph "Organizer"
        OR1["Tạo sự kiện"]
        OR2["Quản lý vé"]
        OR3["Xem đơn hàng sự kiện"]
        OR4["Dashboard thống kê"]
    end

    subgraph "Admin"
        AD1["Phê duyệt sự kiện"]
        AD2["Quản lý người dùng"]
        AD3["Quản lý danh mục"]
        AD4["Dashboard toàn hệ thống"]
    end
```

### 5.2 AuthFilter Logic

```
Request → AuthFilter
  ├── URL matches /organizer/*, /admin/*, /checkout, /tickets, /order-confirmation?
  │   ├── NO → Pass through (public page)
  │   └── YES → Check session user
  │       ├── user == null → Redirect to /login?redirect=<original_url>
  │       └── user != null → Check role
  │           ├── /admin/* && role != "admin" → Redirect /home?error=unauthorized
  │           ├── /organizer/* && role != "organizer" && role != "admin" → Redirect /home
  │           └── Role OK → chain.doFilter() (allow)
```

### 5.3 Ma trận quyền truy cập

| URL Pattern | Public | Customer | Organizer | Admin |
|-------------|--------|----------|-----------|-------|
| `/home`, `/events`, `/event-detail` | ✅ | ✅ | ✅ | ✅ |
| `/categories`, `/about`, `/faq` | ✅ | ✅ | ✅ | ✅ |
| `/login`, `/register` | ✅ | ✅ | ✅ | ✅ |
| `/checkout`, `/tickets` | ❌ | ✅ | ✅ | ✅ |
| `/order-confirmation` | ❌ | ✅ | ✅ | ✅ |
| `/profile` | ❌ | ✅ | ✅ | ✅ |
| `/organizer/*` | ❌ | ❌ | ✅ | ✅ |
| `/admin/*` | ❌ | ❌ | ❌ | ✅ |
| `/media/upload` | ✅* | ✅ | ✅ | ✅ |

> *`/media/upload` kiểm tra auth trong servlet code, không qua AuthFilter

---

## 6. SERVLET ENDPOINTS (API Reference)

### 6.1 Public Endpoints

| Servlet | URL | Method | Chức năng |
|---------|-----|--------|-----------|
| `HomeServlet` | `/home` | GET | Trang chủ: featured events + categories + upcoming events |
| `EventsServlet` | `/events` | GET | Danh sách sự kiện: search, filter by category/date, phân trang |
| `EventDetailServlet` | `/event-detail` | GET | Chi tiết sự kiện: info, ticket types, related events |
| `TicketSelectionServlet` | `/tickets` | GET | Chọn loại vé + số lượng 🔒 |
| `CheckoutServlet` | `/checkout` | GET/POST | Form thanh toán (GET) + Tạo đơn hàng (POST) 🔒 |
| `OrderConfirmationServlet` | `/order-confirmation` | GET | Xác nhận đơn hàng thành công 🔒 |
| `LoginServlet` | `/login` | GET/POST | Form đăng nhập (GET) + Xử lý login (POST) |
| `RegisterServlet` | `/register` | GET/POST | Form đăng ký (GET) + Tạo tài khoản (POST) |
| `LogoutServlet` | `/logout` | GET | Xóa session, redirect về home |
| `ProfileServlet` | `/profile` | GET/POST | Xem (GET) + Cập nhật profile (POST) |
| `StaticPagesServlet` | `/categories`, `/about`, `/faq` | GET | Trang tĩnh |
| `MediaUploadServlet` | `/media/upload` | POST/DELETE | Upload file → Cloudinary, trả JSON |

> 🔒 = Yêu cầu đăng nhập (AuthFilter protected)

### 6.2 Admin Endpoints

| Servlet | URL | Method | Chức năng |
|---------|-----|--------|-----------|
| `AdminDashboardController` | `/admin`, `/admin/dashboard` | GET | Dashboard: tổng users, events, orders, revenue |
| `AdminEventController` | `/admin/events`, `/admin/events/*` | GET/POST | CRUD sự kiện + phê duyệt/từ chối |
| `AdminUserController` | `/admin/users`, `/admin/users/*` | GET/POST | CRUD người dùng: search, update role, deactivate |
| `AdminCategoryController` | `/admin/categories`, `/admin/categories/*` | GET/POST | CRUD danh mục sự kiện |

### 6.3 Organizer Endpoints

| Servlet | URL | Method | Chức năng |
|---------|-----|--------|-----------|
| `OrganizerDashboardController` | `/organizer`, `/organizer/dashboard` | GET | Dashboard: thống kê sự kiện cá nhân |
| `OrganizerEventController` | `/organizer/events`, `/organizer/events/*` | GET/POST | CRUD sự kiện của organizer |
| `OrganizerOrderController` | `/organizer/orders`, `/organizer/orders/*` | GET/POST | Xem đơn hàng, cập nhật trạng thái |

---

## 7. DATA MODELS (Chi tiết)

### 7.1 User

| Field | Type | DB Column | Mô tả |
|-------|------|-----------|-------|
| `userId` | int | `user_id` | PK, auto-increment |
| `email` | String | `email` | Unique, dùng để login |
| `fullName` | String | `full_name` | Tên hiển thị |
| `phone` | String | `phone` | Số điện thoại |
| `role` | String | `role` | `customer` / `organizer` / `admin` |
| `avatar` | String | `avatar` | URL ảnh đại diện |
| `isActive` | boolean | `is_active` | Tài khoản đang hoạt động |
| `createdAt` | Date | `created_at` | Ngày tạo |

### 7.2 Event

| Field | Type | DB Column | Mô tả |
|-------|------|-----------|-------|
| `eventId` | int | `event_id` | PK |
| `organizerId` | int | `organizer_id` | FK → Users |
| `categoryId` | int | `category_id` | FK → Categories |
| `title` | String | `title` | Tên sự kiện |
| `slug` | String | `slug` | URL-friendly identifier |
| `description` | String | `description` | Mô tả HTML |
| `venueName` | String | `venue_name` | Tên địa điểm |
| `venueAddress` | String | `venue_address` | Địa chỉ |
| `startDate` | Date | `start_date` | Ngày bắt đầu |
| `endDate` | Date | `end_date` | Ngày kết thúc |
| `bannerImage` | String | `banner_image` | URL banner (Cloudinary) |
| `status` | String | `status` | `draft`/`pending`/`approved`/`rejected`/`cancelled` |
| `isFeatured` | boolean | `is_featured` | Sự kiện nổi bật |
| `isOnline` | boolean | `is_online` | Sự kiện online |
| `maxCapacity` | int | `max_capacity` | Sức chứa tối đa |
| `viewCount` | int | `view_count` | Lượt xem |
| *categoryName* | String | *JOIN* | Tên danh mục (joined) |
| *organizerName* | String | *JOIN* | Tên organizer (joined) |
| *minPrice* | double | *Subquery* | Giá vé thấp nhất (computed) |

### 7.3 TicketType

| Field | Type | Mô tả |
|-------|------|-------|
| `ticketTypeId` | int | PK |
| `eventId` | int | FK → Events |
| `name` | String | Tên loại vé (VIP, Standard...) |
| `description` | String | Mô tả quyền lợi |
| `price` | double | Giá vé (VNĐ) |
| `quantity` | int | Tổng số lượng |
| `soldQuantity` | int | Đã bán |
| `saleStart` / `saleEnd` | Date | Thời gian mở bán |
| `isActive` | boolean | Trạng thái (soft delete) |
| *availableQuantity* | int | `quantity - soldQuantity` (computed) |

### 7.4 Order

| Field | Type | Mô tả |
|-------|------|-------|
| `orderId` | int | PK |
| `orderCode` | String | Mã đơn hàng unique (ORD-timestamp-random) |
| `userId` | int | FK → Users (khách mua) |
| `eventId` | int | FK → Events |
| `totalAmount` | double | Tổng giá trước giảm |
| `discountAmount` | double | Giảm giá (voucher) |
| `finalAmount` | double | Thành tiền |
| `status` | String | `pending`/`paid`/`cancelled`/`refund_requested`/`refunded` |
| `paymentMethod` | String | `bank_transfer`/`cash`/`vnpay`/`momo` |
| `paymentDate` | Date | Ngày thanh toán |
| `buyerName` / `buyerEmail` / `buyerPhone` | String | Thông tin người mua |
| `notes` | String | Ghi chú |
| *items* | List\<OrderItem\> | Danh sách vé trong đơn (joined) |

### 7.5 Media (Cloudinary)

| Field | Type | Mô tả |
|-------|------|-------|
| `mediaId` | int | PK |
| `entityType` | String | `user` / `event` / `ticket_type` (polymorphic) |
| `entityId` | int | ID của entity liên quan |
| `mediaPurpose` | String | `avatar` / `banner` / `gallery` / `ticket_image` |
| `cloudinaryUrl` | String | URL đầy đủ trên Cloudinary |
| `cloudinaryPublicId` | String | ID để delete/transform |
| `fileName` | String | Tên file gốc |
| `fileType` | String | MIME type (image/jpeg...) |
| `fileSize` | long | Kích thước (bytes, max 50MB) |
| `sortOrder` | int | Thứ tự hiển thị |

---

## 8. LUỒNG NGHIỆP VỤ CHÍNH

### 8.1 Luồng mua vé

```mermaid
sequenceDiagram
    actor Customer
    participant Browser
    participant EventDetailServlet
    participant TicketSelectionServlet
    participant CheckoutServlet
    participant OrderService
    participant TicketTypeDAO
    participant OrderDAO

    Customer->>Browser: Xem sự kiện
    Browser->>EventDetailServlet: GET /event-detail?id=1
    EventDetailServlet->>Browser: event-detail.jsp (thông tin + loại vé)

    Customer->>Browser: Chọn vé
    Browser->>TicketSelectionServlet: GET /tickets?eventId=1
    TicketSelectionServlet->>Browser: ticket-selection.jsp

    Customer->>Browser: Điền thông tin thanh toán
    Browser->>CheckoutServlet: POST /checkout (eventId, ticketTypeId, quantity, paymentMethod)

    CheckoutServlet->>OrderService: createOrder(order)
    OrderService->>TicketTypeDAO: checkAvailability(ticketTypeId, qty)
    TicketTypeDAO-->>OrderService: true/false

    alt Vé còn
        OrderService->>OrderDAO: createOrder(order) → orderId
        OrderService->>TicketTypeDAO: updateSoldQuantity(ticketTypeId, qty)
        OrderService-->>CheckoutServlet: orderId > 0
        CheckoutServlet->>Browser: Redirect → /order-confirmation?id=orderId
    else Hết vé
        OrderService-->>CheckoutServlet: 0
        CheckoutServlet->>Browser: Hiện lỗi "Số lượng vé không đủ"
    end
```

### 8.2 Luồng đăng ký & đăng nhập

```mermaid
sequenceDiagram
    actor User
    participant RegisterServlet
    participant LoginServlet
    participant UserService
    participant UserDAO
    participant PasswordUtil

    User->>RegisterServlet: POST /register (email, password, name, phone)
    RegisterServlet->>UserService: register(email, password, name, phone)
    UserService->>UserDAO: isEmailExists(email)
    alt Email đã tồn tại
        UserDAO-->>UserService: true
        UserService-->>RegisterServlet: false
        RegisterServlet->>User: "Email đã được sử dụng"
    else Email mới
        UserDAO-->>UserService: false
        UserService->>PasswordUtil: hashPassword(password) → BCrypt hash
        UserService->>UserDAO: register(email, hash, name, phone)
        RegisterServlet->>User: Redirect → /login?success=registered
    end

    User->>LoginServlet: POST /login (email, password)
    LoginServlet->>UserService: authenticate(email, password)
    UserService->>UserDAO: login(email, password)
    UserDAO->>PasswordUtil: checkPassword(password, storedHash)
    alt Đúng mật khẩu
        UserDAO-->>UserService: User object
        LoginServlet->>User: Session.setAttribute("user", user) → Redirect /home
    else Sai
        LoginServlet->>User: "Email hoặc mật khẩu không đúng"
    end
```

### 8.3 Luồng tạo sự kiện (Organizer)

```mermaid
sequenceDiagram
    actor Organizer
    participant OrganizerEventController
    participant EventService
    participant EventDAO
    participant Admin

    Organizer->>OrganizerEventController: POST /organizer/events (title, venue, date...)
    OrganizerEventController->>EventService: createEvent(event)
    EventService->>EventDAO: createEvent(event) [status = "pending"]
    EventDAO-->>EventService: eventId

    Note over Admin: Admin thấy pending event trong dashboard
    Admin->>AdminEventController: POST /admin/events/{id} (action=approve)
    AdminEventController->>EventService: updateEventStatus(id, "approved")
    Note over Organizer: Event xuất hiện trên trang chủ
```

### 8.4 Luồng upload media (Cloudinary)

```mermaid
sequenceDiagram
    actor User
    participant MediaUploadServlet
    participant MediaService
    participant CloudinaryUtil
    participant Cloudinary CDN
    participant MediaDAO

    User->>MediaUploadServlet: POST /media/upload (file, entityType, entityId, purpose)
    MediaUploadServlet->>MediaService: uploadMedia(file, entityType, entityId, purpose)

    MediaService->>MediaService: Validate (fileType, size ≤ 50MB)
    MediaService->>CloudinaryUtil: upload(inputStream, folder)
    CloudinaryUtil->>Cloudinary CDN: Upload file
    Cloudinary CDN-->>CloudinaryUtil: {url, public_id}

    MediaService->>MediaDAO: insertMedia(media)
    MediaService->>MediaService: Update parent entity (e.g., Events.banner_image = url)
    MediaService-->>MediaUploadServlet: Media object

    MediaUploadServlet->>User: JSON {success: true, url: "https://res.cloudinary.com/..."}
```

---

## 9. CẤU HÌNH & TRIỂN KHAI

### 9.1 Database Connection

File: `com.sellingticket.util.DBContext`

```java
// Connection string format:
String url = "jdbc:sqlserver://localhost:1433;databaseName=SellingTicketDB;encrypt=true;trustServerCertificate=true";
String user = "sa";
String password = "your_password";
```

### 9.2 Cloudinary Configuration

File: `src/java/cloudinary.properties`

```properties
cloudinary.cloud_name=YOUR_CLOUD_NAME
cloudinary.api_key=YOUR_API_KEY
cloudinary.api_secret=YOUR_API_SECRET
cloudinary.secure=true
```

> ⚠️ File này nằm trong `.gitignore` — KHÔNG commit credentials lên Git

### 9.3 Dependencies (WEB-INF/lib)

| JAR | Phiên bản | Mục đích |
|-----|-----------|----------|
| `jakarta.servlet-api` | 6.0.0 | Servlet API (Jakarta EE 10) |
| `jakarta.servlet.jsp-api` | 3.1.0 | JSP API |
| `jakarta.servlet.jsp.jstl` | 3.0.1 | JSTL Tags |
| `jakarta.servlet.jsp.jstl-api` | 3.0.0 | JSTL API |
| `mssql-jdbc` | 12.4.2 | SQL Server JDBC Driver |
| `jbcrypt` | 0.4 | BCrypt Password Hashing |
| `cloudinary-core` | 1.39.0 | Cloudinary SDK Core |
| `cloudinary-http45` | 1.39.0 | Cloudinary HTTP Transport |
| `httpclient` | 4.5.14 | Apache HTTP Client |
| `httpcore` | 4.4.16 | Apache HTTP Core |
| `httpmime` | 4.5.14 | Multipart Upload Support |
| `commons-logging` | 1.2 | Logging (HttpClient dependency) |
| `commons-codec` | 1.16.1 | Encoding (HttpClient dependency) |

### 9.4 Hướng dẫn cài đặt

```bash
# 1. Clone project
git clone https://github.com/YOUR_REPO/PRJ301_GROUP4_SELLING_TICKET.git

# 2. Mở SQL Server Management Studio
#    - Chạy database/ticketbox_schema.sql → Tạo DB + 15 bảng
#    - Chạy database/mock_data.sql → Dữ liệu mẫu

# 3. Cấu hình DB
#    - Mở src/java/com/sellingticket/util/DBContext.java
#    - Sửa connection string, username, password

# 4. Cấu hình Cloudinary (tùy chọn)
#    - Tạo tài khoản tại https://cloudinary.com
#    - Sửa src/java/cloudinary.properties

# 5. Mở project trong NetBeans
#    - File → Open Project → Chọn SellingTicketJava/
#    - Nếu lỗi classpath: Right-click → Resolve Problems
#    - Shift+F11 → Clean & Build

# 6. Deploy
#    - F6 → Run (Tomcat tự deploy)
#    - Mở http://localhost:8080/SellingTicketJava/home
```

### 9.5 Tài khoản mẫu (Mock Data)

| Email | Password | Role |
|-------|----------|------|
| `admin@ticketbox.vn` | `123456` | Admin |
| `organizer@ticketbox.vn` | `123456` | Organizer |
| `user@ticketbox.vn` | `123456` | Customer |

---

## 10. TỔNG KẾT SỐ LIỆU

| Metric | Giá trị |
|--------|---------|
| **Tổng file Java** | 44 |
| **Models** | 7 (User, Event, Category, TicketType, Order, OrderItem, Media) |
| **DAOs** | 6 (User, Event, Category, TicketType, Order, Media) |
| **Services** | 6 (User, Event, Category, Ticket, Order, Media) |
| **Servlets** | 20 (13 public + 4 admin + 3 organizer) |
| **Filters** | 1 (AuthFilter) |
| **Utilities** | 4 (DBContext, PasswordUtil, ServletUtil, CloudinaryUtil) |
| **JSP Pages** | 35 (17 public + 8 admin + 10 organizer) |
| **CSS/JS** | 3 files (main.css, animations.js, toast.js) |
| **Database Tables** | 15 |
| **JAR Dependencies** | 13 |
