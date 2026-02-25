-- =============================================
-- TICKETBOX DATABASE SCHEMA V3.0 (Optimized)
-- SQL Server | PRJ301 Final Project - Group 4
-- 15 Tables | Cloudinary Media | SeePay Payment
-- =============================================

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
-- 1. USERS
-- =============================================
CREATE TABLE Users (
    user_id INT IDENTITY(1,1) PRIMARY KEY,
    email NVARCHAR(255) NOT NULL UNIQUE,
    password_hash NVARCHAR(255) NOT NULL,
    full_name NVARCHAR(100) NOT NULL,
    phone NVARCHAR(20),
    role NVARCHAR(20) DEFAULT 'customer' CHECK (role IN ('customer', 'organizer', 'admin')),
    avatar_url NVARCHAR(500),
    is_active BIT DEFAULT 1,

    -- Organizer profile
    bio NVARCHAR(2000),
    website NVARCHAR(255),
    social_facebook NVARCHAR(255),
    social_instagram NVARCHAR(255),

    -- Security
    email_verified BIT DEFAULT 0,
    email_verified_at DATETIME,
    last_login_at DATETIME,
    last_login_ip NVARCHAR(45),
    password_changed_at DATETIME,

    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME DEFAULT GETDATE()
);

-- =============================================
-- 2. CATEGORIES
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
-- 3. MEDIA (Cloudinary URLs - Polymorphic)
-- Stores all uploaded images/videos as Cloudinary URLs.
-- entity_type + entity_id = polymorphic FK to any table.
-- =============================================
CREATE TABLE Media (
    media_id INT IDENTITY(1,1) PRIMARY KEY,
    uploader_id INT NOT NULL,

    -- Cloudinary fields
    cloudinary_url NVARCHAR(500) NOT NULL,
    cloudinary_public_id NVARCHAR(255) NOT NULL,

    -- File metadata
    file_name NVARCHAR(255) NOT NULL,
    file_size INT CHECK (file_size <= 52428800), -- Max 50MB
    media_type NVARCHAR(10) NOT NULL CHECK (media_type IN ('image', 'video')),
    mime_type NVARCHAR(50),
    width INT,
    height INT,

    -- Polymorphic relationship
    entity_type NVARCHAR(20) NOT NULL CHECK (entity_type IN (
        'user', 'event', 'ticket_type'
    )),
    entity_id INT NOT NULL,
    media_purpose NVARCHAR(20) NOT NULL CHECK (media_purpose IN (
        'avatar', 'banner', 'gallery', 'inline', 'ticket_design'
    )),
    display_order INT DEFAULT 0,
    alt_text NVARCHAR(255),

    created_at DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (uploader_id) REFERENCES Users(user_id)
);

-- =============================================
-- 4. EVENTS
-- description = rich HTML from TinyMCE/Quill editor
-- Inline images stored in Media with entity_type='event', media_purpose='inline'
-- =============================================
CREATE TABLE Events (
    event_id INT IDENTITY(1,1) PRIMARY KEY,
    organizer_id INT NOT NULL,
    category_id INT NOT NULL,
    title NVARCHAR(255) NOT NULL,
    slug NVARCHAR(255) NOT NULL UNIQUE,
    short_description NVARCHAR(500),
    description NVARCHAR(MAX), -- Rich HTML content
    banner_image NVARCHAR(500),
    location NVARCHAR(255),
    address NVARCHAR(500),
    start_date DATETIME NOT NULL,
    end_date DATETIME,
    status NVARCHAR(20) DEFAULT 'draft' CHECK (status IN (
        'draft', 'pending', 'approved', 'rejected', 'cancelled', 'completed'
    )),
    is_featured BIT DEFAULT 0,
    is_private BIT DEFAULT 0,
    views INT DEFAULT 0,
    published_at DATETIME,
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (organizer_id) REFERENCES Users(user_id),
    FOREIGN KEY (category_id) REFERENCES Categories(category_id)
);

-- =============================================
-- 5. TICKET TYPES
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
    color_theme NVARCHAR(7),
    design_url NVARCHAR(500), -- Cloudinary URL for ticket design
    created_at DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (event_id) REFERENCES Events(event_id) ON DELETE CASCADE
);

