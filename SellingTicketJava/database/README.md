# Database Setup Guide

## Cau truc thu muc

```
database/
	README.md
	schema/
		ticketbox_schema.sql
		full_reset_seed.sql
	migrations/
		migration_*.sql
		fix_roles.sql
	seeds/
		mock_data.sql
		seed_orders_tickets.sql
		support_tickets.sql
		event_staff.sql
```

## Cach khoi tao nhanh (khuyen dung)

Chay file:

```
database/schema/full_reset_seed.sql
```

File nay se:
- Tao lai database `SellingTicketDB`
- Tao day du 21 bang
- Tao indexes
- Seed du lieu phong phu cho test (users, events, tickets, orders, vouchers, support, chat, media, settings)

## Cach khoi tao toi gian

Neu ban chi muon schema co ban, chay:

```
database/schema/ticketbox_schema.sql
```

Sau do co the chay them cac file trong `database/migrations/` va `database/seeds/` theo nhu cau.

## Cau hinh ket noi

Chinh sua file `src/java/com/sellingticket/util/DBContext.java`:

```java
private static final String SERVER_NAME = "localhost";
private static final String DB_NAME = "SellingTicketDB";
private static final String PORT_NUMBER = "1433";
private static final String USER_ID = "sa";
private static final String PASSWORD = "your_password_here";
```

## Tai khoan mau chinh

| Email | Password | Role |
|-------|----------|------|
| admin@ticketbox.vn | Admin@123 | Admin |
| support@ticketbox.vn | Admin@123 | Support Agent |
| organizer@ticketbox.vn | Organizer@123 | Organizer |
| customer@ticketbox.vn | Customer@123 | Customer |

## Kiem tra ket noi

Chay class `DBContext` voi method `main()`:

```
java com.sellingticket.util.DBContext
```

Output `Connection successful!` la ket noi thanh cong.
