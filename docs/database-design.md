# Ticketbox - Database Design (ERD)

## Entity Relationship Diagram

```
┌─────────────────┐       ┌─────────────────┐       ┌─────────────────┐
│     USERS       │       │   ORGANIZERS    │       │ EVENT_CATEGORIES│
├─────────────────┤       ├─────────────────┤       ├─────────────────┤
│ PK user_id      │       │ PK organizer_id │       │ PK category_id  │
│    email        │       │ FK user_id      │───────│    name         │
│    password_hash│       │    company_name │       │    icon         │
│    full_name    │       │    description  │       │    description  │
│    phone        │       │    logo         │       └─────────────────┘
│    role         │       │    status       │              │
│    created_at   │       └─────────────────┘              │
└─────────────────┘              │                         │
        │                        │                         │
        │                        ▼                         │
        │                ┌─────────────────┐               │
        │                │     EVENTS      │               │
        │                ├─────────────────┤               │
        │                │ PK event_id     │               │
        │                │ FK organizer_id │◄──────────────┘
        │                │ FK category_id  │
        │                │    title        │
        │                │    description  │
        │                │    banner_image │
        │                │    location     │
        │                │    address      │
        │                │    start_date   │
        │                │    end_date     │
        │                │    status       │
        │                │    is_private   │
        │                │    access_code  │
        │                └─────────────────┘
        │                        │
        │                        │ 1:N
        │                        ▼
        │                ┌─────────────────┐
        │                │  TICKET_TYPES   │
        │                ├─────────────────┤
        │                │ PK ticket_type_id│
        │                │ FK event_id     │
        │                │    name         │
        │                │    description  │
        │                │    price        │
        │                │    quantity     │
        │                │    max_per_order│
        │                └─────────────────┘
        │                        │
        │                        │ 1:N
        ▼                        ▼
┌─────────────────┐       ┌─────────────────┐
│     ORDERS      │       │   ORDER_ITEMS   │
├─────────────────┤       ├─────────────────┤
│ PK order_id     │◄─────│ FK order_id     │
│ FK user_id      │       │ FK ticket_type_id│
│    order_code   │       │    quantity     │
│    total_amount │       │    unit_price   │
│    status       │       │    subtotal     │
│    payment_method│      └─────────────────┘
│    created_at   │              │
└─────────────────┘              │
        │                        │ 1:N
        │                        ▼
        │                ┌─────────────────┐
        │                │    TICKETS      │
        │                ├─────────────────┤
        │                │ PK ticket_id    │
        │                │ FK order_item_id│
        │                │    ticket_code  │
        │                │    qr_code      │
        │                │    status       │
        │                │    checked_in_at│
        │                └─────────────────┘
```

---

## Table Definitions

### 1. Users
```sql
CREATE TABLE Users (
    user_id INT IDENTITY(1,1) PRIMARY KEY,
    email NVARCHAR(255) NOT NULL UNIQUE,
    password_hash NVARCHAR(255) NOT NULL,
    full_name NVARCHAR(100) NOT NULL,
    phone NVARCHAR(20),
    role NVARCHAR(20) DEFAULT 'customer', -- customer, organizer, admin
    avatar NVARCHAR(500),
    created_at DATETIME DEFAULT GETDATE()
);
```

### 2. Organizers
```sql
CREATE TABLE Organizers (
    organizer_id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT FOREIGN KEY REFERENCES Users(user_id),
    company_name NVARCHAR(255) NOT NULL,
    description NVARCHAR(MAX),
    logo NVARCHAR(500),
    status NVARCHAR(20) DEFAULT 'pending' -- pending, approved, rejected
);
```

### 3. EventCategories
```sql
CREATE TABLE EventCategories (
    category_id INT IDENTITY(1,1) PRIMARY KEY,
    name NVARCHAR(100) NOT NULL,
    icon NVARCHAR(50),
    description NVARCHAR(255)
);
```

### 4. Events
```sql
CREATE TABLE Events (
    event_id INT IDENTITY(1,1) PRIMARY KEY,
    organizer_id INT FOREIGN KEY REFERENCES Organizers(organizer_id),
    category_id INT FOREIGN KEY REFERENCES EventCategories(category_id),
    title NVARCHAR(255) NOT NULL,
    description NVARCHAR(MAX),
    banner_image NVARCHAR(500),
    location NVARCHAR(255),
    address NVARCHAR(500),
    start_date DATETIME NOT NULL,
    end_date DATETIME,
    status NVARCHAR(20) DEFAULT 'draft', -- draft, pending, approved, cancelled
    is_private BIT DEFAULT 0,
    access_code NVARCHAR(50),
    created_at DATETIME DEFAULT GETDATE()
);
```

### 5. TicketTypes
```sql
CREATE TABLE TicketTypes (
    ticket_type_id INT IDENTITY(1,1) PRIMARY KEY,
    event_id INT FOREIGN KEY REFERENCES Events(event_id),
    name NVARCHAR(100) NOT NULL,
    description NVARCHAR(255),
    price DECIMAL(12,2) NOT NULL,
    quantity INT NOT NULL,
    max_per_order INT DEFAULT 10
);
```

### 6. Orders
```sql
CREATE TABLE Orders (
    order_id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT FOREIGN KEY REFERENCES Users(user_id),
    order_code NVARCHAR(20) NOT NULL UNIQUE,
    total_amount DECIMAL(12,2) NOT NULL,
    status NVARCHAR(20) DEFAULT 'pending', -- pending, paid, cancelled, refunded
    payment_method NVARCHAR(50),
    created_at DATETIME DEFAULT GETDATE()
);
```

### 7. OrderItems
```sql
CREATE TABLE OrderItems (
    order_item_id INT IDENTITY(1,1) PRIMARY KEY,
    order_id INT FOREIGN KEY REFERENCES Orders(order_id),
    ticket_type_id INT FOREIGN KEY REFERENCES TicketTypes(ticket_type_id),
    quantity INT NOT NULL,
    unit_price DECIMAL(12,2) NOT NULL,
    subtotal DECIMAL(12,2) NOT NULL
);
```

### 8. Tickets
```sql
CREATE TABLE Tickets (
    ticket_id INT IDENTITY(1,1) PRIMARY KEY,
    order_item_id INT FOREIGN KEY REFERENCES OrderItems(order_item_id),
    ticket_code NVARCHAR(20) NOT NULL UNIQUE,
    qr_code NVARCHAR(500),
    status NVARCHAR(20) DEFAULT 'valid', -- valid, used, cancelled
    checked_in_at DATETIME
);
```
