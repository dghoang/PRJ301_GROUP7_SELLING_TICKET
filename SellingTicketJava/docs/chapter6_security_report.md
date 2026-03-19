# CHƯƠNG 6: BẢO MẬT & AN TOÀN

> **Tổng quan:** Hệ thống SellingTicket triển khai kiến trúc bảo mật **7 lớp (defense-in-depth)**, bao phủ toàn bộ vòng đời request từ HTTP headers → CSRF → Authentication → Authorization → Input Validation → Audit Trail. Mỗi lớp bảo mật hoạt động độc lập, đảm bảo nếu một lớp bị bypass thì các lớp tiếp theo vẫn bảo vệ hệ thống.

---

## 6.1. Kiến trúc Filter Chain (Chuỗi bộ lọc bảo mật)

### 6.1.1. Tổng quan Filter Chain

Mỗi HTTP request đi qua một chuỗi bộ lọc (filter chain) được cấu hình trong [web.xml](file:///d:/GITHUB/PRJ301_GROUP4_SELLING_TICKET/SellingTicketJava/src/webapp/WEB-INF/web.xml), xử lý tuần tự từ trên xuống dưới:

```
┌─────────────────────────────────────────────────────────────────┐
│                    HTTP REQUEST ĐẾN                             │
└──────────────────────────┬──────────────────────────────────────┘
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│ 1. CacheFilter           │ Cache-Control cho static assets      │
│    (*.css, *.js, *.png)  │ (1 năm cho CSS/JS/images)           │
├──────────────────────────┼──────────────────────────────────────┤
│ 2. SecurityHeadersFilter │ HTTP security headers cho mọi URL   │
│    (url-pattern: /*)     │ X-Frame-Options, CSP, HSTS,...       │
├──────────────────────────┼──────────────────────────────────────┤
│ 3. CsrfFilter            │ Xác thực CSRF token cho POST        │
│    (/login, /checkout,   │ requests (login, admin, organizer,   │
│     /admin/*, /api/*)    │ API, checkout, profile)              │
├──────────────────────────┼──────────────────────────────────────┤
│ 4. AuthFilter            │ Xác thực người dùng                 │
│    (/admin/*, /organizer/│ Session → JWT Cookie → Bearer Token  │
│     /checkout, /profile) │ + Kiểm tra role + active status     │
├──────────────────────────┼──────────────────────────────────────┤
│ 5. OrganizerAccessFilter │ Phân quyền chi tiết cho Organizer   │
│    (/organizer/*)        │ Kiểm tra sở hữu event + quyền edit │
├──────────────────────────┼──────────────────────────────────────┤
│ 6. StaffAccessFilter     │ Phân quyền cho nhân viên BTC        │
│    (/staff/*)            │ Kiểm tra EventStaff table           │
├──────────────────────────┼──────────────────────────────────────┤
│ 7. ProtectedJspAccessFilter │ Chặn truy cập trực tiếp JSP     │
│    (*.jsp)               │ Chỉ cho phép forward/include        │
└──────────────────────────┴──────────────────────────────────────┘
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│                    CONTROLLER (Servlet)                          │
└─────────────────────────────────────────────────────────────────┘
```

### 6.1.2. Chi tiết cấu hình Filter trong [web.xml](file:///d:/GITHUB/PRJ301_GROUP4_SELLING_TICKET/SellingTicketJava/src/webapp/WEB-INF/web.xml)

| # | Filter | URL Pattern | Chức năng |
|---|--------|-------------|-----------|
| 1 | `CacheFilter` | `*.css`, `*.js`, `*.png`, `*.jpg`, `*.svg`, `*.webp`, `*.ico` | Đặt Cache-Control header cho static assets |
| 2 | [SecurityHeadersFilter](file:///d:/GITHUB/PRJ301_GROUP4_SELLING_TICKET/SellingTicketJava/src/java/com/sellingticket/filter/SecurityHeadersFilter.java#26-106) | `/*` | Bảo vệ mọi response bằng security headers |
| 3 | [CsrfFilter](file:///d:/GITHUB/PRJ301_GROUP4_SELLING_TICKET/SellingTicketJava/src/java/com/sellingticket/filter/CsrfFilter.java#24-220) | `/login`, `/register`, `/checkout`, `/profile`, `/change-password`, `/support/*`, `/media/upload`, `/organizer/*`, `/admin/*`, `/api/*` | CSRF protection cho mọi form submission và API call |
| 4 | [AuthFilter](file:///d:/GITHUB/PRJ301_GROUP4_SELLING_TICKET/SellingTicketJava/src/java/com/sellingticket/filter/AuthFilter.java#34-292) | `/organizer/*`, `/admin/*`, `/checkout`, `/tickets`, `/my-tickets`, `/profile`, `/change-password`, `/support/*`, `/api/admin/*`, `/api/organizer/*`, `/api/my-tickets`, `/api/my-orders`, `/api/chat/*`, `/api/payment/*`, `/api/voucher/*`, `/api/upload`, `/media/upload` | Authentication & role-based access |
| 5 | [OrganizerAccessFilter](file:///d:/GITHUB/PRJ301_GROUP4_SELLING_TICKET/SellingTicketJava/src/java/com/sellingticket/filter/OrganizerAccessFilter.java#23-122) | `/organizer/*` | Organizer ownership + permission |
| 6 | [StaffAccessFilter](file:///d:/GITHUB/PRJ301_GROUP4_SELLING_TICKET/SellingTicketJava/src/java/com/sellingticket/filter/StaffAccessFilter.java#23-67) | `/staff/*` | Staff assignment verification |
| 7 | [ProtectedJspAccessFilter](file:///d:/GITHUB/PRJ301_GROUP4_SELLING_TICKET/SellingTicketJava/src/java/com/sellingticket/filter/ProtectedJspAccessFilter.java#21-83) | `*.jsp` (trong code, registered programmatically) | Chặn direct JSP access |

---

## 6.2. Xác thực (Authentication)

### 6.2.1. Kiến trúc xác thực đa lớp

Hệ thống sử dụng **3 phương thức xác thực song song**, thử lần lượt cho đến khi thành công:

```
┌──────────────────────────────────────────────────────────────┐
│                    AuthFilter.doFilter()                       │
│                                                               │
│  ┌─ Bước 1: Kiểm tra HttpSession ─────────────────────────┐ │
│  │  session.getAttribute("user") != null?                   │ │
│  │  → Có: Kiểm tra user.isActive() → Cho phép              │ │
│  │  → Không: Sang bước 2                                    │ │
│  └──────────────────────────────────────────────────────────┘ │
│                           ▼                                   │
│  ┌─ Bước 2: Kiểm tra Refresh Cookie ──────────────────────┐ │
│  │  Cookie "st_refresh" tồn tại?                            │ │
│  │  → Có: Tra cứu DB → Tái tạo session → Cho phép          │ │
│  │  → Không: Sang bước 3                                    │ │
│  └──────────────────────────────────────────────────────────┘ │
│                           ▼                                   │
│  ┌─ Bước 3: Kiểm tra Bearer Token ────────────────────────┐ │
│  │  Header "Authorization: Bearer <token>" tồn tại?         │ │
│  │  → Có: Verify JWT → Tải user từ DB → Cho phép            │ │
│  │  → Không: Chuyển hướng /login (web) hoặc 401 (API)      │ │
│  └──────────────────────────────────────────────────────────┘ │
└──────────────────────────────────────────────────────────────┘
```

**File:** [AuthFilter.java](file:///d:/GITHUB/PRJ301_GROUP4_SELLING_TICKET/SellingTicketJava/src/java/com/sellingticket/filter/AuthFilter.java) — 292 dòng

**Điểm nổi bật:**
- **Phân biệt Web vs API:** Request đến `/api/*` nhận response JSON `401 Unauthorized`; các request khác được redirect về `/login` với `returnUrl` để quay lại trang cũ sau khi đăng nhập
- **Kiểm tra [isActive()](file:///d:/GITHUB/PRJ301_GROUP4_SELLING_TICKET/SellingTicketJava/src/java/com/sellingticket/model/TicketType.java#48-49):** Tài khoản bị vô hiệu hóa sẽ bị từ chối ngay lập tức, session bị hủy, cookies bị xóa
- **Role enforcement:** Admin pages chỉ cho phép role `admin`, organizer pages chỉ cho phép `organizer` hoặc `admin`

### 6.2.2. Đăng nhập truyền thống (Email/Password)

**File:** [LoginServlet.java](file:///d:/GITHUB/PRJ301_GROUP4_SELLING_TICKET/SellingTicketJava/src/java/com/sellingticket/controller/LoginServlet.java) — 249 dòng

Luồng đăng nhập được thiết kế với nhiều lớp bảo vệ:

```
┌────────────────┐    ┌──────────────┐    ┌────────────────┐    ┌──────────────┐
│  Nhập email +  │    │ Input        │    │ Rate Limiting  │    │ Authenticate │
│  password      │───▶│ Validation   │───▶│ (IP + Email)   │───▶│ (BCrypt)     │
└────────────────┘    └──────────────┘    └────────────────┘    └──────┬───────┘
                                                                       │
                      ┌──────────────┐    ┌────────────────┐    ┌──────▼───────┐
                      │ Issue JWT +  │◀───│ Session        │◀───│ Timing       │
                      │ Set Cookies  │    │ Fixation Prot. │    │ Attack Prot. │
                      └──────────────┘    └────────────────┘    └──────────────┘
```

**Các biện pháp bảo mật trong [LoginServlet](file:///d:/GITHUB/PRJ301_GROUP4_SELLING_TICKET/SellingTicketJava/src/java/com/sellingticket/controller/LoginServlet.java#18-248):**

| Biện pháp | Mô tả | Code Reference |
|-----------|--------|----------------|
| **Input length limit** | Email ≤ 255 chars, Password ≤ 128 chars (chống DoS via oversized payload) | Dòng 56-63 |
| **Email format check** | Regex validation trước khi truy vấn DB | Dòng 68 |
| **Rate limiting** | IP block + Email+IP block (xem mục 6.5) | Dòng 75-90 |
| **Constant-time delay** | [enforceMinimumDelay(200ms)](file:///d:/GITHUB/PRJ301_GROUP4_SELLING_TICKET/SellingTicketJava/src/java/com/sellingticket/controller/LoginServlet.java#220-231) — đảm bảo response time đồng nhất cho login thành công và thất bại, chống timing attack | Dòng 93-98 |
| **Generic error message** | Không tiết lộ email có tồn tại hay không: "Email hoặc mật khẩu không đúng!" | Dòng 109 |
| **Session fixation** | `oldSession.invalidate()` + `request.getSession(true)` — tạo session mới hoàn toàn | Dòng 140-144 |
| **CSRF token reset** | Sinh CSRF token mới ngay sau đăng nhập | Dòng 147-149 |
| **Open redirect prevention** | [sanitizeRedirect()](file:///d:/GITHUB/PRJ301_GROUP4_SELLING_TICKET/SellingTicketJava/src/java/com/sellingticket/controller/LoginServlet.java#189-212) block `//`, `://`, `javascript:`, `%0d`, `%0a` | Dòng 189-211 |
| **No-cache headers** | Ngăn browser cache trang login chứa credentials đã nhập | Dòng 214-218 |

### 6.2.3. Google OAuth 2.0

**File:** [GoogleOAuthServlet.java](file:///d:/GITHUB/PRJ301_GROUP4_SELLING_TICKET/SellingTicketJava/src/java/com/sellingticket/controller/GoogleOAuthServlet.java) — 308 dòng

**Luồng OAuth:**

```
┌──────────┐      ┌───────────┐      ┌──────────┐      ┌──────────┐
│ User     │      │ App       │      │ Google   │      │ Database │
│ Browser  │      │ Server    │      │ OAuth    │      │          │
└────┬─────┘      └─────┬─────┘      └────┬─────┘      └────┬─────┘
     │ GET /auth/google  │                 │                  │
     │──────────────────▶│                 │                  │
     │                   │ Generate state  │                  │
     │                   │ token (UUID)    │                  │
     │ 302 Redirect      │                 │                  │
     │◀──────────────────│                 │                  │
     │                   │                 │                  │
     │ Consent Screen    │                 │                  │
     │──────────────────────────────────▶│                  │
     │ ?code=xxx&state=yyy               │                  │
     │◀──────────────────────────────────│                  │
     │                   │                 │                  │
     │ GET /auth/google/ │                 │                  │
     │ callback?code=xxx │                 │                  │
     │──────────────────▶│                 │                  │
     │                   │ Verify state    │                  │
     │                   │ (CSRF check)    │                  │
     │                   │ Exchange code   │                  │
     │                   │────────────────▶│                  │
     │                   │ access_token    │                  │
     │                   │◀────────────────│                  │
     │                   │ GET /userinfo   │                  │
     │                   │────────────────▶│                  │
     │                   │ email, name     │                  │
     │                   │◀────────────────│                  │
     │                   │                 │                  │
     │                   │ Lookup/Create user                │
     │                   │─────────────────────────────────▶│
     │                   │ User object                       │
     │                   │◀─────────────────────────────────│
     │                   │                 │                  │
     │ Set-Cookie + 302  │                 │                  │
     │◀──────────────────│                 │                  │
```

**Các biện pháp bảo mật trong OAuth:**

| Biện pháp | Mô tả |
|-----------|--------|
| **State token** | UUID ngẫu nhiên lưu trong session, so khớp khi callback → chống CSRF |
| **State cleanup** | `removeAttribute("oauth_state")` ngay sau verify → chống replay |
| **Deactivated check** | Tài khoản bị vô hiệu hóa không được phép đăng nhập qua Google |
| **Auto-registration** | User mới được tạo tự động với `registerOAuth()` (không cần password) |
| **Session fixation** | Giống LoginServlet: invalidate session cũ, tạo mới |
| **Credential isolation** | `client_secret` lưu trong `/WEB-INF/google-oauth.properties` (không thể truy cập từ browser) |

### 6.2.4. JWT Token (JSON Web Token)

**File:** [JwtUtil.java](file:///d:/GITHUB/PRJ301_GROUP4_SELLING_TICKET/SellingTicketJava/src/java/com/sellingticket/util/JwtUtil.java) — 319 dòng

Hệ thống sử dụng JWT tự triển khai (pure Java, không phụ thuộc thư viện ngoài) với **HMAC-SHA256**:

**Các loại token:**

| Token Type | Payload Claims | Thời hạn | Mục đích |
|------------|---------------|----------|----------|
| **Access Token** | `sub` (userId), `email`, `role`, `type:"access"` | 7 ngày | Xác thực API Bearer |
| **Refresh Token** | `sub` (userId), `jti` (unique ID), `type:"refresh"` | 30 ngày | Tái tạo access token |
| **Ticket Token** | `sub` (ticketCode), `tid` (ticketId), `eid` (eventId) | 1 năm | QR code vé điện tử |

**Các biện pháp bảo mật trong JWT:**

| Biện pháp | Code | Mục đích |
|-----------|------|----------|
| **Algorithm header validation** | `isExpectedAlgorithm()` — reject token nếu header không chứa `"HS256"` | Chống **algorithm confusion attack** (alg:none, alg:HS384) |
| **Constant-time comparison** | `MessageDigest.isEqual(aBytes, bBytes)` | Chống **timing attack** trên signature |
| **Token type check** | `"access".equals(claims.get("type"))` | Ngăn sử dụng refresh token như access token |
| **Expiration check** | `System.currentTimeMillis() / 1000 > exp` | Token hết hạn bị từ chối |
| **JSON escape** | `escapeJson()` xử lý `\` và `"` | Chống injection vào JWT payload |

### 6.2.5. Token Lifecycle Service

**File:** [AuthTokenService.java](file:///d:/GITHUB/PRJ301_GROUP4_SELLING_TICKET/SellingTicketJava/src/java/com/sellingticket/service/AuthTokenService.java) — 235 dòng

```
┌──────────────────────────────────────────────────────────────────┐
│                    TOKEN LIFECYCLE                                │
│                                                                   │
│  ┌──────┐     ┌──────────┐     ┌──────────┐     ┌──────────┐   │
│  │Login │────▶│Issue     │────▶│Validate  │────▶│Refresh   │   │
│  │      │     │Tokens    │     │Access    │     │(if exp.) │   │
│  └──────┘     └──────────┘     └──────────┘     └──────────┘   │
│                                                       │          │
│  ┌──────┐     ┌──────────┐                           │          │
│  │Logout│────▶│Revoke    │◀──────────────────────────┘          │
│  │      │     │All Tokens│                                      │
│  └──────┘     └──────────┘                                      │
└──────────────────────────────────────────────────────────────────┘
```

**Đặc điểm quan trọng:**

- **Refresh token lưu DB:** Token ID (`jti`) + `user_id`, `user_agent`, `ip_address`, `expires_at` → cho phép revoke từ xa
- **User mismatch check:** Khi refresh, kiểm tra `userId` trong cookie khớp với `userId` trong DB → chống token theft
- **Full user reload:** Khi validate access token, luôn tải lại user từ DB bằng `userDAO.getUserById()` → đảm bảo role/active status mới nhất
- **Remember me:** Persistent cookies (7 ngày access, 30 ngày refresh) vs Session cookies (xóa khi đóng browser)
- **Revoke all:** `revokeAllUserTokens()` → hủy tất cả token khi đổi password hoặc security event

---

## 6.3. Chống tấn công CSRF (Cross-Site Request Forgery)

**File:** [CsrfFilter.java](file:///d:/GITHUB/PRJ301_GROUP4_SELLING_TICKET/SellingTicketJava/src/java/com/sellingticket/filter/CsrfFilter.java) — 220 dòng

### 6.3.1. Cơ chế CSRF Token

Hệ thống sử dụng **Synchronizer Token Pattern** (OWASP recommended) kết hợp **Origin/Referer validation**:

```
┌──────────────────────────────────────────────────────────────────┐
│                   CSRF VALIDATION FLOW                            │
│                                                                   │
│  Request đến ──▶ GET request? ──YES──▶ PASS (read-only safe)    │
│                       │                                           │
│                      NO (POST/PUT/DELETE)                         │
│                       ▼                                           │
│              Bearer Token? ──YES──▶ PASS (API authed)            │
│                       │                                           │
│                      NO                                           │
│                       ▼                                           │
│              Origin/Referer ──MISMATCH──▶ BLOCK (403)            │
│              same-origin?                                         │
│                       │                                           │
│                      YES                                          │
│                       ▼                                           │
│              CSRF Token ──MISMATCH──▶ BLOCK (403)                │
│              matches?                                             │
│                       │                                           │
│                      YES                                          │
│                       ▼                                           │
│              Rotate token ──▶ PASS                               │
│              (old → prev)                                         │
└──────────────────────────────────────────────────────────────────┘
```

### 6.3.2. Token Rotation (Quay vòng token)

Hệ thống triển khai **per-request token rotation** với dung sai cho double-submit:

```java
// Khi CSRF check thành công:
String newToken = UUID.randomUUID().toString();
session.setAttribute("csrf_token_prev", currentToken);  // Giữ token cũ
session.setAttribute("csrf_token", newToken);            // Sinh token mới
```

**Tại sao giữ `csrf_token_prev`?** → Khi user mở nhiều tab, tab cũ vẫn có token hợp lệ (token trước đó). Validation chấp nhận cả `csrf_token` **và** `csrf_token_prev`.

### 6.3.3. Origin/Referer Validation

Trước khi kiểm tra CSRF token, filter kiểm tra header `Origin` hoặc `Referer`:

```java
String origin = request.getHeader("Origin");
if (origin == null) origin = request.getHeader("Referer");

// So sánh: scheme + host + port phải khớp với server
if (!isSameOrigin(origin, request)) {
    block(response, "Origin mismatch");
    return;
}
```

**Lý do cần cả hai lớp:**
- Origin/Referer validation: Chặn request từ domain khác (protection layer 1)
- CSRF token: Chặn request giả mạo ngay cả khi Origin bị spoof (protection layer 2)

### 6.3.4. Exemptions (Ngoại lệ)

| Exemption | Lý do |
|-----------|-------|
| GET/HEAD/OPTIONS | Read-only, không thay đổi state |
| Bearer Token requests | API clients đã xác thực bằng JWT |
| Webhook endpoints (`/api/seepay/webhook`) | Được xác thực bằng API key riêng |
| Static assets (`.css`, `.js`, `.png`) | Không cần CSRF protection |

### 6.3.5. Tích hợp với JSP Forms

Trong các JSP form, CSRF token được nhúng tự động:

```html
<form method="POST" action="/checkout">
    <input type="hidden" name="csrf_token" value="${csrf_token}">
    <!-- Hoặc qua JavaScript: -->
    <meta name="csrf-token" content="${csrf_token}">
    ...
</form>
```

---

## 6.4. HTTP Security Headers

**File:** [SecurityHeadersFilter.java](file:///d:/GITHUB/PRJ301_GROUP4_SELLING_TICKET/SellingTicketJava/src/java/com/sellingticket/filter/SecurityHeadersFilter.java) — 106 dòng

Mọi HTTP response đều được thêm các security headers sau:

| Header | Giá trị | Chống tấn công |
|--------|---------|----------------|
| `X-Content-Type-Options` | `nosniff` | Ngăn browser đoán MIME type → chống MIME sniffing |
| `X-Frame-Options` | `SAMEORIGIN` | Chỉ cho phép iframe cùng origin → chống **Clickjacking** |
| `X-XSS-Protection` | `1; mode=block` | Kích hoạt XSS filter của browser (legacy, vẫn hữu ích cho IE/old Edge) |
| `Referrer-Policy` | `strict-origin-when-cross-origin` | Chỉ gửi origin (không path) khi cross-origin → Bảo vệ URL nhạy cảm |
| `Permissions-Policy` | `camera=(), microphone=(), geolocation=()` | Tắt API camera/mic/GPS → Giảm attack surface |

**Ví dụ set header trong code:**

```java
@Override
public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
        throws IOException, ServletException {
    HttpServletResponse response = (HttpServletResponse) res;
    
    response.setHeader("X-Content-Type-Options", "nosniff");
    response.setHeader("X-Frame-Options", "SAMEORIGIN");
    response.setHeader("X-XSS-Protection", "1; mode=block");
    response.setHeader("Referrer-Policy", "strict-origin-when-cross-origin");
    response.setHeader("Permissions-Policy", "camera=(), microphone=(), geolocation=()");
    
    chain.doFilter(req, res);
}
```

---

## 6.5. Chống Brute Force (Rate Limiting)

**File:** [LoginAttemptTracker.java](file:///d:/GITHUB/PRJ301_GROUP4_SELLING_TICKET/SellingTicketJava/src/java/com/sellingticket/security/LoginAttemptTracker.java) — 171 dòng

### 6.5.1. Progressive Lockout (Khóa lũy tiến)

Hệ thống sử dụng **2 tầng rate limiting** — theo cặp `(email + IP)` và theo `IP` riêng:

**Tầng 1: Email + IP Lockout**

| Số lần sai | Thời gian khóa | Mục đích |
|------------|----------------|----------|
| 5 lần | 1 phút | Cảnh báo nhẹ |
| 10 lần | 5 phút | Nghi ngờ brute-force |
| 15 lần | 15 phút | Xác nhận tấn công |
| 20+ lần | 60 phút | Khóa kéo dài |

**Tầng 2: IP-Only Lockout** (chống distributed credential stuffing)

| Ngưỡng | Thời gian khóa |
|--------|----------------|
| 30 lần (mọi email) từ cùng IP | 15 phút |

### 6.5.2. Cơ chế hoạt động

```java
// ConcurrentHashMap — thread-safe cho multi-threaded Tomcat
private final ConcurrentHashMap<String, AttemptRecord> attempts;     // email+IP
private final ConcurrentHashMap<String, AttemptRecord> ipAttempts;   // IP-only

// Key format: "email@example.com|192.168.1.100"
private String buildKey(String email, String ip) {
    return email.toLowerCase().trim() + "|" + ip;
}
```

**Cleanup tự động:** Scheduled thread chạy mỗi 10 phút, xóa entries cũ hơn 2 giờ → tránh memory leak.

**Lưu ý quan trọng:** Khi đăng nhập thành công, chỉ reset `email+IP attempts`, **KHÔNG** reset `ipAttempts`. Điều này ngăn kẻ tấn công bypass IP block bằng cách xen kẽ login thành công trên tài khoản khác.

---

## 6.6. Mã hóa mật khẩu (Password Hashing)

**File:** [PasswordUtil.java](file:///d:/GITHUB/PRJ301_GROUP4_SELLING_TICKET/SellingTicketJava/src/java/com/sellingticket/util/PasswordUtil.java)

Hệ thống sử dụng **BCrypt** với cost factor **12** (4096 iterations):

```java
public final class PasswordUtil {
    private static final int BCRYPT_COST = 12;  // ~250ms per hash

    public static String hash(String plainPassword) {
        return BCrypt.hashpw(plainPassword, BCrypt.gensalt(BCRYPT_COST));
    }

    public static boolean verify(String plainPassword, String hashedPassword) {
        return BCrypt.checkpw(plainPassword, hashedPassword);
    }
}
```

**Tại sao chọn BCrypt cost 12?**
- **Cost 10** (mặc định): ~65ms → quá nhanh, brute-force dễ dàng
- **Cost 12**: ~250ms → cân bằng giữa UX (chấp nhận được cho login) và security
- **Cost 14**: ~1s → quá chậm cho trải nghiệm người dùng

**Đặc tính BCrypt:**
- **Salt tự động:** Mỗi hash có salt riêng nhúng trong output → 2 user cùng password sẽ có hash khác nhau
- **Adaptive:** Có thể tăng cost factor khi phần cứng mạnh hơn mà không cần đổi thuật toán
- **Timing-safe:** `BCrypt.checkpw()` sử dụng constant-time comparison

---

## 6.7. Xác thực đầu vào (Input Validation)

**File:** [InputValidator.java](file:///d:/GITHUB/PRJ301_GROUP4_SELLING_TICKET/SellingTicketJava/src/java/com/sellingticket/util/InputValidator.java) — 185 dòng

Hệ thống triển khai **centralized input validation** — một lớp utility duy nhất cho toàn bộ ứng dụng:

### 6.7.1. Các phương thức validation

| Phương thức | Quy tắc | Ví dụ |
|-------------|---------|-------|
| `isValidEmail()` | Regex: `^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$` + max 255 chars | `user@example.com` ✅ |
| `isValidPassword()` | 8-64 chars, ≥1 uppercase, ≥1 lowercase, ≥1 digit | `Password1` ✅ |
| `isValidPhone()` | Regex: `^(0|\+84)?[0-9]{8,10}$` | `0912345678` ✅ |
| `isValidFullName()` | 2-100 chars, chỉ chữ + khoảng trắng + dấu | `Nguyễn Văn A` ✅ |
| `sanitizeHtml()` | Loại bỏ tags HTML nguy hiểm, giữ safe tags | Chống XSS |
| `isValidUrl()` | Chỉ `http://` hoặc `https://` + max 500 chars | Chống javascript: URL |
| `isValidMoney()` | `0 ≤ amount ≤ 999,999,999` | Chống overflow |

### 6.7.2. HTML Sanitization (Chống XSS)

```java
public static String sanitizeHtml(String input) {
    if (input == null) return null;
    // Loại bỏ các tag nguy hiểm
    String clean = input
        .replaceAll("(?i)<script.*?>.*?</script>", "")
        .replaceAll("(?i)<iframe.*?>.*?</iframe>", "")
        .replaceAll("(?i)<object.*?>.*?</object>", "")
        .replaceAll("(?i)<embed.*?>.*?</embed>", "")
        .replaceAll("(?i)on\\w+\\s*=", "")  // Loại bỏ event handlers
        .replaceAll("(?i)javascript:", "");   // Loại bỏ javascript: URLs
    return clean;
}
```

### 6.7.3. Chống SQL Injection

Toàn bộ DAO layer sử dụng **PreparedStatement** — SQL và dữ liệu được tách biệt hoàn toàn:

```java
// ✅ AN TOÀN - PreparedStatement
String sql = "SELECT * FROM Users WHERE email = ? AND is_active = 1";
PreparedStatement ps = conn.prepareStatement(sql);
ps.setString(1, email);  // Giá trị được escape tự động

// ❌ NGUY HIỂM - String concatenation (KHÔNG sử dụng trong dự án)
String sql = "SELECT * FROM Users WHERE email = '" + email + "'";
```

---

## 6.8. Cookie Security (Bảo mật Cookie)

**File:** [CookieUtil.java](file:///d:/GITHUB/PRJ301_GROUP4_SELLING_TICKET/SellingTicketJava/src/java/com/sellingticket/util/CookieUtil.java) — 96 dòng

### 6.8.1. Thuộc tính bảo mật cookie

| Cookie | Thuộc tính | Mục đích |
|--------|-----------|----------|
| `st_refresh` | `HttpOnly` | JavaScript không thể đọc → chống XSS steal token |
| `st_refresh` | `Secure` (khi HTTPS) | Chỉ gửi qua HTTPS → chống sniffing |
| `st_refresh` | `SameSite=Lax` | Không gửi cookie trong cross-site POST → chống CSRF |
| `st_refresh` | `Path=/contextPath` | Giới hạn cookie scope → tránh leak sang app khác trên cùng domain |
| `JSESSIONID` | `HttpOnly=true` | Cấu hình trong `web.xml` → Bảo vệ session cookie |

### 6.8.2. SameSite implementation

Do Jakarta Servlet API không hỗ trợ `SameSite` natively, hệ thống sử dụng **raw Set-Cookie header**:

```java
public static void addSecureCookie(HttpServletResponse response, String name,
                                    String value, int maxAge, boolean isSecure,
                                    String cookiePath) {
    StringBuilder sb = new StringBuilder();
    sb.append(name).append("=").append(value);
    sb.append("; Path=").append(path);
    sb.append("; HttpOnly");
    if (maxAge >= 0) sb.append("; Max-Age=").append(maxAge);
    if (isSecure) sb.append("; Secure");
    sb.append("; SameSite=Lax");
    response.addHeader("Set-Cookie", sb.toString());
}
```

### 6.8.3. Session Configuration (`web.xml`)

```xml
<session-config>
    <session-timeout>60</session-timeout>    <!-- 60 phút timeout -->
    <cookie-config>
        <http-only>true</http-only>          <!-- Bảo vệ JSESSIONID -->
    </cookie-config>
</session-config>
```

---

## 6.9. Phân quyền (Authorization)

### 6.9.1. Role-Based Access Control (RBAC)

Hệ thống phân quyền theo 5 vai trò với nguyên tắc **deny by default**:

| Role | Quyền truy cập | Filter kiểm soát |
|------|----------------|-------------------|
| `guest` (chưa đăng nhập) | Chỉ xem sự kiện, trang chủ, đăng ký | Không filter |
| `customer` | Mua vé, profile, hỗ trợ | `AuthFilter` |
| `organizer` | Quản lý sự kiện, team, dashboard | `AuthFilter` + `OrganizerAccessFilter` |
| `staff` | Soát vé (check-in) | `AuthFilter` + `StaffAccessFilter` |
| `admin` | Toàn quyền hệ thống | `AuthFilter` (role check) |
| `support_agent` | Quản lý support tickets | `AuthFilter` (role check) |

### 6.9.2. OrganizerAccessFilter — Phân quyền chi tiết cho Organizer

**File:** [OrganizerAccessFilter.java](file:///d:/GITHUB/PRJ301_GROUP4_SELLING_TICKET/SellingTicketJava/src/java/com/sellingticket/filter/OrganizerAccessFilter.java) — 122 dòng

Filter thực hiện **3 cấp kiểm tra tuần tự**:

| Cấp | Điều kiện | Hành động khi vi phạm |
|-----|-----------|----------------------|
| **1. Dashboard Lockout** | User chưa có event nào → không được vào dashboard | Redirect `/organizer/events?error=no_events` |
| **2. Operational Lockout** | User chưa có event được duyệt → không được vào Orders, Tickets, Check-in, Vouchers, Statistics | Redirect `/organizer/events?error=unapproved_events` |
| **3. Event Permission** | URL chứa eventId → kiểm tra ownership hoặc staff role | Redirect `/organizer/events?error=no_permission` |

**Exemptions (các trang không cần event được duyệt):** Dashboard (khi có ≥1 event), Events, Create Event, Settings, Chat.

**Permission check cho event cụ thể:**
```java
// Check-in path → cần quyền check-in
boolean isCheckInPath = pathInfo.startsWith("/organizer/check-in");
boolean hasAccess = isCheckInPath
    ? eventService.hasCheckInPermission(eventId, userId, role)
    : eventService.hasEditPermission(eventId, userId, role);
```

### 6.9.3. StaffAccessFilter — Kiểm soát truy cập nhân viên BTC

**File:** [StaffAccessFilter.java](file:///d:/GITHUB/PRJ301_GROUP4_SELLING_TICKET/SellingTicketJava/src/java/com/sellingticket/filter/StaffAccessFilter.java) — 67 dòng

- Admin luôn được qua (bypass)
- User khác phải tồn tại trong bảng `EventStaff` (được gán làm nhân viên cho ít nhất 1 event)
- Nếu không phải staff → redirect về trang chủ với error

### 6.9.4. ProtectedJspAccessFilter — Chặn truy cập JSP trực tiếp

**File:** [ProtectedJspAccessFilter.java](file:///d:/GITHUB/PRJ301_GROUP4_SELLING_TICKET/SellingTicketJava/src/java/com/sellingticket/filter/ProtectedJspAccessFilter.java) — 83 dòng

**Vấn đề:** Trong Java Servlet, JSP files có thể được truy cập trực tiếp qua URL (ví dụ: `/checkout.jsp`), bypass toàn bộ controller logic.

**Giải pháp:** Filter kiểm tra `RequestDispatcher.FORWARD_REQUEST_URI` — chỉ cho phép JSP render khi được forward/include từ servlet:

```java
boolean isForwarded = request.getAttribute(RequestDispatcher.FORWARD_REQUEST_URI) != null;
boolean isIncluded = request.getAttribute(RequestDispatcher.INCLUDE_REQUEST_URI) != null;

if (isForwarded || isIncluded) {
    chain.doFilter(req, res);  // Cho phép
    return;
}

// Truy cập trực tiếp → Block!
response.sendError(HttpServletResponse.SC_NOT_FOUND);  // 404
```

**Phạm vi bảo vệ:**
- Tất cả JSP trong `/admin/` và `/organizer/`
- Các JSP nhạy cảm tại root: `checkout.jsp`, `profile.jsp`, `my-tickets.jsp`, `ticket-selection.jsp`, `order-confirmation.jsp`, `payment-pending.jsp`, `support-ticket.jsp`, `support-ticket-detail.jsp`, `my-support-tickets.jsp`

---

## 6.10. Nhật ký hoạt động (Audit Trail)

**File:** [ActivityLogDAO.java](file:///d:/GITHUB/PRJ301_GROUP4_SELLING_TICKET/SellingTicketJava/src/java/com/sellingticket/dao/ActivityLogDAO.java) — 194 dòng

### 6.10.1. Cấu trúc Audit Log

Mọi hành động quan trọng của admin/organizer đều được ghi nhận vào bảng `ActivityLog`:

| Trường | Kiểu | Mô tả |
|--------|------|-------|
| `log_id` | INT (PK) | ID tự tăng |
| `user_id` | INT (FK) | Người thực hiện |
| `action` | VARCHAR | Loại hành động (ví dụ: `APPROVE_EVENT`, `DELETE_USER`) |
| `entity_type` | VARCHAR | Loại đối tượng (`Event`, `User`, `Order`) |
| `entity_id` | INT | ID đối tượng bị tác động |
| `details` | VARCHAR(500) | Chi tiết bổ sung (truncate tại 500 chars) |
| `ip_address` | VARCHAR | IP của người thực hiện |
| `created_at` | DATETIME | Thời điểm |

### 6.10.2. Chức năng

| Method | Mô tả |
|--------|-------|
| `log()` | Ghi 1 entry (sử dụng PreparedStatement) |
| `getRecent(limit)` | Lấy N entries gần nhất (cap tại 100) |
| `search()` | Tìm kiếm với filter + pagination (OFFSET/FETCH) |
| `countSearch()` | Đếm kết quả cho pagination |
| `getDistinctActions()` | Distinct action types cho filter dropdown |

---

## 6.11. Bảo mật thanh toán (Payment Security)

### 6.11.1. SePay Webhook Security

Khi SePay gửi webhook xác nhận thanh toán, hệ thống thực hiện **5 bước xác thực**:

| Bước | Biện pháp | Mục đích |
|------|-----------|----------|
| 1 | **API Key validation** | Kiểm tra header chứa API key hợp lệ |
| 2 | **Body size cap** | Giới hạn kích thước request body → chống DoS |
| 3 | **Amount mismatch rejection** | So sánh số tiền webhook vs đơn hàng trong DB |
| 4 | **Idempotency check** | Bảng `SeepayWebhookDedup` → chống xử lý trùng lặp |
| 5 | **Atomic order confirmation** | Transaction SQL → đảm bảo tính toàn vẹn dữ liệu |

### 6.11.2. Ticket Token Security

Mỗi vé điện tử chứa JWT token được mã hóa trong QR code:

```
JWT Payload:
{
  "sub": "TIX-A1B2C3D4",    // Mã vé (unique)
  "tid": 12345,              // Ticket ID
  "eid": 67890,              // Event ID
  "iat": 1700000000,         // Thời điểm tạo
  "exp": 1731536000          // Hết hạn (1 năm)
}
```

Khi check-in:
1. Quét QR → Extract JWT
2. `JwtUtil.verifyTicketToken()` → Kiểm tra signature + expiry
3. Tra cứu DB → Kiểm tra trạng thái vé (valid/used/cancelled)
4. Cập nhật trạng thái: `valid → used`

---

## 6.12. Error Handling & Information Leakage Prevention

### 6.12.1. Custom Error Pages

Cấu hình trong `web.xml` để ẩn stack trace và thông tin server:

```xml
<error-page>
    <error-code>404</error-code>
    <location>/404.jsp</location>
</error-page>
<error-page>
    <error-code>500</error-code>
    <location>/500.jsp</location>
</error-page>
<error-page>
    <exception-type>java.lang.Throwable</exception-type>
    <location>/500.jsp</location>
</error-page>
```

**Mục đích:**
- **404:** Trang lỗi thân thiện thay vì Tomcat default (tiết lộ version)
- **500:** Ẩn stack trace/exception details → kẻ tấn công không biết chi tiết lỗi
- **Throwable catch-all:** Mọi exception không xử lý đều hiển thị trang 500 tùy chỉnh

### 6.12.2. Logging Strategy

- Sử dụng `java.util.logging.Logger` thay vì `System.out.println()`
- Log levels: `INFO` cho hoạt động bình thường, `WARNING` cho sự kiện bảo mật, `SEVERE` cho lỗi nghiêm trọng
- **Không log passwords hay tokens đầy đủ** — chỉ log một phần signature (10 chars đầu) khi debug JWT

---

## 6.13. Bảng tổng hợp bảo mật

| Mối đe dọa (Threat) | Giải pháp (Mitigation) | File triển khai | OWASP Category |
|---------------------|----------------------|-----------------|----------------|
| **SQL Injection** | PreparedStatement toàn bộ DAO layer | `*DAO.java` (18 files) | A03:2021 Injection |
| **XSS (Cross-Site Scripting)** | Input validation + HTML sanitization + Security headers | `InputValidator.java`, `SecurityHeadersFilter.java` | A03:2021 Injection |
| **CSRF** | Synchronizer Token + Origin validation + SameSite cookies | `CsrfFilter.java`, `CookieUtil.java` | A01:2021 Broken Access Control |
| **Brute Force / Credential Stuffing** | Progressive lockout (email+IP) + IP-only blocking | `LoginAttemptTracker.java`, `LoginServlet.java` | A07:2021 Identification Failures |
| **Session Hijacking** | HttpOnly + Secure + SameSite cookies | `CookieUtil.java`, `web.xml` | A07:2021 Identification Failures |
| **Session Fixation** | Invalidate old session on login | `LoginServlet.java`, `GoogleOAuthServlet.java` | A07:2021 Identification Failures |
| **Clickjacking** | X-Frame-Options: SAMEORIGIN | `SecurityHeadersFilter.java` | A05:2021 Security Misconfiguration |
| **MIME Sniffing** | X-Content-Type-Options: nosniff | `SecurityHeadersFilter.java` | A05:2021 Security Misconfiguration |
| **Open Redirect** | Whitelist redirect paths, block `://`, `//`, `javascript:` | `LoginServlet.java` | A01:2021 Broken Access Control |
| **Timing Attack** | Constant-time comparison (JWT), fixed-delay login | `JwtUtil.java`, `LoginServlet.java` | A02:2021 Cryptographic Failures |
| **Algorithm Confusion** | Header algorithm validation (reject non-HS256) | `JwtUtil.java` | A02:2021 Cryptographic Failures |
| **Insecure Direct Object Reference** | Event ownership check, permission-based access | `OrganizerAccessFilter.java` | A01:2021 Broken Access Control |
| **Direct JSP Access** | Forward/include check → 404 for direct access | `ProtectedJspAccessFilter.java` | A01:2021 Broken Access Control |
| **Webhook Replay** | Idempotency via `SeepayWebhookDedup` table | `SeepayWebhookServlet.java` | A08:2021 Software/Data Integrity Failures |
| **Information Leakage** | Custom error pages, no stack trace exposure | `web.xml` | A05:2021 Security Misconfiguration |
| **Weak Password** | BCrypt cost 12, password policy enforcement | `PasswordUtil.java`, `InputValidator.java` | A02:2021 Cryptographic Failures |

---

> **Kết luận Chương 6:** Hệ thống SellingTicket triển khai mô hình bảo mật **defense-in-depth** với 7 security filters, xác thực đa lớp (Session + JWT + OAuth), và các biện pháp chống tấn công phủ rộng top 10 OWASP 2021. Kiến trúc bảo mật được thiết kế để mỗi lớp hoạt động độc lập — khi một lớp bị vượt qua, các lớp tiếp theo vẫn bảo vệ hệ thống.
