-- =============================================
-- TICKETBOX DATABASE SCHEMA V3.1 (Idempotent)
-- SQL Server | PRJ301 Final Project - Group 4
-- 15 Tables | Cloudinary Media | SeePay Payment
-- =============================================
-- SAFE TO RE-RUN: Uses IF NOT EXISTS throughout.
-- Will NOT drop existing data.
-- =============================================

-- Create DB if not exists
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'SellingTicketDB')
BEGIN
    CREATE DATABASE SellingTicketDB;
    PRINT 'Database created.';
END
GO

USE SellingTicketDB;
GO

-- =============================================
-- 1. USERS
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('Users') AND type = 'U')
BEGIN
    CREATE TABLE Users (
        user_id INT IDENTITY(1,1) PRIMARY KEY,
        email NVARCHAR(255) NOT NULL UNIQUE,
        password_hash NVARCHAR(255) NOT NULL,
        full_name NVARCHAR(100) NOT NULL,
        phone NVARCHAR(20),
        gender NVARCHAR(10),
        date_of_birth DATE,
        role NVARCHAR(20) DEFAULT 'customer' CHECK (role IN ('customer', 'organizer', 'admin')),
        avatar NVARCHAR(500),
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
    PRINT 'Table Users created.';
END
ELSE
BEGIN
    -- Migration: add missing columns to existing table
    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('Users') AND name = 'gender')
        ALTER TABLE Users ADD gender NVARCHAR(10);
    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('Users') AND name = 'date_of_birth')
        ALTER TABLE Users ADD date_of_birth DATE;
    IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('Users') AND name = 'avatar_url')
        EXEC sp_rename 'Users.avatar_url', 'avatar', 'COLUMN';
    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('Users') AND name = 'avatar')
        ALTER TABLE Users ADD avatar NVARCHAR(500);
    PRINT 'Table Users already exists - columns verified.';
END
GO

-- =============================================
-- 2. CATEGORIES
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('Categories') AND type = 'U')
BEGIN
    CREATE TABLE Categories (
        category_id INT IDENTITY(1,1) PRIMARY KEY,
        name NVARCHAR(100) NOT NULL,
        slug NVARCHAR(100) NOT NULL UNIQUE,
        icon NVARCHAR(50),
        description NVARCHAR(500),
        created_at DATETIME DEFAULT GETDATE()
    );
    PRINT 'Table Categories created.';
END
GO

-- =============================================
-- 3. MEDIA (Cloudinary URLs - Polymorphic)
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('Media') AND type = 'U')
BEGIN
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
    PRINT 'Table Media created.';
END
GO

-- =============================================
-- 4. EVENTS
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('Events') AND type = 'U')
BEGIN
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
    PRINT 'Table Events created.';
END
GO

-- =============================================
-- 5. TICKET TYPES
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('TicketTypes') AND type = 'U')
BEGIN
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
        design_url NVARCHAR(500),
        created_at DATETIME DEFAULT GETDATE(),
        FOREIGN KEY (event_id) REFERENCES Events(event_id) ON DELETE CASCADE
    );
    PRINT 'Table TicketTypes created.';
END
GO

-- =============================================
-- 6. ORDERS
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('Orders') AND type = 'U')
BEGIN
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
    PRINT 'Table Orders created.';
END
GO

-- =============================================
-- 7. ORDER ITEMS
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('OrderItems') AND type = 'U')
BEGIN
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
    PRINT 'Table OrderItems created.';
END
GO

-- =============================================
-- 8. TICKETS (Issued tickets with QR)
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('Tickets') AND type = 'U')
BEGIN
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
    PRINT 'Table Tickets created.';
END
GO

-- =============================================
-- 9. PAYMENT TRANSACTIONS (SeePay)
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('PaymentTransactions') AND type = 'U')
BEGIN
    CREATE TABLE PaymentTransactions (
        transaction_id INT IDENTITY(1,1) PRIMARY KEY,
        order_id INT NOT NULL,
        payment_method NVARCHAR(30) NOT NULL,
        seepay_transaction_id NVARCHAR(100),
        seepay_reference NVARCHAR(100),
        seepay_qr_code NVARCHAR(500),
        amount DECIMAL(18,2) NOT NULL,
        currency NVARCHAR(3) DEFAULT 'VND',
        status NVARCHAR(20) DEFAULT 'pending' CHECK (status IN (
            'pending', 'processing', 'completed', 'failed',
            'cancelled', 'refunded', 'expired'
        )),
        initiated_at DATETIME DEFAULT GETDATE(),
        completed_at DATETIME,
        expires_at DATETIME,
        provider_response NVARCHAR(MAX),
        error_code NVARCHAR(50),
        error_message NVARCHAR(500),
        ip_address NVARCHAR(45),
        FOREIGN KEY (order_id) REFERENCES Orders(order_id)
    );
    PRINT 'Table PaymentTransactions created.';
