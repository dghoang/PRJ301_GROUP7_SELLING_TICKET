# CHƯƠNG 5: TRIỂN KHAI HỆ THỐNG (IMPLEMENTATION)

## 5.1 Tổng quan triển khai

### 5.1.1 Công nghệ và công cụ

Hệ thống TicketBox được triển khai trên nền tảng **Java EE** (Jakarta Servlet 5.0) với các công nghệ cốt lõi:

| Thành phần | Công nghệ | Phiên bản | Ghi chú |
|------------|-----------|-----------|---------|
| **Runtime** | Apache Tomcat | 10.x | Jakarta Servlet 5.0 |
| **Language** | Java | JDK 11+ | Lambda, Functional Interface |
| **Database** | SQL Server | 2019 | JDBC Driver `sqljdbc4` |
| **View Engine** | JSP + JSTL | 2.0 | Expression Language |
| **Build Tool** | Apache Ant | (NetBeans) | Tích hợp IDE |
| **Payment** | SePay API | REST | VietQR, webhook callback |
| **Storage** | Cloudinary | REST SDK | CDN cho ảnh/video |
| **Auth (OAuth)** | Google OAuth 2.0 | — | Đăng nhập xã hội |
| **Password** | BCrypt (jBCrypt) | 0.4 | Cost factor 12 |
| **JWT** | Pure Java | — | HMAC-SHA256 tự triển khai |

### 5.1.2 Quy mô mã nguồn

| Chỉ số | Giá trị |
|--------|---------|
| Tổng số Java classes | **~120 classes** |
| Model (Entity) | 17 classes |
| DAO (Data Access) | 18 classes + BaseDAO |
| Service (Business) | 15 classes |
| Payment subsystem | 5 classes (Factory + Strategy) |
| Controller (Servlet) | 60 Servlets |
| Filter (Security) | 7 Filters |
| Utility | 12 classes |
| JSP pages | 64+ pages |
| SQL migrations | 14 files |
| Tổng lines of code (ước tính) | **~15,000+ LOC** |

### 5.1.3 Nguyên tắc triển khai

Toàn bộ mã nguồn tuân thủ các nguyên tắc:

1. **Separation of Concerns:** Mỗi layer chỉ phụ trách một nhiệm vụ (Controller → Service → DAO)
2. **DRY (Don't Repeat Yourself):** `BaseDAO` loại bỏ boilerplate JDBC cho 18 DAO con
3. **Secure by Default:** 7 filter chain bảo mật chạy trước mọi request
4. **Fail Fast:** `ServiceException` truyền lỗi rõ ràng từ Service lên Controller
5. **Idempotent Migrations:** Mọi migration SQL sử dụng `IF NOT EXISTS` pattern

---

## 5.2 Triển khai Data Access Layer — BaseDAO

### 5.2.1 Vấn đề giải quyết

Trong dự án Java EE truyền thống với JDBC, mỗi thao tác CRUD phải lặp lại cùng một pattern:

```java
// ❌ Pattern lặp lại ở MỌI DAO method (50+ methods):
Connection conn = null;
PreparedStatement ps = null;
ResultSet rs = null;
try {
    conn = DBContext.getConnection();
    ps = conn.prepareStatement(sql);
    ps.setInt(1, id);           // ← Khác nhau
    rs = ps.executeQuery();
    while (rs.next()) {
        // map ResultSet → Object  // ← Khác nhau
    }
} catch (SQLException e) {
    // handle error
} finally {
    // close rs, ps, conn        // ← Luôn giống nhau
}
```

**Vấn đề:** ~70% code là boilerplate (mở/đóng connection, try-catch-finally). Chỉ ~30% là logic thực sự khác biệt (set params, map kết quả).

### 5.2.2 Giải pháp: Template Method + Functional Interface

`BaseDAO` áp dụng **Template Method Pattern** kết hợp **Java 8 Functional Interface** để tách phần cố định khỏi phần thay đổi:

```java
// ══════════════════════════════════════
// 2 Functional Interfaces
// ══════════════════════════════════════

@FunctionalInterface
public interface ParamSetter {
    void setParams(PreparedStatement ps) throws SQLException;
}

@FunctionalInterface
public interface RowMapper<T> {
    T map(ResultSet rs) throws SQLException;
}

// ══════════════════════════════════════
// Template Method: queryList()
// ══════════════════════════════════════

protected <T> List<T> queryList(String sql, ParamSetter setter, RowMapper<T> mapper) {
    List<T> result = new ArrayList<>();
    try (Connection conn = getConnection();
         PreparedStatement ps = conn.prepareStatement(sql)) {

        if (setter != null) setter.setParams(ps);   // ← Delegate tham số

        try (ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                result.add(mapper.map(rs));          // ← Delegate mapping
            }
        }
    } catch (SQLException e) {
        LOGGER.log(Level.SEVERE, "queryList failed: " + sql, e);
    }
    return result;
}
```

**Kết quả:** DAO con chỉ cần truyền Lambda, không còn boilerplate:

```java
// ✅ Sử dụng trong EventDAO — 3 dòng thay vì 25 dòng:
public List<Event> getApprovedEvents() {
    return queryList(
        "SELECT * FROM Events WHERE status = ? AND is_deleted = 0",
        ps -> ps.setString(1, "approved"),      // ParamSetter (Lambda)
        rs -> mapEvent(rs)                       // RowMapper (Lambda)
    );
}
```

### 5.2.3 Các template methods cung cấp

| Method | SQL Type | Return | Use Case |
|--------|----------|--------|----------|
| `queryList(sql, setter, mapper)` | SELECT (nhiều rows) | `List<T>` | Danh sách sự kiện, đơn hàng |
| `querySingle(sql, setter, mapper)` | SELECT (1 row) | `T` hoặc `null` | Tìm user theo email |
| `queryScalar(sql, setter, default)` | SELECT COUNT/SUM | `int` | Đếm vé bán, tổng doanh thu |
| `queryPaged(dataSql, countSql, ...)` | SELECT + COUNT | `PageResult<T>` | Phân trang admin dashboard |
| `executeUpdate(sql, setter)` | INSERT/UPDATE/DELETE | `int` (affected) | Cập nhật trạng thái |
| `executeInsertReturnKey(sql, setter)` | INSERT + IDENTITY | `int` (new PK) | Tạo đơn hàng mới |

### 5.2.4 Phân trang tự động (queryPaged)

Method `queryPaged` xử lý đồng thời 2 query: lấy data + đếm tổng:

```java
protected <T> PageResult<T> queryPaged(
        String dataSql, String countSql,
        ParamSetter setter, RowMapper<T> mapper,
        int page, int pageSize) {

    // 1. Đếm tổng records
    int total = queryScalar(countSql, setter, 0);

    // 2. Tính OFFSET và append phân trang
    int offset = (page - 1) * pageSize;
    String pagedSql = dataSql + " OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";

    // 3. Lấy data trang hiện tại
    List<T> items = queryList(pagedSql,
        ps -> {
            if (setter != null) setter.setParams(ps);
            // Append offset, pageSize vào cuối
        }, mapper);

    return new PageResult<>(items, total, page, pageSize);
}
```

**Model `PageResult<T>`** — Generic class hỗ trợ tính toán phân trang:

```java
public class PageResult<T> {
    private List<T> items;
    private int totalItems, currentPage, pageSize;

    public int getTotalPages() {
        return (int) Math.ceil((double) totalItems / pageSize);
    }
    public boolean hasPreviousPage() { return currentPage > 1; }
    public boolean hasNextPage()     { return currentPage < getTotalPages(); }
}
```

---

## 5.3 Triển khai Connection Pool — DBContext

### 5.3.1 Kiến trúc Connection Pool tự xây dựng

Thay vì sử dụng connection pool bên thứ ba (HikariCP, C3P0), dự án tự triển khai **connection pool** trong `DBContext.java` sử dụng **JDK Dynamic Proxy** và **CAS (Compare-And-Swap)**:

```
┌─────────────────────────────────────────────┐
│              DBContext (Singleton)            │
│                                              │
│  ┌───────────────────────────────────────┐  │
│  │   LinkedBlockingQueue<Connection>      │  │
│  │   ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐   │  │
│  │   │Conn1│ │Conn2│ │Conn3│ │ ... │   │  │
│  │   └─────┘ └─────┘ └─────┘ └─────┘   │  │
│  │          MAX_POOL_SIZE = 20           │  │
│  └───────────────────────────────────────┘  │
│                                              │
│  activeCount: AtomicInteger (CAS)            │
│  waitTimeoutMs: 5000ms                       │
└─────────────────────────────────────────────┘
```

### 5.3.2 Cơ chế hoạt động

**a) Lấy connection (`getConnection`):**

