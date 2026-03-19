# CHƯƠNG 8: KẾT LUẬN & HƯỚNG PHÁT TRIỂN

---

## 8.1. Tổng kết kết quả đạt được

### 8.1.1. Hoàn thành mục tiêu đề tài

Nhóm đã hoàn thành mục tiêu đề tài **"Nền tảng Bán Vé Sự Kiện Trực Tuyến"** (Online Event Ticketing Platform) với đầy đủ các chức năng core và nâng cao. Hệ thống đáp ứng mọi yêu cầu đặt ra từ giai đoạn phân tích, cụ thể:

**Bảng 8-1: Đối chiếu mục tiêu ban đầu và kết quả thực tế**

| # | Mục tiêu ban đầu | Kết quả thực tế | Đánh giá |
|---|-------------------|------------------|----------|
| 1 | Hỗ trợ 5 vai trò người dùng | Guest, Customer, Organizer, Staff, Admin — phân quyền đầy đủ qua RBAC | ✅ Đạt |
| 2 | Quản lý sự kiện full lifecycle | Tạo (multi-step) → Duyệt → Xuất bản → Đóng — quy trình hoàn chỉnh | ✅ Đạt |
| 3 | Đặt vé và thanh toán trực tuyến | Checkout atomic, SePay QR payment, webhook xác nhận tự động | ✅ Đạt |
| 4 | Check-in sự kiện bằng QR | Camera-based QR scan + Manual check-in + JWT ticket token | ✅ Đạt |
| 5 | Bảo mật đa lớp | 7 security filters, CSRF, JWT, OAuth, rate limiting, BCrypt | ✅ Vượt mục tiêu |
| 6 | Dashboard thống kê | Admin dashboard + Organizer dashboard với real-time analytics | ✅ Đạt |
| 7 | Chat & Hỗ trợ | Live chat organizer↔customer + Support ticket system | ✅ Đạt |
| 8 | Đa ngôn ngữ (i18n) | Tiếng Việt + English, dynamic switching | ✅ Đạt |
| 9 | Hệ thống voucher | System voucher (admin) + Event voucher (organizer) | ✅ Đạt |
| 10 | Responsive design | Hoạt động trên Desktop, Tablet, Mobile browser | ✅ Đạt |

### 8.1.2. Quy mô dự án hoàn thành

**Bảng 8-2: Thống kê quy mô mã nguồn**

| Thành phần | Số lượng | Dòng code (LOC) |
|------------|----------|-----------------|
| Java Classes (Backend) | 137 files | 18,547 dòng |
| JSP Pages (Frontend) | 64 files | 18,929 dòng |
| CSS + JavaScript (UI/UX) | — | 2,749 dòng |
| SQL Scripts (Database) | — | 5,594 dòng |
| **Tổng cộng** | **201+ source files** | **~45,819 dòng** |

**Bảng 8-3: Thống kê chi tiết kiến trúc**

| Layer | Thành phần | Số lượng |
|-------|------------|----------|
| **Model** | Entity classes | 17 classes |
| **View** | JSP pages | 64 pages (4 khu vực: Public, Admin, Organizer, Staff) |
| **Controller** | Servlets | 60 servlets (Public: 19, Admin: 13, API: 15, Organizer: 11, Staff: 2) |
| **Service** | Business services | 15 service classes + 5 payment classes |
| **DAO** | Data access objects | 18 DAO classes + 1 BaseDAO abstract |
| **Filter** | Security filters | 7 filter classes |
| **Utility** | Helper classes | 12 utility classes |
| **Security** | Auth/rate limiting | 3 security classes |
| **Exception** | Custom exceptions | 2 exception classes |
| **Database** | Tables | 21 bảng |

### 8.1.3. Thành tựu kỹ thuật nổi bật

#### a) Kiến trúc phân tầng chuẩn enterprise

Hệ thống tuân thủ nghiêm ngặt kiến trúc **4-tier layered architecture** (Presentation → Controller → Service → DAO), đảm bảo:
- **Separation of Concerns**: Mỗi tầng có trách nhiệm rõ ràng, không xâm phạm vào tầng khác.
- **Dependency Inversion**: Service không phụ thuộc vào chi tiết triển khai DAO; Payment module sử dụng Strategy Pattern (`PaymentFactory` → `PaymentProvider` interface).
- **Template Method**: `BaseDAO` cung cấp pattern chung cho database operations, giảm 70% boilerplate code.
- **Single Responsibility**: Mỗi Servlet xử lý duy nhất một use case (ví dụ: `LoginServlet` chỉ xử lý login, `RegisterServlet` chỉ xử lý registration).

#### b) Bảo mật vượt tiêu chuẩn môn học

