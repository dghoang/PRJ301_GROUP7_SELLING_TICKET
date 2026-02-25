# API Reference — Servlet Endpoint Docs

> **SellingTicket** — Jakarta Servlet 6.0 Web Application  
> Base URL: `http://localhost:8080/{contextPath}`

---

## Table of Contents

1. [Public Endpoints](#1-public-endpoints)
2. [Authentication Endpoints](#2-authentication-endpoints)
3. [Customer Endpoints](#3-customer-endpoints--requires-login)
4. [Organizer Endpoints](#4-organizer-endpoints--role-organizer)
5. [Admin Endpoints](#5-admin-endpoints--role-admin)
6. [Data Models](#6-data-models)
7. [Architecture](#7-architecture-overview)

---

## 1. Public Endpoints

### `GET /home`
**Servlet**: `HomeServlet`  
**Description**: Homepage with featured and upcoming events

| Attribute Set | Type | Content |
|--------------|------|---------|
| `featuredEvents` | `List<Event>` | Top featured events (limit varies) |
| `upcomingEvents` | `List<Event>` | Upcoming events sorted by date |
| `categories` | `List<Category>` | All event categories |

**View**: `home.jsp`

---

### `GET /events`
**Servlet**: `EventsServlet`  
**Description**: Browse and search events with filters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `keyword` | string | ❌ | Search by event title |
| `category` | string | ❌ | Filter by category slug |
| `date` | string | ❌ | Date filter (e.g., "this-week", "this-month") |
| `page` | int | ❌ | Page number (default: 1) |

| Attribute Set | Type |
|--------------|------|
| `events` | `List<Event>` |
| `categories` | `List<Category>` |
| `keyword`, `category`, `date` | Search params echoed back |

**View**: `events.jsp`

---

### `GET /event-detail`
**Servlet**: `EventDetailServlet`  
**Description**: Single event detail with ticket types

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | int | ✅ | Event ID |

| Attribute Set | Type |
|--------------|------|
| `event` | `Event` (with `ticketTypes` populated) |
| `relatedEvents` | `List<Event>` |

**Side effect**: Increments event view counter  
**View**: `event-detail.jsp`

---

### `GET /about`, `GET /contact`, `GET /faq`
**Servlet**: `StaticPagesServlet`  
**Description**: Static information pages  
**Views**: `about.jsp`, `contact.jsp`, `faq.jsp`

---

## 2. Authentication Endpoints

### `GET /login`
**Servlet**: `LoginServlet`  
**Description**: Display login form  
**View**: `login.jsp`

---

### `POST /login`
**Servlet**: `LoginServlet`  
**Description**: Authenticate user

| Parameter | Type | Required |
|-----------|------|----------|
| `email` | string | ✅ |
| `password` | string | ✅ |
| `redirect` | string | ❌ |

| Result | Action |
|--------|--------|
| ✅ Success | Set `session.account` → Redirect to `redirect` param or `/home` |
| ❌ Failure | Forward `login.jsp` with `error` attribute |

---

### `GET /register`
**Servlet**: `RegisterServlet`  
**Description**: Display registration form  
**View**: `register.jsp`

---

### `POST /register`
**Servlet**: `RegisterServlet`  
**Description**: Create new user account

| Parameter | Type | Required |
|-----------|------|----------|
| `fullName` | string | ✅ |
| `email` | string | ✅ |
| `phone` | string | ✅ |
| `birthDate` | string (yyyy-MM-dd) | ✅ |
| `gender` | string | ✅ |
| `password` | string | ✅ |
| `confirmPassword` | string | ✅ |

| Result | Action |
|--------|--------|
| ✅ Success | Redirect `login.jsp?registered=true` |
| ❌ Password mismatch | Forward error: "Mật khẩu không khớp!" |
| ❌ Email exists | Forward error: "Email đã tồn tại!" |

---

### `GET /logout`
**Servlet**: `LogoutServlet`  
**Description**: Invalidate session and redirect to `/home`

---

## 3. Customer Endpoints 🔒 (Requires Login)

### `GET /tickets`
**Servlet**: `TicketSelectionServlet`  
**Auth**: Any logged-in user

| Parameter | Type | Required |
|-----------|------|----------|
| `eventId` | int | ✅ |

| Attribute Set | Type |
|--------------|------|
| `event` | `Event` |
| `ticketTypes` | `List<TicketType>` |

**View**: `ticket-selection.jsp`

---

### `GET /checkout`
**Servlet**: `CheckoutServlet`  
**Auth**: Any logged-in user

| Parameter | Type | Required |
|-----------|------|----------|
| `eventId` | int | ✅ |
| `ticketTypeId` | int | ❌ |
| `quantity` | int | ❌ (default: 1) |

**View**: `checkout.jsp` (pre-filled with event/ticket/user data)

---

### `POST /checkout`
**Servlet**: `CheckoutServlet`  
**Auth**: Any logged-in user  
**Description**: Submit order

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `eventId` | int | ✅ | |
| `ticketTypeId` | int | ✅ | |
| `quantity` | int | ✅ | |
| `paymentMethod` | string | ✅ | `bank_transfer` \| `cash` \| `vnpay` \| `momo` |
| `buyerName` | string | ❌ | Defaults to user fullName |
| `buyerEmail` | string | ❌ | Defaults to user email |
| `buyerPhone` | string | ❌ | Defaults to user phone |
| `notes` | string | ❌ | |
| `voucherCode` | string | ❌ | (Not yet implemented) |

| Result | Redirect |
|--------|----------|
| ✅ bank/cash | `/order-confirmation?id={orderId}` |
| ✅ vnpay/momo | `/order-confirmation?id={orderId}&paid=true` |
| ❌ Error | Re-display checkout form with error message |

---

### `GET /order-confirmation`
**Servlet**: `OrderConfirmationServlet`  
**Auth**: Any logged-in user

| Parameter | Type | Required |
|-----------|------|----------|
| `id` | int | ✅ |

**View**: `order-confirmation.jsp`

---

### `GET /profile`
**Servlet**: `ProfileServlet`  
**Auth**: Any logged-in user  
**View**: `profile.jsp`

---

## 4. Organizer Endpoints 🔒 (Role: organizer)

### Events Management

| Method | URL | Action |
|--------|-----|--------|
| GET | `/organizer/events` | List organizer's events |
| GET | `/organizer/events/{id}` | View event detail (ownership verified) |
| GET | `/organizer/events/{id}/edit` | Edit event form |
| GET | `/organizer/create-event` | Create event form |
| POST | `/organizer/create-event` | Submit new event |
| POST | `/organizer/events/update` | Update event |
| POST | `/organizer/events/delete` | Delete event (soft) |

#### `POST /organizer/create-event` — Create Event

| Parameter | Type | Required |
|-----------|------|----------|
| `categoryId` | int | ✅ |
| `title` | string | ✅ |
| `description` | string | ✅ |
| `bannerImage` | string (URL) | ❌ |
| `location` | string | ✅ |
| `address` | string | ✅ |
| `startDate` | string (yyyy-MM-dd'T'HH:mm) | ✅ |
| `endDate` | string | ❌ |
| `isPrivate` | checkbox ("on") | ❌ |
| `ticketName[]` | string[] | ✅ |
| `ticketPrice[]` | double[] | ✅ |
| `ticketQuantity[]` | int[] | ✅ |

> [!NOTE]
> New events are created with `status = "pending"` and require admin approval.

---

### Orders Management

| Method | URL | Action |
|--------|-----|--------|
| GET | `/organizer/orders` | List all orders (with optional `eventId` filter) |
| GET | `/organizer/orders/{eventId}` | View orders for specific event |
| POST | `/organizer/orders/confirm-payment` | Confirm payment (`orderId`, `eventId`) |
| POST | `/organizer/orders/cancel` | Cancel order (`orderId`, `eventId`) |

---

### Dashboard

| Method | URL | Action |
|--------|-----|--------|
| GET | `/organizer` or `/organizer/dashboard` | Dashboard with statistics |

---

## 5. Admin Endpoints 🔒 (Role: admin)

### Dashboard

| Method | URL | Description |
|--------|-----|-------------|
| GET | `/admin` or `/admin/dashboard` | Admin dashboard |

| Attribute Set | Type | Description |
|--------------|------|-------------|
| `totalEvents` | int | Total approved events |
| `pendingEvents` | int | Events awaiting approval |
| `totalUsers` | int | Total registered users |
| `totalRevenue` | double | Total revenue (paid orders) |
| `pendingOrders` | int | Pending order count |
| `paidOrders` | int | Paid order count |
| `pendingEventsList` | `List<Event>` | Recent pending events |

---

### Event Management

| Method | URL | Action |
|--------|-----|--------|
| GET | `/admin/events` | List all events (filterable by `status`, paginated by `page`) |
| GET | `/admin/events/pending` | List pending events only |
| GET | `/admin/events/{id}` | Event detail view |
| POST | `/admin/events/approve` | Approve event (`eventId`) |
| POST | `/admin/events/reject` | Reject event (`eventId`) |
| POST | `/admin/events/delete` | Delete event (`eventId`) |
| POST | `/admin/events/feature` | Toggle featured (`eventId`, `featured=true/false`) |

---

### User Management

| Method | URL | Action |
|--------|-----|--------|
| GET | `/admin/users` | List all users |
| GET | `/admin/users/search` | Search users (`q` parameter) |
| GET | `/admin/users/{id}` | User detail view |
| POST | `/admin/users/update-role` | Change role (`userId`, `role=customer/organizer/admin`) |
| POST | `/admin/users/deactivate` | Soft-delete user (`userId`) |

---

### Category Management

| Method | URL | Action |
|--------|-----|--------|
| GET | `/admin/categories` | List all categories |
| GET | `/admin/categories/edit?edit={id}` | List + edit modal for specific category |
| POST | `/admin/categories/create` | Create category (`name`, `icon`, `description`) |
| POST | `/admin/categories/update` | Update category (`categoryId`, `name`, `slug`, `icon`, `description`) |
| POST | `/admin/categories/delete` | Delete category (`categoryId`) — fails if events exist |

---

## 6. Data Models

### User

| Field | Type | Description |
|-------|------|-------------|
| `userId` | int | PK, auto-increment |
| `email` | string | Unique, used for login |
| `passwordHash` | string | BCrypt hash (cost 12) |
| `fullName` | string | Display name |
| `phone` | string | Contact number |
| `role` | string | `customer` \| `organizer` \| `admin` |
| `avatar` | string | Avatar URL (Cloudinary) |
| `isActive` | boolean | Soft-delete flag |
| `createdAt` | Date | Account creation timestamp |

### Event

| Field | Type | Description |
|-------|------|-------------|
| `eventId` | int | PK |
| `organizerId` | int | FK → Users |
| `categoryId` | int | FK → Categories |
| `title` | string | Event name |
| `slug` | string | URL-friendly identifier |
| `description` | string | Rich HTML description |
| `bannerImage` | string | Banner URL |
| `location` | string | Venue name |
| `address` | string | Full address |
| `startDate` | Date | Event start |
| `endDate` | Date | Event end |
| `status` | string | `pending` \| `approved` \| `rejected` |
| `isFeatured` | boolean | Featured on homepage |
| `views` | int | View counter |

### TicketType

| Field | Type | Description |
|-------|------|-------------|
| `ticketTypeId` | int | PK |
| `eventId` | int | FK → Events |
| `name` | string | Tier name (VIP, Standard, etc.) |
| `price` | double | Unit price (VND) |
| `quantity` | int | Total inventory |
| `soldQuantity` | int | Tickets sold |
| `saleStart` | Date | Sale window start |
| `saleEnd` | Date | Sale window end |

### Order

| Field | Type | Description |
|-------|------|-------------|
| `orderId` | int | PK |
| `orderCode` | string | Unique code (`ORD-{ts}-{rand}`) |
| `userId` | int | FK → Users (buyer) |
| `eventId` | int | FK → Events |
| `totalAmount` | double | Pre-discount total |
| `discountAmount` | double | Discount applied |
| `finalAmount` | double | Amount to pay |
| `status` | string | `pending` \| `paid` \| `cancelled` \| `refund_requested` \| `refunded` |
| `paymentMethod` | string | `bank_transfer` \| `cash` \| `vnpay` \| `momo` |

### Category

| Field | Type | Description |
|-------|------|-------------|
| `categoryId` | int | PK |
| `name` | string | Category name |
| `slug` | string | URL-friendly identifier |
| `icon` | string | Icon class/path |
| `description` | string | Category description |

---

## 7. Architecture Overview

```
com.sellingticket/
├── controller/                   # Servlet Layer (HTTP handling)
│   ├── HomeServlet.java
│   ├── EventsServlet.java
│   ├── EventDetailServlet.java
│   ├── LoginServlet.java
│   ├── RegisterServlet.java
│   ├── LogoutServlet.java
│   ├── CheckoutServlet.java
│   ├── TicketSelectionServlet.java
│   ├── OrderConfirmationServlet.java
│   ├── ProfileServlet.java
│   ├── StaticPagesServlet.java
│   ├── admin/                    # Admin controllers
│   │   ├── AdminDashboardController.java
│   │   ├── AdminEventController.java
│   │   ├── AdminUserController.java
│   │   └── AdminCategoryController.java
│   └── organizer/                # Organizer controllers
│       ├── OrganizerDashboardController.java
│       ├── OrganizerEventController.java
│       └── OrganizerOrderController.java
├── service/                      # Business Logic Layer
│   ├── UserService.java
│   ├── EventService.java
│   ├── OrderService.java
│   ├── TicketService.java
│   └── CategoryService.java
├── dao/                          # Data Access Layer (JDBC)
│   ├── UserDAO.java
│   ├── EventDAO.java
│   ├── OrderDAO.java
│   ├── TicketTypeDAO.java
│   └── CategoryDAO.java
├── model/                        # POJO Models
│   ├── User.java
│   ├── Event.java
│   ├── Order.java
│   ├── OrderItem.java
│   ├── TicketType.java
│   └── Category.java
├── filter/                       # Servlet Filters
│   └── AuthFilter.java
└── util/                         # Utilities
    ├── DBContext.java
    └── PasswordUtil.java
```

### Request Flow

```
Browser → AuthFilter → Servlet (Controller) → Service → DAO → SQL Server
                                                              ↕
                                                         Model (POJO)
```