```java
public Connection getConnection() throws SQLException {
    // 1. Thử lấy connection nhàn rỗi từ pool
    Connection conn = pool.poll();

    if (conn != null && !conn.isClosed()) {
        return wrapConnection(conn);  // Wrap bằng Proxy
    }

    // 2. Pool hết → tạo mới nếu chưa đạt MAX
    if (activeCount.incrementAndGet() <= MAX_POOL_SIZE) {
        return wrapConnection(createNewConnection());
    }

    // 3. Đạt MAX → chờ connection trả về (timeout 5s)
    activeCount.decrementAndGet();
    conn = pool.poll(WAIT_TIMEOUT_MS, TimeUnit.MILLISECONDS);

    if (conn == null) throw new SQLException("Pool exhausted");
    return wrapConnection(conn);
}
```

**b) Trả connection về pool (Proxy Pattern):**

Sử dụng **JDK Dynamic Proxy** để intercept method `close()` — thay vì đóng connection thật, trả lại pool:

```java
private Connection wrapConnection(Connection realConn) {
    return (Connection) Proxy.newProxyInstance(
        Connection.class.getClassLoader(),
        new Class[]{Connection.class},
        (proxy, method, args) -> {
            if ("close".equals(method.getName())) {
                // Không đóng thật → trả về pool
                if (!realConn.isClosed()) {
                    if (!realConn.getAutoCommit()) {
                        realConn.setAutoCommit(true);
                    }
                    pool.offer(realConn);
                }
                return null;
            }
            return method.invoke(realConn, args);
        }
    );
}
```

**c) Thread-safety:**

| Cơ chế | Mục đích |
|--------|----------|
| `AtomicInteger` (CAS) | Đếm active connections không cần `synchronized` |
| `LinkedBlockingQueue` | Thread-safe FIFO queue cho pool |
| `poll(timeout)` | Chờ có connection trả về, tránh busy-wait |
| `Proxy.newProxyInstance` | Intercept `close()` mà không sửa JDBC driver |

### 5.3.3 Unwrap và monitoring

```java
// Lấy connection thật (bỏ qua Proxy) — dùng cho batch operations
public static Connection unwrap(Connection conn) {
    if (Proxy.isProxyClass(conn.getClass())) {
        // Truy xuất InvocationHandler → lấy realConnection
    }
    return conn;
}

// Debug: xem trạng thái pool
public static String getPoolStats() {
    return String.format("Pool: idle=%d, active=%d, max=%d",
        pool.size(), activeCount.get(), MAX_POOL_SIZE);
}
```

---

## 5.4 Triển khai bảo mật — Security Filter Chain

### 5.4.1 Kiến trúc chuỗi filter 7 lớp

Hệ thống triển khai **Defense in Depth** qua 7 Servlet Filter, thực thi theo thứ tự cố định trong `web.xml`:

```
HTTP Request
    │
    ▼
┌──────────────────────────┐
│ 1. SecurityHeadersFilter │ → CSP, X-Frame-Options, HSTS, X-Content-Type-Options
├──────────────────────────┤
│ 2. CsrfFilter            │ → Double-submit CSRF token, Origin validation
├──────────────────────────┤
│ 3. AuthFilter             │ → Session + JWT + Refresh Token (triple fallback)
├──────────────────────────┤
│ 4. CacheFilter            │ → Cache-Control: no-store cho trang nhạy cảm
├──────────────────────────┤
│ 5. OrganizerAccessFilter  │ → Chặn /organizer/* nếu role ≠ organizer
├──────────────────────────┤
│ 6. StaffAccessFilter      │ → Chặn /staff/* nếu role ≠ staff
├──────────────────────────┤
│ 7. ProtectedJspFilter     │ → Chặn truy cập trực tiếp file .jsp
└──────────────────────────┘
    │
    ▼
 Servlet (Controller)
```

### 5.4.2 SecurityHeadersFilter — HTTP Security Headers

Filter đầu tiên trong chain, thêm các header bảo mật vào **mọi HTTP response**:

```java
public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain) {
    HttpServletResponse response = (HttpServletResponse) res;

    // Chống Clickjacking
    response.setHeader("X-Frame-Options", "DENY");

    // Chống MIME sniffing
    response.setHeader("X-Content-Type-Options", "nosniff");

    // Chống XSS (legacy browser)
    response.setHeader("X-XSS-Protection", "1; mode=block");

    // Content Security Policy — chỉ cho phép resources từ domain tin cậy
    response.setHeader("Content-Security-Policy",
        "default-src 'self'; " +
        "script-src 'self' 'unsafe-inline' cdn.jsdelivr.net ...; " +
        "img-src 'self' data: blob: res.cloudinary.com ...; " +
        "connect-src 'self' qr.sepay.vn ...");

    // HSTS — ép HTTPS (chỉ khi đã dùng HTTPS)
    if (request.isSecure()) {
        response.setHeader("Strict-Transport-Security",
            "max-age=31536000; includeSubDomains");
    }

    chain.doFilter(req, res);
}
```