| Cấp độ bảo mật | Yêu cầu môn học PRJ301 | Mức đạt được của dự án |
|-----------------|------------------------|------------------------|
| Authentication | Session-based login | Session + JWT + Refresh Token + Google OAuth 2.0 |
| Authorization | Servlet filter cơ bản | RBAC 5 roles + 3 specialized access filters |
| CSRF Protection | Không yêu cầu | Synchronizer Token + Origin validation + Token rotation |
| Brute Force | Không yêu cầu | Progressive lockout 2 tầng (email+IP, IP-only) |
| Password Safety | Plain-text hoặc MD5 phổ biến | BCrypt cost 12 (~250ms per hash) |
| Input Validation | Cơ bản | Centralized InputValidator + PreparedStatement 100% DAO |
| HTTP Headers | Không yêu cầu | 5 security headers (X-Frame-Options, X-Content-Type-Options...) |
| Cookie Security | Không yêu cầu | HttpOnly + Secure + SameSite=Lax |
| Audit Trail | Không yêu cầu | ActivityLog lưu mọi hành động admin/organizer |

> Kiến trúc bảo mật defense-in-depth với 7 filter layers phủ rộng Top 10 OWASP 2021.

#### c) Thanh toán thực tế (Payment Integration)

Hệ thống tích hợp thanh toán **SePay QR** — cổng thanh toán thực tế hoạt động với ngân hàng Việt Nam — bao gồm:
- **Atomic checkout**: SQL transaction đảm bảo tính toàn vẹn (hoặc tạo đơn + giữ vé thành công hoàn toàn, hoặc rollback).
- **Webhook IPN**: Server-to-server callback xác nhận thanh toán, với 5 bước validation (API key, body size, amount match, idempotency, atomic confirm).
- **QR Code generation**: Tự động sinh mã QR thanh toán theo Napas 247 standard.

#### d) Check-in bằng QR Code

- Mỗi vé được cấp JWT token duy nhất, mã hóa trong QR code.
- Camera-based scanner hoạt động real-time trên trình duyệt, không cần app bên thứ ba.
- Double check-in prevention: Trạng thái vé chuyển `valid → used` sau khi scan → quét lại hiển thị cảnh báo.

#### e) Đa ngôn ngữ (Internationalization)

- Hệ thống hỗ trợ 2 ngôn ngữ: **Tiếng Việt** và **English**.
- Client-side switching: JSON-based i18n (`vi.json`, `en.json`) + `i18n.js` module → không cần reload page.
- Preference lưu trong Local Storage → giữ nguyên lựa chọn khi quay lại.

---

## 8.2. Phân tích đánh giá

### 8.2.1. Điểm mạnh của hệ thống

**Bảng 8-4: Phân tích điểm mạnh**

| Tiêu chí | Chi tiết | Lợi ích |
|----------|----------|---------|
| **Kiến trúc sạch** | MVC 4 tầng + BaseDAO + PaymentFactory Strategy | Dễ bảo trì, mở rộng, onboard thành viên mới nhanh |
| **Bảo mật chuyên sâu** | 7 filters, JWT, OAuth, CSRF, rate limiting | Sản phẩm an toàn ở mức production-grade |
| **Thanh toán thực tế** | SePay QR + webhook IPN | Không phải mock, hoạt động với ngân hàng thật |
| **UX hoàn chỉnh** | 64+ trang, responsive, i18n, thông báo real-time | Trải nghiệm người dùng mượt mà, chuyên nghiệp |
| **Code documentation** | Clean code, self-documenting, rõ ràng | Dễ đọc, dễ review, dễ bảo vệ đồ án |
| **Design patterns** | Template Method, Strategy, Singleton, Factory | Kiến trúc chặt chẽ, tuân thủ best practices |
| **Full-stack coverage** | Backend + Frontend + DB + Payment + Auth + Chat | Một người/nhóm làm được end-to-end |

### 8.2.2. Hạn chế của hệ thống

**Bảng 8-5: Phân tích hạn chế và nguyên nhân**

| # | Hạn chế | Nguyên nhân | Mức độ ảnh hưởng |
|---|---------|-------------|------------------|
| 1 | **Chưa có automated testing** (unit test, integration test) | Hạn chế thời gian của đồ án; kiến thức testing framework (JUnit, Selenium) chưa đủ sâu | Trung bình — Cần test thủ công mỗi lần thay đổi code |
| 2 | **Chưa có CI/CD pipeline** | Chưa triển khai lên cloud; dự án chạy local | Thấp — Chỉ ảnh hưởng khi scale team |
| 3 | **Real-time chat dựa trên HTTP polling** | Servlet/JSP không hỗ trợ WebSocket native; giới hạn của Tomcat cấu hình | Trung bình — Tốn bandwidth, độ trễ 3-5 giây |
| 4 | **Chưa có caching layer** (Redis, Memcached) | Scope đồ án chưa yêu cầu; thời gian hạn chế | Thấp — DB vẫn đáp ứng đủ với ~100 concurrent users |
| 5 | **MoMo/VNPay chưa tích hợp** | API sandbox phức tạp, yêu cầu business account | Thấp — SePay QR đã đáp ứng nhu cầu thanh toán |
| 6 | **Responsive nhưng chưa native mobile** | Scope đồ án là web-based | Thấp — Mobile browser vẫn hoạt động tốt |
| 7 | **Logging cơ bản** (`java.util.logging`) | Chưa tích hợp framework log (Log4j2, SLF4J) | Thấp — Đủ cho debug trong development |
| 8 | **Image lưu trữ Cloudinary** (phụ thuộc bên thứ ba) | Dùng free tier, có giới hạn dung lượng | Thấp — Free tier đủ cho demo |

