-- =============================================
-- TICKETBOX DATABASE SCHEMA
-- SQL Server Database for Ticket Selling System
-- PRJ301 Final Project - Group 4
-- =============================================

-- Create Database
USE master;
GO
IF EXISTS (SELECT name FROM sys.databases WHERE name = 'SellingTicketDB')
    DROP DATABASE SellingTicketDB;
GO
CREATE DATABASE SellingTicketDB;
GO
USE SellingTicketDB;
GO

-- =============================================
-- 1. USERS TABLE
-- =============================================
CREATE TABLE Users (
    user_id INT IDENTITY(1,1) PRIMARY KEY,
    email NVARCHAR(255) NOT NULL UNIQUE,
    password_hash NVARCHAR(255) NOT NULL,
    full_name NVARCHAR(100) NOT NULL,
    phone NVARCHAR(20),
    role NVARCHAR(20) DEFAULT 'customer' CHECK (role IN ('customer', 'organizer', 'admin')),
    avatar NVARCHAR(500),
    is_active BIT DEFAULT 1,
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME DEFAULT GETDATE()
);

-- =============================================
-- 2. CATEGORIES TABLE
-- =============================================
CREATE TABLE Categories (
    category_id INT IDENTITY(1,1) PRIMARY KEY,
    name NVARCHAR(100) NOT NULL,
    slug NVARCHAR(100) NOT NULL UNIQUE,
    icon NVARCHAR(50),
    description NVARCHAR(500),
    created_at DATETIME DEFAULT GETDATE()
);

-- =============================================
-- 3. EVENTS TABLE
-- =============================================
CREATE TABLE Events (
    event_id INT IDENTITY(1,1) PRIMARY KEY,
    organizer_id INT NOT NULL,
    category_id INT NOT NULL,
    title NVARCHAR(255) NOT NULL,
    slug NVARCHAR(255) NOT NULL UNIQUE,
    description NVARCHAR(MAX),
    banner_image NVARCHAR(500),
    location NVARCHAR(255),
    address NVARCHAR(500),
    start_date DATETIME NOT NULL,
    end_date DATETIME,
    status NVARCHAR(20) DEFAULT 'draft' CHECK (status IN ('draft', 'pending', 'approved', 'rejected', 'cancelled', 'completed')),
    is_featured BIT DEFAULT 0,
    is_private BIT DEFAULT 0,
    views INT DEFAULT 0,
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (organizer_id) REFERENCES Users(user_id),
    FOREIGN KEY (category_id) REFERENCES Categories(category_id)
);

-- =============================================
-- 4. TICKET TYPES TABLE
-- =============================================
CREATE TABLE TicketTypes (
    ticket_type_id INT IDENTITY(1,1) PRIMARY KEY,
    event_id INT NOT NULL,
    name NVARCHAR(100) NOT NULL,
    description NVARCHAR(500),
    price DECIMAL(18,2) NOT NULL,
    quantity INT NOT NULL,
    sold_quantity INT DEFAULT 0,
    sale_start DATETIME,
    sale_end DATETIME,
    is_active BIT DEFAULT 1,
    created_at DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (event_id) REFERENCES Events(event_id) ON DELETE CASCADE
);

-- =============================================
-- 5. ORDERS TABLE
-- =============================================
CREATE TABLE Orders (
    order_id INT IDENTITY(1,1) PRIMARY KEY,
    order_code NVARCHAR(50) NOT NULL UNIQUE,
    user_id INT NOT NULL,
    event_id INT NOT NULL,
    total_amount DECIMAL(18,2) NOT NULL,
    discount_amount DECIMAL(18,2) DEFAULT 0,
    final_amount DECIMAL(18,2) NOT NULL,
    status NVARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'paid', 'cancelled', 'refunded')),
    payment_method NVARCHAR(50),
    payment_date DATETIME,
    buyer_name NVARCHAR(100),
    buyer_email NVARCHAR(255),
    buyer_phone NVARCHAR(20),
    notes NVARCHAR(500),
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (user_id) REFERENCES Users(user_id),
    FOREIGN KEY (event_id) REFERENCES Events(event_id)
);

