-- =============================================
-- TICKETBOX — FULL RESET & SEED DATA
-- SQL Server | PRJ301 Group 4
-- Version: 2026-03-11
-- =============================================
-- CHỈ CẦN CHẠY FILE NÀY 1 LẦN ĐỂ SETUP TOÀN BỘ
-- An toàn khi chuyển máy — DROP & CREATE lại tất cả
-- =============================================

-- 1) Tạo DB nếu chưa có
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'SellingTicketDB')
    CREATE DATABASE SellingTicketDB;
GO

USE SellingTicketDB;
GO

-- =============================================
-- DROP TẤT CẢ TABLES (theo thứ tự FK)
-- =============================================
IF OBJECT_ID('ChatMessages',  'U') IS NOT NULL DROP TABLE ChatMessages;
IF OBJECT_ID('ChatSessions',  'U') IS NOT NULL DROP TABLE ChatSessions;
IF OBJECT_ID('TicketMessages', 'U') IS NOT NULL DROP TABLE TicketMessages;
IF OBJECT_ID('SupportTickets','U') IS NOT NULL DROP TABLE SupportTickets;
IF OBJECT_ID('VoucherUsages', 'U') IS NOT NULL DROP TABLE VoucherUsages;
IF OBJECT_ID('Vouchers',      'U') IS NOT NULL DROP TABLE Vouchers;
IF OBJECT_ID('PaymentTransactions','U') IS NOT NULL DROP TABLE PaymentTransactions;
IF OBJECT_ID('Tickets',       'U') IS NOT NULL DROP TABLE Tickets;
IF OBJECT_ID('OrderItems',    'U') IS NOT NULL DROP TABLE OrderItems;
IF OBJECT_ID('Orders',        'U') IS NOT NULL DROP TABLE Orders;
IF OBJECT_ID('TicketTypes',   'U') IS NOT NULL DROP TABLE TicketTypes;
IF OBJECT_ID('EventStaff',    'U') IS NOT NULL DROP TABLE EventStaff;
IF OBJECT_ID('Media',         'U') IS NOT NULL DROP TABLE Media;
IF OBJECT_ID('Events',        'U') IS NOT NULL DROP TABLE Events;
IF OBJECT_ID('RolePermissions','U') IS NOT NULL DROP TABLE RolePermissions;
IF OBJECT_ID('Permissions',   'U') IS NOT NULL DROP TABLE Permissions;
IF OBJECT_ID('PasswordResets','U') IS NOT NULL DROP TABLE PasswordResets;
IF OBJECT_ID('UserSessions',  'U') IS NOT NULL DROP TABLE UserSessions;
IF OBJECT_ID('Categories',    'U') IS NOT NULL DROP TABLE Categories;
IF OBJECT_ID('Users',         'U') IS NOT NULL DROP TABLE Users;
GO

PRINT '=== Dropped all tables ===';
GO

-- =============================================
-- TABLE DEFINITIONS
-- =============================================

-- 1. USERS
CREATE TABLE Users (
    user_id INT IDENTITY(1,1) PRIMARY KEY,
    email NVARCHAR(255) NOT NULL UNIQUE,
    password_hash NVARCHAR(255) NOT NULL,
    full_name NVARCHAR(100) NOT NULL,
    phone NVARCHAR(20),
    gender NVARCHAR(10),
    date_of_birth DATE,
    role NVARCHAR(20) DEFAULT 'customer' CHECK (role IN ('customer','organizer','admin','support_agent')),
    avatar NVARCHAR(500),
    is_active BIT DEFAULT 1,
    is_deleted BIT DEFAULT 0,
    bio NVARCHAR(2000),
    website NVARCHAR(255),
    social_facebook NVARCHAR(255),
    social_instagram NVARCHAR(255),
    email_verified BIT DEFAULT 0,
    email_verified_at DATETIME,
    last_login_at DATETIME,
    last_login_ip NVARCHAR(45),
    password_changed_at DATETIME,
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME DEFAULT GETDATE()
);
GO

-- 2. CATEGORIES
CREATE TABLE Categories (
    category_id INT IDENTITY(1,1) PRIMARY KEY,
    name NVARCHAR(100) NOT NULL,
    slug NVARCHAR(100) NOT NULL UNIQUE,
    icon NVARCHAR(50),
    description NVARCHAR(500),
    is_deleted BIT DEFAULT 0,
    created_at DATETIME DEFAULT GETDATE()
);
GO

-- 3. MEDIA (Cloudinary — Polymorphic)
CREATE TABLE Media (
    media_id INT IDENTITY(1,1) PRIMARY KEY,
    uploader_id INT NOT NULL FOREIGN KEY REFERENCES Users(user_id),
    cloudinary_url NVARCHAR(500) NOT NULL,
    cloudinary_public_id NVARCHAR(255) NOT NULL,
    file_name NVARCHAR(255) NOT NULL,
    file_size INT CHECK (file_size <= 52428800),
    media_type NVARCHAR(10) NOT NULL CHECK (media_type IN ('image','video')),
    mime_type NVARCHAR(50),
    width INT,
    height INT,
    entity_type NVARCHAR(20) NOT NULL CHECK (entity_type IN ('user','event','ticket_type')),
    entity_id INT NOT NULL,
    media_purpose NVARCHAR(20) NOT NULL CHECK (media_purpose IN ('avatar','banner','gallery','inline','ticket_design')),
    display_order INT DEFAULT 0,
    alt_text NVARCHAR(255),
    created_at DATETIME DEFAULT GETDATE()
);
GO

-- 4. EVENTS
CREATE TABLE Events (
    event_id INT IDENTITY(1,1) PRIMARY KEY,
    organizer_id INT NOT NULL FOREIGN KEY REFERENCES Users(user_id),
    category_id INT NOT NULL FOREIGN KEY REFERENCES Categories(category_id),
    title NVARCHAR(255) NOT NULL,
    slug NVARCHAR(255) NOT NULL UNIQUE,
    short_description NVARCHAR(500),
    description NVARCHAR(MAX),
    banner_image NVARCHAR(500),
    location NVARCHAR(255),
    address NVARCHAR(500),
    start_date DATETIME NOT NULL,
    end_date DATETIME,
    status NVARCHAR(20) DEFAULT 'draft' CHECK (status IN ('draft','pending','approved','rejected','cancelled','completed')),
    is_featured BIT DEFAULT 0,
    is_private BIT DEFAULT 0,
    is_deleted BIT DEFAULT 0,
    views INT DEFAULT 0,
    pin_order INT DEFAULT 0,
    display_priority INT DEFAULT 0,
    max_tickets_per_order INT NOT NULL DEFAULT 0,
    max_total_tickets INT NOT NULL DEFAULT 0,
    pre_order_enabled BIT NOT NULL DEFAULT 0,
    rejection_reason NVARCHAR(MAX),
    rejected_at DATETIME,
    published_at DATETIME,
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME DEFAULT GETDATE()
);
GO

-- 5. TICKET TYPES
CREATE TABLE TicketTypes (
    ticket_type_id INT IDENTITY(1,1) PRIMARY KEY,
    event_id INT NOT NULL FOREIGN KEY REFERENCES Events(event_id) ON DELETE CASCADE,
    name NVARCHAR(100) NOT NULL,
    description NVARCHAR(500),
    price DECIMAL(18,2) NOT NULL,
    quantity INT NOT NULL,
    sold_quantity INT DEFAULT 0,
    sale_start DATETIME,
    sale_end DATETIME,
    is_active BIT DEFAULT 1,
    is_deleted BIT DEFAULT 0,
    color_theme NVARCHAR(7),
    design_url NVARCHAR(500),
    created_at DATETIME DEFAULT GETDATE()
);
GO

-- 6. ORDERS
CREATE TABLE Orders (
    order_id INT IDENTITY(1,1) PRIMARY KEY,
    order_code NVARCHAR(50) NOT NULL UNIQUE,
    user_id INT NOT NULL FOREIGN KEY REFERENCES Users(user_id),
    event_id INT NOT NULL FOREIGN KEY REFERENCES Events(event_id),
    total_amount DECIMAL(18,2) NOT NULL,
    discount_amount DECIMAL(18,2) DEFAULT 0,
    final_amount DECIMAL(18,2) NOT NULL,
    status NVARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending','paid','cancelled','refunded')),
    payment_method NVARCHAR(30) DEFAULT 'seepay' CHECK (payment_method IN ('seepay','bank_transfer','cash')),
    payment_date DATETIME,
    payment_expires_at DATETIME,
    is_deleted BIT DEFAULT 0,
    buyer_name NVARCHAR(100),
    buyer_email NVARCHAR(255),
    buyer_phone NVARCHAR(20),
    notes NVARCHAR(500),
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME DEFAULT GETDATE()
);
GO

-- 7. ORDER ITEMS
CREATE TABLE OrderItems (
    order_item_id INT IDENTITY(1,1) PRIMARY KEY,
    order_id INT NOT NULL FOREIGN KEY REFERENCES Orders(order_id) ON DELETE CASCADE,
    ticket_type_id INT NOT NULL FOREIGN KEY REFERENCES TicketTypes(ticket_type_id),
    quantity INT NOT NULL,
    unit_price DECIMAL(18,2) NOT NULL,
    subtotal DECIMAL(18,2) NOT NULL
);
GO

-- 8. TICKETS
CREATE TABLE Tickets (
    ticket_id INT IDENTITY(1,1) PRIMARY KEY,
    ticket_code NVARCHAR(50) NOT NULL UNIQUE,
    order_item_id INT NOT NULL FOREIGN KEY REFERENCES OrderItems(order_item_id) ON DELETE CASCADE,
    attendee_name NVARCHAR(100),
    attendee_email NVARCHAR(255),
    qr_code NVARCHAR(500),
    is_checked_in BIT DEFAULT 0,
    checked_in_at DATETIME,
    checked_in_by INT FOREIGN KEY REFERENCES Users(user_id),
    created_at DATETIME DEFAULT GETDATE()
);
GO

-- 9. PAYMENT TRANSACTIONS
CREATE TABLE PaymentTransactions (
    transaction_id INT IDENTITY(1,1) PRIMARY KEY,
    order_id INT NOT NULL FOREIGN KEY REFERENCES Orders(order_id),
    payment_method NVARCHAR(30) NOT NULL,
    seepay_transaction_id NVARCHAR(100),
    seepay_reference NVARCHAR(100),
    seepay_qr_code NVARCHAR(500),
    amount DECIMAL(18,2) NOT NULL,
    currency NVARCHAR(3) DEFAULT 'VND',
    status NVARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending','processing','completed','failed','cancelled','refunded','expired')),
    initiated_at DATETIME DEFAULT GETDATE(),
    completed_at DATETIME,
    expires_at DATETIME,
    provider_response NVARCHAR(MAX),
    error_code NVARCHAR(50),
    error_message NVARCHAR(500),
    ip_address NVARCHAR(45)
);
GO

-- 10. VOUCHERS
CREATE TABLE Vouchers (
    voucher_id INT IDENTITY(1,1) PRIMARY KEY,
    organizer_id INT NOT NULL FOREIGN KEY REFERENCES Users(user_id),
    event_id INT FOREIGN KEY REFERENCES Events(event_id),
    code NVARCHAR(50) NOT NULL UNIQUE,
    discount_type NVARCHAR(20) CHECK (discount_type IN ('percentage','fixed')),
    discount_value DECIMAL(18,2) NOT NULL,
    min_order_amount DECIMAL(18,2) DEFAULT 0,
    max_uses INT,
    used_count INT DEFAULT 0,
    start_date DATETIME,
    end_date DATETIME,
    is_active BIT DEFAULT 1,
    is_deleted BIT DEFAULT 0,
    created_at DATETIME DEFAULT GETDATE()
);
GO