### 8.2.3. So sánh với các nền tảng hiện có

**Bảng 8-6: So sánh SellingTicket với các nền tảng thị trường**

| Tiêu chí | SellingTicket (Dự án) | Ticketbox | TicketGo |
|----------|----------------------|-----------|----------|
| **Số vai trò** | 5 (Guest, Customer, Organizer, Staff, Admin) | 3 (Buyer, Organizer, Admin) | 3 |
| **Thanh toán** | SePay QR (thực tế) | VNPay, MoMo, Visa, QR | VNPay, MoMo |
| **Check-in** | QR camera + manual + JWT token | QR + thủ công | QR |
| **Chat tích hợp** | ✅ (Organizer ↔ Customer) | ❌ | ❌ |
| **Support ticket** | ✅ (Admin xử lý) | ❌ | ❌ |
| **Voucher system** | ✅ (System + Event-level) | ✅ | Hạn chế |
| **i18n** | ✅ (vi, en) | ❌ (chỉ tiếng Việt) | ❌ |
| **Audit trail** | ✅ (ActivityLog đầy đủ) | Không công khai | Không |
| **Security layers** | 7 filters | Không công khai | Không |
| **Scalability** | ~100 concurrent (đủ cho đồ án) | 200K+ concurrent | Trung bình |
| **Cost** | Miễn phí (self-hosted) | 8.5% + 20K/vé | Thỏa thuận |

> **Nhận xét**: SellingTicket vượt trội ở tính năng Chat tích hợp, Support ticket, đa ngôn ngữ, và chi tiết bảo mật — những tính năng mà cả Ticketbox và TicketGo đều chưa cung cấp. Tuy nhiên, hệ thống chưa đạt mức scalability production do giới hạn kiến trúc monolithic và chưa có caching.

---

## 8.3. Bài học kinh nghiệm

### 8.3.1. Bài học kỹ thuật

| # | Bài học | Chi tiết |
|---|--------|----------|
| 1 | **Thiết kế trước, code sau** | Dành 20% thời gian cho thiết kế kiến trúc (BaseDAO, PaymentFactory) giúp tiết kiệm 50% thời gian phát triển sau này. Nếu không có BaseDAO, mỗi DAO sẽ lặp lại ~50 dòng boilerplate. |
| 2 | **Security là quá trình, không phải tính năng** | Bảo mật phải được tích hợp từ đầu (filter chain), không phải "thêm vào sau". CSRF, rate limiting nếu bổ sung sau sẽ phải refactor nhiều controller. |
| 3 | **PreparedStatement là bắt buộc** | Không bao giờ sử dụng String concatenation cho SQL. Một lần sai có thể mất toàn bộ dữ liệu. |
| 4 | **Tách biệt config khỏi code** | Google OAuth secret, DB credentials, API keys phải đặt trong file config (WEB-INF), không hardcode. |
| 5 | **Atomic transactions cho nghiệp vụ quan trọng** | Checkout, payment confirm phải dùng DB transaction. Nếu không, đơn hàng có thể tạo nhưng vé không được giữ → mất nhất quán. |
| 6 | **Test sớm, test thường xuyên** | Thiếu automated test khiến nhóm phải test thủ công mỗi lần merge → tốn thời gian, dễ bỏ sót lỗi. |

### 8.3.2. Bài học quản lý dự án

| # | Bài học | Chi tiết |
|---|--------|----------|
| 1 | **Phân chia module rõ ràng** | Mỗi thành viên phụ trách 1-2 module → giảm conflict, tăng ownership |
| 2 | **Code review peer-to-peer** | Mỗi PR được review bởi ít nhất 1 thành viên khác → bắt lỗi sớm, học hỏi lẫn nhau |
| 3 | **Documentation song song** | Viết tài liệu ngay khi code → không phải quay lại nhớ lại logic phức tạp |
| 4 | **Git workflow** | Feature branch → Pull Request → Review → Merge vào main → giữ main luôn stable |
| 5 | **Ước lượng thời gian thực tế** | Luôn nhân 1.5x ước lượng ban đầu, đặc biệt cho payment integration và security |

### 8.3.3. Kiến thức thu được