-- =============================================
-- 6. ORDER ITEMS TABLE
-- =============================================
CREATE TABLE OrderItems (
    order_item_id INT IDENTITY(1,1) PRIMARY KEY,
    order_id INT NOT NULL,
    ticket_type_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(18,2) NOT NULL,
    subtotal DECIMAL(18,2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES Orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (ticket_type_id) REFERENCES TicketTypes(ticket_type_id)
);

-- =============================================
-- 7. TICKETS TABLE (Actual tickets issued)
-- =============================================
CREATE TABLE Tickets (
    ticket_id INT IDENTITY(1,1) PRIMARY KEY,
    ticket_code NVARCHAR(50) NOT NULL UNIQUE,
    order_item_id INT NOT NULL,
    attendee_name NVARCHAR(100),
    attendee_email NVARCHAR(255),
    qr_code NVARCHAR(500),
    is_checked_in BIT DEFAULT 0,
    checked_in_at DATETIME,
    checked_in_by INT,
    created_at DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (order_item_id) REFERENCES OrderItems(order_item_id) ON DELETE CASCADE,
    FOREIGN KEY (checked_in_by) REFERENCES Users(user_id)
);

-- =============================================
-- 8. VOUCHERS TABLE
-- =============================================
CREATE TABLE Vouchers (
    voucher_id INT IDENTITY(1,1) PRIMARY KEY,
    organizer_id INT NOT NULL,
    event_id INT,
    code NVARCHAR(50) NOT NULL UNIQUE,
    discount_type NVARCHAR(20) CHECK (discount_type IN ('percentage', 'fixed')),
    discount_value DECIMAL(18,2) NOT NULL,
    min_order_amount DECIMAL(18,2) DEFAULT 0,
    max_uses INT,
    used_count INT DEFAULT 0,
    start_date DATETIME,
    end_date DATETIME,
    is_active BIT DEFAULT 1,
    created_at DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (organizer_id) REFERENCES Users(user_id),
    FOREIGN KEY (event_id) REFERENCES Events(event_id)
);

-- =============================================
-- 9. VOUCHER USAGE TABLE
-- =============================================
CREATE TABLE VoucherUsages (
    usage_id INT IDENTITY(1,1) PRIMARY KEY,
    voucher_id INT NOT NULL,
    order_id INT NOT NULL,
    discount_applied DECIMAL(18,2) NOT NULL,
    used_at DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (voucher_id) REFERENCES Vouchers(voucher_id),
    FOREIGN KEY (order_id) REFERENCES Orders(order_id)
);

-- =============================================
-- CREATE INDEXES
-- =============================================
CREATE INDEX IX_Events_OrganizerID ON Events(organizer_id);
CREATE INDEX IX_Events_CategoryID ON Events(category_id);
CREATE INDEX IX_Events_Status ON Events(status);
CREATE INDEX IX_Events_StartDate ON Events(start_date);
CREATE INDEX IX_Orders_UserID ON Orders(user_id);
CREATE INDEX IX_Orders_EventID ON Orders(event_id);
CREATE INDEX IX_Orders_Status ON Orders(status);
CREATE INDEX IX_Tickets_OrderItemID ON Tickets(order_item_id);
CREATE INDEX IX_Tickets_TicketCode ON Tickets(ticket_code);

-- =============================================
-- INSERT DEFAULT DATA
-- =============================================

-- Default Categories
INSERT INTO Categories (name, slug, icon, description) VALUES
(N'Âm nhạc', 'music', 'fa-music', N'Concerts, liveshow, EDM festivals'),
(N'Thể thao', 'sports', 'fa-futbol', N'Bóng đá, marathon, tennis'),
(N'Workshop', 'workshop', 'fa-laptop', N'Hội thảo, khóa học, training'),
(N'Ẩm thực', 'food', 'fa-utensils', N'Lễ hội ẩm thực, food tour'),
(N'Nghệ thuật', 'art', 'fa-palette', N'Triển lãm, kịch, múa ballet'),
(N'Kinh doanh', 'business', 'fa-briefcase', N'Networking, startup pitch');

-- Default Admin User (password: admin123)
INSERT INTO Users (email, password_hash, full_name, phone, role) VALUES
('admin@ticketbox.vn', 'admin123', N'Admin Ticketbox', '0901234567', 'admin');

-- Default Organizer (password: organizer123)
INSERT INTO Users (email, password_hash, full_name, phone, role) VALUES
('organizer@ticketbox.vn', 'organizer123', N'Live Nation VN', '0909876543', 'organizer');

-- Default Customer (password: customer123)
INSERT INTO Users (email, password_hash, full_name, phone, role) VALUES
('customer@ticketbox.vn', 'customer123', N'Nguyễn Văn A', '0912345678', 'customer');

-- Sample Events
INSERT INTO Events (organizer_id, category_id, title, slug, description, banner_image, location, address, start_date, end_date, status, is_featured) VALUES
(2, 1, N'Đêm nhạc Acoustic - Những bản tình ca', 'dem-nhac-acoustic-2026', N'Đêm nhạc acoustic với những bản tình ca bất hủ', 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=800', N'Nhà hát Thành phố', N'7 Lam Sơn, Quận 1, TP.HCM', '2026-02-15 19:00:00', '2026-02-15 22:00:00', 'approved', 1),
(2, 3, N'Workshop UI/UX Design cho người mới', 'workshop-uiux-2026', N'Học thiết kế UI/UX từ cơ bản đến nâng cao', 'https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=800', N'WeWork Bitexco', N'45 Điện Biên Phủ, Quận 1, TP.HCM', '2026-02-20 09:00:00', '2026-02-20 17:00:00', 'approved', 1),
(2, 1, N'EDM Festival 2026', 'edm-festival-2026', N'Đại tiệc âm nhạc điện tử lớn nhất năm', 'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=800', N'Phú Thọ Stadium', N'1 Lý Thường Kiệt, Quận 10, TP.HCM', '2026-03-01 18:00:00', '2026-03-02 02:00:00', 'approved', 0);

-- Sample Ticket Types
INSERT INTO TicketTypes (event_id, name, description, price, quantity, sold_quantity) VALUES
(1, N'Vé VIP', N'Ghế VIP hàng đầu, quà tặng đặc biệt', 1500000, 100, 45),
(1, N'Vé thường', N'Ghế thường', 500000, 400, 180),
(2, N'Early Bird', N'Vé ưu đãi đặt sớm', 400000, 50, 50),
(2, N'Standard', N'Vé tiêu chuẩn', 600000, 100, 30),
(3, N'General Admission', N'Vé vào cổng', 800000, 2000, 500),
(3, N'VIP Standing', N'Khu VIP gần sân khấu', 2000000, 200, 80);

PRINT 'Database created successfully!';
GO