-- 11. VOUCHER USAGES
CREATE TABLE VoucherUsages (
    usage_id INT IDENTITY(1,1) PRIMARY KEY,
    voucher_id INT NOT NULL FOREIGN KEY REFERENCES Vouchers(voucher_id),
    order_id INT NOT NULL FOREIGN KEY REFERENCES Orders(order_id),
    discount_applied DECIMAL(18,2) NOT NULL,
    used_at DATETIME DEFAULT GETDATE()
);
GO

-- 12. USER SESSIONS
CREATE TABLE UserSessions (
    session_id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT NOT NULL FOREIGN KEY REFERENCES Users(user_id) ON DELETE CASCADE,
    session_token NVARCHAR(255) NOT NULL UNIQUE,
    device_info NVARCHAR(255),
    ip_address NVARCHAR(45),
    expires_at DATETIME NOT NULL,
    is_active BIT DEFAULT 1,
    created_at DATETIME DEFAULT GETDATE(),
    last_activity DATETIME DEFAULT GETDATE()
);
GO

-- 13. PASSWORD RESETS
CREATE TABLE PasswordResets (
    reset_id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT NOT NULL FOREIGN KEY REFERENCES Users(user_id) ON DELETE CASCADE,
    reset_token NVARCHAR(255) NOT NULL UNIQUE,
    expires_at DATETIME NOT NULL,
    is_used BIT DEFAULT 0,
    used_at DATETIME,
    created_at DATETIME DEFAULT GETDATE()
);
GO

-- 14. PERMISSIONS
CREATE TABLE Permissions (
    permission_id INT IDENTITY(1,1) PRIMARY KEY,
    permission_key NVARCHAR(100) NOT NULL UNIQUE,
    permission_name NVARCHAR(100) NOT NULL,
    description NVARCHAR(255),
    module NVARCHAR(50) NOT NULL
);
GO

-- 15. ROLE PERMISSIONS
CREATE TABLE RolePermissions (
    role_permission_id INT IDENTITY(1,1) PRIMARY KEY,
    role NVARCHAR(20) NOT NULL CHECK (role IN ('customer','organizer','admin')),
    permission_id INT NOT NULL FOREIGN KEY REFERENCES Permissions(permission_id) ON DELETE CASCADE,
    UNIQUE (role, permission_id)
);
GO

-- 16. EVENT STAFF
CREATE TABLE EventStaff (
    staff_id INT IDENTITY(1,1) PRIMARY KEY,
    event_id INT NOT NULL FOREIGN KEY REFERENCES Events(event_id) ON DELETE CASCADE,
    user_id INT NOT NULL FOREIGN KEY REFERENCES Users(user_id) ON DELETE CASCADE,
    role NVARCHAR(20) DEFAULT 'editor' CHECK (role IN ('manager','editor','checkin')),
    granted_by INT FOREIGN KEY REFERENCES Users(user_id),
    created_at DATETIME DEFAULT GETDATE(),
    UNIQUE (event_id, user_id)
);
GO

-- 17. SUPPORT TICKETS
CREATE TABLE SupportTickets (
    ticket_id INT IDENTITY(1,1) PRIMARY KEY,
    ticket_code NVARCHAR(20) NOT NULL UNIQUE,
    user_id INT NOT NULL FOREIGN KEY REFERENCES Users(user_id),
    order_id INT NULL FOREIGN KEY REFERENCES Orders(order_id),
    event_id INT NULL FOREIGN KEY REFERENCES Events(event_id),
    category NVARCHAR(30) NOT NULL DEFAULT 'other'
        CHECK (category IN ('payment_error','missing_ticket','cancellation','refund','event_issue','account_issue','technical','feedback','other')),
    subject NVARCHAR(200) NOT NULL,
    description NVARCHAR(MAX) NOT NULL,
    status NVARCHAR(20) NOT NULL DEFAULT 'open'
        CHECK (status IN ('open','in_progress','resolved','closed')),
    priority NVARCHAR(10) NOT NULL DEFAULT 'normal'
        CHECK (priority IN ('low','normal','high','urgent')),
    routed_to NVARCHAR(20) NOT NULL DEFAULT 'admin'
        CHECK (routed_to IN ('admin','organizer')),
    assigned_to INT NULL FOREIGN KEY REFERENCES Users(user_id),
    resolved_at DATETIME NULL,
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME DEFAULT GETDATE()
);
GO

-- 18. TICKET MESSAGES (support conversation thread)
CREATE TABLE TicketMessages (
    message_id INT IDENTITY(1,1) PRIMARY KEY,
    ticket_id INT NOT NULL FOREIGN KEY REFERENCES SupportTickets(ticket_id),
    sender_id INT NOT NULL FOREIGN KEY REFERENCES Users(user_id),
    content NVARCHAR(MAX) NOT NULL,
    is_internal BIT DEFAULT 0,
    created_at DATETIME DEFAULT GETDATE()
);
GO

-- 19. CHAT SESSIONS
CREATE TABLE ChatSessions (
    session_id INT IDENTITY(1,1) PRIMARY KEY,
    customer_id INT NOT NULL FOREIGN KEY REFERENCES Users(user_id),
    agent_id INT NULL FOREIGN KEY REFERENCES Users(user_id),
    event_id INT NULL FOREIGN KEY REFERENCES Events(event_id),
    status NVARCHAR(10) DEFAULT 'waiting' CHECK (status IN ('waiting','active','closed')),
    created_at DATETIME DEFAULT GETDATE(),
    closed_at DATETIME NULL
);
GO

-- 20. CHAT MESSAGES
CREATE TABLE ChatMessages (
    message_id INT IDENTITY(1,1) PRIMARY KEY,
    session_id INT NOT NULL FOREIGN KEY REFERENCES ChatSessions(session_id),
    sender_id INT NOT NULL FOREIGN KEY REFERENCES Users(user_id),
    content NVARCHAR(500) NOT NULL,
    created_at DATETIME DEFAULT GETDATE()
);
GO

PRINT '=== All 20 tables created ===';
GO

-- =============================================
-- INDEXES
-- =============================================
CREATE INDEX IX_Events_OrganizerID ON Events(organizer_id);
CREATE INDEX IX_Events_CategoryID ON Events(category_id);
CREATE NONCLUSTERED INDEX IX_Events_Status ON Events(status, is_deleted) INCLUDE (title, start_date, organizer_id);
CREATE INDEX IX_Events_StartDate ON Events(start_date);
CREATE NONCLUSTERED INDEX IX_Events_Display ON Events(pin_order DESC, display_priority DESC, start_date ASC)
    WHERE is_deleted = 0 AND status = 'approved';

CREATE NONCLUSTERED INDEX IX_Orders_User ON Orders(user_id, is_deleted, created_at DESC) INCLUDE (status, final_amount);
CREATE NONCLUSTERED INDEX IX_Orders_Event ON Orders(event_id, status) INCLUDE (final_amount, created_at);
CREATE NONCLUSTERED INDEX IX_Orders_Status ON Orders(status) INCLUDE (final_amount, created_at);

CREATE INDEX IX_Tickets_TicketCode ON Tickets(ticket_code);
CREATE NONCLUSTERED INDEX IX_TicketTypes_Event ON TicketTypes(event_id, is_active) INCLUDE (price, quantity, sold_quantity);

CREATE INDEX IX_Media_Entity ON Media(entity_type, entity_id);
CREATE INDEX IX_Media_Entity_Purpose ON Media(entity_type, entity_id, media_purpose);
CREATE INDEX IX_Media_UploaderID ON Media(uploader_id);

CREATE INDEX IX_PaymentTx_OrderID ON PaymentTransactions(order_id);
CREATE INDEX IX_PaymentTx_Status ON PaymentTransactions(status);
CREATE INDEX IX_PaymentTx_SeepayID ON PaymentTransactions(seepay_transaction_id);

CREATE INDEX IX_UserSessions_Token ON UserSessions(session_token);
CREATE INDEX IX_UserSessions_UserID ON UserSessions(user_id);
CREATE INDEX IX_PasswordResets_Token ON PasswordResets(reset_token);

CREATE INDEX IX_EventStaff_User ON EventStaff(user_id);
CREATE INDEX IX_EventStaff_Event ON EventStaff(event_id);

CREATE INDEX IX_SupportTickets_user ON SupportTickets(user_id);
CREATE INDEX IX_SupportTickets_status ON SupportTickets(status);
CREATE INDEX IX_SupportTickets_event ON SupportTickets(event_id);
CREATE INDEX IX_SupportTickets_routed ON SupportTickets(routed_to, status);

CREATE INDEX IX_TicketMessages_ticket ON TicketMessages(ticket_id, created_at);
CREATE INDEX IX_ChatSessions_customer_status ON ChatSessions(customer_id, status);
CREATE INDEX IX_ChatSessions_status ON ChatSessions(status);
CREATE INDEX IX_ChatMessages_cursor ON ChatMessages(session_id, message_id) INCLUDE (sender_id, content, created_at);
GO

PRINT '=== All indexes created ===';
GO

-- =============================================
-- SEED DATA — CATEGORIES
-- 7 danh mục sự kiện phổ biến tại Việt Nam
-- =============================================
INSERT INTO Categories (name, slug, icon, description) VALUES
(N'Âm nhạc',    'music',      'fa-music',      N'Concert, liveshow, EDM festival, acoustic night'),
(N'Thể thao',   'sports',     'fa-futbol',     N'Bóng đá, marathon, tennis, esports'),
(N'Workshop',   'workshop',   'fa-laptop',     N'Hội thảo, khóa học, training chuyên môn'),
(N'Ẩm thực',    'food',       'fa-utensils',   N'Lễ hội ẩm thực, food tour, cooking class'),
(N'Nghệ thuật', 'art',        'fa-palette',    N'Triển lãm, kịch, múa ballet, gallery'),
(N'Kinh doanh', 'business',   'fa-briefcase',  N'Hội nghị, networking, startup pitch day'),
(N'Công nghệ',  'technology', 'fa-microchip',  N'Tech conference, hackathon, AI summit');
GO

-- =============================================
-- SEED DATA — USERS (12 users)
-- Mật khẩu BCrypt — dùng cho đăng nhập
-- admin@ticketbox.vn    / Admin@123
-- organizer@ticketbox.vn / Organizer@123
-- customer@ticketbox.vn  / Customer@123
-- (Tất cả user khác cũng dùng mật khẩu tương ứng role@123 pattern)
-- =============================================
INSERT INTO Users (email, password_hash, full_name, phone, gender, date_of_birth, role, avatar, is_active, email_verified, bio, website, social_facebook, social_instagram) VALUES
-- 1: Admin
('admin@ticketbox.vn',
 '$2a$12$odAx650SUPsEauwOWzajb.FUMCDzKZWYPLeG2.NlCs3NBxH2N/Pg.',
 N'Admin TicketBox', '0901234567', 'male', '1990-01-15', 'admin',
 'https://ui-avatars.com/api/?name=Admin&background=6366f1&color=fff&size=200',
 1, 1, N'Quản trị viên hệ thống TicketBox', NULL, NULL, NULL),

-- 2: Organizer — Live Nation VN
('organizer@ticketbox.vn',
 '$2a$12$Bs2nPLu8UK8GZsy1flBiGewDcqwu4x/KqtksjeYEWRQtcBxgiyNVC',
 N'Live Nation Vietnam', '0909876543', NULL, NULL, 'organizer',
 'https://ui-avatars.com/api/?name=LiveNation&background=10b981&color=fff&size=200',
 1, 1, N'Nhà tổ chức sự kiện giải trí hàng đầu Việt Nam. Chuyên tổ chức concert quốc tế & liveshow.',
 'https://livenation.vn', 'https://facebook.com/livenationvn', 'livenationvn'),