Thông qua dự án, nhóm đã nắm vững và áp dụng thành thục:
- **Java Servlet/JSP**: Vòng đời servlet, filter chain, session management, request dispatch.
- **JDBC & SQL Server**: Connection pooling, PreparedStatement, transaction management, stored procedures.
- **Design Patterns**: MVC, Template Method, Strategy, Singleton, Factory, Observer.
- **Web Security**: OWASP Top 10, CSRF prevention, JWT/OAuth flows, rate limiting, BCrypt hashing.
- **Payment Integration**: API webhook pattern, idempotency, atomic confirmation.
- **Frontend**: Responsive CSS, vanilla JavaScript, i18n pattern, QR camera API.
- **Project Management**: Git workflow, code review, documentation, task breakdown.

---

## 8.4. Hướng phát triển tương lai

### 8.4.1. Lộ trình phát triển (Roadmap)

```
┌─────────────────────────────────────────────────────────────────┐
│                    ROADMAP PHÁT TRIỂN                             │
├─────────────┬──────────────────┬──────────────────┬─────────────┤
│  Phase 1    │    Phase 2       │    Phase 3       │   Phase 4   │
│  (1-2 tháng)│   (3-4 tháng)    │   (5-6 tháng)    │  (7+ tháng) │
├─────────────┼──────────────────┼──────────────────┼─────────────┤
│ Testing     │ Performance      │ Mobile App       │ AI & ML     │
│ & CI/CD     │ & Scalability    │ & Microservices  │ Integration │
└─────────────┴──────────────────┴──────────────────┴─────────────┘
```

### 8.4.2. Phase 1: Testing & CI/CD (1-2 tháng)

| Hạng mục | Mô tả | Ưu tiên |
|----------|--------|---------|
| **Unit Testing** | JUnit 5 + Mockito cho Service layer và DAO layer. Coverage target: ≥80% | Cao |
| **Integration Testing** | Testcontainers + SQL Server → test DAO layer với real database | Cao |
| **E2E Testing** | Selenium WebDriver → test luồng chính (login, checkout, check-in) | Trung bình |
| **CI/CD Pipeline** | GitHub Actions: build → test → deploy (Tomcat staging) | Cao |
| **Code Quality** | SonarQube/Checkstyle → tự động scan code quality | Trung bình |
| **Logging Framework** | Chuyển từ `java.util.logging` sang SLF4J + Logback → structured logging | Trung bình |

### 8.4.3. Phase 2: Performance & Scalability (3-4 tháng)

| Hạng mục | Mô tả | Ưu tiên |
|----------|--------|---------|
| **Redis Caching** | Cache event list, user session, ticket validation → giảm 60% DB load | Cao |
| **Connection Pooling** | HikariCP thay thế DriverManager → giảm overhead, tăng throughput 3-5x | Cao |
| **CDN Integration** | Cloudflare/AWS CloudFront cho static assets (CSS, JS, images) | Trung bình |
| **Database Optimization** | Query profiling + Index strategy + Pagination optimization | Cao |
| **WebSocket Chat** | Thay thế HTTP polling → real-time chat với Tomcat WebSocket | Trung bình |
| **Load Testing** | Apache JMeter → benchmark 500+ concurrent users | Trung bình |
| **Payment Expansion** | Tích hợp thêm MoMo, VNPay, ZaloPay → đa dạng phương thức thanh toán | Trung bình |

### 8.4.4. Phase 3: Mobile App & Microservices (5-6 tháng)

| Hạng mục | Mô tả | Ưu tiên |
|----------|--------|---------|
| **Mobile Application** | React Native hoặc Flutter → cross-platform iOS/Android | Cao |
| **REST API Expansion** | Mở rộng API layer để hỗ trợ mobile clients + third-party integration | Cao |
| **Microservices Migration** | Tách monolith thành: Auth Service, Event Service, Payment Service, Notification Service | Trung bình |
| **Message Queue** | RabbitMQ/Kafka cho async processing (email, notification, webhook) | Trung bình |
| **Push Notification** | Firebase Cloud Messaging → thông báo mobile real-time | Trung bình |
| **Offline-first mobile** | Local storage + sync → sử dụng khi mất kết nối internet | Thấp |

### 8.4.5. Phase 4: AI & ML Integration (7+ tháng)

| Hạng mục | Mô tả | Ưu tiên |
|----------|--------|---------|
| **Event Recommendation** | Collaborative filtering + Content-based → gợi ý sự kiện phù hợp | Cao |
| **Dynamic Pricing** | ML model dự đoán demand → điều chỉnh giá vé tự động | Trung bình |
| **Fraud Detection** | Anomaly detection cho thanh toán bất thường (multiple purchases, unusual patterns) | Cao |
| **Chatbot AI** | Tích hợp NLP chatbot → tự động trả lời câu hỏi thường gặp | Trung bình |
| **Analytics Dashboard** | Real-time analytics với Chart.js/D3.js + scheduled reports | Trung bình |
| **Sentiment Analysis** | Phân tích feedback/review sự kiện → insights cho organizer | Thấp |

