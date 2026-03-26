# 11. Security Review

## Tốt đang có
- BCrypt cho password
- PreparedStatement nhiều nơi
- HttpOnly + SameSite cookie cho auth token
- CSRF filter
- Security headers filter
- Session fixation protection
- Login rate limiting
- Constant-time-ish delay cho login

## Vấn đề / rủi ro
### 1. Broken access control / IDOR
- Nhiều controller dùng `orderId`, `eventId`, `userId` từ request.
- Nếu một endpoint nào đó quên check ownership, có thể lộ dữ liệu.
- File cần soi kỹ tiếp: các API `api/*`, admin support, event detail, order detail.

### 2. XSS
- `description`, `notes`, `reason`, `bio` có thể chứa HTML/text từ user.
- JSP cần encode output cẩn thận.
- Event description còn là HTML rich content, nên phải kiểm soát whitelist.

### 3. CSRF
- Có filter, nhưng cần đảm bảo mọi form/POST đều đi qua token/header hợp lệ.

### 4. Upload file
- `MediaService` kiểm tra MIME/size, nhưng vẫn nên kiểm tra thêm content sniffing và ownership.

### 5. Secrets
- Có file `db.properties`, `google-oauth.properties`, `seepay.properties`, `cloudinary.properties`.
- Cần chắc chắn không commit secret thật.

### 6. Password reset / OTP
- Đã thấy bảng `PasswordResets`, nhưng chưa đọc đủ luồng triển khai trong source đã mở.
- Hiện trạng: `chưa xác định được từ source hiện tại`.

### 7. Audit
- Có `ActivityLog`, nhưng không phải mọi hành động nhạy cảm đều thấy ghi log ở phần đã đọc.

## Mức độ nguy hiểm
- Cao: SQLi, broken access control, overselling, webhook replay
- Trung bình: XSS, CSRF, upload abuse, info disclosure

## Tóm tắt dễ nhớ
Phần mạnh nhất là auth cơ bản và payment atomic, nhưng vẫn cần soi sâu access control và XSS/output encoding.

## File nên mở tiếp theo
- `/D:/GITHUB/PRJ301_GROUP4_SELLING_TICKET/SellingTicketJava/docss/12_CONCURRENCY_TICKET_LOCKING.md`

## Điểm người mới hay nhầm
- Thấy có filter là nghĩ an toàn tuyệt đối. Thực tế vẫn phải kiểm tra quyền ở controller/DAO quan trọng.