-- 3: Customer
('customer@ticketbox.vn',
 '$2a$12$07H.CL1nHx2kzH7oo1odGOClkIg/oK3s7.D/wxcRIL6xjhIo9sYhK',
 N'Nguyễn Văn An', '0912345678', 'male', '1998-05-20', 'customer',
 'https://ui-avatars.com/api/?name=An&background=3b82f6&color=fff&size=200',
 1, 1, NULL, NULL, NULL, NULL),

-- 4: Organizer — Vietravel Events
('events@vietravel.vn',
 '$2a$12$Bs2nPLu8UK8GZsy1flBiGewDcqwu4x/KqtksjeYEWRQtcBxgiyNVC',
 N'Vietravel Events', '0283456789', NULL, NULL, 'organizer',
 'https://ui-avatars.com/api/?name=Vietravel&background=f59e0b&color=fff&size=200',
 1, 1, N'Đơn vị tổ chức sự kiện du lịch & ẩm thực lớn nhất Việt Nam.',
 'https://vietravel.com', 'https://facebook.com/vietravel', 'vietravelevents'),

-- 5: Customer — Trần Thị Bình
('binh.tran@gmail.com',
 '$2a$12$07H.CL1nHx2kzH7oo1odGOClkIg/oK3s7.D/wxcRIL6xjhIo9sYhK',
 N'Trần Thị Bình', '0987654321', 'female', '2000-08-12', 'customer',
 'https://ui-avatars.com/api/?name=Binh&background=ec4899&color=fff&size=200',
 1, 1, NULL, NULL, NULL, NULL),

-- 6: Customer — Lê Hoàng Cường
('cuong.le@yahoo.com',
 '$2a$12$07H.CL1nHx2kzH7oo1odGOClkIg/oK3s7.D/wxcRIL6xjhIo9sYhK',
 N'Lê Hoàng Cường', '0976543210', 'male', '1995-12-03', 'customer',
 'https://ui-avatars.com/api/?name=Cuong&background=8b5cf6&color=fff&size=200',
 1, 1, NULL, NULL, NULL, NULL),

-- 7: Organizer — TechViet
('hello@techviet.org',
 '$2a$12$Bs2nPLu8UK8GZsy1flBiGewDcqwu4x/KqtksjeYEWRQtcBxgiyNVC',
 N'TechViet Community', '0281234567', NULL, NULL, 'organizer',
 'https://ui-avatars.com/api/?name=TechViet&background=06b6d4&color=fff&size=200',
 1, 1, N'Cộng đồng công nghệ Việt Nam — Tổ chức hackathon, tech talk, và hội nghị IT.',
 'https://techviet.org', 'https://facebook.com/techviet', 'techviet.community'),

-- 8: Customer — Phạm Minh Đức
('duc.pham@outlook.com',
 '$2a$12$07H.CL1nHx2kzH7oo1odGOClkIg/oK3s7.D/wxcRIL6xjhIo9sYhK',
 N'Phạm Minh Đức', '0965432109', 'male', '1997-03-25', 'customer',
 'https://ui-avatars.com/api/?name=Duc&background=14b8a6&color=fff&size=200',
 1, 1, NULL, NULL, NULL, NULL),

-- 9: Support Agent
('support@ticketbox.vn',
 '$2a$12$odAx650SUPsEauwOWzajb.FUMCDzKZWYPLeG2.NlCs3NBxH2N/Pg.',
 N'Hỗ trợ viên TicketBox', '0901111222', 'female', '1993-07-10', 'support_agent',
 'https://ui-avatars.com/api/?name=Support&background=f43f5e&color=fff&size=200',
 1, 1, N'Nhân viên hỗ trợ khách hàng', NULL, NULL, NULL),

-- 10: Customer — Vũ Thị Hà
('ha.vu@gmail.com',
 '$2a$12$07H.CL1nHx2kzH7oo1odGOClkIg/oK3s7.D/wxcRIL6xjhIo9sYhK',
 N'Vũ Thị Hà', '0945678901', 'female', '2001-11-08', 'customer',
 'https://ui-avatars.com/api/?name=Ha&background=a855f7&color=fff&size=200',
 1, 1, NULL, NULL, NULL, NULL),

-- 11: Customer — Đỗ Quang Khải
('khai.do@gmail.com',
 '$2a$12$07H.CL1nHx2kzH7oo1odGOClkIg/oK3s7.D/wxcRIL6xjhIo9sYhK',
 N'Đỗ Quang Khải', '0934567890', 'male', '1999-04-16', 'customer',
 'https://ui-avatars.com/api/?name=Khai&background=0ea5e9&color=fff&size=200',
 1, 1, NULL, NULL, NULL, NULL),

-- 12: Organizer — Saigon Sports
('info@saigonsports.vn',
 '$2a$12$Bs2nPLu8UK8GZsy1flBiGewDcqwu4x/KqtksjeYEWRQtcBxgiyNVC',
 N'Saigon Sports Club', '0287654321', NULL, NULL, 'organizer',
 'https://ui-avatars.com/api/?name=SaigonSports&background=ef4444&color=fff&size=200',
 1, 1, N'Câu lạc bộ thể thao Sài Gòn — Marathon, bóng rổ, và các giải đấu thể thao cộng đồng.',
 'https://saigonsports.vn', 'https://facebook.com/saigonsports', 'saigonsportsclub');
GO

PRINT '=== 12 users seeded ===';
GO

-- =============================================
-- SEED DATA — PERMISSIONS & ROLE PERMISSIONS
-- =============================================
INSERT INTO Permissions (permission_key, permission_name, description, module) VALUES
('event.create',   'Create Event',   N'Tạo sự kiện mới',        'event'),
('event.edit',     'Edit Event',     N'Chỉnh sửa sự kiện',      'event'),
('event.delete',   'Delete Event',   N'Xóa sự kiện',            'event'),
('event.approve',  'Approve Event',  N'Phê duyệt sự kiện',      'event'),
('event.publish',  'Publish Event',  N'Xuất bản sự kiện',       'event'),
('event.feature',  'Feature Event',  N'Đánh dấu nổi bật',      'event'),
('order.view',     'View Orders',    N'Xem đơn hàng',           'order'),
('order.refund',   'Refund Order',   N'Hoàn tiền',              'order'),
('order.export',   'Export Orders',  N'Xuất báo cáo',           'order'),
('user.view',      'View Users',     N'Xem người dùng',         'user'),
('user.manage',    'Manage Users',   N'Quản lý người dùng',     'user'),
('user.ban',       'Ban Users',      N'Khóa tài khoản',         'user'),
('report.view',    'View Reports',   N'Xem báo cáo',            'report'),
('report.revenue', 'Revenue Report', N'Báo cáo doanh thu',      'report'),
('settings.manage','Manage Settings',N'Quản lý cài đặt',        'setting'),
('media.upload',   'Upload Media',   N'Tải lên media',          'media'),
('media.delete',   'Delete Media',   N'Xóa media',              'media');

INSERT INTO RolePermissions (role, permission_id)
SELECT 'admin', permission_id FROM Permissions;

INSERT INTO RolePermissions (role, permission_id)
SELECT 'organizer', permission_id FROM Permissions
WHERE permission_key IN ('event.create','event.edit','event.publish','order.view','order.export','report.view','report.revenue','media.upload','media.delete');

INSERT INTO RolePermissions (role, permission_id)
SELECT 'customer', permission_id FROM Permissions
WHERE permission_key IN ('order.view','media.upload');
GO

-- =============================================
-- SEED DATA — 20 EVENTS (Dữ liệu thật Việt Nam)
-- organizer_id=2 (Live Nation), 4 (Vietravel), 7 (TechViet), 12 (Saigon Sports)
-- Hình ảnh sử dụng Unsplash (public domain)
-- =============================================
INSERT INTO Events (organizer_id, category_id, title, slug, short_description, description, banner_image, location, address, start_date, end_date, status, is_featured, views, pin_order, display_priority) VALUES
-- === ÂM NHẠC (category_id = 1) ===
(2, 1,
 N'Hà Anh Tuấn — Truyện Ngắn Concert 2026',
 'ha-anh-tuan-truyen-ngan-2026',
 N'Concert quy mô lớn của Hà Anh Tuấn tại SVĐ Mỹ Đình, Hà Nội.',
 N'<h2>Truyện Ngắn Concert 2026</h2>
<p>Sau thành công vang dội của series Truyện Ngắn, Hà Anh Tuấn quay trở lại với đêm nhạc đặc biệt tại SVĐ Quốc gia Mỹ Đình.</p>
<h3>Highlights</h3>
<ul>
<li>Dàn nhạc giao hưởng 60 người</li>
<li>Sân khấu 360 độ với công nghệ LED mapping</li>
<li>Khách mời đặc biệt: Mỹ Tâm, Phan Mạnh Quỳnh</li>
<li>Trải nghiệm VIP lounge với đồ uống miễn phí</li>
</ul>
<h3>Lưu ý</h3>
<p>Vé đã mua không hoàn lại. Check-in bằng QR code từ 17:00.</p>',
 'https://images.unsplash.com/photo-1501281668745-f7f57925c3b4?w=800',
 N'SVĐ Quốc gia Mỹ Đình', N'Đường Lê Đức Thọ, Nam Từ Liêm, Hà Nội',
 '2026-04-20 19:00:00', '2026-04-20 22:30:00', 'approved', 1, 12500, 5, 100),

(2, 1,
 N'Mỹ Tâm — My Soul 1981 Liveshow',
 'my-tam-my-soul-1981-liveshow',
 N'Đẳng cấp nữ hoàng Vpop — liveshow kỷ niệm 25 năm ca hát.',
 N'<h2>My Soul 1981 — Liveshow kỷ niệm 25 năm</h2>
<p>Mỹ Tâm mang đến đêm nhạc xúc động với hơn 40 ca khúc xuyên suốt sự nghiệp.</p>
<h3>Chương trình</h3>
<ul>
<li>Phần 1: Những bài hát đầu tiên (2001-2010)</li>
<li>Phần 2: Đỉnh cao sự nghiệp (2010-2020)</li>
<li>Phần 3: Tương lai và những dự án mới</li>
</ul>',
 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=800',
 N'Nhà hát Hòa Bình', N'240 Đường 3/2, Quận 10, TP.HCM',
 '2026-05-10 19:30:00', '2026-05-10 23:00:00', 'approved', 1, 8700, 4, 95),

(2, 1,
 N'Sơn Tùng M-TP — Sky Tour 2026',
 'son-tung-mtp-sky-tour-2026',
 N'Chuyến lưu diễn toàn quốc của Sơn Tùng M-TP.',
 N'<h2>Sky Tour 2026</h2>
<p>Sơn Tùng M-TP cùng ban nhạc và dancer trở lại sân khấu sau 2 năm vắng bóng.</p>
<p>Sân khấu hoành tráng, hiệu ứng laser & pyro đỉnh cao.</p>',
 'https://images.unsplash.com/photo-1470229722913-7c0e2dbbafd3?w=800',
 N'Phú Thọ Stadium', N'1 Lý Thường Kiệt, Quận 11, TP.HCM',
 '2026-06-15 19:00:00', '2026-06-15 22:00:00', 'approved', 1, 22000, 3, 90),

(2, 1,
 N'Đêm nhạc Acoustic — Bên Nhau Trọn Đời',
 'dem-nhac-acoustic-ben-nhau-tron-doi',
 N'Đêm nhạc acoustic lãng mạn dành cho các cặp đôi.',
 N'<h2>Acoustic Night — Bên Nhau Trọn Đời</h2>
<p>Không gian ấm cúng với tiếng guitar, piano và giọng hát ngọt ngào.</p>
<ul><li>Bùi Anh Tuấn</li><li>Văn Mai Hương</li><li>Vũ.</li></ul>',
 'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=800',
 N'Saigon Opera House', N'7 Lam Sơn, Quận 1, TP.HCM',
 '2026-03-28 20:00:00', '2026-03-28 22:30:00', 'approved', 0, 3200, 0, 70),