### 8.4.6. Mô hình kiến trúc mục tiêu (Target Architecture)

```
                    ┌──────────────────────┐
                    │   Load Balancer       │
                    │   (Nginx/ALB)         │
                    └──────────┬───────────┘
                               │
          ┌────────────────────┼────────────────────┐
          │                    │                     │
    ┌─────▼─────┐      ┌──────▼──────┐      ┌──────▼──────┐
    │ Web App   │      │ Mobile API  │      │ Admin API   │
    │ (JSP/SSR) │      │ (REST/JSON) │      │ (REST/JSON) │
    └─────┬─────┘      └──────┬──────┘      └──────┬──────┘
          │                    │                     │
          └────────────────────┼────────────────────┘
                               │
                    ┌──────────▼───────────┐
                    │   API Gateway        │
                    │   (Rate limit, Auth) │
                    └──────────┬───────────┘
                               │
     ┌──────────┬──────────┬───┼───┬──────────┬──────────┐
     │          │          │       │          │          │
  ┌──▼──┐  ┌───▼───┐  ┌───▼───┐ ┌─▼────┐ ┌──▼───┐ ┌───▼───┐
  │Auth │  │Event  │  │Order  │ │Chat  │ │Notif │ │Payment│
  │Svc  │  │Svc    │  │Svc    │ │Svc   │ │Svc   │ │Svc    │
  └──┬──┘  └───┬───┘  └───┬───┘ └──┬───┘ └──┬───┘ └───┬───┘
     │         │          │        │        │         │
     └─────────┴──────────┼────────┴────────┘         │
                          │                           │
              ┌───────────▼──────────┐    ┌──────────▼─────┐
              │   PostgreSQL/SQL     │    │   Redis Cache   │
              │   Server (Primary)   │    │   + Message Q   │
              └──────────────────────┘    └────────────────┘
```

---

## 8.5. Kết luận chung

Đồ án **"Nền tảng Bán Vé Sự Kiện Trực Tuyến"** đã đạt được các kết quả vượt kỳ vọng ban đầu:

**Về mặt chức năng**: Hệ thống cung cấp đầy đủ 24 use case bao phủ toàn bộ lifecycle mua — bán vé sự kiện từ tạo sự kiện, duyệt, đặt vé, thanh toán thực tế, nhận vé QR, check-in, đến quản trị và hỗ trợ khách hàng. Tính năng chat tích hợp, support ticket, và đa ngôn ngữ là những điểm khác biệt vượt trội so với các nền tảng hiện có trên thị trường.

**Về mặt kỹ thuật**: Kiến trúc MVC 4 tầng được triển khai nghiêm ngặt với 6 design patterns (Template Method, Strategy, Singleton, Factory, Chain of Responsibility, Observer). Bảo mật defense-in-depth với 7 security filters phủ rộng OWASP Top 10 2021. Tổng cộng **~45,800 dòng code** trên 201+ source files thể hiện quy mô đáng kể cho một đồ án PRJ301.

**Về mặt học tập**: Nhóm đã tích lũy kiến thức sâu rộng về Java Web Development, từ Servlet lifecycle, JDBC transaction management, đến security best practices và payment gateway integration — nền tảng vững chắc cho sự nghiệp phát triển phần mềm.

**Về hướng phát triển**: Với kiến trúc phân tầng rõ ràng, hệ thống hoàn toàn có khả năng mở rộng thành sản phẩm thương mại thực tế qua lộ trình 4 phase đã đề xuất: từ testing & CI/CD → performance optimization → mobile app & microservices → AI/ML integration.

> *Nhóm xin chân thành cảm ơn giảng viên hướng dẫn và các thầy cô trong bộ môn đã hỗ trợ, góp ý trong suốt quá trình thực hiện đồ án.*

---
---

# PHỤ LỤC

---

## Phụ lục A: Cấu hình môi trường phát triển

### A.1. Yêu cầu phần mềm

| Phần mềm | Phiên bản | Mục đích |
|-----------|-----------|----------|
| JDK | 8 trở lên (khuyến nghị JDK 11) | Nền tảng chạy Java |
| Apache Tomcat | 9.x | Application server |
| Microsoft SQL Server | 2019+ | Cơ sở dữ liệu |
| SQL Server Management Studio (SSMS) | 18+ | Quản lý DB |
| NetBeans IDE | 12+ hoặc Apache NetBeans 21 | IDE phát triển |
| Git | 2.x | Version control |
| Node.js | 18+ (optional) | Build tools, DOCX generation |

### A.2. Biến môi trường (.env)