END
GO

-- =============================================
-- 10. VOUCHERS
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('Vouchers') AND type = 'U')
BEGIN
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
    PRINT 'Table Vouchers created.';
END
GO

-- =============================================
-- 11. VOUCHER USAGES
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('VoucherUsages') AND type = 'U')
BEGIN
    CREATE TABLE VoucherUsages (
        usage_id INT IDENTITY(1,1) PRIMARY KEY,
        voucher_id INT NOT NULL,
        order_id INT NOT NULL,
        discount_applied DECIMAL(18,2) NOT NULL,
        used_at DATETIME DEFAULT GETDATE(),
        FOREIGN KEY (voucher_id) REFERENCES Vouchers(voucher_id),
        FOREIGN KEY (order_id) REFERENCES Orders(order_id)
    );
    PRINT 'Table VoucherUsages created.';
END
GO

-- =============================================
-- 12. USER SESSIONS
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('UserSessions') AND type = 'U')
BEGIN
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
    PRINT 'Table UserSessions created.';
END
GO

-- =============================================
-- 13. PASSWORD RESETS
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('PasswordResets') AND type = 'U')
BEGIN
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
    PRINT 'Table PasswordResets created.';
END
GO

-- =============================================
-- 14. PERMISSIONS
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('Permissions') AND type = 'U')
BEGIN
    CREATE TABLE Permissions (
        permission_id INT IDENTITY(1,1) PRIMARY KEY,
        permission_key NVARCHAR(100) NOT NULL UNIQUE,
        permission_name NVARCHAR(100) NOT NULL,
        description NVARCHAR(255),
        module NVARCHAR(50) NOT NULL
    );
    PRINT 'Table Permissions created.';
END
GO

-- =============================================
-- 15. ROLE PERMISSIONS
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('RolePermissions') AND type = 'U')
BEGIN
    CREATE TABLE RolePermissions (
        role_permission_id INT IDENTITY(1,1) PRIMARY KEY,
        role NVARCHAR(20) NOT NULL CHECK (role IN ('customer', 'organizer', 'admin')),
        permission_id INT NOT NULL,
        FOREIGN KEY (permission_id) REFERENCES Permissions(permission_id) ON DELETE CASCADE,
        UNIQUE (role, permission_id)
    );
    PRINT 'Table RolePermissions created.';
END
GO

PRINT '--- All 15 tables verified ---';
GO

-- =============================================
-- INDEXES (Idempotent - drops old + recreates)
-- =============================================

-- Helper: drop index if exists, then create
-- Events
IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Events_OrganizerID' AND object_id = OBJECT_ID('Events'))
    DROP INDEX IX_Events_OrganizerID ON Events;
CREATE INDEX IX_Events_OrganizerID ON Events(organizer_id);
GO

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Events_CategoryID' AND object_id = OBJECT_ID('Events'))
    DROP INDEX IX_Events_CategoryID ON Events;
CREATE INDEX IX_Events_CategoryID ON Events(category_id);
GO

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Events_Status' AND object_id = OBJECT_ID('Events'))
    DROP INDEX IX_Events_Status ON Events;
CREATE NONCLUSTERED INDEX IX_Events_Status ON Events(status)
    INCLUDE (title, start_date, organizer_id);
GO

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Events_StartDate' AND object_id = OBJECT_ID('Events'))
    DROP INDEX IX_Events_StartDate ON Events;
CREATE INDEX IX_Events_StartDate ON Events(start_date);
GO

-- Orders
IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Orders_UserID' AND object_id = OBJECT_ID('Orders'))
    DROP INDEX IX_Orders_UserID ON Orders;
IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Orders_User' AND object_id = OBJECT_ID('Orders'))
    DROP INDEX IX_Orders_User ON Orders;
CREATE NONCLUSTERED INDEX IX_Orders_User ON Orders(user_id, created_at DESC)
    INCLUDE (status, final_amount);
GO

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Orders_EventID' AND object_id = OBJECT_ID('Orders'))
    DROP INDEX IX_Orders_EventID ON Orders;
IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Orders_Event' AND object_id = OBJECT_ID('Orders'))
    DROP INDEX IX_Orders_Event ON Orders;
