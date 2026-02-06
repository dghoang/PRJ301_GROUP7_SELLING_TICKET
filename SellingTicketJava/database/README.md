# Database Setup Guide

## Yêu cầu
- SQL Server 2019 hoặc mới hơn
- Java 17+
- Apache Tomcat 10+ hoặc GlassFish

## Bước 1: Tạo Database

Mở SQL Server Management Studio và chạy file:
```
database/ticketbox_schema.sql
```

File này sẽ:
- Tạo database `SellingTicketDB`
- Tạo tất cả tables (Users, Events, Categories, TicketTypes, Orders, OrderItems, Tickets, Vouchers)
- Tạo indexes
- Insert dữ liệu mẫu (categories, users, events, ticket types)

## Bước 2: Cấu hình kết nối

Chỉnh sửa file `src/java/com/sellingticket/util/DBContext.java`:

```java
private static final String SERVER_NAME = "localhost";
private static final String DB_NAME = "SellingTicketDB";
private static final String PORT_NUMBER = "1433";
private static final String USER_ID = "sa";
private static final String PASSWORD = "your_password_here";
```

## Bước 3: Thêm thư viện

Các file JAR đã được download vào `src/webapp/WEB-INF/lib/`:
- `mssql-jdbc-12.4.2.jre11.jar` - SQL Server JDBC Driver
- `javax.servlet-api-4.0.1.jar` - Servlet API
- `javax.servlet.jsp-api-2.3.3.jar` - JSP API
- `jstl-1.2.jar` - JSTL

Trong NetBeans/IntelliJ, thêm các JAR này vào Libraries của project.

## Tài khoản mẫu

| Email | Password | Role |
|-------|----------|------|
| admin@ticketbox.vn | admin123 | Admin |
| organizer@ticketbox.vn | organizer123 | Organizer |
| customer@ticketbox.vn | customer123 | Customer |

## Kiểm tra kết nối

Chạy class `DBContext` với method `main()` để test kết nối:
```
java com.sellingticket.util.DBContext
```

Output: `Connection successful!` = Kết nối thành công.