(2, 1,
 N'EDM Rave — Neon Jungle Festival',
 'edm-rave-neon-jungle-2026',
 N'Đại tiệc EDM với DJ quốc tế — Tiësto, Martin Garrix.',
 N'<h2>Neon Jungle Festival 2026</h2>
<p>Festival EDM lớn nhất Đông Nam Á lần đầu tổ chức tại Việt Nam!</p>
<h3>Line-up</h3>
<ul><li>Tiësto</li><li>Martin Garrix</li><li>DJ Snake</li><li>Hoaprox</li></ul>',
 'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=800',
 N'Đại Nam Wonderland', N'Bình Dương',
 '2026-07-04 17:00:00', '2026-07-05 02:00:00', 'pending', 0, 0, 0, 0),

-- === THỂ THAO (category_id = 2) ===
(12, 2,
 N'Vietnam Marathon — Đà Nẵng 2026',
 'vietnam-marathon-da-nang-2026',
 N'Giải marathon quốc tế lớn nhất tại thành phố đáng sống.',
 N'<h2>Vietnam Marathon — Đà Nẵng 2026</h2>
<p>Chạy dọc bờ biển Mỹ Khê thơ mộng với 3 cự ly: 5K, 21K Half, 42K Full.</p>
<h3>Cự ly & Thời gian xuất phát</h3>
<ul>
<li>42K Full Marathon: 04:30</li>
<li>21K Half Marathon: 05:00</li>
<li>5K Fun Run: 06:00</li>
</ul>
<p>Có huy chương finisher, bib number cá nhân hóa, và tiệc bia sau race.</p>',
 'https://images.unsplash.com/photo-1513593771513-7b58b6c4af38?w=800',
 N'Biển Mỹ Khê, Đà Nẵng', N'Đường Võ Nguyên Giáp, Sơn Trà, Đà Nẵng',
 '2026-05-03 04:30:00', '2026-05-03 12:00:00', 'approved', 1, 6800, 2, 85),

(12, 2,
 N'Giải bóng rổ 3x3 Saigon Open',
 'bong-ro-3x3-saigon-open-2026',
 N'Giải bóng rổ đường phố 3x3 hấp dẫn nhất Sài Gòn.',
 N'<h2>Bóng rổ 3x3 Saigon Open 2026</h2>
<p>64 đội tranh tài, giải thưởng 200 triệu đồng. Format thi đấu theo luật FIBA 3x3.</p>',
 'https://images.unsplash.com/photo-1546519638-68e109498ffc?w=800',
 N'Nhà thi đấu Phú Thọ', N'1 Lý Thường Kiệt, Quận 11, TP.HCM',
 '2026-04-12 08:00:00', '2026-04-13 18:00:00', 'approved', 0, 2100, 0, 60),

(12, 2,
 N'Saigon Night Run 10K',
 'saigon-night-run-10k-2026',
 N'Chạy đêm qua các con phố lung linh Sài Gòn.',
 N'<h2>Saigon Night Run 10K</h2>
<p>Trải nghiệm chạy bộ 10km xuyên trung tâm TP.HCM vào ban đêm.</p>',
 'https://images.unsplash.com/photo-1552674605-db6ffd4facb5?w=800',
 N'Phố đi bộ Nguyễn Huệ', N'Nguyễn Huệ, Quận 1, TP.HCM',
 '2026-03-22 19:00:00', '2026-03-22 22:00:00', 'approved', 0, 4500, 0, 65),

-- === WORKSHOP (category_id = 3) ===
(7, 3,
 N'Workshop UI/UX Design — Từ Zero đến Portfolio',
 'workshop-uiux-zero-to-portfolio',
 N'2 ngày thực hành Figma, Design System với mentor từ Google & Grab.',
 N'<h2>UI/UX Workshop: Zero → Portfolio</h2>
<p>Khóa workshop chuyên sâu 2 ngày, thực hành trên project thật.</p>
<h3>Nội dung</h3>
<ul>
<li>Ngày 1: UX Research, Wireframe, User Flow</li>
<li>Ngày 2: Visual Design, Figma Prototype, Portfolio Review</li>
</ul>
<h3>Mentor</h3>
<ul><li>Nguyễn Quốc Huy — Ex-Google UX Designer</li><li>Trần Minh Anh — Grab Design Lead</li></ul>',
 'https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=800',
 N'Dreamplex Coworking', N'21 Nguyễn Trung Ngạn, Quận 1, TP.HCM',
 '2026-04-05 09:00:00', '2026-04-06 17:00:00', 'approved', 1, 3400, 0, 80),

(7, 3,
 N'Data Science Bootcamp — Python cho người mới',
 'data-science-bootcamp-python-2026',
 N'3 buổi tối học Python, Pandas, Matplotlib từ cơ bản.',
 N'<h2>Data Science Bootcamp</h2>
<p>Khóa học 3 buổi tối dành cho người mới bắt đầu với Data Science.</p>',
 'https://images.unsplash.com/photo-1504384308090-c894fdcc538d?w=800',
 N'Campus Tòa nhà Landmark', N'Vinhomes Central Park, Bình Thạnh, TP.HCM',
 '2026-04-15 18:30:00', '2026-04-17 21:00:00', 'approved', 0, 1800, 0, 55),

-- === ẨM THỰC (category_id = 4) ===
(4, 4,
 N'Lễ hội Ẩm thực Đường phố Sài Gòn 2026',
 'le-hoi-am-thuc-duong-pho-saigon-2026',
 N'100+ gian hàng — Món ngon 3 miền & quốc tế.',
 N'<h2>Street Food Festival Saigon 2026</h2>
<p>Lễ hội ẩm thực lớn nhất năm với hơn 100 gian hàng từ Bắc-Trung-Nam và ẩm thực quốc tế.</p>
<h3>Điểm nhấn</h3>
<ul>
<li>Khu Phở & Bún đặc sản</li>
<li>Khu BBQ & Hải sản tươi sống</li>
<li>Khu Quốc tế: Nhật, Hàn, Thái</li>
<li>Sân khấu ca nhạc acoustic mỗi tối</li>
<li>Cuộc thi ăn nhanh với giải thưởng hấp dẫn</li>
</ul>',
 'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=800',
 N'Công viên 23/9', N'Phạm Ngũ Lão, Quận 1, TP.HCM',
 '2026-05-01 10:00:00', '2026-05-04 22:00:00', 'approved', 1, 9200, 0, 88),

(4, 4,
 N'Cooking Class — Phở Bò Hà Nội Truyền Thống',
 'cooking-class-pho-bo-ha-noi',
 N'Học nấu phở bò Hà Nội chuẩn vị với đầu bếp 30 năm kinh nghiệm.',
 N'<h2>Cooking Class: Phở Bò Hà Nội</h2>
<p>Buổi học nấu ăn 3 tiếng, bao gồm nguyên liệu và thưởng thức tại chỗ.</p>',
 'https://images.unsplash.com/photo-1503764654157-72d979d9af2f?w=800',
 N'Cooking Studio Saigon', N'15 Lý Tự Trọng, Quận 1, TP.HCM',
 '2026-03-30 09:00:00', '2026-03-30 12:00:00', 'approved', 0, 1200, 0, 45),

-- === NGHỆ THUẬT (category_id = 5) ===
(2, 5,
 N'Triển lãm Nghệ thuật Đương đại — Beyond Borders',
 'trien-lam-nghe-thuat-beyond-borders',
 N'30 nghệ sĩ Việt Nam & quốc tế — Hội họa, điêu khắc, digital art.',
 N'<h2>Beyond Borders — Contemporary Art Exhibition</h2>
<p>Triển lãm nghệ thuật đương đại kết hợp truyền thống Việt Nam và hiện đại quốc tế.</p>
<h3>Các khu vực</h3>
<ul>
<li>Main Gallery: Hội họa & Điêu khắc</li>
<li>Digital Room: Immersive Art Experience</li>
<li>Workshop Zone: Vẽ tranh cùng nghệ sĩ</li>
</ul>',
 'https://images.unsplash.com/photo-1531243269054-5ebf6f34081e?w=800',
 N'Bảo tàng Mỹ thuật TP.HCM', N'97A Phó Đức Chính, Quận 1, TP.HCM',
 '2026-04-01 09:00:00', '2026-04-30 18:00:00', 'approved', 0, 5600, 0, 72),

(2, 5,
 N'Nhà hát Kịch — Tấm Cám: The Musical',
 'tam-cam-the-musical-2026',
 N'Vở nhạc kịch cổ tích Việt Nam hoành tráng nhất năm 2026.',
 N'<h2>Tấm Cám: The Musical</h2>
<p>Câu chuyện cổ tích Việt Nam được kể lại bằng nhạc kịch hiện đại với dàn diễn viên 50 người.</p>',
 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=800',
 N'Nhà hát Lớn Hà Nội', N'1 Tràng Tiền, Hoàn Kiếm, Hà Nội',
 '2026-05-20 19:30:00', '2026-05-20 21:30:00', 'approved', 0, 2800, 0, 68),

-- === KINH DOANH (category_id = 6) ===
(7, 6,
 N'Startup Pitch Day — Vietnam Founders Summit',
 'startup-pitch-day-vietnam-founders-2026',
 N'20 startup Việt pitch trước 50+ nhà đầu tư — Demo Day lớn nhất Q2/2026.',
 N'<h2>Vietnam Founders Summit 2026</h2>
<p>Sự kiện kết nối startup với nhà đầu tư, mentor và đối tác chiến lược.</p>
<h3>Agenda</h3>
<ul>
<li>09:00 — Keynote: Future of Vietnam Tech Ecosystem</li>
<li>10:00 — Startup Pitches (Vòng 1: 20 startup x 5 phút)</li>
<li>14:00 — Top 8 Final Pitch</li>
<li>16:00 — Investor Networking Cocktail</li>
</ul>',
 'https://images.unsplash.com/photo-1475721027785-f74eccf877e2?w=800',
 N'GEM Center', N'8 Nguyễn Bỉnh Khiêm, Quận 1, TP.HCM',
 '2026-05-15 09:00:00', '2026-05-15 18:00:00', 'approved', 0, 4100, 0, 75),

(4, 6,
 N'Hội nghị Du lịch & Hospitality Vietnam 2026',
 'hoi-nghi-du-lich-hospitality-2026',
 N'Xu hướng du lịch 2026-2030, AI trong hospitality.',
 N'<h2>Tourism & Hospitality Conference</h2>
<p>Diễn giả từ Marriott, Accor, Vinpearl chia sẻ xu hướng ngành du lịch.</p>',
 'https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=800',
 N'Vinpearl Luxury Landmark 81', N'Landmark 81, Bình Thạnh, TP.HCM',
 '2026-06-10 08:30:00', '2026-06-11 17:00:00', 'pending', 0, 0, 0, 0),

-- === CÔNG NGHỆ (category_id = 7) ===
(7, 7,
 N'Vietnam AI Summit 2026',
 'vietnam-ai-summit-2026',
 N'Hội nghị AI lớn nhất Việt Nam — Speakers từ OpenAI, Google DeepMind.',
 N'<h2>Vietnam AI Summit 2026</h2>
<p>Sự kiện quy tụ chuyên gia AI hàng đầu thế giới tại Việt Nam.</p>
<h3>Topics</h3>
<ul>
<li>LLM & Generative AI in Production</li>
<li>AI in Healthcare & FinTech</li>
<li>Responsible AI & Ethics</li>
<li>Hands-on Workshop: Fine-tuning Open-Source Models</li>
</ul>',
 'https://images.unsplash.com/photo-1485827404703-89b55fcc595e?w=800',
 N'Trung tâm Hội nghị GEM', N'8 Nguyễn Bỉnh Khiêm, Quận 1, TP.HCM',
 '2026-06-20 08:00:00', '2026-06-21 17:00:00', 'approved', 1, 7500, 1, 92),