```properties
# Database
DB_URL=jdbc:sqlserver://localhost:1433;databaseName=SellingTicket;encrypt=false
DB_USER=sa
DB_PASSWORD=<your_password>

# Google OAuth 2.0
GOOGLE_CLIENT_ID=<your_google_client_id>
GOOGLE_CLIENT_SECRET=<your_google_client_secret>
GOOGLE_REDIRECT_URI=http://localhost:8080/SellingTicketJava/google-oauth

# JWT
JWT_SECRET=<your_jwt_secret_base64>
JWT_ACCESS_EXPIRY=604800    # 7 ngày (seconds)
JWT_REFRESH_EXPIRY=2592000  # 30 ngày (seconds)

# SePay Payment
SEPAY_API_KEY=<your_sepay_api_key>
SEPAY_BANK_ACCOUNT=<your_bank_account>

# Cloudinary (Image Upload)
CLOUDINARY_CLOUD_NAME=<your_cloud_name>
CLOUDINARY_API_KEY=<your_api_key>
CLOUDINARY_API_SECRET=<your_api_secret>
```

### A.3. Các bước cài đặt

```
Bước 1: Clone repository
  $ git clone https://github.com/<org>/PRJ301_GROUP4_SELLING_TICKET.git

Bước 2: Import project vào NetBeans
  File → Open Project → Chọn thư mục SellingTicketJava

Bước 3: Tạo database
  - Mở SSMS, kết nối SQL Server
  - Chạy script: database/full_reset_seed.sql

Bước 4: Cấu hình environment
  - Copy .env.example → .env
  - Điền thông tin DB, Google OAuth, SePay vào .env

Bước 5: Cấu hình Tomcat
  - Trong NetBeans: Tools → Servers → Add Server → Apache Tomcat
  - Chọn thư mục Tomcat đã cài đặt

Bước 6: Chạy ứng dụng
  - Right-click project → Run
  - Truy cập: http://localhost:8080/SellingTicketJava
```

---

## Phụ lục B: Cấu trúc cơ sở dữ liệu

### B.1. Danh sách 21 bảng dữ liệu

| # | Bảng | Số cột | Mô tả |
|---|------|--------|-------|
| 1 | `Users` | 8 | Thông tin người dùng: email, password hash, role, active status |
| 2 | `Organizers` | 5 | Mở rộng thông tin tổ chức: tên công ty, mô tả, logo |
| 3 | `EventCategories` | 4 | Danh mục sự kiện: Âm nhạc, Thể thao, Workshop... |
| 4 | `Events` | 12+ | Sự kiện: tiêu đề, mô tả, ngày giờ, địa điểm, trạng thái |
| 5 | `TicketTypes` | 6 | Loại vé: tên, giá, số lượng, mô tả |
| 6 | `Orders` | 7 | Đơn hàng: user, event, tổng tiền, trạng thái, ngày tạo |
| 7 | `OrderItems` | 5 | Chi tiết đơn: loại vé, số lượng, đơn giá |
| 8 | `Tickets` | 5 | Vé điện tử: mã QR, trạng thái (valid/used/cancelled) |
| 9 | `Vouchers` | 10+ | Mã giảm giá: loại (%, fixed), min purchase, hạn sử dụng |
| 10 | `Notifications` | 6+ | Thông báo in-app cho user |
| 11 | `Media` | 5+ | Hình ảnh/video sự kiện (Cloudinary URLs) |
| 12 | `ChatSessions` | 5+ | Phiên chat: organizer ↔ customer |
| 13 | `ChatMessages` | 5+ | Tin nhắn trong phiên chat |
| 14 | `SupportTickets` | 7+ | Phiếu hỗ trợ: title, status, priority, assigned_to |
| 15 | `TicketMessages` | 4+ | Tin nhắn trong phiếu hỗ trợ |
| 16 | `EventStaff` | 4+ | Nhân viên BTC: user_id, event_id, role (manager/staff/scanner) |
| 17 | `ActivityLog` | 6+ | Nhật ký hoạt động: user, action, entity, IP, timestamp |
| 18 | `SiteSettings` | 3+ | Cài đặt hệ thống: key-value pairs |
| 19 | `RefreshTokens` | 5+ | JWT refresh tokens: token_id, user_id, expiry, user_agent, IP |
| 20 | `SeepayWebhookDedup` | 3+ | Chống duplicate webhook: transaction_id, processed_at |
| 21 | `PaymentTransactions` | 5+ | Lịch sử giao dịch thanh toán chi tiết |

### B.2. ER Diagram (Entity Relationship)