| Header | Tấn công chặn | Ý nghĩa |
|--------|---------------|---------|
| `X-Frame-Options: DENY` | Clickjacking | Không cho nhúng iframe |
| `X-Content-Type-Options: nosniff` | MIME confusion | Không cho browser đoán MIME |
| `Content-Security-Policy` | XSS, data injection | Whitelist nguồn resource |
| `Strict-Transport-Security` | SSL stripping | Ép HTTPS 1 năm |

### 5.4.3 CsrfFilter — Double-Submit CSRF Protection

Bảo vệ chống **Cross-Site Request Forgery** bằng kỹ thuật **Double-Submit Cookie + Token Rotation**:

**Cơ chế hoạt động:**

```
1. GET /checkout
   → Server sinh csrfToken, lưu vào Session
   → Render <input type="hidden" name="csrf_token" value="abc123">
   → Set cookie: csrf_cookie=abc123

2. POST /checkout (form submit)
   → CsrfFilter kiểm tra:
      a) csrf_token trong form body == session token?
      b) Origin header == server origin?
   → Nếu khớp → cho phép
   → Nếu không → HTTP 403 Forbidden

3. Sau mỗi validation thành công:
   → Xoá token cũ, sinh token MỚI (rotation)
   → Chống replay attack
```

**Các request được bypass CSRF:**
- `GET`, `HEAD`, `OPTIONS` (safe methods)
- `/api/seepay/webhook` (webhook dùng API key riêng)
- Static resources (`.css`, `.js`, `.png`, `.jpg`)

### 5.4.4 AuthFilter — Triple-Fallback Authentication

Filter xác thực phức tạp nhất, hỗ trợ **3 cơ chế fallback** tự động:

```
Request đến
    │
    ▼
┌─ Check 1: HttpSession ─┐
│ session.getAttribute    │
│ ("currentUser") != null?│
└────────┬────────────────┘
         │ null
         ▼
┌─ Check 2: JWT Cookie ──┐
│ Cookie "st_access"      │
│ → JwtUtil.verify()      │
│ → Load user from DB     │
└────────┬────────────────┘
         │ null/expired
         ▼
┌─ Check 3: Refresh Token ┐
│ Cookie "st_refresh"      │
│ → DB lookup (active?)    │
│ → Issue new access token │
│ → Restore session        │
└────────┬─────────────────┘
         │ null/revoked
         ▼
    Anonymous (guest)
    → request.setAttribute("currentUser", null)
```

**Luồng xử lý trong code:**

```java
public void doFilter(ServletRequest req, ...) {
    HttpServletRequest request = (HttpServletRequest) req;
    User user = null;

    // Fallback 1: HttpSession
    HttpSession session = request.getSession(false);
    if (session != null) {
        user = (User) session.getAttribute("currentUser");
    }

    // Fallback 2: JWT Access Token
    if (user == null) {
        user = authTokenService.validateAccessToken(request);
    }

    // Fallback 3: Refresh Token (auto-renew)
    if (user == null) {
        user = authTokenService.refreshAccessToken(request, response);
        if (user != null) {
            // Khôi phục session
            session = request.getSession(true);
            session.setAttribute("currentUser", user);
        }
    }

    // Kiểm tra user bị vô hiệu hóa
    if (user != null && (!user.isActive() || user.isDeleted())) {
        authTokenService.clearAuthCookies(request, response);
        session.invalidate();
        user = null;
    }

    request.setAttribute("currentUser", user);
    chain.doFilter(req, res);
}
```

**Đặc điểm nổi bật:**

| Tính năng | Chi tiết |
|-----------|---------|
| **Silent renewal** | Refresh token tự động gia hạn, user không cần re-login |
| **Deactivation check** | Mỗi request kiểm tra `is_active` + `is_deleted` |
| **Multi-device** | Refresh token lưu DB kèm `user_agent`, `ip_address` |
| **Secure cookies** | `HttpOnly`, `Secure` (HTTPS), `SameSite=Lax` |
| **Token revocation** | Logout → xóa refresh token khỏi DB + xóa cookies |

### 5.4.5 RBAC — Role-Based Access Control (OrganizerAccessFilter + StaffAccessFilter)

```java
// OrganizerAccessFilter — chặn /organizer/*
public void doFilter(ServletRequest req, ...) {
    User user = (User) request.getAttribute("currentUser");

    if (user == null) {
        response.sendRedirect(contextPath + "/login");
        return;
    }

    String role = user.getRole();
    if (!"organizer".equals(role) && !"admin".equals(role)) {
        response.sendError(403, "Access denied");
        return;
    }

    chain.doFilter(req, res);
}
```

**Ma trận truy cập URL:**

| URL Pattern | customer | organizer | admin | staff | guest |
|-------------|:--------:|:---------:|:-----:|:-----:|:-----:|
| `/home`, `/events/*` | ✅ | ✅ | ✅ | ✅ | ✅ |
| `/checkout`, `/my-orders` | ✅ | ✅ | ✅ | ❌ | ❌ |
| `/organizer/*` | ❌ | ✅ | ✅ | ❌ | ❌ |
| `/admin/*` | ❌ | ❌ | ✅ | ❌ | ❌ |
| `/staff/*` | ❌ | ❌ | ✅ | ✅ | ❌ |
| `/api/seepay/webhook` | — | — | — | — | API Key |

---

## 5.5 Triển khai xác thực — JWT và Password Hashing

### 5.5.1 JWT thuần Java (HMAC-SHA256)

Thay vì sử dụng thư viện JWT bên thứ ba (jjwt, Auth0 JWT), dự án tự triển khai JWT trong `JwtUtil.java` sử dụng thuần **Java Cryptography API**:

**Cấu trúc JWT token:**

```
eyJhbGciOiJIUzI1NiJ9          ← Header: {"alg":"HS256"}
.eyJzdWIiOjEsInR5cGUiOiJhY... ← Payload: {"sub":1,"type":"access","role":"admin",...}
.X5v8KpQ...                   ← Signature: HMAC-SHA256(header.payload, SECRET)
```

**Quá trình tạo token:**

```java
public static String generateAuthToken(int userId, String role, String email, String type) {
    // 1. Header (cố định)
    String header = base64UrlEncode("{\"alg\":\"HS256\"}");

    // 2. Payload (dynamic)
    long now = System.currentTimeMillis() / 1000;
    long exp = now + (type.equals("access")
                      ? ACCESS_TOKEN_EXPIRY_SEC     // 15 phút
                      : REFRESH_TOKEN_EXPIRY_SEC);  // 30 ngày

    String payload = base64UrlEncode(String.format(
        "{\"sub\":%d,\"role\":\"%s\",\"email\":\"%s\",\"type\":\"%s\"," +
        "\"iat\":%d,\"exp\":%d,\"jti\":\"%s\"}",
        userId, role, email, type, now, exp, generateRefreshTokenId()));

    // 3. Signature (HMAC-SHA256)
    String data = header + "." + payload;
    Mac mac = Mac.getInstance("HmacSHA256");
    mac.init(new SecretKeySpec(SECRET_KEY.getBytes(), "HmacSHA256"));
    String signature = base64UrlEncode(mac.doFinal(data.getBytes()));

    return data + "." + signature;
}
```