(7, 7,
 N'Hackathon — Build for Vietnam 2026',
 'hackathon-build-for-vietnam-2026',
 N'48 giờ code non-stop — Giải thưởng 500 triệu đồng.',
 N'<h2>Build for Vietnam Hackathon</h2>
<p>48 giờ xây dựng sản phẩm công nghệ giải quyết vấn đề thực tế tại Việt Nam.</p>
<h3>Tracks</h3>
<ul>
<li>FinTech — Tài chính số cho người dân</li>
<li>HealthTech — Y tế thông minh</li>
<li>EdTech — Giáo dục online</li>
<li>Open Track — Tự chọn</li>
</ul>',
 'https://images.unsplash.com/photo-1504384764586-bb4cdc1707b0?w=800',
 N'VNG Campus', N'182 Lê Đại Hành, Quận 11, TP.HCM',
 '2026-05-24 09:00:00', '2026-05-26 17:00:00', 'approved', 0, 3900, 0, 78),

-- === SỰ KIỆN BỊ TỪ CHỐI ===
(2, 1,
 N'Karaoke Đại Hội — Event Test',
 'karaoke-dai-hoi-test',
 N'Sự kiện test bị từ chối.',
 N'<p>Nội dung không phù hợp.</p>',
 'https://images.unsplash.com/photo-1516450360452-9312f5e86fc7?w=800',
 N'Quán Karaoke ABC', N'123 Nguyễn Trãi, Quận 5, TP.HCM',
 '2026-03-01 20:00:00', '2026-03-01 23:00:00', 'rejected', 0, 50, 0, 0),

-- === DRAFT ===
(2, 1,
 N'Year End Party 2026 (Draft)',
 'year-end-party-2026-draft',
 N'Đang chuẩn bị — chưa hoàn thiện.',
 N'<p>Nội dung đang soạn...</p>',
 NULL,
 N'TBD', N'TBD',
 '2026-12-31 19:00:00', '2027-01-01 02:00:00', 'draft', 0, 0, 0, 0);
GO

-- Cập nhật rejection_reason cho event bị từ chối
UPDATE Events SET rejection_reason = N'Nội dung sự kiện không đủ thông tin. Vui lòng bổ sung mô tả chi tiết, hình ảnh chất lượng cao, và thông tin đầy đủ về nghệ sĩ/diễn giả.',
    rejected_at = '2026-02-28 14:30:00'
WHERE slug = 'karaoke-dai-hoi-test';
GO

PRINT '=== 20 events seeded ===';
GO

-- =============================================
-- SEED DATA — TICKET TYPES (2-3 loại vé mỗi event)
-- =============================================
INSERT INTO TicketTypes (event_id, name, description, price, quantity, sold_quantity, color_theme, sale_start, sale_end) VALUES
-- Event 1: Hà Anh Tuấn Concert
(1, N'SVIP Diamond',      N'Hàng đầu sát sân khấu + Backstage Meet & Greet + Quà lưu niệm có chữ ký', 5000000, 50, 48, '#FFD700', '2026-01-15', '2026-04-19'),
(1, N'VIP Gold',           N'Khu vực VIP trung tâm + Đồ uống miễn phí tại lounge',                      3000000, 200, 195, '#FFA500', '2026-01-15', '2026-04-19'),
(1, N'Thường - CAT1',     N'Khu vực tầng 1 gần sân khấu',                                                1500000, 500, 420, '#4A90D9', '2026-01-15', '2026-04-20'),
(1, N'Thường - CAT2',     N'Khu vực tầng 2',                                                              800000, 1000, 650, '#6B8E23', '2026-01-15', '2026-04-20'),

-- Event 2: Mỹ Tâm Liveshow
(2, N'VIP Hàng Đầu',      N'Hàng ghế 1-5, góc nhìn hoàn hảo + Poster có chữ ký',                        3500000, 100, 97, '#E74C3C', '2026-02-01', '2026-05-09'),
(2, N'Hạng A',             N'Hàng ghế 6-15, khu trung tâm',                                                2000000, 300, 245, '#3498DB', '2026-02-01', '2026-05-09'),
(2, N'Hạng B',             N'Hàng ghế 16+, hai bên cánh',                                                  1000000, 500, 380, '#2ECC71', '2026-02-01', '2026-05-10'),

-- Event 3: Sơn Tùng Sky Tour
(3, N'Diamond',            N'Front row + Fan meeting + Photo with artist',                                 6000000, 30, 30, '#FFD700', '2026-03-01', '2026-06-14'),
(3, N'Platinum',           N'Khu Standing gần sân khấu',                                                   3500000, 300, 280, '#C0C0C0', '2026-03-01', '2026-06-14'),
(3, N'Gold Standing',      N'Khu Standing trung tâm',                                                       2000000, 1000, 750, '#FFA500', '2026-03-01', '2026-06-15'),
(3, N'General Admission',  N'Vé vào cổng',                                                                  800000, 3000, 1800, '#4ECDC4', '2026-03-01', '2026-06-15'),

-- Event 4: Acoustic Bên Nhau
(4, N'Couple Seat',        N'Ghế đôi lãng mạn + Nến & hoa + 2 đồ uống',                                  1200000, 50, 35, '#FF69B4', '2026-02-15', '2026-03-27'),
(4, N'Premium Seat',       N'Ghế đơn VIP',                                                                  600000, 100, 72, '#9B59B6', '2026-02-15', '2026-03-28'),
(4, N'Standard',           N'Ghế thường',                                                                    350000, 200, 140, '#1ABC9C', '2026-02-15', '2026-03-28'),

-- Event 5: EDM Neon Jungle (pending — chưa bán)
(5, N'Early Bird',         N'Giá ưu đãi đặt sớm (số lượng có hạn)',                                       800000, 500, 0, '#FF6B6B', '2026-04-01', '2026-05-31'),
(5, N'GA Festival Pass',   N'Vé 2 ngày toàn bộ khu vực',                                                    1500000, 5000, 0, '#4ECDC4', '2026-04-01', '2026-07-03'),
(5, N'VIP All Access',     N'VIP lounge + DJ backstage meet',                                               4000000, 200, 0, '#FFD700', '2026-04-01', '2026-07-03'),

-- Event 6: Vietnam Marathon
(6, N'42K Full Marathon',  N'Cự ly full marathon — Bao gồm bib, huy chương, áo finisher',                  1200000, 2000, 1750, '#E74C3C', '2026-01-01', '2026-05-01'),
(6, N'21K Half Marathon',  N'Cự ly bán marathon — Bib, huy chương, áo race',                                 800000, 3000, 2600, '#F39C12', '2026-01-01', '2026-05-01'),
(6, N'5K Fun Run',         N'Chạy vui cho mọi lứa tuổi — Bib, huy chương',                                  300000, 5000, 4200, '#2ECC71', '2026-01-01', '2026-05-02'),

-- Event 7: Bóng rổ 3x3
(7, N'Đội tham gia',       N'Phí đăng ký cho 1 đội (3-4 người)',                                            500000, 64, 52, '#FF6B6B', '2026-02-01', '2026-04-10'),
(7, N'Khán giả',           N'Vé vào xem miễn phí (đăng ký để nhận ghế)',                                      0, 500, 380, '#4ECDC4', '2026-02-01', '2026-04-12'),

-- Event 8: Saigon Night Run 10K
(8, N'Runner 10K',         N'Bao gồm bib, huy chương, áo chạy đêm phát quang',                              400000, 3000, 2500, '#9B59B6', '2026-01-15', '2026-03-21'),

-- Event 9: Workshop UI/UX
(9, N'Early Bird',          N'Vé ưu đãi đặt sớm 2 ngày',                                                     800000, 30, 30, '#FF6B6B', '2026-02-01', '2026-03-15'),
(9, N'Standard 2 Days',    N'Vé tiêu chuẩn 2 ngày workshop',                                                 1200000, 50, 38, '#3498DB', '2026-03-16', '2026-04-04'),
(9, N'Student',            N'Vé sinh viên (cần CCCD xác minh)',                                                500000, 20, 15, '#2ECC71', '2026-02-01', '2026-04-04'),

-- Event 10: Data Science Bootcamp
(10, N'Full Bootcamp',     N'3 buổi tối + Tài liệu + Certificate',                                           600000, 40, 28, '#E74C3C', '2026-03-01', '2026-04-14'),
(10, N'Single Session',    N'1 buổi tối (chọn ngày)',                                                         250000, 60, 35, '#3498DB', '2026-03-01', '2026-04-14'),

-- Event 11: Lễ hội Ẩm thực
(11, N'Vé ngày thường',    N'Vé vào cổng 1 ngày (Thứ 2-5)',                                                     50000, 5000, 3800, '#2ECC71', '2026-03-01', '2026-05-04'),
(11, N'Vé cuối tuần',      N'Vé vào cổng 1 ngày (Thứ 6-CN)',                                                    80000, 5000, 4200, '#F39C12', '2026-03-01', '2026-05-04'),
(11, N'VIP Passport 4 ngày', N'Vé all-access 4 ngày + Voucher ăn uống 200K',                                   250000, 500, 420, '#E74C3C', '2026-03-01', '2026-05-01'),

-- Event 12: Cooking Class Phở
(12, N'Học viên',           N'Bao gồm nguyên liệu + thưởng thức tại chỗ',                                     500000, 20, 16, '#FF6B6B', '2026-02-15', '2026-03-29'),

-- Event 13: Triển lãm Beyond Borders
(13, N'Vé tham quan',      N'Vé vào cổng 1 lần',                                                               100000, 3000, 1800, '#3498DB', '2026-03-01', '2026-04-30'),
(13, N'Workshop Pass',     N'Vé tham quan + 1 buổi workshop vẽ tranh',                                          300000, 200, 150, '#9B59B6', '2026-03-01', '2026-04-28'),

-- Event 14: Tấm Cám Musical
(14, N'Hạng Đặc biệt',    N'Hàng 1-3 + souvenirs',                                                            2000000, 60, 55, '#FFD700', '2026-03-01', '2026-05-19'),
(14, N'Hạng A',            N'Hàng 4-10',                                                                        1200000, 150, 120, '#E74C3C', '2026-03-01', '2026-05-19'),
(14, N'Hạng B',            N'Hàng 11-20',                                                                        700000, 300, 200, '#3498DB', '2026-03-01', '2026-05-20'),

-- Event 15: Startup Pitch Day
(15, N'Startup Team',      N'Phí đăng ký startup pitch (1 đội 3-5 người)',                                       0, 20, 18, '#FF6B6B', '2026-03-01', '2026-05-10'),
(15, N'Investor Pass',     N'Vé dành cho nhà đầu tư (có networking lunch)',                                       0, 50, 42, '#FFD700', '2026-03-01', '2026-05-14'),
(15, N'General Attendee',  N'Vé tham dự thường',                                                                  200000, 300, 250, '#2ECC71', '2026-03-01', '2026-05-14'),

-- Event 16: Hội nghị Du lịch (pending)
(16, N'Full Conference',   N'2 ngày hội nghị + lunch + networking dinner',                                      2500000, 200, 0, '#E74C3C', '2026-04-01', '2026-06-09'),
(16, N'Day Pass',          N'Vé 1 ngày',                                                                        1500000, 100, 0, '#3498DB', '2026-04-01', '2026-06-09'),

