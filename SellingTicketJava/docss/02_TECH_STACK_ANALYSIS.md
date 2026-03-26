# 02. Tech Stack Analysis

## Công nghệ đang dùng
- Java Web Servlet/JSP (Jakarta Servlet 6, JSP 3.1)
- JSTL taglib
- Bootstrap 5
- JavaScript thuần
- SQL Server
- JDBC
- BCrypt via `jbcrypt`
- JWT tự triển khai bằng HMAC-SHA256
- Cloudinary
- SeePay integration
- Google OAuth

## Dùng ở đâu
- Servlet: `/src/java/com/sellingticket/controller`
- JSP: `/src/webapp/*.jsp`
- Filter: `/src/java/com/sellingticket/filter`
- JDBC/SQL: DAO classes
- Cloudinary: `CloudinaryUtil`, `MediaService`, upload servlet
- JWT/Cookie: `JwtUtil`, `CookieUtil`, `AuthTokenService`
- Payment: `service/payment/*`

## Điểm mạnh
- Dễ hiểu cho người mới vì luồng rõ ràng.
- Tách `Controller/Service/DAO` khá rõ.
- Có sẵn nhiều lớp bảo vệ: CSRF, auth filter, security headers, login rate limit.
- Dùng BCrypt thay vì lưu plaintext.

## Điểm yếu
- Không phải Spring nên tự quản rất nhiều thứ.
- Một số logic quyền vẫn bị rải ở nhiều nơi.
- JWT/cookie/session cùng tồn tại nên dễ rối nếu chưa hiểu luồng.
- Một số chỗ vẫn cần kiểm tra ownership ở backend chặt hơn.

## Cơ hội tối ưu
- Chuẩn hóa authorization theo 1 middleware/pattern thống nhất.
- Tách DTO/request model thay vì dùng model trực tiếp.
- Thêm transaction/idempotency cho payment và ticket issuance nhiều hơn nữa.
- Chuẩn hóa output encoding ở JSP.

## File liên quan
- `/D:/GITHUB/PRJ301_GROUP4_SELLING_TICKET/SellingTicketJava/src/java/com/sellingticket/util/DBContext.java`
- `/D:/GITHUB/PRJ301_GROUP4_SELLING_TICKET/SellingTicketJava/src/java/com/sellingticket/util/PasswordUtil.java`
- `/D:/GITHUB/PRJ301_GROUP4_SELLING_TICKET/SellingTicketJava/src/java/com/sellingticket/util/JwtUtil.java`
- `/D:/GITHUB/PRJ301_GROUP4_SELLING_TICKET/SellingTicketJava/src/webapp/WEB-INF/web.xml`

## Tóm tắt dễ nhớ
Đây là Java Web “truyền thống”, không phải Spring. Cần hiểu Servlet/JSP/DAO/Filter là hiểu được 80% dự án.

## File nên mở tiếp theo
- `/D:/GITHUB/PRJ301_GROUP4_SELLING_TICKET/SellingTicketJava/docss/03_FOLDER_FILE_MAP.md`

## Điểm người mới hay nhầm
- Nghĩ rằng có JWT là hệ thống hoàn toàn stateless. Thực tế source vẫn giữ session server-side.