**Quá trình xác minh:**

```java
public static Map<String, Object> verifyAuthToken(String token) {
    String[] parts = token.split("\\.");
    if (parts.length != 3) return null;

    // 1. Tái tạo signature từ header.payload
    String expectedSig = hmacSha256(parts[0] + "." + parts[1], SECRET_KEY);

    // 2. So sánh constant-time (chống timing attack)
    if (!MessageDigest.isEqual(expectedSig.getBytes(), parts[2].getBytes())) {
        return null;  // Token bị tamper
    }

    // 3. Parse payload, kiểm tra expiration
    Map<String, Object> claims = parseJson(base64UrlDecode(parts[1]));
    long exp = ((Number) claims.get("exp")).longValue();
    if (System.currentTimeMillis() / 1000 > exp) return null;  // Hết hạn

    return claims;
}
```

**Cấu hình token lifetime:**

| Token Type | Lifetime | Lưu trữ | Mục đích |
|-----------|----------|---------|---------|
| Access Token | 15 phút | Cookie `st_access` (HttpOnly) | Xác thực nhanh, stateless |
| Refresh Token | 30 ngày | Cookie `st_refresh` + DB `RefreshTokens` | Silent renewal, Remember Me |

### 5.5.2 Password Hashing — BCrypt

Sử dụng thư viện **jBCrypt** với cost factor 12 (4096 iterations):

```java
public class PasswordUtil {
    // Hash password mới (register, change password)
    public static String hashPassword(String plainPassword) {
        return BCrypt.hashpw(plainPassword, BCrypt.gensalt(12));
        // Output: $2a$12$LJ3m4ys3... (60 ký tự)
    }

    // Verify password (login)
    public static boolean checkPassword(String plainPassword, String hashedPassword) {
        return BCrypt.checkpw(plainPassword, hashedPassword);
    }
}
```

**Tại sao BCrypt Cost 12?**

| Cost Factor | Iterations | Thời gian hash | Phù hợp |
|-------------|-----------|-----------------|---------|
| 10 | 1,024 | ~80ms | Tối thiểu cho production |
| **12** | **4,096** | **~300ms** | **Cân bằng UX và bảo mật** |
| 14 | 16,384 | ~1.2s | Quá chậm cho web app |

### 5.5.3 AuthTokenService — Token Lifecycle Coordinator

`AuthTokenService` điều phối toàn bộ vòng đời token:

```
Login
  │
  ├─ issueTokens() ───────► Set cookies + Save refresh token to DB
  │
  ├─ validateAccessToken() ► Verify JWT → return User (no DB hit)
  │
  ├─ refreshAccessToken() ─► Lookup refresh in DB → issue new access
  │
  ├─ revokeTokens() ───────► Delete cookies + Revoke in DB
  │
  └─ revokeAllUserTokens() ► Invalidate ALL devices (password change)
```

**Multi-device tracking:** Mỗi refresh token lưu `user_agent` + `ip_address` vào bảng `RefreshTokens`, cho phép:
- Xem danh sách thiết bị đang đăng nhập
- Thu hồi token từ xa (force logout device cụ thể)
- Phát hiện đăng nhập bất thường

---

## 5.6 Triển khai thanh toán — Strategy Pattern

### 5.6.1 Kiến trúc Payment (Factory + Strategy)

Hệ thống thanh toán sử dụng **2 design patterns** kết hợp:

```
OrderService
    │
    ▼
PaymentFactory.getProvider("seepay")    ← Factory Pattern
    │
    ▼
┌─────────────────────────┐
│ «interface»             │
│ PaymentProvider          │
│ + initiatePayment()     │             ← Strategy Pattern
│ + checkStatus()         │
│ + supportsRefund()      │
│ + getMethodName()       │
└────────┬────────────────┘
         │
    ┌────┴────────────┐
    ▼                 ▼
SeepayProvider   BankTransferProvider
(QR VietQR)      (Manual transfer)
```

### 5.6.2 PaymentProvider Interface (Strategy)

```java
public interface PaymentProvider {
    /** Khởi tạo giao dịch thanh toán, trả về QR hoặc thông tin chuyển khoản */
    PaymentResult initiatePayment(Order order);

    /** Kiểm tra trạng thái giao dịch */
    PaymentResult checkStatus(String transactionId);

    /** Provider có hỗ trợ hoàn tiền không? */
    boolean supportsRefund();

    /** Tên phương thức để hiển thị UI */
    String getMethodName();
}
```

### 5.6.3 PaymentFactory (Factory Pattern)

```java
public class PaymentFactory {
    private static final Map<String, PaymentProvider> PROVIDERS = new HashMap<>();

    static {
        PROVIDERS.put("seepay", new SeepayProvider());
        PROVIDERS.put("bank_transfer", new BankTransferProvider());
    }

    public static PaymentProvider getProvider(String paymentMethod) {
        PaymentProvider provider = PROVIDERS.get(paymentMethod);
        if (provider == null) {
            throw new IllegalArgumentException("Unsupported: " + paymentMethod);
        }
        return provider;
    }

    public static boolean isSupported(String paymentMethod) {
        return PROVIDERS.containsKey(paymentMethod);
    }
}
```

**Lợi ích Open/Closed Principle:** Thêm provider mới (MoMo, ZaloPay) chỉ cần:
1. Tạo class `MomoProvider implements PaymentProvider`
2. Thêm 1 dòng: `PROVIDERS.put("momo", new MomoProvider())`
3. **Không sửa bất kỳ code cũ nào**

### 5.6.4 SeepayProvider — Tích hợp VietQR

```java
public class SeepayProvider implements PaymentProvider {

    @Override
    public PaymentResult initiatePayment(Order order) {
        // 1. Tạo nội dung chuyển khoản chứa mã đơn
        String transferContent = order.getOrderCode();

        // 2. Sinh URL VietQR
        String qrUrl = String.format(
            "https://qr.sepay.vn/img?acc=%s&bank=%s&amount=%.0f&des=%s",
            ACCOUNT_NUMBER, BANK_CODE,
            order.getFinalAmount(), transferContent);

        // 3. Trả về kết quả
        return new PaymentResult(true, null, qrUrl,
            "Quét mã QR để thanh toán");
    }
}
```

**Luồng thanh toán SePay đầy đủ:**