-- Event 17: Vietnam AI Summit
(17, N'VIP All-Access',    N'2 ngày + Workshop + Speaker Dinner + Certificate',                                   3000000, 100, 88, '#FFD700', '2026-03-01', '2026-06-19'),
(17, N'Standard',          N'2 ngày conference access',                                                           1500000, 400, 320, '#3498DB', '2026-03-01', '2026-06-19'),
(17, N'Student/Startup',   N'Vé ưu đãi cho sinh viên & startup (cần verify)',                                     500000, 200, 180, '#2ECC71', '2026-03-01', '2026-06-19'),

-- Event 18: Hackathon
(18, N'Team (3-5 người)',  N'Phí đăng ký 1 đội tham gia hackathon',                                               0, 100, 78, '#FF6B6B', '2026-03-01', '2026-05-22'),
(18, N'Mentor Pass',       N'Dành cho mentor hỗ trợ các đội',                                                      0, 30, 22, '#9B59B6', '2026-03-01', '2026-05-22');

-- Events 19, 20 (rejected/draft) — no ticket types needed
GO

PRINT '=== Ticket types seeded ===';
GO

-- =============================================
-- SEED DATA — ORDERS & ORDER ITEMS & TICKETS
-- 25 orders từ nhiều customer khác nhau
-- =============================================
DECLARE @now DATETIME = GETDATE();

-- Order 1: Customer 3 → Event 1 (Hà Anh Tuấn) — 2 VIP + 1 CAT1 = PAID
INSERT INTO Orders (order_code, user_id, event_id, total_amount, discount_amount, final_amount, status, payment_method, payment_date, buyer_name, buyer_email, buyer_phone, created_at)
VALUES ('ORD-2026-0001', 3, 1, 7500000, 0, 7500000, 'paid', 'seepay', DATEADD(DAY,-30,@now), N'Nguyễn Văn An', 'customer@ticketbox.vn', '0912345678', DATEADD(DAY,-30,@now));
INSERT INTO OrderItems (order_id, ticket_type_id, quantity, unit_price, subtotal) VALUES (1, 2, 2, 3000000, 6000000);
INSERT INTO OrderItems (order_id, ticket_type_id, quantity, unit_price, subtotal) VALUES (1, 3, 1, 1500000, 1500000);
INSERT INTO Tickets (ticket_code, order_item_id, attendee_name, attendee_email, qr_code, is_checked_in) VALUES
('TIX-HAT-001', 1, N'Nguyễn Văn An', 'customer@ticketbox.vn', 'TIX-HAT-001|EVT1|VIP|2026-04-20', 0),
('TIX-HAT-002', 1, N'Nguyễn Thị Mai', 'mai@gmail.com', 'TIX-HAT-002|EVT1|VIP|2026-04-20', 0),
('TIX-HAT-003', 2, N'Nguyễn Văn An', 'customer@ticketbox.vn', 'TIX-HAT-003|EVT1|CAT1|2026-04-20', 0);

-- Order 2: Customer 5 → Event 1 (Hà Anh Tuấn) — 1 SVIP = PAID
INSERT INTO Orders (order_code, user_id, event_id, total_amount, discount_amount, final_amount, status, payment_method, payment_date, buyer_name, buyer_email, buyer_phone, created_at)
VALUES ('ORD-2026-0002', 5, 1, 5000000, 0, 5000000, 'paid', 'seepay', DATEADD(DAY,-25,@now), N'Trần Thị Bình', 'binh.tran@gmail.com', '0987654321', DATEADD(DAY,-25,@now));
INSERT INTO OrderItems (order_id, ticket_type_id, quantity, unit_price, subtotal) VALUES (2, 1, 1, 5000000, 5000000);
INSERT INTO Tickets (ticket_code, order_item_id, attendee_name, attendee_email, qr_code) VALUES
('TIX-HAT-004', 3, N'Trần Thị Bình', 'binh.tran@gmail.com', 'TIX-HAT-004|EVT1|SVIP|2026-04-20');

-- Order 3: Customer 6 → Event 2 (Mỹ Tâm) — 2 Hạng A = PAID
INSERT INTO Orders (order_code, user_id, event_id, total_amount, discount_amount, final_amount, status, payment_method, payment_date, buyer_name, buyer_email, buyer_phone, created_at)
VALUES ('ORD-2026-0003', 6, 2, 4000000, 0, 4000000, 'paid', 'seepay', DATEADD(DAY,-20,@now), N'Lê Hoàng Cường', 'cuong.le@yahoo.com', '0976543210', DATEADD(DAY,-20,@now));
INSERT INTO OrderItems (order_id, ticket_type_id, quantity, unit_price, subtotal) VALUES (3, 6, 2, 2000000, 4000000);
INSERT INTO Tickets (ticket_code, order_item_id, attendee_name, attendee_email, qr_code) VALUES
('TIX-MTM-001', 4, N'Lê Hoàng Cường', 'cuong.le@yahoo.com', 'TIX-MTM-001|EVT2|A|2026-05-10'),
('TIX-MTM-002', 4, N'Lê Thị Lan', 'lan.le@gmail.com', 'TIX-MTM-002|EVT2|A|2026-05-10');

-- Order 4: Customer 3 → Event 3 (Sơn Tùng) — 2 Gold Standing = PAID
INSERT INTO Orders (order_code, user_id, event_id, total_amount, discount_amount, final_amount, status, payment_method, payment_date, buyer_name, buyer_email, buyer_phone, created_at)
VALUES ('ORD-2026-0004', 3, 3, 4000000, 0, 4000000, 'paid', 'seepay', DATEADD(DAY,-18,@now), N'Nguyễn Văn An', 'customer@ticketbox.vn', '0912345678', DATEADD(DAY,-18,@now));
INSERT INTO OrderItems (order_id, ticket_type_id, quantity, unit_price, subtotal) VALUES (4, 10, 2, 2000000, 4000000);
INSERT INTO Tickets (ticket_code, order_item_id, attendee_name, attendee_email, qr_code) VALUES
('TIX-STU-001', 5, N'Nguyễn Văn An', 'customer@ticketbox.vn', 'TIX-STU-001|EVT3|GOLD|2026-06-15'),
('TIX-STU-002', 5, N'Trần Minh Tú', 'tu.tran@gmail.com', 'TIX-STU-002|EVT3|GOLD|2026-06-15');

-- Order 5: Customer 8 → Event 6 (Marathon) — 1 Half = PAID
INSERT INTO Orders (order_code, user_id, event_id, total_amount, discount_amount, final_amount, status, payment_method, payment_date, buyer_name, buyer_email, buyer_phone, created_at)
VALUES ('ORD-2026-0005', 8, 6, 800000, 0, 800000, 'paid', 'seepay', DATEADD(DAY,-45,@now), N'Phạm Minh Đức', 'duc.pham@outlook.com', '0965432109', DATEADD(DAY,-45,@now));
INSERT INTO OrderItems (order_id, ticket_type_id, quantity, unit_price, subtotal) VALUES (5, 19, 1, 800000, 800000);
INSERT INTO Tickets (ticket_code, order_item_id, attendee_name, attendee_email, qr_code) VALUES
('TIX-MRT-001', 6, N'Phạm Minh Đức', 'duc.pham@outlook.com', 'TIX-MRT-001|EVT6|HALF|2026-05-03');

-- Order 6: Customer 10 → Event 6 (Marathon) — 1 Fun Run = PAID
INSERT INTO Orders (order_code, user_id, event_id, total_amount, discount_amount, final_amount, status, payment_method, payment_date, buyer_name, buyer_email, buyer_phone, created_at)
VALUES ('ORD-2026-0006', 10, 6, 300000, 0, 300000, 'paid', 'seepay', DATEADD(DAY,-40,@now), N'Vũ Thị Hà', 'ha.vu@gmail.com', '0945678901', DATEADD(DAY,-40,@now));
INSERT INTO OrderItems (order_id, ticket_type_id, quantity, unit_price, subtotal) VALUES (6, 20, 1, 300000, 300000);
INSERT INTO Tickets (ticket_code, order_item_id, attendee_name, attendee_email, qr_code) VALUES
('TIX-MRT-002', 7, N'Vũ Thị Hà', 'ha.vu@gmail.com', 'TIX-MRT-002|EVT6|5K|2026-05-03');

-- Order 7: Customer 11 → Event 9 (Workshop UI/UX) — 1 Standard = PAID
INSERT INTO Orders (order_code, user_id, event_id, total_amount, discount_amount, final_amount, status, payment_method, payment_date, buyer_name, buyer_email, buyer_phone, created_at)
VALUES ('ORD-2026-0007', 11, 9, 1200000, 0, 1200000, 'paid', 'seepay', DATEADD(DAY,-15,@now), N'Đỗ Quang Khải', 'khai.do@gmail.com', '0934567890', DATEADD(DAY,-15,@now));
INSERT INTO OrderItems (order_id, ticket_type_id, quantity, unit_price, subtotal) VALUES (7, 25, 1, 1200000, 1200000);
INSERT INTO Tickets (ticket_code, order_item_id, attendee_name, attendee_email, qr_code) VALUES
('TIX-UXW-001', 8, N'Đỗ Quang Khải', 'khai.do@gmail.com', 'TIX-UXW-001|EVT9|STD|2026-04-05');

-- Order 8: Customer 3 → Event 11 (Ẩm thực) — 2 VIP Passport = PAID
INSERT INTO Orders (order_code, user_id, event_id, total_amount, discount_amount, final_amount, status, payment_method, payment_date, buyer_name, buyer_email, buyer_phone, created_at)
VALUES ('ORD-2026-0008', 3, 11, 500000, 0, 500000, 'paid', 'seepay', DATEADD(DAY,-12,@now), N'Nguyễn Văn An', 'customer@ticketbox.vn', '0912345678', DATEADD(DAY,-12,@now));
INSERT INTO OrderItems (order_id, ticket_type_id, quantity, unit_price, subtotal) VALUES (8, 31, 2, 250000, 500000);
INSERT INTO Tickets (ticket_code, order_item_id, attendee_name, attendee_email, qr_code) VALUES
('TIX-FDF-001', 9, N'Nguyễn Văn An', 'customer@ticketbox.vn', 'TIX-FDF-001|EVT11|VIP|2026-05-01'),
('TIX-FDF-002', 9, N'Nguyễn Thị Mai', 'mai@gmail.com', 'TIX-FDF-002|EVT11|VIP|2026-05-01');

-- Order 9: Customer 5 → Event 17 (AI Summit) — 1 VIP = PAID
INSERT INTO Orders (order_code, user_id, event_id, total_amount, discount_amount, final_amount, status, payment_method, payment_date, buyer_name, buyer_email, buyer_phone, created_at)
VALUES ('ORD-2026-0009', 5, 17, 3000000, 0, 3000000, 'paid', 'seepay', DATEADD(DAY,-10,@now), N'Trần Thị Bình', 'binh.tran@gmail.com', '0987654321', DATEADD(DAY,-10,@now));
INSERT INTO OrderItems (order_id, ticket_type_id, quantity, unit_price, subtotal) VALUES (9, 43, 1, 3000000, 3000000);
INSERT INTO Tickets (ticket_code, order_item_id, attendee_name, attendee_email, qr_code) VALUES
('TIX-AIS-001', 10, N'Trần Thị Bình', 'binh.tran@gmail.com', 'TIX-AIS-001|EVT17|VIP|2026-06-20');

