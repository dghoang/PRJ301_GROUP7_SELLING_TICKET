-- Database Schema for Selling Ticket System
-- Generated based on src/types/index.ts
-- Target: SQL Server

CREATE DATABASE SellingTicketDB;
GO

USE SellingTicketDB;
GO

-- ==========================================
-- 1. USERS & AUTHENTICATION
-- ==========================================

CREATE TABLE Users (
    user_id INT IDENTITY(1,1) PRIMARY KEY,
    email NVARCHAR(100) NOT NULL UNIQUE,
    password_hash NVARCHAR(255) NOT NULL, -- Storing hashed passwords
    full_name NVARCHAR(100) NOT NULL,
    phone NVARCHAR(20),
    date_of_birth DATE,
    gender NVARCHAR(10) CHECK (gender IN ('male', 'female', 'other')),
    avatar_url NVARCHAR(MAX),
    role NVARCHAR(20) CHECK (role IN ('customer', 'organizer', 'admin')) DEFAULT 'customer',
    is_verified BIT DEFAULT 0,
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME DEFAULT GETDATE()
);
GO

-- ==========================================
-- 2. ORGANIZERS
-- ==========================================

CREATE TABLE Organizers (
    organizer_id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT NOT NULL, -- Link to the owner user
    name NVARCHAR(100) NOT NULL,
    logo_url NVARCHAR(MAX),
    description NVARCHAR(MAX),
    email NVARCHAR(100),
    phone NVARCHAR(20),
    website NVARCHAR(255),
    is_verified BIT DEFAULT 0,
    status NVARCHAR(20) CHECK (status IN ('active', 'pending', 'suspended')) DEFAULT 'pending',
    total_events INT DEFAULT 0,
    total_revenue DECIMAL(18, 2) DEFAULT 0,
    created_at DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);
GO

-- ==========================================
-- 3. EVENTS
-- ==========================================

CREATE TABLE EventCategories (
    category_id INT IDENTITY(1,1) PRIMARY KEY,
    name NVARCHAR(100) NOT NULL,
    slug NVARCHAR(100) NOT NULL,
    icon_url NVARCHAR(MAX)
);
GO

CREATE TABLE Events (
    event_id INT IDENTITY(1,1) PRIMARY KEY,
    organizer_id INT NOT NULL,
    category_id INT NOT NULL,
    name NVARCHAR(255) NOT NULL,
    slug NVARCHAR(255) NOT NULL,
    description NVARCHAR(MAX),
    banner_image NVARCHAR(MAX),
    location_type NVARCHAR(20) CHECK (location_type IN ('online', 'offline')),
    venue_name NVARCHAR(255),
    address NVARCHAR(MAX),
    status NVARCHAR(20) CHECK (status IN ('draft', 'pending', 'approved', 'active', 'cancelled', 'completed')) DEFAULT 'draft',
    privacy NVARCHAR(20) CHECK (privacy IN ('public', 'private', 'unlisted')) DEFAULT 'public',
    created_at DATETIME DEFAULT GETDATE(),
    published_at DATETIME,
    FOREIGN KEY (organizer_id) REFERENCES Organizers(organizer_id),
    FOREIGN KEY (category_id) REFERENCES EventCategories(category_id)
);
GO

-- ==========================================
-- 4. TICKETS
-- ==========================================

CREATE TABLE TicketTypes (
    ticket_type_id INT IDENTITY(1,1) PRIMARY KEY,
    event_id INT NOT NULL,
    name NVARCHAR(100) NOT NULL,
    price DECIMAL(18, 2) NOT NULL,
    original_price DECIMAL(18, 2),
    quantity INT NOT NULL,
    sold_quantity INT DEFAULT 0,
    sale_start_time DATETIME,
    sale_end_time DATETIME,
    status NVARCHAR(20) CHECK (status IN ('available', 'sold_out', 'hidden', 'expired')) DEFAULT 'available',
    FOREIGN KEY (event_id) REFERENCES Events(event_id)
);
GO

-- ==========================================
-- 5. ORDERS & PAYMENTS
-- ==========================================

CREATE TABLE Orders (
    order_id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT NOT NULL,
    event_id INT NOT NULL,
    order_number NVARCHAR(50) NOT NULL UNIQUE, -- e.g., ORD-2023-001
    total_amount DECIMAL(18, 2) NOT NULL,
    discount DECIMAL(18, 2) DEFAULT 0,
    payment_method NVARCHAR(50) CHECK (payment_method IN ('bank_transfer', 'credit_card', 'momo', 'zalopay', 'vnpay')),
    payment_status NVARCHAR(20) CHECK (payment_status IN ('pending', 'processing', 'completed', 'failed', 'refunded')) DEFAULT 'pending',
    status NVARCHAR(20) CHECK (status IN ('pending', 'processing', 'paid', 'confirmed', 'cancelled', 'refunded')) DEFAULT 'pending',
    created_at DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (user_id) REFERENCES Users(user_id),
    FOREIGN KEY (event_id) REFERENCES Events(event_id)
);
GO

CREATE TABLE OrderItems (
    order_item_id INT IDENTITY(1,1) PRIMARY KEY,
    order_id INT NOT NULL,
    ticket_type_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(18, 2) NOT NULL,
    total_price DECIMAL(18, 2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES Orders(order_id),
    FOREIGN KEY (ticket_type_id) REFERENCES TicketTypes(ticket_type_id)
);
GO

-- ==========================================
-- 6. ISSUED TICKETS (Actual tickets generated after order)
-- ==========================================

CREATE TABLE Tickets (
    ticket_id INT IDENTITY(1,1) PRIMARY KEY,
    order_id INT NOT NULL,
    ticket_type_id INT NOT NULL,
    event_id INT NOT NULL,
    user_id INT NOT NULL, -- Owner of the ticket
    ticket_code NVARCHAR(100) NOT NULL UNIQUE,
    status NVARCHAR(20) CHECK (status IN ('valid', 'used', 'cancelled', 'expired')) DEFAULT 'valid',
    created_at DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (order_id) REFERENCES Orders(order_id),
    FOREIGN KEY (ticket_type_id) REFERENCES TicketTypes(ticket_type_id),
    FOREIGN KEY (event_id) REFERENCES Events(event_id),
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);
GO

-- ==========================================
-- 7. SEED DATA (Optional - for testing)
-- ==========================================
INSERT INTO EventCategories (name, slug) VALUES ('Music', 'music'), ('Arts', 'arts'), ('Business', 'business');