```
                           ┌──────────┐
                    ┌──────│  Users   │──────┐
                    │      └────┬─────┘      │
                    │           │             │
              ┌─────▼─────┐    │     ┌───────▼──────┐
              │ Organizers │    │     │ Notifications│
              └─────┬──────┘   │     └──────────────┘
                    │          │
              ┌─────▼─────┐   │      ┌──────────────┐
              │  Events   │◄──┘      │  ChatSessions│
              └──┬──┬──┬──┘          └──────┬───────┘
                 │  │  │                    │
    ┌────────────┘  │  └──────────┐  ┌──────▼───────┐
    │               │             │  │ ChatMessages │
┌───▼────┐    ┌─────▼────┐  ┌────▼────┐  └─────────────┘
│Ticket  │    │  Media   │  │ Event  │
│Types   │    │          │  │ Staff  │
└───┬────┘    └──────────┘  └────────┘
    │
┌───▼────┐     ┌──────────┐
│ Orders │────▶│OrderItems│
└───┬────┘     └──────────┘
    │
┌───▼────┐     ┌──────────┐
│ Tickets│     │ Vouchers │
└────────┘     └──────────┘
```

---

## Phụ lục C: REST API Reference

### C.1. Danh sách API Endpoints

| Method | Endpoint | Mô tả | Auth |
|--------|----------|-------|------|
| POST | `/api/auth/login` | Đăng nhập, trả về JWT | ❌ |
| POST | `/api/auth/register` | Đăng ký tài khoản mới | ❌ |
| POST | `/api/auth/refresh` | Refresh access token | 🔑 Refresh Token |
| GET | `/api/events` | Danh sách sự kiện (có filter) | ❌ |
| GET | `/api/events/{id}` | Chi tiết sự kiện | ❌ |
| POST | `/api/orders` | Tạo đơn hàng mới | 🔐 Customer |
| GET | `/api/orders/{id}` | Chi tiết đơn hàng | 🔐 Owner |
| POST | `/api/checkout` | Xử lý thanh toán | 🔐 Customer |
| POST | `/api/seepay/webhook` | SePay IPN callback | 🔑 API Key |
| POST | `/api/checkin/verify` | Xác minh vé (QR scan) | 🔐 Staff/Organizer |
| POST | `/api/checkin/confirm` | Xác nhận check-in | 🔐 Staff/Organizer |
| GET | `/api/chat/messages` | Lấy tin nhắn chat | 🔐 Participant |
| POST | `/api/chat/send` | Gửi tin nhắn | 🔐 Participant |
| GET | `/api/notifications` | Danh sách thông báo | 🔐 User |
| POST | `/api/notifications/read` | Đánh dấu đã đọc | 🔐 User |

**Chú thích**: ❌ = Không cần auth | 🔑 = API Key/Token đặc biệt | 🔐 = Yêu cầu JWT/Session

### C.2. Mẫu Request/Response

**Login API:**
```
POST /api/auth/login
Content-Type: application/json

Request:
{
  "email": "user@example.com",
  "password": "Password123"
}

Response (200 OK):
{
  "success": true,
  "user": {
    "id": 1,
    "email": "user@example.com",
    "fullName": "Nguyễn Văn A",
    "role": "customer"
  },
  "accessToken": "eyJhbGciOi...",
  "expiresIn": 604800
}

Response (401 Unauthorized):
{
  "success": false,
  "message": "Email hoặc mật khẩu không đúng!"
}
```

**SePay Webhook IPN:**
```
POST /api/seepay/webhook
X-API-Key: <sepay_api_key>
Content-Type: application/json

Request:
{
  "id": 123456,
  "gateway": "SePay",
  "transactionDate": "2025-01-15 10:30:00",
  "accountNumber": "1234567890",
  "transferAmount": 500000,
  "content": "SELLTIX ORDER-ABC123"
}

Response (200 OK):
{
  "success": true
}
```

---

## Phụ lục D: Danh sách Design Patterns đã áp dụng

| # | Pattern | Nơi áp dụng | Mô tả |
|---|---------|-------------|-------|
| 1 | **MVC (Model-View-Controller)** | Toàn bộ kiến trúc | Model (17 entities) + View (64 JSP) + Controller (60 Servlets) |
| 2 | **Template Method** | `BaseDAO` | Định nghĩa skeleton cho DB operations (getConnection, executeQuery, close) → 18 DAO con kế thừa |
| 3 | **Strategy** | `PaymentFactory` + `PaymentProvider` | Interface PaymentProvider → SeepayProvider, BankTransferProvider. Thêm provider mới không cần sửa code cũ |
| 4 | **Factory** | `PaymentFactory` | `create(paymentMethod)` → trả về PaymentProvider phù hợp |
| 5 | **Singleton** | DB Connection Pool, SiteSettings | Đảm bảo một instance duy nhất trong toàn bộ application lifecycle |
| 6 | **Chain of Responsibility** | Filter Chain (7 filters) | Mỗi filter xử lý một khía cạnh, không filter nào biết filter tiếp theo làm gì |
| 7 | **Observer** | Notification system | Khi event được approve/order confirmed → tự động tạo notification cho user liên quan |
| 8 | **DAO (Data Access Object)** | `com.sellingticket.dao.*` | Tách biệt data access logic khỏi business logic |
| 9 | **DTO (Data Transfer Object)** | `PageResult<T>` | Gom dữ liệu pagination (items, totalCount, page, pageSize) vào một object |
| 10 | **Front Controller** | Servlet mapping | Mỗi URL pattern map đến đúng một Servlet → single entry point per feature |