-- Order 10: Customer 6 → Event 8 (Night Run) — 2 Runner = PAID
INSERT INTO Orders (order_code, user_id, event_id, total_amount, discount_amount, final_amount, status, payment_method, payment_date, buyer_name, buyer_email, buyer_phone, created_at)
VALUES ('ORD-2026-0010', 6, 8, 800000, 0, 800000, 'paid', 'seepay', DATEADD(DAY,-35,@now), N'Lê Hoàng Cường', 'cuong.le@yahoo.com', '0976543210', DATEADD(DAY,-35,@now));
INSERT INTO OrderItems (order_id, ticket_type_id, quantity, unit_price, subtotal) VALUES (10, 23, 2, 400000, 800000);
INSERT INTO Tickets (ticket_code, order_item_id, attendee_name, attendee_email, qr_code) VALUES
('TIX-NR-001', 11, N'Lê Hoàng Cường', 'cuong.le@yahoo.com', 'TIX-NR-001|EVT8|10K|2026-03-22'),
('TIX-NR-002', 11, N'Lê Thị Lan', 'lan.le@gmail.com', 'TIX-NR-002|EVT8|10K|2026-03-22');

-- Order 11: Customer 8 → Event 4 (Acoustic) — 1 Couple Seat = PAID
INSERT INTO Orders (order_code, user_id, event_id, total_amount, discount_amount, final_amount, status, payment_method, payment_date, buyer_name, buyer_email, buyer_phone, created_at)
VALUES ('ORD-2026-0011', 8, 4, 1200000, 0, 1200000, 'paid', 'seepay', DATEADD(DAY,-8,@now), N'Phạm Minh Đức', 'duc.pham@outlook.com', '0965432109', DATEADD(DAY,-8,@now));
INSERT INTO OrderItems (order_id, ticket_type_id, quantity, unit_price, subtotal) VALUES (11, 12, 1, 1200000, 1200000);
INSERT INTO Tickets (ticket_code, order_item_id, attendee_name, attendee_email, qr_code) VALUES
('TIX-ACS-001', 12, N'Phạm Minh Đức & Ngọc Anh', 'duc.pham@outlook.com', 'TIX-ACS-001|EVT4|COUPLE|2026-03-28');

-- Order 12: Customer 10 → Event 13 (Triển lãm) — 1 Workshop Pass = PAID
INSERT INTO Orders (order_code, user_id, event_id, total_amount, discount_amount, final_amount, status, payment_method, payment_date, buyer_name, buyer_email, buyer_phone, created_at)
VALUES ('ORD-2026-0012', 10, 13, 300000, 0, 300000, 'paid', 'seepay', DATEADD(DAY,-5,@now), N'Vũ Thị Hà', 'ha.vu@gmail.com', '0945678901', DATEADD(DAY,-5,@now));
INSERT INTO OrderItems (order_id, ticket_type_id, quantity, unit_price, subtotal) VALUES (12, 34, 1, 300000, 300000);
INSERT INTO Tickets (ticket_code, order_item_id, attendee_name, attendee_email, qr_code) VALUES
('TIX-ART-001', 13, N'Vũ Thị Hà', 'ha.vu@gmail.com', 'TIX-ART-001|EVT13|WS|2026-04-15');

-- Order 13: Customer 11 → Event 14 (Tấm Cám) — 2 Hạng A = PAID
INSERT INTO Orders (order_code, user_id, event_id, total_amount, discount_amount, final_amount, status, payment_method, payment_date, buyer_name, buyer_email, buyer_phone, created_at)
VALUES ('ORD-2026-0013', 11, 14, 2400000, 0, 2400000, 'paid', 'seepay', DATEADD(DAY,-7,@now), N'Đỗ Quang Khải', 'khai.do@gmail.com', '0934567890', DATEADD(DAY,-7,@now));
INSERT INTO OrderItems (order_id, ticket_type_id, quantity, unit_price, subtotal) VALUES (13, 36, 2, 1200000, 2400000);
INSERT INTO Tickets (ticket_code, order_item_id, attendee_name, attendee_email, qr_code) VALUES
('TIX-TC-001', 14, N'Đỗ Quang Khải', 'khai.do@gmail.com', 'TIX-TC-001|EVT14|A|2026-05-20'),
('TIX-TC-002', 14, N'Đỗ Thị Hương', 'huong.do@gmail.com', 'TIX-TC-002|EVT14|A|2026-05-20');

-- Order 14: Customer 3 → Event 17 (AI Summit) — 1 Student = PAID (discounted)
INSERT INTO Orders (order_code, user_id, event_id, total_amount, discount_amount, final_amount, status, payment_method, payment_date, buyer_name, buyer_email, buyer_phone, created_at)
VALUES ('ORD-2026-0014', 3, 17, 500000, 0, 500000, 'paid', 'seepay', DATEADD(DAY,-3,@now), N'Nguyễn Văn An', 'customer@ticketbox.vn', '0912345678', DATEADD(DAY,-3,@now));
INSERT INTO OrderItems (order_id, ticket_type_id, quantity, unit_price, subtotal) VALUES (14, 45, 1, 500000, 500000);
INSERT INTO Tickets (ticket_code, order_item_id, attendee_name, attendee_email, qr_code) VALUES
('TIX-AIS-002', 15, N'Nguyễn Văn An', 'customer@ticketbox.vn', 'TIX-AIS-002|EVT17|STU|2026-06-20');

-- Order 15: Customer 5 → Event 15 (Startup Pitch) — 1 General = PAID
INSERT INTO Orders (order_code, user_id, event_id, total_amount, discount_amount, final_amount, status, payment_method, payment_date, buyer_name, buyer_email, buyer_phone, created_at)
VALUES ('ORD-2026-0015', 5, 15, 200000, 0, 200000, 'paid', 'seepay', DATEADD(DAY,-6,@now), N'Trần Thị Bình', 'binh.tran@gmail.com', '0987654321', DATEADD(DAY,-6,@now));
INSERT INTO OrderItems (order_id, ticket_type_id, quantity, unit_price, subtotal) VALUES (15, 40, 1, 200000, 200000);
INSERT INTO Tickets (ticket_code, order_item_id, attendee_name, attendee_email, qr_code) VALUES
('TIX-SPD-001', 16, N'Trần Thị Bình', 'binh.tran@gmail.com', 'TIX-SPD-001|EVT15|GA|2026-05-15');

-- Order 16: Customer 3 → Event 2 (Mỹ Tâm) — PENDING payment
INSERT INTO Orders (order_code, user_id, event_id, total_amount, discount_amount, final_amount, status, payment_method, payment_expires_at, buyer_name, buyer_email, buyer_phone, created_at)
VALUES ('ORD-2026-0016', 3, 2, 2000000, 0, 2000000, 'pending', 'seepay', DATEADD(HOUR,2,@now), N'Nguyễn Văn An', 'customer@ticketbox.vn', '0912345678', @now);
INSERT INTO OrderItems (order_id, ticket_type_id, quantity, unit_price, subtotal) VALUES (16, 6, 1, 2000000, 2000000);

-- Order 17: Customer 6 → Event 3 (Sơn Tùng) — CANCELLED
INSERT INTO Orders (order_code, user_id, event_id, total_amount, discount_amount, final_amount, status, payment_method, buyer_name, buyer_email, buyer_phone, created_at)
VALUES ('ORD-2026-0017', 6, 3, 800000, 0, 800000, 'cancelled', 'seepay', N'Lê Hoàng Cường', 'cuong.le@yahoo.com', '0976543210', DATEADD(DAY,-15,@now));
INSERT INTO OrderItems (order_id, ticket_type_id, quantity, unit_price, subtotal) VALUES (17, 11, 1, 800000, 800000);

-- Order 18: Customer 8 → Event 18 (Hackathon) — PAID (free ticket)
INSERT INTO Orders (order_code, user_id, event_id, total_amount, discount_amount, final_amount, status, payment_method, payment_date, buyer_name, buyer_email, buyer_phone, created_at)
VALUES ('ORD-2026-0018', 8, 18, 0, 0, 0, 'paid', 'cash', DATEADD(DAY,-4,@now), N'Phạm Minh Đức', 'duc.pham@outlook.com', '0965432109', DATEADD(DAY,-4,@now));
INSERT INTO OrderItems (order_id, ticket_type_id, quantity, unit_price, subtotal) VALUES (18, 46, 1, 0, 0);
INSERT INTO Tickets (ticket_code, order_item_id, attendee_name, attendee_email, qr_code) VALUES
('TIX-HKT-001', 19, N'Team Codecraft (Phạm Minh Đức, Nguyễn Hoàng, Lê Quỳnh)', 'duc.pham@outlook.com', 'TIX-HKT-001|EVT18|TEAM|2026-05-24');

-- Order 19: Customer 10 → Event 12 (Cooking Class) — PAID
INSERT INTO Orders (order_code, user_id, event_id, total_amount, discount_amount, final_amount, status, payment_method, payment_date, buyer_name, buyer_email, buyer_phone, created_at)
VALUES ('ORD-2026-0019', 10, 12, 500000, 0, 500000, 'paid', 'seepay', DATEADD(DAY,-9,@now), N'Vũ Thị Hà', 'ha.vu@gmail.com', '0945678901', DATEADD(DAY,-9,@now));
INSERT INTO OrderItems (order_id, ticket_type_id, quantity, unit_price, subtotal) VALUES (19, 32, 1, 500000, 500000);
INSERT INTO Tickets (ticket_code, order_item_id, attendee_name, attendee_email, qr_code) VALUES
('TIX-CK-001', 20, N'Vũ Thị Hà', 'ha.vu@gmail.com', 'TIX-CK-001|EVT12|STD|2026-03-30');

-- Order 20: Customer 3 → Event 10 (Data Science) — PAID
INSERT INTO Orders (order_code, user_id, event_id, total_amount, discount_amount, final_amount, status, payment_method, payment_date, buyer_name, buyer_email, buyer_phone, created_at)
VALUES ('ORD-2026-0020', 3, 10, 600000, 0, 600000, 'paid', 'seepay', DATEADD(DAY,-11,@now), N'Nguyễn Văn An', 'customer@ticketbox.vn', '0912345678', DATEADD(DAY,-11,@now));
INSERT INTO OrderItems (order_id, ticket_type_id, quantity, unit_price, subtotal) VALUES (20, 27, 1, 600000, 600000);
INSERT INTO Tickets (ticket_code, order_item_id, attendee_name, attendee_email, qr_code) VALUES
('TIX-DS-001', 21, N'Nguyễn Văn An', 'customer@ticketbox.vn', 'TIX-DS-001|EVT10|FULL|2026-04-15');
GO

PRINT '=== 20 orders + order items + tickets seeded ===';
GO

-- =============================================
-- SEED DATA — PAYMENT TRANSACTIONS
-- =============================================
INSERT INTO PaymentTransactions (order_id, payment_method, seepay_transaction_id, amount, status, completed_at) VALUES
(1,  'seepay', 'SP-202602-001', 7500000, 'completed', DATEADD(DAY,-30,GETDATE())),
(2,  'seepay', 'SP-202602-002', 5000000, 'completed', DATEADD(DAY,-25,GETDATE())),
(3,  'seepay', 'SP-202602-003', 4000000, 'completed', DATEADD(DAY,-20,GETDATE())),
(4,  'seepay', 'SP-202602-004', 4000000, 'completed', DATEADD(DAY,-18,GETDATE())),
(5,  'seepay', 'SP-202601-005', 800000,  'completed', DATEADD(DAY,-45,GETDATE())),
(6,  'seepay', 'SP-202601-006', 300000,  'completed', DATEADD(DAY,-40,GETDATE())),
(7,  'seepay', 'SP-202602-007', 1200000, 'completed', DATEADD(DAY,-15,GETDATE())),
(8,  'seepay', 'SP-202603-008', 500000,  'completed', DATEADD(DAY,-12,GETDATE())),
(9,  'seepay', 'SP-202603-009', 3000000, 'completed', DATEADD(DAY,-10,GETDATE())),
(10, 'seepay', 'SP-202602-010', 800000,  'completed', DATEADD(DAY,-35,GETDATE())),
(11, 'seepay', 'SP-202603-011', 1200000, 'completed', DATEADD(DAY,-8,GETDATE())),
(12, 'seepay', 'SP-202603-012', 300000,  'completed', DATEADD(DAY,-5,GETDATE())),
(13, 'seepay', 'SP-202603-013', 2400000, 'completed', DATEADD(DAY,-7,GETDATE())),
(14, 'seepay', 'SP-202603-014', 500000,  'completed', DATEADD(DAY,-3,GETDATE())),
(15, 'seepay', 'SP-202603-015', 200000,  'completed', DATEADD(DAY,-6,GETDATE())),
(16, 'seepay', NULL,            2000000, 'pending',   NULL),
(17, 'seepay', NULL,            800000,  'cancelled', NULL),
(19, 'seepay', 'SP-202603-019', 500000,  'completed', DATEADD(DAY,-9,GETDATE())),
(20, 'seepay', 'SP-202603-020', 600000,  'completed', DATEADD(DAY,-11,GETDATE()));
GO