-- =============================================
-- 6. ORDERS
-- =============================================
CREATE TABLE Orders (
    order_id INT IDENTITY(1,1) PRIMARY KEY,
    order_code NVARCHAR(50) NOT NULL UNIQUE,
    user_id INT NOT NULL,
    event_id INT NOT NULL,
    total_amount DECIMAL(18,2) NOT NULL,
    discount_amount DECIMAL(18,2) DEFAULT 0,
    final_amount DECIMAL(18,2) NOT NULL,
    status NVARCHAR(20) DEFAULT 'pending' CHECK (status IN (
        'pending', 'paid', 'cancelled', 'refunded'
    )),
    payment_method NVARCHAR(30) DEFAULT 'seepay' CHECK (payment_method IN (
        'seepay', 'bank_transfer', 'cash'
    )),
    payment_date DATETIME,
    payment_expires_at DATETIME,
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
-- 7. ORDER ITEMS
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
-- 8. TICKETS (Issued tickets with QR)
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
-- 9. PAYMENT TRANSACTIONS (SeePay)
-- =============================================
CREATE TABLE PaymentTransactions (
    transaction_id INT IDENTITY(1,1) PRIMARY KEY,
    order_id INT NOT NULL,
    payment_method NVARCHAR(30) NOT NULL,

    -- SeePay fields
    seepay_transaction_id NVARCHAR(100),
    seepay_reference NVARCHAR(100),
    seepay_qr_code NVARCHAR(500),

    -- Transaction info
    amount DECIMAL(18,2) NOT NULL,
    currency NVARCHAR(3) DEFAULT 'VND',
    status NVARCHAR(20) DEFAULT 'pending' CHECK (status IN (
        'pending', 'processing', 'completed', 'failed',
        'cancelled', 'refunded', 'expired'
    )),

    -- Timestamps
    initiated_at DATETIME DEFAULT GETDATE(),
    completed_at DATETIME,
    expires_at DATETIME,

    -- Provider response (includes webhook data)
    provider_response NVARCHAR(MAX),
    error_code NVARCHAR(50),
    error_message NVARCHAR(500),

    -- Client metadata
    ip_address NVARCHAR(45),

    FOREIGN KEY (order_id) REFERENCES Orders(order_id)
);

-- =============================================
-- 10. VOUCHERS
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
-- 11. VOUCHER USAGES
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
-- 12. USER SESSIONS
-- =============================================
CREATE TABLE UserSessions (
    session_id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT NOT NULL,
    session_token NVARCHAR(255) NOT NULL UNIQUE,
    device_info NVARCHAR(255),
    ip_address NVARCHAR(45),
    expires_at DATETIME NOT NULL,
    is_active BIT DEFAULT 1,
    created_at DATETIME DEFAULT GETDATE(),
    last_activity DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE
);

-- =============================================
-- 13. PASSWORD RESETS
-- =============================================
CREATE TABLE PasswordResets (
    reset_id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT NOT NULL,
    reset_token NVARCHAR(255) NOT NULL UNIQUE,
    expires_at DATETIME NOT NULL,
    is_used BIT DEFAULT 0,
    used_at DATETIME,
    created_at DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE
);

-- =============================================
-- 14. PERMISSIONS
-- =============================================
CREATE TABLE Permissions (
    permission_id INT IDENTITY(1,1) PRIMARY KEY,
    permission_key NVARCHAR(100) NOT NULL UNIQUE,
    permission_name NVARCHAR(100) NOT NULL,
    description NVARCHAR(255),
    module NVARCHAR(50) NOT NULL
);

-- =============================================
-- 15. ROLE PERMISSIONS
-- =============================================
CREATE TABLE RolePermissions (
    role_permission_id INT IDENTITY(1,1) PRIMARY KEY,
    role NVARCHAR(20) NOT NULL CHECK (role IN ('customer', 'organizer', 'admin')),
    permission_id INT NOT NULL,
    FOREIGN KEY (permission_id) REFERENCES Permissions(permission_id) ON DELETE CASCADE,
    UNIQUE (role, permission_id)
);

-- =============================================
-- INDEXES
-- =============================================

-- Core lookups
CREATE INDEX IX_Events_OrganizerID ON Events(organizer_id);
CREATE INDEX IX_Events_CategoryID ON Events(category_id);
CREATE INDEX IX_Events_Status ON Events(status);
CREATE INDEX IX_Events_StartDate ON Events(start_date);
CREATE INDEX IX_Orders_UserID ON Orders(user_id);
CREATE INDEX IX_Orders_EventID ON Orders(event_id);
CREATE INDEX IX_Orders_Status ON Orders(status);
CREATE INDEX IX_Tickets_TicketCode ON Tickets(ticket_code);

-- Media (polymorphic queries)
CREATE INDEX IX_Media_Entity ON Media(entity_type, entity_id);
CREATE INDEX IX_Media_Entity_Purpose ON Media(entity_type, entity_id, media_purpose);
CREATE INDEX IX_Media_UploaderID ON Media(uploader_id);

-- Payments
CREATE INDEX IX_PaymentTx_OrderID ON PaymentTransactions(order_id);
CREATE INDEX IX_PaymentTx_Status ON PaymentTransactions(status);
CREATE INDEX IX_PaymentTx_SeepayID ON PaymentTransactions(seepay_transaction_id);

-- Auth
CREATE INDEX IX_UserSessions_Token ON UserSessions(session_token);
CREATE INDEX IX_UserSessions_UserID ON UserSessions(user_id);
CREATE INDEX IX_PasswordResets_Token ON PasswordResets(reset_token);

-- =============================================
-- DEFAULT DATA
-- =============================================

-- Categories
INSERT INTO Categories (name, slug, icon, description) VALUES
(N'Âm nhạc', 'music', 'fa-music', N'Concerts, liveshow, EDM festivals'),
(N'Thể thao', 'sports', 'fa-futbol', N'Bóng đá, marathon, tennis'),
(N'Workshop', 'workshop', 'fa-laptop', N'Hội thảo, khóa học, training'),
(N'Ẩm thực', 'food', 'fa-utensils', N'Lễ hội ẩm thực, food tour'),
(N'Nghệ thuật', 'art', 'fa-palette', N'Triển lãm, kịch, múa ballet'),
(N'Kinh doanh', 'business', 'fa-briefcase', N'Networking, startup pitch');

-- Permissions
INSERT INTO Permissions (permission_key, permission_name, description, module) VALUES
('event.create', 'Create Event', N'Tạo sự kiện mới', 'event'),
('event.edit', 'Edit Event', N'Chỉnh sửa sự kiện', 'event'),
('event.delete', 'Delete Event', N'Xóa sự kiện', 'event'),
('event.approve', 'Approve Event', N'Phê duyệt sự kiện', 'event'),
('event.publish', 'Publish Event', N'Xuất bản sự kiện', 'event'),
('event.feature', 'Feature Event', N'Đánh dấu nổi bật', 'event'),
('order.view', 'View Orders', N'Xem đơn hàng', 'order'),
('order.refund', 'Refund Order', N'Hoàn tiền', 'order'),
('order.export', 'Export Orders', N'Xuất báo cáo', 'order'),
('user.view', 'View Users', N'Xem người dùng', 'user'),
('user.manage', 'Manage Users', N'Quản lý người dùng', 'user'),
('user.ban', 'Ban Users', N'Khóa tài khoản', 'user'),
('report.view', 'View Reports', N'Xem báo cáo', 'report'),
('report.revenue', 'Revenue Report', N'Báo cáo doanh thu', 'report'),
('settings.manage', 'Manage Settings', N'Quản lý cài đặt', 'setting'),
('media.upload', 'Upload Media', N'Tải lên media', 'media'),
('media.delete', 'Delete Media', N'Xóa media', 'media');

-- Admin gets all permissions
INSERT INTO RolePermissions (role, permission_id)
SELECT 'admin', permission_id FROM Permissions;

-- Organizer permissions
INSERT INTO RolePermissions (role, permission_id)
SELECT 'organizer', permission_id FROM Permissions
WHERE permission_key IN (
    'event.create', 'event.edit', 'event.publish',
    'order.view', 'order.export',
    'report.view', 'report.revenue',
    'media.upload', 'media.delete'
);

-- Customer permissions
INSERT INTO RolePermissions (role, permission_id)
SELECT 'customer', permission_id FROM Permissions
WHERE permission_key IN ('order.view', 'media.upload');

-- Users
INSERT INTO Users (email, password_hash, full_name, phone, role, email_verified) VALUES
('admin@ticketbox.vn', 'admin123', N'Admin Ticketbox', '0901234567', 'admin', 1);

INSERT INTO Users (email, password_hash, full_name, phone, role, email_verified, bio) VALUES
('organizer@ticketbox.vn', 'organizer123', N'Live Nation VN', '0909876543', 'organizer', 1, N'Nhà tổ chức sự kiện hàng đầu Việt Nam');

INSERT INTO Users (email, password_hash, full_name, phone, role, email_verified) VALUES
('customer@ticketbox.vn', 'customer123', N'Nguyễn Văn A', '0912345678', 'customer', 1);

-- Sample Events
INSERT INTO Events (organizer_id, category_id, title, slug, short_description, description, banner_image, location, address, start_date, end_date, status, is_featured) VALUES
(2, 1, N'Đêm nhạc Acoustic - Những bản tình ca', 'dem-nhac-acoustic-2026',
    N'Trải nghiệm âm nhạc tuyệt vời với các nghệ sĩ hàng đầu',
    N'<h2>Giới thiệu sự kiện</h2><p>Đêm nhạc Acoustic là sự kiện âm nhạc đặc biệt quy tụ nhiều nghệ sĩ nổi tiếng.</p><h2>Nghệ sĩ tham gia</h2><ul><li>Mỹ Tâm</li><li>Hà Anh Tuấn</li><li>Phan Mạnh Quỳnh</li></ul>',
    'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=800',
    N'Nhà hát Thành phố', N'7 Lam Sơn, Quận 1, TP.HCM',
    '2026-02-15 19:00:00', '2026-02-15 22:00:00', 'approved', 1),
(2, 3, N'Workshop UI/UX Design cho người mới', 'workshop-uiux-2026',
    N'Khóa học thực hành UI/UX cho người mới bắt đầu',
    N'<h2>Nội dung Workshop</h2><p>Học thiết kế UI/UX từ cơ bản đến nâng cao với chuyên gia hàng đầu.</p>',
    'https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=800',
    N'WeWork Bitexco', N'45 Điện Biên Phủ, Quận 1, TP.HCM',
    '2026-02-20 09:00:00', '2026-02-20 17:00:00', 'approved', 1),
(2, 1, N'EDM Festival 2026', 'edm-festival-2026',
    N'Vui hết cỡ với các DJ nổi tiếng thế giới',
    N'<h2>EDM Festival 2026</h2><p>Đại tiệc âm nhạc điện tử lớn nhất năm với line-up khủng.</p>',
    'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=800',
    N'Phú Thọ Stadium', N'1 Lý Thường Kiệt, Quận 10, TP.HCM',
    '2026-03-01 18:00:00', '2026-03-02 02:00:00', 'approved', 0);

-- Ticket Types
INSERT INTO TicketTypes (event_id, name, description, price, quantity, sold_quantity, color_theme) VALUES
(1, N'Vé VIP', N'Ghế VIP hàng đầu, quà tặng đặc biệt', 1500000, 100, 45, '#FFD700'),
(1, N'Vé thường', N'Ghế thường', 500000, 400, 180, '#4A90A4'),
(2, N'Early Bird', N'Vé ưu đãi đặt sớm', 400000, 50, 50, '#FF6B6B'),
(2, N'Standard', N'Vé tiêu chuẩn', 600000, 100, 30, '#4ECDC4'),
(3, N'General Admission', N'Vé vào cổng', 800000, 2000, 500, '#9B59B6'),
(3, N'VIP Standing', N'Khu VIP gần sân khấu', 2000000, 200, 80, '#E74C3C');

PRINT 'TicketBox Database V3.0 created successfully!';
PRINT 'Total tables: 15 (optimized from 25)';
GO