```
1. Customer chọn vé → POST /checkout
2. Server tạo Order (status=pending) + sinh QR code
3. Customer quét QR → chuyển khoản qua ngân hàng
4. SePay detect giao dịch → gọi POST /api/seepay/webhook
5. SeepayWebhookServlet:
   a) Xác thực API key trong header
   b) Check idempotency (SeepayWebhookDedup table)
   c) Parse order_code từ nội dung chuyển khoản
   d) Verify số tiền khớp
   e) Update order status → "paid"
   f) Sinh vé (Tickets) + QR code cho từng vé
6. Frontend polling GET /api/payment-status
   → Phát hiện status="paid" → redirect trang vé
```

### 5.6.5 Webhook Idempotency (SeepayWebhookDedup)

Chống xử lý trùng lặp khi SePay gọi webhook nhiều lần:

```java
// Trong SeepayWebhookServlet
String txnId = webhookData.getString("id");

// 1. Kiểm tra đã xử lý chưa (UNIQUE constraint)
if (dedupDAO.exists(txnId)) {
    response.setStatus(200);  // Trả 200 để SePay không retry
    return;
}

// 2. Ghi nhận trước khi xử lý (insert trước, xử lý sau)
dedupDAO.insert(txnId, orderCode, "processing");

// 3. Xử lý đơn hàng...
orderDAO.confirmPayment(orderId);

// 4. Cập nhật trạng thái dedup
dedupDAO.updateResult(txnId, "processed");
```

---

## 5.7 Triển khai nghiệp vụ — CheckoutServlet

### 5.7.1 Tổng quan luồng checkout

`CheckoutServlet` là servlet phức tạp nhất hệ thống, xử lý **toàn bộ quy trình mua vé** từ validation đến tạo đơn:

```
POST /checkout
    │
    ├─ 1. CSRF Token validation
    ├─ 2. Authentication check (phải đăng nhập)
    ├─ 3. Parse cart items (ticketTypeId + quantity)
    ├─ 4. Validate event (approved? chưa kết thúc?)
    ├─ 5. Anti-hoarding check (max tickets/user/event)
    ├─ 6. Voucher validation (nếu có mã giảm giá)
    ├─ 7. Calculate amounts (total, discount, final, platform fee)
    ├─ 8. Create Order (atomic transaction)
    ├─ 9. Initiate Payment (PaymentFactory → QR code)
    └─ 10. Redirect to payment page
```

### 5.7.2 Anti-Hoarding — Chống gom vé

Cơ chế ngăn một user mua quá nhiều vé cho cùng một sự kiện:

```java
// Giới hạn mặc định: 10 vé/user/event (có thể cấu hình theo event)
int maxPerOrder = event.getMaxTicketsPerOrder();
if (maxPerOrder <= 0) maxPerOrder = DEFAULT_MAX_TICKETS; // 10

// Đếm vé user đã mua cho event này (across ALL orders)
int existingTickets = orderService.countUserTicketsForEvent(userId, eventId);
int requestedTotal = existingTickets + totalRequestedQuantity;

if (requestedTotal > maxPerOrder) {
    request.setAttribute("error",
        String.format("Bạn chỉ được mua tối đa %d vé. Đã mua: %d",
                      maxPerOrder, existingTickets));
    // Forward back to event page
    return;
}
```

### 5.7.3 Voucher Validation và Settlement

```java
// Validate voucher (nếu customer nhập mã giảm giá)
if (voucherCode != null && !voucherCode.isEmpty()) {
    Voucher voucher = voucherService.getVoucherByCode(voucherCode);

    // Kiểm tra 7 điều kiện:
    // 1. Voucher tồn tại?
    // 2. is_active = true?
    // 3. is_deleted = false?
    // 4. Chưa hết hạn (end_date > now)?
    // 5. Đã bắt đầu (start_date <= now)?
    // 6. Chưa hết lượt (used_count < usage_limit)?
    // 7. Đơn hàng tối thiểu (total >= min_order_amount)?

    if (voucher.isUsable()) {
        // Tính giảm giá
        if ("percentage".equals(voucher.getDiscountType())) {
            discount = totalAmount * voucher.getDiscountValue() / 100;
            // Áp dụng cap (max_discount)
            if (voucher.getMaxDiscount() > 0) {
                discount = Math.min(discount, voucher.getMaxDiscount());
            }
        } else { // "fixed"
            discount = voucher.getDiscountValue();
        }
    }
}

// Settlement — phân bổ giảm giá theo nguồn
if ("ORGANIZER".equals(voucher.getFundSource())) {
    order.setEventDiscountAmount(discount);     // Organizer chịu
} else { // "SYSTEM"
    order.setSystemDiscountAmount(discount);    // Platform chịu
}

// Platform fee = 3% trên tổng trước giảm
double platformFee = totalAmount * platformFeeRate;
order.setPlatformFeeAmount(platformFee);

// Organizer nhận = total - event_discount - platform_fee
order.setOrganizerPayoutAmount(
    totalAmount - order.getEventDiscountAmount() - platformFee);
```

### 5.7.4 Double-Submit Guard

Chống submit form trùng lặp (user click 2 lần nút "Thanh toán"):

```java
// Server-side: dùng session token
String submitToken = request.getParameter("submit_token");
String sessionToken = (String) session.getAttribute("checkout_submit_token");

if (submitToken == null || !submitToken.equals(sessionToken)) {
    // Token không khớp → có thể là duplicate submit
    response.sendRedirect(request.getContextPath() + "/my-orders");
    return;
}

// Xóa token ngay lập tức → submit lần 2 sẽ bị chặn
session.removeAttribute("checkout_submit_token");
```

---

## 5.8 Triển khai tích hợp bên ngoài

Hệ thống TicketBox tích hợp 4 dịch vụ bên ngoài: **Cloudinary** (media CDN), **Google OAuth 2.0** (đăng nhập xã hội), **SePay/VietQR** (thanh toán ngân hàng), và **JWT QR Code** (vé điện tử).

### 5.8.1 Cloudinary — Media Storage (CDN)

#### CloudinaryUtil — Singleton Wrapper

`CloudinaryUtil` sử dụng pattern **Singleton** để đảm bảo một instance Cloudinary duy nhất, với cấu hình linh hoạt qua file properties hoặc biến môi trường:

```java
public class CloudinaryUtil {
    private static CloudinaryUtil instance;
    private Cloudinary cloudinary;
    private boolean configured = false;

    private CloudinaryUtil() { loadConfig(); }

    public static synchronized CloudinaryUtil getInstance() {
        if (instance == null) instance = new CloudinaryUtil();
        return instance;
    }

    private void loadConfig() {
        try (InputStream is = getClass().getClassLoader()
                .getResourceAsStream("cloudinary.properties")) {
            Properties props = new Properties();
            props.load(is);

            // Ưu tiên: properties file → biến môi trường
            String cloudName = resolveProperty(props, "cloudinary.cloud_name", "CLOUDINARY_CLOUD_NAME");
            String apiKey    = resolveProperty(props, "cloudinary.api_key",    "CLOUDINARY_API_KEY");
            String apiSecret = resolveProperty(props, "cloudinary.api_secret", "CLOUDINARY_API_SECRET");

            if (isValidCredential(cloudName) && isValidCredential(apiKey) && isValidCredential(apiSecret)) {
                Map<String, String> config = new HashMap<>();
                config.put("cloud_name", cloudName);
                config.put("api_key", apiKey);
                config.put("api_secret", apiSecret);
                config.put("secure", "true");
                this.cloudinary = new Cloudinary(config);
                this.configured = true;
            }
        } catch (Exception e) { /* log error */ }
    }

    // Upload trả về Map chứa url, public_id, width, height, bytes, format
    public Map<String, Object> upload(byte[] fileBytes, String folder, String fileName) {
        if (!configured) return null;
        Map<String, Object> options = new HashMap<>();
        options.put("folder", folder);
        options.put("resource_type", "auto"); // Tự detect image/video
        Map<String, Object> result = cloudinary.uploader().upload(fileBytes, options);
        // Trích xuất các field cần thiết
        Map<String, Object> response = new HashMap<>();
        response.put("url", result.get("secure_url"));
        response.put("public_id", result.get("public_id"));
        response.put("width", result.get("width"));
        response.put("height", result.get("height"));
        return response;
    }

    // URL transformation tích hợp sẵn (không cần gọi API)
    public static String thumbnailUrl(String url) { return transformUrl(url, 400, 225); }
    public static String bannerUrl(String url)    { return transformUrl(url, 1200, 0); }
    public static String avatarUrl(String url) {
        return url.replace("/upload/", "/upload/c_fill,w_150,h_150,g_face,q_auto,f_auto/");
    }
}
```

**Điểm thiết kế đặc biệt:**
- **Fallback cấu hình 2 lớp:** file properties → biến môi trường (hỗ trợ cả local dev và production deployment)
- **Credential validation:** từ chối giá trị placeholder (`YOUR_*`, `CHANGE_ME*`)
- **URL transformation:** chèn tham số resize/format vào URL gốc mà không cần API call

#### MediaService — Upload Pipeline 6 bước

`MediaService` xử lý toàn bộ business logic upload, kết nối CloudinaryUtil với database:

```java
public Media uploadMedia(byte[] fileBytes, String fileName, String mimeType,
                         String entityType, int entityId, String purpose,
                         int uploaderId, String altText) {

    // 1. Validate MIME type (chỉ cho phép image/jpeg, png, webp, gif, video/mp4, webm)
    String mediaType = resolveMediaType(mimeType);
    if (mediaType == null) return null;

    // 2. Validate file size (avatar: 5MB max, others: 50MB max)
    int maxSize = "avatar".equals(purpose) ? MAX_AVATAR_SIZE : MAX_FILE_SIZE;
    if (fileBytes.length > maxSize) return null;

    // 3. Kiểm tra giới hạn số lượng (event: tối đa 10 media)
    if ("event".equals(entityType)) {
        if (mediaDAO.countByEntity(entityType, entityId) >= MAX_IMAGES_PER_EVENT)
            return null;
    }

    // 4. Thay thế avatar/banner cũ (xóa file cũ trên Cloudinary + DB)
    if ("avatar".equals(purpose) || "banner".equals(purpose)) {
        Media existing = mediaDAO.getSingleByEntityAndPurpose(entityType, entityId, purpose);
        if (existing != null) deleteMedia(existing.getMediaId(), uploaderId);
    }

    // 5. Upload lên Cloudinary
    String folder = "ticketbox/" + entityType + "s/" + entityId;
    Map<String, Object> result = cloudinaryUtil.upload(fileBytes, folder, fileName);
    if (result == null) return null;

    // 6. Lưu metadata vào DB
    Media media = new Media();
    media.setCloudinaryUrl((String) result.get("url"));
    media.setCloudinaryPublicId((String) result.get("public_id"));
    media.setFileSize(fileBytes.length);
    // ... set other fields
    int id = mediaDAO.insert(media);
    return id > 0 ? media : null;
}
```

**Folder structure trên Cloudinary:**

| Entity | Folder path | Ví dụ URL |
|--------|------------|-----------|
| Event banner | `ticketbox/events/{id}` | `res.cloudinary.com/.../ticketbox/events/42/banner.jpg` |
| User avatar | `ticketbox/users/{id}` | `res.cloudinary.com/.../ticketbox/users/1/avatar.png` |
| Event gallery | `ticketbox/events/{id}` | `res.cloudinary.com/.../ticketbox/events/42/photo3.jpg` |

### 5.8.2 Google OAuth 2.0 — Đăng nhập xã hội

`GoogleOAuthServlet` xử lý toàn bộ luồng OAuth 2.0 trong một servlet duy nhất, với hai URL pattern:

```
@WebServlet(urlPatterns = {"/auth/google", "/auth/google/callback"})
```

#### Luồng OAuth 5 bước

```
┌──────────┐     GET /auth/google      ┌───────────────────┐
│  Browser  │ ────────────────────────→ │ GoogleOAuthServlet │
│           │ ←── 302 Redirect ──────── │ handleRedirectTo   │
│           │                           │ Google()           │
│           │     (state=UUID)          └───────────────────┘
│           │                                    │
│           │ ────→ Google Consent Screen ────→   │
│           │ ←──── /auth/google/callback?code=X&state=Y
│           │                           ┌───────────────────┐
│           │ ────────────────────────→ │ handleCallback()   │
│           │                           │ 1. Verify state    │
│           │                           │ 2. Exchange code   │
│           │                           │ 3. Get userInfo    │
│           │                           │ 4. Login/Register  │
│           │ ←── 302 → /home ───────── │ 5. Issue JWT       │
└──────────┘                           └───────────────────┘
```

#### Code triển khai thực tế