PRINT '=== Payment transactions seeded ===';
GO

-- =============================================
-- SEED DATA — VOUCHERS
-- =============================================
INSERT INTO Vouchers (organizer_id, event_id, code, discount_type, discount_value, min_order_amount, max_uses, used_count, start_date, end_date, is_active) VALUES
(2, 1,    'HAT2026VIP',   'percentage', 10, 2000000, 50, 12,  '2026-01-15', '2026-04-20', 1),
(2, NULL, 'LIVENATION15', 'percentage', 15, 1000000, 100, 35, '2026-01-01', '2026-12-31', 1),
(7, 17,   'AITECH50K',    'fixed',      50000, 500000, 200, 88, '2026-03-01', '2026-06-20', 1),
(12, 6,   'RUN2026',      'fixed',      100000, 500000, 300, 150, '2026-01-01', '2026-05-01', 1),
(4, 11,   'FOODIE20',     'percentage', 20, 100000, 500, 210, '2026-04-01', '2026-05-04', 1);
GO

-- =============================================
-- SEED DATA — EVENT STAFF
-- =============================================
INSERT INTO EventStaff (event_id, user_id, role, granted_by) VALUES
(1, 3, 'checkin', 2),    -- Customer An is check-in staff for Hà Anh Tuấn concert
(1, 5, 'editor', 2),     -- Trần Thị Bình is editor
(6, 8, 'checkin', 12),   -- Phạm Minh Đức is check-in for marathon
(9, 11, 'editor', 7),    -- Đỗ Quang Khải is editor for UI/UX workshop
(17, 8, 'checkin', 7),   -- Đức is check-in for AI Summit
(17, 6, 'manager', 7);   -- Cường is manager for AI Summit
GO

-- =============================================
-- SEED DATA — SUPPORT TICKETS
-- =============================================
INSERT INTO SupportTickets (ticket_code, user_id, order_id, event_id, category, subject, description, status, priority, routed_to, assigned_to, created_at) VALUES
('SPT-001', 3, 1, 1, 'payment_error',
 N'Thanh toán thành công nhưng chưa nhận được vé',
 N'Tôi đã thanh toán đơn hàng ORD-2026-0001 thành công, tiền đã trừ nhưng sau 30 phút vẫn chưa nhận được email xác nhận vé. Mong hỗ trợ kiểm tra.',
 'resolved', 'high', 'admin', 9, DATEADD(DAY,-29,GETDATE())),

('SPT-002', 5, NULL, 2, 'event_issue',
 N'Hỏi về dress code cho liveshow Mỹ Tâm',
 N'Xin cho hỏi liveshow Mỹ Tâm My Soul có yêu cầu dress code gì không ạ? Khu VIP có tặng kèm đồ uống không? Cảm ơn BTC.',
 'closed', 'low', 'organizer', NULL, DATEADD(DAY,-19,GETDATE())),

('SPT-003', 6, 17, 3, 'cancellation',
 N'Yêu cầu hủy đơn hàng ORD-2026-0017',
 N'Do thay đổi lịch cá nhân, tôi không thể tham dự. Xin hủy đơn hàng và hoàn tiền. Mã giao dịch: ORD-2026-0017. Đã thanh toán qua SeePay.',
 'in_progress', 'normal', 'admin', 9, DATEADD(DAY,-14,GETDATE())),

('SPT-004', 8, NULL, 18, 'technical',
 N'Không tải được QR code vé Hackathon',
 N'App hiển thị QR code bị lỗi, chỉ hiện ô trắng. Tôi dùng Chrome trên Android 14. Đã thử clear cache nhưng vẫn lỗi.',
 'open', 'normal', 'admin', NULL, DATEADD(DAY,-3,GETDATE())),

('SPT-005', 10, NULL, NULL, 'feedback',
 N'Góp ý giao diện trang Vé của tôi',
 N'Giao diện trang Vé của tôi rất đẹp, nhưng em muốn có thêm tính năng filter theo trạng thái vé (đã check-in / chưa). Cảm ơn team!',
 'open', 'low', 'admin', NULL, DATEADD(DAY,-1,GETDATE()));
GO

-- Support Ticket Messages
INSERT INTO TicketMessages (ticket_id, sender_id, content, is_internal, created_at) VALUES
-- SPT-001 conversation
(1, 3, N'Tôi đã thanh toán đơn hàng ORD-2026-0001 thành công, tiền đã trừ nhưng sau 30 phút vẫn chưa nhận được email xác nhận vé. Screenshot đính kèm.', 0, DATEADD(DAY,-29,GETDATE())),
(1, 9, N'[Internal] Kiểm tra SeePay dashboard → Transaction SP-202602-001 status: completed. Vé đã phát hành trong DB. Nguyên nhân: email bị block bởi spam filter.', 1, DATEADD(DAY,-29,GETDATE())),
(1, 9, N'Chào anh An! Em đã kiểm tra và xác nhận đơn hàng đã thanh toán thành công. Vé đã được phát hành. Email xác nhận đã gửi lại, anh kiểm tra hộp thư (cả spam) nhé. Xin lỗi anh vì sự bất tiện!', 0, DATEADD(DAY,-29,GETDATE())),
(1, 3, N'Đã nhận được email rồi ạ. Cảm ơn hỗ trợ nhanh chóng!', 0, DATEADD(DAY,-28,GETDATE())),

-- SPT-003 conversation
(3, 6, N'Do thay đổi lịch, tôi cần hủy đơn ORD-2026-0017 và hoàn tiền. Cảm ơn.', 0, DATEADD(DAY,-14,GETDATE())),
(3, 9, N'Chào anh Cường, em đã tiếp nhận yêu cầu. Theo chính sách, việc hủy vé trước 7 ngày sẽ được hoàn 80% giá trị. Em sẽ xử lý trong 3-5 ngày làm việc ạ.', 0, DATEADD(DAY,-13,GETDATE()));
GO

-- =============================================
-- SEED DATA — CHAT SESSIONS & MESSAGES
-- =============================================
INSERT INTO ChatSessions (customer_id, agent_id, event_id, status, created_at, closed_at) VALUES
(3, 9, 1, 'closed', DATEADD(DAY,-28,GETDATE()), DATEADD(DAY,-28,GETDATE())),
(5, 9, NULL, 'closed', DATEADD(DAY,-18,GETDATE()), DATEADD(DAY,-18,GETDATE())),
(8, NULL, 18, 'waiting', DATEADD(HOUR,-2,GETDATE()), NULL);

INSERT INTO ChatMessages (session_id, sender_id, content, created_at) VALUES
-- Session 1: Customer 3 hỏi về vé
(1, 3, N'Xin chào, tôi muốn hỏi về vé VIP Gold cho concert Hà Anh Tuấn ạ', DATEADD(DAY,-28,GETDATE())),
(1, 9, N'Chào anh! Vé VIP Gold bao gồm chỗ ngồi khu VIP trung tâm và đồ uống miễn phí tại lounge. Giá 3.000.000đ/vé ạ.', DATEADD(DAY,-28,GETDATE())),
(1, 3, N'Lounge mở cửa từ mấy giờ ạ?', DATEADD(DAY,-28,GETDATE())),
(1, 9, N'VIP Lounge mở từ 17:00 nhé anh. Check-in sớm để tận hưởng đồ uống trước giờ show ạ!', DATEADD(DAY,-28,GETDATE())),
(1, 3, N'OK cảm ơn nhiều nhé!', DATEADD(DAY,-28,GETDATE())),

-- Session 2: Customer 5 general question
(2, 5, N'Mình muốn hỏi có chính sách hoàn vé không ạ?', DATEADD(DAY,-18,GETDATE())),
(2, 9, N'Chào bạn! Theo chính sách: Hủy trước 7 ngày → hoàn 80%, hủy 3-7 ngày trước → hoàn 50%, dưới 3 ngày → không hoàn. Bạn muốn hủy sự kiện nào ạ?', DATEADD(DAY,-18,GETDATE())),
(2, 5, N'Ồ, mình chỉ hỏi thôi ạ. Cảm ơn!', DATEADD(DAY,-18,GETDATE())),

-- Session 3: Customer 8 waiting (no agent yet)
(3, 8, N'QR code vé hackathon bị lỗi, không hiển thị được ạ', DATEADD(HOUR,-2,GETDATE()));
GO

PRINT '=== Support tickets + chat seeded ===';
GO

-- =============================================
-- VERIFICATION QUERIES
-- =============================================
PRINT '';
PRINT '============================================';
PRINT '  FULL RESET & SEED COMPLETE!';
PRINT '============================================';

SELECT 'Users' AS [Table], COUNT(*) AS [Rows] FROM Users UNION ALL
SELECT 'Categories', COUNT(*) FROM Categories UNION ALL
SELECT 'Events', COUNT(*) FROM Events UNION ALL
SELECT 'TicketTypes', COUNT(*) FROM TicketTypes UNION ALL
SELECT 'Orders', COUNT(*) FROM Orders UNION ALL
SELECT 'OrderItems', COUNT(*) FROM OrderItems UNION ALL
SELECT 'Tickets', COUNT(*) FROM Tickets UNION ALL
SELECT 'PaymentTransactions', COUNT(*) FROM PaymentTransactions UNION ALL
SELECT 'Vouchers', COUNT(*) FROM Vouchers UNION ALL
SELECT 'EventStaff', COUNT(*) FROM EventStaff UNION ALL
SELECT 'Permissions', COUNT(*) FROM Permissions UNION ALL
SELECT 'RolePermissions', COUNT(*) FROM RolePermissions UNION ALL
SELECT 'SupportTickets', COUNT(*) FROM SupportTickets UNION ALL
SELECT 'TicketMessages', COUNT(*) FROM TicketMessages UNION ALL
SELECT 'ChatSessions', COUNT(*) FROM ChatSessions UNION ALL
SELECT 'ChatMessages', COUNT(*) FROM ChatMessages
ORDER BY [Table];

PRINT '';
PRINT 'LOGIN ACCOUNTS:';
PRINT '  admin@ticketbox.vn     / Admin@123     (admin)';
PRINT '  organizer@ticketbox.vn / Organizer@123 (organizer)';
PRINT '  customer@ticketbox.vn  / Customer@123  (customer)';
PRINT '  support@ticketbox.vn   / Admin@123     (support_agent)';
PRINT '';
PRINT '  events@vietravel.vn    / Organizer@123 (organizer)';
PRINT '  hello@techviet.org     / Organizer@123 (organizer)';
PRINT '  info@saigonsports.vn   / Organizer@123 (organizer)';
PRINT '';
PRINT '  All customers use password: Customer@123';
PRINT '============================================';
GO