CREATE NONCLUSTERED INDEX IX_Orders_Event ON Orders(event_id, status)
    INCLUDE (final_amount, created_at);
GO

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Orders_Status' AND object_id = OBJECT_ID('Orders'))
    DROP INDEX IX_Orders_Status ON Orders;
CREATE NONCLUSTERED INDEX IX_Orders_Status ON Orders(status)
    INCLUDE (final_amount, created_at);
GO

-- Tickets
IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Tickets_TicketCode' AND object_id = OBJECT_ID('Tickets'))
    DROP INDEX IX_Tickets_TicketCode ON Tickets;
CREATE INDEX IX_Tickets_TicketCode ON Tickets(ticket_code);
GO

-- TicketTypes
IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_TicketTypes_Event' AND object_id = OBJECT_ID('TicketTypes'))
    DROP INDEX IX_TicketTypes_Event ON TicketTypes;
CREATE NONCLUSTERED INDEX IX_TicketTypes_Event ON TicketTypes(event_id, is_active)
    INCLUDE (price, quantity, sold_quantity);
GO

-- Media (polymorphic queries)
IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Media_Entity' AND object_id = OBJECT_ID('Media'))
    DROP INDEX IX_Media_Entity ON Media;
CREATE INDEX IX_Media_Entity ON Media(entity_type, entity_id);
GO

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Media_Entity_Purpose' AND object_id = OBJECT_ID('Media'))
    DROP INDEX IX_Media_Entity_Purpose ON Media;
CREATE INDEX IX_Media_Entity_Purpose ON Media(entity_type, entity_id, media_purpose);
GO

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Media_UploaderID' AND object_id = OBJECT_ID('Media'))
    DROP INDEX IX_Media_UploaderID ON Media;
CREATE INDEX IX_Media_UploaderID ON Media(uploader_id);
GO

-- Payments
IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_PaymentTx_OrderID' AND object_id = OBJECT_ID('PaymentTransactions'))
    DROP INDEX IX_PaymentTx_OrderID ON PaymentTransactions;
CREATE INDEX IX_PaymentTx_OrderID ON PaymentTransactions(order_id);
GO

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_PaymentTx_Status' AND object_id = OBJECT_ID('PaymentTransactions'))
    DROP INDEX IX_PaymentTx_Status ON PaymentTransactions;
CREATE INDEX IX_PaymentTx_Status ON PaymentTransactions(status);
GO

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_PaymentTx_SeepayID' AND object_id = OBJECT_ID('PaymentTransactions'))
    DROP INDEX IX_PaymentTx_SeepayID ON PaymentTransactions;
CREATE INDEX IX_PaymentTx_SeepayID ON PaymentTransactions(seepay_transaction_id);
GO

-- Auth
IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_UserSessions_Token' AND object_id = OBJECT_ID('UserSessions'))
    DROP INDEX IX_UserSessions_Token ON UserSessions;
CREATE INDEX IX_UserSessions_Token ON UserSessions(session_token);
GO

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_UserSessions_UserID' AND object_id = OBJECT_ID('UserSessions'))
    DROP INDEX IX_UserSessions_UserID ON UserSessions;
CREATE INDEX IX_UserSessions_UserID ON UserSessions(user_id);
GO

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_PasswordResets_Token' AND object_id = OBJECT_ID('PasswordResets'))
    DROP INDEX IX_PasswordResets_Token ON PasswordResets;
CREATE INDEX IX_PasswordResets_Token ON PasswordResets(reset_token);
GO

PRINT '--- All indexes created ---';
GO

-- =============================================
-- DEFAULT DATA (Idempotent - skip if exists)
-- =============================================

-- Categories
IF NOT EXISTS (SELECT 1 FROM Categories WHERE slug = 'music')
BEGIN
    INSERT INTO Categories (name, slug, icon, description) VALUES
    (N'Âm nhạc', 'music', 'fa-music', N'Concerts, liveshow, EDM festivals'),
    (N'Thể thao', 'sports', 'fa-futbol', N'Bóng đá, marathon, tennis'),
    (N'Workshop', 'workshop', 'fa-laptop', N'Hội thảo, khóa học, training'),
    (N'Ẩm thực', 'food', 'fa-utensils', N'Lễ hội ẩm thực, food tour'),
    (N'Nghệ thuật', 'art', 'fa-palette', N'Triển lãm, kịch, múa ballet'),
    (N'Kinh doanh', 'business', 'fa-briefcase', N'Networking, startup pitch');
    PRINT 'Categories seeded.';