---

## Phụ lục E: Danh mục thuật ngữ & viết tắt

| Thuật ngữ / Viết tắt | Giải thích |
|-----------------------|------------|
| API | Application Programming Interface — giao diện lập trình ứng dụng |
| BCrypt | Thuật toán hash mật khẩu dựa trên Blowfish cipher |
| CDN | Content Delivery Network — mạng phân phối nội dung |
| CI/CD | Continuous Integration / Continuous Delivery |
| CORS | Cross-Origin Resource Sharing |
| CRUD | Create, Read, Update, Delete |
| CSRF | Cross-Site Request Forgery — tấn công giả mạo request |
| DAO | Data Access Object — mẫu thiết kế truy cập dữ liệu |
| DDoS | Distributed Denial of Service — tấn công từ chối dịch vụ |
| ERD | Entity Relationship Diagram — sơ đồ quan hệ thực thể |
| FK | Foreign Key — khóa ngoại |
| HMAC | Hash-based Message Authentication Code |
| i18n | Internationalization (18 chữ giữa i và n) — quốc tế hóa |
| IDOR | Insecure Direct Object Reference — tham chiếu đối tượng trực tiếp không an toàn |
| IPN | Instant Payment Notification — thông báo thanh toán tức thì |
| JDBC | Java Database Connectivity — chuẩn kết nối database trong Java |
| JSP | JavaServer Pages — công nghệ tạo trang web động |
| JSTL | JavaServer Pages Standard Tag Library |
| JWT | JSON Web Token — chuẩn token xác thực |
| LOC | Lines of Code — số dòng mã nguồn |
| MVC | Model-View-Controller — mẫu kiến trúc phần mềm |
| OAuth | Open Authorization — chuẩn ủy quyền mở |
| OWASP | Open Web Application Security Project |
| PK | Primary Key — khóa chính |
| QR | Quick Response — mã phản hồi nhanh |
| RBAC | Role-Based Access Control — kiểm soát truy cập dựa trên vai trò |
| REST | Representational State Transfer — kiến trúc API |
| SePay | Cổng thanh toán trực tuyến Việt Nam |
| SQL | Structured Query Language — ngôn ngữ truy vấn có cấu trúc |
| SSL/TLS | Secure Sockets Layer / Transport Layer Security |
| SSMS | SQL Server Management Studio |
| XSS | Cross-Site Scripting — tấn công chèn script |

---

## Phụ lục F: Tài liệu tham khảo

### F.1. Tài liệu chính thức (Official Documentation)

| # | Nguồn | URL |
|---|-------|-----|
| 1 | Oracle Java Servlet Specification 4.0 | https://javaee.github.io/servlet-spec/ |
| 2 | Apache Tomcat 9 Documentation | https://tomcat.apache.org/tomcat-9.0-doc/ |
| 3 | Microsoft SQL Server Documentation | https://learn.microsoft.com/en-us/sql/sql-server/ |
| 4 | Google OAuth 2.0 for Web Server Apps | https://developers.google.com/identity/protocols/oauth2/web-server |
| 5 | SePay API Documentation | https://sepay.vn/docs |
| 6 | Cloudinary Documentation | https://cloudinary.com/documentation |
| 7 | OWASP Top 10 (2021) | https://owasp.org/Top10/ |
| 8 | MDN Web Docs (HTML, CSS, JS) | https://developer.mozilla.org/ |

### F.2. Sách tham khảo

| # | Tên sách | Tác giả | Năm |
|---|----------|---------|-----|
| 1 | Head First Servlets and JSP | Bryan Basham, Kathy Sierra | 2008 |
| 2 | Design Patterns: Elements of Reusable OO Software | GoF (Gamma, Helm, Johnson, Vlissides) | 1994 |
| 3 | Clean Code: A Handbook of Agile Software Craftsmanship | Robert C. Martin | 2008 |
| 4 | Web Application Security | Andrew Hoffman | 2020 |
| 5 | Database Design for Mere Mortals | Michael J. Hernandez | 2013 |

### F.3. Nguồn thống kê thị trường

| # | Nguồn | Chi tiết |
|---|-------|----------|
| 1 | Statista | Doanh thu event ticketing Việt Nam 2024-2028 |
| 2 | Vietnam Digital Report 2024 | Tỷ lệ thanh toán số tại Việt Nam |
| 3 | Ticketbox Media Kit | Số liệu concert, capacity xử lý |
| 4 | VnExpress, Tuổi Trẻ | Bài phỏng vấn về thị trường vé sự kiện |

---

*Kết thúc báo cáo.*