```java
// Step 1: Redirect to Google (chống CSRF bằng state token)
private void handleRedirectToGoogle(HttpServletRequest req, HttpServletResponse res) {
    String state = UUID.randomUUID().toString();
    req.getSession().setAttribute("oauth_state", state);

    String authUrl = AUTH_URL
        + "?client_id=" + URLEncoder.encode(clientId, UTF_8)
        + "&redirect_uri=" + URLEncoder.encode(redirectUri, UTF_8)
        + "&response_type=code"
        + "&scope=" + URLEncoder.encode("email profile", UTF_8)
        + "&state=" + URLEncoder.encode(state, UTF_8)
        + "&access_type=online&prompt=select_account";
    res.sendRedirect(authUrl);
}

// Step 2-5: Handle callback
private void handleCallback(HttpServletRequest req, HttpServletResponse res) {
    // Verify state (chống CSRF)
    String savedState = (String) req.getSession().getAttribute("oauth_state");
    if (!savedState.equals(req.getParameter("state")))
        throw new SecurityException("OAuth state mismatch");
    req.getSession().removeAttribute("oauth_state");

    // Exchange code → access_token (POST to Google Token endpoint)
    String accessToken = exchangeCodeForToken(req.getParameter("code"));

    // Get user info (GET to Google UserInfo endpoint)
    GoogleUserInfo userInfo = getUserInfo(accessToken);

    // Login hoặc Auto-register
    User user = userService.getUserByEmail(userInfo.email);
    if (user == null) {
        // Kiểm tra tài khoản bị vô hiệu hóa
        User existing = userService.getUserByEmailAny(userInfo.email);
        if (existing != null && !existing.isActive()) {
            // Block đăng nhập — tài khoản đã bị deactivate
            return;
        }
        userService.registerOAuth(userInfo.email, userInfo.name, userInfo.picture);
        user = userService.getUserByEmail(userInfo.email);
    }

    // Session fixation protection
    HttpSession oldSession = req.getSession(false);
    if (oldSession != null) oldSession.invalidate();
    HttpSession session = req.getSession(true);
    session.setAttribute("user", user);

    // Issue JWT tokens (persistent remember-me cho OAuth users)
    authTokenService.issueTokens(res, user, req, true);
}
```

**Bảo mật OAuth đáng chú ý:**
- **CSRF protection:** dùng `state` token (UUID random) lưu trong session
- **Session fixation prevention:** invalidate session cũ trước khi tạo mới
- **Deactivated account check:** kiểm tra cả active và deactivated users
- **No external JSON library:** sử dụng escape-aware JSON parser tự viết (tái sử dụng từ `JwtUtil`)

### 5.8.3 SePay/VietQR — Thanh toán chuyển khoản ngân hàng

Hệ thống thanh toán qua **chuyển khoản ngân hàng** sử dụng 2 component phối hợp:

#### SeepayProvider — Tạo QR thanh toán

`SeepayProvider` implement `PaymentProvider` interface (Strategy pattern), tạo mã QR VietQR:

```java
public class SeepayProvider implements PaymentProvider {
    // Cấu hình từ seepay.properties
    private String bankId = "MB";          // Mã ngân hàng
    private String accountNo = "039***";   // Số tài khoản
    private String accountName = "...";    // Tên chủ tài khoản

    @Override
    public PaymentResult initiatePayment(Order order) {
        String orderCode = order.getOrderCode();
        long amount = (long) order.getFinalAmount();

        // Tạo URL ảnh QR từ VietQR public API
        String qrUrl = String.format(
            "https://img.vietqr.io/image/%s-%s-%s.png?amount=%d&addInfo=%s&accountName=%s",
            bankId, accountNo, qrTemplate, amount,
            URLEncoder.encode(orderCode, "UTF-8"),
            URLEncoder.encode(accountName, "UTF-8")
        );

        return PaymentResult.pending("SP-" + orderCode, qrUrl,
            "Quét mã QR để chuyển khoản " + String.format("%,d", amount) + " VNĐ");
    }

    @Override
    public PaymentResult checkStatus(String txId) {
        // Trạng thái do IPN webhook quyết định, không polling
        return PaymentResult.pending(txId, null, "Đang chờ xác nhận");
    }

    @Override
    public boolean supportsRefund() { return false; } // Refund thủ công
}
```

#### SeepayWebhookServlet — IPN Endpoint với 3-Layer Idempotency

Khi khách chuyển khoản, SePay gửi POST đến `/api/seepay/webhook`. Servlet xử lý qua 7 bước với **3 lớp chống trùng lặp**:

```java
@WebServlet(urlPatterns = {"/api/seepay/webhook"})
public class SeepayWebhookServlet extends HttpServlet {

    private final Set<String> processedTransactions = ConcurrentHashMap.newKeySet();  // Layer 1
    private final Queue<String> processedTransactionOrder = new ConcurrentLinkedQueue<>();
    private SeepayWebhookDedupDAO dedupDAO;  // Layer 2

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res) {
        // Security: Verify SePay API Key
        String authHeader = req.getHeader("Authorization");
        if (!"Bearer " + seepayApiKey).equals(authHeader)) {
            res.setStatus(401); return;
        }

        // DoS protection: body size limit 64KB
        String body = readBodyLimited(req, 65_536);
        if (body == null) { res.setStatus(413); return; }

        // Step 1: Chỉ xử lý giao dịch tiền vào
        if (!"in".equalsIgnoreCase(extractJsonStringSafe(body, "transferType")))
            return;

        // Step 2: 3-layer idempotency check
        String sepayId = extractJsonStringSafe(body, "id");
        if (processedTransactions.contains(sepayId)     // Layer 1: in-memory
            || dedupDAO.isProcessed(sepayId))            // Layer 2: persistent DB
            return; // Duplicate → ignore

        // Step 3: Trích xuất order code từ nội dung chuyển khoản
        String orderCode = extractOrderCode(content);  // Regex: ORD-\d{10,15}-[A-Z0-9]{4,8}

        // Step 4: Tìm order trong DB
        Order order = orderService.getOrderByCode(orderCode);

        // Step 5: Layer 3 — Order-level dedup (skip nếu không pending)
        if (!"pending".equals(order.getStatus())) return;

        // Step 6: Verify amount (±1 VND rounding tolerance)
        long expected = (long) order.getFinalAmount();
        if (Math.abs(amount - expected) > 1) return;  // Amount mismatch

        // Step 7: Confirm payment + issue tickets
        boolean updated = orderService.confirmPayment(order.getOrderId(), txRef);
        if (updated) {
            orderService.issueTickets(order.getOrderId(),
                order.getBuyerName(), order.getBuyerEmail());
        }

        // Luôn trả 200 (tránh SePay retry storm)
        res.setStatus(200);
    }
}
```

**3-Layer Idempotency giải thích:**

| Layer | Cơ chế | Phạm vi | Mục đích |
|-------|--------|---------|----------|
| **1. In-memory** | `ConcurrentHashMap.newKeySet()` | JVM instance | Fast-path, ~O(1) lookup |
| **2. Persistent DB** | `SeepayWebhookDedupDAO` | Toàn hệ thống | Survive server restart |
| **3. Order status** | `order.getStatus() != "pending"` | Business logic | Chống race condition |

In-memory cache có **eviction policy** (tối đa 10,000 entries, FIFO) để tránh memory leak.

---

## 5.9 Dashboard Analytics — DashboardService

### 5.9.1 Kiến trúc Service Layer

`DashboardService` delegate sang `DashboardDAO` với error handling thống nhất qua `ServiceException`, cung cấp **14+ loại metrics** cho 3 đối tượng: Admin, Organizer, và Event-specific:

```java
public class DashboardService {
    private final DashboardDAO dashboardDAO;

    public DashboardService() { this.dashboardDAO = new DashboardDAO(); }

    // Admin-level stats
    public Map<String, Object> getAdminDashboardStats() { ... }
    public List<Map<String, Object>> getCategoryDistribution() { ... }
    public List<Map<String, Object>> getRevenueByDays(int days) { ... }
    public List<Map<String, Object>> getTopEventsByRevenue(int limit) { ... }
    public int getPendingEventsCount() { ... }

    // Dashboard 2.0 — Real-time metrics
    public List<Map<String, Object>> getEventStatusDistribution() { ... }
    public List<Map<String, Object>> getHourlyOrdersToday() { ... }
    public int getActiveUsersToday() { ... }
    public double getConversionRate() { ... }

    // Organizer-scoped stats
    public Map<String, Object> getOrganizerDashboardStats(int organizerId) { ... }
    public List<Map<String, Object>> getOrganizerEventStats(int organizerId) { ... }
    public List<Map<String, Object>> getOrganizerRevenueByDays(int organizerId, int days) { ... }
    public List<Map<String, Object>> getOrganizerTicketDistribution(int organizerId) { ... }
    public List<Map<String, Object>> getOrganizerHourlyDistribution(int organizerId) { ... }

    // Event-specific analytics
    public Map<String, Object> getEventSpecificStats(int eventId) { ... }
    public List<Map<String, Object>> getEventRevenueByDays(int eventId, int days) { ... }

    // Voucher settlement reports
    public Map<String, Object> getVoucherSettlementStats() { ... }
    public Map<String, Object> getOrganizerSettlementStats(int organizerId) { ... }
    public List<Map<String, Object>> getEventSettlementBreakdown(int limit) { ... }
}
```

**Error Handling Pattern:** Mỗi method wrap DAO call trong try-catch, ném `ServiceException` với error code chuẩn:

```java
public List<Map<String, Object>> getRevenueByDays(int days) {
    if (days <= 0 || days > 365) days = 7;  // Input sanitization
    try {
        return dashboardDAO.getRevenueByDays(days);
    } catch (Exception e) {
        LOGGER.log(Level.SEVERE, "Service error: getRevenueByDays", e);
        throw new ServiceException("DASHBOARD_ERROR", "Failed to load revenue data", e);
    }
}
```

### 5.9.2 Customer Tier — Loyalty Engine

`CustomerTierService` phân hạng khách hàng tự động dựa trên **tổng chi tiêu + số đơn hàng paid**:

```java
public class CustomerTierService extends DBContext {

    public static class TierInfo {
        public final String tier;
        public final int priorityScore;
        public final long totalSpent;
        public final int orderCount;
    }

    public TierInfo getTier(int userId) {
        String sql = "SELECT ISNULL(SUM(total_amount), 0) AS total_spent, "
                   + "COUNT(*) AS order_count "
                   + "FROM Orders WHERE user_id = ? AND status = 'paid'";
        // ... execute query ...
        return computeTier(totalSpent, orderCount);
    }

    private TierInfo computeTier(long totalSpent, int orderCount) {
        if (totalSpent >= 5_000_000)
            return new TierInfo("vip_special", 100, totalSpent, orderCount);
        if (orderCount >= 5 || totalSpent >= 2_000_000)
            return new TierInfo("vip", 80, totalSpent, orderCount);
        if (orderCount >= 1)
            return new TierInfo("regular", 50, totalSpent, orderCount);
        return new TierInfo("registered", 20, totalSpent, orderCount);
    }

    // UI helper methods — trả về label + CSS inline cho badge
    public static String getTierLabel(String tier) {
        switch (tier) {
            case "vip_special": return "💎 VIP Đặc biệt";
            case "vip":         return "🥇 VIP";
            case "regular":     return "🥈 Khách thường";
            case "registered":  return "🥉 Đã đăng ký";
            default:            return "👤 Khách";
        }
    }

    // Map tier → ticket priority cho voucher eligibility
    public static String tierToPriority(String tier) {
        switch (tier) {
            case "vip_special": return "urgent";
            case "vip":         return "high";
            case "regular":     return "normal";
            default:            return "low";
        }
    }
}
```

**Bảng phân hạng thực tế:**

| Hạng | Điều kiện | Priority | Badge |
|------|-----------|----------|-------|
| `vip_special` | Spending ≥ 5,000,000₫ | 100 | 💎 gradient vàng-cam |
| `vip` | ≥5 đơn paid HOẶC spending ≥ 2,000,000₫ | 80 | 🥇 gradient xanh-tím |
| `regular` | ≥1 đơn paid | 50 | 🥈 gradient xanh lá-cyan |
| `registered` | Có tài khoản, 0 đơn | 20 | 🥉 nền xám |
| `guest` | Chưa đăng nhập | 0 | 👤 mặc định |

**Điểm đặc biệt:** Tier tính realtime từ query trực tiếp (không cache), kết hợp **2 tiêu chí** (spending + order count) thay vì chỉ spending đơn thuần.

---

## 5.10 Tổng kết Design Patterns sử dụng

| Design Pattern | Vị trí áp dụng | Lợi ích |
|---------------|----------------|---------|
| **Template Method** | `BaseDAO` → 18 DAO con | Loại bỏ ~70% boilerplate JDBC |
| **Factory** | `PaymentFactory` | Tạo payment provider theo tên |
| **Strategy** | `PaymentProvider` interface | Dễ thêm provider mới (OCP) |
| **Proxy** | `DBContext.wrapConnection()` | Intercept `close()` cho connection pool |
| **Filter Chain** | 7 Servlet Filters | Defense in depth cho bảo mật |
| **MVC** | Servlet → Service → DAO → JSP | Separation of concerns |
| **DAO** | 18 DAO classes | Tách biệt logic DB khỏi business |
| **Singleton** | `DBContext` pool + `CloudinaryUtil` | Một instance duy nhất toàn app |
| **Builder** | `PageResult<T>` | Xây dựng kết quả phân trang |
| **Observer** | `NotificationService` | Gửi email khi thay đổi trạng thái |

**Tổng kết chương:** Hệ thống TicketBox được triển khai với kiến trúc rõ ràng, tận dụng tối đa các design patterns chuẩn công nghiệp trên nền tảng Java EE. Các điểm nổi bật bao gồm: (1) `BaseDAO` giảm 70% boilerplate code, (2) Connection pool tự xây dựng với JDK Proxy, (3) Security filter chain 7 lớp theo Defense in Depth, (4) JWT thuần Java không phụ thuộc thư viện ngoài, (5) Payment subsystem mở rộng dễ dàng qua Factory + Strategy, (6) Checkout flow toàn diện với anti-hoarding, voucher settlement, và webhook 3-layer idempotency, (7) Cloudinary CDN với Singleton wrapper + URL transformation tích hợp, và (8) Customer tier system phân hạng realtime theo 2 tiêu chí.