END
GO

-- Permissions
IF NOT EXISTS (SELECT 1 FROM Permissions WHERE permission_key = 'event.create')
BEGIN
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
    PRINT 'Permissions seeded.';
END
GO

-- Role Permissions
IF NOT EXISTS (SELECT 1 FROM RolePermissions WHERE role = 'admin')
BEGIN
    -- Admin gets all
    INSERT INTO RolePermissions (role, permission_id)
    SELECT 'admin', permission_id FROM Permissions;

    -- Organizer
    INSERT INTO RolePermissions (role, permission_id)
    SELECT 'organizer', permission_id FROM Permissions
    WHERE permission_key IN (
        'event.create', 'event.edit', 'event.publish',
        'order.view', 'order.export',
        'report.view', 'report.revenue',
        'media.upload', 'media.delete'
    );

    -- Customer
    INSERT INTO RolePermissions (role, permission_id)
    SELECT 'customer', permission_id FROM Permissions
    WHERE permission_key IN ('order.view', 'media.upload');
    PRINT 'Role permissions seeded.';
END
GO

-- Default Users (passwords are BCrypt hashes, NOT plain text)
-- admin@ticketbox.vn    / Admin@123
-- organizer@ticketbox.vn / Organizer@123
-- customer@ticketbox.vn  / Customer@123
IF NOT EXISTS (SELECT 1 FROM Users WHERE email = 'admin@ticketbox.vn')
BEGIN
    INSERT INTO Users (email, password_hash, full_name, phone, role, email_verified) VALUES
    ('admin@ticketbox.vn', '$2a$12$odAx650SUPsEauwOWzajb.FUMCDzKZWYPLeG2.NlCs3NBxH2N/Pg.', N'Admin Ticketbox', '0901234567', 'admin', 1);
    PRINT 'Admin user created.';
END
GO

IF NOT EXISTS (SELECT 1 FROM Users WHERE email = 'organizer@ticketbox.vn')
BEGIN
    INSERT INTO Users (email, password_hash, full_name, phone, role, email_verified, bio) VALUES
    ('organizer@ticketbox.vn', '$2a$12$Bs2nPLu8UK8GZsy1flBiGewDcqwu4x/KqtksjeYEWRQtcBxgiyNVC', N'Live Nation VN', '0909876543', 'organizer', 1, N'Nhà tổ chức sự kiện hàng đầu Việt Nam');
    PRINT 'Organizer user created.';
END
GO

IF NOT EXISTS (SELECT 1 FROM Users WHERE email = 'customer@ticketbox.vn')
BEGIN
    INSERT INTO Users (email, password_hash, full_name, phone, role, email_verified) VALUES
    ('customer@ticketbox.vn', '$2a$12$07H.CL1nHx2kzH7oo1odGOClkIg/oK3s7.D/wxcRIL6xjhIo9sYhK', N'Nguyễn Văn A', '0912345678', 'customer', 1);
    PRINT 'Customer user created.';
END
GO

-- Sample Events
IF NOT EXISTS (SELECT 1 FROM Events WHERE slug = 'dem-nhac-acoustic-2026')
BEGIN
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
    PRINT 'Sample events created.';
END
GO

-- Ticket Types
IF NOT EXISTS (SELECT 1 FROM TicketTypes WHERE event_id = 1 AND name = N'Vé VIP')
BEGIN
    INSERT INTO TicketTypes (event_id, name, description, price, quantity, sold_quantity, color_theme) VALUES
    (1, N'Vé VIP', N'Ghế VIP hàng đầu, quà tặng đặc biệt', 1500000, 100, 45, '#FFD700'),
    (1, N'Vé thường', N'Ghế thường', 500000, 400, 180, '#4A90A4'),
    (2, N'Early Bird', N'Vé ưu đãi đặt sớm', 400000, 50, 50, '#FF6B6B'),
    (2, N'Standard', N'Vé tiêu chuẩn', 600000, 100, 30, '#4ECDC4'),
    (3, N'General Admission', N'Vé vào cổng', 800000, 2000, 500, '#9B59B6'),
    (3, N'VIP Standing', N'Khu VIP gần sân khấu', 2000000, 200, 80, '#E74C3C');
    PRINT 'Ticket types created.';
END
GO

-- =============================================
PRINT '';
PRINT '============================================';
PRINT '  TicketBox DB V3.1 - Setup Complete!';
PRINT '  15 tables | All indexes | Seed data';
PRINT '  Safe to re-run anytime.';
PRINT '============================================';
GO
