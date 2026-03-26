-- =============================================
-- =============================================
-- =============================================

IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'SellingTicketDB')
    CREATE DATABASE SellingTicketDB;
GO

USE SellingTicketDB;
GO

-- =============================================
-- =============================================
IF OBJECT_ID('Notifications', 'U') IS NOT NULL DROP TABLE Notifications;
IF OBJECT_ID('ActivityLog',   'U') IS NOT NULL DROP TABLE ActivityLog;
IF OBJECT_ID('SiteSettings',  'U') IS NOT NULL DROP TABLE SiteSettings;
IF OBJECT_ID('ChatMessages',  'U') IS NOT NULL DROP TABLE ChatMessages;
IF OBJECT_ID('ChatSessions',  'U') IS NOT NULL DROP TABLE ChatSessions;
IF OBJECT_ID('TicketMessages', 'U') IS NOT NULL DROP TABLE TicketMessages;
IF OBJECT_ID('SupportTickets','U') IS NOT NULL DROP TABLE SupportTickets;
IF OBJECT_ID('VoucherUsages', 'U') IS NOT NULL DROP TABLE VoucherUsages;
IF OBJECT_ID('Vouchers',      'U') IS NOT NULL DROP TABLE Vouchers;
IF OBJECT_ID('SeepayWebhookDedup','U') IS NOT NULL DROP TABLE SeepayWebhookDedup;
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
-- =============================================

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

CREATE TABLE Categories (
    category_id INT IDENTITY(1,1) PRIMARY KEY,
    name NVARCHAR(100) NOT NULL,
    slug NVARCHAR(100) NOT NULL UNIQUE,
    icon NVARCHAR(50),
    description NVARCHAR(500),
    display_order INT DEFAULT 0,
    is_deleted BIT DEFAULT 0,
    created_at DATETIME DEFAULT GETDATE()
);
GO

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

CREATE TABLE Orders (
    order_id INT IDENTITY(1,1) PRIMARY KEY,
    order_code NVARCHAR(50) NOT NULL UNIQUE,
    user_id INT NOT NULL FOREIGN KEY REFERENCES Users(user_id),
    event_id INT NOT NULL FOREIGN KEY REFERENCES Events(event_id),
    total_amount DECIMAL(18,2) NOT NULL,
    discount_amount DECIMAL(18,2) DEFAULT 0,
    final_amount DECIMAL(18,2) NOT NULL,
    status NVARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending','paid','cancelled','refunded','refund_requested','checked_in')),
    payment_method NVARCHAR(30) DEFAULT 'seepay' CHECK (payment_method IN ('seepay','bank_transfer','cash')),
    payment_date DATETIME,
    payment_expires_at DATETIME,
    is_deleted BIT DEFAULT 0,
    buyer_name NVARCHAR(100),
    buyer_email NVARCHAR(255),
    buyer_phone NVARCHAR(20),
    notes NVARCHAR(500),
    voucher_id INT NULL,
    voucher_scope NVARCHAR(10) DEFAULT 'NONE',
    voucher_fund_source NVARCHAR(10) DEFAULT 'NONE',
    event_discount_amount DECIMAL(18,2) DEFAULT 0,
    system_discount_amount DECIMAL(18,2) DEFAULT 0,
    platform_fee_amount DECIMAL(18,2) DEFAULT 0,
    organizer_payout_amount DECIMAL(18,2) DEFAULT 0,
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME DEFAULT GETDATE()
);
GO

CREATE TABLE OrderItems (
    order_item_id INT IDENTITY(1,1) PRIMARY KEY,
    order_id INT NOT NULL FOREIGN KEY REFERENCES Orders(order_id) ON DELETE CASCADE,
    ticket_type_id INT NOT NULL FOREIGN KEY REFERENCES TicketTypes(ticket_type_id),
    quantity INT NOT NULL,
    unit_price DECIMAL(18,2) NOT NULL,
    subtotal DECIMAL(18,2) NOT NULL
);
GO

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

CREATE TABLE SeepayWebhookDedup (
    dedup_id INT IDENTITY(1,1) PRIMARY KEY,
    sepay_transaction_id NVARCHAR(100) NOT NULL UNIQUE,
    order_code NVARCHAR(100),
    process_result NVARCHAR(30) NOT NULL DEFAULT 'processed',
    created_at DATETIME NOT NULL DEFAULT GETDATE()
);
GO

CREATE TABLE Vouchers (
    voucher_id INT IDENTITY(1,1) PRIMARY KEY,
    organizer_id INT NOT NULL FOREIGN KEY REFERENCES Users(user_id),
    event_id INT FOREIGN KEY REFERENCES Events(event_id),
    code NVARCHAR(50) NOT NULL UNIQUE,
    discount_type NVARCHAR(20) CHECK (discount_type IN ('percentage','fixed')),
    discount_value DECIMAL(18,2) NOT NULL,
    min_order_amount DECIMAL(18,2) DEFAULT 0,
    max_discount DECIMAL(18,2) DEFAULT 0,
    usage_limit INT DEFAULT 0,
    used_count INT DEFAULT 0,
    start_date DATETIME,
    end_date DATETIME,
    is_active BIT DEFAULT 1,
    is_deleted BIT DEFAULT 0,
    voucher_scope NVARCHAR(10) DEFAULT 'EVENT',
    fund_source NVARCHAR(10) DEFAULT 'ORGANIZER',
    created_at DATETIME DEFAULT GETDATE()
);
GO

CREATE TABLE VoucherUsages (
    usage_id INT IDENTITY(1,1) PRIMARY KEY,
    voucher_id INT NOT NULL FOREIGN KEY REFERENCES Vouchers(voucher_id),
    order_id INT NOT NULL FOREIGN KEY REFERENCES Orders(order_id),
    discount_applied DECIMAL(18,2) NOT NULL,
    used_at DATETIME DEFAULT GETDATE()
);
GO

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

CREATE TABLE Permissions (
    permission_id INT IDENTITY(1,1) PRIMARY KEY,
    permission_key NVARCHAR(100) NOT NULL UNIQUE,
    permission_name NVARCHAR(100) NOT NULL,
    description NVARCHAR(255),
    module NVARCHAR(50) NOT NULL
);
GO

CREATE TABLE RolePermissions (
    role_permission_id INT IDENTITY(1,1) PRIMARY KEY,
    role NVARCHAR(20) NOT NULL CHECK (role IN ('customer','organizer','admin')),
    permission_id INT NOT NULL FOREIGN KEY REFERENCES Permissions(permission_id) ON DELETE CASCADE,
    UNIQUE (role, permission_id)
);
GO

CREATE TABLE EventStaff (
    staff_id INT IDENTITY(1,1) PRIMARY KEY,
    event_id INT NOT NULL FOREIGN KEY REFERENCES Events(event_id) ON DELETE CASCADE,
    user_id INT NOT NULL FOREIGN KEY REFERENCES Users(user_id) ON DELETE CASCADE,
    role NVARCHAR(20) DEFAULT 'staff' CHECK (role IN ('manager','staff','scanner')),
    granted_by INT FOREIGN KEY REFERENCES Users(user_id),
    created_at DATETIME DEFAULT GETDATE(),
    UNIQUE (event_id, user_id)
);
GO

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

CREATE TABLE TicketMessages (
    message_id INT IDENTITY(1,1) PRIMARY KEY,
    ticket_id INT NOT NULL FOREIGN KEY REFERENCES SupportTickets(ticket_id),
    sender_id INT NOT NULL FOREIGN KEY REFERENCES Users(user_id),
    content NVARCHAR(MAX) NOT NULL,
    is_internal BIT DEFAULT 0,
    created_at DATETIME DEFAULT GETDATE()
);
GO

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

CREATE TABLE ChatMessages (
    message_id INT IDENTITY(1,1) PRIMARY KEY,
    session_id INT NOT NULL FOREIGN KEY REFERENCES ChatSessions(session_id),
    sender_id INT NOT NULL FOREIGN KEY REFERENCES Users(user_id),
    content NVARCHAR(500) NOT NULL,
    created_at DATETIME DEFAULT GETDATE()
);
GO

CREATE TABLE SiteSettings (
    setting_key   NVARCHAR(100) PRIMARY KEY,
    setting_value NVARCHAR(MAX) NOT NULL,
    updated_at    DATETIME DEFAULT GETDATE()
);
GO

CREATE TABLE ActivityLog (
    log_id       INT IDENTITY(1,1) PRIMARY KEY,
    user_id      INT NOT NULL FOREIGN KEY REFERENCES Users(user_id),
    action       VARCHAR(100) NOT NULL,
    entity_type  VARCHAR(50),
    entity_id    INT,
    details      NVARCHAR(500),
    ip_address   VARCHAR(45),
    created_at   DATETIME DEFAULT GETDATE()
);
GO

CREATE TABLE Notifications (
    notification_id INT IDENTITY(1,1) PRIMARY KEY,
    user_id         INT NOT NULL FOREIGN KEY REFERENCES Users(user_id),
    type            VARCHAR(50) NOT NULL,
    title           NVARCHAR(200) NOT NULL,
    message         NVARCHAR(500),
    link            VARCHAR(300),
    is_read         BIT DEFAULT 0,
    created_at      DATETIME DEFAULT GETDATE()
);
GO

PRINT '=== All 24 tables created ===';
GO

-- =============================================
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
CREATE INDEX IX_SeepayWebhookDedup_CreatedAt ON SeepayWebhookDedup(created_at DESC);

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

CREATE INDEX IX_ActivityLog_CreatedAt ON ActivityLog(created_at DESC);
CREATE INDEX IX_ActivityLog_UserId ON ActivityLog(user_id);
CREATE INDEX IX_ActivityLog_Action ON ActivityLog(action);

CREATE INDEX IX_Notifications_UserRead ON Notifications(user_id, is_read);
CREATE INDEX IX_Notifications_CreatedAt ON Notifications(created_at DESC);
GO

PRINT '=== All indexes created ===';
GO

-- =============================================
-- =============================================
INSERT INTO Categories (name, slug, icon, description, display_order) VALUES
(N'Âm nhạc',    'music',      'fa-music',      N'Concert, liveshow, EDM festival, acoustic night', 1),
(N'Thể thao',   'sports',     'fa-futbol',     N'Bóng đá, marathon, tennis, esports', 2),
(N'Workshop',   'workshop',   'fa-laptop',     N'Hội thảo, khóa học, training chuyên môn', 3),
(N'Ẩm thực',    'food',       'fa-utensils',   N'Lễ hội ẩm thực, food tour, cooking class', 4),
(N'Nghệ thuật', 'art',        'fa-palette',    N'Triển lãm, kịch, múa ballet, gallery', 5),
(N'Kinh doanh', 'business',   'fa-briefcase',  N'Hội nghị, networking, startup pitch day', 6),
(N'Công nghệ',  'technology', 'fa-microchip',  N'Tech conference, hackathon, AI summit', 7);
GO

-- =============================================
-- =============================================
INSERT INTO Users (email, password_hash, full_name, phone, gender, date_of_birth, role, avatar, is_active, is_deleted, email_verified, bio, website, social_facebook, social_instagram, last_login_at, last_login_ip) VALUES
-- ========= ADMIN =========
('admin@ticketbox.vn',
 '$2a$12$odAx650SUPsEauwOWzajb.FUMCDzKZWYPLeG2.NlCs3NBxH2N/Pg.',
 N'Admin TicketBox', '0901234567', 'male', '1990-01-15', 'admin',
 'https://ui-avatars.com/api/?name=Admin&background=6366f1&color=fff&size=200',
 1, 0, 1, N'Quản trị viên hệ thống TicketBox', NULL, NULL, NULL,
 DATEADD(MINUTE,-30,GETDATE()), '127.0.0.1'),

-- ========= SUPPORT AGENTS =========
('support@ticketbox.vn',
 '$2a$12$odAx650SUPsEauwOWzajb.FUMCDzKZWYPLeG2.NlCs3NBxH2N/Pg.',
 N'Hỗ trợ viên Linh', '0901111222', 'female', '1993-07-10', 'support_agent',
 'https://ui-avatars.com/api/?name=Linh&background=f43f5e&color=fff&size=200',
 1, 0, 1, N'Nhân viên hỗ trợ khách hàng', NULL, NULL, NULL,
 DATEADD(HOUR,-1,GETDATE()), '127.0.0.1'),

('agent2@ticketbox.vn',
 '$2a$12$odAx650SUPsEauwOWzajb.FUMCDzKZWYPLeG2.NlCs3NBxH2N/Pg.',
 N'Hỗ trợ viên Minh', '0901333444', 'male', '1995-02-14', 'support_agent',
 'https://ui-avatars.com/api/?name=Minh&background=6366f1&color=fff&size=200',
 1, 0, 1, N'Nhân viên hỗ trợ kỹ thuật', NULL, NULL, NULL,
 DATEADD(HOUR,-5,GETDATE()), '127.0.0.1'),

-- ========= ORGANIZERS (5) =========
('organizer@ticketbox.vn',
 '$2a$12$Bs2nPLu8UK8GZsy1flBiGewDcqwu4x/KqtksjeYEWRQtcBxgiyNVC',
 N'Live Nation Vietnam', '0909876543', NULL, NULL, 'organizer',
 'https://ui-avatars.com/api/?name=LiveNation&background=10b981&color=fff&size=200',
 1, 0, 1, N'Nhà tổ chức sự kiện giải trí hàng đầu Việt Nam. Chuyên tổ chức concert quốc tế & liveshow.',
 'https://livenation.vn', 'https://facebook.com/livenationvn', 'livenationvn',
 DATEADD(HOUR,-3,GETDATE()), '14.186.20.55'),

('events@vietravel.vn',
 '$2a$12$Bs2nPLu8UK8GZsy1flBiGewDcqwu4x/KqtksjeYEWRQtcBxgiyNVC',
 N'Vietravel Events', '0283456789', NULL, NULL, 'organizer',
 'https://ui-avatars.com/api/?name=Vietravel&background=f59e0b&color=fff&size=200',
 1, 0, 1, N'Đơn vị tổ chức sự kiện du lịch & ẩm thực lớn nhất Việt Nam.',
 'https://vietravel.com', 'https://facebook.com/vietravel', 'vietravelevents',
 DATEADD(MINUTE, -15, DATEADD(HOUR, -4, DATEADD(DAY,-2,GETDATE()))), '27.72.100.11'),

('hello@techviet.org',
 '$2a$12$Bs2nPLu8UK8GZsy1flBiGewDcqwu4x/KqtksjeYEWRQtcBxgiyNVC',
 N'TechViet Community', '0281234567', NULL, NULL, 'organizer',
 'https://ui-avatars.com/api/?name=TechViet&background=06b6d4&color=fff&size=200',
 1, 0, 1, N'Cộng đồng công nghệ Việt Nam — Tổ chức hackathon, tech talk, và hội nghị IT.',
 'https://techviet.org', 'https://facebook.com/techviet', 'techviet.community',
 DATEADD(MINUTE, -32, DATEADD(HOUR, -12, DATEADD(DAY,-1,GETDATE()))), '14.241.120.88'),

('info@saigonsports.vn',
 '$2a$12$Bs2nPLu8UK8GZsy1flBiGewDcqwu4x/KqtksjeYEWRQtcBxgiyNVC',
 N'Saigon Sports Club', '0287654321', NULL, NULL, 'organizer',
 'https://ui-avatars.com/api/?name=SaigonSports&background=ef4444&color=fff&size=200',
 1, 0, 1, N'Câu lạc bộ thể thao Sài Gòn — Marathon, bóng rổ, và các giải đấu cộng đồng.',
 'https://saigonsports.vn', 'https://facebook.com/saigonsports', 'saigonsportsclub',
 DATEADD(MINUTE, -9, DATEADD(HOUR, -1, DATEADD(DAY,-4,GETDATE()))), '42.118.170.30'),

('contact@sunsetent.vn',
 '$2a$12$Bs2nPLu8UK8GZsy1flBiGewDcqwu4x/KqtksjeYEWRQtcBxgiyNVC',
 N'Sunset Entertainment', '0288765432', NULL, NULL, 'organizer',
 'https://ui-avatars.com/api/?name=Sunset&background=f59e0b&color=fff&size=200',
 1, 0, 1, N'Chuyên tổ chức sự kiện âm nhạc và lễ hội ngoài trời.',
 'https://sunsetent.vn', 'https://facebook.com/sunsetent', 'sunsetent.vn',
 DATEADD(MINUTE, -24, DATEADD(HOUR, -15, DATEADD(DAY,-3,GETDATE()))), '42.117.8.15'),

-- ========= CUSTOMERS (15) =========
('customer@ticketbox.vn',
 '$2a$12$07H.CL1nHx2kzH7oo1odGOClkIg/oK3s7.D/wxcRIL6xjhIo9sYhK',
 N'Nguyễn Văn An', '0912345678', 'male', '1998-05-20', 'customer',
 'https://ui-avatars.com/api/?name=An&background=3b82f6&color=fff&size=200',
 1, 0, 1, NULL, NULL, NULL, NULL,
 DATEADD(HOUR,-2,GETDATE()), '113.161.72.130'),

('binh.tran@gmail.com',
 '$2a$12$07H.CL1nHx2kzH7oo1odGOClkIg/oK3s7.D/wxcRIL6xjhIo9sYhK',
 N'Trần Thị Bình', '0987654321', 'female', '2000-08-12', 'customer',
 'https://ui-avatars.com/api/?name=Binh&background=ec4899&color=fff&size=200',
 1, 0, 1, NULL, NULL, NULL, NULL,
 DATEADD(MINUTE, -24, DATEADD(HOUR, -12, DATEADD(DAY,-1,GETDATE()))), '42.115.232.10'),

('cuong.le@yahoo.com',
 '$2a$12$07H.CL1nHx2kzH7oo1odGOClkIg/oK3s7.D/wxcRIL6xjhIo9sYhK',
 N'Lê Hoàng Cường', '0976543210', 'male', '1995-12-03', 'customer',
 'https://ui-avatars.com/api/?name=Cuong&background=8b5cf6&color=fff&size=200',
 1, 0, 1, NULL, NULL, NULL, NULL,
 DATEADD(MINUTE, -1, DATEADD(HOUR, -1, DATEADD(DAY,-5,GETDATE()))), '171.232.15.1'),

('duc.pham@outlook.com',
 '$2a$12$07H.CL1nHx2kzH7oo1odGOClkIg/oK3s7.D/wxcRIL6xjhIo9sYhK',
 N'Phạm Minh Đức', '0965432109', 'male', '1997-03-25', 'customer',
 'https://ui-avatars.com/api/?name=Duc&background=14b8a6&color=fff&size=200',
 1, 0, 1, NULL, NULL, NULL, NULL,
 DATEADD(MINUTE, -26, DATEADD(HOUR, -7, DATEADD(DAY,-2,GETDATE()))), '113.176.80.44'),

('ha.vu@gmail.com',
 '$2a$12$07H.CL1nHx2kzH7oo1odGOClkIg/oK3s7.D/wxcRIL6xjhIo9sYhK',
 N'Vũ Thị Hà', '0945678901', 'female', '2001-11-08', 'customer',
 'https://ui-avatars.com/api/?name=Ha&background=a855f7&color=fff&size=200',
 1, 0, 1, NULL, NULL, NULL, NULL,
 DATEADD(MINUTE, -2, DATEADD(HOUR, -18, DATEADD(DAY,-3,GETDATE()))), '115.73.214.5'),

('khai.do@gmail.com',
 '$2a$12$07H.CL1nHx2kzH7oo1odGOClkIg/oK3s7.D/wxcRIL6xjhIo9sYhK',
 N'Đỗ Quang Khải', '0934567890', 'male', '1999-04-16', 'customer',
 'https://ui-avatars.com/api/?name=Khai&background=0ea5e9&color=fff&size=200',
 1, 0, 1, NULL, NULL, NULL, NULL,
 DATEADD(MINUTE, -19, DATEADD(HOUR, -22, DATEADD(DAY,-7,GETDATE()))), '103.197.184.11'),

('tung.ngo@gmail.com',
 '$2a$12$07H.CL1nHx2kzH7oo1odGOClkIg/oK3s7.D/wxcRIL6xjhIo9sYhK',
 N'Ngô Thanh Tùng', '0923456789', 'male', '2002-01-30', 'customer',
 'https://ui-avatars.com/api/?name=Tung&background=f97316&color=fff&size=200',
 1, 0, 1, NULL, NULL, NULL, NULL,
 DATEADD(MINUTE, -10, DATEADD(HOUR, -23, DATEADD(DAY,-10,GETDATE()))), '14.169.55.22'),

('yen.hoang@yahoo.com',
 '$2a$12$07H.CL1nHx2kzH7oo1odGOClkIg/oK3s7.D/wxcRIL6xjhIo9sYhK',
 N'Hoàng Thị Yến', '0956789012', 'female', '2003-06-18', 'customer',
 'https://ui-avatars.com/api/?name=Yen&background=d946ef&color=fff&size=200',
 1, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL),

('bao.bui@gmail.com',
 '$2a$12$07H.CL1nHx2kzH7oo1odGOClkIg/oK3s7.D/wxcRIL6xjhIo9sYhK',
 N'Bùi Quốc Bảo', '0913579246', 'male', '1996-09-22', 'customer',
 'https://ui-avatars.com/api/?name=Bao&background=22c55e&color=fff&size=200',
 1, 0, 1, NULL, NULL, NULL, NULL,
 DATEADD(MINUTE, -24, DATEADD(HOUR, -22, DATEADD(DAY,-1,GETDATE()))), '27.72.59.131'),

('chau.ly@gmail.com',
 '$2a$12$07H.CL1nHx2kzH7oo1odGOClkIg/oK3s7.D/wxcRIL6xjhIo9sYhK',
 N'Lý Minh Châu', '0978901234', 'female', '1994-12-05', 'customer',
 'https://ui-avatars.com/api/?name=Chau&background=06b6d4&color=fff&size=200',
 1, 0, 1, NULL, NULL, NULL, NULL,
 DATEADD(MINUTE, -15, DATEADD(HOUR, -4, DATEADD(DAY,-2,GETDATE()))), '113.22.100.77'),

('long.trinh@gmail.com',
 '$2a$12$07H.CL1nHx2kzH7oo1odGOClkIg/oK3s7.D/wxcRIL6xjhIo9sYhK',
 N'Trịnh Hoàng Long', '0939876543', 'male', '2000-07-14', 'customer',
 'https://ui-avatars.com/api/?name=Long&background=84cc16&color=fff&size=200',
 1, 0, 1, NULL, NULL, NULL, NULL,
 DATEADD(MINUTE, -56, DATEADD(HOUR, -6, DATEADD(DAY,-1,GETDATE()))), '103.9.76.55'),

('diem.phan@gmail.com',
 '$2a$12$07H.CL1nHx2kzH7oo1odGOClkIg/oK3s7.D/wxcRIL6xjhIo9sYhK',
 N'Phan Ngọc Diễm', '0967890123', 'female', '1999-03-08', 'customer',
 'https://ui-avatars.com/api/?name=Diem&background=e11d48&color=fff&size=200',
 1, 0, 1, NULL, NULL, NULL, NULL,
 DATEADD(HOUR,-6,GETDATE()), '14.232.166.88'),

('kien.dang@gmail.com',
 '$2a$12$07H.CL1nHx2kzH7oo1odGOClkIg/oK3s7.D/wxcRIL6xjhIo9sYhK',
 N'Đặng Trung Kiên', '0941234567', 'male', '1997-11-25', 'customer',
 'https://ui-avatars.com/api/?name=Kien&background=0891b2&color=fff&size=200',
 1, 0, 1, NULL, NULL, NULL, NULL,
 DATEADD(MINUTE, -12, DATEADD(HOUR, -10, DATEADD(DAY,-1,GETDATE()))), '115.78.233.44'),

-- ========= EDGE CASES =========
('minimal@test.com',
 '$2a$12$07H.CL1nHx2kzH7oo1odGOClkIg/oK3s7.D/wxcRIL6xjhIo9sYhK',
 N'Người Dùng Test', '0900000003', NULL, NULL, 'customer',
 NULL, 1, 0, 1, NULL, NULL, NULL, NULL, NULL, NULL),

('banned.user@test.com',
 '$2a$12$07H.CL1nHx2kzH7oo1odGOClkIg/oK3s7.D/wxcRIL6xjhIo9sYhK',
 N'Trương Văn Gian', '0900000001', 'male', '1991-03-03', 'customer',
 NULL, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL),

('deleted.user@test.com',
 '$2a$12$07H.CL1nHx2kzH7oo1odGOClkIg/oK3s7.D/wxcRIL6xjhIo9sYhK',
 N'Người Dùng Đã Xóa', '0900000002', NULL, NULL, 'customer',
 NULL, 0, 1, 0, NULL, NULL, NULL, NULL, NULL, NULL),

('fullprofile@gmail.com',
 '$2a$12$07H.CL1nHx2kzH7oo1odGOClkIg/oK3s7.D/wxcRIL6xjhIo9sYhK',
 N'Nguyễn Hoàng Phúc', '0918765432', 'male', '1995-06-15', 'customer',
 'https://ui-avatars.com/api/?name=Phuc&background=7c3aed&color=fff&size=200',
 1, 0, 1,
 N'Đam mê âm nhạc và công nghệ. Thường xuyên tham gia các sự kiện lớn tại TPHCM và Hà Nội. Là fan cứng của Hà Anh Tuấn và Mỹ Tâm. Yêu thích chạy bộ cuối tuần.',
 'https://phucnguyen.blog', 'https://facebook.com/phucnguyen', 'phuc.nguyen.95',
 DATEADD(HOUR,-12,GETDATE()), '42.116.200.10');
GO

PRINT '=== 25 users seeded ===';
PRINT '  IDs 1: admin | 2-3: support | 4-8: organizer | 9-25: customer';
GO

-- =============================================
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
-- =============================================
INSERT INTO Events (organizer_id, category_id, title, slug, short_description, description, banner_image, location, address, start_date, end_date, status, is_featured, views, pin_order, display_priority, max_tickets_per_order, max_total_tickets, is_deleted) VALUES
-- ============ ÂM NHẠC (category_id=1) — 7 events ============
(4, 1,
 N'Hà Anh Tuấn — Truyện Ngắn Concert 2026',
 'ha-anh-tuan-truyen-ngan-2026',
 N'Concert quy mô lớn của Hà Anh Tuấn tại SVĐ Mỹ Đình, Hà Nội.',
 N'<h2>Truyện Ngắn Concert 2026</h2>
<p>Sau thành công vang dội của series Truyện Ngắn, Hà Anh Tuấn quay trở lại với đêm nhạc đặc biệt tại SVĐ Quốc gia Mỹ Đình.</p>
<h3>Highlights</h3>
<ul><li>Dàn nhạc giao hưởng 60 người</li><li>Sân khấu 360 độ với công nghệ LED mapping</li><li>Khách mời: Mỹ Tâm, Phan Mạnh Quỳnh</li><li>VIP lounge với đồ uống miễn phí</li></ul>
<p>Vé đã mua không hoàn lại. Check-in bằng QR code từ 17:00.</p>',
 'https://images.unsplash.com/photo-1501281668745-f7f57925c3b4?w=800',
 N'SVĐ Quốc gia Mỹ Đình', N'Đường Lê Đức Thọ, Nam Từ Liêm, Hà Nội',
 '2026-04-20 19:00', '2026-04-20 22:30', 'approved', 1, 15800, 5, 100, 4, 1750, 0),

(4, 1,
 N'Mỹ Tâm — My Soul 1981 Liveshow',
 'my-tam-my-soul-1981-liveshow',
 N'Đẳng cấp nữ hoàng Vpop — liveshow kỷ niệm 25 năm ca hát.',
 N'<h2>My Soul 1981 — Kỷ niệm 25 năm</h2><p>Mỹ Tâm mang đến đêm nhạc xúc động với hơn 40 ca khúc xuyên suốt sự nghiệp.</p>',
 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=800',
 N'Nhà hát Hòa Bình', N'240 Đường 3/2, Quận 10, TP.HCM',
 '2026-05-10 19:30', '2026-05-10 23:00', 'approved', 1, 9200, 4, 95, 4, 900, 0),

(4, 1,
 N'Sơn Tùng M-TP — Sky Tour 2026',
 'son-tung-mtp-sky-tour-2026',
 N'Chuyến lưu diễn toàn quốc của Sơn Tùng M-TP.',
 N'<h2>Sky Tour 2026</h2><p>Sơn Tùng M-TP cùng ban nhạc trở lại sân khấu sau 2 năm vắng bóng. Sân khấu hoành tráng, hiệu ứng laser & pyro.</p>',
 'https://images.unsplash.com/photo-1470229722913-7c0e2dbbafd3?w=800',
 N'Phú Thọ Stadium', N'1 Lý Thường Kiệt, Quận 11, TP.HCM',
 '2026-06-15 19:00', '2026-06-15 22:00', 'approved', 1, 26000, 3, 90, 4, 4330, 0),

(4, 1,
 N'Đêm nhạc Acoustic — Bên Nhau Trọn Đời',
 'dem-nhac-acoustic-ben-nhau-tron-doi',
 N'Đêm nhạc acoustic lãng mạn dành cho các cặp đôi.',
 N'<h2>Acoustic Night</h2><p>Không gian ấm cúng với guitar, piano. Guest: Bùi Anh Tuấn, Văn Mai Hương, Vũ.</p>',
 'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=800',
 N'Saigon Opera House', N'7 Lam Sơn, Quận 1, TP.HCM',
 '2026-03-28 20:00', '2026-03-28 22:30', 'approved', 0, 3800, 0, 70, 2, 350, 0),

(8, 1,
 N'EDM Rave — Neon Jungle Festival',
 'edm-rave-neon-jungle-2026',
 N'Đại tiệc EDM với DJ quốc tế — Tiësto, Martin Garrix.',
 N'<h2>Neon Jungle Festival 2026</h2><p>Festival EDM lớn nhất Đông Nam Á lần đầu tại Việt Nam!</p><ul><li>Tiësto</li><li>Martin Garrix</li><li>DJ Snake</li><li>Hoaprox</li></ul>',
 'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=800',
 N'Đại Nam Wonderland', N'Bình Dương',
 '2026-07-04 17:00', '2026-07-05 02:00', 'pending', 0, 0, 0, 0, 6, 5700, 0),

(8, 1,
 N'Indie Sunset Sessions Vol.3',
 'indie-sunset-sessions-vol3',
 N'Đêm nhạc indie ngoài trời tại bãi biển Vũng Tàu.',
 N'<h2>Indie Sunset Sessions</h2><p>Tận hưởng nhạc indie với hoàng hôn biển. Line-up: Ngọt, Cá Hồi Hoang, Chillies, Da LAB.</p>',
 'https://images.unsplash.com/photo-1501386761578-eac5c94b800a?w=800',
 N'Bãi Sau, Vũng Tàu', N'Đường Thùy Vân, TP Vũng Tàu',
 '2026-04-12 16:00', '2026-04-12 22:00', 'approved', 0, 4200, 0, 65, 4, 2000, 0),

(8, 1,
 N'Karaoke Đại Hội — Event Test',
 'karaoke-dai-hoi-test',
 N'Sự kiện test bị từ chối do thiếu thông tin.',
 N'<p>Nội dung không phù hợp.</p>',
 'https://images.unsplash.com/photo-1516450360452-9312f5e86fc7?w=800',
 N'Quán Karaoke ABC', N'123 Nguyễn Trãi, Quận 5, TP.HCM',
 '2026-03-01 20:00', '2026-03-01 23:00', 'rejected', 0, 50, 0, 0, 0, 0, 0),

-- ============ THỂ THAO (category_id=2) — 5 events ============
(7, 2,
 N'Vietnam Marathon — Đà Nẵng 2026',
 'vietnam-marathon-da-nang-2026',
 N'Giải marathon quốc tế lớn nhất tại thành phố đáng sống.',
 N'<h2>Vietnam Marathon 2026</h2><p>Chạy dọc bờ biển Mỹ Khê. Cự ly: 5K, 21K Half, 42K Full.</p><p>Huy chương finisher, bib cá nhân hóa, tiệc bia sau race.</p>',
 'https://images.unsplash.com/photo-1513593771513-7b58b6c4af38?w=800',
 N'Biển Mỹ Khê, Đà Nẵng', N'Đường Võ Nguyên Giáp, Sơn Trà, Đà Nẵng',
 '2026-05-03 04:30', '2026-05-03 12:00', 'approved', 1, 7800, 2, 85, 2, 10000, 0),

(7, 2,
 N'Giải bóng rổ 3x3 Saigon Open',
 'bong-ro-3x3-saigon-open-2026',
 N'Giải bóng rổ đường phố 3x3 hấp dẫn nhất Sài Gòn.',
 N'<h2>Bóng rổ 3x3 Saigon Open</h2><p>64 đội tranh tài, giải thưởng 200 triệu đồng. Luật FIBA 3x3.</p>',
 'https://images.unsplash.com/photo-1546519638-68e109498ffc?w=800',
 N'Nhà thi đấu Phú Thọ', N'1 Lý Thường Kiệt, Quận 11, TP.HCM',
 '2026-04-12 08:00', '2026-04-13 18:00', 'approved', 0, 2500, 0, 60, 0, 564, 0),

(7, 2,
 N'Saigon Night Run 10K',
 'saigon-night-run-10k-2026',
 N'Chạy đêm qua các con phố lung linh Sài Gòn.',
 N'<h2>Saigon Night Run 10K</h2><p>Chạy bộ 10km xuyên trung tâm TP.HCM vào ban đêm. Áo chạy phát quang đặc biệt.</p>',
 'https://images.unsplash.com/photo-1552674605-db6ffd4facb5?w=800',
 N'Phố đi bộ Nguyễn Huệ', N'Nguyễn Huệ, Quận 1, TP.HCM',
 '2026-03-22 19:00', '2026-03-22 22:00', 'approved', 0, 5100, 0, 65, 2, 3000, 0),

(7, 2,
 N'Giải Bơi Lội TP.HCM Mùa Hè 2026',
 'giai-boi-loi-tphcm-mua-he-2026',
 N'Giải đấu phong trào cho VĐV nghiệp dư và bán chuyên.',
 N'<h2>Giải Bơi Lội TP.HCM</h2><p>Thi đấu tự do, ếch, bướm theo nhóm tuổi.</p>',
 'https://images.unsplash.com/photo-1519315901367-f34ff9154487?w=800',
 N'CLB Bơi Lội Yết Kiêu', N'1 Nguyễn Thị Minh Khai, Quận 1, TP.HCM',
 '2026-07-19 07:00', '2026-07-19 17:00', 'pending', 0, 0, 0, 0, 0, 1900, 0),

(7, 2,
 N'Saigon Fun Run 5K 2025',
 'saigon-fun-run-5k-2025',
 N'Giải chạy cộng đồng 5K đã diễn ra thành công.',
 N'<p>Sự kiện đã kết thúc tháng 11/2025.</p>',
 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=800',
 N'Công viên Gia Định', N'Quận Gò Vấp, TP.HCM',
 '2025-11-15 06:00', '2025-11-15 10:00', 'approved', 0, 2200, 0, 30, 2, 1000, 0),

-- ============ WORKSHOP (category_id=3) — 4 events ============
(6, 3,
 N'Workshop UI/UX Design — Từ Zero đến Portfolio',
 'workshop-uiux-zero-to-portfolio',
 N'2 ngày thực hành Figma, Design System với mentor từ Google & Grab.',
 N'<h2>UI/UX Workshop: Zero → Portfolio</h2><p>Mentor: Nguyễn Quốc Huy (Ex-Google), Trần Minh Anh (Grab Design Lead)</p>',
 'https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=800',
 N'Dreamplex Coworking', N'21 Nguyễn Trung Ngạn, Quận 1, TP.HCM',
 '2026-04-05 09:00', '2026-04-06 17:00', 'approved', 1, 4100, 0, 80, 2, 100, 0),

(6, 3,
 N'Data Science Bootcamp — Python cho người mới',
 'data-science-bootcamp-python-2026',
 N'3 buổi tối học Python, Pandas, Matplotlib từ cơ bản.',
 N'<h2>Data Science Bootcamp</h2><p>Dành cho người mới bắt đầu. Bao gồm tài liệu và certificate.</p>',
 'https://images.unsplash.com/photo-1504384308090-c894fdcc538d?w=800',
 N'Campus Landmark', N'Vinhomes Central Park, Bình Thạnh, TP.HCM',
 '2026-04-15 18:30', '2026-04-17 21:00', 'approved', 0, 2100, 0, 55, 2, 100, 0),

(6, 3,
 N'AI for Business Workshop Draft 2026',
 'ai-for-business-workshop-draft-2026',
 N'Workshop ứng dụng AI cho doanh nghiệp — đang chuẩn bị.',
 N'<p>Đang xây dựng giáo trình và danh sách diễn giả.</p>',
 NULL, N'TBD', N'TBD',
 '2026-09-15 09:00', '2026-09-15 17:00', 'draft', 0, 0, 0, 0, 0, 0, 0),

(6, 3,
 N'Khoá học Digital Marketing Intensive',
 'digital-marketing-intensive-2026',
 N'5 buổi chuyên sâu về Facebook Ads, Google Ads, SEO & Content.',
 N'<h2>Digital Marketing Intensive</h2><p>Từ chiến lược đến thực thi. Phù hợp cho startups và SMEs.</p>',
 'https://images.unsplash.com/photo-1432888498266-38ffec3eaf0a?w=800',
 N'WeWork Landmark 81', N'Landmark 81, Bình Thạnh, TP.HCM',
 '2026-05-20 09:00', '2026-05-24 17:00', 'approved', 0, 1500, 0, 50, 2, 60, 0),

-- ============ ẨM THỰC (category_id=4) — 3 events ============
(5, 4,
 N'Lễ hội Ẩm thực Đường phố Sài Gòn 2026',
 'le-hoi-am-thuc-duong-pho-saigon-2026',
 N'100+ gian hàng — Món ngon 3 miền & quốc tế.',
 N'<h2>Street Food Festival Saigon 2026</h2><p>Hơn 100 gian hàng Bắc-Trung-Nam + quốc tế. Sân khấu acoustic mỗi tối. Thi ăn nhanh.</p>',
 'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=800',
 N'Công viên 23/9', N'Phạm Ngũ Lão, Quận 1, TP.HCM',
 '2026-05-01 10:00', '2026-05-04 22:00', 'approved', 1, 11500, 0, 88, 6, 10500, 0),

(5, 4,
 N'Cooking Class — Phở Bò Hà Nội Truyền Thống',
 'cooking-class-pho-bo-ha-noi',
 N'Học nấu phở bò Hà Nội chuẩn vị với đầu bếp 30 năm kinh nghiệm.',
 N'<h2>Cooking Class: Phở Bò</h2><p>3 tiếng, bao gồm nguyên liệu và thưởng thức tại chỗ.</p>',
 'https://images.unsplash.com/photo-1503764654157-72d979d9af2f?w=800',
 N'Cooking Studio Saigon', N'15 Lý Tự Trọng, Quận 1, TP.HCM',
 '2026-03-30 09:00', '2026-03-30 12:00', 'approved', 0, 1600, 0, 45, 2, 20, 0),

(5, 4,
 N'Food Truck Weekend Draft 2026',
 'food-truck-weekend-draft-2026',
 N'Sự kiện food truck cuối tuần — đang chuẩn bị.',
 N'<p>Đang hoàn thiện line-up gian hàng.</p>',
 NULL, N'TBD', N'TBD',
 '2026-09-05 10:00', '2026-09-06 22:00', 'draft', 0, 0, 0, 0, 0, 0, 0),

-- ============ NGHỆ THUẬT (category_id=5) — 3 events ============
(4, 5,
 N'Triển lãm Nghệ thuật Đương đại — Beyond Borders',
 'trien-lam-nghe-thuat-beyond-borders',
 N'30 nghệ sĩ Việt & quốc tế — Hội họa, điêu khắc, digital art.',
 N'<h2>Beyond Borders</h2><p>Triển lãm kết hợp truyền thống VN và hiện đại quốc tế. Main Gallery + Digital Room + Workshop Zone.</p>',
 'https://images.unsplash.com/photo-1531243269054-5ebf6f34081e?w=800',
 N'Bảo tàng Mỹ thuật TP.HCM', N'97A Phó Đức Chính, Quận 1, TP.HCM',
 '2026-04-01 09:00', '2026-04-30 18:00', 'approved', 0, 6200, 0, 72, 4, 3200, 0),

(4, 5,
 N'Tấm Cám: The Musical',
 'tam-cam-the-musical-2026',
 N'Vở nhạc kịch cổ tích Việt Nam hoành tráng nhất 2026.',
 N'<h2>Tấm Cám: The Musical</h2><p>Cổ tích Việt Nam qua nhạc kịch hiện đại với dàn 50 diễn viên.</p>',
 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=800',
 N'Nhà hát Lớn Hà Nội', N'1 Tràng Tiền, Hoàn Kiếm, Hà Nội',
 '2026-05-20 19:30', '2026-05-20 21:30', 'approved', 0, 3200, 0, 68, 4, 510, 0),

(8, 5,
 N'Triển lãm Ảnh Không Phép 2026',
 'trien-lam-anh-khong-phep',
 N'Sự kiện bị từ chối do chưa có giấy phép triển lãm.',
 N'<p>Thiếu giấy phép từ Sở VHTTDL.</p>',
 'https://images.unsplash.com/photo-1513364776144-60967b0f800f?w=800',
 N'Galerie ABC', N'Quận 3, TP.HCM',
 '2026-06-01 10:00', '2026-06-15 18:00', 'rejected', 0, 0, 0, 0, 0, 0, 0),

-- ============ KINH DOANH (category_id=6) — 3 events ============
(6, 6,
 N'Startup Pitch Day — Vietnam Founders Summit',
 'startup-pitch-day-vietnam-founders-2026',
 N'20 startup pitch trước 50+ nhà đầu tư — Demo Day lớn nhất Q2.',
 N'<h2>Vietnam Founders Summit</h2><p>Kết nối startup — nhà đầu tư. Keynote + Pitches + Networking Cocktail.</p>',
 'https://images.unsplash.com/photo-1475721027785-f74eccf877e2?w=800',
 N'GEM Center', N'8 Nguyễn Bỉnh Khiêm, Quận 1, TP.HCM',
 '2026-05-15 09:00', '2026-05-15 18:00', 'approved', 0, 4700, 0, 75, 5, 370, 0),

(5, 6,
 N'Hội nghị Du lịch & Hospitality Vietnam 2026',
 'hoi-nghi-du-lich-hospitality-2026',
 N'Xu hướng du lịch 2026-2030, AI trong hospitality.',
 N'<h2>Tourism & Hospitality Conference</h2><p>Diễn giả từ Marriott, Accor, Vinpearl.</p>',
 'https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=800',
 N'Vinpearl Luxury Landmark 81', N'Landmark 81, Bình Thạnh, TP.HCM',
 '2026-06-10 08:30', '2026-06-11 17:00', 'pending', 0, 0, 0, 0, 2, 300, 0),

(6, 6,
 N'Crypto Investment Night 2026',
 'crypto-investment-night-2026',
 N'Bị từ chối do thiếu thông tin pháp lý về đầu tư tài sản số.',
 N'<p>Chưa cung cấp đủ cảnh báo rủi ro theo quy định.</p>',
 'https://images.unsplash.com/photo-1621761191319-c6fb62004040?w=800',
 N'Khách sạn Rex', N'141 Nguyễn Huệ, Quận 1, TP.HCM',
 '2026-04-18 18:30', '2026-04-18 21:30', 'rejected', 0, 0, 0, 0, 0, 0, 0),

-- ============ CÔNG NGHỆ (category_id=7) — 5 events ============
(6, 7,
 N'Vietnam AI Summit 2026',
 'vietnam-ai-summit-2026',
 N'Hội nghị AI lớn nhất — Speakers từ OpenAI, Google DeepMind.',
 N'<h2>Vietnam AI Summit</h2><p>Topics: LLM, AI Healthcare, FinTech, Responsible AI. Hands-on workshop.</p>',
 'https://images.unsplash.com/photo-1485827404703-89b55fcc595e?w=800',
 N'Trung tâm Hội nghị GEM', N'8 Nguyễn Bỉnh Khiêm, Quận 1, TP.HCM',
 '2026-06-20 08:00', '2026-06-21 17:00', 'approved', 1, 8900, 1, 92, 3, 700, 0),

(6, 7,
 N'Hackathon — Build for Vietnam 2026',
 'hackathon-build-for-vietnam-2026',
 N'48 giờ code non-stop — Giải thưởng 500 triệu đồng.',
 N'<h2>Build for Vietnam Hackathon</h2><p>Tracks: FinTech, HealthTech, EdTech, Open.</p>',
 'https://images.unsplash.com/photo-1504384764586-bb4cdc1707b0?w=800',
 N'VNG Campus', N'182 Lê Đại Hành, Quận 11, TP.HCM',
 '2026-05-24 09:00', '2026-05-26 17:00', 'approved', 0, 4500, 0, 78, 5, 130, 0),

(6, 7,
 N'Tech Career Fair 2026',
 'tech-career-fair-2026',
 N'Ngày hội nghề nghiệp công nghệ toàn quốc.',
 N'<h2>Tech Career Fair</h2><p>50+ doanh nghiệp tuyển dụng. Student & Professional passes.</p>',
 'https://images.unsplash.com/photo-1552664730-d307ca884978?w=800',
 N'TT Hội nghị Quốc gia', N'57 Phạm Hùng, Nam Từ Liêm, Hà Nội',
 '2026-08-12 08:00', '2026-08-12 18:00', 'pending', 0, 0, 0, 0, 3, 1500, 0),

(6, 7,
 N'Cloud Computing Workshop 2026 (Draft)',
 'cloud-computing-workshop-draft-2026',
 N'Workshop về AWS, GCP, Azure — đang soạn nội dung.',
 N'<p>Đang lên giáo trình.</p>',
 NULL, N'TBD', N'TBD',
 '2026-10-01 09:00', '2026-10-01 17:00', 'draft', 0, 0, 0, 0, 0, 0, 0),

(4, 1,
 N'Beach Countdown Party 2026 Cancelled',
 'beach-countdown-party-2026-cancelled',
 N'Sự kiện countdown bị hủy do thời tiết xấu.',
 N'<p>BTC hủy để đảm bảo an toàn.</p>',
 'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=800',
 N'Bãi biển Cửa Đại', N'Hội An, Quảng Nam',
 '2026-12-31 20:00', '2027-01-01 01:00', 'cancelled', 0, 300, 0, 0, 4, 2000, 0);
GO

UPDATE Events SET rejection_reason = N'Nội dung sự kiện không đủ thông tin. Bổ sung mô tả chi tiết và hình ảnh chất lượng.',
    rejected_at = '2026-02-28 14:30:00' WHERE slug = 'karaoke-dai-hoi-test';
UPDATE Events SET rejection_reason = N'Sự kiện chưa cung cấp tài liệu pháp lý và cảnh báo rủi ro đầu tư.',
    rejected_at = '2026-03-03 10:15:00' WHERE slug = 'crypto-investment-night-2026';
UPDATE Events SET rejection_reason = N'Chưa có giấy phép triển lãm từ Sở VHTTDL.',
    rejected_at = '2026-03-05 09:00:00' WHERE slug = 'trien-lam-anh-khong-phep';

UPDATE Events SET pre_order_enabled = 1 WHERE slug = 'tech-career-fair-2026';
GO

PRINT '=== 30 events seeded (18 approved, 4 pending, 3 rejected, 3 draft, 1 cancelled, 1 past) ===';
GO

-- =============================================
-- =============================================
INSERT INTO TicketTypes (event_id, name, description, price, quantity, sold_quantity, color_theme, sale_start, sale_end) VALUES
-- ===== E1: Hà Anh Tuấn Concert =====
(1, N'SVIP Diamond',      N'Hàng đầu sát sân khấu + Meet & Greet + Quà có chữ ký', 5000000, 50, 48, '#FFD700', '2026-01-15', '2026-04-19'),
(1, N'VIP Gold',           N'Khu VIP trung tâm + Lounge đồ uống miễn phí',          3000000, 200, 195, '#FFA500', '2026-01-15', '2026-04-19'),
(1, N'Thường - CAT1',     N'Khu tầng 1 gần sân khấu',                                1500000, 500, 420, '#4A90D9', '2026-01-15', '2026-04-20'),
(1, N'Thường - CAT2',     N'Khu tầng 2',                                              800000, 1000, 680, '#6B8E23', '2026-01-15', '2026-04-20'),

-- ===== E2: Mỹ Tâm Liveshow =====
(2, N'VIP Hàng Đầu',      N'Hàng 1-5 + Poster chữ ký',                               3500000, 100, 97, '#E74C3C', '2026-02-01', '2026-05-09'),
(2, N'Hạng A',             N'Hàng 6-15, trung tâm',                                    2000000, 300, 260, '#3498DB', '2026-02-01', '2026-05-09'),
(2, N'Hạng B',             N'Hàng 16+, hai bên cánh',                                  1000000, 500, 410, '#2ECC71', '2026-02-01', '2026-05-10'),

-- ===== E3: Sơn Tùng Sky Tour =====
(3, N'Diamond',            N'Front row + Fan meeting + Photo',                         6000000, 30, 30, '#FFD700', '2026-03-01', '2026-06-14'),
(3, N'Platinum',           N'Standing gần sân khấu',                                   3500000, 300, 290, '#C0C0C0', '2026-03-01', '2026-06-14'),
(3, N'Gold Standing',      N'Standing trung tâm',                                       2000000, 1000, 820, '#FFA500', '2026-03-01', '2026-06-15'),
(3, N'General Admission',  N'Vé vào cổng',                                              800000, 3000, 2600, '#4ECDC4', '2026-03-01', '2026-06-15'),

-- ===== E4: Acoustic Bên Nhau =====
(4, N'Couple Seat',        N'Ghế đôi + Nến & hoa + 2 đồ uống',                        1200000, 50, 42, '#FF69B4', '2026-02-15', '2026-03-27'),
(4, N'Premium Seat',       N'Ghế đơn VIP',                                              600000, 100, 85, '#9B59B6', '2026-02-15', '2026-03-28'),
(4, N'Standard',           N'Ghế thường',                                                350000, 200, 155, '#1ABC9C', '2026-02-15', '2026-03-28'),

-- ===== E5: EDM Neon Jungle (pending — chưa bán) =====
(5, N'Early Bird',         N'Giá ưu đãi đặt sớm',                                     800000, 500, 0, '#FF6B6B', '2026-04-01', '2026-05-31'),
(5, N'GA Festival Pass',   N'Vé 2 ngày toàn bộ khu vực',                                1500000, 5000, 0, '#4ECDC4', '2026-04-01', '2026-07-03'),
(5, N'VIP All Access',     N'VIP lounge + DJ backstage meet',                           4000000, 200, 0, '#FFD700', '2026-04-01', '2026-07-03'),

-- ===== E6: Indie Sunset Sessions =====
(6, N'Early Bird',         N'Giá ưu đãi đặt sớm',                                     300000, 300, 300, '#FF6B6B', '2026-02-01', '2026-03-15'),
(6, N'General Admission',  N'Vé phổ thông',                                              500000, 1500, 1300, '#4ECDC4', '2026-03-16', '2026-04-11'),
(6, N'VIP Beach Lounge',   N'Khu VIP bãi biển + Đồ uống',                               1200000, 200, 160, '#FFD700', '2026-02-01', '2026-04-11'),

-- ===== E8: Vietnam Marathon =====
(8, N'42K Full Marathon',  N'Bib + Huy chương + Áo finisher',                          1200000, 2000, 1800, '#E74C3C', '2026-01-01', '2026-05-01'),
(8, N'21K Half Marathon',  N'Bib + Huy chương + Áo race',                               800000, 3000, 2700, '#F39C12', '2026-01-01', '2026-05-01'),
(8, N'5K Fun Run',         N'Bib + Huy chương, mọi lứa tuổi',                           300000, 5000, 4800, '#2ECC71', '2026-01-01', '2026-05-02'),

-- ===== E9: Bóng rổ 3x3 =====
(9, N'Đội tham gia',       N'Phí đăng ký 1 đội (3-4 người)',                            500000, 64, 58, '#FF6B6B', '2026-02-01', '2026-04-10'),
(9, N'Khán giả',           N'Vé vào xem (đăng ký nhận ghế)',                              0, 500, 420, '#4ECDC4', '2026-02-01', '2026-04-12'),

-- ===== E10: Saigon Night Run =====
(10, N'Runner 10K',        N'Bib + Huy chương + Áo phát quang',                         400000, 3000, 2900, '#9B59B6', '2026-01-15', '2026-03-21'),

-- ===== E12: Saigon Fun Run 5K 2025 (past) =====
(12, N'5K Runner',         N'Vé 5K runner',                                              200000, 800, 650, '#2ECC71', '2025-09-01', '2025-11-14'),
(12, N'VIP Runner',        N'Vé VIP kèm áo thun + medal đặc biệt',                     500000, 200, 180, '#FFD700', '2025-09-01', '2025-11-14'),

-- ===== E13: Workshop UI/UX =====
(13, N'Early Bird',        N'Vé ưu đãi 2 ngày (hết hàng)',                              800000, 30, 30, '#FF6B6B', '2026-02-01', '2026-03-15'),
(13, N'Standard 2 Days',   N'Vé 2 ngày workshop',                                       1200000, 50, 42, '#3498DB', '2026-03-16', '2026-04-04'),
(13, N'Student',           N'Vé sinh viên (cần xác minh)',                                500000, 20, 18, '#2ECC71', '2026-02-01', '2026-04-04'),

-- ===== E14: Data Science Bootcamp =====
(14, N'Full Bootcamp',     N'3 buổi + Tài liệu + Certificate',                          600000, 40, 32, '#E74C3C', '2026-03-01', '2026-04-14'),
(14, N'Single Session',    N'1 buổi (chọn ngày)',                                         250000, 60, 40, '#3498DB', '2026-03-01', '2026-04-14'),

-- ===== E16: Digital Marketing Intensive =====
(16, N'Full 5 Days',       N'5 buổi + Tài liệu + Certificate',                          2500000, 40, 25, '#E74C3C', '2026-03-15', '2026-05-19'),
(16, N'Single Day',        N'1 buổi (chọn ngày)',                                         600000, 60, 20, '#3498DB', '2026-03-15', '2026-05-19'),

-- ===== E17: Lễ hội Ẩm thực =====
(17, N'Vé ngày thường',    N'Vào cổng 1 ngày (Thứ 2-5)',                                 50000, 5000, 4500, '#2ECC71', '2026-03-01', '2026-05-04'),
(17, N'Vé cuối tuần',      N'Vào cổng 1 ngày (Thứ 6-CN)',                                80000, 5000, 4900, '#F39C12', '2026-03-01', '2026-05-04'),
(17, N'VIP Passport 4 ngày', N'All-access 4 ngày + Voucher ăn 200K',                    250000, 500, 450, '#E74C3C', '2026-03-01', '2026-05-01'),

-- ===== E18: Cooking Class Phở =====
(18, N'Học viên',           N'Nguyên liệu + thưởng thức tại chỗ',                       500000, 20, 18, '#FF6B6B', '2026-02-15', '2026-03-29'),

-- ===== E20: Triển lãm Beyond Borders =====
(20, N'Vé tham quan',      N'Vào cổng 1 lần',                                            100000, 3000, 2100, '#3498DB', '2026-03-01', '2026-04-30'),
(20, N'Workshop Pass',     N'Tham quan + 1 buổi workshop vẽ',                             300000, 200, 165, '#9B59B6', '2026-03-01', '2026-04-28'),

-- ===== E21: Tấm Cám Musical =====
(21, N'Hạng Đặc biệt',    N'Hàng 1-3 + souvenirs',                                     2000000, 60, 55, '#FFD700', '2026-03-01', '2026-05-19'),
(21, N'Hạng A',            N'Hàng 4-10',                                                  1200000, 150, 130, '#E74C3C', '2026-03-01', '2026-05-19'),
(21, N'Hạng B',            N'Hàng 11-20',                                                  700000, 300, 220, '#3498DB', '2026-03-01', '2026-05-20'),

-- ===== E23: Startup Pitch Day =====
(23, N'Startup Team',      N'Đăng ký pitch (1 đội 3-5 người)',                             0, 20, 18, '#FF6B6B', '2026-03-01', '2026-05-10'),
(23, N'Investor Pass',     N'Nhà đầu tư + networking lunch',                                0, 50, 45, '#FFD700', '2026-03-01', '2026-05-14'),
(23, N'General Attendee',  N'Vé tham dự thường',                                           200000, 300, 260, '#2ECC71', '2026-03-01', '2026-05-14'),

-- ===== E26: AI Summit =====
(26, N'VIP All-Access',    N'2 ngày + Workshop + Speaker Dinner',                        3000000, 100, 92, '#FFD700', '2026-03-01', '2026-06-19'),
(26, N'Standard',          N'2 ngày conference',                                           1500000, 400, 350, '#3498DB', '2026-03-01', '2026-06-19'),
(26, N'Student/Startup',   N'Vé ưu đãi (cần verify)',                                      500000, 200, 185, '#2ECC71', '2026-03-01', '2026-06-19'),

-- ===== E27: Hackathon =====
(27, N'Team (3-5 người)',  N'Đăng ký 1 đội hackathon',                                      0, 100, 82, '#FF6B6B', '2026-03-01', '2026-05-22'),
(27, N'Mentor Pass',       N'Mentor hỗ trợ các đội',                                         0, 30, 24, '#9B59B6', '2026-03-01', '2026-05-22'),

-- ===== E11: Giải Bơi (pending) =====
(11, N'VĐV Cá Nhân',      N'Đăng ký thi đấu cá nhân',                                    300000, 400, 0, '#06B6D4', '2026-05-01', '2026-07-18'),
(11, N'Khán giả',          N'Vé vào xem khán đài',                                          50000, 1500, 0, '#F59E0B', '2026-05-01', '2026-07-19'),

-- ===== E24: Hội nghị Du lịch (pending) =====
(24, N'Full Conference',   N'2 ngày + lunch + networking dinner',                         2500000, 200, 0, '#E74C3C', '2026-04-01', '2026-06-09'),
(24, N'Day Pass',          N'Vé 1 ngày',                                                   1500000, 100, 0, '#3498DB', '2026-04-01', '2026-06-09'),

-- ===== E28: Tech Career Fair (pending) =====
(28, N'Student Pass',      N'Sinh viên & fresher',                                           0, 1000, 0, '#3B82F6', '2026-06-01', '2026-08-11'),
(28, N'Professional Pass', N'Networking ưu tiên',                                           150000, 500, 0, '#10B981', '2026-06-01', '2026-08-11');
GO

PRINT '=== 65 ticket types seeded ===';
GO

-- =============================================
-- =============================================
DECLARE @now DATETIME = GETDATE();

-- === CUSTOMER 9 (An) — VIP buyer: 6 paid orders, 1 pending = ~15.5M total ===
INSERT INTO Orders (order_code, user_id, event_id, total_amount, discount_amount, final_amount, status, payment_method, payment_date, buyer_name, buyer_email, buyer_phone, created_at, voucher_scope, event_discount_amount, platform_fee_amount, organizer_payout_amount)
VALUES ('ORD-2026-0001', 9, 1, 7500000, 0, 7500000, 'paid', 'seepay', DATEADD(MINUTE, -26, DATEADD(HOUR, -5, DATEADD(DAY,-30,@now))), N'Nguyễn Văn An', 'customer@ticketbox.vn', '0912345678', DATEADD(MINUTE, -26, DATEADD(HOUR, -5, DATEADD(DAY,-30,@now))), 'NONE', 0, 375000, 7125000);
INSERT INTO OrderItems (order_id, ticket_type_id, quantity, unit_price, subtotal) VALUES (1, 2, 2, 3000000, 6000000),(1, 3, 1, 1500000, 1500000);

INSERT INTO Orders (order_code, user_id, event_id, total_amount, discount_amount, final_amount, status, payment_method, payment_date, buyer_name, buyer_email, buyer_phone, created_at, platform_fee_amount, organizer_payout_amount)
VALUES ('ORD-2026-0002', 9, 3, 4000000, 0, 4000000, 'paid', 'seepay', DATEADD(MINUTE, -30, DATEADD(HOUR, -1, DATEADD(DAY,-25,@now))), N'Nguyễn Văn An', 'customer@ticketbox.vn', '0912345678', DATEADD(MINUTE, -30, DATEADD(HOUR, -1, DATEADD(DAY,-25,@now))), 200000, 3800000);
INSERT INTO OrderItems (order_id, ticket_type_id, quantity, unit_price, subtotal) VALUES (2, 10, 2, 2000000, 4000000);

INSERT INTO Orders (order_code, user_id, event_id, total_amount, discount_amount, final_amount, status, payment_method, payment_date, buyer_name, buyer_email, buyer_phone, created_at, platform_fee_amount, organizer_payout_amount)
VALUES ('ORD-2026-0003', 9, 17, 500000, 0, 500000, 'paid', 'seepay', DATEADD(MINUTE, -20, DATEADD(HOUR, -14, DATEADD(DAY,-22,@now))), N'Nguyễn Văn An', 'customer@ticketbox.vn', '0912345678', DATEADD(MINUTE, -20, DATEADD(HOUR, -14, DATEADD(DAY,-22,@now))), 25000, 475000);
INSERT INTO OrderItems (order_id, ticket_type_id, quantity, unit_price, subtotal) VALUES (3, 41, 2, 250000, 500000);

INSERT INTO Orders (order_code, user_id, event_id, total_amount, discount_amount, final_amount, status, payment_method, payment_date, buyer_name, buyer_email, buyer_phone, created_at)
VALUES ('ORD-2026-0004', 9, 14, 600000, 0, 600000, 'paid', 'seepay', DATEADD(MINUTE, -58, DATEADD(HOUR, -15, DATEADD(DAY,-18,@now))), N'Nguyễn Văn An', 'customer@ticketbox.vn', '0912345678', DATEADD(MINUTE, -58, DATEADD(HOUR, -15, DATEADD(DAY,-18,@now))));
INSERT INTO OrderItems (order_id, ticket_type_id, quantity, unit_price, subtotal) VALUES (4, 34, 1, 600000, 600000);

INSERT INTO Orders (order_code, user_id, event_id, total_amount, discount_amount, final_amount, status, payment_method, payment_date, buyer_name, buyer_email, buyer_phone, created_at)
VALUES ('ORD-2026-0005', 9, 26, 500000, 0, 500000, 'paid', 'seepay', DATEADD(MINUTE, -21, DATEADD(HOUR, -1, DATEADD(DAY,-10,@now))), N'Nguyễn Văn An', 'customer@ticketbox.vn', '0912345678', DATEADD(MINUTE, -21, DATEADD(HOUR, -1, DATEADD(DAY,-10,@now))));
INSERT INTO OrderItems (order_id, ticket_type_id, quantity, unit_price, subtotal) VALUES (5, 55, 1, 500000, 500000);

INSERT INTO Orders (order_code, user_id, event_id, total_amount, discount_amount, final_amount, status, payment_method, payment_date, buyer_name, buyer_email, buyer_phone, created_at)
VALUES ('ORD-2026-0006', 9, 6, 1000000, 0, 1000000, 'paid', 'seepay', DATEADD(MINUTE, -4, DATEADD(HOUR, -8, DATEADD(DAY,-8,@now))), N'Nguyễn Văn An', 'customer@ticketbox.vn', '0912345678', DATEADD(MINUTE, -4, DATEADD(HOUR, -8, DATEADD(DAY,-8,@now))));
INSERT INTO OrderItems (order_id, ticket_type_id, quantity, unit_price, subtotal) VALUES (6, 20, 2, 500000, 1000000);

INSERT INTO Orders (order_code, user_id, event_id, total_amount, discount_amount, final_amount, status, payment_method, payment_expires_at, buyer_name, buyer_email, buyer_phone, created_at)
VALUES ('ORD-2026-0007', 9, 2, 2000000, 0, 2000000, 'pending', 'seepay', DATEADD(HOUR,2,@now), N'Nguyễn Văn An', 'customer@ticketbox.vn', '0912345678', @now);
INSERT INTO OrderItems (order_id, ticket_type_id, quantity, unit_price, subtotal) VALUES (7, 6, 1, 2000000, 2000000);

-- === CUSTOMER 10 (Bình) — Gold tier: 4 paid = ~11.5M ===
INSERT INTO Orders (order_code, user_id, event_id, total_amount, discount_amount, final_amount, status, payment_method, payment_date, buyer_name, buyer_email, buyer_phone, created_at)
VALUES ('ORD-2026-0008', 10, 1, 5000000, 0, 5000000, 'paid', 'seepay', DATEADD(MINUTE, -17, DATEADD(HOUR, -23, DATEADD(DAY,-28,@now))), N'Trần Thị Bình', 'binh.tran@gmail.com', '0987654321', DATEADD(MINUTE, -17, DATEADD(HOUR, -23, DATEADD(DAY,-28,@now))));
INSERT INTO OrderItems (order_id, ticket_type_id, quantity, unit_price, subtotal) VALUES (8, 1, 1, 5000000, 5000000);

INSERT INTO Orders (order_code, user_id, event_id, total_amount, discount_amount, final_amount, status, payment_method, payment_date, buyer_name, buyer_email, buyer_phone, created_at)
VALUES ('ORD-2026-0009', 10, 26, 3000000, 0, 3000000, 'paid', 'seepay', DATEADD(MINUTE, -39, DATEADD(HOUR, -21, DATEADD(DAY,-15,@now))), N'Trần Thị Bình', 'binh.tran@gmail.com', '0987654321', DATEADD(MINUTE, -39, DATEADD(HOUR, -21, DATEADD(DAY,-15,@now))));
INSERT INTO OrderItems (order_id, ticket_type_id, quantity, unit_price, subtotal) VALUES (9, 53, 1, 3000000, 3000000);

INSERT INTO Orders (order_code, user_id, event_id, total_amount, discount_amount, final_amount, status, payment_method, payment_date, buyer_name, buyer_email, buyer_phone, created_at)
VALUES ('ORD-2026-0010', 10, 23, 200000, 0, 200000, 'paid', 'seepay', DATEADD(MINUTE, -15, DATEADD(HOUR, -3, DATEADD(DAY,-12,@now))), N'Trần Thị Bình', 'binh.tran@gmail.com', '0987654321', DATEADD(MINUTE, -15, DATEADD(HOUR, -3, DATEADD(DAY,-12,@now))));
INSERT INTO OrderItems (order_id, ticket_type_id, quantity, unit_price, subtotal) VALUES (10, 50, 1, 200000, 200000);

INSERT INTO Orders (order_code, user_id, event_id, total_amount, discount_amount, final_amount, status, payment_method, payment_date, buyer_name, buyer_email, buyer_phone, created_at, voucher_id, voucher_scope, voucher_fund_source, event_discount_amount, platform_fee_amount, organizer_payout_amount)
VALUES ('ORD-2026-0011', 10, 20, 600000, 90000, 510000, 'paid', 'seepay', DATEADD(MINUTE, -46, DATEADD(HOUR, -9, DATEADD(DAY,-7,@now))), N'Trần Thị Bình', 'binh.tran@gmail.com', '0987654321', DATEADD(MINUTE, -46, DATEADD(HOUR, -9, DATEADD(DAY,-7,@now))), 2, 'EVENT', 'ORGANIZER', 90000, 30000, 480000);
INSERT INTO OrderItems (order_id, ticket_type_id, quantity, unit_price, subtotal) VALUES (11, 44, 2, 300000, 600000);

-- === CUSTOMER 11 (Cường) — has cancelled + paid ===
INSERT INTO Orders (order_code, user_id, event_id, total_amount, discount_amount, final_amount, status, payment_method, payment_date, buyer_name, buyer_email, buyer_phone, created_at)
VALUES ('ORD-2026-0012', 11, 2, 4000000, 0, 4000000, 'paid', 'seepay', DATEADD(MINUTE, -37, DATEADD(HOUR, -10, DATEADD(DAY,-20,@now))), N'Lê Hoàng Cường', 'cuong.le@yahoo.com', '0976543210', DATEADD(MINUTE, -37, DATEADD(HOUR, -10, DATEADD(DAY,-20,@now))));
INSERT INTO OrderItems (order_id, ticket_type_id, quantity, unit_price, subtotal) VALUES (12, 6, 2, 2000000, 4000000);

INSERT INTO Orders (order_code, user_id, event_id, total_amount, discount_amount, final_amount, status, payment_method, buyer_name, buyer_email, buyer_phone, created_at)
VALUES ('ORD-2026-0013', 11, 3, 800000, 0, 800000, 'cancelled', 'seepay', N'Lê Hoàng Cường', 'cuong.le@yahoo.com', '0976543210', DATEADD(MINUTE, -31, DATEADD(HOUR, -3, DATEADD(DAY,-18,@now))));
INSERT INTO OrderItems (order_id, ticket_type_id, quantity, unit_price, subtotal) VALUES (13, 11, 1, 800000, 800000);

INSERT INTO Orders (order_code, user_id, event_id, total_amount, discount_amount, final_amount, status, payment_method, payment_date, buyer_name, buyer_email, buyer_phone, created_at)
VALUES ('ORD-2026-0014', 11, 10, 800000, 0, 800000, 'paid', 'seepay', DATEADD(MINUTE, -29, DATEADD(HOUR, -13, DATEADD(DAY,-35,@now))), N'Lê Hoàng Cường', 'cuong.le@yahoo.com', '0976543210', DATEADD(MINUTE, -29, DATEADD(HOUR, -13, DATEADD(DAY,-35,@now))));
INSERT INTO OrderItems (order_id, ticket_type_id, quantity, unit_price, subtotal) VALUES (14, 28, 2, 400000, 800000);

-- === CUSTOMER 12 (Đức) — sports/tech, free ticket orders ===
INSERT INTO Orders (order_code, user_id, event_id, total_amount, discount_amount, final_amount, status, payment_method, payment_date, buyer_name, buyer_email, buyer_phone, created_at)
VALUES ('ORD-2026-0015', 12, 8, 800000, 0, 800000, 'paid', 'seepay', DATEADD(MINUTE, -7, DATEADD(HOUR, -22, DATEADD(DAY,-45,@now))), N'Phạm Minh Đức', 'duc.pham@outlook.com', '0965432109', DATEADD(MINUTE, -7, DATEADD(HOUR, -22, DATEADD(DAY,-45,@now))));
INSERT INTO OrderItems (order_id, ticket_type_id, quantity, unit_price, subtotal) VALUES (15, 23, 1, 800000, 800000);

INSERT INTO Orders (order_code, user_id, event_id, total_amount, discount_amount, final_amount, status, payment_method, payment_date, buyer_name, buyer_email, buyer_phone, created_at)
VALUES ('ORD-2026-0016', 12, 27, 0, 0, 0, 'paid', 'cash', DATEADD(MINUTE, -57, DATEADD(HOUR, -23, DATEADD(DAY,-8,@now))), N'Phạm Minh Đức', 'duc.pham@outlook.com', '0965432109', DATEADD(MINUTE, -57, DATEADD(HOUR, -23, DATEADD(DAY,-8,@now))));
INSERT INTO OrderItems (order_id, ticket_type_id, quantity, unit_price, subtotal) VALUES (16, 57, 1, 0, 0);

INSERT INTO Orders (order_code, user_id, event_id, total_amount, discount_amount, final_amount, status, payment_method, payment_date, buyer_name, buyer_email, buyer_phone, created_at)
VALUES ('ORD-2026-0017', 12, 4, 1200000, 0, 1200000, 'paid', 'seepay', DATEADD(MINUTE, -51, DATEADD(HOUR, -5, DATEADD(DAY,-6,@now))), N'Phạm Minh Đức', 'duc.pham@outlook.com', '0965432109', DATEADD(MINUTE, -51, DATEADD(HOUR, -5, DATEADD(DAY,-6,@now))));
INSERT INTO OrderItems (order_id, ticket_type_id, quantity, unit_price, subtotal) VALUES (17, 12, 1, 1200000, 1200000);

-- === CUSTOMER 13 (Hà) — diverse events ===
INSERT INTO Orders (order_code, user_id, event_id, total_amount, discount_amount, final_amount, status, payment_method, payment_date, buyer_name, buyer_email, buyer_phone, created_at)
VALUES ('ORD-2026-0018', 13, 8, 300000, 0, 300000, 'paid', 'seepay', DATEADD(MINUTE, -37, DATEADD(HOUR, -1, DATEADD(DAY,-42,@now))), N'Vũ Thị Hà', 'ha.vu@gmail.com', '0945678901', DATEADD(MINUTE, -37, DATEADD(HOUR, -1, DATEADD(DAY,-42,@now))));
INSERT INTO OrderItems (order_id, ticket_type_id, quantity, unit_price, subtotal) VALUES (18, 24, 1, 300000, 300000);

INSERT INTO Orders (order_code, user_id, event_id, total_amount, discount_amount, final_amount, status, payment_method, payment_date, buyer_name, buyer_email, buyer_phone, created_at)
VALUES ('ORD-2026-0019', 13, 20, 300000, 0, 300000, 'paid', 'seepay', DATEADD(MINUTE, -57, DATEADD(HOUR, -9, DATEADD(DAY,-9,@now))), N'Vũ Thị Hà', 'ha.vu@gmail.com', '0945678901', DATEADD(MINUTE, -57, DATEADD(HOUR, -9, DATEADD(DAY,-9,@now))));
INSERT INTO OrderItems (order_id, ticket_type_id, quantity, unit_price, subtotal) VALUES (19, 44, 1, 300000, 300000);

INSERT INTO Orders (order_code, user_id, event_id, total_amount, discount_amount, final_amount, status, payment_method, payment_date, buyer_name, buyer_email, buyer_phone, created_at)
VALUES ('ORD-2026-0020', 13, 18, 500000, 0, 500000, 'paid', 'seepay', DATEADD(MINUTE, -13, DATEADD(HOUR, -18, DATEADD(DAY,-5,@now))), N'Vũ Thị Hà', 'ha.vu@gmail.com', '0945678901', DATEADD(MINUTE, -13, DATEADD(HOUR, -18, DATEADD(DAY,-5,@now))));
INSERT INTO OrderItems (order_id, ticket_type_id, quantity, unit_price, subtotal) VALUES (20, 42, 1, 500000, 500000);

-- === CUSTOMER 14 (Khải) — tech-focused ===
INSERT INTO Orders (order_code, user_id, event_id, total_amount, discount_amount, final_amount, status, payment_method, payment_date, buyer_name, buyer_email, buyer_phone, created_at)
VALUES ('ORD-2026-0021', 14, 13, 1200000, 0, 1200000, 'paid', 'seepay', DATEADD(MINUTE, -43, DATEADD(HOUR, -10, DATEADD(DAY,-15,@now))), N'Đỗ Quang Khải', 'khai.do@gmail.com', '0934567890', DATEADD(MINUTE, -43, DATEADD(HOUR, -10, DATEADD(DAY,-15,@now))));
INSERT INTO OrderItems (order_id, ticket_type_id, quantity, unit_price, subtotal) VALUES (21, 32, 1, 1200000, 1200000);

INSERT INTO Orders (order_code, user_id, event_id, total_amount, discount_amount, final_amount, status, payment_method, payment_date, buyer_name, buyer_email, buyer_phone, created_at)
VALUES ('ORD-2026-0022', 14, 21, 2400000, 0, 2400000, 'paid', 'seepay', DATEADD(MINUTE, -14, DATEADD(HOUR, -17, DATEADD(DAY,-10,@now))), N'Đỗ Quang Khải', 'khai.do@gmail.com', '0934567890', DATEADD(MINUTE, -14, DATEADD(HOUR, -17, DATEADD(DAY,-10,@now))));
INSERT INTO OrderItems (order_id, ticket_type_id, quantity, unit_price, subtotal) VALUES (22, 46, 2, 1200000, 2400000);

-- === CUSTOMER 15 (Tùng) — low spend, 1 order ===
INSERT INTO Orders (order_code, user_id, event_id, total_amount, discount_amount, final_amount, status, payment_method, payment_date, buyer_name, buyer_email, buyer_phone, created_at)
VALUES ('ORD-2026-0023', 15, 17, 50000, 0, 50000, 'paid', 'seepay', DATEADD(MINUTE, -55, DATEADD(HOUR, -9, DATEADD(DAY,-4,@now))), N'Ngô Thanh Tùng', 'tung.ngo@gmail.com', '0923456789', DATEADD(MINUTE, -55, DATEADD(HOUR, -9, DATEADD(DAY,-4,@now))));
INSERT INTO OrderItems (order_id, ticket_type_id, quantity, unit_price, subtotal) VALUES (23, 39, 1, 50000, 50000);

-- === CUSTOMER 17 (Bảo) — regular buyer, uses vouchers ===
INSERT INTO Orders (order_code, user_id, event_id, total_amount, discount_amount, final_amount, status, payment_method, payment_date, buyer_name, buyer_email, buyer_phone, created_at)
VALUES ('ORD-2026-0024', 17, 6, 2400000, 360000, 2040000, 'paid', 'seepay', DATEADD(MINUTE, -17, DATEADD(HOUR, -20, DATEADD(DAY,-12,@now))), N'Bùi Quốc Bảo', 'bao.bui@gmail.com', '0913579246', DATEADD(MINUTE, -17, DATEADD(HOUR, -20, DATEADD(DAY,-12,@now))));
INSERT INTO OrderItems (order_id, ticket_type_id, quantity, unit_price, subtotal) VALUES (24, 21, 2, 1200000, 2400000);

INSERT INTO Orders (order_code, user_id, event_id, total_amount, discount_amount, final_amount, status, payment_method, payment_date, buyer_name, buyer_email, buyer_phone, created_at)
VALUES ('ORD-2026-0025', 17, 26, 1500000, 50000, 1450000, 'paid', 'seepay', DATEADD(MINUTE, -55, DATEADD(HOUR, -22, DATEADD(DAY,-6,@now))), N'Bùi Quốc Bảo', 'bao.bui@gmail.com', '0913579246', DATEADD(MINUTE, -55, DATEADD(HOUR, -22, DATEADD(DAY,-6,@now))));
INSERT INTO OrderItems (order_id, ticket_type_id, quantity, unit_price, subtotal) VALUES (25, 54, 1, 1500000, 1500000);

-- === CUSTOMER 18 (Châu) — refund scenario ===
INSERT INTO Orders (order_code, user_id, event_id, total_amount, discount_amount, final_amount, status, payment_method, payment_date, buyer_name, buyer_email, buyer_phone, created_at)
VALUES ('ORD-2026-0026', 18, 3, 2000000, 0, 2000000, 'refunded', 'seepay', DATEADD(MINUTE, -14, DATEADD(HOUR, -23, DATEADD(DAY,-20,@now))), N'Lý Minh Châu', 'chau.ly@gmail.com', '0978901234', DATEADD(MINUTE, -14, DATEADD(HOUR, -23, DATEADD(DAY,-20,@now))));
INSERT INTO OrderItems (order_id, ticket_type_id, quantity, unit_price, subtotal) VALUES (26, 10, 1, 2000000, 2000000);

INSERT INTO Orders (order_code, user_id, event_id, total_amount, discount_amount, final_amount, status, payment_method, payment_date, buyer_name, buyer_email, buyer_phone, created_at)
VALUES ('ORD-2026-0027', 18, 1, 1500000, 0, 1500000, 'refunded', 'seepay', DATEADD(MINUTE, -24, DATEADD(HOUR, -9, DATEADD(DAY,-14,@now))), N'Lý Minh Châu', 'chau.ly@gmail.com', '0978901234', DATEADD(MINUTE, -24, DATEADD(HOUR, -9, DATEADD(DAY,-14,@now))));
INSERT INTO OrderItems (order_id, ticket_type_id, quantity, unit_price, subtotal) VALUES (27, 3, 1, 1500000, 1500000);

INSERT INTO Orders (order_code, user_id, event_id, total_amount, discount_amount, final_amount, status, payment_method, payment_date, buyer_name, buyer_email, buyer_phone, created_at)
VALUES ('ORD-2026-0028', 18, 17, 80000, 0, 80000, 'paid', 'seepay', DATEADD(MINUTE, -55, DATEADD(HOUR, -9, DATEADD(DAY,-3,@now))), N'Lý Minh Châu', 'chau.ly@gmail.com', '0978901234', DATEADD(MINUTE, -55, DATEADD(HOUR, -9, DATEADD(DAY,-3,@now))));
INSERT INTO OrderItems (order_id, ticket_type_id, quantity, unit_price, subtotal) VALUES (28, 40, 1, 80000, 80000);

-- === CUSTOMER 20 (Diễm) — multiple events ===
INSERT INTO Orders (order_code, user_id, event_id, total_amount, discount_amount, final_amount, status, payment_method, payment_date, buyer_name, buyer_email, buyer_phone, created_at)
VALUES ('ORD-2026-0029', 20, 2, 3500000, 0, 3500000, 'paid', 'seepay', DATEADD(MINUTE, -3, DATEADD(HOUR, -7, DATEADD(DAY,-16,@now))), N'Phan Ngọc Diễm', 'diem.phan@gmail.com', '0967890123', DATEADD(MINUTE, -3, DATEADD(HOUR, -7, DATEADD(DAY,-16,@now))));
INSERT INTO OrderItems (order_id, ticket_type_id, quantity, unit_price, subtotal) VALUES (29, 5, 1, 3500000, 3500000);

INSERT INTO Orders (order_code, user_id, event_id, total_amount, discount_amount, final_amount, status, payment_method, payment_date, buyer_name, buyer_email, buyer_phone, created_at)
VALUES ('ORD-2026-0030', 20, 16, 2500000, 0, 2500000, 'paid', 'seepay', DATEADD(MINUTE, -49, DATEADD(HOUR, -6, DATEADD(DAY,-9,@now))), N'Phan Ngọc Diễm', 'diem.phan@gmail.com', '0967890123', DATEADD(MINUTE, -49, DATEADD(HOUR, -6, DATEADD(DAY,-9,@now))));
INSERT INTO OrderItems (order_id, ticket_type_id, quantity, unit_price, subtotal) VALUES (30, 37, 1, 2500000, 2500000);

-- === CUSTOMER 21 (Kiên) — checked-in tickets ===
INSERT INTO Orders (order_code, user_id, event_id, total_amount, discount_amount, final_amount, status, payment_method, payment_date, buyer_name, buyer_email, buyer_phone, created_at)
VALUES ('ORD-2025-0031', 21, 12, 500000, 0, 500000, 'paid', 'seepay', '2025-10-20', N'Đặng Trung Kiên', 'kien.dang@gmail.com', '0941234567', '2025-10-20');
INSERT INTO OrderItems (order_id, ticket_type_id, quantity, unit_price, subtotal) VALUES (31, 30, 1, 500000, 500000);

INSERT INTO Orders (order_code, user_id, event_id, total_amount, discount_amount, final_amount, status, payment_method, payment_date, buyer_name, buyer_email, buyer_phone, created_at)
VALUES ('ORD-2026-0032', 21, 10, 400000, 0, 400000, 'paid', 'seepay', DATEADD(MINUTE, -23, DATEADD(HOUR, -14, DATEADD(DAY,-30,@now))), N'Đặng Trung Kiên', 'kien.dang@gmail.com', '0941234567', DATEADD(MINUTE, -23, DATEADD(HOUR, -14, DATEADD(DAY,-30,@now))));
INSERT INTO OrderItems (order_id, ticket_type_id, quantity, unit_price, subtotal) VALUES (32, 28, 1, 400000, 400000);

-- === EDGE CASE ORDERS ===
INSERT INTO Orders (order_code, user_id, event_id, total_amount, discount_amount, final_amount, status, payment_method, buyer_name, buyer_email, buyer_phone, created_at)
VALUES ('ORD-2026-0033', 11, 6, 500000, 0, 500000, 'cancelled', 'seepay', N'Lê Hoàng Cường', 'cuong.le@yahoo.com', '0976543210', DATEADD(MINUTE, -7, DATEADD(HOUR, -14, DATEADD(DAY,-10,@now))));
INSERT INTO OrderItems (order_id, ticket_type_id, quantity, unit_price, subtotal) VALUES (33, 20, 1, 500000, 500000);

INSERT INTO Orders (order_code, user_id, event_id, total_amount, discount_amount, final_amount, status, payment_method, payment_date, buyer_name, buyer_email, buyer_phone, created_at)
VALUES ('ORD-2026-0034', 25, 1, 5000000, 0, 5000000, 'paid', 'seepay', DATEADD(MINUTE, -28, DATEADD(HOUR, -1, DATEADD(DAY,-26,@now))), N'Nguyễn Hoàng Phúc', 'fullprofile@gmail.com', '0918765432', DATEADD(MINUTE, -28, DATEADD(HOUR, -1, DATEADD(DAY,-26,@now))));
INSERT INTO OrderItems (order_id, ticket_type_id, quantity, unit_price, subtotal) VALUES (34, 1, 1, 5000000, 5000000);

INSERT INTO Orders (order_code, user_id, event_id, total_amount, discount_amount, final_amount, status, payment_method, payment_date, buyer_name, buyer_email, buyer_phone, created_at)
VALUES ('ORD-2026-0035', 18, 6, 500000, 0, 500000, 'refunded', 'seepay', DATEADD(MINUTE, -21, DATEADD(HOUR, -6, DATEADD(DAY,-15,@now))), N'Lý Minh Châu', 'chau.ly@gmail.com', '0978901234', DATEADD(MINUTE, -21, DATEADD(HOUR, -6, DATEADD(DAY,-15,@now))));
INSERT INTO OrderItems (order_id, ticket_type_id, quantity, unit_price, subtotal) VALUES (35, 20, 1, 500000, 500000);
GO

PRINT '=== 35 orders + order items seeded ===';
GO

-- =============================================
-- =============================================
INSERT INTO Tickets (ticket_code, order_item_id, attendee_name, attendee_email, qr_code, is_checked_in) VALUES
('TIX-HAT-001', 1, N'Nguyễn Văn An', 'customer@ticketbox.vn', 'TIX-HAT-001|E1|VIP|20260420', 0),
('TIX-HAT-002', 1, N'Nguyễn Thị Mai', 'mai@gmail.com', 'TIX-HAT-002|E1|VIP|20260420', 0),
('TIX-HAT-003', 2, N'Nguyễn Văn An', 'customer@ticketbox.vn', 'TIX-HAT-003|E1|CAT1|20260420', 0),
('TIX-STU-001', 3, N'Nguyễn Văn An', 'customer@ticketbox.vn', 'TIX-STU-001|E3|GOLD|20260615', 0),
('TIX-STU-002', 3, N'Trần Minh Tú', 'tu.tran@gmail.com', 'TIX-STU-002|E3|GOLD|20260615', 0),
('TIX-FDF-001', 4, N'Nguyễn Văn An', 'customer@ticketbox.vn', 'TIX-FDF-001|E17|VIP|20260501', 0),
('TIX-FDF-002', 4, N'Nguyễn Thị Mai', 'mai@gmail.com', 'TIX-FDF-002|E17|VIP|20260501', 0),
('TIX-DS-001', 5, N'Nguyễn Văn An', 'customer@ticketbox.vn', 'TIX-DS-001|E14|FULL|20260415', 0),
('TIX-AIS-001', 6, N'Nguyễn Văn An', 'customer@ticketbox.vn', 'TIX-AIS-001|E26|STU|20260620', 0),
('TIX-IND-001', 7, N'Nguyễn Văn An', 'customer@ticketbox.vn', 'TIX-IND-001|E6|GA|20260412', 0),
('TIX-IND-002', 7, N'Trần Minh Tú', 'tu.tran@gmail.com', 'TIX-IND-002|E6|GA|20260412', 0),
('TIX-HAT-004', 8, N'Trần Thị Bình', 'binh.tran@gmail.com', 'TIX-HAT-004|E1|SVIP|20260420', 0),
('TIX-AIS-002', 9, N'Trần Thị Bình', 'binh.tran@gmail.com', 'TIX-AIS-002|E26|VIP|20260620', 0),
('TIX-SPD-001', 10, N'Trần Thị Bình', 'binh.tran@gmail.com', 'TIX-SPD-001|E23|GA|20260515', 0),
('TIX-ART-001', 11, N'Trần Thị Bình', 'binh.tran@gmail.com', 'TIX-ART-001|E20|WS|20260415', 0),
('TIX-ART-002', 11, N'Nguyễn Hoàng Long', 'long@gmail.com', 'TIX-ART-002|E20|WS|20260415', 0),
('TIX-MTM-001', 12, N'Lê Hoàng Cường', 'cuong.le@yahoo.com', 'TIX-MTM-001|E2|A|20260510', 0),
('TIX-MTM-002', 12, N'Lê Thị Lan', 'lan.le@gmail.com', 'TIX-MTM-002|E2|A|20260510', 0),
('TIX-NR-001', 14, N'Lê Hoàng Cường', 'cuong.le@yahoo.com', 'TIX-NR-001|E10|10K|20260322', 0),
('TIX-NR-002', 14, N'Lê Thị Lan', 'lan.le@gmail.com', 'TIX-NR-002|E10|10K|20260322', 0),
('TIX-MRT-001', 15, N'Phạm Minh Đức', 'duc.pham@outlook.com', 'TIX-MRT-001|E8|HALF|20260503', 0),
('TIX-HKT-001', 16, N'Team Codecraft', 'duc.pham@outlook.com', 'TIX-HKT-001|E27|TEAM|20260524', 0),
('TIX-ACS-001', 17, N'Phạm Minh Đức & Ngọc Anh', 'duc.pham@outlook.com', 'TIX-ACS-001|E4|COUPLE|20260328', 0),
('TIX-MRT-002', 18, N'Vũ Thị Hà', 'ha.vu@gmail.com', 'TIX-MRT-002|E8|5K|20260503', 0),
('TIX-ART-003', 19, N'Vũ Thị Hà', 'ha.vu@gmail.com', 'TIX-ART-003|E20|WS|20260415', 0),
('TIX-CK-001', 20, N'Vũ Thị Hà', 'ha.vu@gmail.com', 'TIX-CK-001|E18|STD|20260330', 0),
('TIX-UXW-001', 21, N'Đỗ Quang Khải', 'khai.do@gmail.com', 'TIX-UXW-001|E13|STD|20260405', 0),
('TIX-TC-001', 22, N'Đỗ Quang Khải', 'khai.do@gmail.com', 'TIX-TC-001|E21|A|20260520', 0),
('TIX-TC-002', 22, N'Đỗ Thị Hương', 'huong.do@gmail.com', 'TIX-TC-002|E21|A|20260520', 0),
('TIX-FDF-003', 23, N'Ngô Thanh Tùng', 'tung.ngo@gmail.com', 'TIX-FDF-003|E17|STD|20260501', 0),
('TIX-IND-003', 24, N'Bùi Quốc Bảo', 'bao.bui@gmail.com', 'TIX-IND-003|E6|VIP|20260412', 0),
('TIX-IND-004', 24, N'Nguyễn Thùy Linh', 'linh.nguyen@gmail.com', 'TIX-IND-004|E6|VIP|20260412', 0),
('TIX-AIS-003', 25, N'Bùi Quốc Bảo', 'bao.bui@gmail.com', 'TIX-AIS-003|E26|STD|20260620', 0),
('TIX-FDF-004', 28, N'Lý Minh Châu', 'chau.ly@gmail.com', 'TIX-FDF-004|E17|WE|20260503', 0),
('TIX-MTM-003', 29, N'Phan Ngọc Diễm', 'diem.phan@gmail.com', 'TIX-MTM-003|E2|VIP|20260510', 0),
('TIX-DM-001', 30, N'Phan Ngọc Diễm', 'diem.phan@gmail.com', 'TIX-DM-001|E16|FULL|20260520', 0),
('TIX-FR-001', 31, N'Đặng Trung Kiên', 'kien.dang@gmail.com', 'TIX-FR-001|E12|VIP|20251115', 1),
('TIX-NR-003', 32, N'Đặng Trung Kiên', 'kien.dang@gmail.com', 'TIX-NR-003|E10|10K|20260322', 0),
('TIX-HAT-005', 34, N'Nguyễn Hoàng Phúc', 'fullprofile@gmail.com', 'TIX-HAT-005|E1|SVIP|20260420', 0);
GO

PRINT '=== 40 tickets seeded (1 checked-in) ===';
GO

-- =============================================
-- =============================================
INSERT INTO PaymentTransactions (order_id, payment_method, seepay_transaction_id, amount, status, completed_at) VALUES
(1,  'seepay', 'SP-202602-001', 7500000, 'completed', DATEADD(MINUTE, -38, DATEADD(HOUR, -23, DATEADD(DAY,-30,GETDATE())))),
(2,  'seepay', 'SP-202602-002', 4000000, 'completed', DATEADD(MINUTE, -18, DATEADD(HOUR, -8, DATEADD(DAY,-25,GETDATE())))),
(3,  'seepay', 'SP-202602-003', 500000,  'completed', DATEADD(MINUTE, -53, DATEADD(HOUR, -23, DATEADD(DAY,-22,GETDATE())))),
(4,  'seepay', 'SP-202602-004', 600000,  'completed', DATEADD(MINUTE, -3, DATEADD(HOUR, -18, DATEADD(DAY,-18,GETDATE())))),
(5,  'seepay', 'SP-202603-005', 500000,  'completed', DATEADD(MINUTE, -29, DATEADD(HOUR, -11, DATEADD(DAY,-10,GETDATE())))),
(6,  'seepay', 'SP-202603-006', 1000000, 'completed', DATEADD(MINUTE, -16, DATEADD(HOUR, -21, DATEADD(DAY,-8,GETDATE())))),
(7,  'seepay', NULL,            2000000, 'pending',   NULL),
(8,  'seepay', 'SP-202602-008', 5000000, 'completed', DATEADD(MINUTE, -6, DATEADD(HOUR, -8, DATEADD(DAY,-28,GETDATE())))),
(9,  'seepay', 'SP-202602-009', 3000000, 'completed', DATEADD(MINUTE, -38, DATEADD(HOUR, -15, DATEADD(DAY,-15,GETDATE())))),
(10, 'seepay', 'SP-202603-010', 200000,  'completed', DATEADD(MINUTE, -48, DATEADD(HOUR, -22, DATEADD(DAY,-12,GETDATE())))),
(11, 'seepay', 'SP-202603-011', 510000,  'completed', DATEADD(MINUTE, -14, DATEADD(HOUR, -15, DATEADD(DAY,-7,GETDATE())))),
(12, 'seepay', 'SP-202602-012', 4000000, 'completed', DATEADD(MINUTE, -2, DATEADD(HOUR, -16, DATEADD(DAY,-20,GETDATE())))),
(13, 'seepay', NULL,            800000,  'cancelled', NULL),
(14, 'seepay', 'SP-202601-014', 800000,  'completed', DATEADD(MINUTE, -53, DATEADD(HOUR, -23, DATEADD(DAY,-35,GETDATE())))),
(15, 'seepay', 'SP-202601-015', 800000,  'completed', DATEADD(MINUTE, -5, DATEADD(HOUR, -2, DATEADD(DAY,-45,GETDATE())))),
(16, 'cash',   NULL,            0,       'completed', DATEADD(MINUTE, -52, DATEADD(HOUR, -3, DATEADD(DAY,-8,GETDATE())))),
(17, 'seepay', 'SP-202603-017', 1200000, 'completed', DATEADD(MINUTE, -55, DATEADD(HOUR, -9, DATEADD(DAY,-6,GETDATE())))),
(18, 'seepay', 'SP-202601-018', 300000,  'completed', DATEADD(MINUTE, -35, DATEADD(HOUR, -19, DATEADD(DAY,-42,GETDATE())))),
(19, 'seepay', 'SP-202603-019', 300000,  'completed', DATEADD(MINUTE, -13, DATEADD(HOUR, -2, DATEADD(DAY,-9,GETDATE())))),
(20, 'seepay', 'SP-202603-020', 500000,  'completed', DATEADD(MINUTE, -30, DATEADD(HOUR, -14, DATEADD(DAY,-5,GETDATE())))),
(21, 'seepay', 'SP-202602-021', 1200000, 'completed', DATEADD(MINUTE, -17, DATEADD(HOUR, -21, DATEADD(DAY,-15,GETDATE())))),
(22, 'seepay', 'SP-202603-022', 2400000, 'completed', DATEADD(MINUTE, -50, DATEADD(HOUR, -14, DATEADD(DAY,-10,GETDATE())))),
(23, 'seepay', 'SP-202603-023', 50000,   'completed', DATEADD(MINUTE, -24, DATEADD(HOUR, -21, DATEADD(DAY,-4,GETDATE())))),
(24, 'seepay', 'SP-202603-024', 2040000, 'completed', DATEADD(MINUTE, -48, DATEADD(HOUR, -14, DATEADD(DAY,-12,GETDATE())))),
(25, 'seepay', 'SP-202603-025', 1450000, 'completed', DATEADD(MINUTE, -50, DATEADD(HOUR, -2, DATEADD(DAY,-6,GETDATE())))),
(26, 'seepay', 'SP-202602-026', 2000000, 'refunded',  DATEADD(MINUTE, -49, DATEADD(HOUR, -11, DATEADD(DAY,-20,GETDATE())))),
(27, 'seepay', 'SP-202602-027', 1500000, 'refunded',  DATEADD(MINUTE, -27, DATEADD(HOUR, -4, DATEADD(DAY,-14,GETDATE())))),
(28, 'seepay', 'SP-202603-028', 80000,   'completed', DATEADD(MINUTE, -56, DATEADD(HOUR, -7, DATEADD(DAY,-3,GETDATE())))),
(29, 'seepay', 'SP-202602-029', 3500000, 'completed', DATEADD(MINUTE, -35, DATEADD(HOUR, -23, DATEADD(DAY,-16,GETDATE())))),
(30, 'seepay', 'SP-202603-030', 2500000, 'completed', DATEADD(MINUTE, -43, DATEADD(HOUR, -11, DATEADD(DAY,-9,GETDATE())))),
(31, 'seepay', 'SP-202510-031', 500000,  'completed', '2025-10-20'),
(32, 'seepay', 'SP-202602-032', 400000,  'completed', DATEADD(MINUTE, -2, DATEADD(HOUR, -22, DATEADD(DAY,-30,GETDATE())))),
(33, 'seepay', NULL,            500000,  'cancelled', NULL),
(34, 'seepay', 'SP-202602-034', 5000000, 'completed', DATEADD(MINUTE, -21, DATEADD(HOUR, -22, DATEADD(DAY,-26,GETDATE())))),
(35, 'seepay', 'SP-202602-035', 500000,  'refunded',  DATEADD(MINUTE, -2, DATEADD(HOUR, -6, DATEADD(DAY,-15,GETDATE()))));
GO

-- =============================================
-- =============================================
INSERT INTO Vouchers (organizer_id, event_id, code, discount_type, discount_value, min_order_amount, max_discount, usage_limit, used_count, start_date, end_date, is_active, voucher_scope, fund_source) VALUES
(4, 1,    'HAT2026VIP',   'percentage', 10, 2000000, 500000, 50, 15,  '2026-01-15', '2026-04-20', 1, 'EVENT', 'ORGANIZER'),
(4, NULL, 'LIVENATION15', 'percentage', 15, 1000000, 750000, 100, 42, '2026-01-01', '2026-12-31', 1, 'EVENT', 'ORGANIZER'),
(6, 26,   'AITECH50K',    'fixed',      50000, 500000, 0, 200, 97,    '2026-03-01', '2026-06-20', 1, 'EVENT', 'ORGANIZER'),
(7, 8,    'RUN2026',      'fixed',      100000, 500000, 0, 300, 182,  '2026-01-01', '2026-05-01', 1, 'EVENT', 'ORGANIZER'),
(5, 17,   'FOODIE20',     'percentage', 20, 100000, 200000, 500, 222, '2026-04-01', '2026-05-04', 1, 'EVENT', 'ORGANIZER'),
(8, 6,    'SUNSET10',     'percentage', 10, 500000, 300000, 100, 20,  '2026-02-01', '2026-04-11', 1, 'EVENT', 'ORGANIZER'),
(6, NULL, 'TECHVIET100K', 'fixed',      100000, 1000000, 0, 50, 10,  '2026-01-01', '2026-12-31', 1, 'EVENT', 'ORGANIZER'),
(4, NULL, 'EXPIRED2025',  'percentage', 25, 500000, 1000000, 100, 45, '2025-01-01', '2025-12-31', 0, 'EVENT', 'ORGANIZER'),
(1, NULL, 'SYSLAUNCH50',  'fixed',      50000, 200000, 0, 1000, 130, '2026-01-01', '2026-06-30', 1, 'SYSTEM', 'SYSTEM'),
(1, NULL, 'SYSVIP10',     'percentage', 10, 3000000, 500000, 500, 92, '2026-01-15', '2026-12-31', 1, 'SYSTEM', 'SYSTEM'),
(1, NULL, 'SYSFLASH200K', 'fixed',      200000, 1000000, 0, 200, 68,  '2026-03-01', '2026-03-31', 1, 'SYSTEM', 'SYSTEM'),
(1, NULL, 'SYSWELCOME30', 'fixed',      30000, 50000, 0, 5000, 415,  '2026-01-01', '2026-12-31', 1, 'SYSTEM', 'SYSTEM');
GO

-- =============================================
-- =============================================
INSERT INTO VoucherUsages (voucher_id, order_id, discount_applied, used_at) VALUES
(2, 11, 90000,  DATEADD(MINUTE, -33, DATEADD(HOUR, -12, DATEADD(DAY,-7,GETDATE())))),   -- LIVENATION15 on O11 (Bình — Triển lãm)
(6, 24, 360000, DATEADD(MINUTE, -33, DATEADD(HOUR, -7, DATEADD(DAY,-12,GETDATE())))),  -- SUNSET10 on O24 (Bảo — Indie Sunset) — wait, 10% of 2.4M = 240K
(3, 25, 50000,  DATEADD(MINUTE, -7, DATEADD(HOUR, -15, DATEADD(DAY,-6,GETDATE()))));    -- AITECH50K on O25 (Bảo — AI Summit)
GO

UPDATE VoucherUsages SET voucher_id = 2 WHERE order_id = 24;
GO

-- =============================================
-- =============================================
INSERT INTO EventStaff (event_id, user_id, role, granted_by) VALUES
(1, 9, 'scanner', 4),    -- An is scanner for Hà Anh Tuấn
(1, 10, 'staff', 4),     -- Bình is staff
(3, 12, 'scanner', 4),   -- Đức is scanner for Sơn Tùng
(8, 12, 'scanner', 7),   -- Đức scanner for Marathon
(13, 14, 'staff', 6),    -- Khải staff for UI/UX
(26, 12, 'scanner', 6),  -- Đức scanner for AI Summit
(26, 11, 'manager', 6),  -- Cường manager for AI Summit
(6, 17, 'scanner', 8),   -- Bảo scanner for Indie Sunset
(12, 21, 'scanner', 7),  -- Kiên scanner for Fun Run 2025
(17, 13, 'scanner', 5),  -- Hà scanner for Food Festival
(2, 20, 'staff', 4);     -- Diễm staff for Mỹ Tâm
GO

-- =============================================
-- =============================================
INSERT INTO SupportTickets (ticket_code, user_id, order_id, event_id, category, subject, description, status, priority, routed_to, assigned_to, resolved_at, created_at) VALUES
('SPT-001', 9, 1, 1, 'payment_error',
 N'Thanh toán thành công nhưng chưa nhận được vé',
 N'Tôi đã thanh toán ORD-2026-0001 thành công, tiền trừ rồi nhưng 30 phút vẫn chưa nhận email vé.',
 'resolved', 'high', 'admin', 2, DATEADD(MINUTE, -46, DATEADD(HOUR, -7, DATEADD(DAY,-29,GETDATE()))), DATEADD(MINUTE, -46, DATEADD(HOUR, -7, DATEADD(DAY,-29,GETDATE())))),

('SPT-002', 10, NULL, 2, 'event_issue',
 N'Hỏi dress code liveshow Mỹ Tâm',
 N'Liveshow có yêu cầu dress code không? Khu VIP có tặng đồ uống không?',
 'closed', 'low', 'organizer', NULL, DATEADD(MINUTE, -32, DATEADD(HOUR, -21, DATEADD(DAY,-18,GETDATE()))), DATEADD(MINUTE, -32, DATEADD(HOUR, -21, DATEADD(DAY,-19,GETDATE())))),

('SPT-003', 11, 13, 3, 'cancellation',
 N'Yêu cầu hủy đơn hàng ORD-2026-0013',
 N'Thay đổi lịch cá nhân, xin hủy đơn và hoàn tiền. Đã thanh toán qua SeePay.',
 'in_progress', 'normal', 'admin', 2, NULL, DATEADD(MINUTE, -57, DATEADD(HOUR, -14, DATEADD(DAY,-17,GETDATE())))),

('SPT-004', 12, NULL, 27, 'technical',
 N'Không tải được QR code vé Hackathon',
 N'QR code bị lỗi trắng trên Chrome Android 14. Đã clear cache.',
 'open', 'normal', 'admin', NULL, NULL, DATEADD(MINUTE, -38, DATEADD(HOUR, -11, DATEADD(DAY,-3,GETDATE())))),

('SPT-005', 13, NULL, NULL, 'feedback',
 N'Góp ý giao diện trang Vé của tôi',
 N'Trang Vé đẹp, muốn có thêm filter theo trạng thái vé. Cảm ơn team!',
 'open', 'low', 'admin', NULL, NULL, DATEADD(MINUTE, -59, DATEADD(HOUR, -18, DATEADD(DAY,-1,GETDATE())))),

('SPT-006', 18, 26, 3, 'refund',
 N'Yêu cầu hoàn tiền vé Sơn Tùng Sky Tour',
 N'Tôi không thể tham dự do bệnh. Xin hoàn tiền theo chính sách. Đơn: ORD-2026-0026.',
 'resolved', 'high', 'admin', 2, DATEADD(MINUTE, -42, DATEADD(HOUR, -18, DATEADD(DAY,-18,GETDATE()))), DATEADD(MINUTE, -42, DATEADD(HOUR, -18, DATEADD(DAY,-19,GETDATE())))),

('SPT-007', 16, NULL, NULL, 'account_issue',
 N'Email chưa xác minh — không nhận được mã',
 N'Tôi đăng ký tài khoản nhưng không nhận được email xác minh. Đã kiểm tra spam.',
 'in_progress', 'normal', 'admin', 3, NULL, DATEADD(MINUTE, -17, DATEADD(HOUR, -2, DATEADD(DAY,-2,GETDATE())))),

('SPT-008', 17, 24, 6, 'missing_ticket',
 N'Đã thanh toán nhưng thiếu 1 vé',
 N'Đơn ORD-2026-0024 mua 2 vé VIP Beach Lounge nhưng chỉ nhận được 1 email vé.',
 'open', 'high', 'admin', NULL, NULL, DATEADD(MINUTE, -29, DATEADD(HOUR, -2, DATEADD(DAY,-1,GETDATE())))),

('SPT-009', 20, NULL, 16, 'event_issue',
 N'Digital Marketing workshop có online không?',
 N'Tôi ở Hà Nội, có thể tham dự online được không?',
 'resolved', 'low', 'organizer', NULL, DATEADD(MINUTE, -51, DATEADD(HOUR, -6, DATEADD(DAY,-7,GETDATE()))), DATEADD(MINUTE, -51, DATEADD(HOUR, -6, DATEADD(DAY,-8,GETDATE())))),

('SPT-010', 18, 27, 1, 'refund',
 N'Hoàn tiền vé Hà Anh Tuấn — trùng lịch',
 N'Đơn ORD-2026-0027 trùng lịch công tác nước ngoài. Xin hoàn theo chính sách.',
 'open', 'urgent', 'admin', NULL, NULL, DATEADD(MINUTE, -8, DATEADD(HOUR, -4, DATEADD(DAY,-1,GETDATE()))));
GO

-- =============================================
-- =============================================
INSERT INTO TicketMessages (ticket_id, sender_id, content, is_internal, created_at) VALUES
(1, 9, N'Tôi đã thanh toán ORD-2026-0001, tiền đã trừ nhưng 30 phút chưa nhận email vé.', 0, DATEADD(MINUTE, -56, DATEADD(HOUR, -23, DATEADD(DAY,-29,GETDATE())))),
(1, 2, N'[Internal] SeePay dashboard: SP-202602-001 completed. Vé đã phát hành. Email bị spam filter.', 1, DATEADD(MINUTE,-1430,GETDATE())),
(1, 2, N'Chào anh An! Đơn hàng đã xác nhận thành công. Email đã gửi lại, kiểm tra spam nhé. Xin lỗi vì bất tiện!', 0, DATEADD(MINUTE,-1425,GETDATE())),
(1, 9, N'Đã nhận được email rồi ạ. Cảm ơn hỗ trợ nhanh!', 0, DATEADD(MINUTE, -35, DATEADD(HOUR, -19, DATEADD(DAY,-28,GETDATE())))),

(3, 11, N'Do thay đổi lịch, xin hủy ORD-2026-0013 và hoàn tiền.', 0, DATEADD(MINUTE, -47, DATEADD(HOUR, -15, DATEADD(DAY,-17,GETDATE())))),
(3, 2, N'Chào anh Cường, đã tiếp nhận. Hủy trước 7 ngày hoàn 80%. Xử lý trong 3-5 ngày làm việc.', 0, DATEADD(MINUTE, -37, DATEADD(HOUR, -10, DATEADD(DAY,-16,GETDATE())))),
(3, 11, N'Vâng, mong được xử lý sớm ạ. Cảm ơn.', 0, DATEADD(MINUTE, -17, DATEADD(HOUR, -15, DATEADD(DAY,-16,GETDATE())))),

(4, 12, N'QR code vé hackathon hiện ô trắng. Chrome Android 14, đã clear cache.', 0, DATEADD(MINUTE, -2, DATEADD(HOUR, -2, DATEADD(DAY,-3,GETDATE())))),

(6, 18, N'Bị bệnh không thể tham dự. Xin hoàn tiền ORD-2026-0026.', 0, DATEADD(MINUTE, -35, DATEADD(HOUR, -2, DATEADD(DAY,-19,GETDATE())))),
(6, 2, N'[Internal] Verify medical reason. Process refund 80%.', 1, DATEADD(MINUTE, -43, DATEADD(HOUR, -12, DATEADD(DAY,-19,GETDATE())))),
(6, 2, N'Chào chị Châu, đã xử lý hoàn tiền 80% (1.600.000đ). Tiền sẽ về trong 5-7 ngày.', 0, DATEADD(MINUTE, -4, DATEADD(HOUR, -19, DATEADD(DAY,-18,GETDATE())))),
(6, 18, N'Đã nhận được thông báo hoàn tiền. Cảm ơn!', 0, DATEADD(MINUTE, -44, DATEADD(HOUR, -16, DATEADD(DAY,-18,GETDATE())))),

(7, 16, N'Không nhận được email xác minh sau khi đăng ký. Đã kiểm tra spam.', 0, DATEADD(MINUTE, -54, DATEADD(HOUR, -18, DATEADD(DAY,-2,GETDATE())))),
(7, 3, N'Chào bạn, em kiểm tra hệ thống. Email yen.hoang@yahoo.com đã gửi nhưng bị bounce. Bạn kiểm tra lại email nhé.', 0, DATEADD(MINUTE, -2, DATEADD(HOUR, -2, DATEADD(DAY,-2,GETDATE())))),

(8, 17, N'Đơn ORD-2026-0024 mua 2 vé nhưng chỉ nhận 1 email. Kiểm tra giúp.', 0, DATEADD(MINUTE, -50, DATEADD(HOUR, -22, DATEADD(DAY,-1,GETDATE())))),

(9, 20, N'Workshop Digital Marketing có hỗ trợ online không ạ?', 0, DATEADD(MINUTE, -43, DATEADD(HOUR, -8, DATEADD(DAY,-8,GETDATE())))),

(10, 18, N'Trùng lịch công tác, xin hoàn vé HAT ORD-2026-0027. Rất gấp ạ.', 0, DATEADD(MINUTE, -47, DATEADD(HOUR, -4, DATEADD(DAY,-1,GETDATE()))));
GO

PRINT '=== 10 support tickets + 18 messages seeded ===';
GO

-- =============================================
-- =============================================
INSERT INTO ChatSessions (customer_id, agent_id, event_id, status, created_at, closed_at) VALUES
(9, 2, 1, 'closed', DATEADD(MINUTE, -19, DATEADD(HOUR, -16, DATEADD(DAY,-28,GETDATE()))), DATEADD(MINUTE, -19, DATEADD(HOUR, -16, DATEADD(DAY,-28,GETDATE())))),
(10, 2, NULL, 'closed', DATEADD(MINUTE, -12, DATEADD(HOUR, -2, DATEADD(DAY,-18,GETDATE()))), DATEADD(MINUTE, -12, DATEADD(HOUR, -2, DATEADD(DAY,-18,GETDATE())))),
(12, 2, 27, 'active', DATEADD(HOUR,-2,GETDATE()), NULL),
(15, NULL, NULL, 'waiting', DATEADD(MINUTE,-30,GETDATE()), NULL),
(18, 3, NULL, 'closed', DATEADD(MINUTE, -20, DATEADD(HOUR, -22, DATEADD(DAY,-17,GETDATE()))), DATEADD(MINUTE, -20, DATEADD(HOUR, -22, DATEADD(DAY,-17,GETDATE())))),
(20, 2, 2, 'active', DATEADD(MINUTE,-45,GETDATE()), NULL);

INSERT INTO ChatMessages (session_id, sender_id, content, created_at) VALUES
(1, 9,  N'Xin chào, tôi muốn hỏi về vé VIP Gold cho concert Hà Anh Tuấn ạ', DATEADD(MINUTE, -1, DATEADD(HOUR, -3, DATEADD(DAY,-28,GETDATE())))),
(1, 2,  N'Chào anh! VIP Gold: chỗ ngồi khu VIP trung tâm + đồ uống miễn phí tại lounge. Giá 3.000.000đ/vé ạ.', DATEADD(MINUTE, -14, DATEADD(HOUR, -10, DATEADD(DAY,-28,GETDATE())))),
(1, 9,  N'Lounge mở cửa từ mấy giờ ạ?', DATEADD(MINUTE, -31, DATEADD(HOUR, -9, DATEADD(DAY,-28,GETDATE())))),
(1, 2,  N'VIP Lounge mở từ 17:00 nhé anh. Check-in sớm để tận hưởng đồ uống trước show!', DATEADD(MINUTE, -17, DATEADD(HOUR, -16, DATEADD(DAY,-28,GETDATE())))),
(1, 9,  N'OK cảm ơn nhiều nhé!', DATEADD(MINUTE, -53, DATEADD(HOUR, -7, DATEADD(DAY,-28,GETDATE())))),

(2, 10, N'Mình muốn hỏi chính sách hoàn vé ạ?', DATEADD(MINUTE, -53, DATEADD(HOUR, -15, DATEADD(DAY,-18,GETDATE())))),
(2, 2,  N'Chào bạn! Hủy trước 7 ngày → hoàn 80%, 3-7 ngày → 50%, dưới 3 ngày → không hoàn.', DATEADD(MINUTE, -8, DATEADD(HOUR, -2, DATEADD(DAY,-18,GETDATE())))),
(2, 10, N'Mình chỉ hỏi thôi ạ. Cảm ơn!', DATEADD(MINUTE, -38, DATEADD(HOUR, -9, DATEADD(DAY,-18,GETDATE())))),

(3, 12, N'QR code vé hackathon bị lỗi, không hiển thị được ạ', DATEADD(HOUR,-2,GETDATE())),
(3, 2,  N'Chào anh! Anh thử đổi sang trình duyệt khác xem sao ạ? Hoặc gửi mã vé em tra giúp.', DATEADD(HOUR,-1,GETDATE())),
(3, 12, N'Mã vé là TIX-HKT-001 ạ', DATEADD(MINUTE,-55,GETDATE())),
(3, 2,  N'Em đã kiểm tra, QR code vẫn hợp lệ. Anh thử mở trên Safari hoặc Firefox nhé.', DATEADD(MINUTE,-50,GETDATE())),

(4, 15, N'Cho hỏi thanh toán bằng chuyển khoản ngân hàng được không ạ?', DATEADD(MINUTE,-30,GETDATE())),

(5, 18, N'Tôi đã yêu cầu hoàn tiền, bao lâu thì nhận được ạ?', DATEADD(MINUTE, -53, DATEADD(HOUR, -2, DATEADD(DAY,-17,GETDATE())))),
(5, 3,  N'Hoàn tiền qua SeePay thường mất 5-7 ngày làm việc kể từ khi xác nhận ạ.', DATEADD(MINUTE, -19, DATEADD(HOUR, -2, DATEADD(DAY,-17,GETDATE())))),
(5, 18, N'Vâng cảm ơn.', DATEADD(MINUTE, -38, DATEADD(HOUR, -1, DATEADD(DAY,-17,GETDATE())))),

(6, 20, N'Cho hỏi liveshow Mỹ Tâm có chia zone Standing không ạ?', DATEADD(MINUTE,-45,GETDATE())),
(6, 2,  N'Chào chị! Liveshow chia 3 zone: VIP Hàng Đầu, Hạng A, Hạng B. Không có Standing ạ.', DATEADD(MINUTE,-40,GETDATE())),
(6, 20, N'Vậy Hạng A ngồi hàng mấy ạ?', DATEADD(MINUTE,-35,GETDATE())),
(6, 2,  N'Hạng A là hàng ghế 6-15, khu trung tâm. View rất tốt ạ!', DATEADD(MINUTE,-30,GETDATE()));
GO

PRINT '=== 6 chat sessions + 22 messages seeded ===';
GO

-- =============================================
-- =============================================
INSERT INTO Media (uploader_id, cloudinary_url, cloudinary_public_id, file_name, file_size, media_type, mime_type, width, height, entity_type, entity_id, media_purpose, display_order, alt_text) VALUES
(9, 'https://res.cloudinary.com/ticketbox/image/upload/v1/avatars/user_9.jpg', 'avatars/user_9', 'user_9.jpg', 45000, 'image', 'image/jpeg', 200, 200, 'user', 9, 'avatar', 0, N'Nguyễn Văn An avatar'),
(10, 'https://res.cloudinary.com/ticketbox/image/upload/v1/avatars/user_10.jpg', 'avatars/user_10', 'user_10.jpg', 38000, 'image', 'image/jpeg', 200, 200, 'user', 10, 'avatar', 0, N'Trần Thị Bình avatar'),
(4, 'https://res.cloudinary.com/ticketbox/image/upload/v1/events/hat_banner.jpg', 'events/hat_banner', 'hat_concert_banner.jpg', 520000, 'image', 'image/jpeg', 1920, 1080, 'event', 1, 'banner', 0, N'Hà Anh Tuấn Concert 2026 Banner'),
(4, 'https://res.cloudinary.com/ticketbox/image/upload/v1/events/mytam_banner.jpg', 'events/mytam_banner', 'mytam_liveshow_banner.jpg', 480000, 'image', 'image/jpeg', 1920, 1080, 'event', 2, 'banner', 0, N'Mỹ Tâm My Soul Banner'),
(4, 'https://res.cloudinary.com/ticketbox/image/upload/v1/events/sontung_banner.jpg', 'events/sontung_banner', 'sontung_sky_tour.jpg', 550000, 'image', 'image/jpeg', 1920, 1080, 'event', 3, 'banner', 0, N'Sơn Tùng Sky Tour Banner'),
(4, 'https://res.cloudinary.com/ticketbox/image/upload/v1/events/hat_gallery1.jpg', 'events/hat_gallery1', 'hat_stage_setup.jpg', 320000, 'image', 'image/jpeg', 1280, 720, 'event', 1, 'gallery', 1, N'Sân khấu 360 độ'),
(4, 'https://res.cloudinary.com/ticketbox/image/upload/v1/events/hat_gallery2.jpg', 'events/hat_gallery2', 'hat_vip_lounge.jpg', 280000, 'image', 'image/jpeg', 1280, 720, 'event', 1, 'gallery', 2, N'VIP Lounge area'),
(7, 'https://res.cloudinary.com/ticketbox/image/upload/v1/events/marathon_gallery1.jpg', 'events/marathon_gallery1', 'marathon_start.jpg', 410000, 'image', 'image/jpeg', 1920, 1080, 'event', 8, 'gallery', 1, N'Xuất phát Marathon'),
(4, 'https://res.cloudinary.com/ticketbox/image/upload/v1/tickets/hat_svip.jpg', 'tickets/hat_svip', 'hat_svip_design.jpg', 150000, 'image', 'image/jpeg', 600, 400, 'ticket_type', 1, 'ticket_design', 0, N'SVIP Diamond ticket design'),
(4, 'https://res.cloudinary.com/ticketbox/image/upload/v1/tickets/hat_vip.jpg', 'tickets/hat_vip', 'hat_vip_design.jpg', 140000, 'image', 'image/jpeg', 600, 400, 'ticket_type', 2, 'ticket_design', 0, N'VIP Gold ticket design');
GO

PRINT '=== 10 media records seeded ===';
GO

-- =============================================
-- =============================================
INSERT INTO SiteSettings (setting_key, setting_value) VALUES
('chat_enabled',                   'true'),
('chat_auto_accept',               'true'),
('chat_cooldown_minutes',          '30'),
('site_name',                      'Ticketbox'),
('require_event_approval',         'true'),
('allow_organizer_registration',   'true');
GO

PRINT '=== Site settings seeded ===';
GO

GO

-- =============================================
-- =============================================
INSERT INTO ActivityLog (user_id, action, entity_type, entity_id, details, ip_address, created_at) VALUES
(1, 'APPROVE_EVENT', 'Event', 1, N'Approved event: Hà Anh Tuấn Concert 2026', '192.168.1.100', DATEADD(MINUTE, -33, DATEADD(HOUR, -17, DATEADD(DAY,-40,GETDATE())))),
(1, 'APPROVE_EVENT', 'Event', 2, N'Approved event: Mỹ Tâm Liveshow My Soul 1981', '192.168.1.100', DATEADD(MINUTE, -35, DATEADD(HOUR, -22, DATEADD(DAY,-39,GETDATE())))),
(1, 'APPROVE_EVENT', 'Event', 3, N'Approved event: Sơn Tùng M-TP Sky Tour Encore', '192.168.1.100', DATEADD(MINUTE, -22, DATEADD(HOUR, -14, DATEADD(DAY,-38,GETDATE())))),
(1, 'REJECT_EVENT', 'Event', 7, N'Rejected event: Karaoke Đại Hội Test — Nội dung không đủ thông tin', '192.168.1.100', DATEADD(MINUTE, -28, DATEADD(HOUR, -23, DATEADD(DAY,-35,GETDATE())))),
(1, 'REJECT_EVENT', 'Event', 22, N'Rejected event: Triển lãm Ảnh Không Phép — Chưa có giấy phép', '192.168.1.100', DATEADD(MINUTE, -42, DATEADD(HOUR, -15, DATEADD(DAY,-34,GETDATE())))),
(1, 'REJECT_EVENT', 'Event', 25, N'Rejected event: Crypto Investment Night — Thiếu thông tin pháp lý', '192.168.1.100', DATEADD(MINUTE, -23, DATEADD(HOUR, -16, DATEADD(DAY,-33,GETDATE())))),
(1, 'APPROVE_EVENT', 'Event', 26, N'Approved event: Vietnam AI Summit 2026 (featured)', '192.168.1.100', DATEADD(MINUTE, -18, DATEADD(HOUR, -1, DATEADD(DAY,-30,GETDATE())))),
(1, 'FEATURE_EVENT', 'Event', 26, N'Marked event as featured', '192.168.1.100', DATEADD(MINUTE, -43, DATEADD(HOUR, -12, DATEADD(DAY,-30,GETDATE())))),
(1, 'PIN_EVENT', 'Event', 26, N'Pinned event: Vietnam AI Summit 2026', '192.168.1.100', DATEADD(MINUTE, -45, DATEADD(HOUR, -12, DATEADD(DAY,-30,GETDATE())))),
(1, 'LOCK_USER', 'User', 22, N'Locked user: Nguyễn Bị Khóa (banned.user@test.com) — vi phạm chính sách', '192.168.1.100', DATEADD(MINUTE, -59, DATEADD(HOUR, -3, DATEADD(DAY,-28,GETDATE())))),
(1, 'DELETE_USER', 'User', 23, N'Soft-deleted user: Trần Đã Xóa (deleted.user@test.com)', '192.168.1.100', DATEADD(MINUTE, -37, DATEADD(HOUR, -2, DATEADD(DAY,-27,GETDATE())))),
(1, 'CHANGE_ROLE', 'User', 4, N'Changed role: organizer@ticketbox.vn → organizer (verified organizer)', '192.168.1.100', DATEADD(MINUTE, -1, DATEADD(HOUR, -12, DATEADD(DAY,-45,GETDATE())))),
(2, 'RESOLVE_TICKET', 'SupportTicket', 1, N'Resolved support ticket SPT-001: Payment email issue', '10.0.0.50', DATEADD(MINUTE, -20, DATEADD(HOUR, -9, DATEADD(DAY,-29,GETDATE())))),
(2, 'PROCESS_REFUND', 'Order', 26, N'Processed refund for ORD-2026-0026 (80% = 1,600,000đ)', '10.0.0.50', DATEADD(MINUTE, -50, DATEADD(HOUR, -19, DATEADD(DAY,-18,GETDATE())))),
(2, 'RESOLVE_TICKET', 'SupportTicket', 6, N'Resolved support ticket SPT-006: Refund completed', '10.0.0.50', DATEADD(MINUTE, -31, DATEADD(HOUR, -5, DATEADD(DAY,-18,GETDATE())))),
(3, 'ASSIGN_TICKET',  'SupportTicket', 7, N'Self-assigned support ticket SPT-007', '10.0.0.51', DATEADD(MINUTE, -6, DATEADD(HOUR, -13, DATEADD(DAY,-2,GETDATE())))),
(1, 'CREATE_VOUCHER', 'Voucher', 9, N'Created system voucher SYSLAUNCH50 (50K fixed)', '192.168.1.100', DATEADD(MINUTE, -22, DATEADD(HOUR, -6, DATEADD(DAY,-50,GETDATE())))),
(1, 'CREATE_VOUCHER', 'Voucher', 10, N'Created system voucher SYSVIP10 (10% up to 500K)', '192.168.1.100', DATEADD(MINUTE, -9, DATEADD(HOUR, -12, DATEADD(DAY,-48,GETDATE())))),
(1, 'CANCEL_ORDER', 'Order', 48, N'Admin cancelled ORD-2026-0048 — customer request', '192.168.1.100', DATEADD(MINUTE, -13, DATEADD(HOUR, -3, DATEADD(DAY,-7,GETDATE())))),
(1, 'UPDATE_SETTINGS', 'SiteSettings', NULL, N'Updated chat_enabled=true, require_event_approval=true', '192.168.1.100', DATEADD(MINUTE, -29, DATEADD(HOUR, -19, DATEADD(DAY,-55,GETDATE())))),
(1, 'SYSTEM_STARTUP', NULL, NULL, N'System initialized — all services online', '127.0.0.1', DATEADD(MINUTE, -2, DATEADD(HOUR, -10, DATEADD(DAY,-60,GETDATE())))),
(1, 'APPROVE_EVENT', 'Event', 8, N'Approved event: Vietnam Marathon Đà Nẵng 2026', '192.168.1.100', DATEADD(MINUTE, -36, DATEADD(HOUR, -21, DATEADD(DAY,-25,GETDATE())))),
(1, 'APPROVE_EVENT', 'Event', 17, N'Approved event: Lễ hội Ẩm thực Đường phố Sài Gòn 2026', '192.168.1.100', DATEADD(MINUTE, -54, DATEADD(HOUR, -23, DATEADD(DAY,-22,GETDATE())))),
(1, 'APPROVE_EVENT', 'Event', 13, N'Approved event: Workshop UI/UX Design', '192.168.1.100', DATEADD(MINUTE, -4, DATEADD(HOUR, -12, DATEADD(DAY,-20,GETDATE())))),
(2, 'CLOSE_TICKET',  'SupportTicket', 2, N'Closed support ticket SPT-002', '10.0.0.50', DATEADD(MINUTE, -37, DATEADD(HOUR, -15, DATEADD(DAY,-18,GETDATE())))),
(1, 'APPROVE_EVENT', 'Event', 27, N'Approved event: Hackathon Build for Vietnam 2026', '192.168.1.100', DATEADD(MINUTE, -19, DATEADD(HOUR, -15, DATEADD(DAY,-15,GETDATE())))),
(2, 'ASSIGN_CHAT',   'ChatSession', 3, N'Assigned chat session #3 to self', '10.0.0.50', DATEADD(HOUR,-2,GETDATE())),
(1, 'VIEW_DASHBOARD', NULL, NULL, N'Admin viewed dashboard overview', '192.168.1.100', DATEADD(HOUR,-1,GETDATE())),
(1, 'EXPORT_REPORT', 'Order', NULL, N'Exported settlement report (all orders)', '192.168.1.100', DATEADD(MINUTE,-30,GETDATE())),
(1, 'VIEW_ACTIVITY_LOG', NULL, NULL, N'Admin viewed activity log page', '192.168.1.100', DATEADD(MINUTE,-10,GETDATE()));
GO

PRINT '=== 30 activity log entries seeded ===';
GO

-- =============================================
-- =============================================
INSERT INTO Notifications (user_id, type, title, message, link, is_read, created_at) VALUES
(1, 'new_event',    N'Sự kiện mới chờ duyệt',        N'EDM Neon Jungle Festival 2026 đang chờ admin duyệt.', '/admin/events/5', 1, DATEADD(MINUTE, -44, DATEADD(HOUR, -13, DATEADD(DAY,-20,GETDATE())))),
(1, 'new_event',    N'Sự kiện mới chờ duyệt',        N'Giải Bơi Lội TP.HCM Mùa Hè 2026 đang chờ duyệt.',     '/admin/events/11', 0, DATEADD(MINUTE, -6, DATEADD(HOUR, -22, DATEADD(DAY,-10,GETDATE())))),
(1, 'new_event',    N'Sự kiện mới chờ duyệt',        N'Hội nghị Du lịch & Hospitality 2026 chờ duyệt.',       '/admin/events/24', 0, DATEADD(MINUTE, -16, DATEADD(HOUR, -4, DATEADD(DAY,-8,GETDATE())))),
(1, 'new_event',    N'Sự kiện mới chờ duyệt',        N'Tech Career Fair 2026 đang chờ admin duyệt.',           '/admin/events/28', 0, DATEADD(MINUTE, -19, DATEADD(HOUR, -8, DATEADD(DAY,-5,GETDATE())))),
(1, 'support',      N'Support ticket cấp bách',       N'SPT-010: Yêu cầu hoàn tiền urgent từ Lý Minh Châu.',  '/admin/support/10', 0, DATEADD(MINUTE, -2, DATEADD(HOUR, -19, DATEADD(DAY,-1,GETDATE())))),
(1, 'support',      N'Support ticket mới',            N'SPT-008: Thiếu vé — Bùi Quốc Bảo cần kiểm tra.',      '/admin/support/8', 0, DATEADD(MINUTE, -50, DATEADD(HOUR, -10, DATEADD(DAY,-1,GETDATE())))),
(1, 'system',       N'Hệ thống khởi động thành công', N'Tất cả services đã online. Version 2026-03-18.',       '/admin/dashboard', 1, DATEADD(MINUTE, -53, DATEADD(HOUR, -4, DATEADD(DAY,-60,GETDATE())))),
(1, 'order',        N'Đơn hàng bị hủy',              N'ORD-2026-0048 (Lê Hoàng Cường) đã bị hủy.',           '/admin/orders/48', 1, DATEADD(MINUTE, -53, DATEADD(HOUR, -15, DATEADD(DAY,-7,GETDATE())))),
(1, 'refund',       N'Hoàn tiền xử lý',              N'ORD-2026-0049 (Lý Minh Châu) đã hoàn tiền thành công.','/admin/orders/49', 1, DATEADD(MINUTE, -39, DATEADD(HOUR, -9, DATEADD(DAY,-8,GETDATE())))),
(2, 'support',      N'Ticket mới được gán',           N'SPT-001: Thanh toán thành công nhưng chưa nhận vé.',   '/admin/support/1', 1, DATEADD(MINUTE, -40, DATEADD(HOUR, -6, DATEADD(DAY,-29,GETDATE())))),
(2, 'support',      N'Ticket mới được gán',           N'SPT-003: Yêu cầu hủy đơn ORD-2026-0013.',             '/admin/support/3', 1, DATEADD(MINUTE, -38, DATEADD(HOUR, -4, DATEADD(DAY,-17,GETDATE())))),
(2, 'support',      N'Ticket mới được gán',           N'SPT-006: Yêu cầu hoàn tiền vé Sơn Tùng.',             '/admin/support/6', 1, DATEADD(MINUTE, -47, DATEADD(HOUR, -19, DATEADD(DAY,-19,GETDATE())))),
(2, 'chat',         N'Chat mới cần hỗ trợ',           N'Phạm Minh Đức đang hỏi về QR code vé Hackathon.',     '/admin/chat', 0, DATEADD(HOUR,-2,GETDATE())),
(2, 'chat',         N'Chat mới cần hỗ trợ',           N'Phan Ngọc Diễm hỏi về liveshow Mỹ Tâm.',              '/admin/chat', 0, DATEADD(MINUTE,-45,GETDATE())),
(3, 'support',      N'Ticket mới được gán',           N'SPT-007: Email chưa xác minh — cần kiểm tra.',        '/admin/support/7', 0, DATEADD(MINUTE, -44, DATEADD(HOUR, -5, DATEADD(DAY,-2,GETDATE())))),
(4, 'event_approved', N'Sự kiện được duyệt',          N'Hà Anh Tuấn Concert 2026 đã được admin duyệt!',       '/organizer/events/1', 1, DATEADD(MINUTE, -15, DATEADD(HOUR, -16, DATEADD(DAY,-40,GETDATE())))),
(4, 'event_approved', N'Sự kiện được duyệt',          N'Mỹ Tâm Liveshow My Soul 1981 đã được duyệt!',         '/organizer/events/2', 1, DATEADD(MINUTE, -18, DATEADD(HOUR, -5, DATEADD(DAY,-39,GETDATE())))),
(4, 'new_order',    N'Đơn hàng mới',                  N'ORD-2026-0001: 7,500,000đ cho Hà Anh Tuấn Concert.',  '/organizer/events/1/orders', 1, DATEADD(MINUTE, -36, DATEADD(HOUR, -18, DATEADD(DAY,-30,GETDATE())))),
(4, 'event_rejected', N'Sự kiện bị từ chối',          N'Karaoke Đại Hội Test bị từ chối. Lý do: thiếu thông tin.', '/organizer/events/7', 1, DATEADD(MINUTE, -13, DATEADD(HOUR, -5, DATEADD(DAY,-35,GETDATE())))),
(6, 'event_approved', N'Sự kiện được duyệt',          N'Vietnam AI Summit 2026 đã được duyệt + featured!',    '/organizer/events/26', 1, DATEADD(MINUTE, -50, DATEADD(HOUR, -17, DATEADD(DAY,-30,GETDATE())))),
(6, 'new_order',    N'Đơn hàng mới',                  N'ORD-2026-0043: 1,450,000đ cho AI Summit.',             '/organizer/events/26/orders', 0, DATEADD(MINUTE, -50, DATEADD(HOUR, -1, DATEADD(DAY,-4,GETDATE())))),
(7, 'event_approved', N'Sự kiện được duyệt',          N'Vietnam Marathon Đà Nẵng 2026 đã được duyệt!',        '/organizer/events/8', 1, DATEADD(MINUTE, -38, DATEADD(HOUR, -13, DATEADD(DAY,-25,GETDATE())))),
(7, 'new_order',    N'Đơn hàng mới',                  N'ORD-2026-0042: 1,100,000đ cho Marathon Full 42K.',     '/organizer/events/8/orders', 0, DATEADD(MINUTE, -7, DATEADD(HOUR, -19, DATEADD(DAY,-3,GETDATE())))),
(5, 'event_approved', N'Sự kiện được duyệt',          N'Lễ hội Ẩm thực Đường phố Sài Gòn 2026 đã được duyệt!', '/organizer/events/17', 1, DATEADD(MINUTE, -29, DATEADD(HOUR, -19, DATEADD(DAY,-22,GETDATE())))),
(5, 'support_routed', N'Support ticket chuyển đến bạn', N'SPT-002: Khách hỏi dress code liveshow — chuyển cho BTC.', '/organizer/support/2', 1, DATEADD(MINUTE, -1, DATEADD(HOUR, -7, DATEADD(DAY,-19,GETDATE()))));
GO

PRINT '=== 25 notifications seeded (9 admin, 5 support, 11 organizer) ===';
GO

-- =============================================
-- =============================================

UPDATE Orders SET
    voucher_scope = 'NONE', voucher_fund_source = 'NONE',
    event_discount_amount = 0, system_discount_amount = 0,
    platform_fee_amount = 0, organizer_payout_amount = total_amount
WHERE order_id <= 35 AND discount_amount = 0;

UPDATE Orders SET
    voucher_id = 2, voucher_scope = 'EVENT', voucher_fund_source = 'ORGANIZER',
    event_discount_amount = 90000, system_discount_amount = 0,
    platform_fee_amount = 0, organizer_payout_amount = 600000 - 90000
WHERE order_id = 11;

UPDATE Orders SET
    voucher_id = 2, voucher_scope = 'EVENT', voucher_fund_source = 'ORGANIZER',
    event_discount_amount = 360000, system_discount_amount = 0,
    platform_fee_amount = 0, organizer_payout_amount = 2400000 - 360000
WHERE order_id = 24;

UPDATE Orders SET
    voucher_id = 3, voucher_scope = 'EVENT', voucher_fund_source = 'ORGANIZER',
    event_discount_amount = 50000, system_discount_amount = 0,
    platform_fee_amount = 0, organizer_payout_amount = 1500000 - 50000
WHERE order_id = 25;
GO

PRINT '=== Settlement fields backfilled for O1-O35 ===';
GO

DECLARE @now2 DATETIME = GETDATE();

-- =============================================
-- =============================================

INSERT INTO Orders (order_code, user_id, event_id, total_amount, discount_amount, final_amount, status, payment_method, payment_date, buyer_name, buyer_email, buyer_phone,
    voucher_id, voucher_scope, voucher_fund_source, event_discount_amount, system_discount_amount, platform_fee_amount, organizer_payout_amount, created_at)
VALUES ('ORD-2026-0036', 9, 1, 1500000, 150000, 1350000, 'paid', 'seepay', DATEADD(DAY,-5,@now2), N'Nguyễn Văn An', 'customer@ticketbox.vn', '0912345678',
    10, 'SYSTEM', 'SYSTEM', 0, 150000, 0, 1500000, DATEADD(DAY,-5,@now2));
INSERT INTO OrderItems (order_id, ticket_type_id, quantity, unit_price, subtotal) VALUES (36, 3, 1, 1500000, 1500000);

INSERT INTO Orders (order_code, user_id, event_id, total_amount, discount_amount, final_amount, status, payment_method, payment_date, buyer_name, buyer_email, buyer_phone,
    voucher_id, voucher_scope, voucher_fund_source, event_discount_amount, system_discount_amount, platform_fee_amount, organizer_payout_amount, created_at)
VALUES ('ORD-2026-0037', 10, 3, 2000000, 50000, 1950000, 'paid', 'seepay', DATEADD(DAY,-4,@now2), N'Trần Thị Bình', 'binh.tran@gmail.com', '0987654321',
    9, 'SYSTEM', 'SYSTEM', 0, 50000, 0, 2000000, DATEADD(DAY,-4,@now2));
INSERT INTO OrderItems (order_id, ticket_type_id, quantity, unit_price, subtotal) VALUES (37, 10, 1, 2000000, 2000000);

INSERT INTO Orders (order_code, user_id, event_id, total_amount, discount_amount, final_amount, status, payment_method, payment_date, buyer_name, buyer_email, buyer_phone,
    voucher_id, voucher_scope, voucher_fund_source, event_discount_amount, system_discount_amount, platform_fee_amount, organizer_payout_amount, created_at)
VALUES ('ORD-2026-0038', 15, 17, 250000, 30000, 220000, 'paid', 'seepay', DATEADD(DAY,-3,@now2), N'Ngô Thanh Tùng', 'tung.ngo@gmail.com', '0923456789',
    12, 'SYSTEM', 'SYSTEM', 0, 30000, 0, 250000, DATEADD(DAY,-3,@now2));
INSERT INTO OrderItems (order_id, ticket_type_id, quantity, unit_price, subtotal) VALUES (38, 41, 1, 250000, 250000);

INSERT INTO Orders (order_code, user_id, event_id, total_amount, discount_amount, final_amount, status, payment_method, payment_date, buyer_name, buyer_email, buyer_phone,
    voucher_id, voucher_scope, voucher_fund_source, event_discount_amount, system_discount_amount, platform_fee_amount, organizer_payout_amount, created_at)
VALUES ('ORD-2026-0039', 19, 8, 800000, 200000, 600000, 'paid', 'seepay', DATEADD(DAY,-2,@now2), N'Trịnh Hoàng Long', 'long.trinh@gmail.com', '0939876543',
    11, 'SYSTEM', 'SYSTEM', 0, 200000, 0, 800000, DATEADD(DAY,-2,@now2));
INSERT INTO OrderItems (order_id, ticket_type_id, quantity, unit_price, subtotal) VALUES (39, 23, 1, 800000, 800000);

INSERT INTO Orders (order_code, user_id, event_id, total_amount, discount_amount, final_amount, status, payment_method, payment_date, buyer_name, buyer_email, buyer_phone,
    voucher_id, voucher_scope, voucher_fund_source, event_discount_amount, system_discount_amount, platform_fee_amount, organizer_payout_amount, created_at)
VALUES ('ORD-2026-0040', 20, 26, 3000000, 300000, 2700000, 'paid', 'seepay', DATEADD(DAY,-2,@now2), N'Phan Ngọc Diễm', 'diem.phan@gmail.com', '0967890123',
    10, 'SYSTEM', 'SYSTEM', 0, 300000, 0, 3000000, DATEADD(DAY,-2,@now2));
INSERT INTO OrderItems (order_id, ticket_type_id, quantity, unit_price, subtotal) VALUES (40, 53, 1, 3000000, 3000000);

INSERT INTO Orders (order_code, user_id, event_id, total_amount, discount_amount, final_amount, status, payment_method, payment_date, buyer_name, buyer_email, buyer_phone,
    voucher_id, voucher_scope, voucher_fund_source, event_discount_amount, system_discount_amount, platform_fee_amount, organizer_payout_amount, created_at)
VALUES ('ORD-2026-0041', 25, 2, 2000000, 50000, 1950000, 'paid', 'seepay', DATEADD(DAY,-1,@now2), N'Nguyễn Hoàng Phúc', 'fullprofile@gmail.com', '0918765432',
    9, 'SYSTEM', 'SYSTEM', 0, 50000, 0, 2000000, DATEADD(DAY,-1,@now2));
INSERT INTO OrderItems (order_id, ticket_type_id, quantity, unit_price, subtotal) VALUES (41, 6, 1, 2000000, 2000000);

-- =============================================
-- =============================================

INSERT INTO Orders (order_code, user_id, event_id, total_amount, discount_amount, final_amount, status, payment_method, payment_date, buyer_name, buyer_email, buyer_phone,
    voucher_id, voucher_scope, voucher_fund_source, event_discount_amount, system_discount_amount, platform_fee_amount, organizer_payout_amount, created_at)
VALUES ('ORD-2026-0042', 21, 8, 1200000, 100000, 1100000, 'paid', 'seepay', DATEADD(DAY,-3,@now2), N'Đặng Trung Kiên', 'kien.dang@gmail.com', '0941234567',
    4, 'EVENT', 'ORGANIZER', 100000, 0, 0, 1100000, DATEADD(DAY,-3,@now2));
INSERT INTO OrderItems (order_id, ticket_type_id, quantity, unit_price, subtotal) VALUES (42, 22, 1, 1200000, 1200000);

INSERT INTO Orders (order_code, user_id, event_id, total_amount, discount_amount, final_amount, status, payment_method, payment_date, buyer_name, buyer_email, buyer_phone,
    voucher_id, voucher_scope, voucher_fund_source, event_discount_amount, system_discount_amount, platform_fee_amount, organizer_payout_amount, created_at)
VALUES ('ORD-2026-0043', 14, 26, 1500000, 50000, 1450000, 'paid', 'seepay', DATEADD(DAY,-4,@now2), N'Đỗ Quang Khải', 'khai.do@gmail.com', '0934567890',
    3, 'EVENT', 'ORGANIZER', 50000, 0, 0, 1450000, DATEADD(DAY,-4,@now2));
INSERT INTO OrderItems (order_id, ticket_type_id, quantity, unit_price, subtotal) VALUES (43, 54, 1, 1500000, 1500000);

INSERT INTO Orders (order_code, user_id, event_id, total_amount, discount_amount, final_amount, status, payment_method, payment_date, buyer_name, buyer_email, buyer_phone,
    voucher_id, voucher_scope, voucher_fund_source, event_discount_amount, system_discount_amount, platform_fee_amount, organizer_payout_amount, created_at)
VALUES ('ORD-2026-0044', 17, 17, 160000, 32000, 128000, 'paid', 'seepay', DATEADD(DAY,-2,@now2), N'Bùi Quốc Bảo', 'bao.bui@gmail.com', '0913579246',
    5, 'EVENT', 'ORGANIZER', 32000, 0, 0, 128000, DATEADD(DAY,-2,@now2));
INSERT INTO OrderItems (order_id, ticket_type_id, quantity, unit_price, subtotal) VALUES (44, 40, 2, 80000, 160000);

INSERT INTO Orders (order_code, user_id, event_id, total_amount, discount_amount, final_amount, status, payment_method, payment_date, buyer_name, buyer_email, buyer_phone,
    voucher_id, voucher_scope, voucher_fund_source, event_discount_amount, system_discount_amount, platform_fee_amount, organizer_payout_amount, created_at)
VALUES ('ORD-2026-0045', 13, 1, 1600000, 160000, 1440000, 'paid', 'seepay', DATEADD(DAY,-3,@now2), N'Vũ Thị Hà', 'ha.vu@gmail.com', '0945678901',
    1, 'EVENT', 'ORGANIZER', 160000, 0, 0, 1440000, DATEADD(DAY,-3,@now2));
INSERT INTO OrderItems (order_id, ticket_type_id, quantity, unit_price, subtotal) VALUES (45, 4, 2, 800000, 1600000);

-- =============================================
-- =============================================

INSERT INTO Orders (order_code, user_id, event_id, total_amount, discount_amount, final_amount, status, payment_method, payment_date, buyer_name, buyer_email, buyer_phone,
    voucher_id, voucher_scope, voucher_fund_source, event_discount_amount, system_discount_amount, platform_fee_amount, organizer_payout_amount, created_at)
VALUES ('ORD-2026-0046', 19, 6, 1500000, 0, 1500000, 'paid', 'seepay', DATEADD(DAY,-5,@now2), N'Trịnh Hoàng Long', 'long.trinh@gmail.com', '0939876543',
    NULL, 'NONE', 'NONE', 0, 0, 0, 1500000, DATEADD(DAY,-5,@now2));
INSERT INTO OrderItems (order_id, ticket_type_id, quantity, unit_price, subtotal) VALUES (46, 20, 3, 500000, 1500000);

INSERT INTO Orders (order_code, user_id, event_id, total_amount, discount_amount, final_amount, status, payment_method, payment_date, buyer_name, buyer_email, buyer_phone,
    voucher_id, voucher_scope, voucher_fund_source, event_discount_amount, system_discount_amount, platform_fee_amount, organizer_payout_amount, created_at)
VALUES ('ORD-2026-0047', 16, 20, 100000, 0, 100000, 'paid', 'seepay', DATEADD(DAY,-6,@now2), N'Hoàng Thị Yến', 'yen.hoang@yahoo.com', '0956789012',
    NULL, 'NONE', 'NONE', 0, 0, 0, 100000, DATEADD(DAY,-6,@now2));
INSERT INTO OrderItems (order_id, ticket_type_id, quantity, unit_price, subtotal) VALUES (47, 43, 1, 100000, 100000);

-- =============================================
-- =============================================

INSERT INTO Orders (order_code, user_id, event_id, total_amount, discount_amount, final_amount, status, payment_method, buyer_name, buyer_email, buyer_phone,
    voucher_id, voucher_scope, voucher_fund_source, event_discount_amount, system_discount_amount, platform_fee_amount, organizer_payout_amount, created_at)
VALUES ('ORD-2026-0048', 11, 1, 3000000, 50000, 2950000, 'cancelled', 'seepay', N'Lê Hoàng Cường', 'cuong.le@yahoo.com', '0976543210',
    9, 'SYSTEM', 'SYSTEM', 0, 50000, 0, 3000000, DATEADD(DAY,-7,@now2));
INSERT INTO OrderItems (order_id, ticket_type_id, quantity, unit_price, subtotal) VALUES (48, 2, 1, 3000000, 3000000);

INSERT INTO Orders (order_code, user_id, event_id, total_amount, discount_amount, final_amount, status, payment_method, payment_date, buyer_name, buyer_email, buyer_phone,
    voucher_id, voucher_scope, voucher_fund_source, event_discount_amount, system_discount_amount, platform_fee_amount, organizer_payout_amount, created_at)
VALUES ('ORD-2026-0049', 18, 26, 500000, 50000, 450000, 'refunded', 'seepay', DATEADD(DAY,-8,@now2), N'Lý Minh Châu', 'chau.ly@gmail.com', '0978901234',
    10, 'SYSTEM', 'SYSTEM', 0, 50000, 0, 500000, DATEADD(DAY,-8,@now2));
INSERT INTO OrderItems (order_id, ticket_type_id, quantity, unit_price, subtotal) VALUES (49, 55, 1, 500000, 500000);

INSERT INTO Orders (order_code, user_id, event_id, total_amount, discount_amount, final_amount, status, payment_method, payment_expires_at, buyer_name, buyer_email, buyer_phone,
    voucher_id, voucher_scope, voucher_fund_source, event_discount_amount, system_discount_amount, platform_fee_amount, organizer_payout_amount, created_at)
VALUES ('ORD-2026-0050', 12, 13, 500000, 30000, 470000, 'pending', 'seepay', DATEADD(HOUR,2,@now2), N'Phạm Minh Đức', 'duc.pham@outlook.com', '0965432109',
    12, 'SYSTEM', 'SYSTEM', 0, 30000, 0, 500000, @now2);
INSERT INTO OrderItems (order_id, ticket_type_id, quantity, unit_price, subtotal) VALUES (50, 33, 1, 500000, 500000);
GO

PRINT '=== 15 new orders (O36-O50) with settlement fields seeded ===';
PRINT '  SYSTEM voucher: O36-O41, O48(cancelled), O49(refunded), O50(pending)';
PRINT '  EVENT voucher: O42-O45';
PRINT '  No voucher: O46-O47';
GO

INSERT INTO Tickets (ticket_code, order_item_id, attendee_name, attendee_email, qr_code, is_checked_in) VALUES
('TIX-HAT-006', 37, N'Nguyễn Văn An',    'customer@ticketbox.vn', 'TIX-HAT-006|E1|CAT1|20260420', 0),
('TIX-STU-003', 38, N'Trần Thị Bình',    'binh.tran@gmail.com', 'TIX-STU-003|E3|GOLD|20260615', 0),
('TIX-FDF-005', 39, N'Ngô Thanh Tùng',   'tung.ngo@gmail.com', 'TIX-FDF-005|E17|VIP|20260501', 0),
('TIX-MRT-003', 40, N'Trịnh Hoàng Long', 'long.trinh@gmail.com', 'TIX-MRT-003|E8|HALF|20260503', 0),
('TIX-AIS-004', 41, N'Phan Ngọc Diễm',   'diem.phan@gmail.com', 'TIX-AIS-004|E26|VIP|20260620', 0),
('TIX-MTM-004', 42, N'Nguyễn Hoàng Phúc', 'fullprofile@gmail.com', 'TIX-MTM-004|E2|A|20260510', 0),
('TIX-MRT-004', 43, N'Đặng Trung Kiên', 'kien.dang@gmail.com', 'TIX-MRT-004|E8|FULL|20260503', 0),
('TIX-AIS-005', 44, N'Đỗ Quang Khải',   'khai.do@gmail.com', 'TIX-AIS-005|E26|STD|20260620', 0),
('TIX-FDF-006', 45, N'Bùi Quốc Bảo',    'bao.bui@gmail.com', 'TIX-FDF-006|E17|WE|20260503', 0),
('TIX-FDF-007', 45, N'Nguyễn Thùy Linh', 'linh.nguyen@gmail.com', 'TIX-FDF-007|E17|WE|20260503', 0),
('TIX-HAT-007', 46, N'Vũ Thị Hà',       'ha.vu@gmail.com', 'TIX-HAT-007|E1|CAT2|20260420', 0),
('TIX-HAT-008', 46, N'Vũ Minh Tuấn',    'tuan.vu@gmail.com', 'TIX-HAT-008|E1|CAT2|20260420', 0),
('TIX-IND-005', 47, N'Trịnh Hoàng Long', 'long.trinh@gmail.com', 'TIX-IND-005|E6|GA|20260412', 0),
('TIX-IND-006', 47, N'Trần Minh Châu',   'chau.friend@gmail.com', 'TIX-IND-006|E6|GA|20260412', 0),
('TIX-IND-007', 47, N'Nguyễn Thùy Dung', 'dung.friend@gmail.com', 'TIX-IND-007|E6|GA|20260412', 0),
('TIX-ART-004', 48, N'Hoàng Thị Yến',   'yen.hoang@yahoo.com', 'TIX-ART-004|E20|GA|20260415', 0);
GO

PRINT '=== 17 new tickets seeded for O36-O47 ===';
GO

INSERT INTO PaymentTransactions (order_id, payment_method, seepay_transaction_id, amount, status, completed_at) VALUES
(36, 'seepay', 'SP-202603-036', 1350000, 'completed', DATEADD(MINUTE, -11, DATEADD(HOUR, -9, DATEADD(DAY,-5,GETDATE())))),
(37, 'seepay', 'SP-202603-037', 1950000, 'completed', DATEADD(MINUTE, -5, DATEADD(HOUR, -5, DATEADD(DAY,-4,GETDATE())))),
(38, 'seepay', 'SP-202603-038', 220000,  'completed', DATEADD(MINUTE, -5, DATEADD(HOUR, -20, DATEADD(DAY,-3,GETDATE())))),
(39, 'seepay', 'SP-202603-039', 600000,  'completed', DATEADD(MINUTE, -43, DATEADD(HOUR, -18, DATEADD(DAY,-2,GETDATE())))),
(40, 'seepay', 'SP-202603-040', 2700000, 'completed', DATEADD(MINUTE, -39, DATEADD(HOUR, -13, DATEADD(DAY,-2,GETDATE())))),
(41, 'seepay', 'SP-202603-041', 1950000, 'completed', DATEADD(MINUTE, -27, DATEADD(HOUR, -3, DATEADD(DAY,-1,GETDATE())))),
(42, 'seepay', 'SP-202603-042', 1100000, 'completed', DATEADD(MINUTE, -44, DATEADD(HOUR, -18, DATEADD(DAY,-3,GETDATE())))),
(43, 'seepay', 'SP-202603-043', 1450000, 'completed', DATEADD(MINUTE, -50, DATEADD(HOUR, -22, DATEADD(DAY,-4,GETDATE())))),
(44, 'seepay', 'SP-202603-044', 128000,  'completed', DATEADD(MINUTE, -1, DATEADD(HOUR, -18, DATEADD(DAY,-2,GETDATE())))),
(45, 'seepay', 'SP-202603-045', 1440000, 'completed', DATEADD(MINUTE, -24, DATEADD(HOUR, -16, DATEADD(DAY,-3,GETDATE())))),
(46, 'seepay', 'SP-202603-046', 1500000, 'completed', DATEADD(MINUTE, -22, DATEADD(HOUR, -4, DATEADD(DAY,-5,GETDATE())))),
(47, 'seepay', 'SP-202603-047', 100000,  'completed', DATEADD(MINUTE, -55, DATEADD(HOUR, -13, DATEADD(DAY,-6,GETDATE())))),
(48, 'seepay', NULL,            2950000, 'cancelled', NULL),
(49, 'seepay', 'SP-202603-049', 450000,  'refunded',  DATEADD(MINUTE, -1, DATEADD(HOUR, -14, DATEADD(DAY,-8,GETDATE())))),
(50, 'seepay', NULL,            470000,  'pending',   NULL);
GO

INSERT INTO VoucherUsages (voucher_id, order_id, discount_applied, used_at) VALUES
(10, 36, 150000, DATEADD(MINUTE, -26, DATEADD(HOUR, -19, DATEADD(DAY,-5,GETDATE())))),  -- SYSVIP10 on O36
(9,  37, 50000,  DATEADD(MINUTE, -15, DATEADD(HOUR, -3, DATEADD(DAY,-4,GETDATE())))),  -- SYSLAUNCH50 on O37
(12, 38, 30000,  DATEADD(MINUTE, -9, DATEADD(HOUR, -14, DATEADD(DAY,-3,GETDATE())))),  -- SYSWELCOME30 on O38
(11, 39, 200000, DATEADD(MINUTE, -25, DATEADD(HOUR, -4, DATEADD(DAY,-2,GETDATE())))),  -- SYSFLASH200K on O39
(10, 40, 300000, DATEADD(MINUTE, -31, DATEADD(HOUR, -20, DATEADD(DAY,-2,GETDATE())))),  -- SYSVIP10 on O40
(9,  41, 50000,  DATEADD(MINUTE, -3, DATEADD(HOUR, -11, DATEADD(DAY,-1,GETDATE())))),  -- SYSLAUNCH50 on O41
(4,  42, 100000, DATEADD(MINUTE, -23, DATEADD(HOUR, -5, DATEADD(DAY,-3,GETDATE())))),  -- RUN2026 on O42
(3,  43, 50000,  DATEADD(MINUTE, -44, DATEADD(HOUR, -10, DATEADD(DAY,-4,GETDATE())))),  -- AITECH50K on O43
(5,  44, 32000,  DATEADD(MINUTE, -26, DATEADD(HOUR, -16, DATEADD(DAY,-2,GETDATE())))),  -- FOODIE20 on O44
(1,  45, 160000, DATEADD(MINUTE, -22, DATEADD(HOUR, -23, DATEADD(DAY,-3,GETDATE())))),  -- HAT2026VIP on O45
(9,  48, 50000,  DATEADD(MINUTE, -26, DATEADD(HOUR, -5, DATEADD(DAY,-7,GETDATE())))),  -- SYSLAUNCH50 on O48 (cancelled)
(10, 49, 50000,  DATEADD(MINUTE, -13, DATEADD(HOUR, -21, DATEADD(DAY,-8,GETDATE())))),  -- SYSVIP10 on O49 (refunded)
(12, 50, 30000,  GETDATE());                   -- SYSWELCOME30 on O50 (pending)
GO

PRINT '=== 13 new voucher usages seeded (new orders) ===';
GO

-- =============================================
-- =============================================
INSERT INTO SiteSettings (setting_key, setting_value) VALUES
('site_tagline',        N'Nền tảng bán vé sự kiện hàng đầu Việt Nam'),
('contact_email',       'support@ticketbox.vn'),
('contact_phone',       '1900-636-123'),
('contact_address',     N'Tầng 8, Tòa nhà Bitexco, 45 Điện Biên Phủ, Quận 1, TP.HCM'),
('platform_fee_percent','5'),
('max_tickets_per_order','10'),
('order_timeout_minutes','15'),
('currency',            'VND'),
('maintenance_mode',    'false'),
('payment_gateway',     'seepay'),
('seepay_api_url',      'https://api.seepay.vn/v2'),
('seepay_bank_code',    'MB'),
('seepay_account_no',   '0345678901'),
('refund_policy_days',  '7'),
('default_language',    'vi'),
('smtp_host',           'smtp.gmail.com'),
('smtp_port',           '587'),
('google_analytics_id', 'G-XXXXXXXXXX'),
('social_facebook',     'https://facebook.com/ticketbox.vn'),
('social_instagram',    'https://instagram.com/ticketbox.vn');
GO

PRINT '=== SiteSettings seeded (additional 20 settings) ===';
GO

-- =============================================
-- =============================================
INSERT INTO ActivityLog (user_id, action, entity_type, entity_id, details, ip_address, created_at) VALUES
(1, 'login',            'user',    1,  N'Admin đăng nhập',                    '192.168.1.100', DATEADD(MINUTE, -30, DATEADD(HOUR, -5, DATEADD(DAY,-30,GETDATE())))),
(1, 'approve_event',    'event',   1,  N'Phê duyệt sự kiện: Đêm nhạc Hà Anh Tuấn',  '192.168.1.100', DATEADD(MINUTE, -3, DATEADD(HOUR, -21, DATEADD(DAY,-28,GETDATE())))),
(1, 'approve_event',    'event',   2,  N'Phê duyệt sự kiện: Rock Storm 2026', '192.168.1.100', DATEADD(MINUTE, -15, DATEADD(HOUR, -23, DATEADD(DAY,-27,GETDATE())))),
(1, 'approve_event',    'event',   3,  N'Phê duyệt sự kiện: Food Festival',   '192.168.1.100', DATEADD(MINUTE, -10, DATEADD(HOUR, -18, DATEADD(DAY,-26,GETDATE())))),
(1, 'approve_event',    'event',   4,  N'Phê duyệt sự kiện: AI Summit',       '192.168.1.100', DATEADD(MINUTE, -28, DATEADD(HOUR, -14, DATEADD(DAY,-25,GETDATE())))),
(1, 'approve_event',    'event',   5,  N'Phê duyệt sự kiện: Run Marathon',    '192.168.1.100', DATEADD(MINUTE, -14, DATEADD(HOUR, -1, DATEADD(DAY,-24,GETDATE())))),
(1, 'feature_event',    'event',   1,  N'Đánh dấu nổi bật sự kiện #1',       '192.168.1.100', DATEADD(MINUTE, -10, DATEADD(HOUR, -13, DATEADD(DAY,-28,GETDATE())))),
(1, 'feature_event',    'event',   2,  N'Đánh dấu nổi bật sự kiện #2',       '192.168.1.100', DATEADD(MINUTE, -8, DATEADD(HOUR, -1, DATEADD(DAY,-27,GETDATE())))),
(1, 'update_settings',  'setting', NULL, N'Cập nhật platform_fee_percent = 5', '192.168.1.100', DATEADD(MINUTE, -11, DATEADD(HOUR, -23, DATEADD(DAY,-20,GETDATE())))),
(1, 'ban_user',         'user',    22, N'Khóa tài khoản: banned.user@test.com','192.168.1.100', DATEADD(MINUTE, -27, DATEADD(HOUR, -17, DATEADD(DAY,-15,GETDATE())))),
(1, 'resolve_ticket',   'ticket',  1,  N'Xử lý xong support ticket #1',       '192.168.1.100', DATEADD(MINUTE, -54, DATEADD(HOUR, -14, DATEADD(DAY,-10,GETDATE())))),
(1, 'refund_order',     'order',   49, N'Hoàn tiền đơn hàng O49',             '192.168.1.100', DATEADD(MINUTE, -48, DATEADD(HOUR, -19, DATEADD(DAY,-8,GETDATE())))),

(2, 'login',            'user',    2,  N'Support agent đăng nhập',            '10.0.0.50',     DATEADD(MINUTE, -30, DATEADD(HOUR, -10, DATEADD(DAY,-25,GETDATE())))),
(2, 'assign_ticket',    'ticket',  2,  N'Tiếp nhận xử lý ticket #2',         '10.0.0.50',     DATEADD(MINUTE, -48, DATEADD(HOUR, -5, DATEADD(DAY,-12,GETDATE())))),
(3, 'login',            'user',    3,  N'Support agent 2 đăng nhập',          '10.0.0.51',     DATEADD(MINUTE, -55, DATEADD(HOUR, -5, DATEADD(DAY,-20,GETDATE())))),

(4, 'login',            'user',    4,  N'Organizer Live Nation đăng nhập',     '172.16.0.10',   DATEADD(MINUTE, -58, DATEADD(HOUR, -10, DATEADD(DAY,-29,GETDATE())))),
(4, 'create_event',     'event',   1,  N'Tạo sự kiện: Đêm nhạc Hà Anh Tuấn', '172.16.0.10',   DATEADD(MINUTE, -6, DATEADD(HOUR, -23, DATEADD(DAY,-29,GETDATE())))),
(4, 'create_event',     'event',   2,  N'Tạo sự kiện: Rock Storm 2026',       '172.16.0.10',   DATEADD(MINUTE, -59, DATEADD(HOUR, -16, DATEADD(DAY,-28,GETDATE())))),
(4, 'upload_media',     'event',   1,  N'Upload banner sự kiện #1',           '172.16.0.10',   DATEADD(MINUTE, -55, DATEADD(HOUR, -13, DATEADD(DAY,-29,GETDATE())))),
(4, 'update_event',     'event',   1,  N'Cập nhật chi tiết sự kiện #1',       '172.16.0.10',   DATEADD(MINUTE, -47, DATEADD(HOUR, -11, DATEADD(DAY,-20,GETDATE())))),
(5, 'login',            'user',    5,  N'VieTravel organizer đăng nhập',       '172.16.0.11',   DATEADD(MINUTE, -9, DATEADD(HOUR, -10, DATEADD(DAY,-25,GETDATE())))),
(5, 'create_event',     'event',   3,  N'Tạo sự kiện: Food Festival',         '172.16.0.11',   DATEADD(MINUTE, -15, DATEADD(HOUR, -17, DATEADD(DAY,-25,GETDATE())))),
(6, 'login',            'user',    6,  N'TechViet organizer đăng nhập',        '172.16.0.12',   DATEADD(MINUTE, -7, DATEADD(HOUR, -4, DATEADD(DAY,-26,GETDATE())))),
(6, 'create_event',     'event',   4,  N'Tạo sự kiện: AI Summit',             '172.16.0.12',   DATEADD(MINUTE, -1, DATEADD(HOUR, -5, DATEADD(DAY,-26,GETDATE())))),

(9, 'login',            'user',    9,  N'Customer An đăng nhập',              '203.162.4.10',  DATEADD(MINUTE, -14, DATEADD(HOUR, -11, DATEADD(DAY,-20,GETDATE())))),
(9, 'purchase_ticket',  'order',   1,  N'Mua vé sự kiện #1',                 '203.162.4.10',  DATEADD(MINUTE, -39, DATEADD(HOUR, -9, DATEADD(DAY,-19,GETDATE())))),
(10,'login',            'user',    10, N'Customer Bình đăng nhập',            '203.162.4.11',  DATEADD(MINUTE, -20, DATEADD(HOUR, -3, DATEADD(DAY,-18,GETDATE())))),
(10,'purchase_ticket',  'order',   2,  N'Mua vé sự kiện #2',                 '203.162.4.11',  DATEADD(MINUTE, -42, DATEADD(HOUR, -19, DATEADD(DAY,-17,GETDATE())))),
(11,'login',            'user',    11, N'Customer Chi đăng nhập',             '203.162.4.12',  DATEADD(MINUTE, -12, DATEADD(HOUR, -17, DATEADD(DAY,-16,GETDATE())))),
(11,'purchase_ticket',  'order',   3,  N'Mua vé sự kiện #1',                 '203.162.4.12',  DATEADD(MINUTE, -51, DATEADD(HOUR, -1, DATEADD(DAY,-15,GETDATE()))));
GO

PRINT '=== ActivityLog seeded (30 entries) ===';
GO

-- =============================================
-- =============================================
INSERT INTO Notifications (user_id, type, title, message, link, is_read, created_at) VALUES
(1, 'event_pending',     N'Sự kiện mới chờ phê duyệt',      N'Sự kiện "Summer Beats 2026" cần được phê duyệt',            '/admin/events?status=pending',  1, DATEADD(MINUTE, -50, DATEADD(HOUR, -10, DATEADD(DAY,-25,GETDATE())))),
(1, 'support_ticket',    N'Support ticket mới',               N'Khách hàng báo cáo lỗi thanh toán — ticket #TK-001',        '/admin/support/1',              1, DATEADD(MINUTE, -10, DATEADD(HOUR, -4, DATEADD(DAY,-15,GETDATE())))),
(1, 'system_alert',      N'Doanh thu tuần vượt mốc',         N'Tổng doanh thu tuần đạt 50,000,000 VND',                     '/admin/dashboard',              0, DATEADD(MINUTE, -7, DATEADD(HOUR, -19, DATEADD(DAY,-5,GETDATE())))),
(1, 'refund_request',    N'Yêu cầu hoàn tiền',               N'Đơn hàng O49 yêu cầu hoàn tiền 600,000 VND',                '/admin/orders/49',              1, DATEADD(MINUTE, -48, DATEADD(HOUR, -4, DATEADD(DAY,-8,GETDATE())))),

(2, 'ticket_assigned',   N'Ticket được giao cho bạn',         N'Ticket #TK-002 đã được giao cho bạn xử lý',                '/support/tickets/2',            1, DATEADD(MINUTE, -35, DATEADD(HOUR, -9, DATEADD(DAY,-12,GETDATE())))),
(2, 'ticket_reply',      N'Khách hàng phản hồi',             N'Có phản hồi mới trong ticket #TK-002',                      '/support/tickets/2',            0, DATEADD(MINUTE, -47, DATEADD(HOUR, -20, DATEADD(DAY,-10,GETDATE())))),
(3, 'ticket_assigned',   N'Ticket được giao cho bạn',         N'Ticket #TK-003 đã được giao cho bạn xử lý',                '/support/tickets/3',            0, DATEADD(MINUTE, -58, DATEADD(HOUR, -17, DATEADD(DAY,-8,GETDATE())))),

(4, 'event_approved',    N'Sự kiện được phê duyệt',          N'Sự kiện "Đêm nhạc Hà Anh Tuấn" đã được phê duyệt',         '/organizer/events/1',           1, DATEADD(MINUTE, -32, DATEADD(HOUR, -12, DATEADD(DAY,-28,GETDATE())))),
(4, 'ticket_sold',       N'Có vé được bán',                  N'2 vé VIP sự kiện "Đêm nhạc Hà Anh Tuấn" vừa được bán',     '/organizer/events/1/orders',    1, DATEADD(MINUTE, -24, DATEADD(HOUR, -23, DATEADD(DAY,-19,GETDATE())))),
(4, 'ticket_sold',       N'Có vé được bán',                  N'3 vé Rock Storm 2026 vừa được bán',                         '/organizer/events/2/orders',    0, DATEADD(MINUTE, -53, DATEADD(HOUR, -12, DATEADD(DAY,-17,GETDATE())))),
(4, 'payout_ready',      N'Thanh toán sẵn sàng',             N'Tổng 4,500,000 VND sẵn sàng thanh toán cho tháng 2',        '/organizer/payouts',            0, DATEADD(MINUTE, -53, DATEADD(HOUR, -17, DATEADD(DAY,-3,GETDATE())))),
(5, 'event_approved',    N'Sự kiện được phê duyệt',          N'Sự kiện "Food Festival Sài Gòn" đã được phê duyệt',        '/organizer/events/3',           1, DATEADD(MINUTE, -43, DATEADD(HOUR, -6, DATEADD(DAY,-26,GETDATE())))),
(6, 'event_approved',    N'Sự kiện được phê duyệt',          N'Sự kiện "AI Summit 2026" đã được phê duyệt',               '/organizer/events/4',           1, DATEADD(MINUTE, -7, DATEADD(HOUR, -16, DATEADD(DAY,-25,GETDATE())))),

(9,  'order_confirmed',  N'Đặt vé thành công',               N'Bạn đã đặt thành công 2 vé VIP — Đêm nhạc Hà Anh Tuấn',   '/my-tickets',                   1, DATEADD(MINUTE, -10, DATEADD(HOUR, -9, DATEADD(DAY,-19,GETDATE())))),
(9,  'event_reminder',   N'Sự kiện sắp diễn ra',             N'Đêm nhạc Hà Anh Tuấn diễn ra sau 3 ngày nữa!',            '/events/1',                     0, DATEADD(MINUTE, -15, DATEADD(HOUR, -10, DATEADD(DAY,-4,GETDATE())))),
(10, 'order_confirmed',  N'Đặt vé thành công',               N'Bạn đã đặt thành công 1 vé — Rock Storm 2026',             '/my-tickets',                   1, DATEADD(MINUTE, -33, DATEADD(HOUR, -1, DATEADD(DAY,-17,GETDATE())))),
(11, 'order_confirmed',  N'Đặt vé thành công',               N'Bạn đã đặt thành công 3 vé — Đêm nhạc Hà Anh Tuấn',       '/my-tickets',                   1, DATEADD(MINUTE, -52, DATEADD(HOUR, -23, DATEADD(DAY,-15,GETDATE())))),
(12, 'order_confirmed',  N'Đặt vé thành công',               N'Đặt vé Food Festival thành công',                          '/my-tickets',                   1, DATEADD(MINUTE, -29, DATEADD(HOUR, -7, DATEADD(DAY,-14,GETDATE())))),
(13, 'order_confirmed',  N'Đặt vé thành công',               N'Đặt vé AI Summit 2026 thành công',                         '/my-tickets',                   0, DATEADD(MINUTE, -51, DATEADD(HOUR, -23, DATEADD(DAY,-12,GETDATE())))),
(14, 'order_confirmed',  N'Đặt vé thành công',               N'Đặt vé Run Marathon thành công',                           '/my-tickets',                   1, DATEADD(MINUTE, -30, DATEADD(HOUR, -13, DATEADD(DAY,-11,GETDATE())))),
(15, 'order_cancelled',  N'Đơn hàng bị hủy',                 N'Đơn hàng O48 đã bị hủy — liên hệ support',                '/support',                      1, DATEADD(MINUTE, -33, DATEADD(HOUR, -3, DATEADD(DAY,-7,GETDATE())))),
(16, 'refund_completed', N'Hoàn tiền thành công',             N'Đơn hàng O49 đã được hoàn tiền 600,000 VND',              '/my-orders',                    0, DATEADD(MINUTE, -2, DATEADD(HOUR, -4, DATEADD(DAY,-6,GETDATE())))),
(17, 'promotion',        N'Khuyến mãi đặc biệt',             N'Giảm 50% cho sự kiện tiếp theo! Dùng mã SYSLAUNCH50',     '/events',                       0, DATEADD(MINUTE, -56, DATEADD(HOUR, -12, DATEADD(DAY,-10,GETDATE())))),
(18, 'promotion',        N'Khuyến mãi đặc biệt',             N'Flash sale vé Rock Storm — chỉ hôm nay!',                 '/events/2',                     0, DATEADD(MINUTE, -3, DATEADD(HOUR, -7, DATEADD(DAY,-9,GETDATE()))));
GO

PRINT '=== Notifications seeded (24 entries) ===';
GO

-- =============================================
-- =============================================
PRINT '';




-- ================= MEGA SEED DATA (EXPLICIT ID >= 1000) =================
SET IDENTITY_INSERT Users ON;
INSERT INTO Users (user_id, email, password_hash, full_name, phone, gender, role, is_active, email_verified, created_at) VALUES
(1000, 'user_mega_1000@ticketbox.vn', '$2a$10$wT8Kz8Y5B4y5.J6uZbS7V.v/jB44G0s4lZ/tA.P91yWb.7J3S7X.S', N'Đỗ Hải', '0967395727', 'male', 'customer', 1, 1, DATEADD(MINUTE, 52, DATEADD(HOUR, 3, DATEADD(DAY, -37, GETDATE())))),
(1001, 'user_mega_1001@ticketbox.vn', '$2a$10$wT8Kz8Y5B4y5.J6uZbS7V.v/jB44G0s4lZ/tA.P91yWb.7J3S7X.S', N'Huỳnh Lan', '0962716305', 'female', 'customer', 1, 1, DATEADD(MINUTE, 35, DATEADD(HOUR, 8, DATEADD(DAY, -16, GETDATE())))),
(1002, 'user_mega_1002@ticketbox.vn', '$2a$10$wT8Kz8Y5B4y5.J6uZbS7V.v/jB44G0s4lZ/tA.P91yWb.7J3S7X.S', N'Huỳnh Anh', '0959366805', 'female', 'customer', 1, 1, DATEADD(MINUTE, 46, DATEADD(HOUR, 7, DATEADD(DAY, -22, GETDATE())))),
(1003, 'user_mega_1003@ticketbox.vn', '$2a$10$wT8Kz8Y5B4y5.J6uZbS7V.v/jB44G0s4lZ/tA.P91yWb.7J3S7X.S', N'Đặng Bảo', '0939029608', 'female', 'customer', 1, 1, DATEADD(MINUTE, 42, DATEADD(HOUR, 9, DATEADD(DAY, -11, GETDATE())))),
(1004, 'user_mega_1004@ticketbox.vn', '$2a$10$wT8Kz8Y5B4y5.J6uZbS7V.v/jB44G0s4lZ/tA.P91yWb.7J3S7X.S', N'Hoàng Tâm', '0989020690', 'female', 'customer', 1, 1, DATEADD(MINUTE, 39, DATEADD(HOUR, 1, DATEADD(DAY, -13, GETDATE())))),
(1005, 'user_mega_1005@ticketbox.vn', '$2a$10$wT8Kz8Y5B4y5.J6uZbS7V.v/jB44G0s4lZ/tA.P91yWb.7J3S7X.S', N'Nguyễn Khoa', '0912653505', 'female', 'customer', 1, 1, DATEADD(MINUTE, 33, DATEADD(HOUR, 12, DATEADD(DAY, -60, GETDATE())))),
(1006, 'user_mega_1006@ticketbox.vn', '$2a$10$wT8Kz8Y5B4y5.J6uZbS7V.v/jB44G0s4lZ/tA.P91yWb.7J3S7X.S', N'Bùi Tâm', '0990138351', 'female', 'customer', 1, 1, DATEADD(MINUTE, 25, DATEADD(HOUR, 9, DATEADD(DAY, -21, GETDATE())))),
(1007, 'user_mega_1007@ticketbox.vn', '$2a$10$wT8Kz8Y5B4y5.J6uZbS7V.v/jB44G0s4lZ/tA.P91yWb.7J3S7X.S', N'Vũ Lan', '0997749469', 'female', 'customer', 1, 1, DATEADD(MINUTE, 59, DATEADD(HOUR, 22, DATEADD(DAY, -15, GETDATE())))),
(1008, 'user_mega_1008@ticketbox.vn', '$2a$10$wT8Kz8Y5B4y5.J6uZbS7V.v/jB44G0s4lZ/tA.P91yWb.7J3S7X.S', N'Trần Linh', '0963997514', 'female', 'customer', 1, 1, DATEADD(MINUTE, 6, DATEADD(HOUR, 7, DATEADD(DAY, -10, GETDATE())))),
(1009, 'user_mega_1009@ticketbox.vn', '$2a$10$wT8Kz8Y5B4y5.J6uZbS7V.v/jB44G0s4lZ/tA.P91yWb.7J3S7X.S', N'Lê Trang', '0978523245', 'female', 'customer', 1, 1, DATEADD(MINUTE, 35, DATEADD(HOUR, 17, DATEADD(DAY, -50, GETDATE())))),
(1010, 'user_mega_1010@ticketbox.vn', '$2a$10$wT8Kz8Y5B4y5.J6uZbS7V.v/jB44G0s4lZ/tA.P91yWb.7J3S7X.S', N'Trần Minh', '0937018227', 'male', 'customer', 1, 1, DATEADD(MINUTE, 37, DATEADD(HOUR, 20, DATEADD(DAY, -46, GETDATE())))),
(1011, 'user_mega_1011@ticketbox.vn', '$2a$10$wT8Kz8Y5B4y5.J6uZbS7V.v/jB44G0s4lZ/tA.P91yWb.7J3S7X.S', N'Trần Bảo', '0963817493', 'male', 'customer', 1, 1, DATEADD(MINUTE, 3, DATEADD(HOUR, 10, DATEADD(DAY, -45, GETDATE())))),
(1012, 'user_mega_1012@ticketbox.vn', '$2a$10$wT8Kz8Y5B4y5.J6uZbS7V.v/jB44G0s4lZ/tA.P91yWb.7J3S7X.S', N'Đặng Hùng', '0956298596', 'female', 'customer', 1, 1, DATEADD(MINUTE, 56, DATEADD(HOUR, 1, DATEADD(DAY, -6, GETDATE())))),
(1013, 'user_mega_1013@ticketbox.vn', '$2a$10$wT8Kz8Y5B4y5.J6uZbS7V.v/jB44G0s4lZ/tA.P91yWb.7J3S7X.S', N'Huỳnh Hải', '0954329896', 'female', 'customer', 1, 1, DATEADD(MINUTE, 36, DATEADD(HOUR, 23, DATEADD(DAY, -22, GETDATE())))),
(1014, 'user_mega_1014@ticketbox.vn', '$2a$10$wT8Kz8Y5B4y5.J6uZbS7V.v/jB44G0s4lZ/tA.P91yWb.7J3S7X.S', N'Trần Bảo', '0997504183', 'female', 'customer', 1, 1, DATEADD(MINUTE, 48, DATEADD(HOUR, 9, DATEADD(DAY, -19, GETDATE())))),
(1015, 'user_mega_1015@ticketbox.vn', '$2a$10$wT8Kz8Y5B4y5.J6uZbS7V.v/jB44G0s4lZ/tA.P91yWb.7J3S7X.S', N'Bùi Bảo', '0926681011', 'male', 'customer', 1, 1, DATEADD(MINUTE, 39, DATEADD(HOUR, 21, DATEADD(DAY, -48, GETDATE())))),
(1016, 'user_mega_1016@ticketbox.vn', '$2a$10$wT8Kz8Y5B4y5.J6uZbS7V.v/jB44G0s4lZ/tA.P91yWb.7J3S7X.S', N'Vũ Hùng', '0980239313', 'male', 'customer', 1, 1, DATEADD(MINUTE, 48, DATEADD(HOUR, 18, DATEADD(DAY, -14, GETDATE())))),
(1017, 'user_mega_1017@ticketbox.vn', '$2a$10$wT8Kz8Y5B4y5.J6uZbS7V.v/jB44G0s4lZ/tA.P91yWb.7J3S7X.S', N'Hoàng Vân', '0980420687', 'male', 'customer', 1, 1, DATEADD(MINUTE, 26, DATEADD(HOUR, 5, DATEADD(DAY, -51, GETDATE())))),
(1018, 'user_mega_1018@ticketbox.vn', '$2a$10$wT8Kz8Y5B4y5.J6uZbS7V.v/jB44G0s4lZ/tA.P91yWb.7J3S7X.S', N'Đỗ Linh', '0985711961', 'male', 'customer', 1, 1, DATEADD(MINUTE, 17, DATEADD(HOUR, 18, DATEADD(DAY, -8, GETDATE())))),
(1019, 'user_mega_1019@ticketbox.vn', '$2a$10$wT8Kz8Y5B4y5.J6uZbS7V.v/jB44G0s4lZ/tA.P91yWb.7J3S7X.S', N'Đặng Kiên', '0913463149', 'female', 'customer', 1, 1, DATEADD(MINUTE, 21, DATEADD(HOUR, 6, DATEADD(DAY, -6, GETDATE())))),
(1020, 'user_mega_1020@ticketbox.vn', '$2a$10$wT8Kz8Y5B4y5.J6uZbS7V.v/jB44G0s4lZ/tA.P91yWb.7J3S7X.S', N'Vũ Khoa', '0980512635', 'female', 'customer', 1, 1, DATEADD(MINUTE, 0, DATEADD(HOUR, 23, DATEADD(DAY, -4, GETDATE())))),
(1021, 'user_mega_1021@ticketbox.vn', '$2a$10$wT8Kz8Y5B4y5.J6uZbS7V.v/jB44G0s4lZ/tA.P91yWb.7J3S7X.S', N'Phạm Hùng', '0970135998', 'female', 'customer', 1, 1, DATEADD(MINUTE, 51, DATEADD(HOUR, 11, DATEADD(DAY, -56, GETDATE())))),
(1022, 'user_mega_1022@ticketbox.vn', '$2a$10$wT8Kz8Y5B4y5.J6uZbS7V.v/jB44G0s4lZ/tA.P91yWb.7J3S7X.S', N'Trần Phong', '0980522458', 'male', 'customer', 1, 1, DATEADD(MINUTE, 30, DATEADD(HOUR, 17, DATEADD(DAY, -46, GETDATE())))),
(1023, 'user_mega_1023@ticketbox.vn', '$2a$10$wT8Kz8Y5B4y5.J6uZbS7V.v/jB44G0s4lZ/tA.P91yWb.7J3S7X.S', N'Đỗ Hùng', '0910083694', 'male', 'customer', 1, 1, DATEADD(MINUTE, 3, DATEADD(HOUR, 9, DATEADD(DAY, -39, GETDATE())))),
(1024, 'user_mega_1024@ticketbox.vn', '$2a$10$wT8Kz8Y5B4y5.J6uZbS7V.v/jB44G0s4lZ/tA.P91yWb.7J3S7X.S', N'Lê Hùng', '0944707449', 'female', 'customer', 1, 1, DATEADD(MINUTE, 48, DATEADD(HOUR, 19, DATEADD(DAY, -31, GETDATE())))),
(1025, 'user_mega_1025@ticketbox.vn', '$2a$10$wT8Kz8Y5B4y5.J6uZbS7V.v/jB44G0s4lZ/tA.P91yWb.7J3S7X.S', N'Nguyễn Phong', '0993408824', 'male', 'customer', 1, 1, DATEADD(MINUTE, 20, DATEADD(HOUR, 0, DATEADD(DAY, -37, GETDATE())))),
(1026, 'user_mega_1026@ticketbox.vn', '$2a$10$wT8Kz8Y5B4y5.J6uZbS7V.v/jB44G0s4lZ/tA.P91yWb.7J3S7X.S', N'Vũ Bảo', '0922135365', 'female', 'customer', 1, 1, DATEADD(MINUTE, 4, DATEADD(HOUR, 1, DATEADD(DAY, -49, GETDATE())))),
(1027, 'user_mega_1027@ticketbox.vn', '$2a$10$wT8Kz8Y5B4y5.J6uZbS7V.v/jB44G0s4lZ/tA.P91yWb.7J3S7X.S', N'Đỗ Phong', '0980373094', 'female', 'customer', 1, 1, DATEADD(MINUTE, 20, DATEADD(HOUR, 18, DATEADD(DAY, -20, GETDATE())))),
(1028, 'user_mega_1028@ticketbox.vn', '$2a$10$wT8Kz8Y5B4y5.J6uZbS7V.v/jB44G0s4lZ/tA.P91yWb.7J3S7X.S', N'Lê Minh', '0912404183', 'male', 'customer', 1, 1, DATEADD(MINUTE, 13, DATEADD(HOUR, 0, DATEADD(DAY, -26, GETDATE())))),
(1029, 'user_mega_1029@ticketbox.vn', '$2a$10$wT8Kz8Y5B4y5.J6uZbS7V.v/jB44G0s4lZ/tA.P91yWb.7J3S7X.S', N'Phạm Vân', '0913837587', 'female', 'customer', 1, 1, DATEADD(MINUTE, 46, DATEADD(HOUR, 2, DATEADD(DAY, -33, GETDATE())))),
(1030, 'user_mega_1030@ticketbox.vn', '$2a$10$wT8Kz8Y5B4y5.J6uZbS7V.v/jB44G0s4lZ/tA.P91yWb.7J3S7X.S', N'Lê Thành', '0937189263', 'male', 'customer', 1, 1, DATEADD(MINUTE, 37, DATEADD(HOUR, 12, DATEADD(DAY, -16, GETDATE())))),
(1031, 'user_mega_1031@ticketbox.vn', '$2a$10$wT8Kz8Y5B4y5.J6uZbS7V.v/jB44G0s4lZ/tA.P91yWb.7J3S7X.S', N'Hoàng Vân', '0927803016', 'female', 'customer', 1, 1, DATEADD(MINUTE, 35, DATEADD(HOUR, 3, DATEADD(DAY, -14, GETDATE())))),
(1032, 'user_mega_1032@ticketbox.vn', '$2a$10$wT8Kz8Y5B4y5.J6uZbS7V.v/jB44G0s4lZ/tA.P91yWb.7J3S7X.S', N'Hoàng Linh', '0987931823', 'male', 'customer', 1, 1, DATEADD(MINUTE, 10, DATEADD(HOUR, 19, DATEADD(DAY, -34, GETDATE())))),
(1033, 'user_mega_1033@ticketbox.vn', '$2a$10$wT8Kz8Y5B4y5.J6uZbS7V.v/jB44G0s4lZ/tA.P91yWb.7J3S7X.S', N'Đỗ Minh', '0936017443', 'female', 'customer', 1, 1, DATEADD(MINUTE, 5, DATEADD(HOUR, 12, DATEADD(DAY, -52, GETDATE())))),
(1034, 'user_mega_1034@ticketbox.vn', '$2a$10$wT8Kz8Y5B4y5.J6uZbS7V.v/jB44G0s4lZ/tA.P91yWb.7J3S7X.S', N'Bùi Minh', '0977100674', 'female', 'customer', 1, 1, DATEADD(MINUTE, 46, DATEADD(HOUR, 1, DATEADD(DAY, -26, GETDATE())))),
(1035, 'user_mega_1035@ticketbox.vn', '$2a$10$wT8Kz8Y5B4y5.J6uZbS7V.v/jB44G0s4lZ/tA.P91yWb.7J3S7X.S', N'Nguyễn Thu', '0928762226', 'male', 'customer', 1, 1, DATEADD(MINUTE, 58, DATEADD(HOUR, 21, DATEADD(DAY, -40, GETDATE())))),
(1036, 'user_mega_1036@ticketbox.vn', '$2a$10$wT8Kz8Y5B4y5.J6uZbS7V.v/jB44G0s4lZ/tA.P91yWb.7J3S7X.S', N'Huỳnh Hùng', '0972370489', 'male', 'customer', 1, 1, DATEADD(MINUTE, 17, DATEADD(HOUR, 1, DATEADD(DAY, -45, GETDATE())))),
(1037, 'user_mega_1037@ticketbox.vn', '$2a$10$wT8Kz8Y5B4y5.J6uZbS7V.v/jB44G0s4lZ/tA.P91yWb.7J3S7X.S', N'Đặng Thành', '0910304238', 'female', 'customer', 1, 1, DATEADD(MINUTE, 12, DATEADD(HOUR, 11, DATEADD(DAY, 0, GETDATE())))),
(1038, 'user_mega_1038@ticketbox.vn', '$2a$10$wT8Kz8Y5B4y5.J6uZbS7V.v/jB44G0s4lZ/tA.P91yWb.7J3S7X.S', N'Đỗ Linh', '0969659930', 'male', 'customer', 1, 1, DATEADD(MINUTE, 13, DATEADD(HOUR, 4, DATEADD(DAY, -1, GETDATE())))),
(1039, 'user_mega_1039@ticketbox.vn', '$2a$10$wT8Kz8Y5B4y5.J6uZbS7V.v/jB44G0s4lZ/tA.P91yWb.7J3S7X.S', N'Trần Anh', '0934359308', 'male', 'customer', 1, 1, DATEADD(MINUTE, 58, DATEADD(HOUR, 10, DATEADD(DAY, -60, GETDATE())))),
(1040, 'user_mega_1040@ticketbox.vn', '$2a$10$wT8Kz8Y5B4y5.J6uZbS7V.v/jB44G0s4lZ/tA.P91yWb.7J3S7X.S', N'Trần Vân', '0923396307', 'male', 'customer', 1, 1, DATEADD(MINUTE, 38, DATEADD(HOUR, 1, DATEADD(DAY, -2, GETDATE())))),
(1041, 'user_mega_1041@ticketbox.vn', '$2a$10$wT8Kz8Y5B4y5.J6uZbS7V.v/jB44G0s4lZ/tA.P91yWb.7J3S7X.S', N'Đặng Kiên', '0939336623', 'female', 'customer', 1, 1, DATEADD(MINUTE, 11, DATEADD(HOUR, 2, DATEADD(DAY, -44, GETDATE())))),
(1042, 'user_mega_1042@ticketbox.vn', '$2a$10$wT8Kz8Y5B4y5.J6uZbS7V.v/jB44G0s4lZ/tA.P91yWb.7J3S7X.S', N'Hoàng Hùng', '0964361915', 'female', 'customer', 1, 1, DATEADD(MINUTE, 34, DATEADD(HOUR, 1, DATEADD(DAY, -30, GETDATE())))),
(1043, 'user_mega_1043@ticketbox.vn', '$2a$10$wT8Kz8Y5B4y5.J6uZbS7V.v/jB44G0s4lZ/tA.P91yWb.7J3S7X.S', N'Đặng Trang', '0996159921', 'male', 'customer', 1, 1, DATEADD(MINUTE, 27, DATEADD(HOUR, 1, DATEADD(DAY, -42, GETDATE())))),
(1044, 'user_mega_1044@ticketbox.vn', '$2a$10$wT8Kz8Y5B4y5.J6uZbS7V.v/jB44G0s4lZ/tA.P91yWb.7J3S7X.S', N'Lê Vân', '0980880900', 'male', 'customer', 1, 1, DATEADD(MINUTE, 29, DATEADD(HOUR, 19, DATEADD(DAY, -9, GETDATE())))),
(1045, 'user_mega_1045@ticketbox.vn', '$2a$10$wT8Kz8Y5B4y5.J6uZbS7V.v/jB44G0s4lZ/tA.P91yWb.7J3S7X.S', N'Nguyễn Lan', '0934859934', 'male', 'customer', 1, 1, DATEADD(MINUTE, 55, DATEADD(HOUR, 21, DATEADD(DAY, -18, GETDATE())))),
(1046, 'user_mega_1046@ticketbox.vn', '$2a$10$wT8Kz8Y5B4y5.J6uZbS7V.v/jB44G0s4lZ/tA.P91yWb.7J3S7X.S', N'Huỳnh Linh', '0953399502', 'female', 'customer', 1, 1, DATEADD(MINUTE, 50, DATEADD(HOUR, 6, DATEADD(DAY, -59, GETDATE())))),
(1047, 'user_mega_1047@ticketbox.vn', '$2a$10$wT8Kz8Y5B4y5.J6uZbS7V.v/jB44G0s4lZ/tA.P91yWb.7J3S7X.S', N'Huỳnh Bảo', '0917703172', 'male', 'customer', 1, 1, DATEADD(MINUTE, 0, DATEADD(HOUR, 5, DATEADD(DAY, -26, GETDATE())))),
(1048, 'user_mega_1048@ticketbox.vn', '$2a$10$wT8Kz8Y5B4y5.J6uZbS7V.v/jB44G0s4lZ/tA.P91yWb.7J3S7X.S', N'Đặng Thành', '0995480791', 'male', 'customer', 1, 1, DATEADD(MINUTE, 2, DATEADD(HOUR, 1, DATEADD(DAY, -20, GETDATE())))),
(1049, 'user_mega_1049@ticketbox.vn', '$2a$10$wT8Kz8Y5B4y5.J6uZbS7V.v/jB44G0s4lZ/tA.P91yWb.7J3S7X.S', N'Lê Bảo', '0948428990', 'female', 'customer', 1, 1, DATEADD(MINUTE, 6, DATEADD(HOUR, 7, DATEADD(DAY, -3, GETDATE())))),
(1050, 'user_mega_1050@ticketbox.vn', '$2a$10$wT8Kz8Y5B4y5.J6uZbS7V.v/jB44G0s4lZ/tA.P91yWb.7J3S7X.S', N'Huỳnh Thành', '0929137276', 'female', 'customer', 1, 1, DATEADD(MINUTE, 1, DATEADD(HOUR, 2, DATEADD(DAY, -56, GETDATE())))),
(1051, 'user_mega_1051@ticketbox.vn', '$2a$10$wT8Kz8Y5B4y5.J6uZbS7V.v/jB44G0s4lZ/tA.P91yWb.7J3S7X.S', N'Nguyễn Tâm', '0961601941', 'female', 'customer', 1, 1, DATEADD(MINUTE, 8, DATEADD(HOUR, 16, DATEADD(DAY, -5, GETDATE())))),
(1052, 'user_mega_1052@ticketbox.vn', '$2a$10$wT8Kz8Y5B4y5.J6uZbS7V.v/jB44G0s4lZ/tA.P91yWb.7J3S7X.S', N'Phạm Anh', '0915726979', 'male', 'customer', 1, 1, DATEADD(MINUTE, 40, DATEADD(HOUR, 1, DATEADD(DAY, 0, GETDATE())))),
(1053, 'user_mega_1053@ticketbox.vn', '$2a$10$wT8Kz8Y5B4y5.J6uZbS7V.v/jB44G0s4lZ/tA.P91yWb.7J3S7X.S', N'Vũ Trang', '0944162669', 'male', 'customer', 1, 1, DATEADD(MINUTE, 22, DATEADD(HOUR, 2, DATEADD(DAY, -38, GETDATE())))),
(1054, 'user_mega_1054@ticketbox.vn', '$2a$10$wT8Kz8Y5B4y5.J6uZbS7V.v/jB44G0s4lZ/tA.P91yWb.7J3S7X.S', N'Đỗ Thu', '0930040922', 'female', 'customer', 1, 1, DATEADD(MINUTE, 43, DATEADD(HOUR, 13, DATEADD(DAY, -25, GETDATE())))),
(1055, 'user_mega_1055@ticketbox.vn', '$2a$10$wT8Kz8Y5B4y5.J6uZbS7V.v/jB44G0s4lZ/tA.P91yWb.7J3S7X.S', N'Nguyễn Kiên', '0998665033', 'male', 'customer', 1, 1, DATEADD(MINUTE, 52, DATEADD(HOUR, 4, DATEADD(DAY, -48, GETDATE())))),
(1056, 'user_mega_1056@ticketbox.vn', '$2a$10$wT8Kz8Y5B4y5.J6uZbS7V.v/jB44G0s4lZ/tA.P91yWb.7J3S7X.S', N'Đỗ Bảo', '0920596407', 'male', 'customer', 1, 1, DATEADD(MINUTE, 38, DATEADD(HOUR, 2, DATEADD(DAY, -49, GETDATE())))),
(1057, 'user_mega_1057@ticketbox.vn', '$2a$10$wT8Kz8Y5B4y5.J6uZbS7V.v/jB44G0s4lZ/tA.P91yWb.7J3S7X.S', N'Trần Phong', '0915957257', 'female', 'customer', 1, 1, DATEADD(MINUTE, 24, DATEADD(HOUR, 1, DATEADD(DAY, -60, GETDATE())))),
(1058, 'user_mega_1058@ticketbox.vn', '$2a$10$wT8Kz8Y5B4y5.J6uZbS7V.v/jB44G0s4lZ/tA.P91yWb.7J3S7X.S', N'Hoàng Linh', '0981956913', 'female', 'customer', 1, 1, DATEADD(MINUTE, 50, DATEADD(HOUR, 19, DATEADD(DAY, -20, GETDATE())))),
(1059, 'user_mega_1059@ticketbox.vn', '$2a$10$wT8Kz8Y5B4y5.J6uZbS7V.v/jB44G0s4lZ/tA.P91yWb.7J3S7X.S', N'Đặng Tâm', '0929113074', 'male', 'customer', 1, 1, DATEADD(MINUTE, 53, DATEADD(HOUR, 3, DATEADD(DAY, -42, GETDATE())))),
(1060, 'user_mega_1060@ticketbox.vn', '$2a$10$wT8Kz8Y5B4y5.J6uZbS7V.v/jB44G0s4lZ/tA.P91yWb.7J3S7X.S', N'Nguyễn Lan', '0951369505', 'male', 'customer', 1, 1, DATEADD(MINUTE, 24, DATEADD(HOUR, 6, DATEADD(DAY, -37, GETDATE())))),
(1061, 'user_mega_1061@ticketbox.vn', '$2a$10$wT8Kz8Y5B4y5.J6uZbS7V.v/jB44G0s4lZ/tA.P91yWb.7J3S7X.S', N'Vũ Trang', '0916474248', 'male', 'customer', 1, 1, DATEADD(MINUTE, 58, DATEADD(HOUR, 0, DATEADD(DAY, -37, GETDATE())))),
(1062, 'user_mega_1062@ticketbox.vn', '$2a$10$wT8Kz8Y5B4y5.J6uZbS7V.v/jB44G0s4lZ/tA.P91yWb.7J3S7X.S', N'Phạm Tâm', '0986192846', 'female', 'customer', 1, 1, DATEADD(MINUTE, 13, DATEADD(HOUR, 16, DATEADD(DAY, -34, GETDATE())))),
(1063, 'user_mega_1063@ticketbox.vn', '$2a$10$wT8Kz8Y5B4y5.J6uZbS7V.v/jB44G0s4lZ/tA.P91yWb.7J3S7X.S', N'Huỳnh Khoa', '0991661156', 'female', 'customer', 1, 1, DATEADD(MINUTE, 32, DATEADD(HOUR, 5, DATEADD(DAY, -44, GETDATE())))),
(1064, 'user_mega_1064@ticketbox.vn', '$2a$10$wT8Kz8Y5B4y5.J6uZbS7V.v/jB44G0s4lZ/tA.P91yWb.7J3S7X.S', N'Phạm Thành', '0936296631', 'female', 'customer', 1, 1, DATEADD(MINUTE, 39, DATEADD(HOUR, 9, DATEADD(DAY, -19, GETDATE())))),
(1065, 'user_mega_1065@ticketbox.vn', '$2a$10$wT8Kz8Y5B4y5.J6uZbS7V.v/jB44G0s4lZ/tA.P91yWb.7J3S7X.S', N'Vũ Hùng', '0974647492', 'female', 'customer', 1, 1, DATEADD(MINUTE, 11, DATEADD(HOUR, 0, DATEADD(DAY, -16, GETDATE())))),
(1066, 'user_mega_1066@ticketbox.vn', '$2a$10$wT8Kz8Y5B4y5.J6uZbS7V.v/jB44G0s4lZ/tA.P91yWb.7J3S7X.S', N'Đỗ Lan', '0993155499', 'female', 'customer', 1, 1, DATEADD(MINUTE, 28, DATEADD(HOUR, 21, DATEADD(DAY, -60, GETDATE())))),
(1067, 'user_mega_1067@ticketbox.vn', '$2a$10$wT8Kz8Y5B4y5.J6uZbS7V.v/jB44G0s4lZ/tA.P91yWb.7J3S7X.S', N'Đặng Trang', '0995826670', 'female', 'customer', 1, 1, DATEADD(MINUTE, 44, DATEADD(HOUR, 21, DATEADD(DAY, -53, GETDATE())))),
(1068, 'user_mega_1068@ticketbox.vn', '$2a$10$wT8Kz8Y5B4y5.J6uZbS7V.v/jB44G0s4lZ/tA.P91yWb.7J3S7X.S', N'Lê Hùng', '0974020435', 'female', 'customer', 1, 1, DATEADD(MINUTE, 51, DATEADD(HOUR, 13, DATEADD(DAY, -58, GETDATE())))),
(1069, 'user_mega_1069@ticketbox.vn', '$2a$10$wT8Kz8Y5B4y5.J6uZbS7V.v/jB44G0s4lZ/tA.P91yWb.7J3S7X.S', N'Trần Hải', '0992946372', 'female', 'customer', 1, 1, DATEADD(MINUTE, 50, DATEADD(HOUR, 11, DATEADD(DAY, -39, GETDATE())))),
(1070, 'user_mega_1070@ticketbox.vn', '$2a$10$wT8Kz8Y5B4y5.J6uZbS7V.v/jB44G0s4lZ/tA.P91yWb.7J3S7X.S', N'Đỗ Kiên', '0913455857', 'female', 'customer', 1, 1, DATEADD(MINUTE, 31, DATEADD(HOUR, 17, DATEADD(DAY, -44, GETDATE())))),
(1071, 'user_mega_1071@ticketbox.vn', '$2a$10$wT8Kz8Y5B4y5.J6uZbS7V.v/jB44G0s4lZ/tA.P91yWb.7J3S7X.S', N'Hoàng Linh', '0964252790', 'male', 'customer', 1, 1, DATEADD(MINUTE, 7, DATEADD(HOUR, 3, DATEADD(DAY, -55, GETDATE())))),
(1072, 'user_mega_1072@ticketbox.vn', '$2a$10$wT8Kz8Y5B4y5.J6uZbS7V.v/jB44G0s4lZ/tA.P91yWb.7J3S7X.S', N'Bùi Thành', '0911279616', 'male', 'customer', 1, 1, DATEADD(MINUTE, 19, DATEADD(HOUR, 8, DATEADD(DAY, -40, GETDATE())))),
(1073, 'user_mega_1073@ticketbox.vn', '$2a$10$wT8Kz8Y5B4y5.J6uZbS7V.v/jB44G0s4lZ/tA.P91yWb.7J3S7X.S', N'Nguyễn Trang', '0910939263', 'male', 'customer', 1, 1, DATEADD(MINUTE, 43, DATEADD(HOUR, 12, DATEADD(DAY, -51, GETDATE())))),
(1074, 'user_mega_1074@ticketbox.vn', '$2a$10$wT8Kz8Y5B4y5.J6uZbS7V.v/jB44G0s4lZ/tA.P91yWb.7J3S7X.S', N'Đỗ Trang', '0960523358', 'female', 'customer', 1, 1, DATEADD(MINUTE, 37, DATEADD(HOUR, 6, DATEADD(DAY, -34, GETDATE())))),
(1075, 'user_mega_1075@ticketbox.vn', '$2a$10$wT8Kz8Y5B4y5.J6uZbS7V.v/jB44G0s4lZ/tA.P91yWb.7J3S7X.S', N'Huỳnh Thành', '0969216261', 'female', 'customer', 1, 1, DATEADD(MINUTE, 17, DATEADD(HOUR, 0, DATEADD(DAY, -1, GETDATE())))),
(1076, 'user_mega_1076@ticketbox.vn', '$2a$10$wT8Kz8Y5B4y5.J6uZbS7V.v/jB44G0s4lZ/tA.P91yWb.7J3S7X.S', N'Đỗ Kiên', '0988473951', 'female', 'customer', 1, 1, DATEADD(MINUTE, 31, DATEADD(HOUR, 12, DATEADD(DAY, -46, GETDATE())))),
(1077, 'user_mega_1077@ticketbox.vn', '$2a$10$wT8Kz8Y5B4y5.J6uZbS7V.v/jB44G0s4lZ/tA.P91yWb.7J3S7X.S', N'Hoàng Hùng', '0955245515', 'female', 'customer', 1, 1, DATEADD(MINUTE, 18, DATEADD(HOUR, 3, DATEADD(DAY, -27, GETDATE())))),
(1078, 'user_mega_1078@ticketbox.vn', '$2a$10$wT8Kz8Y5B4y5.J6uZbS7V.v/jB44G0s4lZ/tA.P91yWb.7J3S7X.S', N'Hoàng Hùng', '0961100275', 'male', 'customer', 1, 1, DATEADD(MINUTE, 21, DATEADD(HOUR, 11, DATEADD(DAY, -17, GETDATE())))),
(1079, 'user_mega_1079@ticketbox.vn', '$2a$10$wT8Kz8Y5B4y5.J6uZbS7V.v/jB44G0s4lZ/tA.P91yWb.7J3S7X.S', N'Hoàng Thu', '0981000370', 'female', 'customer', 1, 1, DATEADD(MINUTE, 57, DATEADD(HOUR, 6, DATEADD(DAY, -8, GETDATE())))),
(1080, 'user_mega_1080@ticketbox.vn', '$2a$10$wT8Kz8Y5B4y5.J6uZbS7V.v/jB44G0s4lZ/tA.P91yWb.7J3S7X.S', N'Nguyễn Khoa', '0994698905', 'female', 'customer', 1, 1, DATEADD(MINUTE, 34, DATEADD(HOUR, 19, DATEADD(DAY, -5, GETDATE())))),
(1081, 'user_mega_1081@ticketbox.vn', '$2a$10$wT8Kz8Y5B4y5.J6uZbS7V.v/jB44G0s4lZ/tA.P91yWb.7J3S7X.S', N'Đỗ Bảo', '0993874150', 'male', 'customer', 1, 1, DATEADD(MINUTE, 44, DATEADD(HOUR, 7, DATEADD(DAY, -57, GETDATE())))),
(1082, 'user_mega_1082@ticketbox.vn', '$2a$10$wT8Kz8Y5B4y5.J6uZbS7V.v/jB44G0s4lZ/tA.P91yWb.7J3S7X.S', N'Đặng Vân', '0977438348', 'male', 'customer', 1, 1, DATEADD(MINUTE, 0, DATEADD(HOUR, 9, DATEADD(DAY, -59, GETDATE())))),
(1083, 'user_mega_1083@ticketbox.vn', '$2a$10$wT8Kz8Y5B4y5.J6uZbS7V.v/jB44G0s4lZ/tA.P91yWb.7J3S7X.S', N'Vũ Kiên', '0973129719', 'male', 'customer', 1, 1, DATEADD(MINUTE, 33, DATEADD(HOUR, 0, DATEADD(DAY, -8, GETDATE())))),
(1084, 'user_mega_1084@ticketbox.vn', '$2a$10$wT8Kz8Y5B4y5.J6uZbS7V.v/jB44G0s4lZ/tA.P91yWb.7J3S7X.S', N'Hoàng Khoa', '0919119629', 'female', 'customer', 1, 1, DATEADD(MINUTE, 8, DATEADD(HOUR, 9, DATEADD(DAY, -1, GETDATE())))),
(1085, 'user_mega_1085@ticketbox.vn', '$2a$10$wT8Kz8Y5B4y5.J6uZbS7V.v/jB44G0s4lZ/tA.P91yWb.7J3S7X.S', N'Huỳnh Trang', '0929676453', 'male', 'customer', 1, 1, DATEADD(MINUTE, 46, DATEADD(HOUR, 5, DATEADD(DAY, 0, GETDATE())))),
(1086, 'user_mega_1086@ticketbox.vn', '$2a$10$wT8Kz8Y5B4y5.J6uZbS7V.v/jB44G0s4lZ/tA.P91yWb.7J3S7X.S', N'Phạm Trang', '0945893550', 'male', 'customer', 1, 1, DATEADD(MINUTE, 24, DATEADD(HOUR, 20, DATEADD(DAY, -36, GETDATE())))),
(1087, 'user_mega_1087@ticketbox.vn', '$2a$10$wT8Kz8Y5B4y5.J6uZbS7V.v/jB44G0s4lZ/tA.P91yWb.7J3S7X.S', N'Nguyễn Khoa', '0966844993', 'female', 'customer', 1, 1, DATEADD(MINUTE, 52, DATEADD(HOUR, 20, DATEADD(DAY, -30, GETDATE())))),
(1088, 'user_mega_1088@ticketbox.vn', '$2a$10$wT8Kz8Y5B4y5.J6uZbS7V.v/jB44G0s4lZ/tA.P91yWb.7J3S7X.S', N'Vũ Khoa', '0961934486', 'male', 'customer', 1, 1, DATEADD(MINUTE, 22, DATEADD(HOUR, 8, DATEADD(DAY, -20, GETDATE())))),
(1089, 'user_mega_1089@ticketbox.vn', '$2a$10$wT8Kz8Y5B4y5.J6uZbS7V.v/jB44G0s4lZ/tA.P91yWb.7J3S7X.S', N'Phạm Hải', '0995571474', 'female', 'customer', 1, 1, DATEADD(MINUTE, 46, DATEADD(HOUR, 22, DATEADD(DAY, -9, GETDATE())))),
(1090, 'user_mega_1090@ticketbox.vn', '$2a$10$wT8Kz8Y5B4y5.J6uZbS7V.v/jB44G0s4lZ/tA.P91yWb.7J3S7X.S', N'Huỳnh Minh', '0912034433', 'male', 'customer', 1, 1, DATEADD(MINUTE, 43, DATEADD(HOUR, 2, DATEADD(DAY, -1, GETDATE())))),
(1091, 'user_mega_1091@ticketbox.vn', '$2a$10$wT8Kz8Y5B4y5.J6uZbS7V.v/jB44G0s4lZ/tA.P91yWb.7J3S7X.S', N'Hoàng Bảo', '0984330638', 'male', 'customer', 1, 1, DATEADD(MINUTE, 43, DATEADD(HOUR, 20, DATEADD(DAY, -58, GETDATE())))),
(1092, 'user_mega_1092@ticketbox.vn', '$2a$10$wT8Kz8Y5B4y5.J6uZbS7V.v/jB44G0s4lZ/tA.P91yWb.7J3S7X.S', N'Lê Khoa', '0989475298', 'male', 'customer', 1, 1, DATEADD(MINUTE, 25, DATEADD(HOUR, 6, DATEADD(DAY, -22, GETDATE())))),
(1093, 'user_mega_1093@ticketbox.vn', '$2a$10$wT8Kz8Y5B4y5.J6uZbS7V.v/jB44G0s4lZ/tA.P91yWb.7J3S7X.S', N'Hoàng Trang', '0927723516', 'female', 'customer', 1, 1, DATEADD(MINUTE, 38, DATEADD(HOUR, 11, DATEADD(DAY, -55, GETDATE())))),
(1094, 'user_mega_1094@ticketbox.vn', '$2a$10$wT8Kz8Y5B4y5.J6uZbS7V.v/jB44G0s4lZ/tA.P91yWb.7J3S7X.S', N'Vũ Khoa', '0987516446', 'female', 'customer', 1, 1, DATEADD(MINUTE, 6, DATEADD(HOUR, 15, DATEADD(DAY, -26, GETDATE())))),
(1095, 'user_mega_1095@ticketbox.vn', '$2a$10$wT8Kz8Y5B4y5.J6uZbS7V.v/jB44G0s4lZ/tA.P91yWb.7J3S7X.S', N'Hoàng Lan', '0954684311', 'female', 'customer', 1, 1, DATEADD(MINUTE, 8, DATEADD(HOUR, 2, DATEADD(DAY, -29, GETDATE())))),
(1096, 'user_mega_1096@ticketbox.vn', '$2a$10$wT8Kz8Y5B4y5.J6uZbS7V.v/jB44G0s4lZ/tA.P91yWb.7J3S7X.S', N'Vũ Hải', '0956947712', 'female', 'customer', 1, 1, DATEADD(MINUTE, 27, DATEADD(HOUR, 12, DATEADD(DAY, -8, GETDATE())))),
(1097, 'user_mega_1097@ticketbox.vn', '$2a$10$wT8Kz8Y5B4y5.J6uZbS7V.v/jB44G0s4lZ/tA.P91yWb.7J3S7X.S', N'Huỳnh Lan', '0925665059', 'male', 'customer', 1, 1, DATEADD(MINUTE, 31, DATEADD(HOUR, 5, DATEADD(DAY, -50, GETDATE())))),
(1098, 'user_mega_1098@ticketbox.vn', '$2a$10$wT8Kz8Y5B4y5.J6uZbS7V.v/jB44G0s4lZ/tA.P91yWb.7J3S7X.S', N'Nguyễn Linh', '0926539782', 'female', 'customer', 1, 1, DATEADD(MINUTE, 7, DATEADD(HOUR, 8, DATEADD(DAY, -50, GETDATE())))),
(1099, 'user_mega_1099@ticketbox.vn', '$2a$10$wT8Kz8Y5B4y5.J6uZbS7V.v/jB44G0s4lZ/tA.P91yWb.7J3S7X.S', N'Lê Phong', '0988567097', 'male', 'customer', 1, 1, DATEADD(MINUTE, 50, DATEADD(HOUR, 13, DATEADD(DAY, -16, GETDATE()))));
SET IDENTITY_INSERT Users OFF;
GO
SET IDENTITY_INSERT Events ON;
INSERT INTO Events (event_id, organizer_id, category_id, title, slug, status, start_date, max_tickets_per_order, created_at) VALUES
(1000, 5, 5, N'Triển lãm Văn hóa 1000', 'mega-event-1000-2653', 'approved', DATEADD(MINUTE, 44, DATEADD(HOUR, 3, DATEADD(DAY, -45, GETDATE()))), 10, DATEADD(MINUTE, 29, DATEADD(HOUR, 17, DATEADD(DAY, -31, GETDATE())))),
(1001, 5, 2, N'Summit Bất Động Sản 1001', 'mega-event-1001-6595', 'approved', DATEADD(MINUTE, 8, DATEADD(HOUR, 1, DATEADD(DAY, 18, GETDATE()))), 10, DATEADD(MINUTE, 28, DATEADD(HOUR, 19, DATEADD(DAY, -59, GETDATE())))),
(1002, 7, 2, N'Lễ hội Khởi nghiệp 1002', 'mega-event-1002-2926', 'pending', DATEADD(MINUTE, 11, DATEADD(HOUR, 19, DATEADD(DAY, -59, GETDATE()))), 10, DATEADD(MINUTE, 32, DATEADD(HOUR, 23, DATEADD(DAY, -49, GETDATE())))),
(1003, 7, 2, N'Workshop Văn hóa 1003', 'mega-event-1003-5363', 'approved', DATEADD(MINUTE, 35, DATEADD(HOUR, 12, DATEADD(DAY, 13, GETDATE()))), 10, DATEADD(MINUTE, 48, DATEADD(HOUR, 17, DATEADD(DAY, -57, GETDATE())))),
(1004, 4, 5, N'Hội thảo Công Nghệ 1004', 'mega-event-1004-8239', 'approved', DATEADD(MINUTE, 1, DATEADD(HOUR, 5, DATEADD(DAY, 69, GETDATE()))), 10, DATEADD(MINUTE, 45, DATEADD(HOUR, 1, DATEADD(DAY, -2, GETDATE())))),
(1005, 5, 1, N'Đêm nhạc Bất Động Sản 1005', 'mega-event-1005-7576', 'approved', DATEADD(MINUTE, 43, DATEADD(HOUR, 3, DATEADD(DAY, 89, GETDATE()))), 10, DATEADD(MINUTE, 12, DATEADD(HOUR, 19, DATEADD(DAY, -18, GETDATE())))),
(1006, 8, 6, N'Giải đấu Tương Lai 1006', 'mega-event-1006-3853', 'pending', DATEADD(MINUTE, 1, DATEADD(HOUR, 9, DATEADD(DAY, 48, GETDATE()))), 10, DATEADD(MINUTE, 47, DATEADD(HOUR, 12, DATEADD(DAY, -38, GETDATE())))),
(1007, 8, 6, N'Triển lãm Gaming 1007', 'mega-event-1007-4589', 'approved', DATEADD(MINUTE, 37, DATEADD(HOUR, 13, DATEADD(DAY, 44, GETDATE()))), 10, DATEADD(MINUTE, 7, DATEADD(HOUR, 11, DATEADD(DAY, -34, GETDATE())))),
(1008, 4, 3, N'Liveshow Sinh Viên 1008', 'mega-event-1008-8753', 'approved', DATEADD(MINUTE, 29, DATEADD(HOUR, 3, DATEADD(DAY, -11, GETDATE()))), 10, DATEADD(MINUTE, 43, DATEADD(HOUR, 5, DATEADD(DAY, -6, GETDATE())))),
(1009, 5, 1, N'Giải đấu Sinh Viên 1009', 'mega-event-1009-7709', 'approved', DATEADD(MINUTE, 19, DATEADD(HOUR, 14, DATEADD(DAY, -35, GETDATE()))), 10, DATEADD(MINUTE, 56, DATEADD(HOUR, 0, DATEADD(DAY, -50, GETDATE())))),
(1010, 7, 1, N'Lễ hội Tương Lai 1010', 'mega-event-1010-3724', 'approved', DATEADD(MINUTE, 57, DATEADD(HOUR, 9, DATEADD(DAY, 76, GETDATE()))), 10, DATEADD(MINUTE, 31, DATEADD(HOUR, 11, DATEADD(DAY, -28, GETDATE())))),
(1011, 5, 6, N'Webinar Nghệ Thuật 1011', 'mega-event-1011-3731', 'draft', DATEADD(MINUTE, 55, DATEADD(HOUR, 17, DATEADD(DAY, -20, GETDATE()))), 10, DATEADD(MINUTE, 59, DATEADD(HOUR, 13, DATEADD(DAY, -8, GETDATE())))),
(1012, 7, 4, N'Hội thảo Sinh Viên 1012', 'mega-event-1012-2994', 'approved', DATEADD(MINUTE, 54, DATEADD(HOUR, 19, DATEADD(DAY, 86, GETDATE()))), 10, DATEADD(MINUTE, 11, DATEADD(HOUR, 5, DATEADD(DAY, -20, GETDATE())))),
(1013, 8, 3, N'Webinar Tương Lai 1013', 'mega-event-1013-4474', 'draft', DATEADD(MINUTE, 45, DATEADD(HOUR, 20, DATEADD(DAY, 8, GETDATE()))), 10, DATEADD(MINUTE, 17, DATEADD(HOUR, 13, DATEADD(DAY, -56, GETDATE())))),
(1014, 4, 6, N'Workshop Tương Lai 1014', 'mega-event-1014-6931', 'approved', DATEADD(MINUTE, 15, DATEADD(HOUR, 11, DATEADD(DAY, 50, GETDATE()))), 10, DATEADD(MINUTE, 29, DATEADD(HOUR, 12, DATEADD(DAY, -39, GETDATE())))),
(1015, 8, 5, N'Hội thảo Khởi nghiệp 1015', 'mega-event-1015-2426', 'approved', DATEADD(MINUTE, 26, DATEADD(HOUR, 8, DATEADD(DAY, 35, GETDATE()))), 10, DATEADD(MINUTE, 46, DATEADD(HOUR, 6, DATEADD(DAY, -16, GETDATE())))),
(1016, 5, 3, N'Liveshow Công Nghệ 1016', 'mega-event-1016-1502', 'approved', DATEADD(MINUTE, 46, DATEADD(HOUR, 16, DATEADD(DAY, 56, GETDATE()))), 10, DATEADD(MINUTE, 3, DATEADD(HOUR, 11, DATEADD(DAY, -32, GETDATE())))),
(1017, 4, 3, N'Lễ hội Thương mại 1017', 'mega-event-1017-8802', 'approved', DATEADD(MINUTE, 48, DATEADD(HOUR, 2, DATEADD(DAY, 75, GETDATE()))), 10, DATEADD(MINUTE, 48, DATEADD(HOUR, 17, DATEADD(DAY, -45, GETDATE())))),
(1018, 8, 5, N'Liveshow Sinh Viên 1018', 'mega-event-1018-9370', 'approved', DATEADD(MINUTE, 30, DATEADD(HOUR, 10, DATEADD(DAY, 49, GETDATE()))), 10, DATEADD(MINUTE, 40, DATEADD(HOUR, 2, DATEADD(DAY, -23, GETDATE())))),
(1019, 8, 2, N'Workshop Sinh Viên 1019', 'mega-event-1019-8520', 'approved', DATEADD(MINUTE, 47, DATEADD(HOUR, 15, DATEADD(DAY, -58, GETDATE()))), 10, DATEADD(MINUTE, 5, DATEADD(HOUR, 5, DATEADD(DAY, -44, GETDATE())))),
(1020, 6, 4, N'Liveshow Nghệ Thuật 1020', 'mega-event-1020-7696', 'draft', DATEADD(MINUTE, 33, DATEADD(HOUR, 5, DATEADD(DAY, 85, GETDATE()))), 10, DATEADD(MINUTE, 8, DATEADD(HOUR, 10, DATEADD(DAY, -43, GETDATE())))),
(1021, 6, 5, N'Giải đấu Gaming 1021', 'mega-event-1021-9054', 'approved', DATEADD(MINUTE, 8, DATEADD(HOUR, 17, DATEADD(DAY, 48, GETDATE()))), 10, DATEADD(MINUTE, 56, DATEADD(HOUR, 14, DATEADD(DAY, -42, GETDATE())))),
(1022, 5, 5, N'Webinar Bất Động Sản 1022', 'mega-event-1022-4646', 'draft', DATEADD(MINUTE, 14, DATEADD(HOUR, 3, DATEADD(DAY, -18, GETDATE()))), 10, DATEADD(MINUTE, 7, DATEADD(HOUR, 3, DATEADD(DAY, -3, GETDATE())))),
(1023, 7, 4, N'Lễ hội Khởi nghiệp 1023', 'mega-event-1023-7826', 'draft', DATEADD(MINUTE, 55, DATEADD(HOUR, 21, DATEADD(DAY, -40, GETDATE()))), 10, DATEADD(MINUTE, 40, DATEADD(HOUR, 2, DATEADD(DAY, -31, GETDATE())))),
(1024, 8, 3, N'Triển lãm Văn hóa 1024', 'mega-event-1024-3910', 'approved', DATEADD(MINUTE, 34, DATEADD(HOUR, 16, DATEADD(DAY, 38, GETDATE()))), 10, DATEADD(MINUTE, 12, DATEADD(HOUR, 7, DATEADD(DAY, -11, GETDATE())))),
(1025, 8, 4, N'Hội thảo Mùa Xuân 2026 1025', 'mega-event-1025-3341', 'approved', DATEADD(MINUTE, 49, DATEADD(HOUR, 23, DATEADD(DAY, 9, GETDATE()))), 10, DATEADD(MINUTE, 4, DATEADD(HOUR, 22, DATEADD(DAY, -35, GETDATE())))),
(1026, 5, 1, N'Giải đấu Tương Lai 1026', 'mega-event-1026-7785', 'approved', DATEADD(MINUTE, 35, DATEADD(HOUR, 7, DATEADD(DAY, 75, GETDATE()))), 10, DATEADD(MINUTE, 14, DATEADD(HOUR, 9, DATEADD(DAY, -49, GETDATE())))),
(1027, 8, 2, N'Hội thảo Tương Lai 1027', 'mega-event-1027-9101', 'approved', DATEADD(MINUTE, 55, DATEADD(HOUR, 22, DATEADD(DAY, -43, GETDATE()))), 10, DATEADD(MINUTE, 34, DATEADD(HOUR, 17, DATEADD(DAY, -1, GETDATE())))),
(1028, 8, 4, N'Workshop Thương mại 1028', 'mega-event-1028-6989', 'approved', DATEADD(MINUTE, 39, DATEADD(HOUR, 20, DATEADD(DAY, -27, GETDATE()))), 10, DATEADD(MINUTE, 49, DATEADD(HOUR, 6, DATEADD(DAY, -18, GETDATE())))),
(1029, 8, 5, N'Đêm nhạc Công Nghệ 1029', 'mega-event-1029-3252', 'approved', DATEADD(MINUTE, 2, DATEADD(HOUR, 23, DATEADD(DAY, 3, GETDATE()))), 10, DATEADD(MINUTE, 39, DATEADD(HOUR, 10, DATEADD(DAY, -12, GETDATE())))),
(1030, 4, 3, N'Triển lãm Nghệ Thuật 1030', 'mega-event-1030-5541', 'approved', DATEADD(MINUTE, 56, DATEADD(HOUR, 6, DATEADD(DAY, -50, GETDATE()))), 10, DATEADD(MINUTE, 16, DATEADD(HOUR, 15, DATEADD(DAY, -12, GETDATE())))),
(1031, 8, 5, N'Giải đấu Nghệ Thuật 1031', 'mega-event-1031-8424', 'approved', DATEADD(MINUTE, 44, DATEADD(HOUR, 13, DATEADD(DAY, 87, GETDATE()))), 10, DATEADD(MINUTE, 36, DATEADD(HOUR, 22, DATEADD(DAY, -2, GETDATE())))),
(1032, 6, 1, N'Hội thảo Văn hóa 1032', 'mega-event-1032-9252', 'pending', DATEADD(MINUTE, 53, DATEADD(HOUR, 3, DATEADD(DAY, 86, GETDATE()))), 10, DATEADD(MINUTE, 4, DATEADD(HOUR, 3, DATEADD(DAY, -59, GETDATE())))),
(1033, 4, 4, N'Lễ hội Sinh Viên 1033', 'mega-event-1033-4372', 'draft', DATEADD(MINUTE, 52, DATEADD(HOUR, 9, DATEADD(DAY, 49, GETDATE()))), 10, DATEADD(MINUTE, 57, DATEADD(HOUR, 22, DATEADD(DAY, -20, GETDATE())))),
(1034, 4, 4, N'Webinar Thương mại 1034', 'mega-event-1034-2295', 'draft', DATEADD(MINUTE, 5, DATEADD(HOUR, 4, DATEADD(DAY, 68, GETDATE()))), 10, DATEADD(MINUTE, 15, DATEADD(HOUR, 0, DATEADD(DAY, -32, GETDATE())))),
(1035, 8, 2, N'Workshop Văn hóa 1035', 'mega-event-1035-6003', 'draft', DATEADD(MINUTE, 25, DATEADD(HOUR, 19, DATEADD(DAY, 9, GETDATE()))), 10, DATEADD(MINUTE, 53, DATEADD(HOUR, 1, DATEADD(DAY, -41, GETDATE())))),
(1036, 5, 2, N'Giải đấu Nghệ Thuật 1036', 'mega-event-1036-9363', 'approved', DATEADD(MINUTE, 25, DATEADD(HOUR, 23, DATEADD(DAY, -21, GETDATE()))), 10, DATEADD(MINUTE, 2, DATEADD(HOUR, 16, DATEADD(DAY, -13, GETDATE())))),
(1037, 4, 5, N'Giao lưu Bất Động Sản 1037', 'mega-event-1037-9841', 'pending', DATEADD(MINUTE, 19, DATEADD(HOUR, 16, DATEADD(DAY, 42, GETDATE()))), 10, DATEADD(MINUTE, 41, DATEADD(HOUR, 15, DATEADD(DAY, -17, GETDATE())))),
(1038, 5, 3, N'Summit Khởi nghiệp 1038', 'mega-event-1038-2395', 'approved', DATEADD(MINUTE, 58, DATEADD(HOUR, 4, DATEADD(DAY, 25, GETDATE()))), 10, DATEADD(MINUTE, 43, DATEADD(HOUR, 12, DATEADD(DAY, -44, GETDATE())))),
(1039, 5, 2, N'Summit Nghệ Thuật 1039', 'mega-event-1039-5235', 'approved', DATEADD(MINUTE, 35, DATEADD(HOUR, 14, DATEADD(DAY, 42, GETDATE()))), 10, DATEADD(MINUTE, 59, DATEADD(HOUR, 7, DATEADD(DAY, -56, GETDATE())))),
(1040, 5, 1, N'Giải đấu Gaming 1040', 'mega-event-1040-7678', 'approved', DATEADD(MINUTE, 47, DATEADD(HOUR, 15, DATEADD(DAY, -53, GETDATE()))), 10, DATEADD(MINUTE, 56, DATEADD(HOUR, 14, DATEADD(DAY, -52, GETDATE())))),
(1041, 5, 1, N'Hội thảo Văn hóa 1041', 'mega-event-1041-5015', 'approved', DATEADD(MINUTE, 45, DATEADD(HOUR, 17, DATEADD(DAY, 52, GETDATE()))), 10, DATEADD(MINUTE, 49, DATEADD(HOUR, 0, DATEADD(DAY, -28, GETDATE())))),
(1042, 6, 2, N'Liveshow Công Nghệ 1042', 'mega-event-1042-1744', 'pending', DATEADD(MINUTE, 5, DATEADD(HOUR, 0, DATEADD(DAY, -33, GETDATE()))), 10, DATEADD(MINUTE, 11, DATEADD(HOUR, 7, DATEADD(DAY, -20, GETDATE())))),
(1043, 4, 1, N'Triển lãm Bất Động Sản 1043', 'mega-event-1043-7020', 'approved', DATEADD(MINUTE, 32, DATEADD(HOUR, 2, DATEADD(DAY, 4, GETDATE()))), 10, DATEADD(MINUTE, 19, DATEADD(HOUR, 21, DATEADD(DAY, -44, GETDATE())))),
(1044, 7, 6, N'Giải đấu Nghệ Thuật 1044', 'mega-event-1044-6944', 'draft', DATEADD(MINUTE, 35, DATEADD(HOUR, 4, DATEADD(DAY, 54, GETDATE()))), 10, DATEADD(MINUTE, 13, DATEADD(HOUR, 18, DATEADD(DAY, -57, GETDATE())))),
(1045, 5, 2, N'Webinar Văn hóa 1045', 'mega-event-1045-7457', 'draft', DATEADD(MINUTE, 4, DATEADD(HOUR, 1, DATEADD(DAY, 45, GETDATE()))), 10, DATEADD(MINUTE, 53, DATEADD(HOUR, 22, DATEADD(DAY, -44, GETDATE())))),
(1046, 4, 3, N'Summit Tương Lai 1046', 'mega-event-1046-5118', 'approved', DATEADD(MINUTE, 41, DATEADD(HOUR, 18, DATEADD(DAY, -16, GETDATE()))), 10, DATEADD(MINUTE, 1, DATEADD(HOUR, 21, DATEADD(DAY, -19, GETDATE())))),
(1047, 6, 2, N'Đêm nhạc Sinh Viên 1047', 'mega-event-1047-9887', 'approved', DATEADD(MINUTE, 2, DATEADD(HOUR, 20, DATEADD(DAY, -37, GETDATE()))), 10, DATEADD(MINUTE, 3, DATEADD(HOUR, 4, DATEADD(DAY, -51, GETDATE())))),
(1048, 5, 6, N'Triển lãm Văn hóa 1048', 'mega-event-1048-5382', 'approved', DATEADD(MINUTE, 2, DATEADD(HOUR, 20, DATEADD(DAY, 89, GETDATE()))), 10, DATEADD(MINUTE, 37, DATEADD(HOUR, 23, DATEADD(DAY, -19, GETDATE())))),
(1049, 5, 2, N'Giao lưu Sinh Viên 1049', 'mega-event-1049-9229', 'draft', DATEADD(MINUTE, 26, DATEADD(HOUR, 8, DATEADD(DAY, -55, GETDATE()))), 10, DATEADD(MINUTE, 36, DATEADD(HOUR, 11, DATEADD(DAY, -6, GETDATE())))),
(1050, 8, 4, N'Triển lãm Gaming 1050', 'mega-event-1050-6902', 'approved', DATEADD(MINUTE, 53, DATEADD(HOUR, 14, DATEADD(DAY, 71, GETDATE()))), 10, DATEADD(MINUTE, 20, DATEADD(HOUR, 21, DATEADD(DAY, -8, GETDATE())))),
(1051, 6, 6, N'Đêm nhạc Thương mại 1051', 'mega-event-1051-2702', 'approved', DATEADD(MINUTE, 58, DATEADD(HOUR, 18, DATEADD(DAY, 38, GETDATE()))), 10, DATEADD(MINUTE, 36, DATEADD(HOUR, 2, DATEADD(DAY, -1, GETDATE())))),
(1052, 4, 6, N'Hội thảo Nghệ Thuật 1052', 'mega-event-1052-8618', 'approved', DATEADD(MINUTE, 54, DATEADD(HOUR, 8, DATEADD(DAY, 24, GETDATE()))), 10, DATEADD(MINUTE, 6, DATEADD(HOUR, 14, DATEADD(DAY, -26, GETDATE())))),
(1053, 7, 3, N'Giao lưu Gaming 1053', 'mega-event-1053-4336', 'approved', DATEADD(MINUTE, 12, DATEADD(HOUR, 21, DATEADD(DAY, 86, GETDATE()))), 10, DATEADD(MINUTE, 43, DATEADD(HOUR, 23, DATEADD(DAY, -57, GETDATE())))),
(1054, 6, 2, N'Lễ hội Tương Lai 1054', 'mega-event-1054-8095', 'approved', DATEADD(MINUTE, 19, DATEADD(HOUR, 9, DATEADD(DAY, 51, GETDATE()))), 10, DATEADD(MINUTE, 58, DATEADD(HOUR, 6, DATEADD(DAY, -48, GETDATE())))),
(1055, 4, 6, N'Triển lãm Tương Lai 1055', 'mega-event-1055-8038', 'draft', DATEADD(MINUTE, 40, DATEADD(HOUR, 9, DATEADD(DAY, 42, GETDATE()))), 10, DATEADD(MINUTE, 12, DATEADD(HOUR, 2, DATEADD(DAY, -2, GETDATE())))),
(1056, 6, 2, N'Triển lãm Tương Lai 1056', 'mega-event-1056-4619', 'pending', DATEADD(MINUTE, 8, DATEADD(HOUR, 4, DATEADD(DAY, 80, GETDATE()))), 10, DATEADD(MINUTE, 36, DATEADD(HOUR, 14, DATEADD(DAY, -14, GETDATE())))),
(1057, 8, 5, N'Summit Công Nghệ 1057', 'mega-event-1057-2901', 'pending', DATEADD(MINUTE, 31, DATEADD(HOUR, 14, DATEADD(DAY, 62, GETDATE()))), 10, DATEADD(MINUTE, 47, DATEADD(HOUR, 18, DATEADD(DAY, -15, GETDATE())))),
(1058, 8, 1, N'Giải đấu Gaming 1058', 'mega-event-1058-3383', 'draft', DATEADD(MINUTE, 49, DATEADD(HOUR, 8, DATEADD(DAY, 65, GETDATE()))), 10, DATEADD(MINUTE, 2, DATEADD(HOUR, 13, DATEADD(DAY, -8, GETDATE())))),
(1059, 8, 5, N'Đêm nhạc Bất Động Sản 1059', 'mega-event-1059-4555', 'approved', DATEADD(MINUTE, 39, DATEADD(HOUR, 0, DATEADD(DAY, 57, GETDATE()))), 10, DATEADD(MINUTE, 32, DATEADD(HOUR, 2, DATEADD(DAY, -33, GETDATE())))),
(1060, 5, 5, N'Workshop Bất Động Sản 1060', 'mega-event-1060-7465', 'approved', DATEADD(MINUTE, 4, DATEADD(HOUR, 12, DATEADD(DAY, 86, GETDATE()))), 10, DATEADD(MINUTE, 40, DATEADD(HOUR, 22, DATEADD(DAY, -23, GETDATE())))),
(1061, 5, 2, N'Giải đấu Công Nghệ 1061', 'mega-event-1061-4513', 'approved', DATEADD(MINUTE, 3, DATEADD(HOUR, 16, DATEADD(DAY, -22, GETDATE()))), 10, DATEADD(MINUTE, 49, DATEADD(HOUR, 21, DATEADD(DAY, -3, GETDATE())))),
(1062, 7, 6, N'Liveshow Thương mại 1062', 'mega-event-1062-5013', 'draft', DATEADD(MINUTE, 26, DATEADD(HOUR, 21, DATEADD(DAY, 64, GETDATE()))), 10, DATEADD(MINUTE, 23, DATEADD(HOUR, 21, DATEADD(DAY, -35, GETDATE())))),
(1063, 4, 3, N'Workshop Tương Lai 1063', 'mega-event-1063-6787', 'pending', DATEADD(MINUTE, 29, DATEADD(HOUR, 19, DATEADD(DAY, 71, GETDATE()))), 10, DATEADD(MINUTE, 14, DATEADD(HOUR, 17, DATEADD(DAY, -55, GETDATE())))),
(1064, 5, 3, N'Đêm nhạc Sinh Viên 1064', 'mega-event-1064-9225', 'approved', DATEADD(MINUTE, 8, DATEADD(HOUR, 12, DATEADD(DAY, 21, GETDATE()))), 10, DATEADD(MINUTE, 32, DATEADD(HOUR, 11, DATEADD(DAY, -57, GETDATE())))),
(1065, 5, 3, N'Triển lãm Khởi nghiệp 1065', 'mega-event-1065-4659', 'approved', DATEADD(MINUTE, 8, DATEADD(HOUR, 20, DATEADD(DAY, 64, GETDATE()))), 10, DATEADD(MINUTE, 58, DATEADD(HOUR, 15, DATEADD(DAY, -45, GETDATE())))),
(1066, 7, 6, N'Hội thảo Tương Lai 1066', 'mega-event-1066-4349', 'approved', DATEADD(MINUTE, 11, DATEADD(HOUR, 2, DATEADD(DAY, -46, GETDATE()))), 10, DATEADD(MINUTE, 50, DATEADD(HOUR, 0, DATEADD(DAY, -15, GETDATE())))),
(1067, 4, 1, N'Summit Khởi nghiệp 1067', 'mega-event-1067-3546', 'approved', DATEADD(MINUTE, 31, DATEADD(HOUR, 7, DATEADD(DAY, -48, GETDATE()))), 10, DATEADD(MINUTE, 11, DATEADD(HOUR, 11, DATEADD(DAY, -52, GETDATE())))),
(1068, 6, 6, N'Lễ hội Thương mại 1068', 'mega-event-1068-2815', 'approved', DATEADD(MINUTE, 23, DATEADD(HOUR, 22, DATEADD(DAY, -18, GETDATE()))), 10, DATEADD(MINUTE, 20, DATEADD(HOUR, 11, DATEADD(DAY, -3, GETDATE())))),
(1069, 5, 6, N'Liveshow Công Nghệ 1069', 'mega-event-1069-1986', 'draft', DATEADD(MINUTE, 54, DATEADD(HOUR, 22, DATEADD(DAY, 87, GETDATE()))), 10, DATEADD(MINUTE, 37, DATEADD(HOUR, 8, DATEADD(DAY, -15, GETDATE())))),
(1070, 7, 1, N'Triển lãm Bất Động Sản 1070', 'mega-event-1070-8504', 'approved', DATEADD(MINUTE, 53, DATEADD(HOUR, 16, DATEADD(DAY, -18, GETDATE()))), 10, DATEADD(MINUTE, 44, DATEADD(HOUR, 19, DATEADD(DAY, -59, GETDATE())))),
(1071, 7, 5, N'Triển lãm Tương Lai 1071', 'mega-event-1071-5942', 'draft', DATEADD(MINUTE, 19, DATEADD(HOUR, 10, DATEADD(DAY, 34, GETDATE()))), 10, DATEADD(MINUTE, 14, DATEADD(HOUR, 7, DATEADD(DAY, -34, GETDATE())))),
(1072, 7, 6, N'Triển lãm Mùa Xuân 2026 1072', 'mega-event-1072-5302', 'draft', DATEADD(MINUTE, 22, DATEADD(HOUR, 11, DATEADD(DAY, -2, GETDATE()))), 10, DATEADD(MINUTE, 5, DATEADD(HOUR, 10, DATEADD(DAY, 0, GETDATE())))),
(1073, 7, 3, N'Liveshow Bất Động Sản 1073', 'mega-event-1073-9844', 'approved', DATEADD(MINUTE, 1, DATEADD(HOUR, 21, DATEADD(DAY, 68, GETDATE()))), 10, DATEADD(MINUTE, 13, DATEADD(HOUR, 14, DATEADD(DAY, -48, GETDATE())))),
(1074, 4, 3, N'Giao lưu Gaming 1074', 'mega-event-1074-9271', 'pending', DATEADD(MINUTE, 16, DATEADD(HOUR, 8, DATEADD(DAY, 75, GETDATE()))), 10, DATEADD(MINUTE, 8, DATEADD(HOUR, 2, DATEADD(DAY, -45, GETDATE())))),
(1075, 7, 1, N'Liveshow Gaming 1075', 'mega-event-1075-6573', 'approved', DATEADD(MINUTE, 12, DATEADD(HOUR, 6, DATEADD(DAY, 78, GETDATE()))), 10, DATEADD(MINUTE, 57, DATEADD(HOUR, 4, DATEADD(DAY, -57, GETDATE())))),
(1076, 7, 1, N'Giao lưu Mùa Xuân 2026 1076', 'mega-event-1076-2705', 'pending', DATEADD(MINUTE, 42, DATEADD(HOUR, 10, DATEADD(DAY, 76, GETDATE()))), 10, DATEADD(MINUTE, 48, DATEADD(HOUR, 12, DATEADD(DAY, -2, GETDATE())))),
(1077, 7, 1, N'Đêm nhạc Công Nghệ 1077', 'mega-event-1077-2941', 'approved', DATEADD(MINUTE, 15, DATEADD(HOUR, 15, DATEADD(DAY, -55, GETDATE()))), 10, DATEADD(MINUTE, 40, DATEADD(HOUR, 6, DATEADD(DAY, -45, GETDATE())))),
(1078, 8, 5, N'Webinar Mùa Xuân 2026 1078', 'mega-event-1078-1032', 'draft', DATEADD(MINUTE, 18, DATEADD(HOUR, 23, DATEADD(DAY, 51, GETDATE()))), 10, DATEADD(MINUTE, 1, DATEADD(HOUR, 13, DATEADD(DAY, -18, GETDATE())))),
(1079, 5, 3, N'Đêm nhạc Khởi nghiệp 1079', 'mega-event-1079-1817', 'pending', DATEADD(MINUTE, 19, DATEADD(HOUR, 1, DATEADD(DAY, 43, GETDATE()))), 10, DATEADD(MINUTE, 58, DATEADD(HOUR, 11, DATEADD(DAY, -13, GETDATE())))),
(1080, 8, 1, N'Đêm nhạc Gaming 1080', 'mega-event-1080-6239', 'approved', DATEADD(MINUTE, 36, DATEADD(HOUR, 21, DATEADD(DAY, 27, GETDATE()))), 10, DATEADD(MINUTE, 52, DATEADD(HOUR, 23, DATEADD(DAY, -48, GETDATE())))),
(1081, 4, 2, N'Đêm nhạc Thương mại 1081', 'mega-event-1081-9660', 'approved', DATEADD(MINUTE, 6, DATEADD(HOUR, 13, DATEADD(DAY, 3, GETDATE()))), 10, DATEADD(MINUTE, 0, DATEADD(HOUR, 10, DATEADD(DAY, -41, GETDATE())))),
(1082, 6, 3, N'Lễ hội Thương mại 1082', 'mega-event-1082-3672', 'approved', DATEADD(MINUTE, 35, DATEADD(HOUR, 15, DATEADD(DAY, -57, GETDATE()))), 10, DATEADD(MINUTE, 41, DATEADD(HOUR, 18, DATEADD(DAY, -49, GETDATE())))),
(1083, 8, 5, N'Liveshow Bất Động Sản 1083', 'mega-event-1083-9505', 'approved', DATEADD(MINUTE, 32, DATEADD(HOUR, 19, DATEADD(DAY, -19, GETDATE()))), 10, DATEADD(MINUTE, 19, DATEADD(HOUR, 15, DATEADD(DAY, -5, GETDATE())))),
(1084, 6, 3, N'Summit Thương mại 1084', 'mega-event-1084-5275', 'approved', DATEADD(MINUTE, 46, DATEADD(HOUR, 11, DATEADD(DAY, -25, GETDATE()))), 10, DATEADD(MINUTE, 20, DATEADD(HOUR, 20, DATEADD(DAY, -58, GETDATE())))),
(1085, 5, 1, N'Hội thảo Công Nghệ 1085', 'mega-event-1085-3303', 'approved', DATEADD(MINUTE, 15, DATEADD(HOUR, 13, DATEADD(DAY, 10, GETDATE()))), 10, DATEADD(MINUTE, 14, DATEADD(HOUR, 13, DATEADD(DAY, -29, GETDATE())))),
(1086, 7, 1, N'Đêm nhạc Công Nghệ 1086', 'mega-event-1086-6233', 'approved', DATEADD(MINUTE, 25, DATEADD(HOUR, 21, DATEADD(DAY, -23, GETDATE()))), 10, DATEADD(MINUTE, 21, DATEADD(HOUR, 1, DATEADD(DAY, -26, GETDATE())))),
(1087, 5, 5, N'Summit Nghệ Thuật 1087', 'mega-event-1087-2312', 'approved', DATEADD(MINUTE, 17, DATEADD(HOUR, 6, DATEADD(DAY, 14, GETDATE()))), 10, DATEADD(MINUTE, 43, DATEADD(HOUR, 15, DATEADD(DAY, -44, GETDATE())))),
(1088, 7, 4, N'Đêm nhạc Công Nghệ 1088', 'mega-event-1088-1872', 'approved', DATEADD(MINUTE, 51, DATEADD(HOUR, 3, DATEADD(DAY, -7, GETDATE()))), 10, DATEADD(MINUTE, 39, DATEADD(HOUR, 11, DATEADD(DAY, -52, GETDATE())))),
(1089, 8, 1, N'Đêm nhạc Khởi nghiệp 1089', 'mega-event-1089-5748', 'pending', DATEADD(MINUTE, 7, DATEADD(HOUR, 21, DATEADD(DAY, 59, GETDATE()))), 10, DATEADD(MINUTE, 51, DATEADD(HOUR, 21, DATEADD(DAY, -21, GETDATE())))),
(1090, 7, 2, N'Giao lưu Công Nghệ 1090', 'mega-event-1090-1803', 'approved', DATEADD(MINUTE, 51, DATEADD(HOUR, 5, DATEADD(DAY, -46, GETDATE()))), 10, DATEADD(MINUTE, 12, DATEADD(HOUR, 9, DATEADD(DAY, -33, GETDATE())))),
(1091, 4, 2, N'Liveshow Nghệ Thuật 1091', 'mega-event-1091-4014', 'approved', DATEADD(MINUTE, 40, DATEADD(HOUR, 4, DATEADD(DAY, 68, GETDATE()))), 10, DATEADD(MINUTE, 21, DATEADD(HOUR, 4, DATEADD(DAY, -42, GETDATE())))),
(1092, 6, 6, N'Workshop Mùa Xuân 2026 1092', 'mega-event-1092-6364', 'approved', DATEADD(MINUTE, 43, DATEADD(HOUR, 2, DATEADD(DAY, 69, GETDATE()))), 10, DATEADD(MINUTE, 16, DATEADD(HOUR, 6, DATEADD(DAY, -23, GETDATE())))),
(1093, 6, 2, N'Triển lãm Thương mại 1093', 'mega-event-1093-3019', 'approved', DATEADD(MINUTE, 55, DATEADD(HOUR, 12, DATEADD(DAY, 38, GETDATE()))), 10, DATEADD(MINUTE, 10, DATEADD(HOUR, 23, DATEADD(DAY, -17, GETDATE())))),
(1094, 7, 4, N'Webinar Thương mại 1094', 'mega-event-1094-2400', 'pending', DATEADD(MINUTE, 12, DATEADD(HOUR, 20, DATEADD(DAY, 39, GETDATE()))), 10, DATEADD(MINUTE, 56, DATEADD(HOUR, 13, DATEADD(DAY, -26, GETDATE())))),
(1095, 6, 5, N'Liveshow Mùa Xuân 2026 1095', 'mega-event-1095-5298', 'approved', DATEADD(MINUTE, 50, DATEADD(HOUR, 0, DATEADD(DAY, -41, GETDATE()))), 10, DATEADD(MINUTE, 31, DATEADD(HOUR, 17, DATEADD(DAY, -6, GETDATE())))),
(1096, 8, 6, N'Giải đấu Thương mại 1096', 'mega-event-1096-2027', 'approved', DATEADD(MINUTE, 4, DATEADD(HOUR, 23, DATEADD(DAY, 64, GETDATE()))), 10, DATEADD(MINUTE, 23, DATEADD(HOUR, 6, DATEADD(DAY, -36, GETDATE())))),
(1097, 7, 3, N'Giao lưu Mùa Xuân 2026 1097', 'mega-event-1097-1889', 'draft', DATEADD(MINUTE, 32, DATEADD(HOUR, 6, DATEADD(DAY, -56, GETDATE()))), 10, DATEADD(MINUTE, 4, DATEADD(HOUR, 3, DATEADD(DAY, -29, GETDATE())))),
(1098, 6, 4, N'Hội thảo Gaming 1098', 'mega-event-1098-4345', 'approved', DATEADD(MINUTE, 15, DATEADD(HOUR, 4, DATEADD(DAY, -43, GETDATE()))), 10, DATEADD(MINUTE, 11, DATEADD(HOUR, 22, DATEADD(DAY, -32, GETDATE())))),
(1099, 4, 5, N'Giao lưu Công Nghệ 1099', 'mega-event-1099-9997', 'pending', DATEADD(MINUTE, 11, DATEADD(HOUR, 19, DATEADD(DAY, -54, GETDATE()))), 10, DATEADD(MINUTE, 55, DATEADD(HOUR, 11, DATEADD(DAY, -53, GETDATE()))));
SET IDENTITY_INSERT Events OFF;
GO
SET IDENTITY_INSERT TicketTypes ON;
INSERT INTO TicketTypes (ticket_type_id, event_id, name, price, quantity, color_theme, created_at) VALUES
(1000, 1000, N'Standard', 200000, 500, '#3498DB', DATEADD(MINUTE, 59, DATEADD(HOUR, 8, DATEADD(DAY, -28, GETDATE())))),
(1001, 1000, N'VIP', 500000, 100, '#E74C3C', DATEADD(MINUTE, 11, DATEADD(HOUR, 14, DATEADD(DAY, -45, GETDATE())))),
(1002, 1000, N'Early Bird', 150000, 200, '#2ECC71', DATEADD(MINUTE, 48, DATEADD(HOUR, 3, DATEADD(DAY, -12, GETDATE())))),
(1003, 1001, N'Standard', 200000, 500, '#3498DB', DATEADD(MINUTE, 19, DATEADD(HOUR, 2, DATEADD(DAY, -26, GETDATE())))),
(1004, 1001, N'VIP', 500000, 100, '#E74C3C', DATEADD(MINUTE, 1, DATEADD(HOUR, 21, DATEADD(DAY, -27, GETDATE())))),
(1005, 1001, N'Early Bird', 150000, 200, '#2ECC71', DATEADD(MINUTE, 58, DATEADD(HOUR, 8, DATEADD(DAY, -8, GETDATE())))),
(1006, 1002, N'Standard', 200000, 500, '#3498DB', DATEADD(MINUTE, 36, DATEADD(HOUR, 13, DATEADD(DAY, -29, GETDATE())))),
(1007, 1002, N'VIP', 500000, 100, '#E74C3C', DATEADD(MINUTE, 4, DATEADD(HOUR, 11, DATEADD(DAY, -40, GETDATE())))),
(1008, 1002, N'Early Bird', 150000, 200, '#2ECC71', DATEADD(MINUTE, 17, DATEADD(HOUR, 23, DATEADD(DAY, -59, GETDATE())))),
(1009, 1003, N'Standard', 200000, 500, '#3498DB', DATEADD(MINUTE, 29, DATEADD(HOUR, 7, DATEADD(DAY, -25, GETDATE())))),
(1010, 1003, N'VIP', 500000, 100, '#E74C3C', DATEADD(MINUTE, 12, DATEADD(HOUR, 1, DATEADD(DAY, -55, GETDATE())))),
(1011, 1003, N'Early Bird', 150000, 200, '#2ECC71', DATEADD(MINUTE, 58, DATEADD(HOUR, 1, DATEADD(DAY, -36, GETDATE())))),
(1012, 1004, N'Standard', 200000, 500, '#3498DB', DATEADD(MINUTE, 22, DATEADD(HOUR, 9, DATEADD(DAY, 0, GETDATE())))),
(1013, 1004, N'VIP', 500000, 100, '#E74C3C', DATEADD(MINUTE, 42, DATEADD(HOUR, 4, DATEADD(DAY, -47, GETDATE())))),
(1014, 1004, N'Early Bird', 150000, 200, '#2ECC71', DATEADD(MINUTE, 49, DATEADD(HOUR, 17, DATEADD(DAY, -4, GETDATE())))),
(1015, 1005, N'Standard', 200000, 500, '#3498DB', DATEADD(MINUTE, 57, DATEADD(HOUR, 18, DATEADD(DAY, -5, GETDATE())))),
(1016, 1005, N'VIP', 500000, 100, '#E74C3C', DATEADD(MINUTE, 35, DATEADD(HOUR, 22, DATEADD(DAY, -28, GETDATE())))),
(1017, 1005, N'Early Bird', 150000, 200, '#2ECC71', DATEADD(MINUTE, 38, DATEADD(HOUR, 20, DATEADD(DAY, -47, GETDATE())))),
(1018, 1006, N'Standard', 200000, 500, '#3498DB', DATEADD(MINUTE, 58, DATEADD(HOUR, 8, DATEADD(DAY, -6, GETDATE())))),
(1019, 1006, N'VIP', 500000, 100, '#E74C3C', DATEADD(MINUTE, 27, DATEADD(HOUR, 6, DATEADD(DAY, -43, GETDATE())))),
(1020, 1006, N'Early Bird', 150000, 200, '#2ECC71', DATEADD(MINUTE, 35, DATEADD(HOUR, 10, DATEADD(DAY, -28, GETDATE())))),
(1021, 1007, N'Standard', 200000, 500, '#3498DB', DATEADD(MINUTE, 58, DATEADD(HOUR, 8, DATEADD(DAY, -42, GETDATE())))),
(1022, 1007, N'VIP', 500000, 100, '#E74C3C', DATEADD(MINUTE, 18, DATEADD(HOUR, 3, DATEADD(DAY, -43, GETDATE())))),
(1023, 1007, N'Early Bird', 150000, 200, '#2ECC71', DATEADD(MINUTE, 0, DATEADD(HOUR, 14, DATEADD(DAY, -28, GETDATE())))),
(1024, 1008, N'Standard', 200000, 500, '#3498DB', DATEADD(MINUTE, 48, DATEADD(HOUR, 14, DATEADD(DAY, -34, GETDATE())))),
(1025, 1008, N'VIP', 500000, 100, '#E74C3C', DATEADD(MINUTE, 50, DATEADD(HOUR, 22, DATEADD(DAY, -37, GETDATE())))),
(1026, 1008, N'Early Bird', 150000, 200, '#2ECC71', DATEADD(MINUTE, 30, DATEADD(HOUR, 23, DATEADD(DAY, -26, GETDATE())))),
(1027, 1009, N'Standard', 200000, 500, '#3498DB', DATEADD(MINUTE, 38, DATEADD(HOUR, 21, DATEADD(DAY, -56, GETDATE())))),
(1028, 1009, N'VIP', 500000, 100, '#E74C3C', DATEADD(MINUTE, 30, DATEADD(HOUR, 18, DATEADD(DAY, -45, GETDATE())))),
(1029, 1009, N'Early Bird', 150000, 200, '#2ECC71', DATEADD(MINUTE, 4, DATEADD(HOUR, 15, DATEADD(DAY, -51, GETDATE())))),
(1030, 1010, N'Standard', 200000, 500, '#3498DB', DATEADD(MINUTE, 45, DATEADD(HOUR, 4, DATEADD(DAY, -7, GETDATE())))),
(1031, 1010, N'VIP', 500000, 100, '#E74C3C', DATEADD(MINUTE, 38, DATEADD(HOUR, 3, DATEADD(DAY, -51, GETDATE())))),
(1032, 1010, N'Early Bird', 150000, 200, '#2ECC71', DATEADD(MINUTE, 47, DATEADD(HOUR, 16, DATEADD(DAY, -28, GETDATE())))),
(1033, 1011, N'Standard', 200000, 500, '#3498DB', DATEADD(MINUTE, 27, DATEADD(HOUR, 11, DATEADD(DAY, -24, GETDATE())))),
(1034, 1011, N'VIP', 500000, 100, '#E74C3C', DATEADD(MINUTE, 44, DATEADD(HOUR, 9, DATEADD(DAY, -58, GETDATE())))),
(1035, 1011, N'Early Bird', 150000, 200, '#2ECC71', DATEADD(MINUTE, 13, DATEADD(HOUR, 18, DATEADD(DAY, -19, GETDATE())))),
(1036, 1012, N'Standard', 200000, 500, '#3498DB', DATEADD(MINUTE, 37, DATEADD(HOUR, 18, DATEADD(DAY, -41, GETDATE())))),
(1037, 1012, N'VIP', 500000, 100, '#E74C3C', DATEADD(MINUTE, 13, DATEADD(HOUR, 4, DATEADD(DAY, -34, GETDATE())))),
(1038, 1012, N'Early Bird', 150000, 200, '#2ECC71', DATEADD(MINUTE, 16, DATEADD(HOUR, 13, DATEADD(DAY, -50, GETDATE())))),
(1039, 1013, N'Standard', 200000, 500, '#3498DB', DATEADD(MINUTE, 0, DATEADD(HOUR, 21, DATEADD(DAY, -39, GETDATE())))),
(1040, 1013, N'VIP', 500000, 100, '#E74C3C', DATEADD(MINUTE, 58, DATEADD(HOUR, 15, DATEADD(DAY, -43, GETDATE())))),
(1041, 1013, N'Early Bird', 150000, 200, '#2ECC71', DATEADD(MINUTE, 30, DATEADD(HOUR, 13, DATEADD(DAY, -55, GETDATE())))),
(1042, 1014, N'Standard', 200000, 500, '#3498DB', DATEADD(MINUTE, 56, DATEADD(HOUR, 15, DATEADD(DAY, -13, GETDATE())))),
(1043, 1014, N'VIP', 500000, 100, '#E74C3C', DATEADD(MINUTE, 53, DATEADD(HOUR, 7, DATEADD(DAY, -29, GETDATE())))),
(1044, 1014, N'Early Bird', 150000, 200, '#2ECC71', DATEADD(MINUTE, 16, DATEADD(HOUR, 13, DATEADD(DAY, -46, GETDATE())))),
(1045, 1015, N'Standard', 200000, 500, '#3498DB', DATEADD(MINUTE, 12, DATEADD(HOUR, 4, DATEADD(DAY, -10, GETDATE())))),
(1046, 1015, N'VIP', 500000, 100, '#E74C3C', DATEADD(MINUTE, 42, DATEADD(HOUR, 3, DATEADD(DAY, -33, GETDATE())))),
(1047, 1015, N'Early Bird', 150000, 200, '#2ECC71', DATEADD(MINUTE, 2, DATEADD(HOUR, 8, DATEADD(DAY, -22, GETDATE())))),
(1048, 1016, N'Standard', 200000, 500, '#3498DB', DATEADD(MINUTE, 54, DATEADD(HOUR, 13, DATEADD(DAY, -34, GETDATE())))),
(1049, 1016, N'VIP', 500000, 100, '#E74C3C', DATEADD(MINUTE, 52, DATEADD(HOUR, 23, DATEADD(DAY, -43, GETDATE())))),
(1050, 1016, N'Early Bird', 150000, 200, '#2ECC71', DATEADD(MINUTE, 13, DATEADD(HOUR, 23, DATEADD(DAY, -19, GETDATE())))),
(1051, 1017, N'Standard', 200000, 500, '#3498DB', DATEADD(MINUTE, 47, DATEADD(HOUR, 14, DATEADD(DAY, -48, GETDATE())))),
(1052, 1017, N'VIP', 500000, 100, '#E74C3C', DATEADD(MINUTE, 1, DATEADD(HOUR, 7, DATEADD(DAY, -3, GETDATE())))),
(1053, 1017, N'Early Bird', 150000, 200, '#2ECC71', DATEADD(MINUTE, 11, DATEADD(HOUR, 17, DATEADD(DAY, -31, GETDATE())))),
(1054, 1018, N'Standard', 200000, 500, '#3498DB', DATEADD(MINUTE, 59, DATEADD(HOUR, 23, DATEADD(DAY, -16, GETDATE())))),
(1055, 1018, N'VIP', 500000, 100, '#E74C3C', DATEADD(MINUTE, 40, DATEADD(HOUR, 22, DATEADD(DAY, -39, GETDATE())))),
(1056, 1018, N'Early Bird', 150000, 200, '#2ECC71', DATEADD(MINUTE, 2, DATEADD(HOUR, 7, DATEADD(DAY, -53, GETDATE())))),
(1057, 1019, N'Standard', 200000, 500, '#3498DB', DATEADD(MINUTE, 54, DATEADD(HOUR, 7, DATEADD(DAY, -41, GETDATE())))),
(1058, 1019, N'VIP', 500000, 100, '#E74C3C', DATEADD(MINUTE, 53, DATEADD(HOUR, 1, DATEADD(DAY, -19, GETDATE())))),
(1059, 1019, N'Early Bird', 150000, 200, '#2ECC71', DATEADD(MINUTE, 38, DATEADD(HOUR, 10, DATEADD(DAY, -18, GETDATE())))),
(1060, 1020, N'Standard', 200000, 500, '#3498DB', DATEADD(MINUTE, 12, DATEADD(HOUR, 14, DATEADD(DAY, -56, GETDATE())))),
(1061, 1020, N'VIP', 500000, 100, '#E74C3C', DATEADD(MINUTE, 3, DATEADD(HOUR, 10, DATEADD(DAY, -20, GETDATE())))),
(1062, 1020, N'Early Bird', 150000, 200, '#2ECC71', DATEADD(MINUTE, 38, DATEADD(HOUR, 22, DATEADD(DAY, -24, GETDATE())))),
(1063, 1021, N'Standard', 200000, 500, '#3498DB', DATEADD(MINUTE, 29, DATEADD(HOUR, 11, DATEADD(DAY, -53, GETDATE())))),
(1064, 1021, N'VIP', 500000, 100, '#E74C3C', DATEADD(MINUTE, 52, DATEADD(HOUR, 16, DATEADD(DAY, -34, GETDATE())))),
(1065, 1021, N'Early Bird', 150000, 200, '#2ECC71', DATEADD(MINUTE, 13, DATEADD(HOUR, 12, DATEADD(DAY, -5, GETDATE())))),
(1066, 1022, N'Standard', 200000, 500, '#3498DB', DATEADD(MINUTE, 33, DATEADD(HOUR, 4, DATEADD(DAY, -51, GETDATE())))),
(1067, 1022, N'VIP', 500000, 100, '#E74C3C', DATEADD(MINUTE, 9, DATEADD(HOUR, 14, DATEADD(DAY, -38, GETDATE())))),
(1068, 1022, N'Early Bird', 150000, 200, '#2ECC71', DATEADD(MINUTE, 48, DATEADD(HOUR, 22, DATEADD(DAY, -52, GETDATE())))),
(1069, 1023, N'Standard', 200000, 500, '#3498DB', DATEADD(MINUTE, 18, DATEADD(HOUR, 20, DATEADD(DAY, -8, GETDATE())))),
(1070, 1023, N'VIP', 500000, 100, '#E74C3C', DATEADD(MINUTE, 11, DATEADD(HOUR, 20, DATEADD(DAY, -5, GETDATE())))),
(1071, 1023, N'Early Bird', 150000, 200, '#2ECC71', DATEADD(MINUTE, 55, DATEADD(HOUR, 16, DATEADD(DAY, -36, GETDATE())))),
(1072, 1024, N'Standard', 200000, 500, '#3498DB', DATEADD(MINUTE, 58, DATEADD(HOUR, 11, DATEADD(DAY, -15, GETDATE())))),
(1073, 1024, N'VIP', 500000, 100, '#E74C3C', DATEADD(MINUTE, 49, DATEADD(HOUR, 20, DATEADD(DAY, -47, GETDATE())))),
(1074, 1024, N'Early Bird', 150000, 200, '#2ECC71', DATEADD(MINUTE, 5, DATEADD(HOUR, 19, DATEADD(DAY, -28, GETDATE())))),
(1075, 1025, N'Standard', 200000, 500, '#3498DB', DATEADD(MINUTE, 57, DATEADD(HOUR, 12, DATEADD(DAY, -12, GETDATE())))),
(1076, 1025, N'VIP', 500000, 100, '#E74C3C', DATEADD(MINUTE, 21, DATEADD(HOUR, 17, DATEADD(DAY, -23, GETDATE())))),
(1077, 1025, N'Early Bird', 150000, 200, '#2ECC71', DATEADD(MINUTE, 48, DATEADD(HOUR, 7, DATEADD(DAY, -51, GETDATE())))),
(1078, 1026, N'Standard', 200000, 500, '#3498DB', DATEADD(MINUTE, 9, DATEADD(HOUR, 14, DATEADD(DAY, -57, GETDATE())))),
(1079, 1026, N'VIP', 500000, 100, '#E74C3C', DATEADD(MINUTE, 20, DATEADD(HOUR, 16, DATEADD(DAY, -28, GETDATE())))),
(1080, 1026, N'Early Bird', 150000, 200, '#2ECC71', DATEADD(MINUTE, 23, DATEADD(HOUR, 4, DATEADD(DAY, -59, GETDATE())))),
(1081, 1027, N'Standard', 200000, 500, '#3498DB', DATEADD(MINUTE, 0, DATEADD(HOUR, 13, DATEADD(DAY, -23, GETDATE())))),
(1082, 1027, N'VIP', 500000, 100, '#E74C3C', DATEADD(MINUTE, 47, DATEADD(HOUR, 18, DATEADD(DAY, -6, GETDATE())))),
(1083, 1027, N'Early Bird', 150000, 200, '#2ECC71', DATEADD(MINUTE, 11, DATEADD(HOUR, 9, DATEADD(DAY, -43, GETDATE())))),
(1084, 1028, N'Standard', 200000, 500, '#3498DB', DATEADD(MINUTE, 11, DATEADD(HOUR, 16, DATEADD(DAY, -53, GETDATE())))),
(1085, 1028, N'VIP', 500000, 100, '#E74C3C', DATEADD(MINUTE, 45, DATEADD(HOUR, 9, DATEADD(DAY, -39, GETDATE())))),
(1086, 1028, N'Early Bird', 150000, 200, '#2ECC71', DATEADD(MINUTE, 31, DATEADD(HOUR, 17, DATEADD(DAY, -28, GETDATE())))),
(1087, 1029, N'Standard', 200000, 500, '#3498DB', DATEADD(MINUTE, 26, DATEADD(HOUR, 4, DATEADD(DAY, -1, GETDATE())))),
(1088, 1029, N'VIP', 500000, 100, '#E74C3C', DATEADD(MINUTE, 13, DATEADD(HOUR, 10, DATEADD(DAY, -18, GETDATE())))),
(1089, 1029, N'Early Bird', 150000, 200, '#2ECC71', DATEADD(MINUTE, 4, DATEADD(HOUR, 0, DATEADD(DAY, -2, GETDATE())))),
(1090, 1030, N'Standard', 200000, 500, '#3498DB', DATEADD(MINUTE, 0, DATEADD(HOUR, 17, DATEADD(DAY, -55, GETDATE())))),
(1091, 1030, N'VIP', 500000, 100, '#E74C3C', DATEADD(MINUTE, 8, DATEADD(HOUR, 22, DATEADD(DAY, -14, GETDATE())))),
(1092, 1030, N'Early Bird', 150000, 200, '#2ECC71', DATEADD(MINUTE, 29, DATEADD(HOUR, 8, DATEADD(DAY, -45, GETDATE())))),
(1093, 1031, N'Standard', 200000, 500, '#3498DB', DATEADD(MINUTE, 8, DATEADD(HOUR, 18, DATEADD(DAY, -45, GETDATE())))),
(1094, 1031, N'VIP', 500000, 100, '#E74C3C', DATEADD(MINUTE, 28, DATEADD(HOUR, 1, DATEADD(DAY, -35, GETDATE())))),
(1095, 1031, N'Early Bird', 150000, 200, '#2ECC71', DATEADD(MINUTE, 21, DATEADD(HOUR, 5, DATEADD(DAY, -13, GETDATE())))),
(1096, 1032, N'Standard', 200000, 500, '#3498DB', DATEADD(MINUTE, 16, DATEADD(HOUR, 2, DATEADD(DAY, -59, GETDATE())))),
(1097, 1032, N'VIP', 500000, 100, '#E74C3C', DATEADD(MINUTE, 25, DATEADD(HOUR, 20, DATEADD(DAY, -22, GETDATE())))),
(1098, 1032, N'Early Bird', 150000, 200, '#2ECC71', DATEADD(MINUTE, 29, DATEADD(HOUR, 5, DATEADD(DAY, -8, GETDATE())))),
(1099, 1033, N'Standard', 200000, 500, '#3498DB', DATEADD(MINUTE, 24, DATEADD(HOUR, 4, DATEADD(DAY, -42, GETDATE())))),
(1100, 1033, N'VIP', 500000, 100, '#E74C3C', DATEADD(MINUTE, 29, DATEADD(HOUR, 14, DATEADD(DAY, -33, GETDATE())))),
(1101, 1033, N'Early Bird', 150000, 200, '#2ECC71', DATEADD(MINUTE, 25, DATEADD(HOUR, 18, DATEADD(DAY, -42, GETDATE())))),
(1102, 1034, N'Standard', 200000, 500, '#3498DB', DATEADD(MINUTE, 4, DATEADD(HOUR, 10, DATEADD(DAY, -42, GETDATE())))),
(1103, 1034, N'VIP', 500000, 100, '#E74C3C', DATEADD(MINUTE, 54, DATEADD(HOUR, 20, DATEADD(DAY, -24, GETDATE())))),
(1104, 1034, N'Early Bird', 150000, 200, '#2ECC71', DATEADD(MINUTE, 52, DATEADD(HOUR, 21, DATEADD(DAY, -46, GETDATE())))),
(1105, 1035, N'Standard', 200000, 500, '#3498DB', DATEADD(MINUTE, 22, DATEADD(HOUR, 4, DATEADD(DAY, -52, GETDATE())))),
(1106, 1035, N'VIP', 500000, 100, '#E74C3C', DATEADD(MINUTE, 14, DATEADD(HOUR, 13, DATEADD(DAY, -9, GETDATE())))),
(1107, 1035, N'Early Bird', 150000, 200, '#2ECC71', DATEADD(MINUTE, 51, DATEADD(HOUR, 15, DATEADD(DAY, -14, GETDATE())))),
(1108, 1036, N'Standard', 200000, 500, '#3498DB', DATEADD(MINUTE, 28, DATEADD(HOUR, 18, DATEADD(DAY, -20, GETDATE())))),
(1109, 1036, N'VIP', 500000, 100, '#E74C3C', DATEADD(MINUTE, 17, DATEADD(HOUR, 16, DATEADD(DAY, -28, GETDATE())))),
(1110, 1036, N'Early Bird', 150000, 200, '#2ECC71', DATEADD(MINUTE, 4, DATEADD(HOUR, 13, DATEADD(DAY, -6, GETDATE())))),
(1111, 1037, N'Standard', 200000, 500, '#3498DB', DATEADD(MINUTE, 48, DATEADD(HOUR, 9, DATEADD(DAY, -56, GETDATE())))),
(1112, 1037, N'VIP', 500000, 100, '#E74C3C', DATEADD(MINUTE, 56, DATEADD(HOUR, 21, DATEADD(DAY, -3, GETDATE())))),
(1113, 1037, N'Early Bird', 150000, 200, '#2ECC71', DATEADD(MINUTE, 3, DATEADD(HOUR, 8, DATEADD(DAY, -21, GETDATE())))),
(1114, 1038, N'Standard', 200000, 500, '#3498DB', DATEADD(MINUTE, 39, DATEADD(HOUR, 22, DATEADD(DAY, -3, GETDATE())))),
(1115, 1038, N'VIP', 500000, 100, '#E74C3C', DATEADD(MINUTE, 52, DATEADD(HOUR, 11, DATEADD(DAY, -45, GETDATE())))),
(1116, 1038, N'Early Bird', 150000, 200, '#2ECC71', DATEADD(MINUTE, 4, DATEADD(HOUR, 16, DATEADD(DAY, -20, GETDATE())))),
(1117, 1039, N'Standard', 200000, 500, '#3498DB', DATEADD(MINUTE, 39, DATEADD(HOUR, 21, DATEADD(DAY, -59, GETDATE())))),
(1118, 1039, N'VIP', 500000, 100, '#E74C3C', DATEADD(MINUTE, 11, DATEADD(HOUR, 3, DATEADD(DAY, -48, GETDATE())))),
(1119, 1039, N'Early Bird', 150000, 200, '#2ECC71', DATEADD(MINUTE, 56, DATEADD(HOUR, 20, DATEADD(DAY, -57, GETDATE())))),
(1120, 1040, N'Standard', 200000, 500, '#3498DB', DATEADD(MINUTE, 26, DATEADD(HOUR, 9, DATEADD(DAY, -17, GETDATE())))),
(1121, 1040, N'VIP', 500000, 100, '#E74C3C', DATEADD(MINUTE, 21, DATEADD(HOUR, 11, DATEADD(DAY, -32, GETDATE())))),
(1122, 1040, N'Early Bird', 150000, 200, '#2ECC71', DATEADD(MINUTE, 19, DATEADD(HOUR, 14, DATEADD(DAY, -57, GETDATE())))),
(1123, 1041, N'Standard', 200000, 500, '#3498DB', DATEADD(MINUTE, 59, DATEADD(HOUR, 10, DATEADD(DAY, -28, GETDATE())))),
(1124, 1041, N'VIP', 500000, 100, '#E74C3C', DATEADD(MINUTE, 21, DATEADD(HOUR, 23, DATEADD(DAY, -3, GETDATE())))),
(1125, 1041, N'Early Bird', 150000, 200, '#2ECC71', DATEADD(MINUTE, 49, DATEADD(HOUR, 17, DATEADD(DAY, -51, GETDATE())))),
(1126, 1042, N'Standard', 200000, 500, '#3498DB', DATEADD(MINUTE, 28, DATEADD(HOUR, 17, DATEADD(DAY, -49, GETDATE())))),
(1127, 1042, N'VIP', 500000, 100, '#E74C3C', DATEADD(MINUTE, 1, DATEADD(HOUR, 10, DATEADD(DAY, -58, GETDATE())))),
(1128, 1042, N'Early Bird', 150000, 200, '#2ECC71', DATEADD(MINUTE, 8, DATEADD(HOUR, 15, DATEADD(DAY, -52, GETDATE())))),
(1129, 1043, N'Standard', 200000, 500, '#3498DB', DATEADD(MINUTE, 1, DATEADD(HOUR, 12, DATEADD(DAY, -26, GETDATE())))),
(1130, 1043, N'VIP', 500000, 100, '#E74C3C', DATEADD(MINUTE, 55, DATEADD(HOUR, 5, DATEADD(DAY, -53, GETDATE())))),
(1131, 1043, N'Early Bird', 150000, 200, '#2ECC71', DATEADD(MINUTE, 14, DATEADD(HOUR, 22, DATEADD(DAY, -6, GETDATE())))),
(1132, 1044, N'Standard', 200000, 500, '#3498DB', DATEADD(MINUTE, 15, DATEADD(HOUR, 21, DATEADD(DAY, -22, GETDATE())))),
(1133, 1044, N'VIP', 500000, 100, '#E74C3C', DATEADD(MINUTE, 39, DATEADD(HOUR, 15, DATEADD(DAY, -57, GETDATE())))),
(1134, 1044, N'Early Bird', 150000, 200, '#2ECC71', DATEADD(MINUTE, 7, DATEADD(HOUR, 19, DATEADD(DAY, -18, GETDATE())))),
(1135, 1045, N'Standard', 200000, 500, '#3498DB', DATEADD(MINUTE, 41, DATEADD(HOUR, 23, DATEADD(DAY, -17, GETDATE())))),
(1136, 1045, N'VIP', 500000, 100, '#E74C3C', DATEADD(MINUTE, 2, DATEADD(HOUR, 16, DATEADD(DAY, -14, GETDATE())))),
(1137, 1045, N'Early Bird', 150000, 200, '#2ECC71', DATEADD(MINUTE, 17, DATEADD(HOUR, 10, DATEADD(DAY, -33, GETDATE())))),
(1138, 1046, N'Standard', 200000, 500, '#3498DB', DATEADD(MINUTE, 15, DATEADD(HOUR, 7, DATEADD(DAY, -10, GETDATE())))),
(1139, 1046, N'VIP', 500000, 100, '#E74C3C', DATEADD(MINUTE, 25, DATEADD(HOUR, 19, DATEADD(DAY, -19, GETDATE())))),
(1140, 1046, N'Early Bird', 150000, 200, '#2ECC71', DATEADD(MINUTE, 4, DATEADD(HOUR, 9, DATEADD(DAY, -36, GETDATE())))),
(1141, 1047, N'Standard', 200000, 500, '#3498DB', DATEADD(MINUTE, 48, DATEADD(HOUR, 15, DATEADD(DAY, -49, GETDATE())))),
(1142, 1047, N'VIP', 500000, 100, '#E74C3C', DATEADD(MINUTE, 5, DATEADD(HOUR, 19, DATEADD(DAY, -33, GETDATE())))),
(1143, 1047, N'Early Bird', 150000, 200, '#2ECC71', DATEADD(MINUTE, 49, DATEADD(HOUR, 5, DATEADD(DAY, -38, GETDATE())))),
(1144, 1048, N'Standard', 200000, 500, '#3498DB', DATEADD(MINUTE, 59, DATEADD(HOUR, 0, DATEADD(DAY, -49, GETDATE())))),
(1145, 1048, N'VIP', 500000, 100, '#E74C3C', DATEADD(MINUTE, 53, DATEADD(HOUR, 8, DATEADD(DAY, -52, GETDATE())))),
(1146, 1048, N'Early Bird', 150000, 200, '#2ECC71', DATEADD(MINUTE, 39, DATEADD(HOUR, 15, DATEADD(DAY, -4, GETDATE())))),
(1147, 1049, N'Standard', 200000, 500, '#3498DB', DATEADD(MINUTE, 27, DATEADD(HOUR, 20, DATEADD(DAY, -26, GETDATE())))),
(1148, 1049, N'VIP', 500000, 100, '#E74C3C', DATEADD(MINUTE, 56, DATEADD(HOUR, 6, DATEADD(DAY, -1, GETDATE())))),
(1149, 1049, N'Early Bird', 150000, 200, '#2ECC71', DATEADD(MINUTE, 27, DATEADD(HOUR, 14, DATEADD(DAY, -22, GETDATE())))),
(1150, 1050, N'Standard', 200000, 500, '#3498DB', DATEADD(MINUTE, 10, DATEADD(HOUR, 15, DATEADD(DAY, -18, GETDATE())))),
(1151, 1050, N'VIP', 500000, 100, '#E74C3C', DATEADD(MINUTE, 51, DATEADD(HOUR, 10, DATEADD(DAY, -52, GETDATE())))),
(1152, 1050, N'Early Bird', 150000, 200, '#2ECC71', DATEADD(MINUTE, 8, DATEADD(HOUR, 10, DATEADD(DAY, -31, GETDATE())))),
(1153, 1051, N'Standard', 200000, 500, '#3498DB', DATEADD(MINUTE, 19, DATEADD(HOUR, 18, DATEADD(DAY, -43, GETDATE())))),
(1154, 1051, N'VIP', 500000, 100, '#E74C3C', DATEADD(MINUTE, 19, DATEADD(HOUR, 16, DATEADD(DAY, -42, GETDATE())))),
(1155, 1051, N'Early Bird', 150000, 200, '#2ECC71', DATEADD(MINUTE, 14, DATEADD(HOUR, 5, DATEADD(DAY, -31, GETDATE())))),
(1156, 1052, N'Standard', 200000, 500, '#3498DB', DATEADD(MINUTE, 35, DATEADD(HOUR, 12, DATEADD(DAY, -19, GETDATE())))),
(1157, 1052, N'VIP', 500000, 100, '#E74C3C', DATEADD(MINUTE, 33, DATEADD(HOUR, 4, DATEADD(DAY, -7, GETDATE())))),
(1158, 1052, N'Early Bird', 150000, 200, '#2ECC71', DATEADD(MINUTE, 20, DATEADD(HOUR, 23, DATEADD(DAY, -48, GETDATE())))),
(1159, 1053, N'Standard', 200000, 500, '#3498DB', DATEADD(MINUTE, 8, DATEADD(HOUR, 10, DATEADD(DAY, -37, GETDATE())))),
(1160, 1053, N'VIP', 500000, 100, '#E74C3C', DATEADD(MINUTE, 57, DATEADD(HOUR, 21, DATEADD(DAY, -58, GETDATE())))),
(1161, 1053, N'Early Bird', 150000, 200, '#2ECC71', DATEADD(MINUTE, 12, DATEADD(HOUR, 12, DATEADD(DAY, -43, GETDATE())))),
(1162, 1054, N'Standard', 200000, 500, '#3498DB', DATEADD(MINUTE, 17, DATEADD(HOUR, 19, DATEADD(DAY, -25, GETDATE())))),
(1163, 1054, N'VIP', 500000, 100, '#E74C3C', DATEADD(MINUTE, 2, DATEADD(HOUR, 13, DATEADD(DAY, -48, GETDATE())))),
(1164, 1054, N'Early Bird', 150000, 200, '#2ECC71', DATEADD(MINUTE, 35, DATEADD(HOUR, 12, DATEADD(DAY, -41, GETDATE())))),
(1165, 1055, N'Standard', 200000, 500, '#3498DB', DATEADD(MINUTE, 20, DATEADD(HOUR, 15, DATEADD(DAY, -44, GETDATE())))),
(1166, 1055, N'VIP', 500000, 100, '#E74C3C', DATEADD(MINUTE, 9, DATEADD(HOUR, 7, DATEADD(DAY, -24, GETDATE())))),
(1167, 1055, N'Early Bird', 150000, 200, '#2ECC71', DATEADD(MINUTE, 58, DATEADD(HOUR, 2, DATEADD(DAY, -54, GETDATE())))),
(1168, 1056, N'Standard', 200000, 500, '#3498DB', DATEADD(MINUTE, 4, DATEADD(HOUR, 16, DATEADD(DAY, -49, GETDATE())))),
(1169, 1056, N'VIP', 500000, 100, '#E74C3C', DATEADD(MINUTE, 42, DATEADD(HOUR, 9, DATEADD(DAY, -14, GETDATE())))),
(1170, 1056, N'Early Bird', 150000, 200, '#2ECC71', DATEADD(MINUTE, 10, DATEADD(HOUR, 5, DATEADD(DAY, -1, GETDATE())))),
(1171, 1057, N'Standard', 200000, 500, '#3498DB', DATEADD(MINUTE, 20, DATEADD(HOUR, 15, DATEADD(DAY, -60, GETDATE())))),
(1172, 1057, N'VIP', 500000, 100, '#E74C3C', DATEADD(MINUTE, 53, DATEADD(HOUR, 12, DATEADD(DAY, -38, GETDATE())))),
(1173, 1057, N'Early Bird', 150000, 200, '#2ECC71', DATEADD(MINUTE, 43, DATEADD(HOUR, 16, DATEADD(DAY, -14, GETDATE())))),
(1174, 1058, N'Standard', 200000, 500, '#3498DB', DATEADD(MINUTE, 50, DATEADD(HOUR, 1, DATEADD(DAY, -24, GETDATE())))),
(1175, 1058, N'VIP', 500000, 100, '#E74C3C', DATEADD(MINUTE, 43, DATEADD(HOUR, 21, DATEADD(DAY, -47, GETDATE())))),
(1176, 1058, N'Early Bird', 150000, 200, '#2ECC71', DATEADD(MINUTE, 3, DATEADD(HOUR, 4, DATEADD(DAY, 0, GETDATE())))),
(1177, 1059, N'Standard', 200000, 500, '#3498DB', DATEADD(MINUTE, 36, DATEADD(HOUR, 5, DATEADD(DAY, -34, GETDATE())))),
(1178, 1059, N'VIP', 500000, 100, '#E74C3C', DATEADD(MINUTE, 23, DATEADD(HOUR, 22, DATEADD(DAY, -48, GETDATE())))),
(1179, 1059, N'Early Bird', 150000, 200, '#2ECC71', DATEADD(MINUTE, 11, DATEADD(HOUR, 19, DATEADD(DAY, -57, GETDATE())))),
(1180, 1060, N'Standard', 200000, 500, '#3498DB', DATEADD(MINUTE, 39, DATEADD(HOUR, 21, DATEADD(DAY, -41, GETDATE())))),
(1181, 1060, N'VIP', 500000, 100, '#E74C3C', DATEADD(MINUTE, 46, DATEADD(HOUR, 14, DATEADD(DAY, -18, GETDATE())))),
(1182, 1060, N'Early Bird', 150000, 200, '#2ECC71', DATEADD(MINUTE, 47, DATEADD(HOUR, 20, DATEADD(DAY, -42, GETDATE())))),
(1183, 1061, N'Standard', 200000, 500, '#3498DB', DATEADD(MINUTE, 18, DATEADD(HOUR, 22, DATEADD(DAY, -7, GETDATE())))),
(1184, 1061, N'VIP', 500000, 100, '#E74C3C', DATEADD(MINUTE, 29, DATEADD(HOUR, 19, DATEADD(DAY, -18, GETDATE())))),
(1185, 1061, N'Early Bird', 150000, 200, '#2ECC71', DATEADD(MINUTE, 8, DATEADD(HOUR, 22, DATEADD(DAY, -22, GETDATE())))),
(1186, 1062, N'Standard', 200000, 500, '#3498DB', DATEADD(MINUTE, 20, DATEADD(HOUR, 21, DATEADD(DAY, -17, GETDATE())))),
(1187, 1062, N'VIP', 500000, 100, '#E74C3C', DATEADD(MINUTE, 19, DATEADD(HOUR, 5, DATEADD(DAY, -17, GETDATE())))),
(1188, 1062, N'Early Bird', 150000, 200, '#2ECC71', DATEADD(MINUTE, 44, DATEADD(HOUR, 20, DATEADD(DAY, -21, GETDATE())))),
(1189, 1063, N'Standard', 200000, 500, '#3498DB', DATEADD(MINUTE, 52, DATEADD(HOUR, 17, DATEADD(DAY, -53, GETDATE())))),
(1190, 1063, N'VIP', 500000, 100, '#E74C3C', DATEADD(MINUTE, 49, DATEADD(HOUR, 6, DATEADD(DAY, -58, GETDATE())))),
(1191, 1063, N'Early Bird', 150000, 200, '#2ECC71', DATEADD(MINUTE, 51, DATEADD(HOUR, 7, DATEADD(DAY, -44, GETDATE())))),
(1192, 1064, N'Standard', 200000, 500, '#3498DB', DATEADD(MINUTE, 27, DATEADD(HOUR, 15, DATEADD(DAY, -14, GETDATE())))),
(1193, 1064, N'VIP', 500000, 100, '#E74C3C', DATEADD(MINUTE, 51, DATEADD(HOUR, 12, DATEADD(DAY, -14, GETDATE())))),
(1194, 1064, N'Early Bird', 150000, 200, '#2ECC71', DATEADD(MINUTE, 16, DATEADD(HOUR, 8, DATEADD(DAY, -42, GETDATE())))),
(1195, 1065, N'Standard', 200000, 500, '#3498DB', DATEADD(MINUTE, 26, DATEADD(HOUR, 17, DATEADD(DAY, -50, GETDATE())))),
(1196, 1065, N'VIP', 500000, 100, '#E74C3C', DATEADD(MINUTE, 39, DATEADD(HOUR, 4, DATEADD(DAY, -60, GETDATE())))),
(1197, 1065, N'Early Bird', 150000, 200, '#2ECC71', DATEADD(MINUTE, 58, DATEADD(HOUR, 11, DATEADD(DAY, -54, GETDATE())))),
(1198, 1066, N'Standard', 200000, 500, '#3498DB', DATEADD(MINUTE, 39, DATEADD(HOUR, 9, DATEADD(DAY, -3, GETDATE())))),
(1199, 1066, N'VIP', 500000, 100, '#E74C3C', DATEADD(MINUTE, 57, DATEADD(HOUR, 0, DATEADD(DAY, -25, GETDATE())))),
(1200, 1066, N'Early Bird', 150000, 200, '#2ECC71', DATEADD(MINUTE, 27, DATEADD(HOUR, 14, DATEADD(DAY, -56, GETDATE())))),
(1201, 1067, N'Standard', 200000, 500, '#3498DB', DATEADD(MINUTE, 17, DATEADD(HOUR, 15, DATEADD(DAY, -45, GETDATE())))),
(1202, 1067, N'VIP', 500000, 100, '#E74C3C', DATEADD(MINUTE, 14, DATEADD(HOUR, 6, DATEADD(DAY, -45, GETDATE())))),
(1203, 1067, N'Early Bird', 150000, 200, '#2ECC71', DATEADD(MINUTE, 42, DATEADD(HOUR, 6, DATEADD(DAY, -16, GETDATE())))),
(1204, 1068, N'Standard', 200000, 500, '#3498DB', DATEADD(MINUTE, 37, DATEADD(HOUR, 1, DATEADD(DAY, -35, GETDATE())))),
(1205, 1068, N'VIP', 500000, 100, '#E74C3C', DATEADD(MINUTE, 3, DATEADD(HOUR, 15, DATEADD(DAY, -10, GETDATE())))),
(1206, 1068, N'Early Bird', 150000, 200, '#2ECC71', DATEADD(MINUTE, 55, DATEADD(HOUR, 19, DATEADD(DAY, -55, GETDATE())))),
(1207, 1069, N'Standard', 200000, 500, '#3498DB', DATEADD(MINUTE, 12, DATEADD(HOUR, 22, DATEADD(DAY, -25, GETDATE())))),
(1208, 1069, N'VIP', 500000, 100, '#E74C3C', DATEADD(MINUTE, 48, DATEADD(HOUR, 20, DATEADD(DAY, -14, GETDATE())))),
(1209, 1069, N'Early Bird', 150000, 200, '#2ECC71', DATEADD(MINUTE, 27, DATEADD(HOUR, 19, DATEADD(DAY, -58, GETDATE())))),
(1210, 1070, N'Standard', 200000, 500, '#3498DB', DATEADD(MINUTE, 53, DATEADD(HOUR, 10, DATEADD(DAY, -3, GETDATE())))),
(1211, 1070, N'VIP', 500000, 100, '#E74C3C', DATEADD(MINUTE, 8, DATEADD(HOUR, 11, DATEADD(DAY, -36, GETDATE())))),
(1212, 1070, N'Early Bird', 150000, 200, '#2ECC71', DATEADD(MINUTE, 55, DATEADD(HOUR, 13, DATEADD(DAY, -20, GETDATE())))),
(1213, 1071, N'Standard', 200000, 500, '#3498DB', DATEADD(MINUTE, 19, DATEADD(HOUR, 2, DATEADD(DAY, -5, GETDATE())))),
(1214, 1071, N'VIP', 500000, 100, '#E74C3C', DATEADD(MINUTE, 9, DATEADD(HOUR, 0, DATEADD(DAY, -6, GETDATE())))),
(1215, 1071, N'Early Bird', 150000, 200, '#2ECC71', DATEADD(MINUTE, 59, DATEADD(HOUR, 10, DATEADD(DAY, -27, GETDATE())))),
(1216, 1072, N'Standard', 200000, 500, '#3498DB', DATEADD(MINUTE, 24, DATEADD(HOUR, 6, DATEADD(DAY, -19, GETDATE())))),
(1217, 1072, N'VIP', 500000, 100, '#E74C3C', DATEADD(MINUTE, 23, DATEADD(HOUR, 16, DATEADD(DAY, -18, GETDATE())))),
(1218, 1072, N'Early Bird', 150000, 200, '#2ECC71', DATEADD(MINUTE, 59, DATEADD(HOUR, 22, DATEADD(DAY, -34, GETDATE())))),
(1219, 1073, N'Standard', 200000, 500, '#3498DB', DATEADD(MINUTE, 3, DATEADD(HOUR, 21, DATEADD(DAY, -2, GETDATE())))),
(1220, 1073, N'VIP', 500000, 100, '#E74C3C', DATEADD(MINUTE, 51, DATEADD(HOUR, 10, DATEADD(DAY, -26, GETDATE())))),
(1221, 1073, N'Early Bird', 150000, 200, '#2ECC71', DATEADD(MINUTE, 36, DATEADD(HOUR, 17, DATEADD(DAY, -29, GETDATE())))),
(1222, 1074, N'Standard', 200000, 500, '#3498DB', DATEADD(MINUTE, 54, DATEADD(HOUR, 17, DATEADD(DAY, -26, GETDATE())))),
(1223, 1074, N'VIP', 500000, 100, '#E74C3C', DATEADD(MINUTE, 34, DATEADD(HOUR, 4, DATEADD(DAY, -39, GETDATE())))),
(1224, 1074, N'Early Bird', 150000, 200, '#2ECC71', DATEADD(MINUTE, 10, DATEADD(HOUR, 18, DATEADD(DAY, -32, GETDATE())))),
(1225, 1075, N'Standard', 200000, 500, '#3498DB', DATEADD(MINUTE, 34, DATEADD(HOUR, 20, DATEADD(DAY, -32, GETDATE())))),
(1226, 1075, N'VIP', 500000, 100, '#E74C3C', DATEADD(MINUTE, 51, DATEADD(HOUR, 13, DATEADD(DAY, -51, GETDATE())))),
(1227, 1075, N'Early Bird', 150000, 200, '#2ECC71', DATEADD(MINUTE, 22, DATEADD(HOUR, 17, DATEADD(DAY, -44, GETDATE())))),
(1228, 1076, N'Standard', 200000, 500, '#3498DB', DATEADD(MINUTE, 33, DATEADD(HOUR, 5, DATEADD(DAY, -41, GETDATE())))),
(1229, 1076, N'VIP', 500000, 100, '#E74C3C', DATEADD(MINUTE, 34, DATEADD(HOUR, 18, DATEADD(DAY, -2, GETDATE())))),
(1230, 1076, N'Early Bird', 150000, 200, '#2ECC71', DATEADD(MINUTE, 28, DATEADD(HOUR, 10, DATEADD(DAY, -25, GETDATE())))),
(1231, 1077, N'Standard', 200000, 500, '#3498DB', DATEADD(MINUTE, 18, DATEADD(HOUR, 1, DATEADD(DAY, -40, GETDATE())))),
(1232, 1077, N'VIP', 500000, 100, '#E74C3C', DATEADD(MINUTE, 56, DATEADD(HOUR, 21, DATEADD(DAY, -35, GETDATE())))),
(1233, 1077, N'Early Bird', 150000, 200, '#2ECC71', DATEADD(MINUTE, 2, DATEADD(HOUR, 2, DATEADD(DAY, -24, GETDATE())))),
(1234, 1078, N'Standard', 200000, 500, '#3498DB', DATEADD(MINUTE, 22, DATEADD(HOUR, 22, DATEADD(DAY, -38, GETDATE())))),
(1235, 1078, N'VIP', 500000, 100, '#E74C3C', DATEADD(MINUTE, 10, DATEADD(HOUR, 7, DATEADD(DAY, -4, GETDATE())))),
(1236, 1078, N'Early Bird', 150000, 200, '#2ECC71', DATEADD(MINUTE, 6, DATEADD(HOUR, 9, DATEADD(DAY, -15, GETDATE())))),
(1237, 1079, N'Standard', 200000, 500, '#3498DB', DATEADD(MINUTE, 34, DATEADD(HOUR, 4, DATEADD(DAY, -35, GETDATE())))),
(1238, 1079, N'VIP', 500000, 100, '#E74C3C', DATEADD(MINUTE, 26, DATEADD(HOUR, 19, DATEADD(DAY, 0, GETDATE())))),
(1239, 1079, N'Early Bird', 150000, 200, '#2ECC71', DATEADD(MINUTE, 22, DATEADD(HOUR, 0, DATEADD(DAY, -38, GETDATE())))),
(1240, 1080, N'Standard', 200000, 500, '#3498DB', DATEADD(MINUTE, 7, DATEADD(HOUR, 3, DATEADD(DAY, -4, GETDATE())))),
(1241, 1080, N'VIP', 500000, 100, '#E74C3C', DATEADD(MINUTE, 11, DATEADD(HOUR, 23, DATEADD(DAY, -6, GETDATE())))),
(1242, 1080, N'Early Bird', 150000, 200, '#2ECC71', DATEADD(MINUTE, 43, DATEADD(HOUR, 6, DATEADD(DAY, -34, GETDATE())))),
(1243, 1081, N'Standard', 200000, 500, '#3498DB', DATEADD(MINUTE, 6, DATEADD(HOUR, 16, DATEADD(DAY, -52, GETDATE())))),
(1244, 1081, N'VIP', 500000, 100, '#E74C3C', DATEADD(MINUTE, 29, DATEADD(HOUR, 19, DATEADD(DAY, -41, GETDATE())))),
(1245, 1081, N'Early Bird', 150000, 200, '#2ECC71', DATEADD(MINUTE, 40, DATEADD(HOUR, 15, DATEADD(DAY, -49, GETDATE())))),
(1246, 1082, N'Standard', 200000, 500, '#3498DB', DATEADD(MINUTE, 30, DATEADD(HOUR, 6, DATEADD(DAY, -37, GETDATE())))),
(1247, 1082, N'VIP', 500000, 100, '#E74C3C', DATEADD(MINUTE, 38, DATEADD(HOUR, 21, DATEADD(DAY, -48, GETDATE())))),
(1248, 1082, N'Early Bird', 150000, 200, '#2ECC71', DATEADD(MINUTE, 11, DATEADD(HOUR, 9, DATEADD(DAY, -5, GETDATE())))),
(1249, 1083, N'Standard', 200000, 500, '#3498DB', DATEADD(MINUTE, 13, DATEADD(HOUR, 4, DATEADD(DAY, -27, GETDATE())))),
(1250, 1083, N'VIP', 500000, 100, '#E74C3C', DATEADD(MINUTE, 49, DATEADD(HOUR, 23, DATEADD(DAY, -51, GETDATE())))),
(1251, 1083, N'Early Bird', 150000, 200, '#2ECC71', DATEADD(MINUTE, 13, DATEADD(HOUR, 12, DATEADD(DAY, -20, GETDATE())))),
(1252, 1084, N'Standard', 200000, 500, '#3498DB', DATEADD(MINUTE, 2, DATEADD(HOUR, 5, DATEADD(DAY, -32, GETDATE())))),
(1253, 1084, N'VIP', 500000, 100, '#E74C3C', DATEADD(MINUTE, 30, DATEADD(HOUR, 21, DATEADD(DAY, -52, GETDATE())))),
(1254, 1084, N'Early Bird', 150000, 200, '#2ECC71', DATEADD(MINUTE, 2, DATEADD(HOUR, 18, DATEADD(DAY, -32, GETDATE())))),
(1255, 1085, N'Standard', 200000, 500, '#3498DB', DATEADD(MINUTE, 23, DATEADD(HOUR, 11, DATEADD(DAY, -22, GETDATE())))),
(1256, 1085, N'VIP', 500000, 100, '#E74C3C', DATEADD(MINUTE, 13, DATEADD(HOUR, 7, DATEADD(DAY, -19, GETDATE())))),
(1257, 1085, N'Early Bird', 150000, 200, '#2ECC71', DATEADD(MINUTE, 12, DATEADD(HOUR, 9, DATEADD(DAY, -59, GETDATE())))),
(1258, 1086, N'Standard', 200000, 500, '#3498DB', DATEADD(MINUTE, 58, DATEADD(HOUR, 21, DATEADD(DAY, -51, GETDATE())))),
(1259, 1086, N'VIP', 500000, 100, '#E74C3C', DATEADD(MINUTE, 22, DATEADD(HOUR, 8, DATEADD(DAY, -50, GETDATE())))),
(1260, 1086, N'Early Bird', 150000, 200, '#2ECC71', DATEADD(MINUTE, 43, DATEADD(HOUR, 0, DATEADD(DAY, -1, GETDATE())))),
(1261, 1087, N'Standard', 200000, 500, '#3498DB', DATEADD(MINUTE, 38, DATEADD(HOUR, 9, DATEADD(DAY, -59, GETDATE())))),
(1262, 1087, N'VIP', 500000, 100, '#E74C3C', DATEADD(MINUTE, 44, DATEADD(HOUR, 19, DATEADD(DAY, -1, GETDATE())))),
(1263, 1087, N'Early Bird', 150000, 200, '#2ECC71', DATEADD(MINUTE, 26, DATEADD(HOUR, 23, DATEADD(DAY, -15, GETDATE())))),
(1264, 1088, N'Standard', 200000, 500, '#3498DB', DATEADD(MINUTE, 8, DATEADD(HOUR, 17, DATEADD(DAY, -9, GETDATE())))),
(1265, 1088, N'VIP', 500000, 100, '#E74C3C', DATEADD(MINUTE, 13, DATEADD(HOUR, 8, DATEADD(DAY, -35, GETDATE())))),
(1266, 1088, N'Early Bird', 150000, 200, '#2ECC71', DATEADD(MINUTE, 44, DATEADD(HOUR, 16, DATEADD(DAY, -47, GETDATE())))),
(1267, 1089, N'Standard', 200000, 500, '#3498DB', DATEADD(MINUTE, 59, DATEADD(HOUR, 8, DATEADD(DAY, -46, GETDATE())))),
(1268, 1089, N'VIP', 500000, 100, '#E74C3C', DATEADD(MINUTE, 59, DATEADD(HOUR, 16, DATEADD(DAY, -32, GETDATE())))),
(1269, 1089, N'Early Bird', 150000, 200, '#2ECC71', DATEADD(MINUTE, 26, DATEADD(HOUR, 22, DATEADD(DAY, -8, GETDATE())))),
(1270, 1090, N'Standard', 200000, 500, '#3498DB', DATEADD(MINUTE, 49, DATEADD(HOUR, 22, DATEADD(DAY, -4, GETDATE())))),
(1271, 1090, N'VIP', 500000, 100, '#E74C3C', DATEADD(MINUTE, 50, DATEADD(HOUR, 11, DATEADD(DAY, -40, GETDATE())))),
(1272, 1090, N'Early Bird', 150000, 200, '#2ECC71', DATEADD(MINUTE, 53, DATEADD(HOUR, 1, DATEADD(DAY, -41, GETDATE())))),
(1273, 1091, N'Standard', 200000, 500, '#3498DB', DATEADD(MINUTE, 41, DATEADD(HOUR, 1, DATEADD(DAY, -33, GETDATE())))),
(1274, 1091, N'VIP', 500000, 100, '#E74C3C', DATEADD(MINUTE, 14, DATEADD(HOUR, 9, DATEADD(DAY, -54, GETDATE())))),
(1275, 1091, N'Early Bird', 150000, 200, '#2ECC71', DATEADD(MINUTE, 42, DATEADD(HOUR, 18, DATEADD(DAY, -19, GETDATE())))),
(1276, 1092, N'Standard', 200000, 500, '#3498DB', DATEADD(MINUTE, 45, DATEADD(HOUR, 17, DATEADD(DAY, -43, GETDATE())))),
(1277, 1092, N'VIP', 500000, 100, '#E74C3C', DATEADD(MINUTE, 55, DATEADD(HOUR, 9, DATEADD(DAY, -40, GETDATE())))),
(1278, 1092, N'Early Bird', 150000, 200, '#2ECC71', DATEADD(MINUTE, 48, DATEADD(HOUR, 5, DATEADD(DAY, -1, GETDATE())))),
(1279, 1093, N'Standard', 200000, 500, '#3498DB', DATEADD(MINUTE, 39, DATEADD(HOUR, 18, DATEADD(DAY, -47, GETDATE())))),
(1280, 1093, N'VIP', 500000, 100, '#E74C3C', DATEADD(MINUTE, 35, DATEADD(HOUR, 22, DATEADD(DAY, -58, GETDATE())))),
(1281, 1093, N'Early Bird', 150000, 200, '#2ECC71', DATEADD(MINUTE, 34, DATEADD(HOUR, 19, DATEADD(DAY, -27, GETDATE())))),
(1282, 1094, N'Standard', 200000, 500, '#3498DB', DATEADD(MINUTE, 5, DATEADD(HOUR, 19, DATEADD(DAY, -14, GETDATE())))),
(1283, 1094, N'VIP', 500000, 100, '#E74C3C', DATEADD(MINUTE, 33, DATEADD(HOUR, 14, DATEADD(DAY, -34, GETDATE())))),
(1284, 1094, N'Early Bird', 150000, 200, '#2ECC71', DATEADD(MINUTE, 13, DATEADD(HOUR, 21, DATEADD(DAY, -24, GETDATE())))),
(1285, 1095, N'Standard', 200000, 500, '#3498DB', DATEADD(MINUTE, 8, DATEADD(HOUR, 6, DATEADD(DAY, -54, GETDATE())))),
(1286, 1095, N'VIP', 500000, 100, '#E74C3C', DATEADD(MINUTE, 44, DATEADD(HOUR, 17, DATEADD(DAY, -37, GETDATE())))),
(1287, 1095, N'Early Bird', 150000, 200, '#2ECC71', DATEADD(MINUTE, 58, DATEADD(HOUR, 0, DATEADD(DAY, -5, GETDATE())))),
(1288, 1096, N'Standard', 200000, 500, '#3498DB', DATEADD(MINUTE, 54, DATEADD(HOUR, 7, DATEADD(DAY, -59, GETDATE())))),
(1289, 1096, N'VIP', 500000, 100, '#E74C3C', DATEADD(MINUTE, 37, DATEADD(HOUR, 21, DATEADD(DAY, -45, GETDATE())))),
(1290, 1096, N'Early Bird', 150000, 200, '#2ECC71', DATEADD(MINUTE, 33, DATEADD(HOUR, 14, DATEADD(DAY, -4, GETDATE())))),
(1291, 1097, N'Standard', 200000, 500, '#3498DB', DATEADD(MINUTE, 45, DATEADD(HOUR, 5, DATEADD(DAY, -10, GETDATE())))),
(1292, 1097, N'VIP', 500000, 100, '#E74C3C', DATEADD(MINUTE, 18, DATEADD(HOUR, 14, DATEADD(DAY, -52, GETDATE())))),
(1293, 1097, N'Early Bird', 150000, 200, '#2ECC71', DATEADD(MINUTE, 43, DATEADD(HOUR, 22, DATEADD(DAY, -38, GETDATE())))),
(1294, 1098, N'Standard', 200000, 500, '#3498DB', DATEADD(MINUTE, 15, DATEADD(HOUR, 12, DATEADD(DAY, -32, GETDATE())))),
(1295, 1098, N'VIP', 500000, 100, '#E74C3C', DATEADD(MINUTE, 17, DATEADD(HOUR, 18, DATEADD(DAY, -42, GETDATE())))),
(1296, 1098, N'Early Bird', 150000, 200, '#2ECC71', DATEADD(MINUTE, 39, DATEADD(HOUR, 13, DATEADD(DAY, -55, GETDATE())))),
(1297, 1099, N'Standard', 200000, 500, '#3498DB', DATEADD(MINUTE, 16, DATEADD(HOUR, 23, DATEADD(DAY, -60, GETDATE())))),
(1298, 1099, N'VIP', 500000, 100, '#E74C3C', DATEADD(MINUTE, 17, DATEADD(HOUR, 14, DATEADD(DAY, -48, GETDATE())))),
(1299, 1099, N'Early Bird', 150000, 200, '#2ECC71', DATEADD(MINUTE, 32, DATEADD(HOUR, 12, DATEADD(DAY, -51, GETDATE()))));
SET IDENTITY_INSERT TicketTypes OFF;
GO
SET IDENTITY_INSERT Orders ON;
INSERT INTO Orders (order_id, order_code, user_id, event_id, total_amount, discount_amount, final_amount, status, payment_method, payment_date, buyer_name, buyer_email, buyer_phone, created_at, organizer_payout_amount) VALUES
(1000, 'ORD-MEGA-0000', 1020, 1014, 1000000, 0, 1000000, 'paid', 'seepay', DATEADD(MINUTE, 52, DATEADD(HOUR, 18, DATEADD(DAY, -40, GETDATE()))), N'Đỗ Thu', 'mega_req_0@gmail.com', '0974481319', DATEADD(MINUTE, 37, DATEADD(HOUR, 20, DATEADD(DAY, -29, GETDATE()))), 1000000),
(1001, 'ORD-MEGA-0001', 1082, 1052, 800000, 0, 800000, 'paid', 'seepay', DATEADD(MINUTE, 8, DATEADD(HOUR, 10, DATEADD(DAY, -30, GETDATE()))), N'Đặng Minh', 'mega_req_1@gmail.com', '0921382480', DATEADD(MINUTE, 8, DATEADD(HOUR, 11, DATEADD(DAY, -22, GETDATE()))), 800000),
(1002, 'ORD-MEGA-0002', 1018, 1065, 500000, 0, 500000, 'paid', 'seepay', DATEADD(MINUTE, 24, DATEADD(HOUR, 12, DATEADD(DAY, -12, GETDATE()))), N'Nguyễn Kiên', 'mega_req_2@gmail.com', '0937161943', DATEADD(MINUTE, 26, DATEADD(HOUR, 21, DATEADD(DAY, -3, GETDATE()))), 500000),
(1003, 'ORD-MEGA-0003', 1072, 1011, 450000, 0, 450000, 'paid', 'seepay', DATEADD(MINUTE, 1, DATEADD(HOUR, 6, DATEADD(DAY, -28, GETDATE()))), N'Bùi Hùng', 'mega_req_3@gmail.com', '0935906007', DATEADD(MINUTE, 39, DATEADD(HOUR, 12, DATEADD(DAY, -7, GETDATE()))), 450000),
(1004, 'ORD-MEGA-0004', 1025, 1070, 800000, 0, 800000, 'paid', 'seepay', DATEADD(MINUTE, 56, DATEADD(HOUR, 9, DATEADD(DAY, -31, GETDATE()))), N'Đỗ Thành', 'mega_req_4@gmail.com', '0945081637', DATEADD(MINUTE, 13, DATEADD(HOUR, 8, DATEADD(DAY, -42, GETDATE()))), 800000),
(1005, 'ORD-MEGA-0005', 1079, 1055, 1500000, 0, 1500000, 'cancelled', 'seepay', NULL, N'Đặng Bảo', 'mega_req_5@gmail.com', '0944798040', DATEADD(MINUTE, 51, DATEADD(HOUR, 10, DATEADD(DAY, -7, GETDATE()))), 1500000),
(1006, 'ORD-MEGA-0006', 1032, 1027, 150000, 0, 150000, 'paid', 'seepay', DATEADD(MINUTE, 9, DATEADD(HOUR, 18, DATEADD(DAY, -5, GETDATE()))), N'Hoàng Linh', 'mega_req_6@gmail.com', '0964937294', DATEADD(MINUTE, 24, DATEADD(HOUR, 15, DATEADD(DAY, -13, GETDATE()))), 150000),
(1007, 'ORD-MEGA-0007', 1088, 1048, 150000, 0, 150000, 'cancelled', 'seepay', NULL, N'Phạm Trang', 'mega_req_7@gmail.com', '0939171479', DATEADD(MINUTE, 30, DATEADD(HOUR, 20, DATEADD(DAY, -59, GETDATE()))), 150000),
(1008, 'ORD-MEGA-0008', 1061, 1071, 800000, 0, 800000, 'paid', 'seepay', DATEADD(MINUTE, 45, DATEADD(HOUR, 12, DATEADD(DAY, -56, GETDATE()))), N'Huỳnh Linh', 'mega_req_8@gmail.com', '0977392061', DATEADD(MINUTE, 25, DATEADD(HOUR, 11, DATEADD(DAY, -16, GETDATE()))), 800000),
(1009, 'ORD-MEGA-0009', 1056, 1024, 800000, 0, 800000, 'paid', 'seepay', DATEADD(MINUTE, 28, DATEADD(HOUR, 8, DATEADD(DAY, -58, GETDATE()))), N'Huỳnh Hải', 'mega_req_9@gmail.com', '0989138147', DATEADD(MINUTE, 27, DATEADD(HOUR, 14, DATEADD(DAY, -56, GETDATE()))), 800000),
(1010, 'ORD-MEGA-0010', 1094, 1011, 1000000, 0, 1000000, 'paid', 'seepay', DATEADD(MINUTE, 49, DATEADD(HOUR, 22, DATEADD(DAY, -14, GETDATE()))), N'Huỳnh Khoa', 'mega_req_10@gmail.com', '0921193580', DATEADD(MINUTE, 32, DATEADD(HOUR, 6, DATEADD(DAY, -21, GETDATE()))), 1000000),
(1011, 'ORD-MEGA-0011', 1012, 1051, 450000, 0, 450000, 'refunded', 'seepay', DATEADD(MINUTE, 58, DATEADD(HOUR, 19, DATEADD(DAY, -29, GETDATE()))), N'Đỗ Linh', 'mega_req_11@gmail.com', '0986319255', DATEADD(MINUTE, 33, DATEADD(HOUR, 6, DATEADD(DAY, -51, GETDATE()))), 450000),
(1012, 'ORD-MEGA-0012', 1092, 1083, 2000000, 0, 2000000, 'paid', 'seepay', DATEADD(MINUTE, 31, DATEADD(HOUR, 6, DATEADD(DAY, -24, GETDATE()))), N'Bùi Thu', 'mega_req_12@gmail.com', '0929045450', DATEADD(MINUTE, 8, DATEADD(HOUR, 22, DATEADD(DAY, -49, GETDATE()))), 2000000),
(1013, 'ORD-MEGA-0013', 1035, 1023, 2000000, 0, 2000000, 'paid', 'seepay', DATEADD(MINUTE, 17, DATEADD(HOUR, 8, DATEADD(DAY, -37, GETDATE()))), N'Phạm Phong', 'mega_req_13@gmail.com', '0960334491', DATEADD(MINUTE, 41, DATEADD(HOUR, 12, DATEADD(DAY, -57, GETDATE()))), 2000000),
(1014, 'ORD-MEGA-0014', 1007, 1005, 400000, 0, 400000, 'refunded', 'seepay', DATEADD(MINUTE, 41, DATEADD(HOUR, 21, DATEADD(DAY, -22, GETDATE()))), N'Hoàng Minh', 'mega_req_14@gmail.com', '0986745151', DATEADD(MINUTE, 23, DATEADD(HOUR, 3, DATEADD(DAY, -26, GETDATE()))), 400000),
(1015, 'ORD-MEGA-0015', 1044, 1033, 500000, 0, 500000, 'cancelled', 'seepay', NULL, N'Đặng Phong', 'mega_req_15@gmail.com', '0994086470', DATEADD(MINUTE, 39, DATEADD(HOUR, 20, DATEADD(DAY, -38, GETDATE()))), 500000),
(1016, 'ORD-MEGA-0016', 1027, 1022, 300000, 0, 300000, 'refunded', 'seepay', DATEADD(MINUTE, 47, DATEADD(HOUR, 12, DATEADD(DAY, -54, GETDATE()))), N'Trần Kiên', 'mega_req_16@gmail.com', '0921772008', DATEADD(MINUTE, 14, DATEADD(HOUR, 5, DATEADD(DAY, -43, GETDATE()))), 300000),
(1017, 'ORD-MEGA-0017', 1033, 1038, 150000, 0, 150000, 'refunded', 'seepay', DATEADD(MINUTE, 22, DATEADD(HOUR, 18, DATEADD(DAY, -59, GETDATE()))), N'Đỗ Linh', 'mega_req_17@gmail.com', '0991801777', DATEADD(MINUTE, 49, DATEADD(HOUR, 10, DATEADD(DAY, -12, GETDATE()))), 150000),
(1018, 'ORD-MEGA-0018', 1093, 1018, 1500000, 0, 1500000, 'paid', 'seepay', DATEADD(MINUTE, 19, DATEADD(HOUR, 21, DATEADD(DAY, -17, GETDATE()))), N'Lê Khoa', 'mega_req_18@gmail.com', '0921685284', DATEADD(MINUTE, 58, DATEADD(HOUR, 22, DATEADD(DAY, -39, GETDATE()))), 1500000),
(1019, 'ORD-MEGA-0019', 1022, 1027, 200000, 0, 200000, 'refunded', 'seepay', DATEADD(MINUTE, 49, DATEADD(HOUR, 3, DATEADD(DAY, -9, GETDATE()))), N'Đặng Trang', 'mega_req_19@gmail.com', '0921478758', DATEADD(MINUTE, 6, DATEADD(HOUR, 13, DATEADD(DAY, -24, GETDATE()))), 200000),
(1020, 'ORD-MEGA-0020', 1035, 1067, 200000, 0, 200000, 'pending', 'seepay', NULL, N'Lê Kiên', 'mega_req_20@gmail.com', '0936673749', DATEADD(MINUTE, 27, DATEADD(HOUR, 17, DATEADD(DAY, -43, GETDATE()))), 200000),
(1021, 'ORD-MEGA-0021', 1050, 1019, 600000, 0, 600000, 'pending', 'seepay', NULL, N'Phạm Hải', 'mega_req_21@gmail.com', '0914731183', DATEADD(MINUTE, 24, DATEADD(HOUR, 0, DATEADD(DAY, -47, GETDATE()))), 600000),
(1022, 'ORD-MEGA-0022', 1049, 1029, 1000000, 0, 1000000, 'pending', 'seepay', NULL, N'Hoàng Bảo', 'mega_req_22@gmail.com', '0949193120', DATEADD(MINUTE, 33, DATEADD(HOUR, 13, DATEADD(DAY, -12, GETDATE()))), 1000000),
(1023, 'ORD-MEGA-0023', 1045, 1050, 1500000, 0, 1500000, 'paid', 'seepay', DATEADD(MINUTE, 10, DATEADD(HOUR, 6, DATEADD(DAY, -14, GETDATE()))), N'Phạm Trang', 'mega_req_23@gmail.com', '0929908030', DATEADD(MINUTE, 38, DATEADD(HOUR, 23, DATEADD(DAY, -12, GETDATE()))), 1500000),
(1024, 'ORD-MEGA-0024', 1010, 1004, 200000, 0, 200000, 'cancelled', 'seepay', NULL, N'Phạm Linh', 'mega_req_24@gmail.com', '0991093353', DATEADD(MINUTE, 21, DATEADD(HOUR, 4, DATEADD(DAY, -2, GETDATE()))), 200000),
(1025, 'ORD-MEGA-0025', 1087, 1006, 450000, 0, 450000, 'paid', 'seepay', DATEADD(MINUTE, 45, DATEADD(HOUR, 22, DATEADD(DAY, -7, GETDATE()))), N'Bùi Anh', 'mega_req_25@gmail.com', '0978057074', DATEADD(MINUTE, 50, DATEADD(HOUR, 13, DATEADD(DAY, -59, GETDATE()))), 450000),
(1026, 'ORD-MEGA-0026', 1063, 1028, 1000000, 0, 1000000, 'pending', 'seepay', NULL, N'Vũ Bảo', 'mega_req_26@gmail.com', '0913217518', DATEADD(MINUTE, 23, DATEADD(HOUR, 13, DATEADD(DAY, -40, GETDATE()))), 1000000),
(1027, 'ORD-MEGA-0027', 1036, 1054, 150000, 0, 150000, 'cancelled', 'seepay', NULL, N'Hoàng Thu', 'mega_req_27@gmail.com', '0966956318', DATEADD(MINUTE, 53, DATEADD(HOUR, 16, DATEADD(DAY, -36, GETDATE()))), 150000),
(1028, 'ORD-MEGA-0028', 1072, 1016, 150000, 0, 150000, 'paid', 'seepay', DATEADD(MINUTE, 52, DATEADD(HOUR, 12, DATEADD(DAY, -58, GETDATE()))), N'Nguyễn Trang', 'mega_req_28@gmail.com', '0988348718', DATEADD(MINUTE, 19, DATEADD(HOUR, 22, DATEADD(DAY, -18, GETDATE()))), 150000),
(1029, 'ORD-MEGA-0029', 1065, 1096, 1500000, 0, 1500000, 'pending', 'seepay', NULL, N'Hoàng Khoa', 'mega_req_29@gmail.com', '0913923191', DATEADD(MINUTE, 23, DATEADD(HOUR, 18, DATEADD(DAY, -48, GETDATE()))), 1500000),
(1030, 'ORD-MEGA-0030', 1096, 1049, 200000, 0, 200000, 'pending', 'seepay', NULL, N'Đặng Thu', 'mega_req_30@gmail.com', '0958968702', DATEADD(MINUTE, 11, DATEADD(HOUR, 7, DATEADD(DAY, -35, GETDATE()))), 200000),
(1031, 'ORD-MEGA-0031', 1002, 1045, 450000, 0, 450000, 'refunded', 'seepay', DATEADD(MINUTE, 51, DATEADD(HOUR, 20, DATEADD(DAY, -9, GETDATE()))), N'Bùi Linh', 'mega_req_31@gmail.com', '0945969908', DATEADD(MINUTE, 8, DATEADD(HOUR, 0, DATEADD(DAY, -4, GETDATE()))), 450000),
(1032, 'ORD-MEGA-0032', 1026, 1010, 500000, 0, 500000, 'cancelled', 'seepay', NULL, N'Vũ Bảo', 'mega_req_32@gmail.com', '0938878343', DATEADD(MINUTE, 19, DATEADD(HOUR, 18, DATEADD(DAY, -24, GETDATE()))), 500000),
(1033, 'ORD-MEGA-0033', 1045, 1001, 450000, 0, 450000, 'pending', 'seepay', NULL, N'Đỗ Thu', 'mega_req_33@gmail.com', '0945501383', DATEADD(MINUTE, 43, DATEADD(HOUR, 7, DATEADD(DAY, -26, GETDATE()))), 450000),
(1034, 'ORD-MEGA-0034', 1015, 1021, 300000, 0, 300000, 'paid', 'seepay', DATEADD(MINUTE, 1, DATEADD(HOUR, 11, DATEADD(DAY, -55, GETDATE()))), N'Phạm Minh', 'mega_req_34@gmail.com', '0955553506', DATEADD(MINUTE, 50, DATEADD(HOUR, 0, DATEADD(DAY, -36, GETDATE()))), 300000),
(1035, 'ORD-MEGA-0035', 1000, 1009, 800000, 0, 800000, 'paid', 'seepay', DATEADD(MINUTE, 6, DATEADD(HOUR, 9, DATEADD(DAY, -1, GETDATE()))), N'Phạm Thu', 'mega_req_35@gmail.com', '0979119270', DATEADD(MINUTE, 11, DATEADD(HOUR, 3, DATEADD(DAY, -29, GETDATE()))), 800000),
(1036, 'ORD-MEGA-0036', 1068, 1011, 800000, 0, 800000, 'paid', 'seepay', DATEADD(MINUTE, 26, DATEADD(HOUR, 23, DATEADD(DAY, -8, GETDATE()))), N'Phạm Thu', 'mega_req_36@gmail.com', '0950165401', DATEADD(MINUTE, 42, DATEADD(HOUR, 20, DATEADD(DAY, -36, GETDATE()))), 800000),
(1037, 'ORD-MEGA-0037', 1009, 1012, 450000, 0, 450000, 'cancelled', 'seepay', NULL, N'Phạm Anh', 'mega_req_37@gmail.com', '0961132254', DATEADD(MINUTE, 9, DATEADD(HOUR, 22, DATEADD(DAY, -57, GETDATE()))), 450000),
(1038, 'ORD-MEGA-0038', 1090, 1008, 200000, 0, 200000, 'cancelled', 'seepay', NULL, N'Trần Hải', 'mega_req_38@gmail.com', '0915665885', DATEADD(MINUTE, 32, DATEADD(HOUR, 10, DATEADD(DAY, -11, GETDATE()))), 200000),
(1039, 'ORD-MEGA-0039', 1088, 1014, 600000, 0, 600000, 'pending', 'seepay', NULL, N'Huỳnh Bảo', 'mega_req_39@gmail.com', '0950840440', DATEADD(MINUTE, 9, DATEADD(HOUR, 8, DATEADD(DAY, -50, GETDATE()))), 600000),
(1040, 'ORD-MEGA-0040', 1044, 1018, 450000, 0, 450000, 'paid', 'seepay', DATEADD(MINUTE, 38, DATEADD(HOUR, 22, DATEADD(DAY, -7, GETDATE()))), N'Hoàng Trang', 'mega_req_40@gmail.com', '0990330595', DATEADD(MINUTE, 58, DATEADD(HOUR, 12, DATEADD(DAY, -41, GETDATE()))), 450000),
(1041, 'ORD-MEGA-0041', 1003, 1002, 450000, 0, 450000, 'paid', 'seepay', DATEADD(MINUTE, 50, DATEADD(HOUR, 2, DATEADD(DAY, -52, GETDATE()))), N'Bùi Lan', 'mega_req_41@gmail.com', '0982167916', DATEADD(MINUTE, 44, DATEADD(HOUR, 18, DATEADD(DAY, -48, GETDATE()))), 450000),
(1042, 'ORD-MEGA-0042', 1010, 1079, 2000000, 0, 2000000, 'paid', 'seepay', DATEADD(MINUTE, 10, DATEADD(HOUR, 13, DATEADD(DAY, -17, GETDATE()))), N'Đặng Thành', 'mega_req_42@gmail.com', '0940253131', DATEADD(MINUTE, 27, DATEADD(HOUR, 20, DATEADD(DAY, -45, GETDATE()))), 2000000),
(1043, 'ORD-MEGA-0043', 1010, 1038, 300000, 0, 300000, 'paid', 'seepay', DATEADD(MINUTE, 39, DATEADD(HOUR, 17, DATEADD(DAY, -2, GETDATE()))), N'Vũ Trang', 'mega_req_43@gmail.com', '0949827515', DATEADD(MINUTE, 30, DATEADD(HOUR, 5, DATEADD(DAY, -31, GETDATE()))), 300000),
(1044, 'ORD-MEGA-0044', 1051, 1028, 1500000, 0, 1500000, 'paid', 'seepay', DATEADD(MINUTE, 20, DATEADD(HOUR, 14, DATEADD(DAY, -13, GETDATE()))), N'Bùi Trang', 'mega_req_44@gmail.com', '0951904129', DATEADD(MINUTE, 27, DATEADD(HOUR, 10, DATEADD(DAY, -32, GETDATE()))), 1500000),
(1045, 'ORD-MEGA-0045', 1025, 1006, 400000, 0, 400000, 'paid', 'seepay', DATEADD(MINUTE, 7, DATEADD(HOUR, 4, DATEADD(DAY, -50, GETDATE()))), N'Lê Minh', 'mega_req_45@gmail.com', '0942635273', DATEADD(MINUTE, 15, DATEADD(HOUR, 18, DATEADD(DAY, -12, GETDATE()))), 400000),
(1046, 'ORD-MEGA-0046', 1047, 1030, 200000, 0, 200000, 'paid', 'seepay', DATEADD(MINUTE, 56, DATEADD(HOUR, 12, DATEADD(DAY, -26, GETDATE()))), N'Phạm Trang', 'mega_req_46@gmail.com', '0926031051', DATEADD(MINUTE, 11, DATEADD(HOUR, 11, DATEADD(DAY, -52, GETDATE()))), 200000),
(1047, 'ORD-MEGA-0047', 1052, 1082, 600000, 0, 600000, 'pending', 'seepay', NULL, N'Lê Vân', 'mega_req_47@gmail.com', '0912152122', DATEADD(MINUTE, 11, DATEADD(HOUR, 13, DATEADD(DAY, -39, GETDATE()))), 600000),
(1048, 'ORD-MEGA-0048', 1089, 1044, 300000, 0, 300000, 'paid', 'seepay', DATEADD(MINUTE, 57, DATEADD(HOUR, 5, DATEADD(DAY, -39, GETDATE()))), N'Hoàng Thu', 'mega_req_48@gmail.com', '0951297266', DATEADD(MINUTE, 46, DATEADD(HOUR, 6, DATEADD(DAY, 0, GETDATE()))), 300000),
(1049, 'ORD-MEGA-0049', 1070, 1009, 600000, 0, 600000, 'cancelled', 'seepay', NULL, N'Lê Khoa', 'mega_req_49@gmail.com', '0917301238', DATEADD(MINUTE, 14, DATEADD(HOUR, 7, DATEADD(DAY, -13, GETDATE()))), 600000),
(1050, 'ORD-MEGA-0050', 1077, 1034, 600000, 0, 600000, 'paid', 'seepay', DATEADD(MINUTE, 6, DATEADD(HOUR, 14, DATEADD(DAY, -18, GETDATE()))), N'Phạm Minh', 'mega_req_50@gmail.com', '0940570865', DATEADD(MINUTE, 38, DATEADD(HOUR, 13, DATEADD(DAY, -60, GETDATE()))), 600000),
(1051, 'ORD-MEGA-0051', 1020, 1006, 800000, 0, 800000, 'paid', 'seepay', DATEADD(MINUTE, 57, DATEADD(HOUR, 8, DATEADD(DAY, -48, GETDATE()))), N'Bùi Hải', 'mega_req_51@gmail.com', '0949776555', DATEADD(MINUTE, 49, DATEADD(HOUR, 6, DATEADD(DAY, -3, GETDATE()))), 800000),
(1052, 'ORD-MEGA-0052', 1024, 1046, 1500000, 0, 1500000, 'paid', 'seepay', DATEADD(MINUTE, 54, DATEADD(HOUR, 7, DATEADD(DAY, -41, GETDATE()))), N'Bùi Hùng', 'mega_req_52@gmail.com', '0985206259', DATEADD(MINUTE, 3, DATEADD(HOUR, 3, DATEADD(DAY, -17, GETDATE()))), 1500000),
(1053, 'ORD-MEGA-0053', 1062, 1049, 200000, 0, 200000, 'paid', 'seepay', DATEADD(MINUTE, 40, DATEADD(HOUR, 5, DATEADD(DAY, -57, GETDATE()))), N'Vũ Hùng', 'mega_req_53@gmail.com', '0975872517', DATEADD(MINUTE, 51, DATEADD(HOUR, 5, DATEADD(DAY, -59, GETDATE()))), 200000),
(1054, 'ORD-MEGA-0054', 1074, 1037, 1500000, 0, 1500000, 'paid', 'seepay', DATEADD(MINUTE, 0, DATEADD(HOUR, 12, DATEADD(DAY, -5, GETDATE()))), N'Nguyễn Linh', 'mega_req_54@gmail.com', '0970539541', DATEADD(MINUTE, 35, DATEADD(HOUR, 23, DATEADD(DAY, -33, GETDATE()))), 1500000),
(1055, 'ORD-MEGA-0055', 1077, 1023, 200000, 0, 200000, 'paid', 'seepay', DATEADD(MINUTE, 9, DATEADD(HOUR, 17, DATEADD(DAY, -56, GETDATE()))), N'Bùi Trang', 'mega_req_55@gmail.com', '0976211108', DATEADD(MINUTE, 50, DATEADD(HOUR, 12, DATEADD(DAY, -49, GETDATE()))), 200000),
(1056, 'ORD-MEGA-0056', 1014, 1066, 500000, 0, 500000, 'paid', 'seepay', DATEADD(MINUTE, 16, DATEADD(HOUR, 23, DATEADD(DAY, -46, GETDATE()))), N'Đặng Anh', 'mega_req_56@gmail.com', '0979327388', DATEADD(MINUTE, 27, DATEADD(HOUR, 8, DATEADD(DAY, -10, GETDATE()))), 500000),
(1057, 'ORD-MEGA-0057', 1034, 1011, 150000, 0, 150000, 'paid', 'seepay', DATEADD(MINUTE, 50, DATEADD(HOUR, 21, DATEADD(DAY, -5, GETDATE()))), N'Phạm Hùng', 'mega_req_57@gmail.com', '0915596723', DATEADD(MINUTE, 6, DATEADD(HOUR, 0, DATEADD(DAY, -36, GETDATE()))), 150000),
(1058, 'ORD-MEGA-0058', 1069, 1079, 300000, 0, 300000, 'paid', 'seepay', DATEADD(MINUTE, 27, DATEADD(HOUR, 2, DATEADD(DAY, -7, GETDATE()))), N'Hoàng Linh', 'mega_req_58@gmail.com', '0999778901', DATEADD(MINUTE, 31, DATEADD(HOUR, 19, DATEADD(DAY, -34, GETDATE()))), 300000),
(1059, 'ORD-MEGA-0059', 1056, 1011, 1500000, 0, 1500000, 'pending', 'seepay', NULL, N'Bùi Phong', 'mega_req_59@gmail.com', '0935508561', DATEADD(MINUTE, 15, DATEADD(HOUR, 18, DATEADD(DAY, 0, GETDATE()))), 1500000),
(1060, 'ORD-MEGA-0060', 1007, 1068, 600000, 0, 600000, 'paid', 'seepay', DATEADD(MINUTE, 57, DATEADD(HOUR, 2, DATEADD(DAY, -37, GETDATE()))), N'Nguyễn Bảo', 'mega_req_60@gmail.com', '0989256770', DATEADD(MINUTE, 32, DATEADD(HOUR, 18, DATEADD(DAY, -52, GETDATE()))), 600000),
(1061, 'ORD-MEGA-0061', 1070, 1034, 800000, 0, 800000, 'cancelled', 'seepay', NULL, N'Nguyễn Lan', 'mega_req_61@gmail.com', '0934722778', DATEADD(MINUTE, 0, DATEADD(HOUR, 18, DATEADD(DAY, -52, GETDATE()))), 800000),
(1062, 'ORD-MEGA-0062', 1086, 1057, 600000, 0, 600000, 'refunded', 'seepay', DATEADD(MINUTE, 38, DATEADD(HOUR, 7, DATEADD(DAY, 0, GETDATE()))), N'Vũ Anh', 'mega_req_62@gmail.com', '0991769630', DATEADD(MINUTE, 38, DATEADD(HOUR, 2, DATEADD(DAY, -11, GETDATE()))), 600000),
(1063, 'ORD-MEGA-0063', 1079, 1084, 600000, 0, 600000, 'refunded', 'seepay', DATEADD(MINUTE, 8, DATEADD(HOUR, 22, DATEADD(DAY, -59, GETDATE()))), N'Huỳnh Linh', 'mega_req_63@gmail.com', '0950258554', DATEADD(MINUTE, 41, DATEADD(HOUR, 3, DATEADD(DAY, -47, GETDATE()))), 600000),
(1064, 'ORD-MEGA-0064', 1005, 1051, 2000000, 0, 2000000, 'paid', 'seepay', DATEADD(MINUTE, 29, DATEADD(HOUR, 1, DATEADD(DAY, -34, GETDATE()))), N'Bùi Tâm', 'mega_req_64@gmail.com', '0964219054', DATEADD(MINUTE, 27, DATEADD(HOUR, 8, DATEADD(DAY, -22, GETDATE()))), 2000000),
(1065, 'ORD-MEGA-0065', 1091, 1037, 1500000, 0, 1500000, 'paid', 'seepay', DATEADD(MINUTE, 16, DATEADD(HOUR, 1, DATEADD(DAY, -57, GETDATE()))), N'Trần Trang', 'mega_req_65@gmail.com', '0915295037', DATEADD(MINUTE, 53, DATEADD(HOUR, 10, DATEADD(DAY, -22, GETDATE()))), 1500000),
(1066, 'ORD-MEGA-0066', 1002, 1073, 450000, 0, 450000, 'refunded', 'seepay', DATEADD(MINUTE, 32, DATEADD(HOUR, 14, DATEADD(DAY, -32, GETDATE()))), N'Nguyễn Anh', 'mega_req_66@gmail.com', '0911710564', DATEADD(MINUTE, 50, DATEADD(HOUR, 22, DATEADD(DAY, -53, GETDATE()))), 450000),
(1067, 'ORD-MEGA-0067', 1043, 1015, 800000, 0, 800000, 'paid', 'seepay', DATEADD(MINUTE, 7, DATEADD(HOUR, 14, DATEADD(DAY, -34, GETDATE()))), N'Vũ Anh', 'mega_req_67@gmail.com', '0948688273', DATEADD(MINUTE, 29, DATEADD(HOUR, 12, DATEADD(DAY, -2, GETDATE()))), 800000),
(1068, 'ORD-MEGA-0068', 1064, 1039, 1000000, 0, 1000000, 'pending', 'seepay', NULL, N'Phạm Tâm', 'mega_req_68@gmail.com', '0975301991', DATEADD(MINUTE, 54, DATEADD(HOUR, 13, DATEADD(DAY, -34, GETDATE()))), 1000000),
(1069, 'ORD-MEGA-0069', 1028, 1073, 600000, 0, 600000, 'refunded', 'seepay', DATEADD(MINUTE, 8, DATEADD(HOUR, 1, DATEADD(DAY, -51, GETDATE()))), N'Đặng Vân', 'mega_req_69@gmail.com', '0994757129', DATEADD(MINUTE, 21, DATEADD(HOUR, 18, DATEADD(DAY, -18, GETDATE()))), 600000),
(1070, 'ORD-MEGA-0070', 1081, 1079, 500000, 0, 500000, 'pending', 'seepay', NULL, N'Vũ Khoa', 'mega_req_70@gmail.com', '0998663853', DATEADD(MINUTE, 10, DATEADD(HOUR, 22, DATEADD(DAY, -10, GETDATE()))), 500000),
(1071, 'ORD-MEGA-0071', 1056, 1066, 1000000, 0, 1000000, 'pending', 'seepay', NULL, N'Nguyễn Thu', 'mega_req_71@gmail.com', '0978955042', DATEADD(MINUTE, 37, DATEADD(HOUR, 3, DATEADD(DAY, -37, GETDATE()))), 1000000),
(1072, 'ORD-MEGA-0072', 1050, 1007, 500000, 0, 500000, 'paid', 'seepay', DATEADD(MINUTE, 53, DATEADD(HOUR, 8, DATEADD(DAY, -55, GETDATE()))), N'Lê Anh', 'mega_req_72@gmail.com', '0947811832', DATEADD(MINUTE, 23, DATEADD(HOUR, 3, DATEADD(DAY, -22, GETDATE()))), 500000),
(1073, 'ORD-MEGA-0073', 1084, 1041, 600000, 0, 600000, 'refunded', 'seepay', DATEADD(MINUTE, 24, DATEADD(HOUR, 2, DATEADD(DAY, 0, GETDATE()))), N'Nguyễn Tâm', 'mega_req_73@gmail.com', '0960732430', DATEADD(MINUTE, 35, DATEADD(HOUR, 17, DATEADD(DAY, -4, GETDATE()))), 600000),
(1074, 'ORD-MEGA-0074', 1074, 1092, 400000, 0, 400000, 'cancelled', 'seepay', NULL, N'Hoàng Lan', 'mega_req_74@gmail.com', '0927626406', DATEADD(MINUTE, 49, DATEADD(HOUR, 20, DATEADD(DAY, -31, GETDATE()))), 400000),
(1075, 'ORD-MEGA-0075', 1005, 1025, 400000, 0, 400000, 'pending', 'seepay', NULL, N'Đỗ Bảo', 'mega_req_75@gmail.com', '0938394874', DATEADD(MINUTE, 55, DATEADD(HOUR, 16, DATEADD(DAY, -18, GETDATE()))), 400000),
(1076, 'ORD-MEGA-0076', 1051, 1087, 300000, 0, 300000, 'pending', 'seepay', NULL, N'Nguyễn Minh', 'mega_req_76@gmail.com', '0968153342', DATEADD(MINUTE, 47, DATEADD(HOUR, 14, DATEADD(DAY, -8, GETDATE()))), 300000),
(1077, 'ORD-MEGA-0077', 1058, 1096, 400000, 0, 400000, 'paid', 'seepay', DATEADD(MINUTE, 36, DATEADD(HOUR, 14, DATEADD(DAY, -7, GETDATE()))), N'Bùi Thành', 'mega_req_77@gmail.com', '0966626367', DATEADD(MINUTE, 1, DATEADD(HOUR, 23, DATEADD(DAY, -36, GETDATE()))), 400000),
(1078, 'ORD-MEGA-0078', 1021, 1045, 200000, 0, 200000, 'refunded', 'seepay', DATEADD(MINUTE, 37, DATEADD(HOUR, 0, DATEADD(DAY, -36, GETDATE()))), N'Trần Linh', 'mega_req_78@gmail.com', '0999982057', DATEADD(MINUTE, 8, DATEADD(HOUR, 9, DATEADD(DAY, -43, GETDATE()))), 200000),
(1079, 'ORD-MEGA-0079', 1027, 1016, 400000, 0, 400000, 'refunded', 'seepay', DATEADD(MINUTE, 51, DATEADD(HOUR, 8, DATEADD(DAY, -38, GETDATE()))), N'Nguyễn Vân', 'mega_req_79@gmail.com', '0912216832', DATEADD(MINUTE, 59, DATEADD(HOUR, 0, DATEADD(DAY, -55, GETDATE()))), 400000),
(1080, 'ORD-MEGA-0080', 1044, 1002, 600000, 0, 600000, 'pending', 'seepay', NULL, N'Đỗ Khoa', 'mega_req_80@gmail.com', '0948677405', DATEADD(MINUTE, 19, DATEADD(HOUR, 9, DATEADD(DAY, -40, GETDATE()))), 600000),
(1081, 'ORD-MEGA-0081', 1082, 1082, 500000, 0, 500000, 'paid', 'seepay', DATEADD(MINUTE, 46, DATEADD(HOUR, 12, DATEADD(DAY, -52, GETDATE()))), N'Đỗ Trang', 'mega_req_81@gmail.com', '0920155789', DATEADD(MINUTE, 43, DATEADD(HOUR, 3, DATEADD(DAY, -23, GETDATE()))), 500000),
(1082, 'ORD-MEGA-0082', 1012, 1047, 500000, 0, 500000, 'paid', 'seepay', DATEADD(MINUTE, 6, DATEADD(HOUR, 21, DATEADD(DAY, -53, GETDATE()))), N'Đặng Linh', 'mega_req_82@gmail.com', '0973166138', DATEADD(MINUTE, 7, DATEADD(HOUR, 5, DATEADD(DAY, -42, GETDATE()))), 500000),
(1083, 'ORD-MEGA-0083', 1093, 1040, 2000000, 0, 2000000, 'paid', 'seepay', DATEADD(MINUTE, 32, DATEADD(HOUR, 4, DATEADD(DAY, -15, GETDATE()))), N'Hoàng Minh', 'mega_req_83@gmail.com', '0994990079', DATEADD(MINUTE, 35, DATEADD(HOUR, 14, DATEADD(DAY, -45, GETDATE()))), 2000000),
(1084, 'ORD-MEGA-0084', 1099, 1094, 150000, 0, 150000, 'pending', 'seepay', NULL, N'Nguyễn Tâm', 'mega_req_84@gmail.com', '0950320775', DATEADD(MINUTE, 28, DATEADD(HOUR, 11, DATEADD(DAY, -15, GETDATE()))), 150000),
(1085, 'ORD-MEGA-0085', 1042, 1081, 600000, 0, 600000, 'pending', 'seepay', NULL, N'Vũ Linh', 'mega_req_85@gmail.com', '0953494583', DATEADD(MINUTE, 43, DATEADD(HOUR, 23, DATEADD(DAY, -12, GETDATE()))), 600000),
(1086, 'ORD-MEGA-0086', 1039, 1057, 150000, 0, 150000, 'paid', 'seepay', DATEADD(MINUTE, 26, DATEADD(HOUR, 22, DATEADD(DAY, -52, GETDATE()))), N'Lê Minh', 'mega_req_86@gmail.com', '0946104481', DATEADD(MINUTE, 36, DATEADD(HOUR, 19, DATEADD(DAY, -13, GETDATE()))), 150000),
(1087, 'ORD-MEGA-0087', 1097, 1082, 2000000, 0, 2000000, 'paid', 'seepay', DATEADD(MINUTE, 14, DATEADD(HOUR, 19, DATEADD(DAY, -11, GETDATE()))), N'Phạm Linh', 'mega_req_87@gmail.com', '0983008593', DATEADD(MINUTE, 24, DATEADD(HOUR, 7, DATEADD(DAY, -21, GETDATE()))), 2000000),
(1088, 'ORD-MEGA-0088', 1090, 1079, 500000, 0, 500000, 'paid', 'seepay', DATEADD(MINUTE, 2, DATEADD(HOUR, 1, DATEADD(DAY, -38, GETDATE()))), N'Huỳnh Bảo', 'mega_req_88@gmail.com', '0972110105', DATEADD(MINUTE, 26, DATEADD(HOUR, 21, DATEADD(DAY, -46, GETDATE()))), 500000),
(1089, 'ORD-MEGA-0089', 1016, 1036, 500000, 0, 500000, 'paid', 'seepay', DATEADD(MINUTE, 13, DATEADD(HOUR, 12, DATEADD(DAY, -11, GETDATE()))), N'Trần Bảo', 'mega_req_89@gmail.com', '0991985405', DATEADD(MINUTE, 31, DATEADD(HOUR, 1, DATEADD(DAY, -3, GETDATE()))), 500000),
(1090, 'ORD-MEGA-0090', 1061, 1004, 1000000, 0, 1000000, 'paid', 'seepay', DATEADD(MINUTE, 32, DATEADD(HOUR, 1, DATEADD(DAY, -2, GETDATE()))), N'Đặng Minh', 'mega_req_90@gmail.com', '0937177231', DATEADD(MINUTE, 9, DATEADD(HOUR, 23, DATEADD(DAY, -29, GETDATE()))), 1000000),
(1091, 'ORD-MEGA-0091', 1023, 1053, 450000, 0, 450000, 'cancelled', 'seepay', NULL, N'Trần Lan', 'mega_req_91@gmail.com', '0929160726', DATEADD(MINUTE, 58, DATEADD(HOUR, 10, DATEADD(DAY, 0, GETDATE()))), 450000),
(1092, 'ORD-MEGA-0092', 1033, 1060, 500000, 0, 500000, 'refunded', 'seepay', DATEADD(MINUTE, 37, DATEADD(HOUR, 20, DATEADD(DAY, -16, GETDATE()))), N'Bùi Bảo', 'mega_req_92@gmail.com', '0997841068', DATEADD(MINUTE, 34, DATEADD(HOUR, 2, DATEADD(DAY, -31, GETDATE()))), 500000),
(1093, 'ORD-MEGA-0093', 1042, 1006, 2000000, 0, 2000000, 'refunded', 'seepay', DATEADD(MINUTE, 54, DATEADD(HOUR, 0, DATEADD(DAY, -4, GETDATE()))), N'Huỳnh Thu', 'mega_req_93@gmail.com', '0967615960', DATEADD(MINUTE, 57, DATEADD(HOUR, 11, DATEADD(DAY, -2, GETDATE()))), 2000000),
(1094, 'ORD-MEGA-0094', 1044, 1059, 600000, 0, 600000, 'paid', 'seepay', DATEADD(MINUTE, 44, DATEADD(HOUR, 23, DATEADD(DAY, -34, GETDATE()))), N'Vũ Thành', 'mega_req_94@gmail.com', '0910095725', DATEADD(MINUTE, 36, DATEADD(HOUR, 3, DATEADD(DAY, -41, GETDATE()))), 600000),
(1095, 'ORD-MEGA-0095', 1035, 1041, 600000, 0, 600000, 'paid', 'seepay', DATEADD(MINUTE, 2, DATEADD(HOUR, 13, DATEADD(DAY, -29, GETDATE()))), N'Huỳnh Phong', 'mega_req_95@gmail.com', '0916236636', DATEADD(MINUTE, 7, DATEADD(HOUR, 13, DATEADD(DAY, -18, GETDATE()))), 600000),
(1096, 'ORD-MEGA-0096', 1050, 1085, 200000, 0, 200000, 'paid', 'seepay', DATEADD(MINUTE, 13, DATEADD(HOUR, 7, DATEADD(DAY, -7, GETDATE()))), N'Lê Thu', 'mega_req_96@gmail.com', '0955365174', DATEADD(MINUTE, 25, DATEADD(HOUR, 14, DATEADD(DAY, -37, GETDATE()))), 200000),
(1097, 'ORD-MEGA-0097', 1006, 1083, 500000, 0, 500000, 'pending', 'seepay', NULL, N'Đặng Thành', 'mega_req_97@gmail.com', '0952377114', DATEADD(MINUTE, 17, DATEADD(HOUR, 7, DATEADD(DAY, -1, GETDATE()))), 500000),
(1098, 'ORD-MEGA-0098', 1034, 1035, 600000, 0, 600000, 'pending', 'seepay', NULL, N'Đặng Hải', 'mega_req_98@gmail.com', '0924980006', DATEADD(MINUTE, 44, DATEADD(HOUR, 10, DATEADD(DAY, -19, GETDATE()))), 600000),
(1099, 'ORD-MEGA-0099', 1061, 1056, 300000, 0, 300000, 'refunded', 'seepay', DATEADD(MINUTE, 56, DATEADD(HOUR, 22, DATEADD(DAY, -12, GETDATE()))), N'Phạm Thu', 'mega_req_99@gmail.com', '0925546249', DATEADD(MINUTE, 56, DATEADD(HOUR, 20, DATEADD(DAY, -48, GETDATE()))), 300000);
INSERT INTO Orders (order_id, order_code, user_id, event_id, total_amount, discount_amount, final_amount, status, payment_method, payment_date, buyer_name, buyer_email, buyer_phone, created_at, organizer_payout_amount) VALUES
(1100, 'ORD-MEGA-0100', 1084, 1093, 400000, 0, 400000, 'paid', 'seepay', DATEADD(MINUTE, 35, DATEADD(HOUR, 10, DATEADD(DAY, -19, GETDATE()))), N'Trần Minh', 'mega_req_100@gmail.com', '0948256621', DATEADD(MINUTE, 28, DATEADD(HOUR, 22, DATEADD(DAY, -11, GETDATE()))), 400000),
(1101, 'ORD-MEGA-0101', 1017, 1047, 600000, 0, 600000, 'cancelled', 'seepay', NULL, N'Nguyễn Hải', 'mega_req_101@gmail.com', '0973657850', DATEADD(MINUTE, 50, DATEADD(HOUR, 18, DATEADD(DAY, -4, GETDATE()))), 600000),
(1102, 'ORD-MEGA-0102', 1053, 1009, 2000000, 0, 2000000, 'paid', 'seepay', DATEADD(MINUTE, 41, DATEADD(HOUR, 6, DATEADD(DAY, -7, GETDATE()))), N'Bùi Tâm', 'mega_req_102@gmail.com', '0968170409', DATEADD(MINUTE, 11, DATEADD(HOUR, 11, DATEADD(DAY, -6, GETDATE()))), 2000000),
(1103, 'ORD-MEGA-0103', 1024, 1043, 200000, 0, 200000, 'refunded', 'seepay', DATEADD(MINUTE, 40, DATEADD(HOUR, 4, DATEADD(DAY, -49, GETDATE()))), N'Nguyễn Vân', 'mega_req_103@gmail.com', '0910735787', DATEADD(MINUTE, 25, DATEADD(HOUR, 11, DATEADD(DAY, -24, GETDATE()))), 200000),
(1104, 'ORD-MEGA-0104', 1016, 1017, 300000, 0, 300000, 'paid', 'seepay', DATEADD(MINUTE, 53, DATEADD(HOUR, 8, DATEADD(DAY, -17, GETDATE()))), N'Hoàng Vân', 'mega_req_104@gmail.com', '0964744329', DATEADD(MINUTE, 28, DATEADD(HOUR, 17, DATEADD(DAY, -10, GETDATE()))), 300000),
(1105, 'ORD-MEGA-0105', 1017, 1060, 1000000, 0, 1000000, 'paid', 'seepay', DATEADD(MINUTE, 35, DATEADD(HOUR, 1, DATEADD(DAY, -5, GETDATE()))), N'Hoàng Khoa', 'mega_req_105@gmail.com', '0987775977', DATEADD(MINUTE, 51, DATEADD(HOUR, 10, DATEADD(DAY, -34, GETDATE()))), 1000000),
(1106, 'ORD-MEGA-0106', 1047, 1061, 450000, 0, 450000, 'paid', 'seepay', DATEADD(MINUTE, 2, DATEADD(HOUR, 17, DATEADD(DAY, -27, GETDATE()))), N'Huỳnh Trang', 'mega_req_106@gmail.com', '0939869746', DATEADD(MINUTE, 8, DATEADD(HOUR, 6, DATEADD(DAY, -36, GETDATE()))), 450000),
(1107, 'ORD-MEGA-0107', 1023, 1018, 300000, 0, 300000, 'cancelled', 'seepay', NULL, N'Đỗ Khoa', 'mega_req_107@gmail.com', '0965461108', DATEADD(MINUTE, 36, DATEADD(HOUR, 2, DATEADD(DAY, -10, GETDATE()))), 300000),
(1108, 'ORD-MEGA-0108', 1040, 1031, 300000, 0, 300000, 'cancelled', 'seepay', NULL, N'Huỳnh Bảo', 'mega_req_108@gmail.com', '0987122612', DATEADD(MINUTE, 9, DATEADD(HOUR, 2, DATEADD(DAY, -42, GETDATE()))), 300000),
(1109, 'ORD-MEGA-0109', 1070, 1070, 500000, 0, 500000, 'cancelled', 'seepay', NULL, N'Đỗ Bảo', 'mega_req_109@gmail.com', '0954422608', DATEADD(MINUTE, 38, DATEADD(HOUR, 8, DATEADD(DAY, -46, GETDATE()))), 500000),
(1110, 'ORD-MEGA-0110', 1064, 1077, 200000, 0, 200000, 'paid', 'seepay', DATEADD(MINUTE, 24, DATEADD(HOUR, 19, DATEADD(DAY, -45, GETDATE()))), N'Hoàng Vân', 'mega_req_110@gmail.com', '0948473053', DATEADD(MINUTE, 57, DATEADD(HOUR, 2, DATEADD(DAY, -30, GETDATE()))), 200000),
(1111, 'ORD-MEGA-0111', 1092, 1003, 200000, 0, 200000, 'pending', 'seepay', NULL, N'Bùi Hùng', 'mega_req_111@gmail.com', '0999781156', DATEADD(MINUTE, 14, DATEADD(HOUR, 20, DATEADD(DAY, -29, GETDATE()))), 200000),
(1112, 'ORD-MEGA-0112', 1064, 1039, 600000, 0, 600000, 'cancelled', 'seepay', NULL, N'Đặng Khoa', 'mega_req_112@gmail.com', '0991109512', DATEADD(MINUTE, 59, DATEADD(HOUR, 15, DATEADD(DAY, -37, GETDATE()))), 600000),
(1113, 'ORD-MEGA-0113', 1098, 1082, 2000000, 0, 2000000, 'cancelled', 'seepay', NULL, N'Lê Tâm', 'mega_req_113@gmail.com', '0921289561', DATEADD(MINUTE, 24, DATEADD(HOUR, 3, DATEADD(DAY, -55, GETDATE()))), 2000000),
(1114, 'ORD-MEGA-0114', 1099, 1025, 150000, 0, 150000, 'cancelled', 'seepay', NULL, N'Đặng Khoa', 'mega_req_114@gmail.com', '0950019861', DATEADD(MINUTE, 50, DATEADD(HOUR, 16, DATEADD(DAY, -19, GETDATE()))), 150000),
(1115, 'ORD-MEGA-0115', 1019, 1031, 600000, 0, 600000, 'pending', 'seepay', NULL, N'Lê Anh', 'mega_req_115@gmail.com', '0974506421', DATEADD(MINUTE, 35, DATEADD(HOUR, 16, DATEADD(DAY, -16, GETDATE()))), 600000),
(1116, 'ORD-MEGA-0116', 1015, 1072, 600000, 0, 600000, 'paid', 'seepay', DATEADD(MINUTE, 56, DATEADD(HOUR, 12, DATEADD(DAY, -22, GETDATE()))), N'Đỗ Minh', 'mega_req_116@gmail.com', '0998682607', DATEADD(MINUTE, 43, DATEADD(HOUR, 4, DATEADD(DAY, -55, GETDATE()))), 600000),
(1117, 'ORD-MEGA-0117', 1069, 1061, 500000, 0, 500000, 'paid', 'seepay', DATEADD(MINUTE, 10, DATEADD(HOUR, 17, DATEADD(DAY, -25, GETDATE()))), N'Trần Bảo', 'mega_req_117@gmail.com', '0975751569', DATEADD(MINUTE, 59, DATEADD(HOUR, 15, DATEADD(DAY, -31, GETDATE()))), 500000),
(1118, 'ORD-MEGA-0118', 1068, 1042, 1000000, 0, 1000000, 'paid', 'seepay', DATEADD(MINUTE, 6, DATEADD(HOUR, 14, DATEADD(DAY, -10, GETDATE()))), N'Phạm Linh', 'mega_req_118@gmail.com', '0924665691', DATEADD(MINUTE, 52, DATEADD(HOUR, 13, DATEADD(DAY, -15, GETDATE()))), 1000000),
(1119, 'ORD-MEGA-0119', 1096, 1098, 1500000, 0, 1500000, 'pending', 'seepay', NULL, N'Đỗ Anh', 'mega_req_119@gmail.com', '0998474510', DATEADD(MINUTE, 49, DATEADD(HOUR, 5, DATEADD(DAY, -22, GETDATE()))), 1500000),
(1120, 'ORD-MEGA-0120', 1049, 1050, 2000000, 0, 2000000, 'refunded', 'seepay', DATEADD(MINUTE, 6, DATEADD(HOUR, 17, DATEADD(DAY, -51, GETDATE()))), N'Nguyễn Thu', 'mega_req_120@gmail.com', '0946853685', DATEADD(MINUTE, 12, DATEADD(HOUR, 13, DATEADD(DAY, -11, GETDATE()))), 2000000),
(1121, 'ORD-MEGA-0121', 1075, 1060, 150000, 0, 150000, 'pending', 'seepay', NULL, N'Lê Tâm', 'mega_req_121@gmail.com', '0946336528', DATEADD(MINUTE, 26, DATEADD(HOUR, 23, DATEADD(DAY, -22, GETDATE()))), 150000),
(1122, 'ORD-MEGA-0122', 1065, 1081, 1500000, 0, 1500000, 'cancelled', 'seepay', NULL, N'Nguyễn Anh', 'mega_req_122@gmail.com', '0924280988', DATEADD(MINUTE, 23, DATEADD(HOUR, 7, DATEADD(DAY, -9, GETDATE()))), 1500000),
(1123, 'ORD-MEGA-0123', 1066, 1072, 150000, 0, 150000, 'pending', 'seepay', NULL, N'Lê Hùng', 'mega_req_123@gmail.com', '0942131470', DATEADD(MINUTE, 49, DATEADD(HOUR, 16, DATEADD(DAY, -37, GETDATE()))), 150000),
(1124, 'ORD-MEGA-0124', 1047, 1006, 200000, 0, 200000, 'paid', 'seepay', DATEADD(MINUTE, 18, DATEADD(HOUR, 4, DATEADD(DAY, -47, GETDATE()))), N'Nguyễn Thu', 'mega_req_124@gmail.com', '0910443956', DATEADD(MINUTE, 34, DATEADD(HOUR, 0, DATEADD(DAY, -58, GETDATE()))), 200000),
(1125, 'ORD-MEGA-0125', 1069, 1012, 1500000, 0, 1500000, 'cancelled', 'seepay', NULL, N'Đỗ Lan', 'mega_req_125@gmail.com', '0929197999', DATEADD(MINUTE, 29, DATEADD(HOUR, 14, DATEADD(DAY, -52, GETDATE()))), 1500000),
(1126, 'ORD-MEGA-0126', 1030, 1090, 450000, 0, 450000, 'paid', 'seepay', DATEADD(MINUTE, 41, DATEADD(HOUR, 22, DATEADD(DAY, -4, GETDATE()))), N'Đặng Thu', 'mega_req_126@gmail.com', '0970521067', DATEADD(MINUTE, 59, DATEADD(HOUR, 13, DATEADD(DAY, -41, GETDATE()))), 450000),
(1127, 'ORD-MEGA-0127', 1054, 1045, 600000, 0, 600000, 'pending', 'seepay', NULL, N'Lê Lan', 'mega_req_127@gmail.com', '0952981753', DATEADD(MINUTE, 22, DATEADD(HOUR, 15, DATEADD(DAY, -49, GETDATE()))), 600000),
(1128, 'ORD-MEGA-0128', 1010, 1044, 150000, 0, 150000, 'paid', 'seepay', DATEADD(MINUTE, 30, DATEADD(HOUR, 18, DATEADD(DAY, -58, GETDATE()))), N'Trần Thu', 'mega_req_128@gmail.com', '0954355769', DATEADD(MINUTE, 45, DATEADD(HOUR, 8, DATEADD(DAY, -40, GETDATE()))), 150000),
(1129, 'ORD-MEGA-0129', 1049, 1095, 300000, 0, 300000, 'cancelled', 'seepay', NULL, N'Trần Tâm', 'mega_req_129@gmail.com', '0954876968', DATEADD(MINUTE, 25, DATEADD(HOUR, 17, DATEADD(DAY, -22, GETDATE()))), 300000),
(1130, 'ORD-MEGA-0130', 1047, 1038, 150000, 0, 150000, 'paid', 'seepay', DATEADD(MINUTE, 34, DATEADD(HOUR, 18, DATEADD(DAY, -31, GETDATE()))), N'Vũ Bảo', 'mega_req_130@gmail.com', '0926956329', DATEADD(MINUTE, 41, DATEADD(HOUR, 9, DATEADD(DAY, -2, GETDATE()))), 150000),
(1131, 'ORD-MEGA-0131', 1081, 1028, 2000000, 0, 2000000, 'paid', 'seepay', DATEADD(MINUTE, 31, DATEADD(HOUR, 5, DATEADD(DAY, -24, GETDATE()))), N'Lê Kiên', 'mega_req_131@gmail.com', '0984954420', DATEADD(MINUTE, 26, DATEADD(HOUR, 20, DATEADD(DAY, -32, GETDATE()))), 2000000),
(1132, 'ORD-MEGA-0132', 1072, 1007, 600000, 0, 600000, 'paid', 'seepay', DATEADD(MINUTE, 21, DATEADD(HOUR, 1, DATEADD(DAY, -41, GETDATE()))), N'Bùi Trang', 'mega_req_132@gmail.com', '0945238659', DATEADD(MINUTE, 59, DATEADD(HOUR, 9, DATEADD(DAY, -40, GETDATE()))), 600000),
(1133, 'ORD-MEGA-0133', 1089, 1020, 600000, 0, 600000, 'paid', 'seepay', DATEADD(MINUTE, 39, DATEADD(HOUR, 10, DATEADD(DAY, -40, GETDATE()))), N'Lê Anh', 'mega_req_133@gmail.com', '0939451514', DATEADD(MINUTE, 53, DATEADD(HOUR, 13, DATEADD(DAY, -36, GETDATE()))), 600000),
(1134, 'ORD-MEGA-0134', 1072, 1052, 200000, 0, 200000, 'paid', 'seepay', DATEADD(MINUTE, 40, DATEADD(HOUR, 6, DATEADD(DAY, -7, GETDATE()))), N'Đặng Hải', 'mega_req_134@gmail.com', '0936493109', DATEADD(MINUTE, 29, DATEADD(HOUR, 19, DATEADD(DAY, -40, GETDATE()))), 200000),
(1135, 'ORD-MEGA-0135', 1078, 1006, 450000, 0, 450000, 'refunded', 'seepay', DATEADD(MINUTE, 10, DATEADD(HOUR, 13, DATEADD(DAY, -52, GETDATE()))), N'Trần Kiên', 'mega_req_135@gmail.com', '0928255222', DATEADD(MINUTE, 13, DATEADD(HOUR, 21, DATEADD(DAY, -3, GETDATE()))), 450000),
(1136, 'ORD-MEGA-0136', 1057, 1048, 500000, 0, 500000, 'paid', 'seepay', DATEADD(MINUTE, 26, DATEADD(HOUR, 8, DATEADD(DAY, -18, GETDATE()))), N'Bùi Linh', 'mega_req_136@gmail.com', '0910900717', DATEADD(MINUTE, 10, DATEADD(HOUR, 2, DATEADD(DAY, -15, GETDATE()))), 500000),
(1137, 'ORD-MEGA-0137', 1038, 1045, 1000000, 0, 1000000, 'paid', 'seepay', DATEADD(MINUTE, 27, DATEADD(HOUR, 10, DATEADD(DAY, -57, GETDATE()))), N'Phạm Tâm', 'mega_req_137@gmail.com', '0974531676', DATEADD(MINUTE, 48, DATEADD(HOUR, 12, DATEADD(DAY, -56, GETDATE()))), 1000000),
(1138, 'ORD-MEGA-0138', 1004, 1082, 800000, 0, 800000, 'paid', 'seepay', DATEADD(MINUTE, 43, DATEADD(HOUR, 6, DATEADD(DAY, -39, GETDATE()))), N'Nguyễn Thu', 'mega_req_138@gmail.com', '0976069845', DATEADD(MINUTE, 5, DATEADD(HOUR, 7, DATEADD(DAY, -46, GETDATE()))), 800000),
(1139, 'ORD-MEGA-0139', 1059, 1076, 500000, 0, 500000, 'pending', 'seepay', NULL, N'Bùi Minh', 'mega_req_139@gmail.com', '0956988651', DATEADD(MINUTE, 3, DATEADD(HOUR, 0, DATEADD(DAY, -21, GETDATE()))), 500000),
(1140, 'ORD-MEGA-0140', 1088, 1065, 600000, 0, 600000, 'pending', 'seepay', NULL, N'Vũ Bảo', 'mega_req_140@gmail.com', '0959852997', DATEADD(MINUTE, 47, DATEADD(HOUR, 13, DATEADD(DAY, -59, GETDATE()))), 600000),
(1141, 'ORD-MEGA-0141', 1023, 1012, 600000, 0, 600000, 'paid', 'seepay', DATEADD(MINUTE, 48, DATEADD(HOUR, 16, DATEADD(DAY, -56, GETDATE()))), N'Hoàng Kiên', 'mega_req_141@gmail.com', '0962173852', DATEADD(MINUTE, 48, DATEADD(HOUR, 23, DATEADD(DAY, -40, GETDATE()))), 600000),
(1142, 'ORD-MEGA-0142', 1032, 1073, 2000000, 0, 2000000, 'refunded', 'seepay', DATEADD(MINUTE, 26, DATEADD(HOUR, 2, DATEADD(DAY, -15, GETDATE()))), N'Trần Hùng', 'mega_req_142@gmail.com', '0955353455', DATEADD(MINUTE, 52, DATEADD(HOUR, 0, DATEADD(DAY, -44, GETDATE()))), 2000000),
(1143, 'ORD-MEGA-0143', 1036, 1002, 1500000, 0, 1500000, 'pending', 'seepay', NULL, N'Trần Hùng', 'mega_req_143@gmail.com', '0982743727', DATEADD(MINUTE, 34, DATEADD(HOUR, 8, DATEADD(DAY, -50, GETDATE()))), 1500000),
(1144, 'ORD-MEGA-0144', 1009, 1040, 600000, 0, 600000, 'pending', 'seepay', NULL, N'Đặng Kiên', 'mega_req_144@gmail.com', '0925389255', DATEADD(MINUTE, 24, DATEADD(HOUR, 1, DATEADD(DAY, -25, GETDATE()))), 600000),
(1145, 'ORD-MEGA-0145', 1029, 1092, 500000, 0, 500000, 'paid', 'seepay', DATEADD(MINUTE, 29, DATEADD(HOUR, 10, DATEADD(DAY, -38, GETDATE()))), N'Nguyễn Lan', 'mega_req_145@gmail.com', '0976130108', DATEADD(MINUTE, 24, DATEADD(HOUR, 15, DATEADD(DAY, -17, GETDATE()))), 500000),
(1146, 'ORD-MEGA-0146', 1046, 1074, 800000, 0, 800000, 'paid', 'seepay', DATEADD(MINUTE, 28, DATEADD(HOUR, 9, DATEADD(DAY, -32, GETDATE()))), N'Phạm Vân', 'mega_req_146@gmail.com', '0968731210', DATEADD(MINUTE, 16, DATEADD(HOUR, 7, DATEADD(DAY, -52, GETDATE()))), 800000),
(1147, 'ORD-MEGA-0147', 1062, 1075, 500000, 0, 500000, 'pending', 'seepay', NULL, N'Nguyễn Thu', 'mega_req_147@gmail.com', '0918875664', DATEADD(MINUTE, 15, DATEADD(HOUR, 13, DATEADD(DAY, -33, GETDATE()))), 500000),
(1148, 'ORD-MEGA-0148', 1000, 1042, 150000, 0, 150000, 'paid', 'seepay', DATEADD(MINUTE, 41, DATEADD(HOUR, 6, DATEADD(DAY, -60, GETDATE()))), N'Vũ Khoa', 'mega_req_148@gmail.com', '0945280082', DATEADD(MINUTE, 45, DATEADD(HOUR, 0, DATEADD(DAY, -45, GETDATE()))), 150000),
(1149, 'ORD-MEGA-0149', 1002, 1057, 600000, 0, 600000, 'refunded', 'seepay', DATEADD(MINUTE, 12, DATEADD(HOUR, 10, DATEADD(DAY, -52, GETDATE()))), N'Đỗ Thu', 'mega_req_149@gmail.com', '0943920664', DATEADD(MINUTE, 22, DATEADD(HOUR, 0, DATEADD(DAY, -25, GETDATE()))), 600000),
(1150, 'ORD-MEGA-0150', 1040, 1010, 300000, 0, 300000, 'paid', 'seepay', DATEADD(MINUTE, 39, DATEADD(HOUR, 0, DATEADD(DAY, -14, GETDATE()))), N'Trần Trang', 'mega_req_150@gmail.com', '0993910436', DATEADD(MINUTE, 10, DATEADD(HOUR, 12, DATEADD(DAY, -8, GETDATE()))), 300000),
(1151, 'ORD-MEGA-0151', 1082, 1070, 450000, 0, 450000, 'paid', 'seepay', DATEADD(MINUTE, 54, DATEADD(HOUR, 15, DATEADD(DAY, -60, GETDATE()))), N'Phạm Lan', 'mega_req_151@gmail.com', '0914349021', DATEADD(MINUTE, 56, DATEADD(HOUR, 7, DATEADD(DAY, -52, GETDATE()))), 450000),
(1152, 'ORD-MEGA-0152', 1041, 1030, 1000000, 0, 1000000, 'paid', 'seepay', DATEADD(MINUTE, 38, DATEADD(HOUR, 10, DATEADD(DAY, -9, GETDATE()))), N'Trần Khoa', 'mega_req_152@gmail.com', '0967591286', DATEADD(MINUTE, 48, DATEADD(HOUR, 14, DATEADD(DAY, -50, GETDATE()))), 1000000),
(1153, 'ORD-MEGA-0153', 1028, 1098, 600000, 0, 600000, 'pending', 'seepay', NULL, N'Lê Hùng', 'mega_req_153@gmail.com', '0921502626', DATEADD(MINUTE, 29, DATEADD(HOUR, 16, DATEADD(DAY, -14, GETDATE()))), 600000),
(1154, 'ORD-MEGA-0154', 1065, 1096, 1000000, 0, 1000000, 'pending', 'seepay', NULL, N'Hoàng Hùng', 'mega_req_154@gmail.com', '0967193609', DATEADD(MINUTE, 3, DATEADD(HOUR, 12, DATEADD(DAY, -21, GETDATE()))), 1000000),
(1155, 'ORD-MEGA-0155', 1070, 1079, 200000, 0, 200000, 'paid', 'seepay', DATEADD(MINUTE, 15, DATEADD(HOUR, 10, DATEADD(DAY, -29, GETDATE()))), N'Đỗ Tâm', 'mega_req_155@gmail.com', '0982135025', DATEADD(MINUTE, 9, DATEADD(HOUR, 8, DATEADD(DAY, -11, GETDATE()))), 200000),
(1156, 'ORD-MEGA-0156', 1011, 1053, 1500000, 0, 1500000, 'cancelled', 'seepay', NULL, N'Huỳnh Trang', 'mega_req_156@gmail.com', '0963520116', DATEADD(MINUTE, 42, DATEADD(HOUR, 17, DATEADD(DAY, -42, GETDATE()))), 1500000),
(1157, 'ORD-MEGA-0157', 1049, 1096, 300000, 0, 300000, 'pending', 'seepay', NULL, N'Hoàng Linh', 'mega_req_157@gmail.com', '0917398132', DATEADD(MINUTE, 56, DATEADD(HOUR, 3, DATEADD(DAY, -45, GETDATE()))), 300000),
(1158, 'ORD-MEGA-0158', 1056, 1010, 2000000, 0, 2000000, 'cancelled', 'seepay', NULL, N'Đỗ Tâm', 'mega_req_158@gmail.com', '0913375232', DATEADD(MINUTE, 22, DATEADD(HOUR, 6, DATEADD(DAY, -60, GETDATE()))), 2000000),
(1159, 'ORD-MEGA-0159', 1065, 1048, 400000, 0, 400000, 'refunded', 'seepay', DATEADD(MINUTE, 0, DATEADD(HOUR, 22, DATEADD(DAY, -9, GETDATE()))), N'Huỳnh Vân', 'mega_req_159@gmail.com', '0991311443', DATEADD(MINUTE, 40, DATEADD(HOUR, 9, DATEADD(DAY, -41, GETDATE()))), 400000),
(1160, 'ORD-MEGA-0160', 1061, 1014, 1000000, 0, 1000000, 'refunded', 'seepay', DATEADD(MINUTE, 24, DATEADD(HOUR, 22, DATEADD(DAY, -13, GETDATE()))), N'Bùi Bảo', 'mega_req_160@gmail.com', '0936275339', DATEADD(MINUTE, 32, DATEADD(HOUR, 5, DATEADD(DAY, -55, GETDATE()))), 1000000),
(1161, 'ORD-MEGA-0161', 1077, 1014, 2000000, 0, 2000000, 'pending', 'seepay', NULL, N'Lê Thu', 'mega_req_161@gmail.com', '0926256545', DATEADD(MINUTE, 51, DATEADD(HOUR, 4, DATEADD(DAY, -52, GETDATE()))), 2000000),
(1162, 'ORD-MEGA-0162', 1032, 1076, 2000000, 0, 2000000, 'paid', 'seepay', DATEADD(MINUTE, 21, DATEADD(HOUR, 10, DATEADD(DAY, -41, GETDATE()))), N'Đặng Trang', 'mega_req_162@gmail.com', '0999803910', DATEADD(MINUTE, 24, DATEADD(HOUR, 9, DATEADD(DAY, -28, GETDATE()))), 2000000),
(1163, 'ORD-MEGA-0163', 1081, 1051, 150000, 0, 150000, 'paid', 'seepay', DATEADD(MINUTE, 57, DATEADD(HOUR, 12, DATEADD(DAY, -51, GETDATE()))), N'Huỳnh Hùng', 'mega_req_163@gmail.com', '0915902748', DATEADD(MINUTE, 36, DATEADD(HOUR, 3, DATEADD(DAY, -47, GETDATE()))), 150000),
(1164, 'ORD-MEGA-0164', 1035, 1002, 300000, 0, 300000, 'paid', 'seepay', DATEADD(MINUTE, 22, DATEADD(HOUR, 6, DATEADD(DAY, -58, GETDATE()))), N'Trần Minh', 'mega_req_164@gmail.com', '0962240574', DATEADD(MINUTE, 36, DATEADD(HOUR, 20, DATEADD(DAY, -58, GETDATE()))), 300000),
(1165, 'ORD-MEGA-0165', 1007, 1013, 600000, 0, 600000, 'cancelled', 'seepay', NULL, N'Bùi Hải', 'mega_req_165@gmail.com', '0956458045', DATEADD(MINUTE, 56, DATEADD(HOUR, 3, DATEADD(DAY, -23, GETDATE()))), 600000),
(1166, 'ORD-MEGA-0166', 1010, 1089, 800000, 0, 800000, 'paid', 'seepay', DATEADD(MINUTE, 9, DATEADD(HOUR, 12, DATEADD(DAY, -47, GETDATE()))), N'Bùi Thu', 'mega_req_166@gmail.com', '0974265469', DATEADD(MINUTE, 20, DATEADD(HOUR, 9, DATEADD(DAY, -53, GETDATE()))), 800000),
(1167, 'ORD-MEGA-0167', 1007, 1043, 1500000, 0, 1500000, 'cancelled', 'seepay', NULL, N'Bùi Hải', 'mega_req_167@gmail.com', '0950556123', DATEADD(MINUTE, 56, DATEADD(HOUR, 15, DATEADD(DAY, -16, GETDATE()))), 1500000),
(1168, 'ORD-MEGA-0168', 1070, 1090, 150000, 0, 150000, 'cancelled', 'seepay', NULL, N'Trần Minh', 'mega_req_168@gmail.com', '0951165205', DATEADD(MINUTE, 47, DATEADD(HOUR, 21, DATEADD(DAY, -12, GETDATE()))), 150000),
(1169, 'ORD-MEGA-0169', 1078, 1081, 200000, 0, 200000, 'cancelled', 'seepay', NULL, N'Vũ Bảo', 'mega_req_169@gmail.com', '0917064081', DATEADD(MINUTE, 16, DATEADD(HOUR, 6, DATEADD(DAY, -54, GETDATE()))), 200000),
(1170, 'ORD-MEGA-0170', 1042, 1091, 500000, 0, 500000, 'paid', 'seepay', DATEADD(MINUTE, 57, DATEADD(HOUR, 18, DATEADD(DAY, -53, GETDATE()))), N'Lê Kiên', 'mega_req_170@gmail.com', '0929169810', DATEADD(MINUTE, 10, DATEADD(HOUR, 10, DATEADD(DAY, -1, GETDATE()))), 500000),
(1171, 'ORD-MEGA-0171', 1007, 1028, 1000000, 0, 1000000, 'pending', 'seepay', NULL, N'Bùi Thu', 'mega_req_171@gmail.com', '0997916873', DATEADD(MINUTE, 44, DATEADD(HOUR, 20, DATEADD(DAY, -41, GETDATE()))), 1000000),
(1172, 'ORD-MEGA-0172', 1024, 1054, 200000, 0, 200000, 'paid', 'seepay', DATEADD(MINUTE, 23, DATEADD(HOUR, 7, DATEADD(DAY, -59, GETDATE()))), N'Phạm Thành', 'mega_req_172@gmail.com', '0990879783', DATEADD(MINUTE, 22, DATEADD(HOUR, 20, DATEADD(DAY, -25, GETDATE()))), 200000),
(1173, 'ORD-MEGA-0173', 1051, 1053, 400000, 0, 400000, 'paid', 'seepay', DATEADD(MINUTE, 24, DATEADD(HOUR, 22, DATEADD(DAY, -12, GETDATE()))), N'Đặng Anh', 'mega_req_173@gmail.com', '0964005924', DATEADD(MINUTE, 40, DATEADD(HOUR, 15, DATEADD(DAY, -28, GETDATE()))), 400000),
(1174, 'ORD-MEGA-0174', 1081, 1020, 300000, 0, 300000, 'cancelled', 'seepay', NULL, N'Nguyễn Kiên', 'mega_req_174@gmail.com', '0925892830', DATEADD(MINUTE, 55, DATEADD(HOUR, 20, DATEADD(DAY, -43, GETDATE()))), 300000),
(1175, 'ORD-MEGA-0175', 1044, 1016, 1500000, 0, 1500000, 'paid', 'seepay', DATEADD(MINUTE, 27, DATEADD(HOUR, 6, DATEADD(DAY, -43, GETDATE()))), N'Lê Phong', 'mega_req_175@gmail.com', '0969076426', DATEADD(MINUTE, 57, DATEADD(HOUR, 14, DATEADD(DAY, -33, GETDATE()))), 1500000),
(1176, 'ORD-MEGA-0176', 1098, 1082, 300000, 0, 300000, 'refunded', 'seepay', DATEADD(MINUTE, 0, DATEADD(HOUR, 17, DATEADD(DAY, -1, GETDATE()))), N'Đỗ Hải', 'mega_req_176@gmail.com', '0957168565', DATEADD(MINUTE, 45, DATEADD(HOUR, 10, DATEADD(DAY, -17, GETDATE()))), 300000),
(1177, 'ORD-MEGA-0177', 1097, 1025, 1500000, 0, 1500000, 'cancelled', 'seepay', NULL, N'Vũ Vân', 'mega_req_177@gmail.com', '0915651872', DATEADD(MINUTE, 33, DATEADD(HOUR, 17, DATEADD(DAY, -4, GETDATE()))), 1500000),
(1178, 'ORD-MEGA-0178', 1035, 1019, 300000, 0, 300000, 'pending', 'seepay', NULL, N'Đỗ Kiên', 'mega_req_178@gmail.com', '0993675136', DATEADD(MINUTE, 18, DATEADD(HOUR, 20, DATEADD(DAY, -51, GETDATE()))), 300000),
(1179, 'ORD-MEGA-0179', 1061, 1046, 2000000, 0, 2000000, 'pending', 'seepay', NULL, N'Trần Thu', 'mega_req_179@gmail.com', '0917593293', DATEADD(MINUTE, 29, DATEADD(HOUR, 0, DATEADD(DAY, -25, GETDATE()))), 2000000),
(1180, 'ORD-MEGA-0180', 1039, 1066, 1000000, 0, 1000000, 'paid', 'seepay', DATEADD(MINUTE, 54, DATEADD(HOUR, 21, DATEADD(DAY, -21, GETDATE()))), N'Phạm Khoa', 'mega_req_180@gmail.com', '0953411439', DATEADD(MINUTE, 31, DATEADD(HOUR, 10, DATEADD(DAY, -48, GETDATE()))), 1000000),
(1181, 'ORD-MEGA-0181', 1035, 1059, 200000, 0, 200000, 'pending', 'seepay', NULL, N'Đặng Lan', 'mega_req_181@gmail.com', '0956093819', DATEADD(MINUTE, 59, DATEADD(HOUR, 14, DATEADD(DAY, -25, GETDATE()))), 200000),
(1182, 'ORD-MEGA-0182', 1088, 1033, 300000, 0, 300000, 'paid', 'seepay', DATEADD(MINUTE, 30, DATEADD(HOUR, 16, DATEADD(DAY, -26, GETDATE()))), N'Trần Kiên', 'mega_req_182@gmail.com', '0948035946', DATEADD(MINUTE, 43, DATEADD(HOUR, 22, DATEADD(DAY, 0, GETDATE()))), 300000),
(1183, 'ORD-MEGA-0183', 1068, 1098, 1000000, 0, 1000000, 'pending', 'seepay', NULL, N'Huỳnh Anh', 'mega_req_183@gmail.com', '0977406197', DATEADD(MINUTE, 9, DATEADD(HOUR, 12, DATEADD(DAY, -8, GETDATE()))), 1000000),
(1184, 'ORD-MEGA-0184', 1011, 1090, 500000, 0, 500000, 'refunded', 'seepay', DATEADD(MINUTE, 20, DATEADD(HOUR, 16, DATEADD(DAY, -32, GETDATE()))), N'Huỳnh Trang', 'mega_req_184@gmail.com', '0992693626', DATEADD(MINUTE, 22, DATEADD(HOUR, 20, DATEADD(DAY, -18, GETDATE()))), 500000),
(1185, 'ORD-MEGA-0185', 1028, 1058, 200000, 0, 200000, 'paid', 'seepay', DATEADD(MINUTE, 17, DATEADD(HOUR, 16, DATEADD(DAY, -40, GETDATE()))), N'Hoàng Khoa', 'mega_req_185@gmail.com', '0998178844', DATEADD(MINUTE, 9, DATEADD(HOUR, 21, DATEADD(DAY, -22, GETDATE()))), 200000),
(1186, 'ORD-MEGA-0186', 1058, 1014, 2000000, 0, 2000000, 'paid', 'seepay', DATEADD(MINUTE, 15, DATEADD(HOUR, 20, DATEADD(DAY, -12, GETDATE()))), N'Hoàng Minh', 'mega_req_186@gmail.com', '0932357901', DATEADD(MINUTE, 35, DATEADD(HOUR, 15, DATEADD(DAY, -21, GETDATE()))), 2000000),
(1187, 'ORD-MEGA-0187', 1057, 1024, 150000, 0, 150000, 'cancelled', 'seepay', NULL, N'Huỳnh Vân', 'mega_req_187@gmail.com', '0989107979', DATEADD(MINUTE, 21, DATEADD(HOUR, 7, DATEADD(DAY, -35, GETDATE()))), 150000),
(1188, 'ORD-MEGA-0188', 1063, 1033, 450000, 0, 450000, 'refunded', 'seepay', DATEADD(MINUTE, 10, DATEADD(HOUR, 3, DATEADD(DAY, -11, GETDATE()))), N'Phạm Lan', 'mega_req_188@gmail.com', '0940177491', DATEADD(MINUTE, 16, DATEADD(HOUR, 8, DATEADD(DAY, -23, GETDATE()))), 450000),
(1189, 'ORD-MEGA-0189', 1079, 1022, 2000000, 0, 2000000, 'paid', 'seepay', DATEADD(MINUTE, 16, DATEADD(HOUR, 8, DATEADD(DAY, -7, GETDATE()))), N'Bùi Phong', 'mega_req_189@gmail.com', '0991628367', DATEADD(MINUTE, 12, DATEADD(HOUR, 19, DATEADD(DAY, -41, GETDATE()))), 2000000),
(1190, 'ORD-MEGA-0190', 1087, 1060, 200000, 0, 200000, 'paid', 'seepay', DATEADD(MINUTE, 3, DATEADD(HOUR, 1, DATEADD(DAY, -1, GETDATE()))), N'Vũ Hải', 'mega_req_190@gmail.com', '0937852356', DATEADD(MINUTE, 19, DATEADD(HOUR, 21, DATEADD(DAY, -44, GETDATE()))), 200000),
(1191, 'ORD-MEGA-0191', 1022, 1081, 400000, 0, 400000, 'paid', 'seepay', DATEADD(MINUTE, 15, DATEADD(HOUR, 23, DATEADD(DAY, -46, GETDATE()))), N'Trần Kiên', 'mega_req_191@gmail.com', '0991982912', DATEADD(MINUTE, 7, DATEADD(HOUR, 19, DATEADD(DAY, -38, GETDATE()))), 400000),
(1192, 'ORD-MEGA-0192', 1062, 1078, 400000, 0, 400000, 'refunded', 'seepay', DATEADD(MINUTE, 40, DATEADD(HOUR, 3, DATEADD(DAY, -43, GETDATE()))), N'Phạm Trang', 'mega_req_192@gmail.com', '0928993177', DATEADD(MINUTE, 44, DATEADD(HOUR, 15, DATEADD(DAY, -13, GETDATE()))), 400000),
(1193, 'ORD-MEGA-0193', 1063, 1036, 600000, 0, 600000, 'pending', 'seepay', NULL, N'Lê Phong', 'mega_req_193@gmail.com', '0986865357', DATEADD(MINUTE, 26, DATEADD(HOUR, 8, DATEADD(DAY, -54, GETDATE()))), 600000),
(1194, 'ORD-MEGA-0194', 1036, 1096, 600000, 0, 600000, 'cancelled', 'seepay', NULL, N'Bùi Kiên', 'mega_req_194@gmail.com', '0981589713', DATEADD(MINUTE, 0, DATEADD(HOUR, 23, DATEADD(DAY, -50, GETDATE()))), 600000),
(1195, 'ORD-MEGA-0195', 1084, 1052, 800000, 0, 800000, 'paid', 'seepay', DATEADD(MINUTE, 23, DATEADD(HOUR, 18, DATEADD(DAY, -30, GETDATE()))), N'Trần Kiên', 'mega_req_195@gmail.com', '0942626907', DATEADD(MINUTE, 11, DATEADD(HOUR, 20, DATEADD(DAY, -35, GETDATE()))), 800000),
(1196, 'ORD-MEGA-0196', 1078, 1092, 300000, 0, 300000, 'paid', 'seepay', DATEADD(MINUTE, 1, DATEADD(HOUR, 10, DATEADD(DAY, -19, GETDATE()))), N'Phạm Phong', 'mega_req_196@gmail.com', '0957181622', DATEADD(MINUTE, 31, DATEADD(HOUR, 19, DATEADD(DAY, -55, GETDATE()))), 300000),
(1197, 'ORD-MEGA-0197', 1069, 1032, 1000000, 0, 1000000, 'pending', 'seepay', NULL, N'Đặng Minh', 'mega_req_197@gmail.com', '0988417224', DATEADD(MINUTE, 42, DATEADD(HOUR, 15, DATEADD(DAY, -41, GETDATE()))), 1000000),
(1198, 'ORD-MEGA-0198', 1032, 1033, 150000, 0, 150000, 'pending', 'seepay', NULL, N'Bùi Vân', 'mega_req_198@gmail.com', '0913586358', DATEADD(MINUTE, 50, DATEADD(HOUR, 2, DATEADD(DAY, -3, GETDATE()))), 150000),
(1199, 'ORD-MEGA-0199', 1057, 1002, 800000, 0, 800000, 'pending', 'seepay', NULL, N'Vũ Tâm', 'mega_req_199@gmail.com', '0978134137', DATEADD(MINUTE, 18, DATEADD(HOUR, 7, DATEADD(DAY, -57, GETDATE()))), 800000);
INSERT INTO Orders (order_id, order_code, user_id, event_id, total_amount, discount_amount, final_amount, status, payment_method, payment_date, buyer_name, buyer_email, buyer_phone, created_at, organizer_payout_amount) VALUES
(1200, 'ORD-MEGA-0200', 1009, 1006, 200000, 0, 200000, 'cancelled', 'seepay', NULL, N'Nguyễn Minh', 'mega_req_200@gmail.com', '0950158549', DATEADD(MINUTE, 50, DATEADD(HOUR, 20, DATEADD(DAY, -4, GETDATE()))), 200000),
(1201, 'ORD-MEGA-0201', 1087, 1063, 1500000, 0, 1500000, 'refunded', 'seepay', DATEADD(MINUTE, 25, DATEADD(HOUR, 4, DATEADD(DAY, -14, GETDATE()))), N'Lê Anh', 'mega_req_201@gmail.com', '0983071608', DATEADD(MINUTE, 36, DATEADD(HOUR, 17, DATEADD(DAY, -46, GETDATE()))), 1500000),
(1202, 'ORD-MEGA-0202', 1025, 1033, 2000000, 0, 2000000, 'refunded', 'seepay', DATEADD(MINUTE, 16, DATEADD(HOUR, 22, DATEADD(DAY, -56, GETDATE()))), N'Huỳnh Hải', 'mega_req_202@gmail.com', '0942074080', DATEADD(MINUTE, 21, DATEADD(HOUR, 23, DATEADD(DAY, -41, GETDATE()))), 2000000),
(1203, 'ORD-MEGA-0203', 1048, 1095, 400000, 0, 400000, 'pending', 'seepay', NULL, N'Trần Anh', 'mega_req_203@gmail.com', '0925468007', DATEADD(MINUTE, 16, DATEADD(HOUR, 8, DATEADD(DAY, -37, GETDATE()))), 400000),
(1204, 'ORD-MEGA-0204', 1045, 1091, 450000, 0, 450000, 'pending', 'seepay', NULL, N'Nguyễn Bảo', 'mega_req_204@gmail.com', '0912583815', DATEADD(MINUTE, 18, DATEADD(HOUR, 3, DATEADD(DAY, -51, GETDATE()))), 450000),
(1205, 'ORD-MEGA-0205', 1025, 1010, 1500000, 0, 1500000, 'paid', 'seepay', DATEADD(MINUTE, 14, DATEADD(HOUR, 9, DATEADD(DAY, -25, GETDATE()))), N'Hoàng Bảo', 'mega_req_205@gmail.com', '0928597878', DATEADD(MINUTE, 9, DATEADD(HOUR, 0, DATEADD(DAY, -9, GETDATE()))), 1500000),
(1206, 'ORD-MEGA-0206', 1053, 1017, 150000, 0, 150000, 'pending', 'seepay', NULL, N'Lê Bảo', 'mega_req_206@gmail.com', '0937659063', DATEADD(MINUTE, 1, DATEADD(HOUR, 8, DATEADD(DAY, -24, GETDATE()))), 150000),
(1207, 'ORD-MEGA-0207', 1070, 1008, 800000, 0, 800000, 'paid', 'seepay', DATEADD(MINUTE, 29, DATEADD(HOUR, 15, DATEADD(DAY, -11, GETDATE()))), N'Huỳnh Anh', 'mega_req_207@gmail.com', '0950705468', DATEADD(MINUTE, 26, DATEADD(HOUR, 22, DATEADD(DAY, -34, GETDATE()))), 800000),
(1208, 'ORD-MEGA-0208', 1038, 1022, 600000, 0, 600000, 'pending', 'seepay', NULL, N'Lê Phong', 'mega_req_208@gmail.com', '0959581843', DATEADD(MINUTE, 40, DATEADD(HOUR, 19, DATEADD(DAY, -21, GETDATE()))), 600000),
(1209, 'ORD-MEGA-0209', 1000, 1036, 200000, 0, 200000, 'cancelled', 'seepay', NULL, N'Trần Bảo', 'mega_req_209@gmail.com', '0954646162', DATEADD(MINUTE, 23, DATEADD(HOUR, 15, DATEADD(DAY, -6, GETDATE()))), 200000),
(1210, 'ORD-MEGA-0210', 1055, 1086, 150000, 0, 150000, 'paid', 'seepay', DATEADD(MINUTE, 36, DATEADD(HOUR, 1, DATEADD(DAY, -45, GETDATE()))), N'Đặng Lan', 'mega_req_210@gmail.com', '0983822965', DATEADD(MINUTE, 0, DATEADD(HOUR, 17, DATEADD(DAY, -11, GETDATE()))), 150000),
(1211, 'ORD-MEGA-0211', 1081, 1054, 500000, 0, 500000, 'paid', 'seepay', DATEADD(MINUTE, 24, DATEADD(HOUR, 12, DATEADD(DAY, -56, GETDATE()))), N'Bùi Kiên', 'mega_req_211@gmail.com', '0992257839', DATEADD(MINUTE, 34, DATEADD(HOUR, 14, DATEADD(DAY, -27, GETDATE()))), 500000),
(1212, 'ORD-MEGA-0212', 1080, 1070, 400000, 0, 400000, 'refunded', 'seepay', DATEADD(MINUTE, 7, DATEADD(HOUR, 23, DATEADD(DAY, -28, GETDATE()))), N'Phạm Bảo', 'mega_req_212@gmail.com', '0941259674', DATEADD(MINUTE, 45, DATEADD(HOUR, 3, DATEADD(DAY, -37, GETDATE()))), 400000),
(1213, 'ORD-MEGA-0213', 1084, 1078, 150000, 0, 150000, 'paid', 'seepay', DATEADD(MINUTE, 18, DATEADD(HOUR, 4, DATEADD(DAY, -29, GETDATE()))), N'Hoàng Trang', 'mega_req_213@gmail.com', '0996930204', DATEADD(MINUTE, 28, DATEADD(HOUR, 0, DATEADD(DAY, -53, GETDATE()))), 150000),
(1214, 'ORD-MEGA-0214', 1019, 1018, 200000, 0, 200000, 'paid', 'seepay', DATEADD(MINUTE, 35, DATEADD(HOUR, 20, DATEADD(DAY, -58, GETDATE()))), N'Trần Bảo', 'mega_req_214@gmail.com', '0933200843', DATEADD(MINUTE, 44, DATEADD(HOUR, 13, DATEADD(DAY, -44, GETDATE()))), 200000),
(1215, 'ORD-MEGA-0215', 1069, 1078, 600000, 0, 600000, 'refunded', 'seepay', DATEADD(MINUTE, 22, DATEADD(HOUR, 19, DATEADD(DAY, -52, GETDATE()))), N'Nguyễn Lan', 'mega_req_215@gmail.com', '0943683278', DATEADD(MINUTE, 37, DATEADD(HOUR, 4, DATEADD(DAY, -26, GETDATE()))), 600000),
(1216, 'ORD-MEGA-0216', 1046, 1024, 150000, 0, 150000, 'paid', 'seepay', DATEADD(MINUTE, 1, DATEADD(HOUR, 14, DATEADD(DAY, -54, GETDATE()))), N'Phạm Trang', 'mega_req_216@gmail.com', '0944702757', DATEADD(MINUTE, 53, DATEADD(HOUR, 20, DATEADD(DAY, -14, GETDATE()))), 150000),
(1217, 'ORD-MEGA-0217', 1001, 1083, 450000, 0, 450000, 'refunded', 'seepay', DATEADD(MINUTE, 6, DATEADD(HOUR, 5, DATEADD(DAY, -26, GETDATE()))), N'Bùi Hải', 'mega_req_217@gmail.com', '0970404255', DATEADD(MINUTE, 4, DATEADD(HOUR, 17, DATEADD(DAY, -41, GETDATE()))), 450000),
(1218, 'ORD-MEGA-0218', 1041, 1044, 600000, 0, 600000, 'pending', 'seepay', NULL, N'Hoàng Trang', 'mega_req_218@gmail.com', '0933675105', DATEADD(MINUTE, 51, DATEADD(HOUR, 0, DATEADD(DAY, -48, GETDATE()))), 600000),
(1219, 'ORD-MEGA-0219', 1095, 1090, 150000, 0, 150000, 'paid', 'seepay', DATEADD(MINUTE, 44, DATEADD(HOUR, 17, DATEADD(DAY, -19, GETDATE()))), N'Huỳnh Phong', 'mega_req_219@gmail.com', '0955986865', DATEADD(MINUTE, 40, DATEADD(HOUR, 17, DATEADD(DAY, -50, GETDATE()))), 150000),
(1220, 'ORD-MEGA-0220', 1065, 1097, 150000, 0, 150000, 'refunded', 'seepay', DATEADD(MINUTE, 22, DATEADD(HOUR, 19, DATEADD(DAY, -51, GETDATE()))), N'Bùi Trang', 'mega_req_220@gmail.com', '0988063928', DATEADD(MINUTE, 38, DATEADD(HOUR, 16, DATEADD(DAY, -12, GETDATE()))), 150000),
(1221, 'ORD-MEGA-0221', 1039, 1086, 800000, 0, 800000, 'paid', 'seepay', DATEADD(MINUTE, 42, DATEADD(HOUR, 8, DATEADD(DAY, -46, GETDATE()))), N'Đặng Thành', 'mega_req_221@gmail.com', '0983270171', DATEADD(MINUTE, 45, DATEADD(HOUR, 10, DATEADD(DAY, -48, GETDATE()))), 800000),
(1222, 'ORD-MEGA-0222', 1086, 1084, 1500000, 0, 1500000, 'paid', 'seepay', DATEADD(MINUTE, 2, DATEADD(HOUR, 6, DATEADD(DAY, -50, GETDATE()))), N'Đỗ Thu', 'mega_req_222@gmail.com', '0982225137', DATEADD(MINUTE, 5, DATEADD(HOUR, 1, DATEADD(DAY, 0, GETDATE()))), 1500000),
(1223, 'ORD-MEGA-0223', 1071, 1063, 500000, 0, 500000, 'paid', 'seepay', DATEADD(MINUTE, 36, DATEADD(HOUR, 11, DATEADD(DAY, -3, GETDATE()))), N'Đặng Thu', 'mega_req_223@gmail.com', '0950287107', DATEADD(MINUTE, 57, DATEADD(HOUR, 20, DATEADD(DAY, -35, GETDATE()))), 500000),
(1224, 'ORD-MEGA-0224', 1085, 1045, 600000, 0, 600000, 'cancelled', 'seepay', NULL, N'Huỳnh Minh', 'mega_req_224@gmail.com', '0989373323', DATEADD(MINUTE, 44, DATEADD(HOUR, 7, DATEADD(DAY, -8, GETDATE()))), 600000),
(1225, 'ORD-MEGA-0225', 1027, 1050, 500000, 0, 500000, 'paid', 'seepay', DATEADD(MINUTE, 42, DATEADD(HOUR, 13, DATEADD(DAY, -55, GETDATE()))), N'Huỳnh Anh', 'mega_req_225@gmail.com', '0955382933', DATEADD(MINUTE, 50, DATEADD(HOUR, 7, DATEADD(DAY, -26, GETDATE()))), 500000),
(1226, 'ORD-MEGA-0226', 1098, 1017, 450000, 0, 450000, 'paid', 'seepay', DATEADD(MINUTE, 54, DATEADD(HOUR, 5, DATEADD(DAY, -33, GETDATE()))), N'Lê Trang', 'mega_req_226@gmail.com', '0985092539', DATEADD(MINUTE, 16, DATEADD(HOUR, 16, DATEADD(DAY, -1, GETDATE()))), 450000),
(1227, 'ORD-MEGA-0227', 1079, 1011, 1500000, 0, 1500000, 'pending', 'seepay', NULL, N'Bùi Phong', 'mega_req_227@gmail.com', '0914308586', DATEADD(MINUTE, 52, DATEADD(HOUR, 0, DATEADD(DAY, -4, GETDATE()))), 1500000),
(1228, 'ORD-MEGA-0228', 1092, 1090, 200000, 0, 200000, 'cancelled', 'seepay', NULL, N'Đặng Vân', 'mega_req_228@gmail.com', '0999006074', DATEADD(MINUTE, 21, DATEADD(HOUR, 8, DATEADD(DAY, -39, GETDATE()))), 200000),
(1229, 'ORD-MEGA-0229', 1055, 1026, 1000000, 0, 1000000, 'refunded', 'seepay', DATEADD(MINUTE, 31, DATEADD(HOUR, 8, DATEADD(DAY, -57, GETDATE()))), N'Đặng Bảo', 'mega_req_229@gmail.com', '0954677070', DATEADD(MINUTE, 14, DATEADD(HOUR, 10, DATEADD(DAY, -38, GETDATE()))), 1000000),
(1230, 'ORD-MEGA-0230', 1088, 1037, 1500000, 0, 1500000, 'cancelled', 'seepay', NULL, N'Phạm Bảo', 'mega_req_230@gmail.com', '0933815259', DATEADD(MINUTE, 57, DATEADD(HOUR, 16, DATEADD(DAY, -5, GETDATE()))), 1500000),
(1231, 'ORD-MEGA-0231', 1076, 1074, 300000, 0, 300000, 'paid', 'seepay', DATEADD(MINUTE, 22, DATEADD(HOUR, 4, DATEADD(DAY, -40, GETDATE()))), N'Bùi Hùng', 'mega_req_231@gmail.com', '0981176422', DATEADD(MINUTE, 53, DATEADD(HOUR, 15, DATEADD(DAY, -44, GETDATE()))), 300000),
(1232, 'ORD-MEGA-0232', 1011, 1054, 1000000, 0, 1000000, 'refunded', 'seepay', DATEADD(MINUTE, 10, DATEADD(HOUR, 3, DATEADD(DAY, -14, GETDATE()))), N'Đỗ Trang', 'mega_req_232@gmail.com', '0977145113', DATEADD(MINUTE, 53, DATEADD(HOUR, 19, DATEADD(DAY, -26, GETDATE()))), 1000000),
(1233, 'ORD-MEGA-0233', 1074, 1063, 600000, 0, 600000, 'refunded', 'seepay', DATEADD(MINUTE, 55, DATEADD(HOUR, 12, DATEADD(DAY, -38, GETDATE()))), N'Hoàng Phong', 'mega_req_233@gmail.com', '0952864189', DATEADD(MINUTE, 8, DATEADD(HOUR, 0, DATEADD(DAY, -4, GETDATE()))), 600000),
(1234, 'ORD-MEGA-0234', 1086, 1073, 600000, 0, 600000, 'paid', 'seepay', DATEADD(MINUTE, 13, DATEADD(HOUR, 22, DATEADD(DAY, -55, GETDATE()))), N'Đặng Kiên', 'mega_req_234@gmail.com', '0945079298', DATEADD(MINUTE, 17, DATEADD(HOUR, 6, DATEADD(DAY, -24, GETDATE()))), 600000),
(1235, 'ORD-MEGA-0235', 1045, 1044, 450000, 0, 450000, 'cancelled', 'seepay', NULL, N'Lê Bảo', 'mega_req_235@gmail.com', '0954102400', DATEADD(MINUTE, 45, DATEADD(HOUR, 16, DATEADD(DAY, -12, GETDATE()))), 450000),
(1236, 'ORD-MEGA-0236', 1023, 1034, 450000, 0, 450000, 'cancelled', 'seepay', NULL, N'Nguyễn Thu', 'mega_req_236@gmail.com', '0922829795', DATEADD(MINUTE, 9, DATEADD(HOUR, 6, DATEADD(DAY, -57, GETDATE()))), 450000),
(1237, 'ORD-MEGA-0237', 1046, 1076, 450000, 0, 450000, 'paid', 'seepay', DATEADD(MINUTE, 33, DATEADD(HOUR, 8, DATEADD(DAY, -24, GETDATE()))), N'Trần Khoa', 'mega_req_237@gmail.com', '0991540797', DATEADD(MINUTE, 54, DATEADD(HOUR, 2, DATEADD(DAY, -52, GETDATE()))), 450000),
(1238, 'ORD-MEGA-0238', 1084, 1011, 600000, 0, 600000, 'paid', 'seepay', DATEADD(MINUTE, 18, DATEADD(HOUR, 8, DATEADD(DAY, -6, GETDATE()))), N'Đỗ Vân', 'mega_req_238@gmail.com', '0992584044', DATEADD(MINUTE, 12, DATEADD(HOUR, 2, DATEADD(DAY, -47, GETDATE()))), 600000),
(1239, 'ORD-MEGA-0239', 1015, 1014, 600000, 0, 600000, 'paid', 'seepay', DATEADD(MINUTE, 27, DATEADD(HOUR, 13, DATEADD(DAY, -57, GETDATE()))), N'Hoàng Thành', 'mega_req_239@gmail.com', '0928795054', DATEADD(MINUTE, 10, DATEADD(HOUR, 5, DATEADD(DAY, -38, GETDATE()))), 600000),
(1240, 'ORD-MEGA-0240', 1032, 1011, 450000, 0, 450000, 'pending', 'seepay', NULL, N'Đỗ Phong', 'mega_req_240@gmail.com', '0939398023', DATEADD(MINUTE, 20, DATEADD(HOUR, 8, DATEADD(DAY, -21, GETDATE()))), 450000),
(1241, 'ORD-MEGA-0241', 1082, 1076, 600000, 0, 600000, 'pending', 'seepay', NULL, N'Lê Vân', 'mega_req_241@gmail.com', '0996229387', DATEADD(MINUTE, 52, DATEADD(HOUR, 4, DATEADD(DAY, -42, GETDATE()))), 600000),
(1242, 'ORD-MEGA-0242', 1072, 1021, 450000, 0, 450000, 'paid', 'seepay', DATEADD(MINUTE, 16, DATEADD(HOUR, 7, DATEADD(DAY, -1, GETDATE()))), N'Đỗ Thu', 'mega_req_242@gmail.com', '0978323450', DATEADD(MINUTE, 48, DATEADD(HOUR, 3, DATEADD(DAY, -31, GETDATE()))), 450000),
(1243, 'ORD-MEGA-0243', 1085, 1045, 1000000, 0, 1000000, 'refunded', 'seepay', DATEADD(MINUTE, 5, DATEADD(HOUR, 4, DATEADD(DAY, -57, GETDATE()))), N'Hoàng Bảo', 'mega_req_243@gmail.com', '0994118836', DATEADD(MINUTE, 19, DATEADD(HOUR, 12, DATEADD(DAY, -33, GETDATE()))), 1000000),
(1244, 'ORD-MEGA-0244', 1010, 1053, 600000, 0, 600000, 'paid', 'seepay', DATEADD(MINUTE, 30, DATEADD(HOUR, 10, DATEADD(DAY, -49, GETDATE()))), N'Vũ Trang', 'mega_req_244@gmail.com', '0929837217', DATEADD(MINUTE, 21, DATEADD(HOUR, 2, DATEADD(DAY, -5, GETDATE()))), 600000),
(1245, 'ORD-MEGA-0245', 1022, 1026, 1000000, 0, 1000000, 'pending', 'seepay', NULL, N'Đặng Anh', 'mega_req_245@gmail.com', '0916272602', DATEADD(MINUTE, 23, DATEADD(HOUR, 15, DATEADD(DAY, 0, GETDATE()))), 1000000),
(1246, 'ORD-MEGA-0246', 1099, 1039, 1000000, 0, 1000000, 'cancelled', 'seepay', NULL, N'Bùi Thu', 'mega_req_246@gmail.com', '0952777428', DATEADD(MINUTE, 24, DATEADD(HOUR, 7, DATEADD(DAY, -55, GETDATE()))), 1000000),
(1247, 'ORD-MEGA-0247', 1064, 1060, 600000, 0, 600000, 'cancelled', 'seepay', NULL, N'Phạm Hùng', 'mega_req_247@gmail.com', '0913838546', DATEADD(MINUTE, 10, DATEADD(HOUR, 6, DATEADD(DAY, -4, GETDATE()))), 600000),
(1248, 'ORD-MEGA-0248', 1001, 1075, 450000, 0, 450000, 'paid', 'seepay', DATEADD(MINUTE, 52, DATEADD(HOUR, 22, DATEADD(DAY, -38, GETDATE()))), N'Phạm Khoa', 'mega_req_248@gmail.com', '0952482492', DATEADD(MINUTE, 35, DATEADD(HOUR, 8, DATEADD(DAY, -20, GETDATE()))), 450000),
(1249, 'ORD-MEGA-0249', 1048, 1057, 600000, 0, 600000, 'paid', 'seepay', DATEADD(MINUTE, 50, DATEADD(HOUR, 0, DATEADD(DAY, -25, GETDATE()))), N'Trần Vân', 'mega_req_249@gmail.com', '0990830288', DATEADD(MINUTE, 35, DATEADD(HOUR, 7, DATEADD(DAY, 0, GETDATE()))), 600000),
(1250, 'ORD-MEGA-0250', 1088, 1053, 500000, 0, 500000, 'paid', 'seepay', DATEADD(MINUTE, 9, DATEADD(HOUR, 19, DATEADD(DAY, -52, GETDATE()))), N'Vũ Kiên', 'mega_req_250@gmail.com', '0980366924', DATEADD(MINUTE, 56, DATEADD(HOUR, 9, DATEADD(DAY, -9, GETDATE()))), 500000),
(1251, 'ORD-MEGA-0251', 1024, 1020, 400000, 0, 400000, 'pending', 'seepay', NULL, N'Đỗ Thành', 'mega_req_251@gmail.com', '0996944712', DATEADD(MINUTE, 36, DATEADD(HOUR, 13, DATEADD(DAY, -14, GETDATE()))), 400000),
(1252, 'ORD-MEGA-0252', 1092, 1032, 600000, 0, 600000, 'refunded', 'seepay', DATEADD(MINUTE, 21, DATEADD(HOUR, 13, DATEADD(DAY, -58, GETDATE()))), N'Huỳnh Thành', 'mega_req_252@gmail.com', '0968475683', DATEADD(MINUTE, 51, DATEADD(HOUR, 19, DATEADD(DAY, -28, GETDATE()))), 600000),
(1253, 'ORD-MEGA-0253', 1029, 1022, 200000, 0, 200000, 'pending', 'seepay', NULL, N'Lê Linh', 'mega_req_253@gmail.com', '0916011574', DATEADD(MINUTE, 19, DATEADD(HOUR, 9, DATEADD(DAY, -17, GETDATE()))), 200000),
(1254, 'ORD-MEGA-0254', 1032, 1077, 150000, 0, 150000, 'paid', 'seepay', DATEADD(MINUTE, 59, DATEADD(HOUR, 14, DATEADD(DAY, -52, GETDATE()))), N'Đặng Phong', 'mega_req_254@gmail.com', '0941988995', DATEADD(MINUTE, 10, DATEADD(HOUR, 16, DATEADD(DAY, -59, GETDATE()))), 150000),
(1255, 'ORD-MEGA-0255', 1040, 1063, 2000000, 0, 2000000, 'paid', 'seepay', DATEADD(MINUTE, 30, DATEADD(HOUR, 20, DATEADD(DAY, -41, GETDATE()))), N'Bùi Minh', 'mega_req_255@gmail.com', '0988106630', DATEADD(MINUTE, 27, DATEADD(HOUR, 15, DATEADD(DAY, -31, GETDATE()))), 2000000),
(1256, 'ORD-MEGA-0256', 1068, 1041, 600000, 0, 600000, 'paid', 'seepay', DATEADD(MINUTE, 8, DATEADD(HOUR, 17, DATEADD(DAY, -24, GETDATE()))), N'Phạm Phong', 'mega_req_256@gmail.com', '0978575980', DATEADD(MINUTE, 11, DATEADD(HOUR, 16, DATEADD(DAY, -31, GETDATE()))), 600000),
(1257, 'ORD-MEGA-0257', 1090, 1084, 1500000, 0, 1500000, 'refunded', 'seepay', DATEADD(MINUTE, 3, DATEADD(HOUR, 23, DATEADD(DAY, -31, GETDATE()))), N'Vũ Hùng', 'mega_req_257@gmail.com', '0931687143', DATEADD(MINUTE, 38, DATEADD(HOUR, 8, DATEADD(DAY, -15, GETDATE()))), 1500000),
(1258, 'ORD-MEGA-0258', 1081, 1000, 1000000, 0, 1000000, 'refunded', 'seepay', DATEADD(MINUTE, 16, DATEADD(HOUR, 2, DATEADD(DAY, -44, GETDATE()))), N'Phạm Khoa', 'mega_req_258@gmail.com', '0993030720', DATEADD(MINUTE, 45, DATEADD(HOUR, 9, DATEADD(DAY, -34, GETDATE()))), 1000000),
(1259, 'ORD-MEGA-0259', 1088, 1076, 1500000, 0, 1500000, 'cancelled', 'seepay', NULL, N'Trần Linh', 'mega_req_259@gmail.com', '0931990764', DATEADD(MINUTE, 40, DATEADD(HOUR, 11, DATEADD(DAY, -18, GETDATE()))), 1500000),
(1260, 'ORD-MEGA-0260', 1070, 1002, 150000, 0, 150000, 'paid', 'seepay', DATEADD(MINUTE, 59, DATEADD(HOUR, 22, DATEADD(DAY, -15, GETDATE()))), N'Nguyễn Trang', 'mega_req_260@gmail.com', '0994362427', DATEADD(MINUTE, 56, DATEADD(HOUR, 21, DATEADD(DAY, -1, GETDATE()))), 150000),
(1261, 'ORD-MEGA-0261', 1045, 1011, 600000, 0, 600000, 'pending', 'seepay', NULL, N'Bùi Bảo', 'mega_req_261@gmail.com', '0914774669', DATEADD(MINUTE, 1, DATEADD(HOUR, 7, DATEADD(DAY, -57, GETDATE()))), 600000),
(1262, 'ORD-MEGA-0262', 1099, 1061, 300000, 0, 300000, 'paid', 'seepay', DATEADD(MINUTE, 31, DATEADD(HOUR, 23, DATEADD(DAY, -60, GETDATE()))), N'Hoàng Phong', 'mega_req_262@gmail.com', '0915666709', DATEADD(MINUTE, 30, DATEADD(HOUR, 7, DATEADD(DAY, -54, GETDATE()))), 300000),
(1263, 'ORD-MEGA-0263', 1017, 1009, 450000, 0, 450000, 'paid', 'seepay', DATEADD(MINUTE, 20, DATEADD(HOUR, 3, DATEADD(DAY, -11, GETDATE()))), N'Bùi Lan', 'mega_req_263@gmail.com', '0943768698', DATEADD(MINUTE, 6, DATEADD(HOUR, 5, DATEADD(DAY, -21, GETDATE()))), 450000),
(1264, 'ORD-MEGA-0264', 1077, 1083, 200000, 0, 200000, 'paid', 'seepay', DATEADD(MINUTE, 9, DATEADD(HOUR, 20, DATEADD(DAY, -8, GETDATE()))), N'Bùi Minh', 'mega_req_264@gmail.com', '0957462918', DATEADD(MINUTE, 20, DATEADD(HOUR, 19, DATEADD(DAY, -37, GETDATE()))), 200000),
(1265, 'ORD-MEGA-0265', 1041, 1089, 500000, 0, 500000, 'cancelled', 'seepay', NULL, N'Lê Hùng', 'mega_req_265@gmail.com', '0976050831', DATEADD(MINUTE, 45, DATEADD(HOUR, 23, DATEADD(DAY, -20, GETDATE()))), 500000),
(1266, 'ORD-MEGA-0266', 1000, 1013, 600000, 0, 600000, 'cancelled', 'seepay', NULL, N'Bùi Lan', 'mega_req_266@gmail.com', '0943727976', DATEADD(MINUTE, 57, DATEADD(HOUR, 12, DATEADD(DAY, -4, GETDATE()))), 600000),
(1267, 'ORD-MEGA-0267', 1024, 1084, 800000, 0, 800000, 'paid', 'seepay', DATEADD(MINUTE, 3, DATEADD(HOUR, 12, DATEADD(DAY, -36, GETDATE()))), N'Bùi Vân', 'mega_req_267@gmail.com', '0957962124', DATEADD(MINUTE, 41, DATEADD(HOUR, 12, DATEADD(DAY, -32, GETDATE()))), 800000),
(1268, 'ORD-MEGA-0268', 1004, 1026, 600000, 0, 600000, 'paid', 'seepay', DATEADD(MINUTE, 1, DATEADD(HOUR, 8, DATEADD(DAY, -48, GETDATE()))), N'Đặng Minh', 'mega_req_268@gmail.com', '0973260927', DATEADD(MINUTE, 38, DATEADD(HOUR, 7, DATEADD(DAY, -10, GETDATE()))), 600000),
(1269, 'ORD-MEGA-0269', 1048, 1085, 1500000, 0, 1500000, 'pending', 'seepay', NULL, N'Trần Trang', 'mega_req_269@gmail.com', '0912987594', DATEADD(MINUTE, 4, DATEADD(HOUR, 9, DATEADD(DAY, -56, GETDATE()))), 1500000),
(1270, 'ORD-MEGA-0270', 1075, 1058, 1000000, 0, 1000000, 'paid', 'seepay', DATEADD(MINUTE, 55, DATEADD(HOUR, 21, DATEADD(DAY, -23, GETDATE()))), N'Vũ Thành', 'mega_req_270@gmail.com', '0998123102', DATEADD(MINUTE, 48, DATEADD(HOUR, 16, DATEADD(DAY, -30, GETDATE()))), 1000000),
(1271, 'ORD-MEGA-0271', 1026, 1096, 1000000, 0, 1000000, 'refunded', 'seepay', DATEADD(MINUTE, 1, DATEADD(HOUR, 14, DATEADD(DAY, -55, GETDATE()))), N'Trần Phong', 'mega_req_271@gmail.com', '0914049010', DATEADD(MINUTE, 10, DATEADD(HOUR, 2, DATEADD(DAY, -1, GETDATE()))), 1000000),
(1272, 'ORD-MEGA-0272', 1096, 1098, 200000, 0, 200000, 'paid', 'seepay', DATEADD(MINUTE, 32, DATEADD(HOUR, 17, DATEADD(DAY, -7, GETDATE()))), N'Nguyễn Trang', 'mega_req_272@gmail.com', '0987366395', DATEADD(MINUTE, 59, DATEADD(HOUR, 12, DATEADD(DAY, -7, GETDATE()))), 200000),
(1273, 'ORD-MEGA-0273', 1053, 1081, 800000, 0, 800000, 'pending', 'seepay', NULL, N'Nguyễn Minh', 'mega_req_273@gmail.com', '0930059131', DATEADD(MINUTE, 1, DATEADD(HOUR, 7, DATEADD(DAY, -51, GETDATE()))), 800000),
(1274, 'ORD-MEGA-0274', 1041, 1034, 300000, 0, 300000, 'pending', 'seepay', NULL, N'Hoàng Hải', 'mega_req_274@gmail.com', '0943935329', DATEADD(MINUTE, 27, DATEADD(HOUR, 8, DATEADD(DAY, -17, GETDATE()))), 300000),
(1275, 'ORD-MEGA-0275', 1066, 1051, 400000, 0, 400000, 'cancelled', 'seepay', NULL, N'Bùi Phong', 'mega_req_275@gmail.com', '0972694009', DATEADD(MINUTE, 49, DATEADD(HOUR, 18, DATEADD(DAY, -39, GETDATE()))), 400000),
(1276, 'ORD-MEGA-0276', 1005, 1015, 600000, 0, 600000, 'pending', 'seepay', NULL, N'Bùi Bảo', 'mega_req_276@gmail.com', '0984363915', DATEADD(MINUTE, 46, DATEADD(HOUR, 22, DATEADD(DAY, -2, GETDATE()))), 600000),
(1277, 'ORD-MEGA-0277', 1079, 1002, 300000, 0, 300000, 'paid', 'seepay', DATEADD(MINUTE, 16, DATEADD(HOUR, 4, DATEADD(DAY, -33, GETDATE()))), N'Vũ Minh', 'mega_req_277@gmail.com', '0911771227', DATEADD(MINUTE, 22, DATEADD(HOUR, 17, DATEADD(DAY, -20, GETDATE()))), 300000),
(1278, 'ORD-MEGA-0278', 1066, 1014, 1000000, 0, 1000000, 'cancelled', 'seepay', NULL, N'Đỗ Khoa', 'mega_req_278@gmail.com', '0959088798', DATEADD(MINUTE, 46, DATEADD(HOUR, 9, DATEADD(DAY, -50, GETDATE()))), 1000000),
(1279, 'ORD-MEGA-0279', 1079, 1086, 800000, 0, 800000, 'paid', 'seepay', DATEADD(MINUTE, 58, DATEADD(HOUR, 16, DATEADD(DAY, -32, GETDATE()))), N'Đặng Tâm', 'mega_req_279@gmail.com', '0997478303', DATEADD(MINUTE, 43, DATEADD(HOUR, 22, DATEADD(DAY, -6, GETDATE()))), 800000),
(1280, 'ORD-MEGA-0280', 1055, 1078, 450000, 0, 450000, 'paid', 'seepay', DATEADD(MINUTE, 2, DATEADD(HOUR, 22, DATEADD(DAY, -52, GETDATE()))), N'Vũ Tâm', 'mega_req_280@gmail.com', '0970596140', DATEADD(MINUTE, 53, DATEADD(HOUR, 15, DATEADD(DAY, -8, GETDATE()))), 450000),
(1281, 'ORD-MEGA-0281', 1047, 1069, 300000, 0, 300000, 'paid', 'seepay', DATEADD(MINUTE, 14, DATEADD(HOUR, 7, DATEADD(DAY, -35, GETDATE()))), N'Đặng Phong', 'mega_req_281@gmail.com', '0914765119', DATEADD(MINUTE, 32, DATEADD(HOUR, 10, DATEADD(DAY, -48, GETDATE()))), 300000),
(1282, 'ORD-MEGA-0282', 1061, 1041, 800000, 0, 800000, 'refunded', 'seepay', DATEADD(MINUTE, 10, DATEADD(HOUR, 14, DATEADD(DAY, -41, GETDATE()))), N'Trần Anh', 'mega_req_282@gmail.com', '0926821225', DATEADD(MINUTE, 56, DATEADD(HOUR, 17, DATEADD(DAY, -29, GETDATE()))), 800000),
(1283, 'ORD-MEGA-0283', 1024, 1053, 450000, 0, 450000, 'cancelled', 'seepay', NULL, N'Đặng Tâm', 'mega_req_283@gmail.com', '0971146788', DATEADD(MINUTE, 37, DATEADD(HOUR, 13, DATEADD(DAY, -3, GETDATE()))), 450000),
(1284, 'ORD-MEGA-0284', 1009, 1052, 450000, 0, 450000, 'cancelled', 'seepay', NULL, N'Nguyễn Tâm', 'mega_req_284@gmail.com', '0979713987', DATEADD(MINUTE, 52, DATEADD(HOUR, 6, DATEADD(DAY, -54, GETDATE()))), 450000),
(1285, 'ORD-MEGA-0285', 1091, 1071, 600000, 0, 600000, 'cancelled', 'seepay', NULL, N'Vũ Thu', 'mega_req_285@gmail.com', '0942739693', DATEADD(MINUTE, 39, DATEADD(HOUR, 23, DATEADD(DAY, -55, GETDATE()))), 600000),
(1286, 'ORD-MEGA-0286', 1006, 1089, 300000, 0, 300000, 'paid', 'seepay', DATEADD(MINUTE, 53, DATEADD(HOUR, 20, DATEADD(DAY, -16, GETDATE()))), N'Trần Lan', 'mega_req_286@gmail.com', '0984446973', DATEADD(MINUTE, 6, DATEADD(HOUR, 23, DATEADD(DAY, -9, GETDATE()))), 300000),
(1287, 'ORD-MEGA-0287', 1053, 1092, 600000, 0, 600000, 'paid', 'seepay', DATEADD(MINUTE, 56, DATEADD(HOUR, 22, DATEADD(DAY, -12, GETDATE()))), N'Lê Kiên', 'mega_req_287@gmail.com', '0952434718', DATEADD(MINUTE, 22, DATEADD(HOUR, 20, DATEADD(DAY, -58, GETDATE()))), 600000),
(1288, 'ORD-MEGA-0288', 1011, 1091, 450000, 0, 450000, 'paid', 'seepay', DATEADD(MINUTE, 41, DATEADD(HOUR, 2, DATEADD(DAY, -49, GETDATE()))), N'Phạm Vân', 'mega_req_288@gmail.com', '0929194636', DATEADD(MINUTE, 22, DATEADD(HOUR, 6, DATEADD(DAY, -11, GETDATE()))), 450000),
(1289, 'ORD-MEGA-0289', 1023, 1059, 500000, 0, 500000, 'paid', 'seepay', DATEADD(MINUTE, 42, DATEADD(HOUR, 15, DATEADD(DAY, -40, GETDATE()))), N'Lê Thành', 'mega_req_289@gmail.com', '0993552607', DATEADD(MINUTE, 10, DATEADD(HOUR, 3, DATEADD(DAY, -5, GETDATE()))), 500000),
(1290, 'ORD-MEGA-0290', 1086, 1052, 450000, 0, 450000, 'paid', 'seepay', DATEADD(MINUTE, 20, DATEADD(HOUR, 13, DATEADD(DAY, -36, GETDATE()))), N'Nguyễn Anh', 'mega_req_290@gmail.com', '0949101258', DATEADD(MINUTE, 24, DATEADD(HOUR, 21, DATEADD(DAY, -11, GETDATE()))), 450000),
(1291, 'ORD-MEGA-0291', 1000, 1031, 2000000, 0, 2000000, 'cancelled', 'seepay', NULL, N'Trần Trang', 'mega_req_291@gmail.com', '0913958623', DATEADD(MINUTE, 22, DATEADD(HOUR, 10, DATEADD(DAY, -40, GETDATE()))), 2000000),
(1292, 'ORD-MEGA-0292', 1067, 1008, 300000, 0, 300000, 'pending', 'seepay', NULL, N'Nguyễn Anh', 'mega_req_292@gmail.com', '0945307300', DATEADD(MINUTE, 49, DATEADD(HOUR, 7, DATEADD(DAY, -9, GETDATE()))), 300000),
(1293, 'ORD-MEGA-0293', 1055, 1001, 1000000, 0, 1000000, 'cancelled', 'seepay', NULL, N'Huỳnh Tâm', 'mega_req_293@gmail.com', '0970143169', DATEADD(MINUTE, 42, DATEADD(HOUR, 17, DATEADD(DAY, -5, GETDATE()))), 1000000),
(1294, 'ORD-MEGA-0294', 1091, 1004, 150000, 0, 150000, 'cancelled', 'seepay', NULL, N'Nguyễn Hùng', 'mega_req_294@gmail.com', '0934610725', DATEADD(MINUTE, 54, DATEADD(HOUR, 2, DATEADD(DAY, -13, GETDATE()))), 150000),
(1295, 'ORD-MEGA-0295', 1000, 1064, 800000, 0, 800000, 'pending', 'seepay', NULL, N'Nguyễn Anh', 'mega_req_295@gmail.com', '0985433892', DATEADD(MINUTE, 15, DATEADD(HOUR, 11, DATEADD(DAY, -42, GETDATE()))), 800000),
(1296, 'ORD-MEGA-0296', 1062, 1048, 300000, 0, 300000, 'paid', 'seepay', DATEADD(MINUTE, 55, DATEADD(HOUR, 8, DATEADD(DAY, -2, GETDATE()))), N'Phạm Trang', 'mega_req_296@gmail.com', '0910045701', DATEADD(MINUTE, 32, DATEADD(HOUR, 6, DATEADD(DAY, -59, GETDATE()))), 300000),
(1297, 'ORD-MEGA-0297', 1066, 1053, 1000000, 0, 1000000, 'paid', 'seepay', DATEADD(MINUTE, 9, DATEADD(HOUR, 17, DATEADD(DAY, -46, GETDATE()))), N'Đỗ Phong', 'mega_req_297@gmail.com', '0975794440', DATEADD(MINUTE, 7, DATEADD(HOUR, 6, DATEADD(DAY, -26, GETDATE()))), 1000000),
(1298, 'ORD-MEGA-0298', 1008, 1030, 1000000, 0, 1000000, 'pending', 'seepay', NULL, N'Hoàng Lan', 'mega_req_298@gmail.com', '0938830620', DATEADD(MINUTE, 29, DATEADD(HOUR, 13, DATEADD(DAY, -27, GETDATE()))), 1000000),
(1299, 'ORD-MEGA-0299', 1093, 1094, 300000, 0, 300000, 'paid', 'seepay', DATEADD(MINUTE, 41, DATEADD(HOUR, 23, DATEADD(DAY, -22, GETDATE()))), N'Lê Linh', 'mega_req_299@gmail.com', '0938571234', DATEADD(MINUTE, 28, DATEADD(HOUR, 21, DATEADD(DAY, -59, GETDATE()))), 300000);
INSERT INTO Orders (order_id, order_code, user_id, event_id, total_amount, discount_amount, final_amount, status, payment_method, payment_date, buyer_name, buyer_email, buyer_phone, created_at, organizer_payout_amount) VALUES
(1300, 'ORD-MEGA-0300', 1022, 1031, 400000, 0, 400000, 'cancelled', 'seepay', NULL, N'Phạm Hải', 'mega_req_300@gmail.com', '0915161446', DATEADD(MINUTE, 37, DATEADD(HOUR, 12, DATEADD(DAY, -55, GETDATE()))), 400000),
(1301, 'ORD-MEGA-0301', 1023, 1035, 2000000, 0, 2000000, 'paid', 'seepay', DATEADD(MINUTE, 22, DATEADD(HOUR, 23, DATEADD(DAY, -7, GETDATE()))), N'Huỳnh Trang', 'mega_req_301@gmail.com', '0985712179', DATEADD(MINUTE, 19, DATEADD(HOUR, 17, DATEADD(DAY, -37, GETDATE()))), 2000000),
(1302, 'ORD-MEGA-0302', 1047, 1015, 150000, 0, 150000, 'cancelled', 'seepay', NULL, N'Huỳnh Thành', 'mega_req_302@gmail.com', '0994463481', DATEADD(MINUTE, 48, DATEADD(HOUR, 19, DATEADD(DAY, -18, GETDATE()))), 150000),
(1303, 'ORD-MEGA-0303', 1017, 1044, 600000, 0, 600000, 'paid', 'seepay', DATEADD(MINUTE, 28, DATEADD(HOUR, 21, DATEADD(DAY, -34, GETDATE()))), N'Nguyễn Thu', 'mega_req_303@gmail.com', '0950991313', DATEADD(MINUTE, 44, DATEADD(HOUR, 4, DATEADD(DAY, -20, GETDATE()))), 600000),
(1304, 'ORD-MEGA-0304', 1088, 1088, 600000, 0, 600000, 'paid', 'seepay', DATEADD(MINUTE, 37, DATEADD(HOUR, 0, DATEADD(DAY, -60, GETDATE()))), N'Phạm Thu', 'mega_req_304@gmail.com', '0988898157', DATEADD(MINUTE, 18, DATEADD(HOUR, 19, DATEADD(DAY, -28, GETDATE()))), 600000),
(1305, 'ORD-MEGA-0305', 1094, 1059, 400000, 0, 400000, 'paid', 'seepay', DATEADD(MINUTE, 53, DATEADD(HOUR, 14, DATEADD(DAY, -28, GETDATE()))), N'Phạm Phong', 'mega_req_305@gmail.com', '0986308982', DATEADD(MINUTE, 55, DATEADD(HOUR, 22, DATEADD(DAY, -13, GETDATE()))), 400000),
(1306, 'ORD-MEGA-0306', 1017, 1008, 2000000, 0, 2000000, 'paid', 'seepay', DATEADD(MINUTE, 39, DATEADD(HOUR, 21, DATEADD(DAY, -21, GETDATE()))), N'Bùi Khoa', 'mega_req_306@gmail.com', '0929156143', DATEADD(MINUTE, 51, DATEADD(HOUR, 14, DATEADD(DAY, -35, GETDATE()))), 2000000),
(1307, 'ORD-MEGA-0307', 1056, 1047, 400000, 0, 400000, 'refunded', 'seepay', DATEADD(MINUTE, 11, DATEADD(HOUR, 18, DATEADD(DAY, -18, GETDATE()))), N'Bùi Thu', 'mega_req_307@gmail.com', '0967195169', DATEADD(MINUTE, 17, DATEADD(HOUR, 19, DATEADD(DAY, -47, GETDATE()))), 400000),
(1308, 'ORD-MEGA-0308', 1093, 1007, 1500000, 0, 1500000, 'pending', 'seepay', NULL, N'Huỳnh Trang', 'mega_req_308@gmail.com', '0976348852', DATEADD(MINUTE, 23, DATEADD(HOUR, 21, DATEADD(DAY, -31, GETDATE()))), 1500000),
(1309, 'ORD-MEGA-0309', 1024, 1007, 300000, 0, 300000, 'paid', 'seepay', DATEADD(MINUTE, 5, DATEADD(HOUR, 1, DATEADD(DAY, -50, GETDATE()))), N'Bùi Phong', 'mega_req_309@gmail.com', '0927676271', DATEADD(MINUTE, 13, DATEADD(HOUR, 16, DATEADD(DAY, -56, GETDATE()))), 300000),
(1310, 'ORD-MEGA-0310', 1027, 1064, 600000, 0, 600000, 'pending', 'seepay', NULL, N'Đặng Tâm', 'mega_req_310@gmail.com', '0911359701', DATEADD(MINUTE, 7, DATEADD(HOUR, 8, DATEADD(DAY, -39, GETDATE()))), 600000),
(1311, 'ORD-MEGA-0311', 1003, 1004, 2000000, 0, 2000000, 'refunded', 'seepay', DATEADD(MINUTE, 10, DATEADD(HOUR, 7, DATEADD(DAY, -44, GETDATE()))), N'Hoàng Thành', 'mega_req_311@gmail.com', '0937909824', DATEADD(MINUTE, 12, DATEADD(HOUR, 18, DATEADD(DAY, -26, GETDATE()))), 2000000),
(1312, 'ORD-MEGA-0312', 1085, 1004, 200000, 0, 200000, 'paid', 'seepay', DATEADD(MINUTE, 8, DATEADD(HOUR, 16, DATEADD(DAY, -28, GETDATE()))), N'Nguyễn Thu', 'mega_req_312@gmail.com', '0991429689', DATEADD(MINUTE, 29, DATEADD(HOUR, 11, DATEADD(DAY, -4, GETDATE()))), 200000),
(1313, 'ORD-MEGA-0313', 1067, 1020, 150000, 0, 150000, 'paid', 'seepay', DATEADD(MINUTE, 35, DATEADD(HOUR, 11, DATEADD(DAY, -5, GETDATE()))), N'Hoàng Kiên', 'mega_req_313@gmail.com', '0935128461', DATEADD(MINUTE, 13, DATEADD(HOUR, 12, DATEADD(DAY, -24, GETDATE()))), 150000),
(1314, 'ORD-MEGA-0314', 1062, 1034, 1500000, 0, 1500000, 'refunded', 'seepay', DATEADD(MINUTE, 11, DATEADD(HOUR, 22, DATEADD(DAY, -35, GETDATE()))), N'Huỳnh Phong', 'mega_req_314@gmail.com', '0955538893', DATEADD(MINUTE, 22, DATEADD(HOUR, 20, DATEADD(DAY, -57, GETDATE()))), 1500000),
(1315, 'ORD-MEGA-0315', 1001, 1079, 1500000, 0, 1500000, 'paid', 'seepay', DATEADD(MINUTE, 46, DATEADD(HOUR, 9, DATEADD(DAY, -17, GETDATE()))), N'Phạm Anh', 'mega_req_315@gmail.com', '0935621749', DATEADD(MINUTE, 53, DATEADD(HOUR, 23, DATEADD(DAY, -35, GETDATE()))), 1500000),
(1316, 'ORD-MEGA-0316', 1021, 1086, 300000, 0, 300000, 'pending', 'seepay', NULL, N'Huỳnh Vân', 'mega_req_316@gmail.com', '0995274597', DATEADD(MINUTE, 34, DATEADD(HOUR, 13, DATEADD(DAY, -9, GETDATE()))), 300000),
(1317, 'ORD-MEGA-0317', 1001, 1043, 2000000, 0, 2000000, 'pending', 'seepay', NULL, N'Trần Hải', 'mega_req_317@gmail.com', '0967929275', DATEADD(MINUTE, 2, DATEADD(HOUR, 11, DATEADD(DAY, -42, GETDATE()))), 2000000),
(1318, 'ORD-MEGA-0318', 1052, 1056, 1500000, 0, 1500000, 'paid', 'seepay', DATEADD(MINUTE, 33, DATEADD(HOUR, 9, DATEADD(DAY, -10, GETDATE()))), N'Trần Anh', 'mega_req_318@gmail.com', '0980938468', DATEADD(MINUTE, 10, DATEADD(HOUR, 12, DATEADD(DAY, -3, GETDATE()))), 1500000),
(1319, 'ORD-MEGA-0319', 1008, 1065, 400000, 0, 400000, 'cancelled', 'seepay', NULL, N'Nguyễn Thành', 'mega_req_319@gmail.com', '0920853815', DATEADD(MINUTE, 17, DATEADD(HOUR, 22, DATEADD(DAY, -35, GETDATE()))), 400000),
(1320, 'ORD-MEGA-0320', 1014, 1067, 600000, 0, 600000, 'cancelled', 'seepay', NULL, N'Phạm Minh', 'mega_req_320@gmail.com', '0952357996', DATEADD(MINUTE, 58, DATEADD(HOUR, 3, DATEADD(DAY, -25, GETDATE()))), 600000),
(1321, 'ORD-MEGA-0321', 1008, 1011, 150000, 0, 150000, 'cancelled', 'seepay', NULL, N'Phạm Minh', 'mega_req_321@gmail.com', '0949359816', DATEADD(MINUTE, 49, DATEADD(HOUR, 15, DATEADD(DAY, -18, GETDATE()))), 150000),
(1322, 'ORD-MEGA-0322', 1032, 1080, 450000, 0, 450000, 'cancelled', 'seepay', NULL, N'Nguyễn Minh', 'mega_req_322@gmail.com', '0967203849', DATEADD(MINUTE, 52, DATEADD(HOUR, 1, DATEADD(DAY, -6, GETDATE()))), 450000),
(1323, 'ORD-MEGA-0323', 1057, 1014, 1500000, 0, 1500000, 'cancelled', 'seepay', NULL, N'Hoàng Phong', 'mega_req_323@gmail.com', '0934389951', DATEADD(MINUTE, 14, DATEADD(HOUR, 6, DATEADD(DAY, -44, GETDATE()))), 1500000),
(1324, 'ORD-MEGA-0324', 1047, 1060, 400000, 0, 400000, 'paid', 'seepay', DATEADD(MINUTE, 19, DATEADD(HOUR, 4, DATEADD(DAY, -59, GETDATE()))), N'Hoàng Trang', 'mega_req_324@gmail.com', '0992412792', DATEADD(MINUTE, 23, DATEADD(HOUR, 0, DATEADD(DAY, -27, GETDATE()))), 400000),
(1325, 'ORD-MEGA-0325', 1084, 1012, 600000, 0, 600000, 'paid', 'seepay', DATEADD(MINUTE, 27, DATEADD(HOUR, 13, DATEADD(DAY, -58, GETDATE()))), N'Phạm Trang', 'mega_req_325@gmail.com', '0960343516', DATEADD(MINUTE, 59, DATEADD(HOUR, 21, DATEADD(DAY, -14, GETDATE()))), 600000),
(1326, 'ORD-MEGA-0326', 1007, 1025, 450000, 0, 450000, 'paid', 'seepay', DATEADD(MINUTE, 26, DATEADD(HOUR, 17, DATEADD(DAY, -25, GETDATE()))), N'Vũ Tâm', 'mega_req_326@gmail.com', '0978068674', DATEADD(MINUTE, 47, DATEADD(HOUR, 15, DATEADD(DAY, -33, GETDATE()))), 450000),
(1327, 'ORD-MEGA-0327', 1091, 1073, 300000, 0, 300000, 'paid', 'seepay', DATEADD(MINUTE, 56, DATEADD(HOUR, 15, DATEADD(DAY, -3, GETDATE()))), N'Đỗ Anh', 'mega_req_327@gmail.com', '0921895086', DATEADD(MINUTE, 11, DATEADD(HOUR, 17, DATEADD(DAY, -35, GETDATE()))), 300000),
(1328, 'ORD-MEGA-0328', 1027, 1033, 1000000, 0, 1000000, 'refunded', 'seepay', DATEADD(MINUTE, 30, DATEADD(HOUR, 18, DATEADD(DAY, -36, GETDATE()))), N'Lê Lan', 'mega_req_328@gmail.com', '0949453669', DATEADD(MINUTE, 35, DATEADD(HOUR, 4, DATEADD(DAY, -33, GETDATE()))), 1000000),
(1329, 'ORD-MEGA-0329', 1053, 1061, 450000, 0, 450000, 'cancelled', 'seepay', NULL, N'Vũ Kiên', 'mega_req_329@gmail.com', '0972373948', DATEADD(MINUTE, 58, DATEADD(HOUR, 3, DATEADD(DAY, -44, GETDATE()))), 450000),
(1330, 'ORD-MEGA-0330', 1025, 1073, 800000, 0, 800000, 'pending', 'seepay', NULL, N'Bùi Thành', 'mega_req_330@gmail.com', '0940122975', DATEADD(MINUTE, 47, DATEADD(HOUR, 14, DATEADD(DAY, -32, GETDATE()))), 800000),
(1331, 'ORD-MEGA-0331', 1065, 1020, 600000, 0, 600000, 'refunded', 'seepay', DATEADD(MINUTE, 41, DATEADD(HOUR, 16, DATEADD(DAY, -3, GETDATE()))), N'Hoàng Anh', 'mega_req_331@gmail.com', '0911183720', DATEADD(MINUTE, 27, DATEADD(HOUR, 22, DATEADD(DAY, -7, GETDATE()))), 600000),
(1332, 'ORD-MEGA-0332', 1041, 1080, 800000, 0, 800000, 'cancelled', 'seepay', NULL, N'Trần Hải', 'mega_req_332@gmail.com', '0982620814', DATEADD(MINUTE, 57, DATEADD(HOUR, 2, DATEADD(DAY, -46, GETDATE()))), 800000),
(1333, 'ORD-MEGA-0333', 1042, 1030, 450000, 0, 450000, 'paid', 'seepay', DATEADD(MINUTE, 56, DATEADD(HOUR, 2, DATEADD(DAY, -54, GETDATE()))), N'Huỳnh Linh', 'mega_req_333@gmail.com', '0995187955', DATEADD(MINUTE, 53, DATEADD(HOUR, 0, DATEADD(DAY, -14, GETDATE()))), 450000),
(1334, 'ORD-MEGA-0334', 1097, 1081, 400000, 0, 400000, 'pending', 'seepay', NULL, N'Hoàng Kiên', 'mega_req_334@gmail.com', '0921237647', DATEADD(MINUTE, 29, DATEADD(HOUR, 23, DATEADD(DAY, -3, GETDATE()))), 400000),
(1335, 'ORD-MEGA-0335', 1070, 1019, 400000, 0, 400000, 'refunded', 'seepay', DATEADD(MINUTE, 20, DATEADD(HOUR, 10, DATEADD(DAY, -36, GETDATE()))), N'Đặng Khoa', 'mega_req_335@gmail.com', '0916847280', DATEADD(MINUTE, 54, DATEADD(HOUR, 12, DATEADD(DAY, -53, GETDATE()))), 400000),
(1336, 'ORD-MEGA-0336', 1060, 1098, 1500000, 0, 1500000, 'paid', 'seepay', DATEADD(MINUTE, 4, DATEADD(HOUR, 12, DATEADD(DAY, -8, GETDATE()))), N'Huỳnh Tâm', 'mega_req_336@gmail.com', '0968058758', DATEADD(MINUTE, 14, DATEADD(HOUR, 7, DATEADD(DAY, -13, GETDATE()))), 1500000),
(1337, 'ORD-MEGA-0337', 1027, 1041, 450000, 0, 450000, 'cancelled', 'seepay', NULL, N'Lê Trang', 'mega_req_337@gmail.com', '0989480520', DATEADD(MINUTE, 48, DATEADD(HOUR, 3, DATEADD(DAY, -12, GETDATE()))), 450000),
(1338, 'ORD-MEGA-0338', 1059, 1089, 200000, 0, 200000, 'cancelled', 'seepay', NULL, N'Bùi Tâm', 'mega_req_338@gmail.com', '0981393638', DATEADD(MINUTE, 46, DATEADD(HOUR, 15, DATEADD(DAY, -21, GETDATE()))), 200000),
(1339, 'ORD-MEGA-0339', 1029, 1042, 450000, 0, 450000, 'refunded', 'seepay', DATEADD(MINUTE, 58, DATEADD(HOUR, 0, DATEADD(DAY, -27, GETDATE()))), N'Hoàng Phong', 'mega_req_339@gmail.com', '0975435158', DATEADD(MINUTE, 5, DATEADD(HOUR, 18, DATEADD(DAY, -32, GETDATE()))), 450000),
(1340, 'ORD-MEGA-0340', 1061, 1075, 600000, 0, 600000, 'paid', 'seepay', DATEADD(MINUTE, 12, DATEADD(HOUR, 23, DATEADD(DAY, -60, GETDATE()))), N'Nguyễn Khoa', 'mega_req_340@gmail.com', '0956555491', DATEADD(MINUTE, 57, DATEADD(HOUR, 7, DATEADD(DAY, -42, GETDATE()))), 600000),
(1341, 'ORD-MEGA-0341', 1085, 1016, 200000, 0, 200000, 'paid', 'seepay', DATEADD(MINUTE, 6, DATEADD(HOUR, 13, DATEADD(DAY, -37, GETDATE()))), N'Phạm Trang', 'mega_req_341@gmail.com', '0952772002', DATEADD(MINUTE, 49, DATEADD(HOUR, 2, DATEADD(DAY, -58, GETDATE()))), 200000),
(1342, 'ORD-MEGA-0342', 1054, 1076, 300000, 0, 300000, 'refunded', 'seepay', DATEADD(MINUTE, 48, DATEADD(HOUR, 13, DATEADD(DAY, -19, GETDATE()))), N'Đỗ Bảo', 'mega_req_342@gmail.com', '0996009314', DATEADD(MINUTE, 8, DATEADD(HOUR, 16, DATEADD(DAY, -18, GETDATE()))), 300000),
(1343, 'ORD-MEGA-0343', 1088, 1038, 600000, 0, 600000, 'paid', 'seepay', DATEADD(MINUTE, 42, DATEADD(HOUR, 10, DATEADD(DAY, -18, GETDATE()))), N'Vũ Thành', 'mega_req_343@gmail.com', '0914102468', DATEADD(MINUTE, 34, DATEADD(HOUR, 19, DATEADD(DAY, -57, GETDATE()))), 600000),
(1344, 'ORD-MEGA-0344', 1072, 1004, 2000000, 0, 2000000, 'refunded', 'seepay', DATEADD(MINUTE, 31, DATEADD(HOUR, 3, DATEADD(DAY, -32, GETDATE()))), N'Trần Hùng', 'mega_req_344@gmail.com', '0938796172', DATEADD(MINUTE, 41, DATEADD(HOUR, 22, DATEADD(DAY, -34, GETDATE()))), 2000000),
(1345, 'ORD-MEGA-0345', 1045, 1045, 2000000, 0, 2000000, 'paid', 'seepay', DATEADD(MINUTE, 52, DATEADD(HOUR, 4, DATEADD(DAY, -55, GETDATE()))), N'Vũ Tâm', 'mega_req_345@gmail.com', '0996099890', DATEADD(MINUTE, 58, DATEADD(HOUR, 23, DATEADD(DAY, -9, GETDATE()))), 2000000),
(1346, 'ORD-MEGA-0346', 1006, 1056, 450000, 0, 450000, 'refunded', 'seepay', DATEADD(MINUTE, 0, DATEADD(HOUR, 5, DATEADD(DAY, -1, GETDATE()))), N'Hoàng Thu', 'mega_req_346@gmail.com', '0916247816', DATEADD(MINUTE, 59, DATEADD(HOUR, 9, DATEADD(DAY, -3, GETDATE()))), 450000),
(1347, 'ORD-MEGA-0347', 1020, 1046, 2000000, 0, 2000000, 'paid', 'seepay', DATEADD(MINUTE, 29, DATEADD(HOUR, 16, DATEADD(DAY, -29, GETDATE()))), N'Nguyễn Thành', 'mega_req_347@gmail.com', '0914767075', DATEADD(MINUTE, 46, DATEADD(HOUR, 12, DATEADD(DAY, -42, GETDATE()))), 2000000),
(1348, 'ORD-MEGA-0348', 1056, 1059, 300000, 0, 300000, 'paid', 'seepay', DATEADD(MINUTE, 10, DATEADD(HOUR, 15, DATEADD(DAY, -36, GETDATE()))), N'Bùi Vân', 'mega_req_348@gmail.com', '0995955314', DATEADD(MINUTE, 26, DATEADD(HOUR, 6, DATEADD(DAY, -16, GETDATE()))), 300000),
(1349, 'ORD-MEGA-0349', 1023, 1041, 400000, 0, 400000, 'refunded', 'seepay', DATEADD(MINUTE, 23, DATEADD(HOUR, 18, DATEADD(DAY, -23, GETDATE()))), N'Lê Phong', 'mega_req_349@gmail.com', '0934782476', DATEADD(MINUTE, 3, DATEADD(HOUR, 1, DATEADD(DAY, -48, GETDATE()))), 400000),
(1350, 'ORD-MEGA-0350', 1064, 1033, 600000, 0, 600000, 'cancelled', 'seepay', NULL, N'Hoàng Hải', 'mega_req_350@gmail.com', '0936753213', DATEADD(MINUTE, 50, DATEADD(HOUR, 22, DATEADD(DAY, -15, GETDATE()))), 600000),
(1351, 'ORD-MEGA-0351', 1050, 1098, 150000, 0, 150000, 'cancelled', 'seepay', NULL, N'Đỗ Hùng', 'mega_req_351@gmail.com', '0987775313', DATEADD(MINUTE, 16, DATEADD(HOUR, 14, DATEADD(DAY, -30, GETDATE()))), 150000),
(1352, 'ORD-MEGA-0352', 1010, 1000, 450000, 0, 450000, 'pending', 'seepay', NULL, N'Trần Anh', 'mega_req_352@gmail.com', '0932423715', DATEADD(MINUTE, 59, DATEADD(HOUR, 20, DATEADD(DAY, -49, GETDATE()))), 450000),
(1353, 'ORD-MEGA-0353', 1039, 1041, 600000, 0, 600000, 'pending', 'seepay', NULL, N'Vũ Bảo', 'mega_req_353@gmail.com', '0945522225', DATEADD(MINUTE, 48, DATEADD(HOUR, 16, DATEADD(DAY, -39, GETDATE()))), 600000),
(1354, 'ORD-MEGA-0354', 1076, 1018, 600000, 0, 600000, 'refunded', 'seepay', DATEADD(MINUTE, 43, DATEADD(HOUR, 18, DATEADD(DAY, -1, GETDATE()))), N'Trần Hùng', 'mega_req_354@gmail.com', '0957304839', DATEADD(MINUTE, 58, DATEADD(HOUR, 1, DATEADD(DAY, -55, GETDATE()))), 600000),
(1355, 'ORD-MEGA-0355', 1007, 1011, 600000, 0, 600000, 'paid', 'seepay', DATEADD(MINUTE, 48, DATEADD(HOUR, 10, DATEADD(DAY, -39, GETDATE()))), N'Hoàng Phong', 'mega_req_355@gmail.com', '0988871901', DATEADD(MINUTE, 28, DATEADD(HOUR, 5, DATEADD(DAY, -57, GETDATE()))), 600000),
(1356, 'ORD-MEGA-0356', 1071, 1070, 1500000, 0, 1500000, 'cancelled', 'seepay', NULL, N'Trần Vân', 'mega_req_356@gmail.com', '0992889699', DATEADD(MINUTE, 45, DATEADD(HOUR, 8, DATEADD(DAY, -24, GETDATE()))), 1500000),
(1357, 'ORD-MEGA-0357', 1016, 1031, 800000, 0, 800000, 'paid', 'seepay', DATEADD(MINUTE, 3, DATEADD(HOUR, 22, DATEADD(DAY, -53, GETDATE()))), N'Lê Lan', 'mega_req_357@gmail.com', '0960403504', DATEADD(MINUTE, 23, DATEADD(HOUR, 13, DATEADD(DAY, -25, GETDATE()))), 800000),
(1358, 'ORD-MEGA-0358', 1037, 1003, 500000, 0, 500000, 'paid', 'seepay', DATEADD(MINUTE, 29, DATEADD(HOUR, 21, DATEADD(DAY, -6, GETDATE()))), N'Phạm Lan', 'mega_req_358@gmail.com', '0946799557', DATEADD(MINUTE, 14, DATEADD(HOUR, 18, DATEADD(DAY, -29, GETDATE()))), 500000),
(1359, 'ORD-MEGA-0359', 1053, 1054, 450000, 0, 450000, 'pending', 'seepay', NULL, N'Đỗ Hùng', 'mega_req_359@gmail.com', '0911631543', DATEADD(MINUTE, 38, DATEADD(HOUR, 3, DATEADD(DAY, -3, GETDATE()))), 450000),
(1360, 'ORD-MEGA-0360', 1066, 1037, 500000, 0, 500000, 'paid', 'seepay', DATEADD(MINUTE, 9, DATEADD(HOUR, 16, DATEADD(DAY, -16, GETDATE()))), N'Đỗ Minh', 'mega_req_360@gmail.com', '0927980992', DATEADD(MINUTE, 52, DATEADD(HOUR, 16, DATEADD(DAY, -27, GETDATE()))), 500000),
(1361, 'ORD-MEGA-0361', 1006, 1029, 800000, 0, 800000, 'paid', 'seepay', DATEADD(MINUTE, 8, DATEADD(HOUR, 8, DATEADD(DAY, -13, GETDATE()))), N'Phạm Trang', 'mega_req_361@gmail.com', '0948722295', DATEADD(MINUTE, 35, DATEADD(HOUR, 15, DATEADD(DAY, -4, GETDATE()))), 800000),
(1362, 'ORD-MEGA-0362', 1055, 1057, 800000, 0, 800000, 'paid', 'seepay', DATEADD(MINUTE, 6, DATEADD(HOUR, 13, DATEADD(DAY, 0, GETDATE()))), N'Hoàng Minh', 'mega_req_362@gmail.com', '0922996694', DATEADD(MINUTE, 30, DATEADD(HOUR, 6, DATEADD(DAY, -57, GETDATE()))), 800000),
(1363, 'ORD-MEGA-0363', 1067, 1084, 1000000, 0, 1000000, 'pending', 'seepay', NULL, N'Lê Phong', 'mega_req_363@gmail.com', '0959146512', DATEADD(MINUTE, 6, DATEADD(HOUR, 20, DATEADD(DAY, 0, GETDATE()))), 1000000),
(1364, 'ORD-MEGA-0364', 1085, 1054, 800000, 0, 800000, 'pending', 'seepay', NULL, N'Huỳnh Khoa', 'mega_req_364@gmail.com', '0913924513', DATEADD(MINUTE, 15, DATEADD(HOUR, 1, DATEADD(DAY, -20, GETDATE()))), 800000),
(1365, 'ORD-MEGA-0365', 1064, 1066, 400000, 0, 400000, 'paid', 'seepay', DATEADD(MINUTE, 43, DATEADD(HOUR, 11, DATEADD(DAY, -2, GETDATE()))), N'Phạm Thành', 'mega_req_365@gmail.com', '0917826493', DATEADD(MINUTE, 45, DATEADD(HOUR, 15, DATEADD(DAY, -49, GETDATE()))), 400000),
(1366, 'ORD-MEGA-0366', 1006, 1093, 600000, 0, 600000, 'refunded', 'seepay', DATEADD(MINUTE, 20, DATEADD(HOUR, 13, DATEADD(DAY, -9, GETDATE()))), N'Phạm Phong', 'mega_req_366@gmail.com', '0980583039', DATEADD(MINUTE, 34, DATEADD(HOUR, 15, DATEADD(DAY, -2, GETDATE()))), 600000),
(1367, 'ORD-MEGA-0367', 1061, 1089, 600000, 0, 600000, 'paid', 'seepay', DATEADD(MINUTE, 6, DATEADD(HOUR, 22, DATEADD(DAY, -31, GETDATE()))), N'Trần Bảo', 'mega_req_367@gmail.com', '0925358144', DATEADD(MINUTE, 48, DATEADD(HOUR, 15, DATEADD(DAY, -34, GETDATE()))), 600000),
(1368, 'ORD-MEGA-0368', 1073, 1000, 1500000, 0, 1500000, 'refunded', 'seepay', DATEADD(MINUTE, 50, DATEADD(HOUR, 12, DATEADD(DAY, -30, GETDATE()))), N'Bùi Hải', 'mega_req_368@gmail.com', '0947002082', DATEADD(MINUTE, 12, DATEADD(HOUR, 4, DATEADD(DAY, -5, GETDATE()))), 1500000),
(1369, 'ORD-MEGA-0369', 1036, 1003, 600000, 0, 600000, 'cancelled', 'seepay', NULL, N'Lê Trang', 'mega_req_369@gmail.com', '0949915922', DATEADD(MINUTE, 17, DATEADD(HOUR, 22, DATEADD(DAY, -53, GETDATE()))), 600000),
(1370, 'ORD-MEGA-0370', 1077, 1055, 800000, 0, 800000, 'cancelled', 'seepay', NULL, N'Huỳnh Linh', 'mega_req_370@gmail.com', '0985239644', DATEADD(MINUTE, 6, DATEADD(HOUR, 15, DATEADD(DAY, -46, GETDATE()))), 800000),
(1371, 'ORD-MEGA-0371', 1037, 1074, 150000, 0, 150000, 'paid', 'seepay', DATEADD(MINUTE, 8, DATEADD(HOUR, 4, DATEADD(DAY, -41, GETDATE()))), N'Đặng Trang', 'mega_req_371@gmail.com', '0983895615', DATEADD(MINUTE, 17, DATEADD(HOUR, 18, DATEADD(DAY, -4, GETDATE()))), 150000),
(1372, 'ORD-MEGA-0372', 1023, 1051, 1000000, 0, 1000000, 'pending', 'seepay', NULL, N'Trần Linh', 'mega_req_372@gmail.com', '0969090859', DATEADD(MINUTE, 4, DATEADD(HOUR, 15, DATEADD(DAY, -59, GETDATE()))), 1000000),
(1373, 'ORD-MEGA-0373', 1059, 1007, 500000, 0, 500000, 'refunded', 'seepay', DATEADD(MINUTE, 54, DATEADD(HOUR, 14, DATEADD(DAY, -51, GETDATE()))), N'Đặng Tâm', 'mega_req_373@gmail.com', '0967479379', DATEADD(MINUTE, 47, DATEADD(HOUR, 16, DATEADD(DAY, -52, GETDATE()))), 500000),
(1374, 'ORD-MEGA-0374', 1026, 1044, 600000, 0, 600000, 'pending', 'seepay', NULL, N'Phạm Tâm', 'mega_req_374@gmail.com', '0975154682', DATEADD(MINUTE, 46, DATEADD(HOUR, 21, DATEADD(DAY, -42, GETDATE()))), 600000),
(1375, 'ORD-MEGA-0375', 1064, 1014, 200000, 0, 200000, 'cancelled', 'seepay', NULL, N'Bùi Lan', 'mega_req_375@gmail.com', '0932005316', DATEADD(MINUTE, 59, DATEADD(HOUR, 22, DATEADD(DAY, -4, GETDATE()))), 200000),
(1376, 'ORD-MEGA-0376', 1038, 1013, 1500000, 0, 1500000, 'pending', 'seepay', NULL, N'Huỳnh Kiên', 'mega_req_376@gmail.com', '0980616858', DATEADD(MINUTE, 24, DATEADD(HOUR, 4, DATEADD(DAY, -33, GETDATE()))), 1500000),
(1377, 'ORD-MEGA-0377', 1073, 1001, 200000, 0, 200000, 'cancelled', 'seepay', NULL, N'Đỗ Kiên', 'mega_req_377@gmail.com', '0957144671', DATEADD(MINUTE, 5, DATEADD(HOUR, 0, DATEADD(DAY, -41, GETDATE()))), 200000),
(1378, 'ORD-MEGA-0378', 1011, 1039, 1000000, 0, 1000000, 'pending', 'seepay', NULL, N'Vũ Anh', 'mega_req_378@gmail.com', '0921624461', DATEADD(MINUTE, 7, DATEADD(HOUR, 13, DATEADD(DAY, -39, GETDATE()))), 1000000),
(1379, 'ORD-MEGA-0379', 1033, 1081, 1000000, 0, 1000000, 'cancelled', 'seepay', NULL, N'Đặng Trang', 'mega_req_379@gmail.com', '0976461811', DATEADD(MINUTE, 3, DATEADD(HOUR, 14, DATEADD(DAY, -6, GETDATE()))), 1000000),
(1380, 'ORD-MEGA-0380', 1088, 1074, 400000, 0, 400000, 'refunded', 'seepay', DATEADD(MINUTE, 43, DATEADD(HOUR, 19, DATEADD(DAY, -57, GETDATE()))), N'Vũ Khoa', 'mega_req_380@gmail.com', '0987522164', DATEADD(MINUTE, 49, DATEADD(HOUR, 21, DATEADD(DAY, -1, GETDATE()))), 400000),
(1381, 'ORD-MEGA-0381', 1019, 1036, 2000000, 0, 2000000, 'paid', 'seepay', DATEADD(MINUTE, 36, DATEADD(HOUR, 15, DATEADD(DAY, -4, GETDATE()))), N'Bùi Phong', 'mega_req_381@gmail.com', '0949651227', DATEADD(MINUTE, 59, DATEADD(HOUR, 18, DATEADD(DAY, -58, GETDATE()))), 2000000),
(1382, 'ORD-MEGA-0382', 1082, 1006, 1500000, 0, 1500000, 'paid', 'seepay', DATEADD(MINUTE, 26, DATEADD(HOUR, 11, DATEADD(DAY, -35, GETDATE()))), N'Đặng Vân', 'mega_req_382@gmail.com', '0961850372', DATEADD(MINUTE, 18, DATEADD(HOUR, 5, DATEADD(DAY, -58, GETDATE()))), 1500000),
(1383, 'ORD-MEGA-0383', 1097, 1026, 600000, 0, 600000, 'paid', 'seepay', DATEADD(MINUTE, 15, DATEADD(HOUR, 16, DATEADD(DAY, -53, GETDATE()))), N'Huỳnh Lan', 'mega_req_383@gmail.com', '0978109392', DATEADD(MINUTE, 59, DATEADD(HOUR, 7, DATEADD(DAY, -4, GETDATE()))), 600000),
(1384, 'ORD-MEGA-0384', 1057, 1098, 800000, 0, 800000, 'paid', 'seepay', DATEADD(MINUTE, 35, DATEADD(HOUR, 5, DATEADD(DAY, -15, GETDATE()))), N'Trần Hùng', 'mega_req_384@gmail.com', '0971642877', DATEADD(MINUTE, 27, DATEADD(HOUR, 18, DATEADD(DAY, -19, GETDATE()))), 800000),
(1385, 'ORD-MEGA-0385', 1073, 1004, 450000, 0, 450000, 'paid', 'seepay', DATEADD(MINUTE, 56, DATEADD(HOUR, 18, DATEADD(DAY, -60, GETDATE()))), N'Nguyễn Anh', 'mega_req_385@gmail.com', '0947648825', DATEADD(MINUTE, 21, DATEADD(HOUR, 14, DATEADD(DAY, -41, GETDATE()))), 450000),
(1386, 'ORD-MEGA-0386', 1074, 1039, 300000, 0, 300000, 'paid', 'seepay', DATEADD(MINUTE, 44, DATEADD(HOUR, 9, DATEADD(DAY, -32, GETDATE()))), N'Huỳnh Hùng', 'mega_req_386@gmail.com', '0997422923', DATEADD(MINUTE, 44, DATEADD(HOUR, 21, DATEADD(DAY, -34, GETDATE()))), 300000),
(1387, 'ORD-MEGA-0387', 1001, 1087, 450000, 0, 450000, 'paid', 'seepay', DATEADD(MINUTE, 59, DATEADD(HOUR, 4, DATEADD(DAY, -39, GETDATE()))), N'Lê Hùng', 'mega_req_387@gmail.com', '0971503806', DATEADD(MINUTE, 46, DATEADD(HOUR, 23, DATEADD(DAY, -6, GETDATE()))), 450000),
(1388, 'ORD-MEGA-0388', 1078, 1038, 800000, 0, 800000, 'paid', 'seepay', DATEADD(MINUTE, 17, DATEADD(HOUR, 11, DATEADD(DAY, -9, GETDATE()))), N'Huỳnh Linh', 'mega_req_388@gmail.com', '0915325460', DATEADD(MINUTE, 41, DATEADD(HOUR, 13, DATEADD(DAY, -47, GETDATE()))), 800000),
(1389, 'ORD-MEGA-0389', 1017, 1038, 300000, 0, 300000, 'pending', 'seepay', NULL, N'Hoàng Bảo', 'mega_req_389@gmail.com', '0965802118', DATEADD(MINUTE, 29, DATEADD(HOUR, 8, DATEADD(DAY, -56, GETDATE()))), 300000),
(1390, 'ORD-MEGA-0390', 1044, 1060, 200000, 0, 200000, 'paid', 'seepay', DATEADD(MINUTE, 3, DATEADD(HOUR, 4, DATEADD(DAY, -49, GETDATE()))), N'Đỗ Vân', 'mega_req_390@gmail.com', '0988129389', DATEADD(MINUTE, 34, DATEADD(HOUR, 16, DATEADD(DAY, -3, GETDATE()))), 200000),
(1391, 'ORD-MEGA-0391', 1091, 1059, 150000, 0, 150000, 'refunded', 'seepay', DATEADD(MINUTE, 25, DATEADD(HOUR, 22, DATEADD(DAY, -50, GETDATE()))), N'Nguyễn Hùng', 'mega_req_391@gmail.com', '0966129903', DATEADD(MINUTE, 35, DATEADD(HOUR, 3, DATEADD(DAY, -30, GETDATE()))), 150000),
(1392, 'ORD-MEGA-0392', 1009, 1061, 150000, 0, 150000, 'paid', 'seepay', DATEADD(MINUTE, 13, DATEADD(HOUR, 22, DATEADD(DAY, -31, GETDATE()))), N'Bùi Vân', 'mega_req_392@gmail.com', '0931677627', DATEADD(MINUTE, 59, DATEADD(HOUR, 21, DATEADD(DAY, -23, GETDATE()))), 150000),
(1393, 'ORD-MEGA-0393', 1090, 1094, 600000, 0, 600000, 'paid', 'seepay', DATEADD(MINUTE, 6, DATEADD(HOUR, 4, DATEADD(DAY, -39, GETDATE()))), N'Vũ Minh', 'mega_req_393@gmail.com', '0959361601', DATEADD(MINUTE, 44, DATEADD(HOUR, 8, DATEADD(DAY, -39, GETDATE()))), 600000),
(1394, 'ORD-MEGA-0394', 1041, 1079, 450000, 0, 450000, 'paid', 'seepay', DATEADD(MINUTE, 25, DATEADD(HOUR, 11, DATEADD(DAY, -56, GETDATE()))), N'Hoàng Hải', 'mega_req_394@gmail.com', '0959604377', DATEADD(MINUTE, 48, DATEADD(HOUR, 23, DATEADD(DAY, -51, GETDATE()))), 450000),
(1395, 'ORD-MEGA-0395', 1057, 1013, 800000, 0, 800000, 'paid', 'seepay', DATEADD(MINUTE, 38, DATEADD(HOUR, 20, DATEADD(DAY, -45, GETDATE()))), N'Lê Thành', 'mega_req_395@gmail.com', '0981961885', DATEADD(MINUTE, 24, DATEADD(HOUR, 6, DATEADD(DAY, -30, GETDATE()))), 800000),
(1396, 'ORD-MEGA-0396', 1015, 1010, 500000, 0, 500000, 'paid', 'seepay', DATEADD(MINUTE, 23, DATEADD(HOUR, 1, DATEADD(DAY, -24, GETDATE()))), N'Nguyễn Thu', 'mega_req_396@gmail.com', '0957484201', DATEADD(MINUTE, 7, DATEADD(HOUR, 7, DATEADD(DAY, -11, GETDATE()))), 500000),
(1397, 'ORD-MEGA-0397', 1068, 1001, 200000, 0, 200000, 'pending', 'seepay', NULL, N'Phạm Khoa', 'mega_req_397@gmail.com', '0922925748', DATEADD(MINUTE, 53, DATEADD(HOUR, 9, DATEADD(DAY, -30, GETDATE()))), 200000),
(1398, 'ORD-MEGA-0398', 1024, 1079, 450000, 0, 450000, 'paid', 'seepay', DATEADD(MINUTE, 5, DATEADD(HOUR, 2, DATEADD(DAY, -32, GETDATE()))), N'Lê Thành', 'mega_req_398@gmail.com', '0973655268', DATEADD(MINUTE, 55, DATEADD(HOUR, 22, DATEADD(DAY, -10, GETDATE()))), 450000),
(1399, 'ORD-MEGA-0399', 1036, 1032, 600000, 0, 600000, 'pending', 'seepay', NULL, N'Phạm Lan', 'mega_req_399@gmail.com', '0946006955', DATEADD(MINUTE, 54, DATEADD(HOUR, 21, DATEADD(DAY, -34, GETDATE()))), 600000);
INSERT INTO Orders (order_id, order_code, user_id, event_id, total_amount, discount_amount, final_amount, status, payment_method, payment_date, buyer_name, buyer_email, buyer_phone, created_at, organizer_payout_amount) VALUES
(1400, 'ORD-MEGA-0400', 1097, 1087, 300000, 0, 300000, 'paid', 'seepay', DATEADD(MINUTE, 9, DATEADD(HOUR, 20, DATEADD(DAY, -35, GETDATE()))), N'Lê Hùng', 'mega_req_400@gmail.com', '0918221469', DATEADD(MINUTE, 20, DATEADD(HOUR, 21, DATEADD(DAY, -50, GETDATE()))), 300000),
(1401, 'ORD-MEGA-0401', 1027, 1078, 800000, 0, 800000, 'paid', 'seepay', DATEADD(MINUTE, 10, DATEADD(HOUR, 18, DATEADD(DAY, -35, GETDATE()))), N'Phạm Minh', 'mega_req_401@gmail.com', '0978095249', DATEADD(MINUTE, 5, DATEADD(HOUR, 1, DATEADD(DAY, -43, GETDATE()))), 800000),
(1402, 'ORD-MEGA-0402', 1052, 1095, 500000, 0, 500000, 'paid', 'seepay', DATEADD(MINUTE, 34, DATEADD(HOUR, 8, DATEADD(DAY, -16, GETDATE()))), N'Đỗ Trang', 'mega_req_402@gmail.com', '0931892504', DATEADD(MINUTE, 34, DATEADD(HOUR, 7, DATEADD(DAY, -55, GETDATE()))), 500000),
(1403, 'ORD-MEGA-0403', 1052, 1064, 200000, 0, 200000, 'paid', 'seepay', DATEADD(MINUTE, 36, DATEADD(HOUR, 0, DATEADD(DAY, -12, GETDATE()))), N'Vũ Khoa', 'mega_req_403@gmail.com', '0975412427', DATEADD(MINUTE, 33, DATEADD(HOUR, 7, DATEADD(DAY, -31, GETDATE()))), 200000),
(1404, 'ORD-MEGA-0404', 1089, 1043, 600000, 0, 600000, 'cancelled', 'seepay', NULL, N'Huỳnh Thu', 'mega_req_404@gmail.com', '0946333847', DATEADD(MINUTE, 39, DATEADD(HOUR, 13, DATEADD(DAY, -8, GETDATE()))), 600000),
(1405, 'ORD-MEGA-0405', 1077, 1006, 450000, 0, 450000, 'paid', 'seepay', DATEADD(MINUTE, 54, DATEADD(HOUR, 20, DATEADD(DAY, -39, GETDATE()))), N'Bùi Hùng', 'mega_req_405@gmail.com', '0960049360', DATEADD(MINUTE, 1, DATEADD(HOUR, 21, DATEADD(DAY, -56, GETDATE()))), 450000),
(1406, 'ORD-MEGA-0406', 1034, 1020, 600000, 0, 600000, 'paid', 'seepay', DATEADD(MINUTE, 49, DATEADD(HOUR, 22, DATEADD(DAY, -1, GETDATE()))), N'Nguyễn Vân', 'mega_req_406@gmail.com', '0950128582', DATEADD(MINUTE, 23, DATEADD(HOUR, 20, DATEADD(DAY, -31, GETDATE()))), 600000),
(1407, 'ORD-MEGA-0407', 1039, 1079, 1500000, 0, 1500000, 'paid', 'seepay', DATEADD(MINUTE, 39, DATEADD(HOUR, 12, DATEADD(DAY, -54, GETDATE()))), N'Nguyễn Hải', 'mega_req_407@gmail.com', '0967746634', DATEADD(MINUTE, 43, DATEADD(HOUR, 21, DATEADD(DAY, -11, GETDATE()))), 1500000),
(1408, 'ORD-MEGA-0408', 1070, 1059, 150000, 0, 150000, 'paid', 'seepay', DATEADD(MINUTE, 10, DATEADD(HOUR, 0, DATEADD(DAY, -53, GETDATE()))), N'Đỗ Anh', 'mega_req_408@gmail.com', '0930685875', DATEADD(MINUTE, 3, DATEADD(HOUR, 20, DATEADD(DAY, -54, GETDATE()))), 150000),
(1409, 'ORD-MEGA-0409', 1090, 1023, 600000, 0, 600000, 'refunded', 'seepay', DATEADD(MINUTE, 37, DATEADD(HOUR, 23, DATEADD(DAY, -12, GETDATE()))), N'Bùi Thành', 'mega_req_409@gmail.com', '0948313706', DATEADD(MINUTE, 41, DATEADD(HOUR, 0, DATEADD(DAY, -35, GETDATE()))), 600000),
(1410, 'ORD-MEGA-0410', 1026, 1098, 150000, 0, 150000, 'paid', 'seepay', DATEADD(MINUTE, 21, DATEADD(HOUR, 13, DATEADD(DAY, -18, GETDATE()))), N'Nguyễn Thành', 'mega_req_410@gmail.com', '0979935469', DATEADD(MINUTE, 5, DATEADD(HOUR, 23, DATEADD(DAY, -21, GETDATE()))), 150000),
(1411, 'ORD-MEGA-0411', 1006, 1080, 150000, 0, 150000, 'pending', 'seepay', NULL, N'Trần Thành', 'mega_req_411@gmail.com', '0990004844', DATEADD(MINUTE, 11, DATEADD(HOUR, 2, DATEADD(DAY, -5, GETDATE()))), 150000),
(1412, 'ORD-MEGA-0412', 1068, 1038, 500000, 0, 500000, 'paid', 'seepay', DATEADD(MINUTE, 33, DATEADD(HOUR, 1, DATEADD(DAY, -58, GETDATE()))), N'Vũ Phong', 'mega_req_412@gmail.com', '0958857480', DATEADD(MINUTE, 38, DATEADD(HOUR, 20, DATEADD(DAY, -8, GETDATE()))), 500000),
(1413, 'ORD-MEGA-0413', 1056, 1020, 1500000, 0, 1500000, 'refunded', 'seepay', DATEADD(MINUTE, 15, DATEADD(HOUR, 12, DATEADD(DAY, -35, GETDATE()))), N'Trần Anh', 'mega_req_413@gmail.com', '0986214770', DATEADD(MINUTE, 30, DATEADD(HOUR, 19, DATEADD(DAY, -29, GETDATE()))), 1500000),
(1414, 'ORD-MEGA-0414', 1013, 1027, 150000, 0, 150000, 'refunded', 'seepay', DATEADD(MINUTE, 36, DATEADD(HOUR, 16, DATEADD(DAY, -30, GETDATE()))), N'Trần Minh', 'mega_req_414@gmail.com', '0918813834', DATEADD(MINUTE, 1, DATEADD(HOUR, 7, DATEADD(DAY, -50, GETDATE()))), 150000),
(1415, 'ORD-MEGA-0415', 1050, 1080, 500000, 0, 500000, 'paid', 'seepay', DATEADD(MINUTE, 53, DATEADD(HOUR, 19, DATEADD(DAY, -43, GETDATE()))), N'Hoàng Lan', 'mega_req_415@gmail.com', '0979954013', DATEADD(MINUTE, 56, DATEADD(HOUR, 10, DATEADD(DAY, -43, GETDATE()))), 500000),
(1416, 'ORD-MEGA-0416', 1000, 1008, 800000, 0, 800000, 'paid', 'seepay', DATEADD(MINUTE, 50, DATEADD(HOUR, 15, DATEADD(DAY, -60, GETDATE()))), N'Đặng Thành', 'mega_req_416@gmail.com', '0938726365', DATEADD(MINUTE, 47, DATEADD(HOUR, 20, DATEADD(DAY, -57, GETDATE()))), 800000),
(1417, 'ORD-MEGA-0417', 1044, 1098, 1500000, 0, 1500000, 'paid', 'seepay', DATEADD(MINUTE, 58, DATEADD(HOUR, 21, DATEADD(DAY, -17, GETDATE()))), N'Phạm Anh', 'mega_req_417@gmail.com', '0939887800', DATEADD(MINUTE, 10, DATEADD(HOUR, 0, DATEADD(DAY, -6, GETDATE()))), 1500000),
(1418, 'ORD-MEGA-0418', 1006, 1074, 400000, 0, 400000, 'paid', 'seepay', DATEADD(MINUTE, 27, DATEADD(HOUR, 19, DATEADD(DAY, -53, GETDATE()))), N'Vũ Bảo', 'mega_req_418@gmail.com', '0967066778', DATEADD(MINUTE, 56, DATEADD(HOUR, 20, DATEADD(DAY, -12, GETDATE()))), 400000),
(1419, 'ORD-MEGA-0419', 1001, 1082, 1000000, 0, 1000000, 'paid', 'seepay', DATEADD(MINUTE, 18, DATEADD(HOUR, 21, DATEADD(DAY, -1, GETDATE()))), N'Huỳnh Vân', 'mega_req_419@gmail.com', '0954896677', DATEADD(MINUTE, 49, DATEADD(HOUR, 14, DATEADD(DAY, -6, GETDATE()))), 1000000),
(1420, 'ORD-MEGA-0420', 1023, 1075, 450000, 0, 450000, 'paid', 'seepay', DATEADD(MINUTE, 7, DATEADD(HOUR, 22, DATEADD(DAY, -7, GETDATE()))), N'Lê Hùng', 'mega_req_420@gmail.com', '0957348616', DATEADD(MINUTE, 57, DATEADD(HOUR, 14, DATEADD(DAY, -9, GETDATE()))), 450000),
(1421, 'ORD-MEGA-0421', 1080, 1058, 200000, 0, 200000, 'pending', 'seepay', NULL, N'Trần Thu', 'mega_req_421@gmail.com', '0950759045', DATEADD(MINUTE, 54, DATEADD(HOUR, 4, DATEADD(DAY, -39, GETDATE()))), 200000),
(1422, 'ORD-MEGA-0422', 1097, 1088, 400000, 0, 400000, 'cancelled', 'seepay', NULL, N'Lê Hùng', 'mega_req_422@gmail.com', '0977712727', DATEADD(MINUTE, 47, DATEADD(HOUR, 2, DATEADD(DAY, -27, GETDATE()))), 400000),
(1423, 'ORD-MEGA-0423', 1074, 1052, 300000, 0, 300000, 'cancelled', 'seepay', NULL, N'Đỗ Hùng', 'mega_req_423@gmail.com', '0997438716', DATEADD(MINUTE, 45, DATEADD(HOUR, 3, DATEADD(DAY, -38, GETDATE()))), 300000),
(1424, 'ORD-MEGA-0424', 1015, 1052, 1000000, 0, 1000000, 'paid', 'seepay', DATEADD(MINUTE, 44, DATEADD(HOUR, 10, DATEADD(DAY, -43, GETDATE()))), N'Nguyễn Khoa', 'mega_req_424@gmail.com', '0943781960', DATEADD(MINUTE, 56, DATEADD(HOUR, 4, DATEADD(DAY, -5, GETDATE()))), 1000000),
(1425, 'ORD-MEGA-0425', 1001, 1030, 800000, 0, 800000, 'refunded', 'seepay', DATEADD(MINUTE, 26, DATEADD(HOUR, 3, DATEADD(DAY, -5, GETDATE()))), N'Nguyễn Phong', 'mega_req_425@gmail.com', '0952889717', DATEADD(MINUTE, 52, DATEADD(HOUR, 15, DATEADD(DAY, -4, GETDATE()))), 800000),
(1426, 'ORD-MEGA-0426', 1036, 1063, 600000, 0, 600000, 'paid', 'seepay', DATEADD(MINUTE, 25, DATEADD(HOUR, 18, DATEADD(DAY, -32, GETDATE()))), N'Vũ Trang', 'mega_req_426@gmail.com', '0973689725', DATEADD(MINUTE, 5, DATEADD(HOUR, 14, DATEADD(DAY, -36, GETDATE()))), 600000),
(1427, 'ORD-MEGA-0427', 1075, 1093, 450000, 0, 450000, 'refunded', 'seepay', DATEADD(MINUTE, 7, DATEADD(HOUR, 18, DATEADD(DAY, -56, GETDATE()))), N'Đặng Hải', 'mega_req_427@gmail.com', '0991333765', DATEADD(MINUTE, 0, DATEADD(HOUR, 4, DATEADD(DAY, -8, GETDATE()))), 450000),
(1428, 'ORD-MEGA-0428', 1008, 1095, 600000, 0, 600000, 'cancelled', 'seepay', NULL, N'Đặng Hùng', 'mega_req_428@gmail.com', '0980995563', DATEADD(MINUTE, 15, DATEADD(HOUR, 6, DATEADD(DAY, -4, GETDATE()))), 600000),
(1429, 'ORD-MEGA-0429', 1016, 1094, 300000, 0, 300000, 'refunded', 'seepay', DATEADD(MINUTE, 9, DATEADD(HOUR, 22, DATEADD(DAY, -8, GETDATE()))), N'Nguyễn Kiên', 'mega_req_429@gmail.com', '0956245255', DATEADD(MINUTE, 0, DATEADD(HOUR, 18, DATEADD(DAY, -12, GETDATE()))), 300000),
(1430, 'ORD-MEGA-0430', 1056, 1009, 150000, 0, 150000, 'paid', 'seepay', DATEADD(MINUTE, 1, DATEADD(HOUR, 4, DATEADD(DAY, -27, GETDATE()))), N'Đặng Trang', 'mega_req_430@gmail.com', '0913427898', DATEADD(MINUTE, 47, DATEADD(HOUR, 19, DATEADD(DAY, -14, GETDATE()))), 150000),
(1431, 'ORD-MEGA-0431', 1003, 1038, 500000, 0, 500000, 'paid', 'seepay', DATEADD(MINUTE, 6, DATEADD(HOUR, 3, DATEADD(DAY, -48, GETDATE()))), N'Vũ Lan', 'mega_req_431@gmail.com', '0954695808', DATEADD(MINUTE, 48, DATEADD(HOUR, 20, DATEADD(DAY, -16, GETDATE()))), 500000),
(1432, 'ORD-MEGA-0432', 1082, 1061, 600000, 0, 600000, 'cancelled', 'seepay', NULL, N'Nguyễn Hải', 'mega_req_432@gmail.com', '0921229489', DATEADD(MINUTE, 21, DATEADD(HOUR, 12, DATEADD(DAY, -4, GETDATE()))), 600000),
(1433, 'ORD-MEGA-0433', 1065, 1084, 500000, 0, 500000, 'pending', 'seepay', NULL, N'Bùi Anh', 'mega_req_433@gmail.com', '0990024910', DATEADD(MINUTE, 1, DATEADD(HOUR, 16, DATEADD(DAY, -22, GETDATE()))), 500000),
(1434, 'ORD-MEGA-0434', 1036, 1029, 1500000, 0, 1500000, 'refunded', 'seepay', DATEADD(MINUTE, 40, DATEADD(HOUR, 4, DATEADD(DAY, -5, GETDATE()))), N'Phạm Tâm', 'mega_req_434@gmail.com', '0938972235', DATEADD(MINUTE, 19, DATEADD(HOUR, 7, DATEADD(DAY, -4, GETDATE()))), 1500000),
(1435, 'ORD-MEGA-0435', 1000, 1025, 600000, 0, 600000, 'paid', 'seepay', DATEADD(MINUTE, 29, DATEADD(HOUR, 5, DATEADD(DAY, -41, GETDATE()))), N'Đặng Anh', 'mega_req_435@gmail.com', '0964493321', DATEADD(MINUTE, 38, DATEADD(HOUR, 0, DATEADD(DAY, -47, GETDATE()))), 600000),
(1436, 'ORD-MEGA-0436', 1015, 1085, 800000, 0, 800000, 'refunded', 'seepay', DATEADD(MINUTE, 37, DATEADD(HOUR, 14, DATEADD(DAY, -27, GETDATE()))), N'Huỳnh Hùng', 'mega_req_436@gmail.com', '0942443048', DATEADD(MINUTE, 14, DATEADD(HOUR, 6, DATEADD(DAY, -28, GETDATE()))), 800000),
(1437, 'ORD-MEGA-0437', 1036, 1051, 2000000, 0, 2000000, 'pending', 'seepay', NULL, N'Vũ Phong', 'mega_req_437@gmail.com', '0910628846', DATEADD(MINUTE, 28, DATEADD(HOUR, 17, DATEADD(DAY, -38, GETDATE()))), 2000000),
(1438, 'ORD-MEGA-0438', 1077, 1055, 1500000, 0, 1500000, 'paid', 'seepay', DATEADD(MINUTE, 42, DATEADD(HOUR, 15, DATEADD(DAY, 0, GETDATE()))), N'Phạm Thành', 'mega_req_438@gmail.com', '0993137348', DATEADD(MINUTE, 0, DATEADD(HOUR, 1, DATEADD(DAY, -18, GETDATE()))), 1500000),
(1439, 'ORD-MEGA-0439', 1033, 1099, 200000, 0, 200000, 'paid', 'seepay', DATEADD(MINUTE, 11, DATEADD(HOUR, 16, DATEADD(DAY, -10, GETDATE()))), N'Đỗ Linh', 'mega_req_439@gmail.com', '0923598285', DATEADD(MINUTE, 47, DATEADD(HOUR, 22, DATEADD(DAY, -38, GETDATE()))), 200000),
(1440, 'ORD-MEGA-0440', 1064, 1054, 600000, 0, 600000, 'pending', 'seepay', NULL, N'Đặng Anh', 'mega_req_440@gmail.com', '0992553953', DATEADD(MINUTE, 26, DATEADD(HOUR, 8, DATEADD(DAY, -16, GETDATE()))), 600000),
(1441, 'ORD-MEGA-0441', 1031, 1065, 200000, 0, 200000, 'refunded', 'seepay', DATEADD(MINUTE, 21, DATEADD(HOUR, 13, DATEADD(DAY, -25, GETDATE()))), N'Đỗ Phong', 'mega_req_441@gmail.com', '0998753552', DATEADD(MINUTE, 57, DATEADD(HOUR, 16, DATEADD(DAY, -7, GETDATE()))), 200000),
(1442, 'ORD-MEGA-0442', 1036, 1004, 500000, 0, 500000, 'pending', 'seepay', NULL, N'Phạm Hải', 'mega_req_442@gmail.com', '0938528170', DATEADD(MINUTE, 21, DATEADD(HOUR, 21, DATEADD(DAY, -52, GETDATE()))), 500000),
(1443, 'ORD-MEGA-0443', 1076, 1007, 500000, 0, 500000, 'pending', 'seepay', NULL, N'Phạm Tâm', 'mega_req_443@gmail.com', '0947991860', DATEADD(MINUTE, 30, DATEADD(HOUR, 11, DATEADD(DAY, -45, GETDATE()))), 500000),
(1444, 'ORD-MEGA-0444', 1057, 1003, 450000, 0, 450000, 'cancelled', 'seepay', NULL, N'Lê Anh', 'mega_req_444@gmail.com', '0936948700', DATEADD(MINUTE, 51, DATEADD(HOUR, 8, DATEADD(DAY, -7, GETDATE()))), 450000),
(1445, 'ORD-MEGA-0445', 1072, 1081, 200000, 0, 200000, 'cancelled', 'seepay', NULL, N'Đỗ Phong', 'mega_req_445@gmail.com', '0926382616', DATEADD(MINUTE, 22, DATEADD(HOUR, 22, DATEADD(DAY, -46, GETDATE()))), 200000),
(1446, 'ORD-MEGA-0446', 1004, 1003, 800000, 0, 800000, 'paid', 'seepay', DATEADD(MINUTE, 57, DATEADD(HOUR, 12, DATEADD(DAY, -4, GETDATE()))), N'Nguyễn Vân', 'mega_req_446@gmail.com', '0989671135', DATEADD(MINUTE, 37, DATEADD(HOUR, 10, DATEADD(DAY, -35, GETDATE()))), 800000),
(1447, 'ORD-MEGA-0447', 1048, 1023, 500000, 0, 500000, 'paid', 'seepay', DATEADD(MINUTE, 59, DATEADD(HOUR, 6, DATEADD(DAY, -27, GETDATE()))), N'Vũ Tâm', 'mega_req_447@gmail.com', '0968075648', DATEADD(MINUTE, 22, DATEADD(HOUR, 21, DATEADD(DAY, -48, GETDATE()))), 500000),
(1448, 'ORD-MEGA-0448', 1092, 1029, 1500000, 0, 1500000, 'paid', 'seepay', DATEADD(MINUTE, 39, DATEADD(HOUR, 15, DATEADD(DAY, -51, GETDATE()))), N'Phạm Linh', 'mega_req_448@gmail.com', '0913854157', DATEADD(MINUTE, 29, DATEADD(HOUR, 1, DATEADD(DAY, -54, GETDATE()))), 1500000),
(1449, 'ORD-MEGA-0449', 1077, 1007, 600000, 0, 600000, 'refunded', 'seepay', DATEADD(MINUTE, 54, DATEADD(HOUR, 12, DATEADD(DAY, 0, GETDATE()))), N'Đỗ Phong', 'mega_req_449@gmail.com', '0960900829', DATEADD(MINUTE, 9, DATEADD(HOUR, 9, DATEADD(DAY, -50, GETDATE()))), 600000),
(1450, 'ORD-MEGA-0450', 1029, 1009, 1000000, 0, 1000000, 'cancelled', 'seepay', NULL, N'Hoàng Vân', 'mega_req_450@gmail.com', '0985621186', DATEADD(MINUTE, 41, DATEADD(HOUR, 16, DATEADD(DAY, -19, GETDATE()))), 1000000),
(1451, 'ORD-MEGA-0451', 1091, 1042, 800000, 0, 800000, 'refunded', 'seepay', DATEADD(MINUTE, 49, DATEADD(HOUR, 1, DATEADD(DAY, -3, GETDATE()))), N'Nguyễn Kiên', 'mega_req_451@gmail.com', '0929224651', DATEADD(MINUTE, 35, DATEADD(HOUR, 14, DATEADD(DAY, -57, GETDATE()))), 800000),
(1452, 'ORD-MEGA-0452', 1077, 1076, 2000000, 0, 2000000, 'cancelled', 'seepay', NULL, N'Bùi Thành', 'mega_req_452@gmail.com', '0993601896', DATEADD(MINUTE, 41, DATEADD(HOUR, 10, DATEADD(DAY, -43, GETDATE()))), 2000000),
(1453, 'ORD-MEGA-0453', 1030, 1060, 150000, 0, 150000, 'paid', 'seepay', DATEADD(MINUTE, 48, DATEADD(HOUR, 12, DATEADD(DAY, -16, GETDATE()))), N'Lê Linh', 'mega_req_453@gmail.com', '0948037562', DATEADD(MINUTE, 3, DATEADD(HOUR, 5, DATEADD(DAY, -11, GETDATE()))), 150000),
(1454, 'ORD-MEGA-0454', 1060, 1058, 150000, 0, 150000, 'paid', 'seepay', DATEADD(MINUTE, 3, DATEADD(HOUR, 12, DATEADD(DAY, -9, GETDATE()))), N'Vũ Phong', 'mega_req_454@gmail.com', '0962376249', DATEADD(MINUTE, 46, DATEADD(HOUR, 14, DATEADD(DAY, -10, GETDATE()))), 150000),
(1455, 'ORD-MEGA-0455', 1066, 1020, 1500000, 0, 1500000, 'refunded', 'seepay', DATEADD(MINUTE, 57, DATEADD(HOUR, 20, DATEADD(DAY, -10, GETDATE()))), N'Vũ Khoa', 'mega_req_455@gmail.com', '0969515436', DATEADD(MINUTE, 16, DATEADD(HOUR, 6, DATEADD(DAY, -42, GETDATE()))), 1500000),
(1456, 'ORD-MEGA-0456', 1075, 1038, 400000, 0, 400000, 'paid', 'seepay', DATEADD(MINUTE, 17, DATEADD(HOUR, 20, DATEADD(DAY, -46, GETDATE()))), N'Trần Tâm', 'mega_req_456@gmail.com', '0985643664', DATEADD(MINUTE, 57, DATEADD(HOUR, 13, DATEADD(DAY, -56, GETDATE()))), 400000),
(1457, 'ORD-MEGA-0457', 1057, 1062, 2000000, 0, 2000000, 'paid', 'seepay', DATEADD(MINUTE, 28, DATEADD(HOUR, 0, DATEADD(DAY, -37, GETDATE()))), N'Hoàng Minh', 'mega_req_457@gmail.com', '0930902027', DATEADD(MINUTE, 16, DATEADD(HOUR, 11, DATEADD(DAY, -37, GETDATE()))), 2000000),
(1458, 'ORD-MEGA-0458', 1063, 1058, 200000, 0, 200000, 'pending', 'seepay', NULL, N'Bùi Anh', 'mega_req_458@gmail.com', '0948863147', DATEADD(MINUTE, 23, DATEADD(HOUR, 8, DATEADD(DAY, -59, GETDATE()))), 200000),
(1459, 'ORD-MEGA-0459', 1094, 1019, 450000, 0, 450000, 'cancelled', 'seepay', NULL, N'Hoàng Khoa', 'mega_req_459@gmail.com', '0982929057', DATEADD(MINUTE, 39, DATEADD(HOUR, 4, DATEADD(DAY, -1, GETDATE()))), 450000),
(1460, 'ORD-MEGA-0460', 1031, 1088, 400000, 0, 400000, 'paid', 'seepay', DATEADD(MINUTE, 28, DATEADD(HOUR, 12, DATEADD(DAY, -57, GETDATE()))), N'Huỳnh Bảo', 'mega_req_460@gmail.com', '0932068277', DATEADD(MINUTE, 20, DATEADD(HOUR, 6, DATEADD(DAY, -12, GETDATE()))), 400000),
(1461, 'ORD-MEGA-0461', 1033, 1007, 500000, 0, 500000, 'cancelled', 'seepay', NULL, N'Bùi Tâm', 'mega_req_461@gmail.com', '0992531057', DATEADD(MINUTE, 45, DATEADD(HOUR, 13, DATEADD(DAY, 0, GETDATE()))), 500000),
(1462, 'ORD-MEGA-0462', 1051, 1046, 2000000, 0, 2000000, 'refunded', 'seepay', DATEADD(MINUTE, 25, DATEADD(HOUR, 16, DATEADD(DAY, -60, GETDATE()))), N'Lê Minh', 'mega_req_462@gmail.com', '0944683146', DATEADD(MINUTE, 18, DATEADD(HOUR, 15, DATEADD(DAY, -60, GETDATE()))), 2000000),
(1463, 'ORD-MEGA-0463', 1013, 1094, 150000, 0, 150000, 'pending', 'seepay', NULL, N'Vũ Khoa', 'mega_req_463@gmail.com', '0968114439', DATEADD(MINUTE, 32, DATEADD(HOUR, 7, DATEADD(DAY, -57, GETDATE()))), 150000),
(1464, 'ORD-MEGA-0464', 1072, 1096, 800000, 0, 800000, 'refunded', 'seepay', DATEADD(MINUTE, 21, DATEADD(HOUR, 7, DATEADD(DAY, -32, GETDATE()))), N'Huỳnh Thu', 'mega_req_464@gmail.com', '0923441179', DATEADD(MINUTE, 33, DATEADD(HOUR, 9, DATEADD(DAY, -45, GETDATE()))), 800000),
(1465, 'ORD-MEGA-0465', 1026, 1029, 400000, 0, 400000, 'paid', 'seepay', DATEADD(MINUTE, 14, DATEADD(HOUR, 20, DATEADD(DAY, -45, GETDATE()))), N'Trần Hải', 'mega_req_465@gmail.com', '0990880089', DATEADD(MINUTE, 18, DATEADD(HOUR, 20, DATEADD(DAY, -33, GETDATE()))), 400000),
(1466, 'ORD-MEGA-0466', 1048, 1093, 150000, 0, 150000, 'paid', 'seepay', DATEADD(MINUTE, 47, DATEADD(HOUR, 7, DATEADD(DAY, -27, GETDATE()))), N'Vũ Hùng', 'mega_req_466@gmail.com', '0952375235', DATEADD(MINUTE, 1, DATEADD(HOUR, 16, DATEADD(DAY, -54, GETDATE()))), 150000),
(1467, 'ORD-MEGA-0467', 1005, 1029, 200000, 0, 200000, 'paid', 'seepay', DATEADD(MINUTE, 53, DATEADD(HOUR, 4, DATEADD(DAY, -11, GETDATE()))), N'Phạm Thu', 'mega_req_467@gmail.com', '0929901782', DATEADD(MINUTE, 59, DATEADD(HOUR, 0, DATEADD(DAY, -5, GETDATE()))), 200000),
(1468, 'ORD-MEGA-0468', 1073, 1018, 600000, 0, 600000, 'refunded', 'seepay', DATEADD(MINUTE, 55, DATEADD(HOUR, 2, DATEADD(DAY, -23, GETDATE()))), N'Trần Thành', 'mega_req_468@gmail.com', '0994982532', DATEADD(MINUTE, 42, DATEADD(HOUR, 2, DATEADD(DAY, -43, GETDATE()))), 600000),
(1469, 'ORD-MEGA-0469', 1033, 1042, 400000, 0, 400000, 'cancelled', 'seepay', NULL, N'Huỳnh Kiên', 'mega_req_469@gmail.com', '0996015153', DATEADD(MINUTE, 43, DATEADD(HOUR, 21, DATEADD(DAY, -60, GETDATE()))), 400000),
(1470, 'ORD-MEGA-0470', 1096, 1093, 600000, 0, 600000, 'refunded', 'seepay', DATEADD(MINUTE, 40, DATEADD(HOUR, 3, DATEADD(DAY, -10, GETDATE()))), N'Lê Thu', 'mega_req_470@gmail.com', '0986630617', DATEADD(MINUTE, 26, DATEADD(HOUR, 2, DATEADD(DAY, -28, GETDATE()))), 600000),
(1471, 'ORD-MEGA-0471', 1096, 1010, 300000, 0, 300000, 'refunded', 'seepay', DATEADD(MINUTE, 6, DATEADD(HOUR, 17, DATEADD(DAY, -58, GETDATE()))), N'Nguyễn Khoa', 'mega_req_471@gmail.com', '0985657473', DATEADD(MINUTE, 52, DATEADD(HOUR, 10, DATEADD(DAY, -8, GETDATE()))), 300000),
(1472, 'ORD-MEGA-0472', 1024, 1074, 200000, 0, 200000, 'cancelled', 'seepay', NULL, N'Lê Linh', 'mega_req_472@gmail.com', '0974034479', DATEADD(MINUTE, 29, DATEADD(HOUR, 18, DATEADD(DAY, -8, GETDATE()))), 200000),
(1473, 'ORD-MEGA-0473', 1061, 1074, 400000, 0, 400000, 'pending', 'seepay', NULL, N'Nguyễn Trang', 'mega_req_473@gmail.com', '0941702847', DATEADD(MINUTE, 33, DATEADD(HOUR, 4, DATEADD(DAY, -38, GETDATE()))), 400000),
(1474, 'ORD-MEGA-0474', 1088, 1082, 500000, 0, 500000, 'paid', 'seepay', DATEADD(MINUTE, 23, DATEADD(HOUR, 14, DATEADD(DAY, -20, GETDATE()))), N'Hoàng Minh', 'mega_req_474@gmail.com', '0934834210', DATEADD(MINUTE, 19, DATEADD(HOUR, 21, DATEADD(DAY, -29, GETDATE()))), 500000),
(1475, 'ORD-MEGA-0475', 1056, 1016, 600000, 0, 600000, 'refunded', 'seepay', DATEADD(MINUTE, 11, DATEADD(HOUR, 11, DATEADD(DAY, -30, GETDATE()))), N'Hoàng Hùng', 'mega_req_475@gmail.com', '0990902707', DATEADD(MINUTE, 37, DATEADD(HOUR, 14, DATEADD(DAY, -10, GETDATE()))), 600000),
(1476, 'ORD-MEGA-0476', 1003, 1028, 300000, 0, 300000, 'paid', 'seepay', DATEADD(MINUTE, 24, DATEADD(HOUR, 12, DATEADD(DAY, 0, GETDATE()))), N'Vũ Hùng', 'mega_req_476@gmail.com', '0947473687', DATEADD(MINUTE, 58, DATEADD(HOUR, 5, DATEADD(DAY, -46, GETDATE()))), 300000),
(1477, 'ORD-MEGA-0477', 1099, 1061, 500000, 0, 500000, 'refunded', 'seepay', DATEADD(MINUTE, 38, DATEADD(HOUR, 21, DATEADD(DAY, -21, GETDATE()))), N'Lê Bảo', 'mega_req_477@gmail.com', '0918383888', DATEADD(MINUTE, 26, DATEADD(HOUR, 13, DATEADD(DAY, -3, GETDATE()))), 500000),
(1478, 'ORD-MEGA-0478', 1004, 1002, 2000000, 0, 2000000, 'paid', 'seepay', DATEADD(MINUTE, 25, DATEADD(HOUR, 19, DATEADD(DAY, -51, GETDATE()))), N'Trần Trang', 'mega_req_478@gmail.com', '0954645104', DATEADD(MINUTE, 20, DATEADD(HOUR, 21, DATEADD(DAY, -14, GETDATE()))), 2000000),
(1479, 'ORD-MEGA-0479', 1026, 1097, 800000, 0, 800000, 'paid', 'seepay', DATEADD(MINUTE, 39, DATEADD(HOUR, 14, DATEADD(DAY, -45, GETDATE()))), N'Phạm Thành', 'mega_req_479@gmail.com', '0997160182', DATEADD(MINUTE, 20, DATEADD(HOUR, 23, DATEADD(DAY, -56, GETDATE()))), 800000),
(1480, 'ORD-MEGA-0480', 1079, 1086, 2000000, 0, 2000000, 'refunded', 'seepay', DATEADD(MINUTE, 10, DATEADD(HOUR, 17, DATEADD(DAY, -58, GETDATE()))), N'Hoàng Hải', 'mega_req_480@gmail.com', '0987001682', DATEADD(MINUTE, 15, DATEADD(HOUR, 6, DATEADD(DAY, -32, GETDATE()))), 2000000),
(1481, 'ORD-MEGA-0481', 1050, 1051, 1000000, 0, 1000000, 'paid', 'seepay', DATEADD(MINUTE, 16, DATEADD(HOUR, 9, DATEADD(DAY, -36, GETDATE()))), N'Vũ Tâm', 'mega_req_481@gmail.com', '0996901805', DATEADD(MINUTE, 18, DATEADD(HOUR, 4, DATEADD(DAY, -45, GETDATE()))), 1000000),
(1482, 'ORD-MEGA-0482', 1050, 1098, 1000000, 0, 1000000, 'pending', 'seepay', NULL, N'Bùi Anh', 'mega_req_482@gmail.com', '0999493407', DATEADD(MINUTE, 57, DATEADD(HOUR, 17, DATEADD(DAY, -34, GETDATE()))), 1000000),
(1483, 'ORD-MEGA-0483', 1064, 1059, 200000, 0, 200000, 'paid', 'seepay', DATEADD(MINUTE, 34, DATEADD(HOUR, 9, DATEADD(DAY, -17, GETDATE()))), N'Hoàng Lan', 'mega_req_483@gmail.com', '0991823015', DATEADD(MINUTE, 11, DATEADD(HOUR, 14, DATEADD(DAY, -47, GETDATE()))), 200000),
(1484, 'ORD-MEGA-0484', 1033, 1093, 500000, 0, 500000, 'paid', 'seepay', DATEADD(MINUTE, 37, DATEADD(HOUR, 20, DATEADD(DAY, -32, GETDATE()))), N'Trần Minh', 'mega_req_484@gmail.com', '0928146318', DATEADD(MINUTE, 38, DATEADD(HOUR, 15, DATEADD(DAY, -50, GETDATE()))), 500000),
(1485, 'ORD-MEGA-0485', 1039, 1002, 200000, 0, 200000, 'paid', 'seepay', DATEADD(MINUTE, 53, DATEADD(HOUR, 1, DATEADD(DAY, -41, GETDATE()))), N'Đỗ Hùng', 'mega_req_485@gmail.com', '0958818233', DATEADD(MINUTE, 4, DATEADD(HOUR, 4, DATEADD(DAY, -2, GETDATE()))), 200000),
(1486, 'ORD-MEGA-0486', 1051, 1099, 450000, 0, 450000, 'pending', 'seepay', NULL, N'Trần Tâm', 'mega_req_486@gmail.com', '0986991090', DATEADD(MINUTE, 23, DATEADD(HOUR, 17, DATEADD(DAY, -7, GETDATE()))), 450000),
(1487, 'ORD-MEGA-0487', 1080, 1079, 600000, 0, 600000, 'paid', 'seepay', DATEADD(MINUTE, 53, DATEADD(HOUR, 22, DATEADD(DAY, -45, GETDATE()))), N'Nguyễn Hải', 'mega_req_487@gmail.com', '0943462042', DATEADD(MINUTE, 23, DATEADD(HOUR, 22, DATEADD(DAY, -57, GETDATE()))), 600000),
(1488, 'ORD-MEGA-0488', 1097, 1076, 600000, 0, 600000, 'pending', 'seepay', NULL, N'Vũ Trang', 'mega_req_488@gmail.com', '0935931137', DATEADD(MINUTE, 24, DATEADD(HOUR, 9, DATEADD(DAY, -35, GETDATE()))), 600000),
(1489, 'ORD-MEGA-0489', 1071, 1072, 200000, 0, 200000, 'refunded', 'seepay', DATEADD(MINUTE, 6, DATEADD(HOUR, 6, DATEADD(DAY, -40, GETDATE()))), N'Vũ Linh', 'mega_req_489@gmail.com', '0995918202', DATEADD(MINUTE, 11, DATEADD(HOUR, 13, DATEADD(DAY, -42, GETDATE()))), 200000),
(1490, 'ORD-MEGA-0490', 1049, 1040, 200000, 0, 200000, 'refunded', 'seepay', DATEADD(MINUTE, 11, DATEADD(HOUR, 11, DATEADD(DAY, -32, GETDATE()))), N'Đỗ Trang', 'mega_req_490@gmail.com', '0938445891', DATEADD(MINUTE, 49, DATEADD(HOUR, 7, DATEADD(DAY, -51, GETDATE()))), 200000),
(1491, 'ORD-MEGA-0491', 1061, 1003, 2000000, 0, 2000000, 'cancelled', 'seepay', NULL, N'Đỗ Lan', 'mega_req_491@gmail.com', '0993583826', DATEADD(MINUTE, 58, DATEADD(HOUR, 20, DATEADD(DAY, -31, GETDATE()))), 2000000),
(1492, 'ORD-MEGA-0492', 1079, 1028, 600000, 0, 600000, 'paid', 'seepay', DATEADD(MINUTE, 47, DATEADD(HOUR, 18, DATEADD(DAY, -57, GETDATE()))), N'Huỳnh Bảo', 'mega_req_492@gmail.com', '0981034879', DATEADD(MINUTE, 39, DATEADD(HOUR, 4, DATEADD(DAY, -18, GETDATE()))), 600000),
(1493, 'ORD-MEGA-0493', 1051, 1046, 300000, 0, 300000, 'cancelled', 'seepay', NULL, N'Trần Lan', 'mega_req_493@gmail.com', '0969656658', DATEADD(MINUTE, 47, DATEADD(HOUR, 19, DATEADD(DAY, -51, GETDATE()))), 300000),
(1494, 'ORD-MEGA-0494', 1012, 1002, 400000, 0, 400000, 'paid', 'seepay', DATEADD(MINUTE, 15, DATEADD(HOUR, 11, DATEADD(DAY, -17, GETDATE()))), N'Vũ Thu', 'mega_req_494@gmail.com', '0995456204', DATEADD(MINUTE, 14, DATEADD(HOUR, 12, DATEADD(DAY, -49, GETDATE()))), 400000),
(1495, 'ORD-MEGA-0495', 1080, 1001, 200000, 0, 200000, 'refunded', 'seepay', DATEADD(MINUTE, 6, DATEADD(HOUR, 17, DATEADD(DAY, -10, GETDATE()))), N'Phạm Trang', 'mega_req_495@gmail.com', '0910458228', DATEADD(MINUTE, 30, DATEADD(HOUR, 16, DATEADD(DAY, -34, GETDATE()))), 200000),
(1496, 'ORD-MEGA-0496', 1091, 1010, 150000, 0, 150000, 'paid', 'seepay', DATEADD(MINUTE, 57, DATEADD(HOUR, 20, DATEADD(DAY, -30, GETDATE()))), N'Nguyễn Bảo', 'mega_req_496@gmail.com', '0961569868', DATEADD(MINUTE, 5, DATEADD(HOUR, 2, DATEADD(DAY, -25, GETDATE()))), 150000),
(1497, 'ORD-MEGA-0497', 1014, 1015, 2000000, 0, 2000000, 'refunded', 'seepay', DATEADD(MINUTE, 24, DATEADD(HOUR, 15, DATEADD(DAY, -41, GETDATE()))), N'Nguyễn Trang', 'mega_req_497@gmail.com', '0958173081', DATEADD(MINUTE, 54, DATEADD(HOUR, 3, DATEADD(DAY, -59, GETDATE()))), 2000000),
(1498, 'ORD-MEGA-0498', 1029, 1010, 150000, 0, 150000, 'paid', 'seepay', DATEADD(MINUTE, 50, DATEADD(HOUR, 18, DATEADD(DAY, -29, GETDATE()))), N'Phạm Phong', 'mega_req_498@gmail.com', '0979559371', DATEADD(MINUTE, 45, DATEADD(HOUR, 8, DATEADD(DAY, -1, GETDATE()))), 150000),
(1499, 'ORD-MEGA-0499', 1011, 1030, 2000000, 0, 2000000, 'cancelled', 'seepay', NULL, N'Nguyễn Kiên', 'mega_req_499@gmail.com', '0913118851', DATEADD(MINUTE, 5, DATEADD(HOUR, 1, DATEADD(DAY, -20, GETDATE()))), 2000000);
SET IDENTITY_INSERT Orders OFF;
GO
SET IDENTITY_INSERT OrderItems ON;
INSERT INTO OrderItems (order_item_id, order_id, ticket_type_id, quantity, unit_price, subtotal) VALUES
(1000, 1000, 1043, 2, 500000, 1000000),
(1001, 1001, 1156, 4, 200000, 800000),
(1002, 1002, 1196, 1, 500000, 500000),
(1003, 1003, 1035, 3, 150000, 450000),
(1004, 1004, 1210, 4, 200000, 800000),
(1005, 1005, 1166, 3, 500000, 1500000),
(1006, 1006, 1083, 1, 150000, 150000),
(1007, 1007, 1146, 1, 150000, 150000),
(1008, 1008, 1213, 4, 200000, 800000),
(1009, 1009, 1072, 4, 200000, 800000),
(1010, 1010, 1034, 2, 500000, 1000000),
(1011, 1011, 1155, 3, 150000, 450000),
(1012, 1012, 1250, 4, 500000, 2000000),
(1013, 1013, 1070, 4, 500000, 2000000),
(1014, 1014, 1015, 2, 200000, 400000),
(1015, 1015, 1100, 1, 500000, 500000),
(1016, 1016, 1068, 2, 150000, 300000),
(1017, 1017, 1116, 1, 150000, 150000),
(1018, 1018, 1055, 3, 500000, 1500000),
(1019, 1019, 1081, 1, 200000, 200000),
(1020, 1020, 1201, 1, 200000, 200000),
(1021, 1021, 1057, 3, 200000, 600000),
(1022, 1022, 1088, 2, 500000, 1000000),
(1023, 1023, 1151, 3, 500000, 1500000),
(1024, 1024, 1012, 1, 200000, 200000),
(1025, 1025, 1020, 3, 150000, 450000),
(1026, 1026, 1085, 2, 500000, 1000000),
(1027, 1027, 1164, 1, 150000, 150000),
(1028, 1028, 1050, 1, 150000, 150000),
(1029, 1029, 1289, 3, 500000, 1500000),
(1030, 1030, 1147, 1, 200000, 200000),
(1031, 1031, 1137, 3, 150000, 450000),
(1032, 1032, 1031, 1, 500000, 500000),
(1033, 1033, 1005, 3, 150000, 450000),
(1034, 1034, 1065, 2, 150000, 300000),
(1035, 1035, 1027, 4, 200000, 800000),
(1036, 1036, 1033, 4, 200000, 800000),
(1037, 1037, 1038, 3, 150000, 450000),
(1038, 1038, 1024, 1, 200000, 200000),
(1039, 1039, 1042, 3, 200000, 600000),
(1040, 1040, 1056, 3, 150000, 450000),
(1041, 1041, 1008, 3, 150000, 450000),
(1042, 1042, 1238, 4, 500000, 2000000),
(1043, 1043, 1116, 2, 150000, 300000),
(1044, 1044, 1085, 3, 500000, 1500000),
(1045, 1045, 1018, 2, 200000, 400000),
(1046, 1046, 1090, 1, 200000, 200000),
(1047, 1047, 1248, 4, 150000, 600000),
(1048, 1048, 1134, 2, 150000, 300000),
(1049, 1049, 1027, 3, 200000, 600000),
(1050, 1050, 1102, 3, 200000, 600000),
(1051, 1051, 1018, 4, 200000, 800000),
(1052, 1052, 1139, 3, 500000, 1500000),
(1053, 1053, 1147, 1, 200000, 200000),
(1054, 1054, 1112, 3, 500000, 1500000),
(1055, 1055, 1069, 1, 200000, 200000),
(1056, 1056, 1199, 1, 500000, 500000),
(1057, 1057, 1035, 1, 150000, 150000),
(1058, 1058, 1239, 2, 150000, 300000),
(1059, 1059, 1034, 3, 500000, 1500000),
(1060, 1060, 1204, 3, 200000, 600000),
(1061, 1061, 1102, 4, 200000, 800000),
(1062, 1062, 1171, 3, 200000, 600000),
(1063, 1063, 1254, 4, 150000, 600000),
(1064, 1064, 1154, 4, 500000, 2000000),
(1065, 1065, 1112, 3, 500000, 1500000),
(1066, 1066, 1221, 3, 150000, 450000),
(1067, 1067, 1045, 4, 200000, 800000),
(1068, 1068, 1118, 2, 500000, 1000000),
(1069, 1069, 1221, 4, 150000, 600000),
(1070, 1070, 1238, 1, 500000, 500000),
(1071, 1071, 1199, 2, 500000, 1000000),
(1072, 1072, 1022, 1, 500000, 500000),
(1073, 1073, 1125, 4, 150000, 600000),
(1074, 1074, 1276, 2, 200000, 400000),
(1075, 1075, 1075, 2, 200000, 400000),
(1076, 1076, 1263, 2, 150000, 300000),
(1077, 1077, 1288, 2, 200000, 400000),
(1078, 1078, 1135, 1, 200000, 200000),
(1079, 1079, 1048, 2, 200000, 400000),
(1080, 1080, 1008, 4, 150000, 600000),
(1081, 1081, 1247, 1, 500000, 500000),
(1082, 1082, 1142, 1, 500000, 500000),
(1083, 1083, 1121, 4, 500000, 2000000),
(1084, 1084, 1284, 1, 150000, 150000),
(1085, 1085, 1245, 4, 150000, 600000),
(1086, 1086, 1173, 1, 150000, 150000),
(1087, 1087, 1247, 4, 500000, 2000000),
(1088, 1088, 1238, 1, 500000, 500000),
(1089, 1089, 1109, 1, 500000, 500000),
(1090, 1090, 1013, 2, 500000, 1000000),
(1091, 1091, 1161, 3, 150000, 450000),
(1092, 1092, 1181, 1, 500000, 500000),
(1093, 1093, 1019, 4, 500000, 2000000),
(1094, 1094, 1177, 3, 200000, 600000),
(1095, 1095, 1123, 3, 200000, 600000),
(1096, 1096, 1255, 1, 200000, 200000),
(1097, 1097, 1250, 1, 500000, 500000),
(1098, 1098, 1107, 4, 150000, 600000),
(1099, 1099, 1170, 2, 150000, 300000);
INSERT INTO OrderItems (order_item_id, order_id, ticket_type_id, quantity, unit_price, subtotal) VALUES
(1100, 1100, 1279, 2, 200000, 400000),
(1101, 1101, 1141, 3, 200000, 600000),
(1102, 1102, 1028, 4, 500000, 2000000),
(1103, 1103, 1129, 1, 200000, 200000),
(1104, 1104, 1053, 2, 150000, 300000),
(1105, 1105, 1181, 2, 500000, 1000000),
(1106, 1106, 1185, 3, 150000, 450000),
(1107, 1107, 1056, 2, 150000, 300000),
(1108, 1108, 1095, 2, 150000, 300000),
(1109, 1109, 1211, 1, 500000, 500000),
(1110, 1110, 1231, 1, 200000, 200000),
(1111, 1111, 1009, 1, 200000, 200000),
(1112, 1112, 1117, 3, 200000, 600000),
(1113, 1113, 1247, 4, 500000, 2000000),
(1114, 1114, 1077, 1, 150000, 150000),
(1115, 1115, 1095, 4, 150000, 600000),
(1116, 1116, 1218, 4, 150000, 600000),
(1117, 1117, 1184, 1, 500000, 500000),
(1118, 1118, 1127, 2, 500000, 1000000),
(1119, 1119, 1295, 3, 500000, 1500000),
(1120, 1120, 1151, 4, 500000, 2000000),
(1121, 1121, 1182, 1, 150000, 150000),
(1122, 1122, 1244, 3, 500000, 1500000),
(1123, 1123, 1218, 1, 150000, 150000),
(1124, 1124, 1018, 1, 200000, 200000),
(1125, 1125, 1037, 3, 500000, 1500000),
(1126, 1126, 1272, 3, 150000, 450000),
(1127, 1127, 1137, 4, 150000, 600000),
(1128, 1128, 1134, 1, 150000, 150000),
(1129, 1129, 1287, 2, 150000, 300000),
(1130, 1130, 1116, 1, 150000, 150000),
(1131, 1131, 1085, 4, 500000, 2000000),
(1132, 1132, 1023, 4, 150000, 600000),
(1133, 1133, 1062, 4, 150000, 600000),
(1134, 1134, 1156, 1, 200000, 200000),
(1135, 1135, 1020, 3, 150000, 450000),
(1136, 1136, 1145, 1, 500000, 500000),
(1137, 1137, 1136, 2, 500000, 1000000),
(1138, 1138, 1246, 4, 200000, 800000),
(1139, 1139, 1229, 1, 500000, 500000),
(1140, 1140, 1197, 4, 150000, 600000),
(1141, 1141, 1036, 3, 200000, 600000),
(1142, 1142, 1220, 4, 500000, 2000000),
(1143, 1143, 1007, 3, 500000, 1500000),
(1144, 1144, 1120, 3, 200000, 600000),
(1145, 1145, 1277, 1, 500000, 500000),
(1146, 1146, 1222, 4, 200000, 800000),
(1147, 1147, 1226, 1, 500000, 500000),
(1148, 1148, 1128, 1, 150000, 150000),
(1149, 1149, 1171, 3, 200000, 600000),
(1150, 1150, 1032, 2, 150000, 300000),
(1151, 1151, 1212, 3, 150000, 450000),
(1152, 1152, 1091, 2, 500000, 1000000),
(1153, 1153, 1296, 4, 150000, 600000),
(1154, 1154, 1289, 2, 500000, 1000000),
(1155, 1155, 1237, 1, 200000, 200000),
(1156, 1156, 1160, 3, 500000, 1500000),
(1157, 1157, 1290, 2, 150000, 300000),
(1158, 1158, 1031, 4, 500000, 2000000),
(1159, 1159, 1144, 2, 200000, 400000),
(1160, 1160, 1043, 2, 500000, 1000000),
(1161, 1161, 1043, 4, 500000, 2000000),
(1162, 1162, 1229, 4, 500000, 2000000),
(1163, 1163, 1155, 1, 150000, 150000),
(1164, 1164, 1008, 2, 150000, 300000),
(1165, 1165, 1039, 3, 200000, 600000),
(1166, 1166, 1267, 4, 200000, 800000),
(1167, 1167, 1130, 3, 500000, 1500000),
(1168, 1168, 1272, 1, 150000, 150000),
(1169, 1169, 1243, 1, 200000, 200000),
(1170, 1170, 1274, 1, 500000, 500000),
(1171, 1171, 1085, 2, 500000, 1000000),
(1172, 1172, 1162, 1, 200000, 200000),
(1173, 1173, 1159, 2, 200000, 400000),
(1174, 1174, 1062, 2, 150000, 300000),
(1175, 1175, 1049, 3, 500000, 1500000),
(1176, 1176, 1248, 2, 150000, 300000),
(1177, 1177, 1076, 3, 500000, 1500000),
(1178, 1178, 1059, 2, 150000, 300000),
(1179, 1179, 1139, 4, 500000, 2000000),
(1180, 1180, 1199, 2, 500000, 1000000),
(1181, 1181, 1177, 1, 200000, 200000),
(1182, 1182, 1101, 2, 150000, 300000),
(1183, 1183, 1295, 2, 500000, 1000000),
(1184, 1184, 1271, 1, 500000, 500000),
(1185, 1185, 1174, 1, 200000, 200000),
(1186, 1186, 1043, 4, 500000, 2000000),
(1187, 1187, 1074, 1, 150000, 150000),
(1188, 1188, 1101, 3, 150000, 450000),
(1189, 1189, 1067, 4, 500000, 2000000),
(1190, 1190, 1180, 1, 200000, 200000),
(1191, 1191, 1243, 2, 200000, 400000),
(1192, 1192, 1234, 2, 200000, 400000),
(1193, 1193, 1110, 4, 150000, 600000),
(1194, 1194, 1290, 4, 150000, 600000),
(1195, 1195, 1156, 4, 200000, 800000),
(1196, 1196, 1278, 2, 150000, 300000),
(1197, 1197, 1097, 2, 500000, 1000000),
(1198, 1198, 1101, 1, 150000, 150000),
(1199, 1199, 1006, 4, 200000, 800000);
INSERT INTO OrderItems (order_item_id, order_id, ticket_type_id, quantity, unit_price, subtotal) VALUES
(1200, 1200, 1018, 1, 200000, 200000),
(1201, 1201, 1190, 3, 500000, 1500000),
(1202, 1202, 1100, 4, 500000, 2000000),
(1203, 1203, 1285, 2, 200000, 400000),
(1204, 1204, 1275, 3, 150000, 450000),
(1205, 1205, 1031, 3, 500000, 1500000),
(1206, 1206, 1053, 1, 150000, 150000),
(1207, 1207, 1024, 4, 200000, 800000),
(1208, 1208, 1068, 4, 150000, 600000),
(1209, 1209, 1108, 1, 200000, 200000),
(1210, 1210, 1260, 1, 150000, 150000),
(1211, 1211, 1163, 1, 500000, 500000),
(1212, 1212, 1210, 2, 200000, 400000),
(1213, 1213, 1236, 1, 150000, 150000),
(1214, 1214, 1054, 1, 200000, 200000),
(1215, 1215, 1236, 4, 150000, 600000),
(1216, 1216, 1074, 1, 150000, 150000),
(1217, 1217, 1251, 3, 150000, 450000),
(1218, 1218, 1134, 4, 150000, 600000),
(1219, 1219, 1272, 1, 150000, 150000),
(1220, 1220, 1293, 1, 150000, 150000),
(1221, 1221, 1258, 4, 200000, 800000),
(1222, 1222, 1253, 3, 500000, 1500000),
(1223, 1223, 1190, 1, 500000, 500000),
(1224, 1224, 1135, 3, 200000, 600000),
(1225, 1225, 1151, 1, 500000, 500000),
(1226, 1226, 1053, 3, 150000, 450000),
(1227, 1227, 1034, 3, 500000, 1500000),
(1228, 1228, 1270, 1, 200000, 200000),
(1229, 1229, 1079, 2, 500000, 1000000),
(1230, 1230, 1112, 3, 500000, 1500000),
(1231, 1231, 1224, 2, 150000, 300000),
(1232, 1232, 1163, 2, 500000, 1000000),
(1233, 1233, 1189, 3, 200000, 600000),
(1234, 1234, 1221, 4, 150000, 600000),
(1235, 1235, 1134, 3, 150000, 450000),
(1236, 1236, 1104, 3, 150000, 450000),
(1237, 1237, 1230, 3, 150000, 450000),
(1238, 1238, 1035, 4, 150000, 600000),
(1239, 1239, 1042, 3, 200000, 600000),
(1240, 1240, 1035, 3, 150000, 450000),
(1241, 1241, 1230, 4, 150000, 600000),
(1242, 1242, 1065, 3, 150000, 450000),
(1243, 1243, 1136, 2, 500000, 1000000),
(1244, 1244, 1159, 3, 200000, 600000),
(1245, 1245, 1079, 2, 500000, 1000000),
(1246, 1246, 1118, 2, 500000, 1000000),
(1247, 1247, 1180, 3, 200000, 600000),
(1248, 1248, 1227, 3, 150000, 450000),
(1249, 1249, 1171, 3, 200000, 600000),
(1250, 1250, 1160, 1, 500000, 500000),
(1251, 1251, 1060, 2, 200000, 400000),
(1252, 1252, 1096, 3, 200000, 600000),
(1253, 1253, 1066, 1, 200000, 200000),
(1254, 1254, 1233, 1, 150000, 150000),
(1255, 1255, 1190, 4, 500000, 2000000),
(1256, 1256, 1125, 4, 150000, 600000),
(1257, 1257, 1253, 3, 500000, 1500000),
(1258, 1258, 1001, 2, 500000, 1000000),
(1259, 1259, 1229, 3, 500000, 1500000),
(1260, 1260, 1008, 1, 150000, 150000),
(1261, 1261, 1035, 4, 150000, 600000),
(1262, 1262, 1185, 2, 150000, 300000),
(1263, 1263, 1029, 3, 150000, 450000),
(1264, 1264, 1249, 1, 200000, 200000),
(1265, 1265, 1268, 1, 500000, 500000),
(1266, 1266, 1041, 4, 150000, 600000),
(1267, 1267, 1252, 4, 200000, 800000),
(1268, 1268, 1078, 3, 200000, 600000),
(1269, 1269, 1256, 3, 500000, 1500000),
(1270, 1270, 1175, 2, 500000, 1000000),
(1271, 1271, 1289, 2, 500000, 1000000),
(1272, 1272, 1294, 1, 200000, 200000),
(1273, 1273, 1243, 4, 200000, 800000),
(1274, 1274, 1104, 2, 150000, 300000),
(1275, 1275, 1153, 2, 200000, 400000),
(1276, 1276, 1047, 4, 150000, 600000),
(1277, 1277, 1008, 2, 150000, 300000),
(1278, 1278, 1043, 2, 500000, 1000000),
(1279, 1279, 1258, 4, 200000, 800000),
(1280, 1280, 1236, 3, 150000, 450000),
(1281, 1281, 1209, 2, 150000, 300000),
(1282, 1282, 1123, 4, 200000, 800000),
(1283, 1283, 1161, 3, 150000, 450000),
(1284, 1284, 1158, 3, 150000, 450000),
(1285, 1285, 1215, 4, 150000, 600000),
(1286, 1286, 1269, 2, 150000, 300000),
(1287, 1287, 1278, 4, 150000, 600000),
(1288, 1288, 1275, 3, 150000, 450000),
(1289, 1289, 1178, 1, 500000, 500000),
(1290, 1290, 1158, 3, 150000, 450000),
(1291, 1291, 1094, 4, 500000, 2000000),
(1292, 1292, 1026, 2, 150000, 300000),
(1293, 1293, 1004, 2, 500000, 1000000),
(1294, 1294, 1014, 1, 150000, 150000),
(1295, 1295, 1192, 4, 200000, 800000),
(1296, 1296, 1146, 2, 150000, 300000),
(1297, 1297, 1160, 2, 500000, 1000000),
(1298, 1298, 1091, 2, 500000, 1000000),
(1299, 1299, 1284, 2, 150000, 300000);
INSERT INTO OrderItems (order_item_id, order_id, ticket_type_id, quantity, unit_price, subtotal) VALUES
(1300, 1300, 1093, 2, 200000, 400000),
(1301, 1301, 1106, 4, 500000, 2000000),
(1302, 1302, 1047, 1, 150000, 150000),
(1303, 1303, 1132, 3, 200000, 600000),
(1304, 1304, 1266, 4, 150000, 600000),
(1305, 1305, 1177, 2, 200000, 400000),
(1306, 1306, 1025, 4, 500000, 2000000),
(1307, 1307, 1141, 2, 200000, 400000),
(1308, 1308, 1022, 3, 500000, 1500000),
(1309, 1309, 1023, 2, 150000, 300000),
(1310, 1310, 1194, 4, 150000, 600000),
(1311, 1311, 1013, 4, 500000, 2000000),
(1312, 1312, 1012, 1, 200000, 200000),
(1313, 1313, 1062, 1, 150000, 150000),
(1314, 1314, 1103, 3, 500000, 1500000),
(1315, 1315, 1238, 3, 500000, 1500000),
(1316, 1316, 1260, 2, 150000, 300000),
(1317, 1317, 1130, 4, 500000, 2000000),
(1318, 1318, 1169, 3, 500000, 1500000),
(1319, 1319, 1195, 2, 200000, 400000),
(1320, 1320, 1203, 4, 150000, 600000),
(1321, 1321, 1035, 1, 150000, 150000),
(1322, 1322, 1242, 3, 150000, 450000),
(1323, 1323, 1043, 3, 500000, 1500000),
(1324, 1324, 1180, 2, 200000, 400000),
(1325, 1325, 1038, 4, 150000, 600000),
(1326, 1326, 1077, 3, 150000, 450000),
(1327, 1327, 1221, 2, 150000, 300000),
(1328, 1328, 1100, 2, 500000, 1000000),
(1329, 1329, 1185, 3, 150000, 450000),
(1330, 1330, 1219, 4, 200000, 800000),
(1331, 1331, 1060, 3, 200000, 600000),
(1332, 1332, 1240, 4, 200000, 800000),
(1333, 1333, 1092, 3, 150000, 450000),
(1334, 1334, 1243, 2, 200000, 400000),
(1335, 1335, 1057, 2, 200000, 400000),
(1336, 1336, 1295, 3, 500000, 1500000),
(1337, 1337, 1125, 3, 150000, 450000),
(1338, 1338, 1267, 1, 200000, 200000),
(1339, 1339, 1128, 3, 150000, 450000),
(1340, 1340, 1225, 3, 200000, 600000),
(1341, 1341, 1048, 1, 200000, 200000),
(1342, 1342, 1230, 2, 150000, 300000),
(1343, 1343, 1114, 3, 200000, 600000),
(1344, 1344, 1013, 4, 500000, 2000000),
(1345, 1345, 1136, 4, 500000, 2000000),
(1346, 1346, 1170, 3, 150000, 450000),
(1347, 1347, 1139, 4, 500000, 2000000),
(1348, 1348, 1179, 2, 150000, 300000),
(1349, 1349, 1123, 2, 200000, 400000),
(1350, 1350, 1099, 3, 200000, 600000),
(1351, 1351, 1296, 1, 150000, 150000),
(1352, 1352, 1002, 3, 150000, 450000),
(1353, 1353, 1123, 3, 200000, 600000),
(1354, 1354, 1054, 3, 200000, 600000),
(1355, 1355, 1033, 3, 200000, 600000),
(1356, 1356, 1211, 3, 500000, 1500000),
(1357, 1357, 1093, 4, 200000, 800000),
(1358, 1358, 1010, 1, 500000, 500000),
(1359, 1359, 1164, 3, 150000, 450000),
(1360, 1360, 1112, 1, 500000, 500000),
(1361, 1361, 1087, 4, 200000, 800000),
(1362, 1362, 1171, 4, 200000, 800000),
(1363, 1363, 1253, 2, 500000, 1000000),
(1364, 1364, 1162, 4, 200000, 800000),
(1365, 1365, 1198, 2, 200000, 400000),
(1366, 1366, 1279, 3, 200000, 600000),
(1367, 1367, 1267, 3, 200000, 600000),
(1368, 1368, 1001, 3, 500000, 1500000),
(1369, 1369, 1009, 3, 200000, 600000),
(1370, 1370, 1165, 4, 200000, 800000),
(1371, 1371, 1224, 1, 150000, 150000),
(1372, 1372, 1154, 2, 500000, 1000000),
(1373, 1373, 1022, 1, 500000, 500000),
(1374, 1374, 1132, 3, 200000, 600000),
(1375, 1375, 1042, 1, 200000, 200000),
(1376, 1376, 1040, 3, 500000, 1500000),
(1377, 1377, 1003, 1, 200000, 200000),
(1378, 1378, 1118, 2, 500000, 1000000),
(1379, 1379, 1244, 2, 500000, 1000000),
(1380, 1380, 1222, 2, 200000, 400000),
(1381, 1381, 1109, 4, 500000, 2000000),
(1382, 1382, 1019, 3, 500000, 1500000),
(1383, 1383, 1078, 3, 200000, 600000),
(1384, 1384, 1294, 4, 200000, 800000),
(1385, 1385, 1014, 3, 150000, 450000),
(1386, 1386, 1119, 2, 150000, 300000),
(1387, 1387, 1263, 3, 150000, 450000),
(1388, 1388, 1114, 4, 200000, 800000),
(1389, 1389, 1116, 2, 150000, 300000),
(1390, 1390, 1180, 1, 200000, 200000),
(1391, 1391, 1179, 1, 150000, 150000),
(1392, 1392, 1185, 1, 150000, 150000),
(1393, 1393, 1284, 4, 150000, 600000),
(1394, 1394, 1239, 3, 150000, 450000),
(1395, 1395, 1039, 4, 200000, 800000),
(1396, 1396, 1031, 1, 500000, 500000),
(1397, 1397, 1003, 1, 200000, 200000),
(1398, 1398, 1239, 3, 150000, 450000),
(1399, 1399, 1096, 3, 200000, 600000);
INSERT INTO OrderItems (order_item_id, order_id, ticket_type_id, quantity, unit_price, subtotal) VALUES
(1400, 1400, 1263, 2, 150000, 300000),
(1401, 1401, 1234, 4, 200000, 800000),
(1402, 1402, 1286, 1, 500000, 500000),
(1403, 1403, 1192, 1, 200000, 200000),
(1404, 1404, 1129, 3, 200000, 600000),
(1405, 1405, 1020, 3, 150000, 450000),
(1406, 1406, 1062, 4, 150000, 600000),
(1407, 1407, 1238, 3, 500000, 1500000),
(1408, 1408, 1179, 1, 150000, 150000),
(1409, 1409, 1071, 4, 150000, 600000),
(1410, 1410, 1296, 1, 150000, 150000),
(1411, 1411, 1242, 1, 150000, 150000),
(1412, 1412, 1115, 1, 500000, 500000),
(1413, 1413, 1061, 3, 500000, 1500000),
(1414, 1414, 1083, 1, 150000, 150000),
(1415, 1415, 1241, 1, 500000, 500000),
(1416, 1416, 1024, 4, 200000, 800000),
(1417, 1417, 1295, 3, 500000, 1500000),
(1418, 1418, 1222, 2, 200000, 400000),
(1419, 1419, 1247, 2, 500000, 1000000),
(1420, 1420, 1227, 3, 150000, 450000),
(1421, 1421, 1174, 1, 200000, 200000),
(1422, 1422, 1264, 2, 200000, 400000),
(1423, 1423, 1158, 2, 150000, 300000),
(1424, 1424, 1157, 2, 500000, 1000000),
(1425, 1425, 1090, 4, 200000, 800000),
(1426, 1426, 1189, 3, 200000, 600000),
(1427, 1427, 1281, 3, 150000, 450000),
(1428, 1428, 1287, 4, 150000, 600000),
(1429, 1429, 1284, 2, 150000, 300000),
(1430, 1430, 1029, 1, 150000, 150000),
(1431, 1431, 1115, 1, 500000, 500000),
(1432, 1432, 1183, 3, 200000, 600000),
(1433, 1433, 1253, 1, 500000, 500000),
(1434, 1434, 1088, 3, 500000, 1500000),
(1435, 1435, 1077, 4, 150000, 600000),
(1436, 1436, 1255, 4, 200000, 800000),
(1437, 1437, 1154, 4, 500000, 2000000),
(1438, 1438, 1166, 3, 500000, 1500000),
(1439, 1439, 1297, 1, 200000, 200000),
(1440, 1440, 1162, 3, 200000, 600000),
(1441, 1441, 1195, 1, 200000, 200000),
(1442, 1442, 1013, 1, 500000, 500000),
(1443, 1443, 1022, 1, 500000, 500000),
(1444, 1444, 1011, 3, 150000, 450000),
(1445, 1445, 1243, 1, 200000, 200000),
(1446, 1446, 1009, 4, 200000, 800000),
(1447, 1447, 1070, 1, 500000, 500000),
(1448, 1448, 1088, 3, 500000, 1500000),
(1449, 1449, 1023, 4, 150000, 600000),
(1450, 1450, 1028, 2, 500000, 1000000),
(1451, 1451, 1126, 4, 200000, 800000),
(1452, 1452, 1229, 4, 500000, 2000000),
(1453, 1453, 1182, 1, 150000, 150000),
(1454, 1454, 1176, 1, 150000, 150000),
(1455, 1455, 1061, 3, 500000, 1500000),
(1456, 1456, 1114, 2, 200000, 400000),
(1457, 1457, 1187, 4, 500000, 2000000),
(1458, 1458, 1174, 1, 200000, 200000),
(1459, 1459, 1059, 3, 150000, 450000),
(1460, 1460, 1264, 2, 200000, 400000),
(1461, 1461, 1022, 1, 500000, 500000),
(1462, 1462, 1139, 4, 500000, 2000000),
(1463, 1463, 1284, 1, 150000, 150000),
(1464, 1464, 1288, 4, 200000, 800000),
(1465, 1465, 1087, 2, 200000, 400000),
(1466, 1466, 1281, 1, 150000, 150000),
(1467, 1467, 1087, 1, 200000, 200000),
(1468, 1468, 1056, 4, 150000, 600000),
(1469, 1469, 1126, 2, 200000, 400000),
(1470, 1470, 1279, 3, 200000, 600000),
(1471, 1471, 1032, 2, 150000, 300000),
(1472, 1472, 1222, 1, 200000, 200000),
(1473, 1473, 1222, 2, 200000, 400000),
(1474, 1474, 1247, 1, 500000, 500000),
(1475, 1475, 1050, 4, 150000, 600000),
(1476, 1476, 1086, 2, 150000, 300000),
(1477, 1477, 1184, 1, 500000, 500000),
(1478, 1478, 1007, 4, 500000, 2000000),
(1479, 1479, 1291, 4, 200000, 800000),
(1480, 1480, 1259, 4, 500000, 2000000),
(1481, 1481, 1154, 2, 500000, 1000000),
(1482, 1482, 1295, 2, 500000, 1000000),
(1483, 1483, 1177, 1, 200000, 200000),
(1484, 1484, 1280, 1, 500000, 500000),
(1485, 1485, 1006, 1, 200000, 200000),
(1486, 1486, 1299, 3, 150000, 450000),
(1487, 1487, 1237, 3, 200000, 600000),
(1488, 1488, 1228, 3, 200000, 600000),
(1489, 1489, 1216, 1, 200000, 200000),
(1490, 1490, 1120, 1, 200000, 200000),
(1491, 1491, 1010, 4, 500000, 2000000),
(1492, 1492, 1086, 4, 150000, 600000),
(1493, 1493, 1140, 2, 150000, 300000),
(1494, 1494, 1006, 2, 200000, 400000),
(1495, 1495, 1003, 1, 200000, 200000),
(1496, 1496, 1032, 1, 150000, 150000),
(1497, 1497, 1046, 4, 500000, 2000000),
(1498, 1498, 1032, 1, 150000, 150000),
(1499, 1499, 1091, 4, 500000, 2000000);
SET IDENTITY_INSERT OrderItems OFF;
GO
SET IDENTITY_INSERT Tickets ON;
INSERT INTO Tickets (ticket_id, ticket_code, order_item_id, attendee_name, attendee_email, qr_code, is_checked_in, created_at) VALUES
(1000, 'TIX-MEGA-1000-0', 1000, N'Đỗ Thu', 'mega_req_0@gmail.com', 'TIX-MEGA-1000-0|E1014|1043', 0, DATEADD(MINUTE, 37, DATEADD(HOUR, 20, DATEADD(DAY, -29, GETDATE())))),
(1001, 'TIX-MEGA-1000-1', 1000, N'Đỗ Thu', 'mega_req_0@gmail.com', 'TIX-MEGA-1000-1|E1014|1043', 0, DATEADD(MINUTE, 37, DATEADD(HOUR, 20, DATEADD(DAY, -29, GETDATE())))),
(1002, 'TIX-MEGA-1001-0', 1001, N'Đặng Minh', 'mega_req_1@gmail.com', 'TIX-MEGA-1001-0|E1052|1156', 0, DATEADD(MINUTE, 8, DATEADD(HOUR, 11, DATEADD(DAY, -22, GETDATE())))),
(1003, 'TIX-MEGA-1001-1', 1001, N'Đặng Minh', 'mega_req_1@gmail.com', 'TIX-MEGA-1001-1|E1052|1156', 0, DATEADD(MINUTE, 8, DATEADD(HOUR, 11, DATEADD(DAY, -22, GETDATE())))),
(1004, 'TIX-MEGA-1001-2', 1001, N'Đặng Minh', 'mega_req_1@gmail.com', 'TIX-MEGA-1001-2|E1052|1156', 0, DATEADD(MINUTE, 8, DATEADD(HOUR, 11, DATEADD(DAY, -22, GETDATE())))),
(1005, 'TIX-MEGA-1001-3', 1001, N'Đặng Minh', 'mega_req_1@gmail.com', 'TIX-MEGA-1001-3|E1052|1156', 0, DATEADD(MINUTE, 8, DATEADD(HOUR, 11, DATEADD(DAY, -22, GETDATE())))),
(1006, 'TIX-MEGA-1002-0', 1002, N'Nguyễn Kiên', 'mega_req_2@gmail.com', 'TIX-MEGA-1002-0|E1065|1196', 0, DATEADD(MINUTE, 26, DATEADD(HOUR, 21, DATEADD(DAY, -3, GETDATE())))),
(1007, 'TIX-MEGA-1003-0', 1003, N'Bùi Hùng', 'mega_req_3@gmail.com', 'TIX-MEGA-1003-0|E1011|1035', 1, DATEADD(MINUTE, 39, DATEADD(HOUR, 12, DATEADD(DAY, -7, GETDATE())))),
(1008, 'TIX-MEGA-1003-1', 1003, N'Bùi Hùng', 'mega_req_3@gmail.com', 'TIX-MEGA-1003-1|E1011|1035', 0, DATEADD(MINUTE, 39, DATEADD(HOUR, 12, DATEADD(DAY, -7, GETDATE())))),
(1009, 'TIX-MEGA-1003-2', 1003, N'Bùi Hùng', 'mega_req_3@gmail.com', 'TIX-MEGA-1003-2|E1011|1035', 0, DATEADD(MINUTE, 39, DATEADD(HOUR, 12, DATEADD(DAY, -7, GETDATE())))),
(1010, 'TIX-MEGA-1004-0', 1004, N'Đỗ Thành', 'mega_req_4@gmail.com', 'TIX-MEGA-1004-0|E1070|1210', 0, DATEADD(MINUTE, 13, DATEADD(HOUR, 8, DATEADD(DAY, -42, GETDATE())))),
(1011, 'TIX-MEGA-1004-1', 1004, N'Đỗ Thành', 'mega_req_4@gmail.com', 'TIX-MEGA-1004-1|E1070|1210', 1, DATEADD(MINUTE, 13, DATEADD(HOUR, 8, DATEADD(DAY, -42, GETDATE())))),
(1012, 'TIX-MEGA-1004-2', 1004, N'Đỗ Thành', 'mega_req_4@gmail.com', 'TIX-MEGA-1004-2|E1070|1210', 0, DATEADD(MINUTE, 13, DATEADD(HOUR, 8, DATEADD(DAY, -42, GETDATE())))),
(1013, 'TIX-MEGA-1004-3', 1004, N'Đỗ Thành', 'mega_req_4@gmail.com', 'TIX-MEGA-1004-3|E1070|1210', 0, DATEADD(MINUTE, 13, DATEADD(HOUR, 8, DATEADD(DAY, -42, GETDATE())))),
(1014, 'TIX-MEGA-1005-0', 1005, N'Đặng Bảo', 'mega_req_5@gmail.com', 'TIX-MEGA-1005-0|E1055|1166', 0, DATEADD(MINUTE, 51, DATEADD(HOUR, 10, DATEADD(DAY, -7, GETDATE())))),
(1015, 'TIX-MEGA-1005-1', 1005, N'Đặng Bảo', 'mega_req_5@gmail.com', 'TIX-MEGA-1005-1|E1055|1166', 0, DATEADD(MINUTE, 51, DATEADD(HOUR, 10, DATEADD(DAY, -7, GETDATE())))),
(1016, 'TIX-MEGA-1005-2', 1005, N'Đặng Bảo', 'mega_req_5@gmail.com', 'TIX-MEGA-1005-2|E1055|1166', 0, DATEADD(MINUTE, 51, DATEADD(HOUR, 10, DATEADD(DAY, -7, GETDATE())))),
(1017, 'TIX-MEGA-1006-0', 1006, N'Hoàng Linh', 'mega_req_6@gmail.com', 'TIX-MEGA-1006-0|E1027|1083', 1, DATEADD(MINUTE, 24, DATEADD(HOUR, 15, DATEADD(DAY, -13, GETDATE())))),
(1018, 'TIX-MEGA-1007-0', 1007, N'Phạm Trang', 'mega_req_7@gmail.com', 'TIX-MEGA-1007-0|E1048|1146', 0, DATEADD(MINUTE, 30, DATEADD(HOUR, 20, DATEADD(DAY, -59, GETDATE())))),
(1019, 'TIX-MEGA-1008-0', 1008, N'Huỳnh Linh', 'mega_req_8@gmail.com', 'TIX-MEGA-1008-0|E1071|1213', 0, DATEADD(MINUTE, 25, DATEADD(HOUR, 11, DATEADD(DAY, -16, GETDATE())))),
(1020, 'TIX-MEGA-1008-1', 1008, N'Huỳnh Linh', 'mega_req_8@gmail.com', 'TIX-MEGA-1008-1|E1071|1213', 0, DATEADD(MINUTE, 25, DATEADD(HOUR, 11, DATEADD(DAY, -16, GETDATE())))),
(1021, 'TIX-MEGA-1008-2', 1008, N'Huỳnh Linh', 'mega_req_8@gmail.com', 'TIX-MEGA-1008-2|E1071|1213', 0, DATEADD(MINUTE, 25, DATEADD(HOUR, 11, DATEADD(DAY, -16, GETDATE())))),
(1022, 'TIX-MEGA-1008-3', 1008, N'Huỳnh Linh', 'mega_req_8@gmail.com', 'TIX-MEGA-1008-3|E1071|1213', 0, DATEADD(MINUTE, 25, DATEADD(HOUR, 11, DATEADD(DAY, -16, GETDATE())))),
(1023, 'TIX-MEGA-1009-0', 1009, N'Huỳnh Hải', 'mega_req_9@gmail.com', 'TIX-MEGA-1009-0|E1024|1072', 0, DATEADD(MINUTE, 27, DATEADD(HOUR, 14, DATEADD(DAY, -56, GETDATE())))),
(1024, 'TIX-MEGA-1009-1', 1009, N'Huỳnh Hải', 'mega_req_9@gmail.com', 'TIX-MEGA-1009-1|E1024|1072', 1, DATEADD(MINUTE, 27, DATEADD(HOUR, 14, DATEADD(DAY, -56, GETDATE())))),
(1025, 'TIX-MEGA-1009-2', 1009, N'Huỳnh Hải', 'mega_req_9@gmail.com', 'TIX-MEGA-1009-2|E1024|1072', 0, DATEADD(MINUTE, 27, DATEADD(HOUR, 14, DATEADD(DAY, -56, GETDATE())))),
(1026, 'TIX-MEGA-1009-3', 1009, N'Huỳnh Hải', 'mega_req_9@gmail.com', 'TIX-MEGA-1009-3|E1024|1072', 0, DATEADD(MINUTE, 27, DATEADD(HOUR, 14, DATEADD(DAY, -56, GETDATE())))),
(1027, 'TIX-MEGA-1010-0', 1010, N'Huỳnh Khoa', 'mega_req_10@gmail.com', 'TIX-MEGA-1010-0|E1011|1034', 0, DATEADD(MINUTE, 32, DATEADD(HOUR, 6, DATEADD(DAY, -21, GETDATE())))),
(1028, 'TIX-MEGA-1010-1', 1010, N'Huỳnh Khoa', 'mega_req_10@gmail.com', 'TIX-MEGA-1010-1|E1011|1034', 1, DATEADD(MINUTE, 32, DATEADD(HOUR, 6, DATEADD(DAY, -21, GETDATE())))),
(1029, 'TIX-MEGA-1011-0', 1011, N'Đỗ Linh', 'mega_req_11@gmail.com', 'TIX-MEGA-1011-0|E1051|1155', 0, DATEADD(MINUTE, 33, DATEADD(HOUR, 6, DATEADD(DAY, -51, GETDATE())))),
(1030, 'TIX-MEGA-1011-1', 1011, N'Đỗ Linh', 'mega_req_11@gmail.com', 'TIX-MEGA-1011-1|E1051|1155', 0, DATEADD(MINUTE, 33, DATEADD(HOUR, 6, DATEADD(DAY, -51, GETDATE())))),
(1031, 'TIX-MEGA-1011-2', 1011, N'Đỗ Linh', 'mega_req_11@gmail.com', 'TIX-MEGA-1011-2|E1051|1155', 0, DATEADD(MINUTE, 33, DATEADD(HOUR, 6, DATEADD(DAY, -51, GETDATE())))),
(1032, 'TIX-MEGA-1012-0', 1012, N'Bùi Thu', 'mega_req_12@gmail.com', 'TIX-MEGA-1012-0|E1083|1250', 0, DATEADD(MINUTE, 8, DATEADD(HOUR, 22, DATEADD(DAY, -49, GETDATE())))),
(1033, 'TIX-MEGA-1012-1', 1012, N'Bùi Thu', 'mega_req_12@gmail.com', 'TIX-MEGA-1012-1|E1083|1250', 1, DATEADD(MINUTE, 8, DATEADD(HOUR, 22, DATEADD(DAY, -49, GETDATE())))),
(1034, 'TIX-MEGA-1012-2', 1012, N'Bùi Thu', 'mega_req_12@gmail.com', 'TIX-MEGA-1012-2|E1083|1250', 0, DATEADD(MINUTE, 8, DATEADD(HOUR, 22, DATEADD(DAY, -49, GETDATE())))),
(1035, 'TIX-MEGA-1012-3', 1012, N'Bùi Thu', 'mega_req_12@gmail.com', 'TIX-MEGA-1012-3|E1083|1250', 1, DATEADD(MINUTE, 8, DATEADD(HOUR, 22, DATEADD(DAY, -49, GETDATE())))),
(1036, 'TIX-MEGA-1013-0', 1013, N'Phạm Phong', 'mega_req_13@gmail.com', 'TIX-MEGA-1013-0|E1023|1070', 0, DATEADD(MINUTE, 41, DATEADD(HOUR, 12, DATEADD(DAY, -57, GETDATE())))),
(1037, 'TIX-MEGA-1013-1', 1013, N'Phạm Phong', 'mega_req_13@gmail.com', 'TIX-MEGA-1013-1|E1023|1070', 1, DATEADD(MINUTE, 41, DATEADD(HOUR, 12, DATEADD(DAY, -57, GETDATE())))),
(1038, 'TIX-MEGA-1013-2', 1013, N'Phạm Phong', 'mega_req_13@gmail.com', 'TIX-MEGA-1013-2|E1023|1070', 0, DATEADD(MINUTE, 41, DATEADD(HOUR, 12, DATEADD(DAY, -57, GETDATE())))),
(1039, 'TIX-MEGA-1013-3', 1013, N'Phạm Phong', 'mega_req_13@gmail.com', 'TIX-MEGA-1013-3|E1023|1070', 0, DATEADD(MINUTE, 41, DATEADD(HOUR, 12, DATEADD(DAY, -57, GETDATE())))),
(1040, 'TIX-MEGA-1014-0', 1014, N'Hoàng Minh', 'mega_req_14@gmail.com', 'TIX-MEGA-1014-0|E1005|1015', 0, DATEADD(MINUTE, 23, DATEADD(HOUR, 3, DATEADD(DAY, -26, GETDATE())))),
(1041, 'TIX-MEGA-1014-1', 1014, N'Hoàng Minh', 'mega_req_14@gmail.com', 'TIX-MEGA-1014-1|E1005|1015', 0, DATEADD(MINUTE, 23, DATEADD(HOUR, 3, DATEADD(DAY, -26, GETDATE())))),
(1042, 'TIX-MEGA-1015-0', 1015, N'Đặng Phong', 'mega_req_15@gmail.com', 'TIX-MEGA-1015-0|E1033|1100', 0, DATEADD(MINUTE, 39, DATEADD(HOUR, 20, DATEADD(DAY, -38, GETDATE())))),
(1043, 'TIX-MEGA-1016-0', 1016, N'Trần Kiên', 'mega_req_16@gmail.com', 'TIX-MEGA-1016-0|E1022|1068', 0, DATEADD(MINUTE, 14, DATEADD(HOUR, 5, DATEADD(DAY, -43, GETDATE())))),
(1044, 'TIX-MEGA-1016-1', 1016, N'Trần Kiên', 'mega_req_16@gmail.com', 'TIX-MEGA-1016-1|E1022|1068', 0, DATEADD(MINUTE, 14, DATEADD(HOUR, 5, DATEADD(DAY, -43, GETDATE())))),
(1045, 'TIX-MEGA-1017-0', 1017, N'Đỗ Linh', 'mega_req_17@gmail.com', 'TIX-MEGA-1017-0|E1038|1116', 0, DATEADD(MINUTE, 49, DATEADD(HOUR, 10, DATEADD(DAY, -12, GETDATE())))),
(1046, 'TIX-MEGA-1018-0', 1018, N'Lê Khoa', 'mega_req_18@gmail.com', 'TIX-MEGA-1018-0|E1018|1055', 0, DATEADD(MINUTE, 58, DATEADD(HOUR, 22, DATEADD(DAY, -39, GETDATE())))),
(1047, 'TIX-MEGA-1018-1', 1018, N'Lê Khoa', 'mega_req_18@gmail.com', 'TIX-MEGA-1018-1|E1018|1055', 0, DATEADD(MINUTE, 58, DATEADD(HOUR, 22, DATEADD(DAY, -39, GETDATE())))),
(1048, 'TIX-MEGA-1018-2', 1018, N'Lê Khoa', 'mega_req_18@gmail.com', 'TIX-MEGA-1018-2|E1018|1055', 0, DATEADD(MINUTE, 58, DATEADD(HOUR, 22, DATEADD(DAY, -39, GETDATE())))),
(1049, 'TIX-MEGA-1019-0', 1019, N'Đặng Trang', 'mega_req_19@gmail.com', 'TIX-MEGA-1019-0|E1027|1081', 0, DATEADD(MINUTE, 6, DATEADD(HOUR, 13, DATEADD(DAY, -24, GETDATE())))),
(1050, 'TIX-MEGA-1020-0', 1020, N'Lê Kiên', 'mega_req_20@gmail.com', 'TIX-MEGA-1020-0|E1067|1201', 0, DATEADD(MINUTE, 27, DATEADD(HOUR, 17, DATEADD(DAY, -43, GETDATE())))),
(1051, 'TIX-MEGA-1021-0', 1021, N'Phạm Hải', 'mega_req_21@gmail.com', 'TIX-MEGA-1021-0|E1019|1057', 0, DATEADD(MINUTE, 24, DATEADD(HOUR, 0, DATEADD(DAY, -47, GETDATE())))),
(1052, 'TIX-MEGA-1021-1', 1021, N'Phạm Hải', 'mega_req_21@gmail.com', 'TIX-MEGA-1021-1|E1019|1057', 0, DATEADD(MINUTE, 24, DATEADD(HOUR, 0, DATEADD(DAY, -47, GETDATE())))),
(1053, 'TIX-MEGA-1021-2', 1021, N'Phạm Hải', 'mega_req_21@gmail.com', 'TIX-MEGA-1021-2|E1019|1057', 0, DATEADD(MINUTE, 24, DATEADD(HOUR, 0, DATEADD(DAY, -47, GETDATE())))),
(1054, 'TIX-MEGA-1022-0', 1022, N'Hoàng Bảo', 'mega_req_22@gmail.com', 'TIX-MEGA-1022-0|E1029|1088', 0, DATEADD(MINUTE, 33, DATEADD(HOUR, 13, DATEADD(DAY, -12, GETDATE())))),
(1055, 'TIX-MEGA-1022-1', 1022, N'Hoàng Bảo', 'mega_req_22@gmail.com', 'TIX-MEGA-1022-1|E1029|1088', 0, DATEADD(MINUTE, 33, DATEADD(HOUR, 13, DATEADD(DAY, -12, GETDATE())))),
(1056, 'TIX-MEGA-1023-0', 1023, N'Phạm Trang', 'mega_req_23@gmail.com', 'TIX-MEGA-1023-0|E1050|1151', 0, DATEADD(MINUTE, 38, DATEADD(HOUR, 23, DATEADD(DAY, -12, GETDATE())))),
(1057, 'TIX-MEGA-1023-1', 1023, N'Phạm Trang', 'mega_req_23@gmail.com', 'TIX-MEGA-1023-1|E1050|1151', 0, DATEADD(MINUTE, 38, DATEADD(HOUR, 23, DATEADD(DAY, -12, GETDATE())))),
(1058, 'TIX-MEGA-1023-2', 1023, N'Phạm Trang', 'mega_req_23@gmail.com', 'TIX-MEGA-1023-2|E1050|1151', 0, DATEADD(MINUTE, 38, DATEADD(HOUR, 23, DATEADD(DAY, -12, GETDATE())))),
(1059, 'TIX-MEGA-1024-0', 1024, N'Phạm Linh', 'mega_req_24@gmail.com', 'TIX-MEGA-1024-0|E1004|1012', 0, DATEADD(MINUTE, 21, DATEADD(HOUR, 4, DATEADD(DAY, -2, GETDATE())))),
(1060, 'TIX-MEGA-1025-0', 1025, N'Bùi Anh', 'mega_req_25@gmail.com', 'TIX-MEGA-1025-0|E1006|1020', 0, DATEADD(MINUTE, 50, DATEADD(HOUR, 13, DATEADD(DAY, -59, GETDATE())))),
(1061, 'TIX-MEGA-1025-1', 1025, N'Bùi Anh', 'mega_req_25@gmail.com', 'TIX-MEGA-1025-1|E1006|1020', 0, DATEADD(MINUTE, 50, DATEADD(HOUR, 13, DATEADD(DAY, -59, GETDATE())))),
(1062, 'TIX-MEGA-1025-2', 1025, N'Bùi Anh', 'mega_req_25@gmail.com', 'TIX-MEGA-1025-2|E1006|1020', 0, DATEADD(MINUTE, 50, DATEADD(HOUR, 13, DATEADD(DAY, -59, GETDATE())))),
(1063, 'TIX-MEGA-1026-0', 1026, N'Vũ Bảo', 'mega_req_26@gmail.com', 'TIX-MEGA-1026-0|E1028|1085', 0, DATEADD(MINUTE, 23, DATEADD(HOUR, 13, DATEADD(DAY, -40, GETDATE())))),
(1064, 'TIX-MEGA-1026-1', 1026, N'Vũ Bảo', 'mega_req_26@gmail.com', 'TIX-MEGA-1026-1|E1028|1085', 0, DATEADD(MINUTE, 23, DATEADD(HOUR, 13, DATEADD(DAY, -40, GETDATE())))),
(1065, 'TIX-MEGA-1027-0', 1027, N'Hoàng Thu', 'mega_req_27@gmail.com', 'TIX-MEGA-1027-0|E1054|1164', 0, DATEADD(MINUTE, 53, DATEADD(HOUR, 16, DATEADD(DAY, -36, GETDATE())))),
(1066, 'TIX-MEGA-1028-0', 1028, N'Nguyễn Trang', 'mega_req_28@gmail.com', 'TIX-MEGA-1028-0|E1016|1050', 0, DATEADD(MINUTE, 19, DATEADD(HOUR, 22, DATEADD(DAY, -18, GETDATE())))),
(1067, 'TIX-MEGA-1029-0', 1029, N'Hoàng Khoa', 'mega_req_29@gmail.com', 'TIX-MEGA-1029-0|E1096|1289', 0, DATEADD(MINUTE, 23, DATEADD(HOUR, 18, DATEADD(DAY, -48, GETDATE())))),
(1068, 'TIX-MEGA-1029-1', 1029, N'Hoàng Khoa', 'mega_req_29@gmail.com', 'TIX-MEGA-1029-1|E1096|1289', 0, DATEADD(MINUTE, 23, DATEADD(HOUR, 18, DATEADD(DAY, -48, GETDATE())))),
(1069, 'TIX-MEGA-1029-2', 1029, N'Hoàng Khoa', 'mega_req_29@gmail.com', 'TIX-MEGA-1029-2|E1096|1289', 0, DATEADD(MINUTE, 23, DATEADD(HOUR, 18, DATEADD(DAY, -48, GETDATE())))),
(1070, 'TIX-MEGA-1030-0', 1030, N'Đặng Thu', 'mega_req_30@gmail.com', 'TIX-MEGA-1030-0|E1049|1147', 0, DATEADD(MINUTE, 11, DATEADD(HOUR, 7, DATEADD(DAY, -35, GETDATE())))),
(1071, 'TIX-MEGA-1031-0', 1031, N'Bùi Linh', 'mega_req_31@gmail.com', 'TIX-MEGA-1031-0|E1045|1137', 0, DATEADD(MINUTE, 8, DATEADD(HOUR, 0, DATEADD(DAY, -4, GETDATE())))),
(1072, 'TIX-MEGA-1031-1', 1031, N'Bùi Linh', 'mega_req_31@gmail.com', 'TIX-MEGA-1031-1|E1045|1137', 0, DATEADD(MINUTE, 8, DATEADD(HOUR, 0, DATEADD(DAY, -4, GETDATE())))),
(1073, 'TIX-MEGA-1031-2', 1031, N'Bùi Linh', 'mega_req_31@gmail.com', 'TIX-MEGA-1031-2|E1045|1137', 0, DATEADD(MINUTE, 8, DATEADD(HOUR, 0, DATEADD(DAY, -4, GETDATE())))),
(1074, 'TIX-MEGA-1032-0', 1032, N'Vũ Bảo', 'mega_req_32@gmail.com', 'TIX-MEGA-1032-0|E1010|1031', 0, DATEADD(MINUTE, 19, DATEADD(HOUR, 18, DATEADD(DAY, -24, GETDATE())))),
(1075, 'TIX-MEGA-1033-0', 1033, N'Đỗ Thu', 'mega_req_33@gmail.com', 'TIX-MEGA-1033-0|E1001|1005', 0, DATEADD(MINUTE, 43, DATEADD(HOUR, 7, DATEADD(DAY, -26, GETDATE())))),
(1076, 'TIX-MEGA-1033-1', 1033, N'Đỗ Thu', 'mega_req_33@gmail.com', 'TIX-MEGA-1033-1|E1001|1005', 0, DATEADD(MINUTE, 43, DATEADD(HOUR, 7, DATEADD(DAY, -26, GETDATE())))),
(1077, 'TIX-MEGA-1033-2', 1033, N'Đỗ Thu', 'mega_req_33@gmail.com', 'TIX-MEGA-1033-2|E1001|1005', 0, DATEADD(MINUTE, 43, DATEADD(HOUR, 7, DATEADD(DAY, -26, GETDATE())))),
(1078, 'TIX-MEGA-1034-0', 1034, N'Phạm Minh', 'mega_req_34@gmail.com', 'TIX-MEGA-1034-0|E1021|1065', 0, DATEADD(MINUTE, 50, DATEADD(HOUR, 0, DATEADD(DAY, -36, GETDATE())))),
(1079, 'TIX-MEGA-1034-1', 1034, N'Phạm Minh', 'mega_req_34@gmail.com', 'TIX-MEGA-1034-1|E1021|1065', 0, DATEADD(MINUTE, 50, DATEADD(HOUR, 0, DATEADD(DAY, -36, GETDATE())))),
(1080, 'TIX-MEGA-1035-0', 1035, N'Phạm Thu', 'mega_req_35@gmail.com', 'TIX-MEGA-1035-0|E1009|1027', 1, DATEADD(MINUTE, 11, DATEADD(HOUR, 3, DATEADD(DAY, -29, GETDATE())))),
(1081, 'TIX-MEGA-1035-1', 1035, N'Phạm Thu', 'mega_req_35@gmail.com', 'TIX-MEGA-1035-1|E1009|1027', 0, DATEADD(MINUTE, 11, DATEADD(HOUR, 3, DATEADD(DAY, -29, GETDATE())))),
(1082, 'TIX-MEGA-1035-2', 1035, N'Phạm Thu', 'mega_req_35@gmail.com', 'TIX-MEGA-1035-2|E1009|1027', 0, DATEADD(MINUTE, 11, DATEADD(HOUR, 3, DATEADD(DAY, -29, GETDATE())))),
(1083, 'TIX-MEGA-1035-3', 1035, N'Phạm Thu', 'mega_req_35@gmail.com', 'TIX-MEGA-1035-3|E1009|1027', 0, DATEADD(MINUTE, 11, DATEADD(HOUR, 3, DATEADD(DAY, -29, GETDATE())))),
(1084, 'TIX-MEGA-1036-0', 1036, N'Phạm Thu', 'mega_req_36@gmail.com', 'TIX-MEGA-1036-0|E1011|1033', 1, DATEADD(MINUTE, 42, DATEADD(HOUR, 20, DATEADD(DAY, -36, GETDATE())))),
(1085, 'TIX-MEGA-1036-1', 1036, N'Phạm Thu', 'mega_req_36@gmail.com', 'TIX-MEGA-1036-1|E1011|1033', 0, DATEADD(MINUTE, 42, DATEADD(HOUR, 20, DATEADD(DAY, -36, GETDATE())))),
(1086, 'TIX-MEGA-1036-2', 1036, N'Phạm Thu', 'mega_req_36@gmail.com', 'TIX-MEGA-1036-2|E1011|1033', 0, DATEADD(MINUTE, 42, DATEADD(HOUR, 20, DATEADD(DAY, -36, GETDATE())))),
(1087, 'TIX-MEGA-1036-3', 1036, N'Phạm Thu', 'mega_req_36@gmail.com', 'TIX-MEGA-1036-3|E1011|1033', 0, DATEADD(MINUTE, 42, DATEADD(HOUR, 20, DATEADD(DAY, -36, GETDATE())))),
(1088, 'TIX-MEGA-1037-0', 1037, N'Phạm Anh', 'mega_req_37@gmail.com', 'TIX-MEGA-1037-0|E1012|1038', 0, DATEADD(MINUTE, 9, DATEADD(HOUR, 22, DATEADD(DAY, -57, GETDATE())))),
(1089, 'TIX-MEGA-1037-1', 1037, N'Phạm Anh', 'mega_req_37@gmail.com', 'TIX-MEGA-1037-1|E1012|1038', 0, DATEADD(MINUTE, 9, DATEADD(HOUR, 22, DATEADD(DAY, -57, GETDATE())))),
(1090, 'TIX-MEGA-1037-2', 1037, N'Phạm Anh', 'mega_req_37@gmail.com', 'TIX-MEGA-1037-2|E1012|1038', 0, DATEADD(MINUTE, 9, DATEADD(HOUR, 22, DATEADD(DAY, -57, GETDATE())))),
(1091, 'TIX-MEGA-1038-0', 1038, N'Trần Hải', 'mega_req_38@gmail.com', 'TIX-MEGA-1038-0|E1008|1024', 0, DATEADD(MINUTE, 32, DATEADD(HOUR, 10, DATEADD(DAY, -11, GETDATE())))),
(1092, 'TIX-MEGA-1039-0', 1039, N'Huỳnh Bảo', 'mega_req_39@gmail.com', 'TIX-MEGA-1039-0|E1014|1042', 0, DATEADD(MINUTE, 9, DATEADD(HOUR, 8, DATEADD(DAY, -50, GETDATE())))),
(1093, 'TIX-MEGA-1039-1', 1039, N'Huỳnh Bảo', 'mega_req_39@gmail.com', 'TIX-MEGA-1039-1|E1014|1042', 0, DATEADD(MINUTE, 9, DATEADD(HOUR, 8, DATEADD(DAY, -50, GETDATE())))),
(1094, 'TIX-MEGA-1039-2', 1039, N'Huỳnh Bảo', 'mega_req_39@gmail.com', 'TIX-MEGA-1039-2|E1014|1042', 0, DATEADD(MINUTE, 9, DATEADD(HOUR, 8, DATEADD(DAY, -50, GETDATE())))),
(1095, 'TIX-MEGA-1040-0', 1040, N'Hoàng Trang', 'mega_req_40@gmail.com', 'TIX-MEGA-1040-0|E1018|1056', 0, DATEADD(MINUTE, 58, DATEADD(HOUR, 12, DATEADD(DAY, -41, GETDATE())))),
(1096, 'TIX-MEGA-1040-1', 1040, N'Hoàng Trang', 'mega_req_40@gmail.com', 'TIX-MEGA-1040-1|E1018|1056', 0, DATEADD(MINUTE, 58, DATEADD(HOUR, 12, DATEADD(DAY, -41, GETDATE())))),
(1097, 'TIX-MEGA-1040-2', 1040, N'Hoàng Trang', 'mega_req_40@gmail.com', 'TIX-MEGA-1040-2|E1018|1056', 0, DATEADD(MINUTE, 58, DATEADD(HOUR, 12, DATEADD(DAY, -41, GETDATE())))),
(1098, 'TIX-MEGA-1041-0', 1041, N'Bùi Lan', 'mega_req_41@gmail.com', 'TIX-MEGA-1041-0|E1002|1008', 0, DATEADD(MINUTE, 44, DATEADD(HOUR, 18, DATEADD(DAY, -48, GETDATE())))),
(1099, 'TIX-MEGA-1041-1', 1041, N'Bùi Lan', 'mega_req_41@gmail.com', 'TIX-MEGA-1041-1|E1002|1008', 0, DATEADD(MINUTE, 44, DATEADD(HOUR, 18, DATEADD(DAY, -48, GETDATE())))),
(1100, 'TIX-MEGA-1041-2', 1041, N'Bùi Lan', 'mega_req_41@gmail.com', 'TIX-MEGA-1041-2|E1002|1008', 0, DATEADD(MINUTE, 44, DATEADD(HOUR, 18, DATEADD(DAY, -48, GETDATE()))));
INSERT INTO Tickets (ticket_id, ticket_code, order_item_id, attendee_name, attendee_email, qr_code, is_checked_in, created_at) VALUES
(1101, 'TIX-MEGA-1042-0', 1042, N'Đặng Thành', 'mega_req_42@gmail.com', 'TIX-MEGA-1042-0|E1079|1238', 0, DATEADD(MINUTE, 27, DATEADD(HOUR, 20, DATEADD(DAY, -45, GETDATE())))),
(1102, 'TIX-MEGA-1042-1', 1042, N'Đặng Thành', 'mega_req_42@gmail.com', 'TIX-MEGA-1042-1|E1079|1238', 0, DATEADD(MINUTE, 27, DATEADD(HOUR, 20, DATEADD(DAY, -45, GETDATE())))),
(1103, 'TIX-MEGA-1042-2', 1042, N'Đặng Thành', 'mega_req_42@gmail.com', 'TIX-MEGA-1042-2|E1079|1238', 0, DATEADD(MINUTE, 27, DATEADD(HOUR, 20, DATEADD(DAY, -45, GETDATE())))),
(1104, 'TIX-MEGA-1042-3', 1042, N'Đặng Thành', 'mega_req_42@gmail.com', 'TIX-MEGA-1042-3|E1079|1238', 0, DATEADD(MINUTE, 27, DATEADD(HOUR, 20, DATEADD(DAY, -45, GETDATE())))),
(1105, 'TIX-MEGA-1043-0', 1043, N'Vũ Trang', 'mega_req_43@gmail.com', 'TIX-MEGA-1043-0|E1038|1116', 0, DATEADD(MINUTE, 30, DATEADD(HOUR, 5, DATEADD(DAY, -31, GETDATE())))),
(1106, 'TIX-MEGA-1043-1', 1043, N'Vũ Trang', 'mega_req_43@gmail.com', 'TIX-MEGA-1043-1|E1038|1116', 0, DATEADD(MINUTE, 30, DATEADD(HOUR, 5, DATEADD(DAY, -31, GETDATE())))),
(1107, 'TIX-MEGA-1044-0', 1044, N'Bùi Trang', 'mega_req_44@gmail.com', 'TIX-MEGA-1044-0|E1028|1085', 0, DATEADD(MINUTE, 27, DATEADD(HOUR, 10, DATEADD(DAY, -32, GETDATE())))),
(1108, 'TIX-MEGA-1044-1', 1044, N'Bùi Trang', 'mega_req_44@gmail.com', 'TIX-MEGA-1044-1|E1028|1085', 0, DATEADD(MINUTE, 27, DATEADD(HOUR, 10, DATEADD(DAY, -32, GETDATE())))),
(1109, 'TIX-MEGA-1044-2', 1044, N'Bùi Trang', 'mega_req_44@gmail.com', 'TIX-MEGA-1044-2|E1028|1085', 0, DATEADD(MINUTE, 27, DATEADD(HOUR, 10, DATEADD(DAY, -32, GETDATE())))),
(1110, 'TIX-MEGA-1045-0', 1045, N'Lê Minh', 'mega_req_45@gmail.com', 'TIX-MEGA-1045-0|E1006|1018', 0, DATEADD(MINUTE, 15, DATEADD(HOUR, 18, DATEADD(DAY, -12, GETDATE())))),
(1111, 'TIX-MEGA-1045-1', 1045, N'Lê Minh', 'mega_req_45@gmail.com', 'TIX-MEGA-1045-1|E1006|1018', 0, DATEADD(MINUTE, 15, DATEADD(HOUR, 18, DATEADD(DAY, -12, GETDATE())))),
(1112, 'TIX-MEGA-1046-0', 1046, N'Phạm Trang', 'mega_req_46@gmail.com', 'TIX-MEGA-1046-0|E1030|1090', 0, DATEADD(MINUTE, 11, DATEADD(HOUR, 11, DATEADD(DAY, -52, GETDATE())))),
(1113, 'TIX-MEGA-1047-0', 1047, N'Lê Vân', 'mega_req_47@gmail.com', 'TIX-MEGA-1047-0|E1082|1248', 0, DATEADD(MINUTE, 11, DATEADD(HOUR, 13, DATEADD(DAY, -39, GETDATE())))),
(1114, 'TIX-MEGA-1047-1', 1047, N'Lê Vân', 'mega_req_47@gmail.com', 'TIX-MEGA-1047-1|E1082|1248', 0, DATEADD(MINUTE, 11, DATEADD(HOUR, 13, DATEADD(DAY, -39, GETDATE())))),
(1115, 'TIX-MEGA-1047-2', 1047, N'Lê Vân', 'mega_req_47@gmail.com', 'TIX-MEGA-1047-2|E1082|1248', 0, DATEADD(MINUTE, 11, DATEADD(HOUR, 13, DATEADD(DAY, -39, GETDATE())))),
(1116, 'TIX-MEGA-1047-3', 1047, N'Lê Vân', 'mega_req_47@gmail.com', 'TIX-MEGA-1047-3|E1082|1248', 0, DATEADD(MINUTE, 11, DATEADD(HOUR, 13, DATEADD(DAY, -39, GETDATE())))),
(1117, 'TIX-MEGA-1048-0', 1048, N'Hoàng Thu', 'mega_req_48@gmail.com', 'TIX-MEGA-1048-0|E1044|1134', 0, DATEADD(MINUTE, 46, DATEADD(HOUR, 6, DATEADD(DAY, 0, GETDATE())))),
(1118, 'TIX-MEGA-1048-1', 1048, N'Hoàng Thu', 'mega_req_48@gmail.com', 'TIX-MEGA-1048-1|E1044|1134', 0, DATEADD(MINUTE, 46, DATEADD(HOUR, 6, DATEADD(DAY, 0, GETDATE())))),
(1119, 'TIX-MEGA-1049-0', 1049, N'Lê Khoa', 'mega_req_49@gmail.com', 'TIX-MEGA-1049-0|E1009|1027', 0, DATEADD(MINUTE, 14, DATEADD(HOUR, 7, DATEADD(DAY, -13, GETDATE())))),
(1120, 'TIX-MEGA-1049-1', 1049, N'Lê Khoa', 'mega_req_49@gmail.com', 'TIX-MEGA-1049-1|E1009|1027', 0, DATEADD(MINUTE, 14, DATEADD(HOUR, 7, DATEADD(DAY, -13, GETDATE())))),
(1121, 'TIX-MEGA-1049-2', 1049, N'Lê Khoa', 'mega_req_49@gmail.com', 'TIX-MEGA-1049-2|E1009|1027', 0, DATEADD(MINUTE, 14, DATEADD(HOUR, 7, DATEADD(DAY, -13, GETDATE())))),
(1122, 'TIX-MEGA-1050-0', 1050, N'Phạm Minh', 'mega_req_50@gmail.com', 'TIX-MEGA-1050-0|E1034|1102', 0, DATEADD(MINUTE, 38, DATEADD(HOUR, 13, DATEADD(DAY, -60, GETDATE())))),
(1123, 'TIX-MEGA-1050-1', 1050, N'Phạm Minh', 'mega_req_50@gmail.com', 'TIX-MEGA-1050-1|E1034|1102', 0, DATEADD(MINUTE, 38, DATEADD(HOUR, 13, DATEADD(DAY, -60, GETDATE())))),
(1124, 'TIX-MEGA-1050-2', 1050, N'Phạm Minh', 'mega_req_50@gmail.com', 'TIX-MEGA-1050-2|E1034|1102', 0, DATEADD(MINUTE, 38, DATEADD(HOUR, 13, DATEADD(DAY, -60, GETDATE())))),
(1125, 'TIX-MEGA-1051-0', 1051, N'Bùi Hải', 'mega_req_51@gmail.com', 'TIX-MEGA-1051-0|E1006|1018', 0, DATEADD(MINUTE, 49, DATEADD(HOUR, 6, DATEADD(DAY, -3, GETDATE())))),
(1126, 'TIX-MEGA-1051-1', 1051, N'Bùi Hải', 'mega_req_51@gmail.com', 'TIX-MEGA-1051-1|E1006|1018', 0, DATEADD(MINUTE, 49, DATEADD(HOUR, 6, DATEADD(DAY, -3, GETDATE())))),
(1127, 'TIX-MEGA-1051-2', 1051, N'Bùi Hải', 'mega_req_51@gmail.com', 'TIX-MEGA-1051-2|E1006|1018', 1, DATEADD(MINUTE, 49, DATEADD(HOUR, 6, DATEADD(DAY, -3, GETDATE())))),
(1128, 'TIX-MEGA-1051-3', 1051, N'Bùi Hải', 'mega_req_51@gmail.com', 'TIX-MEGA-1051-3|E1006|1018', 0, DATEADD(MINUTE, 49, DATEADD(HOUR, 6, DATEADD(DAY, -3, GETDATE())))),
(1129, 'TIX-MEGA-1052-0', 1052, N'Bùi Hùng', 'mega_req_52@gmail.com', 'TIX-MEGA-1052-0|E1046|1139', 0, DATEADD(MINUTE, 3, DATEADD(HOUR, 3, DATEADD(DAY, -17, GETDATE())))),
(1130, 'TIX-MEGA-1052-1', 1052, N'Bùi Hùng', 'mega_req_52@gmail.com', 'TIX-MEGA-1052-1|E1046|1139', 0, DATEADD(MINUTE, 3, DATEADD(HOUR, 3, DATEADD(DAY, -17, GETDATE())))),
(1131, 'TIX-MEGA-1052-2', 1052, N'Bùi Hùng', 'mega_req_52@gmail.com', 'TIX-MEGA-1052-2|E1046|1139', 0, DATEADD(MINUTE, 3, DATEADD(HOUR, 3, DATEADD(DAY, -17, GETDATE())))),
(1132, 'TIX-MEGA-1053-0', 1053, N'Vũ Hùng', 'mega_req_53@gmail.com', 'TIX-MEGA-1053-0|E1049|1147', 1, DATEADD(MINUTE, 51, DATEADD(HOUR, 5, DATEADD(DAY, -59, GETDATE())))),
(1133, 'TIX-MEGA-1054-0', 1054, N'Nguyễn Linh', 'mega_req_54@gmail.com', 'TIX-MEGA-1054-0|E1037|1112', 0, DATEADD(MINUTE, 35, DATEADD(HOUR, 23, DATEADD(DAY, -33, GETDATE())))),
(1134, 'TIX-MEGA-1054-1', 1054, N'Nguyễn Linh', 'mega_req_54@gmail.com', 'TIX-MEGA-1054-1|E1037|1112', 0, DATEADD(MINUTE, 35, DATEADD(HOUR, 23, DATEADD(DAY, -33, GETDATE())))),
(1135, 'TIX-MEGA-1054-2', 1054, N'Nguyễn Linh', 'mega_req_54@gmail.com', 'TIX-MEGA-1054-2|E1037|1112', 0, DATEADD(MINUTE, 35, DATEADD(HOUR, 23, DATEADD(DAY, -33, GETDATE())))),
(1136, 'TIX-MEGA-1055-0', 1055, N'Bùi Trang', 'mega_req_55@gmail.com', 'TIX-MEGA-1055-0|E1023|1069', 0, DATEADD(MINUTE, 50, DATEADD(HOUR, 12, DATEADD(DAY, -49, GETDATE())))),
(1137, 'TIX-MEGA-1056-0', 1056, N'Đặng Anh', 'mega_req_56@gmail.com', 'TIX-MEGA-1056-0|E1066|1199', 1, DATEADD(MINUTE, 27, DATEADD(HOUR, 8, DATEADD(DAY, -10, GETDATE())))),
(1138, 'TIX-MEGA-1057-0', 1057, N'Phạm Hùng', 'mega_req_57@gmail.com', 'TIX-MEGA-1057-0|E1011|1035', 0, DATEADD(MINUTE, 6, DATEADD(HOUR, 0, DATEADD(DAY, -36, GETDATE())))),
(1139, 'TIX-MEGA-1058-0', 1058, N'Hoàng Linh', 'mega_req_58@gmail.com', 'TIX-MEGA-1058-0|E1079|1239', 0, DATEADD(MINUTE, 31, DATEADD(HOUR, 19, DATEADD(DAY, -34, GETDATE())))),
(1140, 'TIX-MEGA-1058-1', 1058, N'Hoàng Linh', 'mega_req_58@gmail.com', 'TIX-MEGA-1058-1|E1079|1239', 0, DATEADD(MINUTE, 31, DATEADD(HOUR, 19, DATEADD(DAY, -34, GETDATE())))),
(1141, 'TIX-MEGA-1059-0', 1059, N'Bùi Phong', 'mega_req_59@gmail.com', 'TIX-MEGA-1059-0|E1011|1034', 0, DATEADD(MINUTE, 15, DATEADD(HOUR, 18, DATEADD(DAY, 0, GETDATE())))),
(1142, 'TIX-MEGA-1059-1', 1059, N'Bùi Phong', 'mega_req_59@gmail.com', 'TIX-MEGA-1059-1|E1011|1034', 0, DATEADD(MINUTE, 15, DATEADD(HOUR, 18, DATEADD(DAY, 0, GETDATE())))),
(1143, 'TIX-MEGA-1059-2', 1059, N'Bùi Phong', 'mega_req_59@gmail.com', 'TIX-MEGA-1059-2|E1011|1034', 0, DATEADD(MINUTE, 15, DATEADD(HOUR, 18, DATEADD(DAY, 0, GETDATE())))),
(1144, 'TIX-MEGA-1060-0', 1060, N'Nguyễn Bảo', 'mega_req_60@gmail.com', 'TIX-MEGA-1060-0|E1068|1204', 0, DATEADD(MINUTE, 32, DATEADD(HOUR, 18, DATEADD(DAY, -52, GETDATE())))),
(1145, 'TIX-MEGA-1060-1', 1060, N'Nguyễn Bảo', 'mega_req_60@gmail.com', 'TIX-MEGA-1060-1|E1068|1204', 1, DATEADD(MINUTE, 32, DATEADD(HOUR, 18, DATEADD(DAY, -52, GETDATE())))),
(1146, 'TIX-MEGA-1060-2', 1060, N'Nguyễn Bảo', 'mega_req_60@gmail.com', 'TIX-MEGA-1060-2|E1068|1204', 0, DATEADD(MINUTE, 32, DATEADD(HOUR, 18, DATEADD(DAY, -52, GETDATE())))),
(1147, 'TIX-MEGA-1061-0', 1061, N'Nguyễn Lan', 'mega_req_61@gmail.com', 'TIX-MEGA-1061-0|E1034|1102', 0, DATEADD(MINUTE, 0, DATEADD(HOUR, 18, DATEADD(DAY, -52, GETDATE())))),
(1148, 'TIX-MEGA-1061-1', 1061, N'Nguyễn Lan', 'mega_req_61@gmail.com', 'TIX-MEGA-1061-1|E1034|1102', 0, DATEADD(MINUTE, 0, DATEADD(HOUR, 18, DATEADD(DAY, -52, GETDATE())))),
(1149, 'TIX-MEGA-1061-2', 1061, N'Nguyễn Lan', 'mega_req_61@gmail.com', 'TIX-MEGA-1061-2|E1034|1102', 0, DATEADD(MINUTE, 0, DATEADD(HOUR, 18, DATEADD(DAY, -52, GETDATE())))),
(1150, 'TIX-MEGA-1061-3', 1061, N'Nguyễn Lan', 'mega_req_61@gmail.com', 'TIX-MEGA-1061-3|E1034|1102', 0, DATEADD(MINUTE, 0, DATEADD(HOUR, 18, DATEADD(DAY, -52, GETDATE())))),
(1151, 'TIX-MEGA-1062-0', 1062, N'Vũ Anh', 'mega_req_62@gmail.com', 'TIX-MEGA-1062-0|E1057|1171', 0, DATEADD(MINUTE, 38, DATEADD(HOUR, 2, DATEADD(DAY, -11, GETDATE())))),
(1152, 'TIX-MEGA-1062-1', 1062, N'Vũ Anh', 'mega_req_62@gmail.com', 'TIX-MEGA-1062-1|E1057|1171', 0, DATEADD(MINUTE, 38, DATEADD(HOUR, 2, DATEADD(DAY, -11, GETDATE())))),
(1153, 'TIX-MEGA-1062-2', 1062, N'Vũ Anh', 'mega_req_62@gmail.com', 'TIX-MEGA-1062-2|E1057|1171', 0, DATEADD(MINUTE, 38, DATEADD(HOUR, 2, DATEADD(DAY, -11, GETDATE())))),
(1154, 'TIX-MEGA-1063-0', 1063, N'Huỳnh Linh', 'mega_req_63@gmail.com', 'TIX-MEGA-1063-0|E1084|1254', 0, DATEADD(MINUTE, 41, DATEADD(HOUR, 3, DATEADD(DAY, -47, GETDATE())))),
(1155, 'TIX-MEGA-1063-1', 1063, N'Huỳnh Linh', 'mega_req_63@gmail.com', 'TIX-MEGA-1063-1|E1084|1254', 0, DATEADD(MINUTE, 41, DATEADD(HOUR, 3, DATEADD(DAY, -47, GETDATE())))),
(1156, 'TIX-MEGA-1063-2', 1063, N'Huỳnh Linh', 'mega_req_63@gmail.com', 'TIX-MEGA-1063-2|E1084|1254', 0, DATEADD(MINUTE, 41, DATEADD(HOUR, 3, DATEADD(DAY, -47, GETDATE())))),
(1157, 'TIX-MEGA-1063-3', 1063, N'Huỳnh Linh', 'mega_req_63@gmail.com', 'TIX-MEGA-1063-3|E1084|1254', 0, DATEADD(MINUTE, 41, DATEADD(HOUR, 3, DATEADD(DAY, -47, GETDATE())))),
(1158, 'TIX-MEGA-1064-0', 1064, N'Bùi Tâm', 'mega_req_64@gmail.com', 'TIX-MEGA-1064-0|E1051|1154', 0, DATEADD(MINUTE, 27, DATEADD(HOUR, 8, DATEADD(DAY, -22, GETDATE())))),
(1159, 'TIX-MEGA-1064-1', 1064, N'Bùi Tâm', 'mega_req_64@gmail.com', 'TIX-MEGA-1064-1|E1051|1154', 0, DATEADD(MINUTE, 27, DATEADD(HOUR, 8, DATEADD(DAY, -22, GETDATE())))),
(1160, 'TIX-MEGA-1064-2', 1064, N'Bùi Tâm', 'mega_req_64@gmail.com', 'TIX-MEGA-1064-2|E1051|1154', 0, DATEADD(MINUTE, 27, DATEADD(HOUR, 8, DATEADD(DAY, -22, GETDATE())))),
(1161, 'TIX-MEGA-1064-3', 1064, N'Bùi Tâm', 'mega_req_64@gmail.com', 'TIX-MEGA-1064-3|E1051|1154', 1, DATEADD(MINUTE, 27, DATEADD(HOUR, 8, DATEADD(DAY, -22, GETDATE())))),
(1162, 'TIX-MEGA-1065-0', 1065, N'Trần Trang', 'mega_req_65@gmail.com', 'TIX-MEGA-1065-0|E1037|1112', 0, DATEADD(MINUTE, 53, DATEADD(HOUR, 10, DATEADD(DAY, -22, GETDATE())))),
(1163, 'TIX-MEGA-1065-1', 1065, N'Trần Trang', 'mega_req_65@gmail.com', 'TIX-MEGA-1065-1|E1037|1112', 0, DATEADD(MINUTE, 53, DATEADD(HOUR, 10, DATEADD(DAY, -22, GETDATE())))),
(1164, 'TIX-MEGA-1065-2', 1065, N'Trần Trang', 'mega_req_65@gmail.com', 'TIX-MEGA-1065-2|E1037|1112', 0, DATEADD(MINUTE, 53, DATEADD(HOUR, 10, DATEADD(DAY, -22, GETDATE())))),
(1165, 'TIX-MEGA-1066-0', 1066, N'Nguyễn Anh', 'mega_req_66@gmail.com', 'TIX-MEGA-1066-0|E1073|1221', 0, DATEADD(MINUTE, 50, DATEADD(HOUR, 22, DATEADD(DAY, -53, GETDATE())))),
(1166, 'TIX-MEGA-1066-1', 1066, N'Nguyễn Anh', 'mega_req_66@gmail.com', 'TIX-MEGA-1066-1|E1073|1221', 0, DATEADD(MINUTE, 50, DATEADD(HOUR, 22, DATEADD(DAY, -53, GETDATE())))),
(1167, 'TIX-MEGA-1066-2', 1066, N'Nguyễn Anh', 'mega_req_66@gmail.com', 'TIX-MEGA-1066-2|E1073|1221', 0, DATEADD(MINUTE, 50, DATEADD(HOUR, 22, DATEADD(DAY, -53, GETDATE())))),
(1168, 'TIX-MEGA-1067-0', 1067, N'Vũ Anh', 'mega_req_67@gmail.com', 'TIX-MEGA-1067-0|E1015|1045', 1, DATEADD(MINUTE, 29, DATEADD(HOUR, 12, DATEADD(DAY, -2, GETDATE())))),
(1169, 'TIX-MEGA-1067-1', 1067, N'Vũ Anh', 'mega_req_67@gmail.com', 'TIX-MEGA-1067-1|E1015|1045', 1, DATEADD(MINUTE, 29, DATEADD(HOUR, 12, DATEADD(DAY, -2, GETDATE())))),
(1170, 'TIX-MEGA-1067-2', 1067, N'Vũ Anh', 'mega_req_67@gmail.com', 'TIX-MEGA-1067-2|E1015|1045', 0, DATEADD(MINUTE, 29, DATEADD(HOUR, 12, DATEADD(DAY, -2, GETDATE())))),
(1171, 'TIX-MEGA-1067-3', 1067, N'Vũ Anh', 'mega_req_67@gmail.com', 'TIX-MEGA-1067-3|E1015|1045', 0, DATEADD(MINUTE, 29, DATEADD(HOUR, 12, DATEADD(DAY, -2, GETDATE())))),
(1172, 'TIX-MEGA-1068-0', 1068, N'Phạm Tâm', 'mega_req_68@gmail.com', 'TIX-MEGA-1068-0|E1039|1118', 0, DATEADD(MINUTE, 54, DATEADD(HOUR, 13, DATEADD(DAY, -34, GETDATE())))),
(1173, 'TIX-MEGA-1068-1', 1068, N'Phạm Tâm', 'mega_req_68@gmail.com', 'TIX-MEGA-1068-1|E1039|1118', 0, DATEADD(MINUTE, 54, DATEADD(HOUR, 13, DATEADD(DAY, -34, GETDATE())))),
(1174, 'TIX-MEGA-1069-0', 1069, N'Đặng Vân', 'mega_req_69@gmail.com', 'TIX-MEGA-1069-0|E1073|1221', 0, DATEADD(MINUTE, 21, DATEADD(HOUR, 18, DATEADD(DAY, -18, GETDATE())))),
(1175, 'TIX-MEGA-1069-1', 1069, N'Đặng Vân', 'mega_req_69@gmail.com', 'TIX-MEGA-1069-1|E1073|1221', 0, DATEADD(MINUTE, 21, DATEADD(HOUR, 18, DATEADD(DAY, -18, GETDATE())))),
(1176, 'TIX-MEGA-1069-2', 1069, N'Đặng Vân', 'mega_req_69@gmail.com', 'TIX-MEGA-1069-2|E1073|1221', 0, DATEADD(MINUTE, 21, DATEADD(HOUR, 18, DATEADD(DAY, -18, GETDATE())))),
(1177, 'TIX-MEGA-1069-3', 1069, N'Đặng Vân', 'mega_req_69@gmail.com', 'TIX-MEGA-1069-3|E1073|1221', 0, DATEADD(MINUTE, 21, DATEADD(HOUR, 18, DATEADD(DAY, -18, GETDATE())))),
(1178, 'TIX-MEGA-1070-0', 1070, N'Vũ Khoa', 'mega_req_70@gmail.com', 'TIX-MEGA-1070-0|E1079|1238', 0, DATEADD(MINUTE, 10, DATEADD(HOUR, 22, DATEADD(DAY, -10, GETDATE())))),
(1179, 'TIX-MEGA-1071-0', 1071, N'Nguyễn Thu', 'mega_req_71@gmail.com', 'TIX-MEGA-1071-0|E1066|1199', 0, DATEADD(MINUTE, 37, DATEADD(HOUR, 3, DATEADD(DAY, -37, GETDATE())))),
(1180, 'TIX-MEGA-1071-1', 1071, N'Nguyễn Thu', 'mega_req_71@gmail.com', 'TIX-MEGA-1071-1|E1066|1199', 0, DATEADD(MINUTE, 37, DATEADD(HOUR, 3, DATEADD(DAY, -37, GETDATE())))),
(1181, 'TIX-MEGA-1072-0', 1072, N'Lê Anh', 'mega_req_72@gmail.com', 'TIX-MEGA-1072-0|E1007|1022', 0, DATEADD(MINUTE, 23, DATEADD(HOUR, 3, DATEADD(DAY, -22, GETDATE())))),
(1182, 'TIX-MEGA-1073-0', 1073, N'Nguyễn Tâm', 'mega_req_73@gmail.com', 'TIX-MEGA-1073-0|E1041|1125', 0, DATEADD(MINUTE, 35, DATEADD(HOUR, 17, DATEADD(DAY, -4, GETDATE())))),
(1183, 'TIX-MEGA-1073-1', 1073, N'Nguyễn Tâm', 'mega_req_73@gmail.com', 'TIX-MEGA-1073-1|E1041|1125', 0, DATEADD(MINUTE, 35, DATEADD(HOUR, 17, DATEADD(DAY, -4, GETDATE())))),
(1184, 'TIX-MEGA-1073-2', 1073, N'Nguyễn Tâm', 'mega_req_73@gmail.com', 'TIX-MEGA-1073-2|E1041|1125', 0, DATEADD(MINUTE, 35, DATEADD(HOUR, 17, DATEADD(DAY, -4, GETDATE())))),
(1185, 'TIX-MEGA-1073-3', 1073, N'Nguyễn Tâm', 'mega_req_73@gmail.com', 'TIX-MEGA-1073-3|E1041|1125', 0, DATEADD(MINUTE, 35, DATEADD(HOUR, 17, DATEADD(DAY, -4, GETDATE())))),
(1186, 'TIX-MEGA-1074-0', 1074, N'Hoàng Lan', 'mega_req_74@gmail.com', 'TIX-MEGA-1074-0|E1092|1276', 0, DATEADD(MINUTE, 49, DATEADD(HOUR, 20, DATEADD(DAY, -31, GETDATE())))),
(1187, 'TIX-MEGA-1074-1', 1074, N'Hoàng Lan', 'mega_req_74@gmail.com', 'TIX-MEGA-1074-1|E1092|1276', 0, DATEADD(MINUTE, 49, DATEADD(HOUR, 20, DATEADD(DAY, -31, GETDATE())))),
(1188, 'TIX-MEGA-1075-0', 1075, N'Đỗ Bảo', 'mega_req_75@gmail.com', 'TIX-MEGA-1075-0|E1025|1075', 0, DATEADD(MINUTE, 55, DATEADD(HOUR, 16, DATEADD(DAY, -18, GETDATE())))),
(1189, 'TIX-MEGA-1075-1', 1075, N'Đỗ Bảo', 'mega_req_75@gmail.com', 'TIX-MEGA-1075-1|E1025|1075', 0, DATEADD(MINUTE, 55, DATEADD(HOUR, 16, DATEADD(DAY, -18, GETDATE())))),
(1190, 'TIX-MEGA-1076-0', 1076, N'Nguyễn Minh', 'mega_req_76@gmail.com', 'TIX-MEGA-1076-0|E1087|1263', 0, DATEADD(MINUTE, 47, DATEADD(HOUR, 14, DATEADD(DAY, -8, GETDATE())))),
(1191, 'TIX-MEGA-1076-1', 1076, N'Nguyễn Minh', 'mega_req_76@gmail.com', 'TIX-MEGA-1076-1|E1087|1263', 0, DATEADD(MINUTE, 47, DATEADD(HOUR, 14, DATEADD(DAY, -8, GETDATE())))),
(1192, 'TIX-MEGA-1077-0', 1077, N'Bùi Thành', 'mega_req_77@gmail.com', 'TIX-MEGA-1077-0|E1096|1288', 0, DATEADD(MINUTE, 1, DATEADD(HOUR, 23, DATEADD(DAY, -36, GETDATE())))),
(1193, 'TIX-MEGA-1077-1', 1077, N'Bùi Thành', 'mega_req_77@gmail.com', 'TIX-MEGA-1077-1|E1096|1288', 0, DATEADD(MINUTE, 1, DATEADD(HOUR, 23, DATEADD(DAY, -36, GETDATE())))),
(1194, 'TIX-MEGA-1078-0', 1078, N'Trần Linh', 'mega_req_78@gmail.com', 'TIX-MEGA-1078-0|E1045|1135', 0, DATEADD(MINUTE, 8, DATEADD(HOUR, 9, DATEADD(DAY, -43, GETDATE())))),
(1195, 'TIX-MEGA-1079-0', 1079, N'Nguyễn Vân', 'mega_req_79@gmail.com', 'TIX-MEGA-1079-0|E1016|1048', 0, DATEADD(MINUTE, 59, DATEADD(HOUR, 0, DATEADD(DAY, -55, GETDATE())))),
(1196, 'TIX-MEGA-1079-1', 1079, N'Nguyễn Vân', 'mega_req_79@gmail.com', 'TIX-MEGA-1079-1|E1016|1048', 0, DATEADD(MINUTE, 59, DATEADD(HOUR, 0, DATEADD(DAY, -55, GETDATE())))),
(1197, 'TIX-MEGA-1080-0', 1080, N'Đỗ Khoa', 'mega_req_80@gmail.com', 'TIX-MEGA-1080-0|E1002|1008', 0, DATEADD(MINUTE, 19, DATEADD(HOUR, 9, DATEADD(DAY, -40, GETDATE())))),
(1198, 'TIX-MEGA-1080-1', 1080, N'Đỗ Khoa', 'mega_req_80@gmail.com', 'TIX-MEGA-1080-1|E1002|1008', 0, DATEADD(MINUTE, 19, DATEADD(HOUR, 9, DATEADD(DAY, -40, GETDATE())))),
(1199, 'TIX-MEGA-1080-2', 1080, N'Đỗ Khoa', 'mega_req_80@gmail.com', 'TIX-MEGA-1080-2|E1002|1008', 0, DATEADD(MINUTE, 19, DATEADD(HOUR, 9, DATEADD(DAY, -40, GETDATE())))),
(1200, 'TIX-MEGA-1080-3', 1080, N'Đỗ Khoa', 'mega_req_80@gmail.com', 'TIX-MEGA-1080-3|E1002|1008', 0, DATEADD(MINUTE, 19, DATEADD(HOUR, 9, DATEADD(DAY, -40, GETDATE()))));
INSERT INTO Tickets (ticket_id, ticket_code, order_item_id, attendee_name, attendee_email, qr_code, is_checked_in, created_at) VALUES
(1201, 'TIX-MEGA-1081-0', 1081, N'Đỗ Trang', 'mega_req_81@gmail.com', 'TIX-MEGA-1081-0|E1082|1247', 1, DATEADD(MINUTE, 43, DATEADD(HOUR, 3, DATEADD(DAY, -23, GETDATE())))),
(1202, 'TIX-MEGA-1082-0', 1082, N'Đặng Linh', 'mega_req_82@gmail.com', 'TIX-MEGA-1082-0|E1047|1142', 0, DATEADD(MINUTE, 7, DATEADD(HOUR, 5, DATEADD(DAY, -42, GETDATE())))),
(1203, 'TIX-MEGA-1083-0', 1083, N'Hoàng Minh', 'mega_req_83@gmail.com', 'TIX-MEGA-1083-0|E1040|1121', 1, DATEADD(MINUTE, 35, DATEADD(HOUR, 14, DATEADD(DAY, -45, GETDATE())))),
(1204, 'TIX-MEGA-1083-1', 1083, N'Hoàng Minh', 'mega_req_83@gmail.com', 'TIX-MEGA-1083-1|E1040|1121', 0, DATEADD(MINUTE, 35, DATEADD(HOUR, 14, DATEADD(DAY, -45, GETDATE())))),
(1205, 'TIX-MEGA-1083-2', 1083, N'Hoàng Minh', 'mega_req_83@gmail.com', 'TIX-MEGA-1083-2|E1040|1121', 0, DATEADD(MINUTE, 35, DATEADD(HOUR, 14, DATEADD(DAY, -45, GETDATE())))),
(1206, 'TIX-MEGA-1083-3', 1083, N'Hoàng Minh', 'mega_req_83@gmail.com', 'TIX-MEGA-1083-3|E1040|1121', 1, DATEADD(MINUTE, 35, DATEADD(HOUR, 14, DATEADD(DAY, -45, GETDATE())))),
(1207, 'TIX-MEGA-1084-0', 1084, N'Nguyễn Tâm', 'mega_req_84@gmail.com', 'TIX-MEGA-1084-0|E1094|1284', 0, DATEADD(MINUTE, 28, DATEADD(HOUR, 11, DATEADD(DAY, -15, GETDATE())))),
(1208, 'TIX-MEGA-1085-0', 1085, N'Vũ Linh', 'mega_req_85@gmail.com', 'TIX-MEGA-1085-0|E1081|1245', 0, DATEADD(MINUTE, 43, DATEADD(HOUR, 23, DATEADD(DAY, -12, GETDATE())))),
(1209, 'TIX-MEGA-1085-1', 1085, N'Vũ Linh', 'mega_req_85@gmail.com', 'TIX-MEGA-1085-1|E1081|1245', 0, DATEADD(MINUTE, 43, DATEADD(HOUR, 23, DATEADD(DAY, -12, GETDATE())))),
(1210, 'TIX-MEGA-1085-2', 1085, N'Vũ Linh', 'mega_req_85@gmail.com', 'TIX-MEGA-1085-2|E1081|1245', 0, DATEADD(MINUTE, 43, DATEADD(HOUR, 23, DATEADD(DAY, -12, GETDATE())))),
(1211, 'TIX-MEGA-1085-3', 1085, N'Vũ Linh', 'mega_req_85@gmail.com', 'TIX-MEGA-1085-3|E1081|1245', 0, DATEADD(MINUTE, 43, DATEADD(HOUR, 23, DATEADD(DAY, -12, GETDATE())))),
(1212, 'TIX-MEGA-1086-0', 1086, N'Lê Minh', 'mega_req_86@gmail.com', 'TIX-MEGA-1086-0|E1057|1173', 1, DATEADD(MINUTE, 36, DATEADD(HOUR, 19, DATEADD(DAY, -13, GETDATE())))),
(1213, 'TIX-MEGA-1087-0', 1087, N'Phạm Linh', 'mega_req_87@gmail.com', 'TIX-MEGA-1087-0|E1082|1247', 0, DATEADD(MINUTE, 24, DATEADD(HOUR, 7, DATEADD(DAY, -21, GETDATE())))),
(1214, 'TIX-MEGA-1087-1', 1087, N'Phạm Linh', 'mega_req_87@gmail.com', 'TIX-MEGA-1087-1|E1082|1247', 0, DATEADD(MINUTE, 24, DATEADD(HOUR, 7, DATEADD(DAY, -21, GETDATE())))),
(1215, 'TIX-MEGA-1087-2', 1087, N'Phạm Linh', 'mega_req_87@gmail.com', 'TIX-MEGA-1087-2|E1082|1247', 0, DATEADD(MINUTE, 24, DATEADD(HOUR, 7, DATEADD(DAY, -21, GETDATE())))),
(1216, 'TIX-MEGA-1087-3', 1087, N'Phạm Linh', 'mega_req_87@gmail.com', 'TIX-MEGA-1087-3|E1082|1247', 0, DATEADD(MINUTE, 24, DATEADD(HOUR, 7, DATEADD(DAY, -21, GETDATE())))),
(1217, 'TIX-MEGA-1088-0', 1088, N'Huỳnh Bảo', 'mega_req_88@gmail.com', 'TIX-MEGA-1088-0|E1079|1238', 0, DATEADD(MINUTE, 26, DATEADD(HOUR, 21, DATEADD(DAY, -46, GETDATE())))),
(1218, 'TIX-MEGA-1089-0', 1089, N'Trần Bảo', 'mega_req_89@gmail.com', 'TIX-MEGA-1089-0|E1036|1109', 0, DATEADD(MINUTE, 31, DATEADD(HOUR, 1, DATEADD(DAY, -3, GETDATE())))),
(1219, 'TIX-MEGA-1090-0', 1090, N'Đặng Minh', 'mega_req_90@gmail.com', 'TIX-MEGA-1090-0|E1004|1013', 0, DATEADD(MINUTE, 9, DATEADD(HOUR, 23, DATEADD(DAY, -29, GETDATE())))),
(1220, 'TIX-MEGA-1090-1', 1090, N'Đặng Minh', 'mega_req_90@gmail.com', 'TIX-MEGA-1090-1|E1004|1013', 0, DATEADD(MINUTE, 9, DATEADD(HOUR, 23, DATEADD(DAY, -29, GETDATE())))),
(1221, 'TIX-MEGA-1091-0', 1091, N'Trần Lan', 'mega_req_91@gmail.com', 'TIX-MEGA-1091-0|E1053|1161', 0, DATEADD(MINUTE, 58, DATEADD(HOUR, 10, DATEADD(DAY, 0, GETDATE())))),
(1222, 'TIX-MEGA-1091-1', 1091, N'Trần Lan', 'mega_req_91@gmail.com', 'TIX-MEGA-1091-1|E1053|1161', 0, DATEADD(MINUTE, 58, DATEADD(HOUR, 10, DATEADD(DAY, 0, GETDATE())))),
(1223, 'TIX-MEGA-1091-2', 1091, N'Trần Lan', 'mega_req_91@gmail.com', 'TIX-MEGA-1091-2|E1053|1161', 0, DATEADD(MINUTE, 58, DATEADD(HOUR, 10, DATEADD(DAY, 0, GETDATE())))),
(1224, 'TIX-MEGA-1092-0', 1092, N'Bùi Bảo', 'mega_req_92@gmail.com', 'TIX-MEGA-1092-0|E1060|1181', 0, DATEADD(MINUTE, 34, DATEADD(HOUR, 2, DATEADD(DAY, -31, GETDATE())))),
(1225, 'TIX-MEGA-1093-0', 1093, N'Huỳnh Thu', 'mega_req_93@gmail.com', 'TIX-MEGA-1093-0|E1006|1019', 0, DATEADD(MINUTE, 57, DATEADD(HOUR, 11, DATEADD(DAY, -2, GETDATE())))),
(1226, 'TIX-MEGA-1093-1', 1093, N'Huỳnh Thu', 'mega_req_93@gmail.com', 'TIX-MEGA-1093-1|E1006|1019', 0, DATEADD(MINUTE, 57, DATEADD(HOUR, 11, DATEADD(DAY, -2, GETDATE())))),
(1227, 'TIX-MEGA-1093-2', 1093, N'Huỳnh Thu', 'mega_req_93@gmail.com', 'TIX-MEGA-1093-2|E1006|1019', 0, DATEADD(MINUTE, 57, DATEADD(HOUR, 11, DATEADD(DAY, -2, GETDATE())))),
(1228, 'TIX-MEGA-1093-3', 1093, N'Huỳnh Thu', 'mega_req_93@gmail.com', 'TIX-MEGA-1093-3|E1006|1019', 0, DATEADD(MINUTE, 57, DATEADD(HOUR, 11, DATEADD(DAY, -2, GETDATE())))),
(1229, 'TIX-MEGA-1094-0', 1094, N'Vũ Thành', 'mega_req_94@gmail.com', 'TIX-MEGA-1094-0|E1059|1177', 0, DATEADD(MINUTE, 36, DATEADD(HOUR, 3, DATEADD(DAY, -41, GETDATE())))),
(1230, 'TIX-MEGA-1094-1', 1094, N'Vũ Thành', 'mega_req_94@gmail.com', 'TIX-MEGA-1094-1|E1059|1177', 0, DATEADD(MINUTE, 36, DATEADD(HOUR, 3, DATEADD(DAY, -41, GETDATE())))),
(1231, 'TIX-MEGA-1094-2', 1094, N'Vũ Thành', 'mega_req_94@gmail.com', 'TIX-MEGA-1094-2|E1059|1177', 0, DATEADD(MINUTE, 36, DATEADD(HOUR, 3, DATEADD(DAY, -41, GETDATE())))),
(1232, 'TIX-MEGA-1095-0', 1095, N'Huỳnh Phong', 'mega_req_95@gmail.com', 'TIX-MEGA-1095-0|E1041|1123', 0, DATEADD(MINUTE, 7, DATEADD(HOUR, 13, DATEADD(DAY, -18, GETDATE())))),
(1233, 'TIX-MEGA-1095-1', 1095, N'Huỳnh Phong', 'mega_req_95@gmail.com', 'TIX-MEGA-1095-1|E1041|1123', 0, DATEADD(MINUTE, 7, DATEADD(HOUR, 13, DATEADD(DAY, -18, GETDATE())))),
(1234, 'TIX-MEGA-1095-2', 1095, N'Huỳnh Phong', 'mega_req_95@gmail.com', 'TIX-MEGA-1095-2|E1041|1123', 0, DATEADD(MINUTE, 7, DATEADD(HOUR, 13, DATEADD(DAY, -18, GETDATE())))),
(1235, 'TIX-MEGA-1096-0', 1096, N'Lê Thu', 'mega_req_96@gmail.com', 'TIX-MEGA-1096-0|E1085|1255', 1, DATEADD(MINUTE, 25, DATEADD(HOUR, 14, DATEADD(DAY, -37, GETDATE())))),
(1236, 'TIX-MEGA-1097-0', 1097, N'Đặng Thành', 'mega_req_97@gmail.com', 'TIX-MEGA-1097-0|E1083|1250', 0, DATEADD(MINUTE, 17, DATEADD(HOUR, 7, DATEADD(DAY, -1, GETDATE())))),
(1237, 'TIX-MEGA-1098-0', 1098, N'Đặng Hải', 'mega_req_98@gmail.com', 'TIX-MEGA-1098-0|E1035|1107', 0, DATEADD(MINUTE, 44, DATEADD(HOUR, 10, DATEADD(DAY, -19, GETDATE())))),
(1238, 'TIX-MEGA-1098-1', 1098, N'Đặng Hải', 'mega_req_98@gmail.com', 'TIX-MEGA-1098-1|E1035|1107', 0, DATEADD(MINUTE, 44, DATEADD(HOUR, 10, DATEADD(DAY, -19, GETDATE())))),
(1239, 'TIX-MEGA-1098-2', 1098, N'Đặng Hải', 'mega_req_98@gmail.com', 'TIX-MEGA-1098-2|E1035|1107', 0, DATEADD(MINUTE, 44, DATEADD(HOUR, 10, DATEADD(DAY, -19, GETDATE())))),
(1240, 'TIX-MEGA-1098-3', 1098, N'Đặng Hải', 'mega_req_98@gmail.com', 'TIX-MEGA-1098-3|E1035|1107', 0, DATEADD(MINUTE, 44, DATEADD(HOUR, 10, DATEADD(DAY, -19, GETDATE())))),
(1241, 'TIX-MEGA-1099-0', 1099, N'Phạm Thu', 'mega_req_99@gmail.com', 'TIX-MEGA-1099-0|E1056|1170', 0, DATEADD(MINUTE, 56, DATEADD(HOUR, 20, DATEADD(DAY, -48, GETDATE())))),
(1242, 'TIX-MEGA-1099-1', 1099, N'Phạm Thu', 'mega_req_99@gmail.com', 'TIX-MEGA-1099-1|E1056|1170', 0, DATEADD(MINUTE, 56, DATEADD(HOUR, 20, DATEADD(DAY, -48, GETDATE())))),
(1243, 'TIX-MEGA-1100-0', 1100, N'Trần Minh', 'mega_req_100@gmail.com', 'TIX-MEGA-1100-0|E1093|1279', 0, DATEADD(MINUTE, 28, DATEADD(HOUR, 22, DATEADD(DAY, -11, GETDATE())))),
(1244, 'TIX-MEGA-1100-1', 1100, N'Trần Minh', 'mega_req_100@gmail.com', 'TIX-MEGA-1100-1|E1093|1279', 0, DATEADD(MINUTE, 28, DATEADD(HOUR, 22, DATEADD(DAY, -11, GETDATE())))),
(1245, 'TIX-MEGA-1101-0', 1101, N'Nguyễn Hải', 'mega_req_101@gmail.com', 'TIX-MEGA-1101-0|E1047|1141', 0, DATEADD(MINUTE, 50, DATEADD(HOUR, 18, DATEADD(DAY, -4, GETDATE())))),
(1246, 'TIX-MEGA-1101-1', 1101, N'Nguyễn Hải', 'mega_req_101@gmail.com', 'TIX-MEGA-1101-1|E1047|1141', 0, DATEADD(MINUTE, 50, DATEADD(HOUR, 18, DATEADD(DAY, -4, GETDATE())))),
(1247, 'TIX-MEGA-1101-2', 1101, N'Nguyễn Hải', 'mega_req_101@gmail.com', 'TIX-MEGA-1101-2|E1047|1141', 0, DATEADD(MINUTE, 50, DATEADD(HOUR, 18, DATEADD(DAY, -4, GETDATE())))),
(1248, 'TIX-MEGA-1102-0', 1102, N'Bùi Tâm', 'mega_req_102@gmail.com', 'TIX-MEGA-1102-0|E1009|1028', 0, DATEADD(MINUTE, 11, DATEADD(HOUR, 11, DATEADD(DAY, -6, GETDATE())))),
(1249, 'TIX-MEGA-1102-1', 1102, N'Bùi Tâm', 'mega_req_102@gmail.com', 'TIX-MEGA-1102-1|E1009|1028', 0, DATEADD(MINUTE, 11, DATEADD(HOUR, 11, DATEADD(DAY, -6, GETDATE())))),
(1250, 'TIX-MEGA-1102-2', 1102, N'Bùi Tâm', 'mega_req_102@gmail.com', 'TIX-MEGA-1102-2|E1009|1028', 0, DATEADD(MINUTE, 11, DATEADD(HOUR, 11, DATEADD(DAY, -6, GETDATE())))),
(1251, 'TIX-MEGA-1102-3', 1102, N'Bùi Tâm', 'mega_req_102@gmail.com', 'TIX-MEGA-1102-3|E1009|1028', 0, DATEADD(MINUTE, 11, DATEADD(HOUR, 11, DATEADD(DAY, -6, GETDATE())))),
(1252, 'TIX-MEGA-1103-0', 1103, N'Nguyễn Vân', 'mega_req_103@gmail.com', 'TIX-MEGA-1103-0|E1043|1129', 0, DATEADD(MINUTE, 25, DATEADD(HOUR, 11, DATEADD(DAY, -24, GETDATE())))),
(1253, 'TIX-MEGA-1104-0', 1104, N'Hoàng Vân', 'mega_req_104@gmail.com', 'TIX-MEGA-1104-0|E1017|1053', 0, DATEADD(MINUTE, 28, DATEADD(HOUR, 17, DATEADD(DAY, -10, GETDATE())))),
(1254, 'TIX-MEGA-1104-1', 1104, N'Hoàng Vân', 'mega_req_104@gmail.com', 'TIX-MEGA-1104-1|E1017|1053', 0, DATEADD(MINUTE, 28, DATEADD(HOUR, 17, DATEADD(DAY, -10, GETDATE())))),
(1255, 'TIX-MEGA-1105-0', 1105, N'Hoàng Khoa', 'mega_req_105@gmail.com', 'TIX-MEGA-1105-0|E1060|1181', 0, DATEADD(MINUTE, 51, DATEADD(HOUR, 10, DATEADD(DAY, -34, GETDATE())))),
(1256, 'TIX-MEGA-1105-1', 1105, N'Hoàng Khoa', 'mega_req_105@gmail.com', 'TIX-MEGA-1105-1|E1060|1181', 0, DATEADD(MINUTE, 51, DATEADD(HOUR, 10, DATEADD(DAY, -34, GETDATE())))),
(1257, 'TIX-MEGA-1106-0', 1106, N'Huỳnh Trang', 'mega_req_106@gmail.com', 'TIX-MEGA-1106-0|E1061|1185', 1, DATEADD(MINUTE, 8, DATEADD(HOUR, 6, DATEADD(DAY, -36, GETDATE())))),
(1258, 'TIX-MEGA-1106-1', 1106, N'Huỳnh Trang', 'mega_req_106@gmail.com', 'TIX-MEGA-1106-1|E1061|1185', 0, DATEADD(MINUTE, 8, DATEADD(HOUR, 6, DATEADD(DAY, -36, GETDATE())))),
(1259, 'TIX-MEGA-1106-2', 1106, N'Huỳnh Trang', 'mega_req_106@gmail.com', 'TIX-MEGA-1106-2|E1061|1185', 0, DATEADD(MINUTE, 8, DATEADD(HOUR, 6, DATEADD(DAY, -36, GETDATE())))),
(1260, 'TIX-MEGA-1107-0', 1107, N'Đỗ Khoa', 'mega_req_107@gmail.com', 'TIX-MEGA-1107-0|E1018|1056', 0, DATEADD(MINUTE, 36, DATEADD(HOUR, 2, DATEADD(DAY, -10, GETDATE())))),
(1261, 'TIX-MEGA-1107-1', 1107, N'Đỗ Khoa', 'mega_req_107@gmail.com', 'TIX-MEGA-1107-1|E1018|1056', 0, DATEADD(MINUTE, 36, DATEADD(HOUR, 2, DATEADD(DAY, -10, GETDATE())))),
(1262, 'TIX-MEGA-1108-0', 1108, N'Huỳnh Bảo', 'mega_req_108@gmail.com', 'TIX-MEGA-1108-0|E1031|1095', 0, DATEADD(MINUTE, 9, DATEADD(HOUR, 2, DATEADD(DAY, -42, GETDATE())))),
(1263, 'TIX-MEGA-1108-1', 1108, N'Huỳnh Bảo', 'mega_req_108@gmail.com', 'TIX-MEGA-1108-1|E1031|1095', 0, DATEADD(MINUTE, 9, DATEADD(HOUR, 2, DATEADD(DAY, -42, GETDATE())))),
(1264, 'TIX-MEGA-1109-0', 1109, N'Đỗ Bảo', 'mega_req_109@gmail.com', 'TIX-MEGA-1109-0|E1070|1211', 0, DATEADD(MINUTE, 38, DATEADD(HOUR, 8, DATEADD(DAY, -46, GETDATE())))),
(1265, 'TIX-MEGA-1110-0', 1110, N'Hoàng Vân', 'mega_req_110@gmail.com', 'TIX-MEGA-1110-0|E1077|1231', 0, DATEADD(MINUTE, 57, DATEADD(HOUR, 2, DATEADD(DAY, -30, GETDATE())))),
(1266, 'TIX-MEGA-1111-0', 1111, N'Bùi Hùng', 'mega_req_111@gmail.com', 'TIX-MEGA-1111-0|E1003|1009', 0, DATEADD(MINUTE, 14, DATEADD(HOUR, 20, DATEADD(DAY, -29, GETDATE())))),
(1267, 'TIX-MEGA-1112-0', 1112, N'Đặng Khoa', 'mega_req_112@gmail.com', 'TIX-MEGA-1112-0|E1039|1117', 0, DATEADD(MINUTE, 59, DATEADD(HOUR, 15, DATEADD(DAY, -37, GETDATE())))),
(1268, 'TIX-MEGA-1112-1', 1112, N'Đặng Khoa', 'mega_req_112@gmail.com', 'TIX-MEGA-1112-1|E1039|1117', 0, DATEADD(MINUTE, 59, DATEADD(HOUR, 15, DATEADD(DAY, -37, GETDATE())))),
(1269, 'TIX-MEGA-1112-2', 1112, N'Đặng Khoa', 'mega_req_112@gmail.com', 'TIX-MEGA-1112-2|E1039|1117', 0, DATEADD(MINUTE, 59, DATEADD(HOUR, 15, DATEADD(DAY, -37, GETDATE())))),
(1270, 'TIX-MEGA-1113-0', 1113, N'Lê Tâm', 'mega_req_113@gmail.com', 'TIX-MEGA-1113-0|E1082|1247', 0, DATEADD(MINUTE, 24, DATEADD(HOUR, 3, DATEADD(DAY, -55, GETDATE())))),
(1271, 'TIX-MEGA-1113-1', 1113, N'Lê Tâm', 'mega_req_113@gmail.com', 'TIX-MEGA-1113-1|E1082|1247', 0, DATEADD(MINUTE, 24, DATEADD(HOUR, 3, DATEADD(DAY, -55, GETDATE())))),
(1272, 'TIX-MEGA-1113-2', 1113, N'Lê Tâm', 'mega_req_113@gmail.com', 'TIX-MEGA-1113-2|E1082|1247', 0, DATEADD(MINUTE, 24, DATEADD(HOUR, 3, DATEADD(DAY, -55, GETDATE())))),
(1273, 'TIX-MEGA-1113-3', 1113, N'Lê Tâm', 'mega_req_113@gmail.com', 'TIX-MEGA-1113-3|E1082|1247', 0, DATEADD(MINUTE, 24, DATEADD(HOUR, 3, DATEADD(DAY, -55, GETDATE())))),
(1274, 'TIX-MEGA-1114-0', 1114, N'Đặng Khoa', 'mega_req_114@gmail.com', 'TIX-MEGA-1114-0|E1025|1077', 0, DATEADD(MINUTE, 50, DATEADD(HOUR, 16, DATEADD(DAY, -19, GETDATE())))),
(1275, 'TIX-MEGA-1115-0', 1115, N'Lê Anh', 'mega_req_115@gmail.com', 'TIX-MEGA-1115-0|E1031|1095', 0, DATEADD(MINUTE, 35, DATEADD(HOUR, 16, DATEADD(DAY, -16, GETDATE())))),
(1276, 'TIX-MEGA-1115-1', 1115, N'Lê Anh', 'mega_req_115@gmail.com', 'TIX-MEGA-1115-1|E1031|1095', 0, DATEADD(MINUTE, 35, DATEADD(HOUR, 16, DATEADD(DAY, -16, GETDATE())))),
(1277, 'TIX-MEGA-1115-2', 1115, N'Lê Anh', 'mega_req_115@gmail.com', 'TIX-MEGA-1115-2|E1031|1095', 0, DATEADD(MINUTE, 35, DATEADD(HOUR, 16, DATEADD(DAY, -16, GETDATE())))),
(1278, 'TIX-MEGA-1115-3', 1115, N'Lê Anh', 'mega_req_115@gmail.com', 'TIX-MEGA-1115-3|E1031|1095', 0, DATEADD(MINUTE, 35, DATEADD(HOUR, 16, DATEADD(DAY, -16, GETDATE())))),
(1279, 'TIX-MEGA-1116-0', 1116, N'Đỗ Minh', 'mega_req_116@gmail.com', 'TIX-MEGA-1116-0|E1072|1218', 0, DATEADD(MINUTE, 43, DATEADD(HOUR, 4, DATEADD(DAY, -55, GETDATE())))),
(1280, 'TIX-MEGA-1116-1', 1116, N'Đỗ Minh', 'mega_req_116@gmail.com', 'TIX-MEGA-1116-1|E1072|1218', 0, DATEADD(MINUTE, 43, DATEADD(HOUR, 4, DATEADD(DAY, -55, GETDATE())))),
(1281, 'TIX-MEGA-1116-2', 1116, N'Đỗ Minh', 'mega_req_116@gmail.com', 'TIX-MEGA-1116-2|E1072|1218', 0, DATEADD(MINUTE, 43, DATEADD(HOUR, 4, DATEADD(DAY, -55, GETDATE())))),
(1282, 'TIX-MEGA-1116-3', 1116, N'Đỗ Minh', 'mega_req_116@gmail.com', 'TIX-MEGA-1116-3|E1072|1218', 0, DATEADD(MINUTE, 43, DATEADD(HOUR, 4, DATEADD(DAY, -55, GETDATE())))),
(1283, 'TIX-MEGA-1117-0', 1117, N'Trần Bảo', 'mega_req_117@gmail.com', 'TIX-MEGA-1117-0|E1061|1184', 0, DATEADD(MINUTE, 59, DATEADD(HOUR, 15, DATEADD(DAY, -31, GETDATE())))),
(1284, 'TIX-MEGA-1118-0', 1118, N'Phạm Linh', 'mega_req_118@gmail.com', 'TIX-MEGA-1118-0|E1042|1127', 1, DATEADD(MINUTE, 52, DATEADD(HOUR, 13, DATEADD(DAY, -15, GETDATE())))),
(1285, 'TIX-MEGA-1118-1', 1118, N'Phạm Linh', 'mega_req_118@gmail.com', 'TIX-MEGA-1118-1|E1042|1127', 1, DATEADD(MINUTE, 52, DATEADD(HOUR, 13, DATEADD(DAY, -15, GETDATE())))),
(1286, 'TIX-MEGA-1119-0', 1119, N'Đỗ Anh', 'mega_req_119@gmail.com', 'TIX-MEGA-1119-0|E1098|1295', 0, DATEADD(MINUTE, 49, DATEADD(HOUR, 5, DATEADD(DAY, -22, GETDATE())))),
(1287, 'TIX-MEGA-1119-1', 1119, N'Đỗ Anh', 'mega_req_119@gmail.com', 'TIX-MEGA-1119-1|E1098|1295', 0, DATEADD(MINUTE, 49, DATEADD(HOUR, 5, DATEADD(DAY, -22, GETDATE())))),
(1288, 'TIX-MEGA-1119-2', 1119, N'Đỗ Anh', 'mega_req_119@gmail.com', 'TIX-MEGA-1119-2|E1098|1295', 0, DATEADD(MINUTE, 49, DATEADD(HOUR, 5, DATEADD(DAY, -22, GETDATE())))),
(1289, 'TIX-MEGA-1120-0', 1120, N'Nguyễn Thu', 'mega_req_120@gmail.com', 'TIX-MEGA-1120-0|E1050|1151', 0, DATEADD(MINUTE, 12, DATEADD(HOUR, 13, DATEADD(DAY, -11, GETDATE())))),
(1290, 'TIX-MEGA-1120-1', 1120, N'Nguyễn Thu', 'mega_req_120@gmail.com', 'TIX-MEGA-1120-1|E1050|1151', 0, DATEADD(MINUTE, 12, DATEADD(HOUR, 13, DATEADD(DAY, -11, GETDATE())))),
(1291, 'TIX-MEGA-1120-2', 1120, N'Nguyễn Thu', 'mega_req_120@gmail.com', 'TIX-MEGA-1120-2|E1050|1151', 0, DATEADD(MINUTE, 12, DATEADD(HOUR, 13, DATEADD(DAY, -11, GETDATE())))),
(1292, 'TIX-MEGA-1120-3', 1120, N'Nguyễn Thu', 'mega_req_120@gmail.com', 'TIX-MEGA-1120-3|E1050|1151', 0, DATEADD(MINUTE, 12, DATEADD(HOUR, 13, DATEADD(DAY, -11, GETDATE())))),
(1293, 'TIX-MEGA-1121-0', 1121, N'Lê Tâm', 'mega_req_121@gmail.com', 'TIX-MEGA-1121-0|E1060|1182', 0, DATEADD(MINUTE, 26, DATEADD(HOUR, 23, DATEADD(DAY, -22, GETDATE())))),
(1294, 'TIX-MEGA-1122-0', 1122, N'Nguyễn Anh', 'mega_req_122@gmail.com', 'TIX-MEGA-1122-0|E1081|1244', 0, DATEADD(MINUTE, 23, DATEADD(HOUR, 7, DATEADD(DAY, -9, GETDATE())))),
(1295, 'TIX-MEGA-1122-1', 1122, N'Nguyễn Anh', 'mega_req_122@gmail.com', 'TIX-MEGA-1122-1|E1081|1244', 0, DATEADD(MINUTE, 23, DATEADD(HOUR, 7, DATEADD(DAY, -9, GETDATE())))),
(1296, 'TIX-MEGA-1122-2', 1122, N'Nguyễn Anh', 'mega_req_122@gmail.com', 'TIX-MEGA-1122-2|E1081|1244', 0, DATEADD(MINUTE, 23, DATEADD(HOUR, 7, DATEADD(DAY, -9, GETDATE())))),
(1297, 'TIX-MEGA-1123-0', 1123, N'Lê Hùng', 'mega_req_123@gmail.com', 'TIX-MEGA-1123-0|E1072|1218', 0, DATEADD(MINUTE, 49, DATEADD(HOUR, 16, DATEADD(DAY, -37, GETDATE())))),
(1298, 'TIX-MEGA-1124-0', 1124, N'Nguyễn Thu', 'mega_req_124@gmail.com', 'TIX-MEGA-1124-0|E1006|1018', 0, DATEADD(MINUTE, 34, DATEADD(HOUR, 0, DATEADD(DAY, -58, GETDATE())))),
(1299, 'TIX-MEGA-1125-0', 1125, N'Đỗ Lan', 'mega_req_125@gmail.com', 'TIX-MEGA-1125-0|E1012|1037', 0, DATEADD(MINUTE, 29, DATEADD(HOUR, 14, DATEADD(DAY, -52, GETDATE())))),
(1300, 'TIX-MEGA-1125-1', 1125, N'Đỗ Lan', 'mega_req_125@gmail.com', 'TIX-MEGA-1125-1|E1012|1037', 0, DATEADD(MINUTE, 29, DATEADD(HOUR, 14, DATEADD(DAY, -52, GETDATE())))),
(1301, 'TIX-MEGA-1125-2', 1125, N'Đỗ Lan', 'mega_req_125@gmail.com', 'TIX-MEGA-1125-2|E1012|1037', 0, DATEADD(MINUTE, 29, DATEADD(HOUR, 14, DATEADD(DAY, -52, GETDATE()))));
INSERT INTO Tickets (ticket_id, ticket_code, order_item_id, attendee_name, attendee_email, qr_code, is_checked_in, created_at) VALUES
(1302, 'TIX-MEGA-1126-0', 1126, N'Đặng Thu', 'mega_req_126@gmail.com', 'TIX-MEGA-1126-0|E1090|1272', 0, DATEADD(MINUTE, 59, DATEADD(HOUR, 13, DATEADD(DAY, -41, GETDATE())))),
(1303, 'TIX-MEGA-1126-1', 1126, N'Đặng Thu', 'mega_req_126@gmail.com', 'TIX-MEGA-1126-1|E1090|1272', 1, DATEADD(MINUTE, 59, DATEADD(HOUR, 13, DATEADD(DAY, -41, GETDATE())))),
(1304, 'TIX-MEGA-1126-2', 1126, N'Đặng Thu', 'mega_req_126@gmail.com', 'TIX-MEGA-1126-2|E1090|1272', 0, DATEADD(MINUTE, 59, DATEADD(HOUR, 13, DATEADD(DAY, -41, GETDATE())))),
(1305, 'TIX-MEGA-1127-0', 1127, N'Lê Lan', 'mega_req_127@gmail.com', 'TIX-MEGA-1127-0|E1045|1137', 0, DATEADD(MINUTE, 22, DATEADD(HOUR, 15, DATEADD(DAY, -49, GETDATE())))),
(1306, 'TIX-MEGA-1127-1', 1127, N'Lê Lan', 'mega_req_127@gmail.com', 'TIX-MEGA-1127-1|E1045|1137', 0, DATEADD(MINUTE, 22, DATEADD(HOUR, 15, DATEADD(DAY, -49, GETDATE())))),
(1307, 'TIX-MEGA-1127-2', 1127, N'Lê Lan', 'mega_req_127@gmail.com', 'TIX-MEGA-1127-2|E1045|1137', 0, DATEADD(MINUTE, 22, DATEADD(HOUR, 15, DATEADD(DAY, -49, GETDATE())))),
(1308, 'TIX-MEGA-1127-3', 1127, N'Lê Lan', 'mega_req_127@gmail.com', 'TIX-MEGA-1127-3|E1045|1137', 0, DATEADD(MINUTE, 22, DATEADD(HOUR, 15, DATEADD(DAY, -49, GETDATE())))),
(1309, 'TIX-MEGA-1128-0', 1128, N'Trần Thu', 'mega_req_128@gmail.com', 'TIX-MEGA-1128-0|E1044|1134', 0, DATEADD(MINUTE, 45, DATEADD(HOUR, 8, DATEADD(DAY, -40, GETDATE())))),
(1310, 'TIX-MEGA-1129-0', 1129, N'Trần Tâm', 'mega_req_129@gmail.com', 'TIX-MEGA-1129-0|E1095|1287', 0, DATEADD(MINUTE, 25, DATEADD(HOUR, 17, DATEADD(DAY, -22, GETDATE())))),
(1311, 'TIX-MEGA-1129-1', 1129, N'Trần Tâm', 'mega_req_129@gmail.com', 'TIX-MEGA-1129-1|E1095|1287', 0, DATEADD(MINUTE, 25, DATEADD(HOUR, 17, DATEADD(DAY, -22, GETDATE())))),
(1312, 'TIX-MEGA-1130-0', 1130, N'Vũ Bảo', 'mega_req_130@gmail.com', 'TIX-MEGA-1130-0|E1038|1116', 0, DATEADD(MINUTE, 41, DATEADD(HOUR, 9, DATEADD(DAY, -2, GETDATE())))),
(1313, 'TIX-MEGA-1131-0', 1131, N'Lê Kiên', 'mega_req_131@gmail.com', 'TIX-MEGA-1131-0|E1028|1085', 0, DATEADD(MINUTE, 26, DATEADD(HOUR, 20, DATEADD(DAY, -32, GETDATE())))),
(1314, 'TIX-MEGA-1131-1', 1131, N'Lê Kiên', 'mega_req_131@gmail.com', 'TIX-MEGA-1131-1|E1028|1085', 0, DATEADD(MINUTE, 26, DATEADD(HOUR, 20, DATEADD(DAY, -32, GETDATE())))),
(1315, 'TIX-MEGA-1131-2', 1131, N'Lê Kiên', 'mega_req_131@gmail.com', 'TIX-MEGA-1131-2|E1028|1085', 0, DATEADD(MINUTE, 26, DATEADD(HOUR, 20, DATEADD(DAY, -32, GETDATE())))),
(1316, 'TIX-MEGA-1131-3', 1131, N'Lê Kiên', 'mega_req_131@gmail.com', 'TIX-MEGA-1131-3|E1028|1085', 0, DATEADD(MINUTE, 26, DATEADD(HOUR, 20, DATEADD(DAY, -32, GETDATE())))),
(1317, 'TIX-MEGA-1132-0', 1132, N'Bùi Trang', 'mega_req_132@gmail.com', 'TIX-MEGA-1132-0|E1007|1023', 0, DATEADD(MINUTE, 59, DATEADD(HOUR, 9, DATEADD(DAY, -40, GETDATE())))),
(1318, 'TIX-MEGA-1132-1', 1132, N'Bùi Trang', 'mega_req_132@gmail.com', 'TIX-MEGA-1132-1|E1007|1023', 0, DATEADD(MINUTE, 59, DATEADD(HOUR, 9, DATEADD(DAY, -40, GETDATE())))),
(1319, 'TIX-MEGA-1132-2', 1132, N'Bùi Trang', 'mega_req_132@gmail.com', 'TIX-MEGA-1132-2|E1007|1023', 0, DATEADD(MINUTE, 59, DATEADD(HOUR, 9, DATEADD(DAY, -40, GETDATE())))),
(1320, 'TIX-MEGA-1132-3', 1132, N'Bùi Trang', 'mega_req_132@gmail.com', 'TIX-MEGA-1132-3|E1007|1023', 1, DATEADD(MINUTE, 59, DATEADD(HOUR, 9, DATEADD(DAY, -40, GETDATE())))),
(1321, 'TIX-MEGA-1133-0', 1133, N'Lê Anh', 'mega_req_133@gmail.com', 'TIX-MEGA-1133-0|E1020|1062', 0, DATEADD(MINUTE, 53, DATEADD(HOUR, 13, DATEADD(DAY, -36, GETDATE())))),
(1322, 'TIX-MEGA-1133-1', 1133, N'Lê Anh', 'mega_req_133@gmail.com', 'TIX-MEGA-1133-1|E1020|1062', 1, DATEADD(MINUTE, 53, DATEADD(HOUR, 13, DATEADD(DAY, -36, GETDATE())))),
(1323, 'TIX-MEGA-1133-2', 1133, N'Lê Anh', 'mega_req_133@gmail.com', 'TIX-MEGA-1133-2|E1020|1062', 0, DATEADD(MINUTE, 53, DATEADD(HOUR, 13, DATEADD(DAY, -36, GETDATE())))),
(1324, 'TIX-MEGA-1133-3', 1133, N'Lê Anh', 'mega_req_133@gmail.com', 'TIX-MEGA-1133-3|E1020|1062', 0, DATEADD(MINUTE, 53, DATEADD(HOUR, 13, DATEADD(DAY, -36, GETDATE())))),
(1325, 'TIX-MEGA-1134-0', 1134, N'Đặng Hải', 'mega_req_134@gmail.com', 'TIX-MEGA-1134-0|E1052|1156', 0, DATEADD(MINUTE, 29, DATEADD(HOUR, 19, DATEADD(DAY, -40, GETDATE())))),
(1326, 'TIX-MEGA-1135-0', 1135, N'Trần Kiên', 'mega_req_135@gmail.com', 'TIX-MEGA-1135-0|E1006|1020', 0, DATEADD(MINUTE, 13, DATEADD(HOUR, 21, DATEADD(DAY, -3, GETDATE())))),
(1327, 'TIX-MEGA-1135-1', 1135, N'Trần Kiên', 'mega_req_135@gmail.com', 'TIX-MEGA-1135-1|E1006|1020', 0, DATEADD(MINUTE, 13, DATEADD(HOUR, 21, DATEADD(DAY, -3, GETDATE())))),
(1328, 'TIX-MEGA-1135-2', 1135, N'Trần Kiên', 'mega_req_135@gmail.com', 'TIX-MEGA-1135-2|E1006|1020', 0, DATEADD(MINUTE, 13, DATEADD(HOUR, 21, DATEADD(DAY, -3, GETDATE())))),
(1329, 'TIX-MEGA-1136-0', 1136, N'Bùi Linh', 'mega_req_136@gmail.com', 'TIX-MEGA-1136-0|E1048|1145', 0, DATEADD(MINUTE, 10, DATEADD(HOUR, 2, DATEADD(DAY, -15, GETDATE())))),
(1330, 'TIX-MEGA-1137-0', 1137, N'Phạm Tâm', 'mega_req_137@gmail.com', 'TIX-MEGA-1137-0|E1045|1136', 0, DATEADD(MINUTE, 48, DATEADD(HOUR, 12, DATEADD(DAY, -56, GETDATE())))),
(1331, 'TIX-MEGA-1137-1', 1137, N'Phạm Tâm', 'mega_req_137@gmail.com', 'TIX-MEGA-1137-1|E1045|1136', 0, DATEADD(MINUTE, 48, DATEADD(HOUR, 12, DATEADD(DAY, -56, GETDATE())))),
(1332, 'TIX-MEGA-1138-0', 1138, N'Nguyễn Thu', 'mega_req_138@gmail.com', 'TIX-MEGA-1138-0|E1082|1246', 0, DATEADD(MINUTE, 5, DATEADD(HOUR, 7, DATEADD(DAY, -46, GETDATE())))),
(1333, 'TIX-MEGA-1138-1', 1138, N'Nguyễn Thu', 'mega_req_138@gmail.com', 'TIX-MEGA-1138-1|E1082|1246', 0, DATEADD(MINUTE, 5, DATEADD(HOUR, 7, DATEADD(DAY, -46, GETDATE())))),
(1334, 'TIX-MEGA-1138-2', 1138, N'Nguyễn Thu', 'mega_req_138@gmail.com', 'TIX-MEGA-1138-2|E1082|1246', 0, DATEADD(MINUTE, 5, DATEADD(HOUR, 7, DATEADD(DAY, -46, GETDATE())))),
(1335, 'TIX-MEGA-1138-3', 1138, N'Nguyễn Thu', 'mega_req_138@gmail.com', 'TIX-MEGA-1138-3|E1082|1246', 0, DATEADD(MINUTE, 5, DATEADD(HOUR, 7, DATEADD(DAY, -46, GETDATE())))),
(1336, 'TIX-MEGA-1139-0', 1139, N'Bùi Minh', 'mega_req_139@gmail.com', 'TIX-MEGA-1139-0|E1076|1229', 0, DATEADD(MINUTE, 3, DATEADD(HOUR, 0, DATEADD(DAY, -21, GETDATE())))),
(1337, 'TIX-MEGA-1140-0', 1140, N'Vũ Bảo', 'mega_req_140@gmail.com', 'TIX-MEGA-1140-0|E1065|1197', 0, DATEADD(MINUTE, 47, DATEADD(HOUR, 13, DATEADD(DAY, -59, GETDATE())))),
(1338, 'TIX-MEGA-1140-1', 1140, N'Vũ Bảo', 'mega_req_140@gmail.com', 'TIX-MEGA-1140-1|E1065|1197', 0, DATEADD(MINUTE, 47, DATEADD(HOUR, 13, DATEADD(DAY, -59, GETDATE())))),
(1339, 'TIX-MEGA-1140-2', 1140, N'Vũ Bảo', 'mega_req_140@gmail.com', 'TIX-MEGA-1140-2|E1065|1197', 0, DATEADD(MINUTE, 47, DATEADD(HOUR, 13, DATEADD(DAY, -59, GETDATE())))),
(1340, 'TIX-MEGA-1140-3', 1140, N'Vũ Bảo', 'mega_req_140@gmail.com', 'TIX-MEGA-1140-3|E1065|1197', 0, DATEADD(MINUTE, 47, DATEADD(HOUR, 13, DATEADD(DAY, -59, GETDATE())))),
(1341, 'TIX-MEGA-1141-0', 1141, N'Hoàng Kiên', 'mega_req_141@gmail.com', 'TIX-MEGA-1141-0|E1012|1036', 1, DATEADD(MINUTE, 48, DATEADD(HOUR, 23, DATEADD(DAY, -40, GETDATE())))),
(1342, 'TIX-MEGA-1141-1', 1141, N'Hoàng Kiên', 'mega_req_141@gmail.com', 'TIX-MEGA-1141-1|E1012|1036', 0, DATEADD(MINUTE, 48, DATEADD(HOUR, 23, DATEADD(DAY, -40, GETDATE())))),
(1343, 'TIX-MEGA-1141-2', 1141, N'Hoàng Kiên', 'mega_req_141@gmail.com', 'TIX-MEGA-1141-2|E1012|1036', 0, DATEADD(MINUTE, 48, DATEADD(HOUR, 23, DATEADD(DAY, -40, GETDATE())))),
(1344, 'TIX-MEGA-1142-0', 1142, N'Trần Hùng', 'mega_req_142@gmail.com', 'TIX-MEGA-1142-0|E1073|1220', 0, DATEADD(MINUTE, 52, DATEADD(HOUR, 0, DATEADD(DAY, -44, GETDATE())))),
(1345, 'TIX-MEGA-1142-1', 1142, N'Trần Hùng', 'mega_req_142@gmail.com', 'TIX-MEGA-1142-1|E1073|1220', 0, DATEADD(MINUTE, 52, DATEADD(HOUR, 0, DATEADD(DAY, -44, GETDATE())))),
(1346, 'TIX-MEGA-1142-2', 1142, N'Trần Hùng', 'mega_req_142@gmail.com', 'TIX-MEGA-1142-2|E1073|1220', 0, DATEADD(MINUTE, 52, DATEADD(HOUR, 0, DATEADD(DAY, -44, GETDATE())))),
(1347, 'TIX-MEGA-1142-3', 1142, N'Trần Hùng', 'mega_req_142@gmail.com', 'TIX-MEGA-1142-3|E1073|1220', 0, DATEADD(MINUTE, 52, DATEADD(HOUR, 0, DATEADD(DAY, -44, GETDATE())))),
(1348, 'TIX-MEGA-1143-0', 1143, N'Trần Hùng', 'mega_req_143@gmail.com', 'TIX-MEGA-1143-0|E1002|1007', 0, DATEADD(MINUTE, 34, DATEADD(HOUR, 8, DATEADD(DAY, -50, GETDATE())))),
(1349, 'TIX-MEGA-1143-1', 1143, N'Trần Hùng', 'mega_req_143@gmail.com', 'TIX-MEGA-1143-1|E1002|1007', 0, DATEADD(MINUTE, 34, DATEADD(HOUR, 8, DATEADD(DAY, -50, GETDATE())))),
(1350, 'TIX-MEGA-1143-2', 1143, N'Trần Hùng', 'mega_req_143@gmail.com', 'TIX-MEGA-1143-2|E1002|1007', 0, DATEADD(MINUTE, 34, DATEADD(HOUR, 8, DATEADD(DAY, -50, GETDATE())))),
(1351, 'TIX-MEGA-1144-0', 1144, N'Đặng Kiên', 'mega_req_144@gmail.com', 'TIX-MEGA-1144-0|E1040|1120', 0, DATEADD(MINUTE, 24, DATEADD(HOUR, 1, DATEADD(DAY, -25, GETDATE())))),
(1352, 'TIX-MEGA-1144-1', 1144, N'Đặng Kiên', 'mega_req_144@gmail.com', 'TIX-MEGA-1144-1|E1040|1120', 0, DATEADD(MINUTE, 24, DATEADD(HOUR, 1, DATEADD(DAY, -25, GETDATE())))),
(1353, 'TIX-MEGA-1144-2', 1144, N'Đặng Kiên', 'mega_req_144@gmail.com', 'TIX-MEGA-1144-2|E1040|1120', 0, DATEADD(MINUTE, 24, DATEADD(HOUR, 1, DATEADD(DAY, -25, GETDATE())))),
(1354, 'TIX-MEGA-1145-0', 1145, N'Nguyễn Lan', 'mega_req_145@gmail.com', 'TIX-MEGA-1145-0|E1092|1277', 1, DATEADD(MINUTE, 24, DATEADD(HOUR, 15, DATEADD(DAY, -17, GETDATE())))),
(1355, 'TIX-MEGA-1146-0', 1146, N'Phạm Vân', 'mega_req_146@gmail.com', 'TIX-MEGA-1146-0|E1074|1222', 0, DATEADD(MINUTE, 16, DATEADD(HOUR, 7, DATEADD(DAY, -52, GETDATE())))),
(1356, 'TIX-MEGA-1146-1', 1146, N'Phạm Vân', 'mega_req_146@gmail.com', 'TIX-MEGA-1146-1|E1074|1222', 1, DATEADD(MINUTE, 16, DATEADD(HOUR, 7, DATEADD(DAY, -52, GETDATE())))),
(1357, 'TIX-MEGA-1146-2', 1146, N'Phạm Vân', 'mega_req_146@gmail.com', 'TIX-MEGA-1146-2|E1074|1222', 0, DATEADD(MINUTE, 16, DATEADD(HOUR, 7, DATEADD(DAY, -52, GETDATE())))),
(1358, 'TIX-MEGA-1146-3', 1146, N'Phạm Vân', 'mega_req_146@gmail.com', 'TIX-MEGA-1146-3|E1074|1222', 0, DATEADD(MINUTE, 16, DATEADD(HOUR, 7, DATEADD(DAY, -52, GETDATE())))),
(1359, 'TIX-MEGA-1147-0', 1147, N'Nguyễn Thu', 'mega_req_147@gmail.com', 'TIX-MEGA-1147-0|E1075|1226', 0, DATEADD(MINUTE, 15, DATEADD(HOUR, 13, DATEADD(DAY, -33, GETDATE())))),
(1360, 'TIX-MEGA-1148-0', 1148, N'Vũ Khoa', 'mega_req_148@gmail.com', 'TIX-MEGA-1148-0|E1042|1128', 0, DATEADD(MINUTE, 45, DATEADD(HOUR, 0, DATEADD(DAY, -45, GETDATE())))),
(1361, 'TIX-MEGA-1149-0', 1149, N'Đỗ Thu', 'mega_req_149@gmail.com', 'TIX-MEGA-1149-0|E1057|1171', 0, DATEADD(MINUTE, 22, DATEADD(HOUR, 0, DATEADD(DAY, -25, GETDATE())))),
(1362, 'TIX-MEGA-1149-1', 1149, N'Đỗ Thu', 'mega_req_149@gmail.com', 'TIX-MEGA-1149-1|E1057|1171', 0, DATEADD(MINUTE, 22, DATEADD(HOUR, 0, DATEADD(DAY, -25, GETDATE())))),
(1363, 'TIX-MEGA-1149-2', 1149, N'Đỗ Thu', 'mega_req_149@gmail.com', 'TIX-MEGA-1149-2|E1057|1171', 0, DATEADD(MINUTE, 22, DATEADD(HOUR, 0, DATEADD(DAY, -25, GETDATE())))),
(1364, 'TIX-MEGA-1150-0', 1150, N'Trần Trang', 'mega_req_150@gmail.com', 'TIX-MEGA-1150-0|E1010|1032', 1, DATEADD(MINUTE, 10, DATEADD(HOUR, 12, DATEADD(DAY, -8, GETDATE())))),
(1365, 'TIX-MEGA-1150-1', 1150, N'Trần Trang', 'mega_req_150@gmail.com', 'TIX-MEGA-1150-1|E1010|1032', 0, DATEADD(MINUTE, 10, DATEADD(HOUR, 12, DATEADD(DAY, -8, GETDATE())))),
(1366, 'TIX-MEGA-1151-0', 1151, N'Phạm Lan', 'mega_req_151@gmail.com', 'TIX-MEGA-1151-0|E1070|1212', 1, DATEADD(MINUTE, 56, DATEADD(HOUR, 7, DATEADD(DAY, -52, GETDATE())))),
(1367, 'TIX-MEGA-1151-1', 1151, N'Phạm Lan', 'mega_req_151@gmail.com', 'TIX-MEGA-1151-1|E1070|1212', 0, DATEADD(MINUTE, 56, DATEADD(HOUR, 7, DATEADD(DAY, -52, GETDATE())))),
(1368, 'TIX-MEGA-1151-2', 1151, N'Phạm Lan', 'mega_req_151@gmail.com', 'TIX-MEGA-1151-2|E1070|1212', 0, DATEADD(MINUTE, 56, DATEADD(HOUR, 7, DATEADD(DAY, -52, GETDATE())))),
(1369, 'TIX-MEGA-1152-0', 1152, N'Trần Khoa', 'mega_req_152@gmail.com', 'TIX-MEGA-1152-0|E1030|1091', 0, DATEADD(MINUTE, 48, DATEADD(HOUR, 14, DATEADD(DAY, -50, GETDATE())))),
(1370, 'TIX-MEGA-1152-1', 1152, N'Trần Khoa', 'mega_req_152@gmail.com', 'TIX-MEGA-1152-1|E1030|1091', 1, DATEADD(MINUTE, 48, DATEADD(HOUR, 14, DATEADD(DAY, -50, GETDATE())))),
(1371, 'TIX-MEGA-1153-0', 1153, N'Lê Hùng', 'mega_req_153@gmail.com', 'TIX-MEGA-1153-0|E1098|1296', 0, DATEADD(MINUTE, 29, DATEADD(HOUR, 16, DATEADD(DAY, -14, GETDATE())))),
(1372, 'TIX-MEGA-1153-1', 1153, N'Lê Hùng', 'mega_req_153@gmail.com', 'TIX-MEGA-1153-1|E1098|1296', 0, DATEADD(MINUTE, 29, DATEADD(HOUR, 16, DATEADD(DAY, -14, GETDATE())))),
(1373, 'TIX-MEGA-1153-2', 1153, N'Lê Hùng', 'mega_req_153@gmail.com', 'TIX-MEGA-1153-2|E1098|1296', 0, DATEADD(MINUTE, 29, DATEADD(HOUR, 16, DATEADD(DAY, -14, GETDATE())))),
(1374, 'TIX-MEGA-1153-3', 1153, N'Lê Hùng', 'mega_req_153@gmail.com', 'TIX-MEGA-1153-3|E1098|1296', 0, DATEADD(MINUTE, 29, DATEADD(HOUR, 16, DATEADD(DAY, -14, GETDATE())))),
(1375, 'TIX-MEGA-1154-0', 1154, N'Hoàng Hùng', 'mega_req_154@gmail.com', 'TIX-MEGA-1154-0|E1096|1289', 0, DATEADD(MINUTE, 3, DATEADD(HOUR, 12, DATEADD(DAY, -21, GETDATE())))),
(1376, 'TIX-MEGA-1154-1', 1154, N'Hoàng Hùng', 'mega_req_154@gmail.com', 'TIX-MEGA-1154-1|E1096|1289', 0, DATEADD(MINUTE, 3, DATEADD(HOUR, 12, DATEADD(DAY, -21, GETDATE())))),
(1377, 'TIX-MEGA-1155-0', 1155, N'Đỗ Tâm', 'mega_req_155@gmail.com', 'TIX-MEGA-1155-0|E1079|1237', 0, DATEADD(MINUTE, 9, DATEADD(HOUR, 8, DATEADD(DAY, -11, GETDATE())))),
(1378, 'TIX-MEGA-1156-0', 1156, N'Huỳnh Trang', 'mega_req_156@gmail.com', 'TIX-MEGA-1156-0|E1053|1160', 0, DATEADD(MINUTE, 42, DATEADD(HOUR, 17, DATEADD(DAY, -42, GETDATE())))),
(1379, 'TIX-MEGA-1156-1', 1156, N'Huỳnh Trang', 'mega_req_156@gmail.com', 'TIX-MEGA-1156-1|E1053|1160', 0, DATEADD(MINUTE, 42, DATEADD(HOUR, 17, DATEADD(DAY, -42, GETDATE())))),
(1380, 'TIX-MEGA-1156-2', 1156, N'Huỳnh Trang', 'mega_req_156@gmail.com', 'TIX-MEGA-1156-2|E1053|1160', 0, DATEADD(MINUTE, 42, DATEADD(HOUR, 17, DATEADD(DAY, -42, GETDATE())))),
(1381, 'TIX-MEGA-1157-0', 1157, N'Hoàng Linh', 'mega_req_157@gmail.com', 'TIX-MEGA-1157-0|E1096|1290', 0, DATEADD(MINUTE, 56, DATEADD(HOUR, 3, DATEADD(DAY, -45, GETDATE())))),
(1382, 'TIX-MEGA-1157-1', 1157, N'Hoàng Linh', 'mega_req_157@gmail.com', 'TIX-MEGA-1157-1|E1096|1290', 0, DATEADD(MINUTE, 56, DATEADD(HOUR, 3, DATEADD(DAY, -45, GETDATE())))),
(1383, 'TIX-MEGA-1158-0', 1158, N'Đỗ Tâm', 'mega_req_158@gmail.com', 'TIX-MEGA-1158-0|E1010|1031', 0, DATEADD(MINUTE, 22, DATEADD(HOUR, 6, DATEADD(DAY, -60, GETDATE())))),
(1384, 'TIX-MEGA-1158-1', 1158, N'Đỗ Tâm', 'mega_req_158@gmail.com', 'TIX-MEGA-1158-1|E1010|1031', 0, DATEADD(MINUTE, 22, DATEADD(HOUR, 6, DATEADD(DAY, -60, GETDATE())))),
(1385, 'TIX-MEGA-1158-2', 1158, N'Đỗ Tâm', 'mega_req_158@gmail.com', 'TIX-MEGA-1158-2|E1010|1031', 0, DATEADD(MINUTE, 22, DATEADD(HOUR, 6, DATEADD(DAY, -60, GETDATE())))),
(1386, 'TIX-MEGA-1158-3', 1158, N'Đỗ Tâm', 'mega_req_158@gmail.com', 'TIX-MEGA-1158-3|E1010|1031', 0, DATEADD(MINUTE, 22, DATEADD(HOUR, 6, DATEADD(DAY, -60, GETDATE())))),
(1387, 'TIX-MEGA-1159-0', 1159, N'Huỳnh Vân', 'mega_req_159@gmail.com', 'TIX-MEGA-1159-0|E1048|1144', 0, DATEADD(MINUTE, 40, DATEADD(HOUR, 9, DATEADD(DAY, -41, GETDATE())))),
(1388, 'TIX-MEGA-1159-1', 1159, N'Huỳnh Vân', 'mega_req_159@gmail.com', 'TIX-MEGA-1159-1|E1048|1144', 0, DATEADD(MINUTE, 40, DATEADD(HOUR, 9, DATEADD(DAY, -41, GETDATE())))),
(1389, 'TIX-MEGA-1160-0', 1160, N'Bùi Bảo', 'mega_req_160@gmail.com', 'TIX-MEGA-1160-0|E1014|1043', 0, DATEADD(MINUTE, 32, DATEADD(HOUR, 5, DATEADD(DAY, -55, GETDATE())))),
(1390, 'TIX-MEGA-1160-1', 1160, N'Bùi Bảo', 'mega_req_160@gmail.com', 'TIX-MEGA-1160-1|E1014|1043', 0, DATEADD(MINUTE, 32, DATEADD(HOUR, 5, DATEADD(DAY, -55, GETDATE())))),
(1391, 'TIX-MEGA-1161-0', 1161, N'Lê Thu', 'mega_req_161@gmail.com', 'TIX-MEGA-1161-0|E1014|1043', 0, DATEADD(MINUTE, 51, DATEADD(HOUR, 4, DATEADD(DAY, -52, GETDATE())))),
(1392, 'TIX-MEGA-1161-1', 1161, N'Lê Thu', 'mega_req_161@gmail.com', 'TIX-MEGA-1161-1|E1014|1043', 0, DATEADD(MINUTE, 51, DATEADD(HOUR, 4, DATEADD(DAY, -52, GETDATE())))),
(1393, 'TIX-MEGA-1161-2', 1161, N'Lê Thu', 'mega_req_161@gmail.com', 'TIX-MEGA-1161-2|E1014|1043', 0, DATEADD(MINUTE, 51, DATEADD(HOUR, 4, DATEADD(DAY, -52, GETDATE())))),
(1394, 'TIX-MEGA-1161-3', 1161, N'Lê Thu', 'mega_req_161@gmail.com', 'TIX-MEGA-1161-3|E1014|1043', 0, DATEADD(MINUTE, 51, DATEADD(HOUR, 4, DATEADD(DAY, -52, GETDATE())))),
(1395, 'TIX-MEGA-1162-0', 1162, N'Đặng Trang', 'mega_req_162@gmail.com', 'TIX-MEGA-1162-0|E1076|1229', 0, DATEADD(MINUTE, 24, DATEADD(HOUR, 9, DATEADD(DAY, -28, GETDATE())))),
(1396, 'TIX-MEGA-1162-1', 1162, N'Đặng Trang', 'mega_req_162@gmail.com', 'TIX-MEGA-1162-1|E1076|1229', 1, DATEADD(MINUTE, 24, DATEADD(HOUR, 9, DATEADD(DAY, -28, GETDATE())))),
(1397, 'TIX-MEGA-1162-2', 1162, N'Đặng Trang', 'mega_req_162@gmail.com', 'TIX-MEGA-1162-2|E1076|1229', 0, DATEADD(MINUTE, 24, DATEADD(HOUR, 9, DATEADD(DAY, -28, GETDATE())))),
(1398, 'TIX-MEGA-1162-3', 1162, N'Đặng Trang', 'mega_req_162@gmail.com', 'TIX-MEGA-1162-3|E1076|1229', 0, DATEADD(MINUTE, 24, DATEADD(HOUR, 9, DATEADD(DAY, -28, GETDATE())))),
(1399, 'TIX-MEGA-1163-0', 1163, N'Huỳnh Hùng', 'mega_req_163@gmail.com', 'TIX-MEGA-1163-0|E1051|1155', 0, DATEADD(MINUTE, 36, DATEADD(HOUR, 3, DATEADD(DAY, -47, GETDATE())))),
(1400, 'TIX-MEGA-1164-0', 1164, N'Trần Minh', 'mega_req_164@gmail.com', 'TIX-MEGA-1164-0|E1002|1008', 1, DATEADD(MINUTE, 36, DATEADD(HOUR, 20, DATEADD(DAY, -58, GETDATE())))),
(1401, 'TIX-MEGA-1164-1', 1164, N'Trần Minh', 'mega_req_164@gmail.com', 'TIX-MEGA-1164-1|E1002|1008', 0, DATEADD(MINUTE, 36, DATEADD(HOUR, 20, DATEADD(DAY, -58, GETDATE()))));
INSERT INTO Tickets (ticket_id, ticket_code, order_item_id, attendee_name, attendee_email, qr_code, is_checked_in, created_at) VALUES
(1402, 'TIX-MEGA-1165-0', 1165, N'Bùi Hải', 'mega_req_165@gmail.com', 'TIX-MEGA-1165-0|E1013|1039', 0, DATEADD(MINUTE, 56, DATEADD(HOUR, 3, DATEADD(DAY, -23, GETDATE())))),
(1403, 'TIX-MEGA-1165-1', 1165, N'Bùi Hải', 'mega_req_165@gmail.com', 'TIX-MEGA-1165-1|E1013|1039', 0, DATEADD(MINUTE, 56, DATEADD(HOUR, 3, DATEADD(DAY, -23, GETDATE())))),
(1404, 'TIX-MEGA-1165-2', 1165, N'Bùi Hải', 'mega_req_165@gmail.com', 'TIX-MEGA-1165-2|E1013|1039', 0, DATEADD(MINUTE, 56, DATEADD(HOUR, 3, DATEADD(DAY, -23, GETDATE())))),
(1405, 'TIX-MEGA-1166-0', 1166, N'Bùi Thu', 'mega_req_166@gmail.com', 'TIX-MEGA-1166-0|E1089|1267', 0, DATEADD(MINUTE, 20, DATEADD(HOUR, 9, DATEADD(DAY, -53, GETDATE())))),
(1406, 'TIX-MEGA-1166-1', 1166, N'Bùi Thu', 'mega_req_166@gmail.com', 'TIX-MEGA-1166-1|E1089|1267', 0, DATEADD(MINUTE, 20, DATEADD(HOUR, 9, DATEADD(DAY, -53, GETDATE())))),
(1407, 'TIX-MEGA-1166-2', 1166, N'Bùi Thu', 'mega_req_166@gmail.com', 'TIX-MEGA-1166-2|E1089|1267', 0, DATEADD(MINUTE, 20, DATEADD(HOUR, 9, DATEADD(DAY, -53, GETDATE())))),
(1408, 'TIX-MEGA-1166-3', 1166, N'Bùi Thu', 'mega_req_166@gmail.com', 'TIX-MEGA-1166-3|E1089|1267', 0, DATEADD(MINUTE, 20, DATEADD(HOUR, 9, DATEADD(DAY, -53, GETDATE())))),
(1409, 'TIX-MEGA-1167-0', 1167, N'Bùi Hải', 'mega_req_167@gmail.com', 'TIX-MEGA-1167-0|E1043|1130', 0, DATEADD(MINUTE, 56, DATEADD(HOUR, 15, DATEADD(DAY, -16, GETDATE())))),
(1410, 'TIX-MEGA-1167-1', 1167, N'Bùi Hải', 'mega_req_167@gmail.com', 'TIX-MEGA-1167-1|E1043|1130', 0, DATEADD(MINUTE, 56, DATEADD(HOUR, 15, DATEADD(DAY, -16, GETDATE())))),
(1411, 'TIX-MEGA-1167-2', 1167, N'Bùi Hải', 'mega_req_167@gmail.com', 'TIX-MEGA-1167-2|E1043|1130', 0, DATEADD(MINUTE, 56, DATEADD(HOUR, 15, DATEADD(DAY, -16, GETDATE())))),
(1412, 'TIX-MEGA-1168-0', 1168, N'Trần Minh', 'mega_req_168@gmail.com', 'TIX-MEGA-1168-0|E1090|1272', 0, DATEADD(MINUTE, 47, DATEADD(HOUR, 21, DATEADD(DAY, -12, GETDATE())))),
(1413, 'TIX-MEGA-1169-0', 1169, N'Vũ Bảo', 'mega_req_169@gmail.com', 'TIX-MEGA-1169-0|E1081|1243', 0, DATEADD(MINUTE, 16, DATEADD(HOUR, 6, DATEADD(DAY, -54, GETDATE())))),
(1414, 'TIX-MEGA-1170-0', 1170, N'Lê Kiên', 'mega_req_170@gmail.com', 'TIX-MEGA-1170-0|E1091|1274', 0, DATEADD(MINUTE, 10, DATEADD(HOUR, 10, DATEADD(DAY, -1, GETDATE())))),
(1415, 'TIX-MEGA-1171-0', 1171, N'Bùi Thu', 'mega_req_171@gmail.com', 'TIX-MEGA-1171-0|E1028|1085', 0, DATEADD(MINUTE, 44, DATEADD(HOUR, 20, DATEADD(DAY, -41, GETDATE())))),
(1416, 'TIX-MEGA-1171-1', 1171, N'Bùi Thu', 'mega_req_171@gmail.com', 'TIX-MEGA-1171-1|E1028|1085', 0, DATEADD(MINUTE, 44, DATEADD(HOUR, 20, DATEADD(DAY, -41, GETDATE())))),
(1417, 'TIX-MEGA-1172-0', 1172, N'Phạm Thành', 'mega_req_172@gmail.com', 'TIX-MEGA-1172-0|E1054|1162', 0, DATEADD(MINUTE, 22, DATEADD(HOUR, 20, DATEADD(DAY, -25, GETDATE())))),
(1418, 'TIX-MEGA-1173-0', 1173, N'Đặng Anh', 'mega_req_173@gmail.com', 'TIX-MEGA-1173-0|E1053|1159', 0, DATEADD(MINUTE, 40, DATEADD(HOUR, 15, DATEADD(DAY, -28, GETDATE())))),
(1419, 'TIX-MEGA-1173-1', 1173, N'Đặng Anh', 'mega_req_173@gmail.com', 'TIX-MEGA-1173-1|E1053|1159', 0, DATEADD(MINUTE, 40, DATEADD(HOUR, 15, DATEADD(DAY, -28, GETDATE())))),
(1420, 'TIX-MEGA-1174-0', 1174, N'Nguyễn Kiên', 'mega_req_174@gmail.com', 'TIX-MEGA-1174-0|E1020|1062', 0, DATEADD(MINUTE, 55, DATEADD(HOUR, 20, DATEADD(DAY, -43, GETDATE())))),
(1421, 'TIX-MEGA-1174-1', 1174, N'Nguyễn Kiên', 'mega_req_174@gmail.com', 'TIX-MEGA-1174-1|E1020|1062', 0, DATEADD(MINUTE, 55, DATEADD(HOUR, 20, DATEADD(DAY, -43, GETDATE())))),
(1422, 'TIX-MEGA-1175-0', 1175, N'Lê Phong', 'mega_req_175@gmail.com', 'TIX-MEGA-1175-0|E1016|1049', 1, DATEADD(MINUTE, 57, DATEADD(HOUR, 14, DATEADD(DAY, -33, GETDATE())))),
(1423, 'TIX-MEGA-1175-1', 1175, N'Lê Phong', 'mega_req_175@gmail.com', 'TIX-MEGA-1175-1|E1016|1049', 0, DATEADD(MINUTE, 57, DATEADD(HOUR, 14, DATEADD(DAY, -33, GETDATE())))),
(1424, 'TIX-MEGA-1175-2', 1175, N'Lê Phong', 'mega_req_175@gmail.com', 'TIX-MEGA-1175-2|E1016|1049', 1, DATEADD(MINUTE, 57, DATEADD(HOUR, 14, DATEADD(DAY, -33, GETDATE())))),
(1425, 'TIX-MEGA-1176-0', 1176, N'Đỗ Hải', 'mega_req_176@gmail.com', 'TIX-MEGA-1176-0|E1082|1248', 0, DATEADD(MINUTE, 45, DATEADD(HOUR, 10, DATEADD(DAY, -17, GETDATE())))),
(1426, 'TIX-MEGA-1176-1', 1176, N'Đỗ Hải', 'mega_req_176@gmail.com', 'TIX-MEGA-1176-1|E1082|1248', 0, DATEADD(MINUTE, 45, DATEADD(HOUR, 10, DATEADD(DAY, -17, GETDATE())))),
(1427, 'TIX-MEGA-1177-0', 1177, N'Vũ Vân', 'mega_req_177@gmail.com', 'TIX-MEGA-1177-0|E1025|1076', 0, DATEADD(MINUTE, 33, DATEADD(HOUR, 17, DATEADD(DAY, -4, GETDATE())))),
(1428, 'TIX-MEGA-1177-1', 1177, N'Vũ Vân', 'mega_req_177@gmail.com', 'TIX-MEGA-1177-1|E1025|1076', 0, DATEADD(MINUTE, 33, DATEADD(HOUR, 17, DATEADD(DAY, -4, GETDATE())))),
(1429, 'TIX-MEGA-1177-2', 1177, N'Vũ Vân', 'mega_req_177@gmail.com', 'TIX-MEGA-1177-2|E1025|1076', 0, DATEADD(MINUTE, 33, DATEADD(HOUR, 17, DATEADD(DAY, -4, GETDATE())))),
(1430, 'TIX-MEGA-1178-0', 1178, N'Đỗ Kiên', 'mega_req_178@gmail.com', 'TIX-MEGA-1178-0|E1019|1059', 0, DATEADD(MINUTE, 18, DATEADD(HOUR, 20, DATEADD(DAY, -51, GETDATE())))),
(1431, 'TIX-MEGA-1178-1', 1178, N'Đỗ Kiên', 'mega_req_178@gmail.com', 'TIX-MEGA-1178-1|E1019|1059', 0, DATEADD(MINUTE, 18, DATEADD(HOUR, 20, DATEADD(DAY, -51, GETDATE())))),
(1432, 'TIX-MEGA-1179-0', 1179, N'Trần Thu', 'mega_req_179@gmail.com', 'TIX-MEGA-1179-0|E1046|1139', 0, DATEADD(MINUTE, 29, DATEADD(HOUR, 0, DATEADD(DAY, -25, GETDATE())))),
(1433, 'TIX-MEGA-1179-1', 1179, N'Trần Thu', 'mega_req_179@gmail.com', 'TIX-MEGA-1179-1|E1046|1139', 0, DATEADD(MINUTE, 29, DATEADD(HOUR, 0, DATEADD(DAY, -25, GETDATE())))),
(1434, 'TIX-MEGA-1179-2', 1179, N'Trần Thu', 'mega_req_179@gmail.com', 'TIX-MEGA-1179-2|E1046|1139', 0, DATEADD(MINUTE, 29, DATEADD(HOUR, 0, DATEADD(DAY, -25, GETDATE())))),
(1435, 'TIX-MEGA-1179-3', 1179, N'Trần Thu', 'mega_req_179@gmail.com', 'TIX-MEGA-1179-3|E1046|1139', 0, DATEADD(MINUTE, 29, DATEADD(HOUR, 0, DATEADD(DAY, -25, GETDATE())))),
(1436, 'TIX-MEGA-1180-0', 1180, N'Phạm Khoa', 'mega_req_180@gmail.com', 'TIX-MEGA-1180-0|E1066|1199', 0, DATEADD(MINUTE, 31, DATEADD(HOUR, 10, DATEADD(DAY, -48, GETDATE())))),
(1437, 'TIX-MEGA-1180-1', 1180, N'Phạm Khoa', 'mega_req_180@gmail.com', 'TIX-MEGA-1180-1|E1066|1199', 0, DATEADD(MINUTE, 31, DATEADD(HOUR, 10, DATEADD(DAY, -48, GETDATE())))),
(1438, 'TIX-MEGA-1181-0', 1181, N'Đặng Lan', 'mega_req_181@gmail.com', 'TIX-MEGA-1181-0|E1059|1177', 0, DATEADD(MINUTE, 59, DATEADD(HOUR, 14, DATEADD(DAY, -25, GETDATE())))),
(1439, 'TIX-MEGA-1182-0', 1182, N'Trần Kiên', 'mega_req_182@gmail.com', 'TIX-MEGA-1182-0|E1033|1101', 0, DATEADD(MINUTE, 43, DATEADD(HOUR, 22, DATEADD(DAY, 0, GETDATE())))),
(1440, 'TIX-MEGA-1182-1', 1182, N'Trần Kiên', 'mega_req_182@gmail.com', 'TIX-MEGA-1182-1|E1033|1101', 0, DATEADD(MINUTE, 43, DATEADD(HOUR, 22, DATEADD(DAY, 0, GETDATE())))),
(1441, 'TIX-MEGA-1183-0', 1183, N'Huỳnh Anh', 'mega_req_183@gmail.com', 'TIX-MEGA-1183-0|E1098|1295', 0, DATEADD(MINUTE, 9, DATEADD(HOUR, 12, DATEADD(DAY, -8, GETDATE())))),
(1442, 'TIX-MEGA-1183-1', 1183, N'Huỳnh Anh', 'mega_req_183@gmail.com', 'TIX-MEGA-1183-1|E1098|1295', 0, DATEADD(MINUTE, 9, DATEADD(HOUR, 12, DATEADD(DAY, -8, GETDATE())))),
(1443, 'TIX-MEGA-1184-0', 1184, N'Huỳnh Trang', 'mega_req_184@gmail.com', 'TIX-MEGA-1184-0|E1090|1271', 0, DATEADD(MINUTE, 22, DATEADD(HOUR, 20, DATEADD(DAY, -18, GETDATE())))),
(1444, 'TIX-MEGA-1185-0', 1185, N'Hoàng Khoa', 'mega_req_185@gmail.com', 'TIX-MEGA-1185-0|E1058|1174', 0, DATEADD(MINUTE, 9, DATEADD(HOUR, 21, DATEADD(DAY, -22, GETDATE())))),
(1445, 'TIX-MEGA-1186-0', 1186, N'Hoàng Minh', 'mega_req_186@gmail.com', 'TIX-MEGA-1186-0|E1014|1043', 0, DATEADD(MINUTE, 35, DATEADD(HOUR, 15, DATEADD(DAY, -21, GETDATE())))),
(1446, 'TIX-MEGA-1186-1', 1186, N'Hoàng Minh', 'mega_req_186@gmail.com', 'TIX-MEGA-1186-1|E1014|1043', 0, DATEADD(MINUTE, 35, DATEADD(HOUR, 15, DATEADD(DAY, -21, GETDATE())))),
(1447, 'TIX-MEGA-1186-2', 1186, N'Hoàng Minh', 'mega_req_186@gmail.com', 'TIX-MEGA-1186-2|E1014|1043', 0, DATEADD(MINUTE, 35, DATEADD(HOUR, 15, DATEADD(DAY, -21, GETDATE())))),
(1448, 'TIX-MEGA-1186-3', 1186, N'Hoàng Minh', 'mega_req_186@gmail.com', 'TIX-MEGA-1186-3|E1014|1043', 0, DATEADD(MINUTE, 35, DATEADD(HOUR, 15, DATEADD(DAY, -21, GETDATE())))),
(1449, 'TIX-MEGA-1187-0', 1187, N'Huỳnh Vân', 'mega_req_187@gmail.com', 'TIX-MEGA-1187-0|E1024|1074', 0, DATEADD(MINUTE, 21, DATEADD(HOUR, 7, DATEADD(DAY, -35, GETDATE())))),
(1450, 'TIX-MEGA-1188-0', 1188, N'Phạm Lan', 'mega_req_188@gmail.com', 'TIX-MEGA-1188-0|E1033|1101', 0, DATEADD(MINUTE, 16, DATEADD(HOUR, 8, DATEADD(DAY, -23, GETDATE())))),
(1451, 'TIX-MEGA-1188-1', 1188, N'Phạm Lan', 'mega_req_188@gmail.com', 'TIX-MEGA-1188-1|E1033|1101', 0, DATEADD(MINUTE, 16, DATEADD(HOUR, 8, DATEADD(DAY, -23, GETDATE())))),
(1452, 'TIX-MEGA-1188-2', 1188, N'Phạm Lan', 'mega_req_188@gmail.com', 'TIX-MEGA-1188-2|E1033|1101', 0, DATEADD(MINUTE, 16, DATEADD(HOUR, 8, DATEADD(DAY, -23, GETDATE())))),
(1453, 'TIX-MEGA-1189-0', 1189, N'Bùi Phong', 'mega_req_189@gmail.com', 'TIX-MEGA-1189-0|E1022|1067', 0, DATEADD(MINUTE, 12, DATEADD(HOUR, 19, DATEADD(DAY, -41, GETDATE())))),
(1454, 'TIX-MEGA-1189-1', 1189, N'Bùi Phong', 'mega_req_189@gmail.com', 'TIX-MEGA-1189-1|E1022|1067', 0, DATEADD(MINUTE, 12, DATEADD(HOUR, 19, DATEADD(DAY, -41, GETDATE())))),
(1455, 'TIX-MEGA-1189-2', 1189, N'Bùi Phong', 'mega_req_189@gmail.com', 'TIX-MEGA-1189-2|E1022|1067', 0, DATEADD(MINUTE, 12, DATEADD(HOUR, 19, DATEADD(DAY, -41, GETDATE())))),
(1456, 'TIX-MEGA-1189-3', 1189, N'Bùi Phong', 'mega_req_189@gmail.com', 'TIX-MEGA-1189-3|E1022|1067', 0, DATEADD(MINUTE, 12, DATEADD(HOUR, 19, DATEADD(DAY, -41, GETDATE())))),
(1457, 'TIX-MEGA-1190-0', 1190, N'Vũ Hải', 'mega_req_190@gmail.com', 'TIX-MEGA-1190-0|E1060|1180', 1, DATEADD(MINUTE, 19, DATEADD(HOUR, 21, DATEADD(DAY, -44, GETDATE())))),
(1458, 'TIX-MEGA-1191-0', 1191, N'Trần Kiên', 'mega_req_191@gmail.com', 'TIX-MEGA-1191-0|E1081|1243', 0, DATEADD(MINUTE, 7, DATEADD(HOUR, 19, DATEADD(DAY, -38, GETDATE())))),
(1459, 'TIX-MEGA-1191-1', 1191, N'Trần Kiên', 'mega_req_191@gmail.com', 'TIX-MEGA-1191-1|E1081|1243', 0, DATEADD(MINUTE, 7, DATEADD(HOUR, 19, DATEADD(DAY, -38, GETDATE())))),
(1460, 'TIX-MEGA-1192-0', 1192, N'Phạm Trang', 'mega_req_192@gmail.com', 'TIX-MEGA-1192-0|E1078|1234', 0, DATEADD(MINUTE, 44, DATEADD(HOUR, 15, DATEADD(DAY, -13, GETDATE())))),
(1461, 'TIX-MEGA-1192-1', 1192, N'Phạm Trang', 'mega_req_192@gmail.com', 'TIX-MEGA-1192-1|E1078|1234', 0, DATEADD(MINUTE, 44, DATEADD(HOUR, 15, DATEADD(DAY, -13, GETDATE())))),
(1462, 'TIX-MEGA-1193-0', 1193, N'Lê Phong', 'mega_req_193@gmail.com', 'TIX-MEGA-1193-0|E1036|1110', 0, DATEADD(MINUTE, 26, DATEADD(HOUR, 8, DATEADD(DAY, -54, GETDATE())))),
(1463, 'TIX-MEGA-1193-1', 1193, N'Lê Phong', 'mega_req_193@gmail.com', 'TIX-MEGA-1193-1|E1036|1110', 0, DATEADD(MINUTE, 26, DATEADD(HOUR, 8, DATEADD(DAY, -54, GETDATE())))),
(1464, 'TIX-MEGA-1193-2', 1193, N'Lê Phong', 'mega_req_193@gmail.com', 'TIX-MEGA-1193-2|E1036|1110', 0, DATEADD(MINUTE, 26, DATEADD(HOUR, 8, DATEADD(DAY, -54, GETDATE())))),
(1465, 'TIX-MEGA-1193-3', 1193, N'Lê Phong', 'mega_req_193@gmail.com', 'TIX-MEGA-1193-3|E1036|1110', 0, DATEADD(MINUTE, 26, DATEADD(HOUR, 8, DATEADD(DAY, -54, GETDATE())))),
(1466, 'TIX-MEGA-1194-0', 1194, N'Bùi Kiên', 'mega_req_194@gmail.com', 'TIX-MEGA-1194-0|E1096|1290', 0, DATEADD(MINUTE, 0, DATEADD(HOUR, 23, DATEADD(DAY, -50, GETDATE())))),
(1467, 'TIX-MEGA-1194-1', 1194, N'Bùi Kiên', 'mega_req_194@gmail.com', 'TIX-MEGA-1194-1|E1096|1290', 0, DATEADD(MINUTE, 0, DATEADD(HOUR, 23, DATEADD(DAY, -50, GETDATE())))),
(1468, 'TIX-MEGA-1194-2', 1194, N'Bùi Kiên', 'mega_req_194@gmail.com', 'TIX-MEGA-1194-2|E1096|1290', 0, DATEADD(MINUTE, 0, DATEADD(HOUR, 23, DATEADD(DAY, -50, GETDATE())))),
(1469, 'TIX-MEGA-1194-3', 1194, N'Bùi Kiên', 'mega_req_194@gmail.com', 'TIX-MEGA-1194-3|E1096|1290', 0, DATEADD(MINUTE, 0, DATEADD(HOUR, 23, DATEADD(DAY, -50, GETDATE())))),
(1470, 'TIX-MEGA-1195-0', 1195, N'Trần Kiên', 'mega_req_195@gmail.com', 'TIX-MEGA-1195-0|E1052|1156', 0, DATEADD(MINUTE, 11, DATEADD(HOUR, 20, DATEADD(DAY, -35, GETDATE())))),
(1471, 'TIX-MEGA-1195-1', 1195, N'Trần Kiên', 'mega_req_195@gmail.com', 'TIX-MEGA-1195-1|E1052|1156', 0, DATEADD(MINUTE, 11, DATEADD(HOUR, 20, DATEADD(DAY, -35, GETDATE())))),
(1472, 'TIX-MEGA-1195-2', 1195, N'Trần Kiên', 'mega_req_195@gmail.com', 'TIX-MEGA-1195-2|E1052|1156', 1, DATEADD(MINUTE, 11, DATEADD(HOUR, 20, DATEADD(DAY, -35, GETDATE())))),
(1473, 'TIX-MEGA-1195-3', 1195, N'Trần Kiên', 'mega_req_195@gmail.com', 'TIX-MEGA-1195-3|E1052|1156', 1, DATEADD(MINUTE, 11, DATEADD(HOUR, 20, DATEADD(DAY, -35, GETDATE())))),
(1474, 'TIX-MEGA-1196-0', 1196, N'Phạm Phong', 'mega_req_196@gmail.com', 'TIX-MEGA-1196-0|E1092|1278', 0, DATEADD(MINUTE, 31, DATEADD(HOUR, 19, DATEADD(DAY, -55, GETDATE())))),
(1475, 'TIX-MEGA-1196-1', 1196, N'Phạm Phong', 'mega_req_196@gmail.com', 'TIX-MEGA-1196-1|E1092|1278', 0, DATEADD(MINUTE, 31, DATEADD(HOUR, 19, DATEADD(DAY, -55, GETDATE())))),
(1476, 'TIX-MEGA-1197-0', 1197, N'Đặng Minh', 'mega_req_197@gmail.com', 'TIX-MEGA-1197-0|E1032|1097', 0, DATEADD(MINUTE, 42, DATEADD(HOUR, 15, DATEADD(DAY, -41, GETDATE())))),
(1477, 'TIX-MEGA-1197-1', 1197, N'Đặng Minh', 'mega_req_197@gmail.com', 'TIX-MEGA-1197-1|E1032|1097', 0, DATEADD(MINUTE, 42, DATEADD(HOUR, 15, DATEADD(DAY, -41, GETDATE())))),
(1478, 'TIX-MEGA-1198-0', 1198, N'Bùi Vân', 'mega_req_198@gmail.com', 'TIX-MEGA-1198-0|E1033|1101', 0, DATEADD(MINUTE, 50, DATEADD(HOUR, 2, DATEADD(DAY, -3, GETDATE())))),
(1479, 'TIX-MEGA-1199-0', 1199, N'Vũ Tâm', 'mega_req_199@gmail.com', 'TIX-MEGA-1199-0|E1002|1006', 0, DATEADD(MINUTE, 18, DATEADD(HOUR, 7, DATEADD(DAY, -57, GETDATE())))),
(1480, 'TIX-MEGA-1199-1', 1199, N'Vũ Tâm', 'mega_req_199@gmail.com', 'TIX-MEGA-1199-1|E1002|1006', 0, DATEADD(MINUTE, 18, DATEADD(HOUR, 7, DATEADD(DAY, -57, GETDATE())))),
(1481, 'TIX-MEGA-1199-2', 1199, N'Vũ Tâm', 'mega_req_199@gmail.com', 'TIX-MEGA-1199-2|E1002|1006', 0, DATEADD(MINUTE, 18, DATEADD(HOUR, 7, DATEADD(DAY, -57, GETDATE())))),
(1482, 'TIX-MEGA-1199-3', 1199, N'Vũ Tâm', 'mega_req_199@gmail.com', 'TIX-MEGA-1199-3|E1002|1006', 0, DATEADD(MINUTE, 18, DATEADD(HOUR, 7, DATEADD(DAY, -57, GETDATE())))),
(1483, 'TIX-MEGA-1200-0', 1200, N'Nguyễn Minh', 'mega_req_200@gmail.com', 'TIX-MEGA-1200-0|E1006|1018', 0, DATEADD(MINUTE, 50, DATEADD(HOUR, 20, DATEADD(DAY, -4, GETDATE())))),
(1484, 'TIX-MEGA-1201-0', 1201, N'Lê Anh', 'mega_req_201@gmail.com', 'TIX-MEGA-1201-0|E1063|1190', 0, DATEADD(MINUTE, 36, DATEADD(HOUR, 17, DATEADD(DAY, -46, GETDATE())))),
(1485, 'TIX-MEGA-1201-1', 1201, N'Lê Anh', 'mega_req_201@gmail.com', 'TIX-MEGA-1201-1|E1063|1190', 0, DATEADD(MINUTE, 36, DATEADD(HOUR, 17, DATEADD(DAY, -46, GETDATE())))),
(1486, 'TIX-MEGA-1201-2', 1201, N'Lê Anh', 'mega_req_201@gmail.com', 'TIX-MEGA-1201-2|E1063|1190', 0, DATEADD(MINUTE, 36, DATEADD(HOUR, 17, DATEADD(DAY, -46, GETDATE())))),
(1487, 'TIX-MEGA-1202-0', 1202, N'Huỳnh Hải', 'mega_req_202@gmail.com', 'TIX-MEGA-1202-0|E1033|1100', 0, DATEADD(MINUTE, 21, DATEADD(HOUR, 23, DATEADD(DAY, -41, GETDATE())))),
(1488, 'TIX-MEGA-1202-1', 1202, N'Huỳnh Hải', 'mega_req_202@gmail.com', 'TIX-MEGA-1202-1|E1033|1100', 0, DATEADD(MINUTE, 21, DATEADD(HOUR, 23, DATEADD(DAY, -41, GETDATE())))),
(1489, 'TIX-MEGA-1202-2', 1202, N'Huỳnh Hải', 'mega_req_202@gmail.com', 'TIX-MEGA-1202-2|E1033|1100', 0, DATEADD(MINUTE, 21, DATEADD(HOUR, 23, DATEADD(DAY, -41, GETDATE())))),
(1490, 'TIX-MEGA-1202-3', 1202, N'Huỳnh Hải', 'mega_req_202@gmail.com', 'TIX-MEGA-1202-3|E1033|1100', 0, DATEADD(MINUTE, 21, DATEADD(HOUR, 23, DATEADD(DAY, -41, GETDATE())))),
(1491, 'TIX-MEGA-1203-0', 1203, N'Trần Anh', 'mega_req_203@gmail.com', 'TIX-MEGA-1203-0|E1095|1285', 0, DATEADD(MINUTE, 16, DATEADD(HOUR, 8, DATEADD(DAY, -37, GETDATE())))),
(1492, 'TIX-MEGA-1203-1', 1203, N'Trần Anh', 'mega_req_203@gmail.com', 'TIX-MEGA-1203-1|E1095|1285', 0, DATEADD(MINUTE, 16, DATEADD(HOUR, 8, DATEADD(DAY, -37, GETDATE())))),
(1493, 'TIX-MEGA-1204-0', 1204, N'Nguyễn Bảo', 'mega_req_204@gmail.com', 'TIX-MEGA-1204-0|E1091|1275', 0, DATEADD(MINUTE, 18, DATEADD(HOUR, 3, DATEADD(DAY, -51, GETDATE())))),
(1494, 'TIX-MEGA-1204-1', 1204, N'Nguyễn Bảo', 'mega_req_204@gmail.com', 'TIX-MEGA-1204-1|E1091|1275', 0, DATEADD(MINUTE, 18, DATEADD(HOUR, 3, DATEADD(DAY, -51, GETDATE())))),
(1495, 'TIX-MEGA-1204-2', 1204, N'Nguyễn Bảo', 'mega_req_204@gmail.com', 'TIX-MEGA-1204-2|E1091|1275', 0, DATEADD(MINUTE, 18, DATEADD(HOUR, 3, DATEADD(DAY, -51, GETDATE())))),
(1496, 'TIX-MEGA-1205-0', 1205, N'Hoàng Bảo', 'mega_req_205@gmail.com', 'TIX-MEGA-1205-0|E1010|1031', 1, DATEADD(MINUTE, 9, DATEADD(HOUR, 0, DATEADD(DAY, -9, GETDATE())))),
(1497, 'TIX-MEGA-1205-1', 1205, N'Hoàng Bảo', 'mega_req_205@gmail.com', 'TIX-MEGA-1205-1|E1010|1031', 1, DATEADD(MINUTE, 9, DATEADD(HOUR, 0, DATEADD(DAY, -9, GETDATE())))),
(1498, 'TIX-MEGA-1205-2', 1205, N'Hoàng Bảo', 'mega_req_205@gmail.com', 'TIX-MEGA-1205-2|E1010|1031', 0, DATEADD(MINUTE, 9, DATEADD(HOUR, 0, DATEADD(DAY, -9, GETDATE())))),
(1499, 'TIX-MEGA-1206-0', 1206, N'Lê Bảo', 'mega_req_206@gmail.com', 'TIX-MEGA-1206-0|E1017|1053', 0, DATEADD(MINUTE, 1, DATEADD(HOUR, 8, DATEADD(DAY, -24, GETDATE())))),
(1500, 'TIX-MEGA-1207-0', 1207, N'Huỳnh Anh', 'mega_req_207@gmail.com', 'TIX-MEGA-1207-0|E1008|1024', 0, DATEADD(MINUTE, 26, DATEADD(HOUR, 22, DATEADD(DAY, -34, GETDATE())))),
(1501, 'TIX-MEGA-1207-1', 1207, N'Huỳnh Anh', 'mega_req_207@gmail.com', 'TIX-MEGA-1207-1|E1008|1024', 0, DATEADD(MINUTE, 26, DATEADD(HOUR, 22, DATEADD(DAY, -34, GETDATE())))),
(1502, 'TIX-MEGA-1207-2', 1207, N'Huỳnh Anh', 'mega_req_207@gmail.com', 'TIX-MEGA-1207-2|E1008|1024', 1, DATEADD(MINUTE, 26, DATEADD(HOUR, 22, DATEADD(DAY, -34, GETDATE())))),
(1503, 'TIX-MEGA-1207-3', 1207, N'Huỳnh Anh', 'mega_req_207@gmail.com', 'TIX-MEGA-1207-3|E1008|1024', 0, DATEADD(MINUTE, 26, DATEADD(HOUR, 22, DATEADD(DAY, -34, GETDATE()))));
INSERT INTO Tickets (ticket_id, ticket_code, order_item_id, attendee_name, attendee_email, qr_code, is_checked_in, created_at) VALUES
(1504, 'TIX-MEGA-1208-0', 1208, N'Lê Phong', 'mega_req_208@gmail.com', 'TIX-MEGA-1208-0|E1022|1068', 0, DATEADD(MINUTE, 40, DATEADD(HOUR, 19, DATEADD(DAY, -21, GETDATE())))),
(1505, 'TIX-MEGA-1208-1', 1208, N'Lê Phong', 'mega_req_208@gmail.com', 'TIX-MEGA-1208-1|E1022|1068', 0, DATEADD(MINUTE, 40, DATEADD(HOUR, 19, DATEADD(DAY, -21, GETDATE())))),
(1506, 'TIX-MEGA-1208-2', 1208, N'Lê Phong', 'mega_req_208@gmail.com', 'TIX-MEGA-1208-2|E1022|1068', 0, DATEADD(MINUTE, 40, DATEADD(HOUR, 19, DATEADD(DAY, -21, GETDATE())))),
(1507, 'TIX-MEGA-1208-3', 1208, N'Lê Phong', 'mega_req_208@gmail.com', 'TIX-MEGA-1208-3|E1022|1068', 0, DATEADD(MINUTE, 40, DATEADD(HOUR, 19, DATEADD(DAY, -21, GETDATE())))),
(1508, 'TIX-MEGA-1209-0', 1209, N'Trần Bảo', 'mega_req_209@gmail.com', 'TIX-MEGA-1209-0|E1036|1108', 0, DATEADD(MINUTE, 23, DATEADD(HOUR, 15, DATEADD(DAY, -6, GETDATE())))),
(1509, 'TIX-MEGA-1210-0', 1210, N'Đặng Lan', 'mega_req_210@gmail.com', 'TIX-MEGA-1210-0|E1086|1260', 1, DATEADD(MINUTE, 0, DATEADD(HOUR, 17, DATEADD(DAY, -11, GETDATE())))),
(1510, 'TIX-MEGA-1211-0', 1211, N'Bùi Kiên', 'mega_req_211@gmail.com', 'TIX-MEGA-1211-0|E1054|1163', 0, DATEADD(MINUTE, 34, DATEADD(HOUR, 14, DATEADD(DAY, -27, GETDATE())))),
(1511, 'TIX-MEGA-1212-0', 1212, N'Phạm Bảo', 'mega_req_212@gmail.com', 'TIX-MEGA-1212-0|E1070|1210', 0, DATEADD(MINUTE, 45, DATEADD(HOUR, 3, DATEADD(DAY, -37, GETDATE())))),
(1512, 'TIX-MEGA-1212-1', 1212, N'Phạm Bảo', 'mega_req_212@gmail.com', 'TIX-MEGA-1212-1|E1070|1210', 0, DATEADD(MINUTE, 45, DATEADD(HOUR, 3, DATEADD(DAY, -37, GETDATE())))),
(1513, 'TIX-MEGA-1213-0', 1213, N'Hoàng Trang', 'mega_req_213@gmail.com', 'TIX-MEGA-1213-0|E1078|1236', 0, DATEADD(MINUTE, 28, DATEADD(HOUR, 0, DATEADD(DAY, -53, GETDATE())))),
(1514, 'TIX-MEGA-1214-0', 1214, N'Trần Bảo', 'mega_req_214@gmail.com', 'TIX-MEGA-1214-0|E1018|1054', 0, DATEADD(MINUTE, 44, DATEADD(HOUR, 13, DATEADD(DAY, -44, GETDATE())))),
(1515, 'TIX-MEGA-1215-0', 1215, N'Nguyễn Lan', 'mega_req_215@gmail.com', 'TIX-MEGA-1215-0|E1078|1236', 0, DATEADD(MINUTE, 37, DATEADD(HOUR, 4, DATEADD(DAY, -26, GETDATE())))),
(1516, 'TIX-MEGA-1215-1', 1215, N'Nguyễn Lan', 'mega_req_215@gmail.com', 'TIX-MEGA-1215-1|E1078|1236', 0, DATEADD(MINUTE, 37, DATEADD(HOUR, 4, DATEADD(DAY, -26, GETDATE())))),
(1517, 'TIX-MEGA-1215-2', 1215, N'Nguyễn Lan', 'mega_req_215@gmail.com', 'TIX-MEGA-1215-2|E1078|1236', 0, DATEADD(MINUTE, 37, DATEADD(HOUR, 4, DATEADD(DAY, -26, GETDATE())))),
(1518, 'TIX-MEGA-1215-3', 1215, N'Nguyễn Lan', 'mega_req_215@gmail.com', 'TIX-MEGA-1215-3|E1078|1236', 0, DATEADD(MINUTE, 37, DATEADD(HOUR, 4, DATEADD(DAY, -26, GETDATE())))),
(1519, 'TIX-MEGA-1216-0', 1216, N'Phạm Trang', 'mega_req_216@gmail.com', 'TIX-MEGA-1216-0|E1024|1074', 0, DATEADD(MINUTE, 53, DATEADD(HOUR, 20, DATEADD(DAY, -14, GETDATE())))),
(1520, 'TIX-MEGA-1217-0', 1217, N'Bùi Hải', 'mega_req_217@gmail.com', 'TIX-MEGA-1217-0|E1083|1251', 0, DATEADD(MINUTE, 4, DATEADD(HOUR, 17, DATEADD(DAY, -41, GETDATE())))),
(1521, 'TIX-MEGA-1217-1', 1217, N'Bùi Hải', 'mega_req_217@gmail.com', 'TIX-MEGA-1217-1|E1083|1251', 0, DATEADD(MINUTE, 4, DATEADD(HOUR, 17, DATEADD(DAY, -41, GETDATE())))),
(1522, 'TIX-MEGA-1217-2', 1217, N'Bùi Hải', 'mega_req_217@gmail.com', 'TIX-MEGA-1217-2|E1083|1251', 0, DATEADD(MINUTE, 4, DATEADD(HOUR, 17, DATEADD(DAY, -41, GETDATE())))),
(1523, 'TIX-MEGA-1218-0', 1218, N'Hoàng Trang', 'mega_req_218@gmail.com', 'TIX-MEGA-1218-0|E1044|1134', 0, DATEADD(MINUTE, 51, DATEADD(HOUR, 0, DATEADD(DAY, -48, GETDATE())))),
(1524, 'TIX-MEGA-1218-1', 1218, N'Hoàng Trang', 'mega_req_218@gmail.com', 'TIX-MEGA-1218-1|E1044|1134', 0, DATEADD(MINUTE, 51, DATEADD(HOUR, 0, DATEADD(DAY, -48, GETDATE())))),
(1525, 'TIX-MEGA-1218-2', 1218, N'Hoàng Trang', 'mega_req_218@gmail.com', 'TIX-MEGA-1218-2|E1044|1134', 0, DATEADD(MINUTE, 51, DATEADD(HOUR, 0, DATEADD(DAY, -48, GETDATE())))),
(1526, 'TIX-MEGA-1218-3', 1218, N'Hoàng Trang', 'mega_req_218@gmail.com', 'TIX-MEGA-1218-3|E1044|1134', 0, DATEADD(MINUTE, 51, DATEADD(HOUR, 0, DATEADD(DAY, -48, GETDATE())))),
(1527, 'TIX-MEGA-1219-0', 1219, N'Huỳnh Phong', 'mega_req_219@gmail.com', 'TIX-MEGA-1219-0|E1090|1272', 1, DATEADD(MINUTE, 40, DATEADD(HOUR, 17, DATEADD(DAY, -50, GETDATE())))),
(1528, 'TIX-MEGA-1220-0', 1220, N'Bùi Trang', 'mega_req_220@gmail.com', 'TIX-MEGA-1220-0|E1097|1293', 0, DATEADD(MINUTE, 38, DATEADD(HOUR, 16, DATEADD(DAY, -12, GETDATE())))),
(1529, 'TIX-MEGA-1221-0', 1221, N'Đặng Thành', 'mega_req_221@gmail.com', 'TIX-MEGA-1221-0|E1086|1258', 0, DATEADD(MINUTE, 45, DATEADD(HOUR, 10, DATEADD(DAY, -48, GETDATE())))),
(1530, 'TIX-MEGA-1221-1', 1221, N'Đặng Thành', 'mega_req_221@gmail.com', 'TIX-MEGA-1221-1|E1086|1258', 0, DATEADD(MINUTE, 45, DATEADD(HOUR, 10, DATEADD(DAY, -48, GETDATE())))),
(1531, 'TIX-MEGA-1221-2', 1221, N'Đặng Thành', 'mega_req_221@gmail.com', 'TIX-MEGA-1221-2|E1086|1258', 1, DATEADD(MINUTE, 45, DATEADD(HOUR, 10, DATEADD(DAY, -48, GETDATE())))),
(1532, 'TIX-MEGA-1221-3', 1221, N'Đặng Thành', 'mega_req_221@gmail.com', 'TIX-MEGA-1221-3|E1086|1258', 1, DATEADD(MINUTE, 45, DATEADD(HOUR, 10, DATEADD(DAY, -48, GETDATE())))),
(1533, 'TIX-MEGA-1222-0', 1222, N'Đỗ Thu', 'mega_req_222@gmail.com', 'TIX-MEGA-1222-0|E1084|1253', 0, DATEADD(MINUTE, 5, DATEADD(HOUR, 1, DATEADD(DAY, 0, GETDATE())))),
(1534, 'TIX-MEGA-1222-1', 1222, N'Đỗ Thu', 'mega_req_222@gmail.com', 'TIX-MEGA-1222-1|E1084|1253', 0, DATEADD(MINUTE, 5, DATEADD(HOUR, 1, DATEADD(DAY, 0, GETDATE())))),
(1535, 'TIX-MEGA-1222-2', 1222, N'Đỗ Thu', 'mega_req_222@gmail.com', 'TIX-MEGA-1222-2|E1084|1253', 0, DATEADD(MINUTE, 5, DATEADD(HOUR, 1, DATEADD(DAY, 0, GETDATE())))),
(1536, 'TIX-MEGA-1223-0', 1223, N'Đặng Thu', 'mega_req_223@gmail.com', 'TIX-MEGA-1223-0|E1063|1190', 0, DATEADD(MINUTE, 57, DATEADD(HOUR, 20, DATEADD(DAY, -35, GETDATE())))),
(1537, 'TIX-MEGA-1224-0', 1224, N'Huỳnh Minh', 'mega_req_224@gmail.com', 'TIX-MEGA-1224-0|E1045|1135', 0, DATEADD(MINUTE, 44, DATEADD(HOUR, 7, DATEADD(DAY, -8, GETDATE())))),
(1538, 'TIX-MEGA-1224-1', 1224, N'Huỳnh Minh', 'mega_req_224@gmail.com', 'TIX-MEGA-1224-1|E1045|1135', 0, DATEADD(MINUTE, 44, DATEADD(HOUR, 7, DATEADD(DAY, -8, GETDATE())))),
(1539, 'TIX-MEGA-1224-2', 1224, N'Huỳnh Minh', 'mega_req_224@gmail.com', 'TIX-MEGA-1224-2|E1045|1135', 0, DATEADD(MINUTE, 44, DATEADD(HOUR, 7, DATEADD(DAY, -8, GETDATE())))),
(1540, 'TIX-MEGA-1225-0', 1225, N'Huỳnh Anh', 'mega_req_225@gmail.com', 'TIX-MEGA-1225-0|E1050|1151', 0, DATEADD(MINUTE, 50, DATEADD(HOUR, 7, DATEADD(DAY, -26, GETDATE())))),
(1541, 'TIX-MEGA-1226-0', 1226, N'Lê Trang', 'mega_req_226@gmail.com', 'TIX-MEGA-1226-0|E1017|1053', 1, DATEADD(MINUTE, 16, DATEADD(HOUR, 16, DATEADD(DAY, -1, GETDATE())))),
(1542, 'TIX-MEGA-1226-1', 1226, N'Lê Trang', 'mega_req_226@gmail.com', 'TIX-MEGA-1226-1|E1017|1053', 1, DATEADD(MINUTE, 16, DATEADD(HOUR, 16, DATEADD(DAY, -1, GETDATE())))),
(1543, 'TIX-MEGA-1226-2', 1226, N'Lê Trang', 'mega_req_226@gmail.com', 'TIX-MEGA-1226-2|E1017|1053', 1, DATEADD(MINUTE, 16, DATEADD(HOUR, 16, DATEADD(DAY, -1, GETDATE())))),
(1544, 'TIX-MEGA-1227-0', 1227, N'Bùi Phong', 'mega_req_227@gmail.com', 'TIX-MEGA-1227-0|E1011|1034', 0, DATEADD(MINUTE, 52, DATEADD(HOUR, 0, DATEADD(DAY, -4, GETDATE())))),
(1545, 'TIX-MEGA-1227-1', 1227, N'Bùi Phong', 'mega_req_227@gmail.com', 'TIX-MEGA-1227-1|E1011|1034', 0, DATEADD(MINUTE, 52, DATEADD(HOUR, 0, DATEADD(DAY, -4, GETDATE())))),
(1546, 'TIX-MEGA-1227-2', 1227, N'Bùi Phong', 'mega_req_227@gmail.com', 'TIX-MEGA-1227-2|E1011|1034', 0, DATEADD(MINUTE, 52, DATEADD(HOUR, 0, DATEADD(DAY, -4, GETDATE())))),
(1547, 'TIX-MEGA-1228-0', 1228, N'Đặng Vân', 'mega_req_228@gmail.com', 'TIX-MEGA-1228-0|E1090|1270', 0, DATEADD(MINUTE, 21, DATEADD(HOUR, 8, DATEADD(DAY, -39, GETDATE())))),
(1548, 'TIX-MEGA-1229-0', 1229, N'Đặng Bảo', 'mega_req_229@gmail.com', 'TIX-MEGA-1229-0|E1026|1079', 0, DATEADD(MINUTE, 14, DATEADD(HOUR, 10, DATEADD(DAY, -38, GETDATE())))),
(1549, 'TIX-MEGA-1229-1', 1229, N'Đặng Bảo', 'mega_req_229@gmail.com', 'TIX-MEGA-1229-1|E1026|1079', 0, DATEADD(MINUTE, 14, DATEADD(HOUR, 10, DATEADD(DAY, -38, GETDATE())))),
(1550, 'TIX-MEGA-1230-0', 1230, N'Phạm Bảo', 'mega_req_230@gmail.com', 'TIX-MEGA-1230-0|E1037|1112', 0, DATEADD(MINUTE, 57, DATEADD(HOUR, 16, DATEADD(DAY, -5, GETDATE())))),
(1551, 'TIX-MEGA-1230-1', 1230, N'Phạm Bảo', 'mega_req_230@gmail.com', 'TIX-MEGA-1230-1|E1037|1112', 0, DATEADD(MINUTE, 57, DATEADD(HOUR, 16, DATEADD(DAY, -5, GETDATE())))),
(1552, 'TIX-MEGA-1230-2', 1230, N'Phạm Bảo', 'mega_req_230@gmail.com', 'TIX-MEGA-1230-2|E1037|1112', 0, DATEADD(MINUTE, 57, DATEADD(HOUR, 16, DATEADD(DAY, -5, GETDATE())))),
(1553, 'TIX-MEGA-1231-0', 1231, N'Bùi Hùng', 'mega_req_231@gmail.com', 'TIX-MEGA-1231-0|E1074|1224', 0, DATEADD(MINUTE, 53, DATEADD(HOUR, 15, DATEADD(DAY, -44, GETDATE())))),
(1554, 'TIX-MEGA-1231-1', 1231, N'Bùi Hùng', 'mega_req_231@gmail.com', 'TIX-MEGA-1231-1|E1074|1224', 0, DATEADD(MINUTE, 53, DATEADD(HOUR, 15, DATEADD(DAY, -44, GETDATE())))),
(1555, 'TIX-MEGA-1232-0', 1232, N'Đỗ Trang', 'mega_req_232@gmail.com', 'TIX-MEGA-1232-0|E1054|1163', 0, DATEADD(MINUTE, 53, DATEADD(HOUR, 19, DATEADD(DAY, -26, GETDATE())))),
(1556, 'TIX-MEGA-1232-1', 1232, N'Đỗ Trang', 'mega_req_232@gmail.com', 'TIX-MEGA-1232-1|E1054|1163', 0, DATEADD(MINUTE, 53, DATEADD(HOUR, 19, DATEADD(DAY, -26, GETDATE())))),
(1557, 'TIX-MEGA-1233-0', 1233, N'Hoàng Phong', 'mega_req_233@gmail.com', 'TIX-MEGA-1233-0|E1063|1189', 0, DATEADD(MINUTE, 8, DATEADD(HOUR, 0, DATEADD(DAY, -4, GETDATE())))),
(1558, 'TIX-MEGA-1233-1', 1233, N'Hoàng Phong', 'mega_req_233@gmail.com', 'TIX-MEGA-1233-1|E1063|1189', 0, DATEADD(MINUTE, 8, DATEADD(HOUR, 0, DATEADD(DAY, -4, GETDATE())))),
(1559, 'TIX-MEGA-1233-2', 1233, N'Hoàng Phong', 'mega_req_233@gmail.com', 'TIX-MEGA-1233-2|E1063|1189', 0, DATEADD(MINUTE, 8, DATEADD(HOUR, 0, DATEADD(DAY, -4, GETDATE())))),
(1560, 'TIX-MEGA-1234-0', 1234, N'Đặng Kiên', 'mega_req_234@gmail.com', 'TIX-MEGA-1234-0|E1073|1221', 0, DATEADD(MINUTE, 17, DATEADD(HOUR, 6, DATEADD(DAY, -24, GETDATE())))),
(1561, 'TIX-MEGA-1234-1', 1234, N'Đặng Kiên', 'mega_req_234@gmail.com', 'TIX-MEGA-1234-1|E1073|1221', 0, DATEADD(MINUTE, 17, DATEADD(HOUR, 6, DATEADD(DAY, -24, GETDATE())))),
(1562, 'TIX-MEGA-1234-2', 1234, N'Đặng Kiên', 'mega_req_234@gmail.com', 'TIX-MEGA-1234-2|E1073|1221', 0, DATEADD(MINUTE, 17, DATEADD(HOUR, 6, DATEADD(DAY, -24, GETDATE())))),
(1563, 'TIX-MEGA-1234-3', 1234, N'Đặng Kiên', 'mega_req_234@gmail.com', 'TIX-MEGA-1234-3|E1073|1221', 0, DATEADD(MINUTE, 17, DATEADD(HOUR, 6, DATEADD(DAY, -24, GETDATE())))),
(1564, 'TIX-MEGA-1235-0', 1235, N'Lê Bảo', 'mega_req_235@gmail.com', 'TIX-MEGA-1235-0|E1044|1134', 0, DATEADD(MINUTE, 45, DATEADD(HOUR, 16, DATEADD(DAY, -12, GETDATE())))),
(1565, 'TIX-MEGA-1235-1', 1235, N'Lê Bảo', 'mega_req_235@gmail.com', 'TIX-MEGA-1235-1|E1044|1134', 0, DATEADD(MINUTE, 45, DATEADD(HOUR, 16, DATEADD(DAY, -12, GETDATE())))),
(1566, 'TIX-MEGA-1235-2', 1235, N'Lê Bảo', 'mega_req_235@gmail.com', 'TIX-MEGA-1235-2|E1044|1134', 0, DATEADD(MINUTE, 45, DATEADD(HOUR, 16, DATEADD(DAY, -12, GETDATE())))),
(1567, 'TIX-MEGA-1236-0', 1236, N'Nguyễn Thu', 'mega_req_236@gmail.com', 'TIX-MEGA-1236-0|E1034|1104', 0, DATEADD(MINUTE, 9, DATEADD(HOUR, 6, DATEADD(DAY, -57, GETDATE())))),
(1568, 'TIX-MEGA-1236-1', 1236, N'Nguyễn Thu', 'mega_req_236@gmail.com', 'TIX-MEGA-1236-1|E1034|1104', 0, DATEADD(MINUTE, 9, DATEADD(HOUR, 6, DATEADD(DAY, -57, GETDATE())))),
(1569, 'TIX-MEGA-1236-2', 1236, N'Nguyễn Thu', 'mega_req_236@gmail.com', 'TIX-MEGA-1236-2|E1034|1104', 0, DATEADD(MINUTE, 9, DATEADD(HOUR, 6, DATEADD(DAY, -57, GETDATE())))),
(1570, 'TIX-MEGA-1237-0', 1237, N'Trần Khoa', 'mega_req_237@gmail.com', 'TIX-MEGA-1237-0|E1076|1230', 0, DATEADD(MINUTE, 54, DATEADD(HOUR, 2, DATEADD(DAY, -52, GETDATE())))),
(1571, 'TIX-MEGA-1237-1', 1237, N'Trần Khoa', 'mega_req_237@gmail.com', 'TIX-MEGA-1237-1|E1076|1230', 0, DATEADD(MINUTE, 54, DATEADD(HOUR, 2, DATEADD(DAY, -52, GETDATE())))),
(1572, 'TIX-MEGA-1237-2', 1237, N'Trần Khoa', 'mega_req_237@gmail.com', 'TIX-MEGA-1237-2|E1076|1230', 0, DATEADD(MINUTE, 54, DATEADD(HOUR, 2, DATEADD(DAY, -52, GETDATE())))),
(1573, 'TIX-MEGA-1238-0', 1238, N'Đỗ Vân', 'mega_req_238@gmail.com', 'TIX-MEGA-1238-0|E1011|1035', 1, DATEADD(MINUTE, 12, DATEADD(HOUR, 2, DATEADD(DAY, -47, GETDATE())))),
(1574, 'TIX-MEGA-1238-1', 1238, N'Đỗ Vân', 'mega_req_238@gmail.com', 'TIX-MEGA-1238-1|E1011|1035', 0, DATEADD(MINUTE, 12, DATEADD(HOUR, 2, DATEADD(DAY, -47, GETDATE())))),
(1575, 'TIX-MEGA-1238-2', 1238, N'Đỗ Vân', 'mega_req_238@gmail.com', 'TIX-MEGA-1238-2|E1011|1035', 0, DATEADD(MINUTE, 12, DATEADD(HOUR, 2, DATEADD(DAY, -47, GETDATE())))),
(1576, 'TIX-MEGA-1238-3', 1238, N'Đỗ Vân', 'mega_req_238@gmail.com', 'TIX-MEGA-1238-3|E1011|1035', 0, DATEADD(MINUTE, 12, DATEADD(HOUR, 2, DATEADD(DAY, -47, GETDATE())))),
(1577, 'TIX-MEGA-1239-0', 1239, N'Hoàng Thành', 'mega_req_239@gmail.com', 'TIX-MEGA-1239-0|E1014|1042', 1, DATEADD(MINUTE, 10, DATEADD(HOUR, 5, DATEADD(DAY, -38, GETDATE())))),
(1578, 'TIX-MEGA-1239-1', 1239, N'Hoàng Thành', 'mega_req_239@gmail.com', 'TIX-MEGA-1239-1|E1014|1042', 0, DATEADD(MINUTE, 10, DATEADD(HOUR, 5, DATEADD(DAY, -38, GETDATE())))),
(1579, 'TIX-MEGA-1239-2', 1239, N'Hoàng Thành', 'mega_req_239@gmail.com', 'TIX-MEGA-1239-2|E1014|1042', 1, DATEADD(MINUTE, 10, DATEADD(HOUR, 5, DATEADD(DAY, -38, GETDATE())))),
(1580, 'TIX-MEGA-1240-0', 1240, N'Đỗ Phong', 'mega_req_240@gmail.com', 'TIX-MEGA-1240-0|E1011|1035', 0, DATEADD(MINUTE, 20, DATEADD(HOUR, 8, DATEADD(DAY, -21, GETDATE())))),
(1581, 'TIX-MEGA-1240-1', 1240, N'Đỗ Phong', 'mega_req_240@gmail.com', 'TIX-MEGA-1240-1|E1011|1035', 0, DATEADD(MINUTE, 20, DATEADD(HOUR, 8, DATEADD(DAY, -21, GETDATE())))),
(1582, 'TIX-MEGA-1240-2', 1240, N'Đỗ Phong', 'mega_req_240@gmail.com', 'TIX-MEGA-1240-2|E1011|1035', 0, DATEADD(MINUTE, 20, DATEADD(HOUR, 8, DATEADD(DAY, -21, GETDATE())))),
(1583, 'TIX-MEGA-1241-0', 1241, N'Lê Vân', 'mega_req_241@gmail.com', 'TIX-MEGA-1241-0|E1076|1230', 0, DATEADD(MINUTE, 52, DATEADD(HOUR, 4, DATEADD(DAY, -42, GETDATE())))),
(1584, 'TIX-MEGA-1241-1', 1241, N'Lê Vân', 'mega_req_241@gmail.com', 'TIX-MEGA-1241-1|E1076|1230', 0, DATEADD(MINUTE, 52, DATEADD(HOUR, 4, DATEADD(DAY, -42, GETDATE())))),
(1585, 'TIX-MEGA-1241-2', 1241, N'Lê Vân', 'mega_req_241@gmail.com', 'TIX-MEGA-1241-2|E1076|1230', 0, DATEADD(MINUTE, 52, DATEADD(HOUR, 4, DATEADD(DAY, -42, GETDATE())))),
(1586, 'TIX-MEGA-1241-3', 1241, N'Lê Vân', 'mega_req_241@gmail.com', 'TIX-MEGA-1241-3|E1076|1230', 0, DATEADD(MINUTE, 52, DATEADD(HOUR, 4, DATEADD(DAY, -42, GETDATE())))),
(1587, 'TIX-MEGA-1242-0', 1242, N'Đỗ Thu', 'mega_req_242@gmail.com', 'TIX-MEGA-1242-0|E1021|1065', 0, DATEADD(MINUTE, 48, DATEADD(HOUR, 3, DATEADD(DAY, -31, GETDATE())))),
(1588, 'TIX-MEGA-1242-1', 1242, N'Đỗ Thu', 'mega_req_242@gmail.com', 'TIX-MEGA-1242-1|E1021|1065', 0, DATEADD(MINUTE, 48, DATEADD(HOUR, 3, DATEADD(DAY, -31, GETDATE())))),
(1589, 'TIX-MEGA-1242-2', 1242, N'Đỗ Thu', 'mega_req_242@gmail.com', 'TIX-MEGA-1242-2|E1021|1065', 0, DATEADD(MINUTE, 48, DATEADD(HOUR, 3, DATEADD(DAY, -31, GETDATE())))),
(1590, 'TIX-MEGA-1243-0', 1243, N'Hoàng Bảo', 'mega_req_243@gmail.com', 'TIX-MEGA-1243-0|E1045|1136', 0, DATEADD(MINUTE, 19, DATEADD(HOUR, 12, DATEADD(DAY, -33, GETDATE())))),
(1591, 'TIX-MEGA-1243-1', 1243, N'Hoàng Bảo', 'mega_req_243@gmail.com', 'TIX-MEGA-1243-1|E1045|1136', 0, DATEADD(MINUTE, 19, DATEADD(HOUR, 12, DATEADD(DAY, -33, GETDATE())))),
(1592, 'TIX-MEGA-1244-0', 1244, N'Vũ Trang', 'mega_req_244@gmail.com', 'TIX-MEGA-1244-0|E1053|1159', 0, DATEADD(MINUTE, 21, DATEADD(HOUR, 2, DATEADD(DAY, -5, GETDATE())))),
(1593, 'TIX-MEGA-1244-1', 1244, N'Vũ Trang', 'mega_req_244@gmail.com', 'TIX-MEGA-1244-1|E1053|1159', 0, DATEADD(MINUTE, 21, DATEADD(HOUR, 2, DATEADD(DAY, -5, GETDATE())))),
(1594, 'TIX-MEGA-1244-2', 1244, N'Vũ Trang', 'mega_req_244@gmail.com', 'TIX-MEGA-1244-2|E1053|1159', 1, DATEADD(MINUTE, 21, DATEADD(HOUR, 2, DATEADD(DAY, -5, GETDATE())))),
(1595, 'TIX-MEGA-1245-0', 1245, N'Đặng Anh', 'mega_req_245@gmail.com', 'TIX-MEGA-1245-0|E1026|1079', 0, DATEADD(MINUTE, 23, DATEADD(HOUR, 15, DATEADD(DAY, 0, GETDATE())))),
(1596, 'TIX-MEGA-1245-1', 1245, N'Đặng Anh', 'mega_req_245@gmail.com', 'TIX-MEGA-1245-1|E1026|1079', 0, DATEADD(MINUTE, 23, DATEADD(HOUR, 15, DATEADD(DAY, 0, GETDATE())))),
(1597, 'TIX-MEGA-1246-0', 1246, N'Bùi Thu', 'mega_req_246@gmail.com', 'TIX-MEGA-1246-0|E1039|1118', 0, DATEADD(MINUTE, 24, DATEADD(HOUR, 7, DATEADD(DAY, -55, GETDATE())))),
(1598, 'TIX-MEGA-1246-1', 1246, N'Bùi Thu', 'mega_req_246@gmail.com', 'TIX-MEGA-1246-1|E1039|1118', 0, DATEADD(MINUTE, 24, DATEADD(HOUR, 7, DATEADD(DAY, -55, GETDATE())))),
(1599, 'TIX-MEGA-1247-0', 1247, N'Phạm Hùng', 'mega_req_247@gmail.com', 'TIX-MEGA-1247-0|E1060|1180', 0, DATEADD(MINUTE, 10, DATEADD(HOUR, 6, DATEADD(DAY, -4, GETDATE())))),
(1600, 'TIX-MEGA-1247-1', 1247, N'Phạm Hùng', 'mega_req_247@gmail.com', 'TIX-MEGA-1247-1|E1060|1180', 0, DATEADD(MINUTE, 10, DATEADD(HOUR, 6, DATEADD(DAY, -4, GETDATE())))),
(1601, 'TIX-MEGA-1247-2', 1247, N'Phạm Hùng', 'mega_req_247@gmail.com', 'TIX-MEGA-1247-2|E1060|1180', 0, DATEADD(MINUTE, 10, DATEADD(HOUR, 6, DATEADD(DAY, -4, GETDATE())))),
(1602, 'TIX-MEGA-1248-0', 1248, N'Phạm Khoa', 'mega_req_248@gmail.com', 'TIX-MEGA-1248-0|E1075|1227', 0, DATEADD(MINUTE, 35, DATEADD(HOUR, 8, DATEADD(DAY, -20, GETDATE())))),
(1603, 'TIX-MEGA-1248-1', 1248, N'Phạm Khoa', 'mega_req_248@gmail.com', 'TIX-MEGA-1248-1|E1075|1227', 0, DATEADD(MINUTE, 35, DATEADD(HOUR, 8, DATEADD(DAY, -20, GETDATE())))),
(1604, 'TIX-MEGA-1248-2', 1248, N'Phạm Khoa', 'mega_req_248@gmail.com', 'TIX-MEGA-1248-2|E1075|1227', 0, DATEADD(MINUTE, 35, DATEADD(HOUR, 8, DATEADD(DAY, -20, GETDATE()))));
INSERT INTO Tickets (ticket_id, ticket_code, order_item_id, attendee_name, attendee_email, qr_code, is_checked_in, created_at) VALUES
(1605, 'TIX-MEGA-1249-0', 1249, N'Trần Vân', 'mega_req_249@gmail.com', 'TIX-MEGA-1249-0|E1057|1171', 1, DATEADD(MINUTE, 35, DATEADD(HOUR, 7, DATEADD(DAY, 0, GETDATE())))),
(1606, 'TIX-MEGA-1249-1', 1249, N'Trần Vân', 'mega_req_249@gmail.com', 'TIX-MEGA-1249-1|E1057|1171', 0, DATEADD(MINUTE, 35, DATEADD(HOUR, 7, DATEADD(DAY, 0, GETDATE())))),
(1607, 'TIX-MEGA-1249-2', 1249, N'Trần Vân', 'mega_req_249@gmail.com', 'TIX-MEGA-1249-2|E1057|1171', 0, DATEADD(MINUTE, 35, DATEADD(HOUR, 7, DATEADD(DAY, 0, GETDATE())))),
(1608, 'TIX-MEGA-1250-0', 1250, N'Vũ Kiên', 'mega_req_250@gmail.com', 'TIX-MEGA-1250-0|E1053|1160', 0, DATEADD(MINUTE, 56, DATEADD(HOUR, 9, DATEADD(DAY, -9, GETDATE())))),
(1609, 'TIX-MEGA-1251-0', 1251, N'Đỗ Thành', 'mega_req_251@gmail.com', 'TIX-MEGA-1251-0|E1020|1060', 0, DATEADD(MINUTE, 36, DATEADD(HOUR, 13, DATEADD(DAY, -14, GETDATE())))),
(1610, 'TIX-MEGA-1251-1', 1251, N'Đỗ Thành', 'mega_req_251@gmail.com', 'TIX-MEGA-1251-1|E1020|1060', 0, DATEADD(MINUTE, 36, DATEADD(HOUR, 13, DATEADD(DAY, -14, GETDATE())))),
(1611, 'TIX-MEGA-1252-0', 1252, N'Huỳnh Thành', 'mega_req_252@gmail.com', 'TIX-MEGA-1252-0|E1032|1096', 0, DATEADD(MINUTE, 51, DATEADD(HOUR, 19, DATEADD(DAY, -28, GETDATE())))),
(1612, 'TIX-MEGA-1252-1', 1252, N'Huỳnh Thành', 'mega_req_252@gmail.com', 'TIX-MEGA-1252-1|E1032|1096', 0, DATEADD(MINUTE, 51, DATEADD(HOUR, 19, DATEADD(DAY, -28, GETDATE())))),
(1613, 'TIX-MEGA-1252-2', 1252, N'Huỳnh Thành', 'mega_req_252@gmail.com', 'TIX-MEGA-1252-2|E1032|1096', 0, DATEADD(MINUTE, 51, DATEADD(HOUR, 19, DATEADD(DAY, -28, GETDATE())))),
(1614, 'TIX-MEGA-1253-0', 1253, N'Lê Linh', 'mega_req_253@gmail.com', 'TIX-MEGA-1253-0|E1022|1066', 0, DATEADD(MINUTE, 19, DATEADD(HOUR, 9, DATEADD(DAY, -17, GETDATE())))),
(1615, 'TIX-MEGA-1254-0', 1254, N'Đặng Phong', 'mega_req_254@gmail.com', 'TIX-MEGA-1254-0|E1077|1233', 0, DATEADD(MINUTE, 10, DATEADD(HOUR, 16, DATEADD(DAY, -59, GETDATE())))),
(1616, 'TIX-MEGA-1255-0', 1255, N'Bùi Minh', 'mega_req_255@gmail.com', 'TIX-MEGA-1255-0|E1063|1190', 0, DATEADD(MINUTE, 27, DATEADD(HOUR, 15, DATEADD(DAY, -31, GETDATE())))),
(1617, 'TIX-MEGA-1255-1', 1255, N'Bùi Minh', 'mega_req_255@gmail.com', 'TIX-MEGA-1255-1|E1063|1190', 0, DATEADD(MINUTE, 27, DATEADD(HOUR, 15, DATEADD(DAY, -31, GETDATE())))),
(1618, 'TIX-MEGA-1255-2', 1255, N'Bùi Minh', 'mega_req_255@gmail.com', 'TIX-MEGA-1255-2|E1063|1190', 0, DATEADD(MINUTE, 27, DATEADD(HOUR, 15, DATEADD(DAY, -31, GETDATE())))),
(1619, 'TIX-MEGA-1255-3', 1255, N'Bùi Minh', 'mega_req_255@gmail.com', 'TIX-MEGA-1255-3|E1063|1190', 0, DATEADD(MINUTE, 27, DATEADD(HOUR, 15, DATEADD(DAY, -31, GETDATE())))),
(1620, 'TIX-MEGA-1256-0', 1256, N'Phạm Phong', 'mega_req_256@gmail.com', 'TIX-MEGA-1256-0|E1041|1125', 0, DATEADD(MINUTE, 11, DATEADD(HOUR, 16, DATEADD(DAY, -31, GETDATE())))),
(1621, 'TIX-MEGA-1256-1', 1256, N'Phạm Phong', 'mega_req_256@gmail.com', 'TIX-MEGA-1256-1|E1041|1125', 0, DATEADD(MINUTE, 11, DATEADD(HOUR, 16, DATEADD(DAY, -31, GETDATE())))),
(1622, 'TIX-MEGA-1256-2', 1256, N'Phạm Phong', 'mega_req_256@gmail.com', 'TIX-MEGA-1256-2|E1041|1125', 0, DATEADD(MINUTE, 11, DATEADD(HOUR, 16, DATEADD(DAY, -31, GETDATE())))),
(1623, 'TIX-MEGA-1256-3', 1256, N'Phạm Phong', 'mega_req_256@gmail.com', 'TIX-MEGA-1256-3|E1041|1125', 0, DATEADD(MINUTE, 11, DATEADD(HOUR, 16, DATEADD(DAY, -31, GETDATE())))),
(1624, 'TIX-MEGA-1257-0', 1257, N'Vũ Hùng', 'mega_req_257@gmail.com', 'TIX-MEGA-1257-0|E1084|1253', 0, DATEADD(MINUTE, 38, DATEADD(HOUR, 8, DATEADD(DAY, -15, GETDATE())))),
(1625, 'TIX-MEGA-1257-1', 1257, N'Vũ Hùng', 'mega_req_257@gmail.com', 'TIX-MEGA-1257-1|E1084|1253', 0, DATEADD(MINUTE, 38, DATEADD(HOUR, 8, DATEADD(DAY, -15, GETDATE())))),
(1626, 'TIX-MEGA-1257-2', 1257, N'Vũ Hùng', 'mega_req_257@gmail.com', 'TIX-MEGA-1257-2|E1084|1253', 0, DATEADD(MINUTE, 38, DATEADD(HOUR, 8, DATEADD(DAY, -15, GETDATE())))),
(1627, 'TIX-MEGA-1258-0', 1258, N'Phạm Khoa', 'mega_req_258@gmail.com', 'TIX-MEGA-1258-0|E1000|1001', 0, DATEADD(MINUTE, 45, DATEADD(HOUR, 9, DATEADD(DAY, -34, GETDATE())))),
(1628, 'TIX-MEGA-1258-1', 1258, N'Phạm Khoa', 'mega_req_258@gmail.com', 'TIX-MEGA-1258-1|E1000|1001', 0, DATEADD(MINUTE, 45, DATEADD(HOUR, 9, DATEADD(DAY, -34, GETDATE())))),
(1629, 'TIX-MEGA-1259-0', 1259, N'Trần Linh', 'mega_req_259@gmail.com', 'TIX-MEGA-1259-0|E1076|1229', 0, DATEADD(MINUTE, 40, DATEADD(HOUR, 11, DATEADD(DAY, -18, GETDATE())))),
(1630, 'TIX-MEGA-1259-1', 1259, N'Trần Linh', 'mega_req_259@gmail.com', 'TIX-MEGA-1259-1|E1076|1229', 0, DATEADD(MINUTE, 40, DATEADD(HOUR, 11, DATEADD(DAY, -18, GETDATE())))),
(1631, 'TIX-MEGA-1259-2', 1259, N'Trần Linh', 'mega_req_259@gmail.com', 'TIX-MEGA-1259-2|E1076|1229', 0, DATEADD(MINUTE, 40, DATEADD(HOUR, 11, DATEADD(DAY, -18, GETDATE())))),
(1632, 'TIX-MEGA-1260-0', 1260, N'Nguyễn Trang', 'mega_req_260@gmail.com', 'TIX-MEGA-1260-0|E1002|1008', 0, DATEADD(MINUTE, 56, DATEADD(HOUR, 21, DATEADD(DAY, -1, GETDATE())))),
(1633, 'TIX-MEGA-1261-0', 1261, N'Bùi Bảo', 'mega_req_261@gmail.com', 'TIX-MEGA-1261-0|E1011|1035', 0, DATEADD(MINUTE, 1, DATEADD(HOUR, 7, DATEADD(DAY, -57, GETDATE())))),
(1634, 'TIX-MEGA-1261-1', 1261, N'Bùi Bảo', 'mega_req_261@gmail.com', 'TIX-MEGA-1261-1|E1011|1035', 0, DATEADD(MINUTE, 1, DATEADD(HOUR, 7, DATEADD(DAY, -57, GETDATE())))),
(1635, 'TIX-MEGA-1261-2', 1261, N'Bùi Bảo', 'mega_req_261@gmail.com', 'TIX-MEGA-1261-2|E1011|1035', 0, DATEADD(MINUTE, 1, DATEADD(HOUR, 7, DATEADD(DAY, -57, GETDATE())))),
(1636, 'TIX-MEGA-1261-3', 1261, N'Bùi Bảo', 'mega_req_261@gmail.com', 'TIX-MEGA-1261-3|E1011|1035', 0, DATEADD(MINUTE, 1, DATEADD(HOUR, 7, DATEADD(DAY, -57, GETDATE())))),
(1637, 'TIX-MEGA-1262-0', 1262, N'Hoàng Phong', 'mega_req_262@gmail.com', 'TIX-MEGA-1262-0|E1061|1185', 1, DATEADD(MINUTE, 30, DATEADD(HOUR, 7, DATEADD(DAY, -54, GETDATE())))),
(1638, 'TIX-MEGA-1262-1', 1262, N'Hoàng Phong', 'mega_req_262@gmail.com', 'TIX-MEGA-1262-1|E1061|1185', 0, DATEADD(MINUTE, 30, DATEADD(HOUR, 7, DATEADD(DAY, -54, GETDATE())))),
(1639, 'TIX-MEGA-1263-0', 1263, N'Bùi Lan', 'mega_req_263@gmail.com', 'TIX-MEGA-1263-0|E1009|1029', 0, DATEADD(MINUTE, 6, DATEADD(HOUR, 5, DATEADD(DAY, -21, GETDATE())))),
(1640, 'TIX-MEGA-1263-1', 1263, N'Bùi Lan', 'mega_req_263@gmail.com', 'TIX-MEGA-1263-1|E1009|1029', 0, DATEADD(MINUTE, 6, DATEADD(HOUR, 5, DATEADD(DAY, -21, GETDATE())))),
(1641, 'TIX-MEGA-1263-2', 1263, N'Bùi Lan', 'mega_req_263@gmail.com', 'TIX-MEGA-1263-2|E1009|1029', 1, DATEADD(MINUTE, 6, DATEADD(HOUR, 5, DATEADD(DAY, -21, GETDATE())))),
(1642, 'TIX-MEGA-1264-0', 1264, N'Bùi Minh', 'mega_req_264@gmail.com', 'TIX-MEGA-1264-0|E1083|1249', 0, DATEADD(MINUTE, 20, DATEADD(HOUR, 19, DATEADD(DAY, -37, GETDATE())))),
(1643, 'TIX-MEGA-1265-0', 1265, N'Lê Hùng', 'mega_req_265@gmail.com', 'TIX-MEGA-1265-0|E1089|1268', 0, DATEADD(MINUTE, 45, DATEADD(HOUR, 23, DATEADD(DAY, -20, GETDATE())))),
(1644, 'TIX-MEGA-1266-0', 1266, N'Bùi Lan', 'mega_req_266@gmail.com', 'TIX-MEGA-1266-0|E1013|1041', 0, DATEADD(MINUTE, 57, DATEADD(HOUR, 12, DATEADD(DAY, -4, GETDATE())))),
(1645, 'TIX-MEGA-1266-1', 1266, N'Bùi Lan', 'mega_req_266@gmail.com', 'TIX-MEGA-1266-1|E1013|1041', 0, DATEADD(MINUTE, 57, DATEADD(HOUR, 12, DATEADD(DAY, -4, GETDATE())))),
(1646, 'TIX-MEGA-1266-2', 1266, N'Bùi Lan', 'mega_req_266@gmail.com', 'TIX-MEGA-1266-2|E1013|1041', 0, DATEADD(MINUTE, 57, DATEADD(HOUR, 12, DATEADD(DAY, -4, GETDATE())))),
(1647, 'TIX-MEGA-1266-3', 1266, N'Bùi Lan', 'mega_req_266@gmail.com', 'TIX-MEGA-1266-3|E1013|1041', 0, DATEADD(MINUTE, 57, DATEADD(HOUR, 12, DATEADD(DAY, -4, GETDATE())))),
(1648, 'TIX-MEGA-1267-0', 1267, N'Bùi Vân', 'mega_req_267@gmail.com', 'TIX-MEGA-1267-0|E1084|1252', 0, DATEADD(MINUTE, 41, DATEADD(HOUR, 12, DATEADD(DAY, -32, GETDATE())))),
(1649, 'TIX-MEGA-1267-1', 1267, N'Bùi Vân', 'mega_req_267@gmail.com', 'TIX-MEGA-1267-1|E1084|1252', 0, DATEADD(MINUTE, 41, DATEADD(HOUR, 12, DATEADD(DAY, -32, GETDATE())))),
(1650, 'TIX-MEGA-1267-2', 1267, N'Bùi Vân', 'mega_req_267@gmail.com', 'TIX-MEGA-1267-2|E1084|1252', 0, DATEADD(MINUTE, 41, DATEADD(HOUR, 12, DATEADD(DAY, -32, GETDATE())))),
(1651, 'TIX-MEGA-1267-3', 1267, N'Bùi Vân', 'mega_req_267@gmail.com', 'TIX-MEGA-1267-3|E1084|1252', 0, DATEADD(MINUTE, 41, DATEADD(HOUR, 12, DATEADD(DAY, -32, GETDATE())))),
(1652, 'TIX-MEGA-1268-0', 1268, N'Đặng Minh', 'mega_req_268@gmail.com', 'TIX-MEGA-1268-0|E1026|1078', 0, DATEADD(MINUTE, 38, DATEADD(HOUR, 7, DATEADD(DAY, -10, GETDATE())))),
(1653, 'TIX-MEGA-1268-1', 1268, N'Đặng Minh', 'mega_req_268@gmail.com', 'TIX-MEGA-1268-1|E1026|1078', 1, DATEADD(MINUTE, 38, DATEADD(HOUR, 7, DATEADD(DAY, -10, GETDATE())))),
(1654, 'TIX-MEGA-1268-2', 1268, N'Đặng Minh', 'mega_req_268@gmail.com', 'TIX-MEGA-1268-2|E1026|1078', 0, DATEADD(MINUTE, 38, DATEADD(HOUR, 7, DATEADD(DAY, -10, GETDATE())))),
(1655, 'TIX-MEGA-1269-0', 1269, N'Trần Trang', 'mega_req_269@gmail.com', 'TIX-MEGA-1269-0|E1085|1256', 0, DATEADD(MINUTE, 4, DATEADD(HOUR, 9, DATEADD(DAY, -56, GETDATE())))),
(1656, 'TIX-MEGA-1269-1', 1269, N'Trần Trang', 'mega_req_269@gmail.com', 'TIX-MEGA-1269-1|E1085|1256', 0, DATEADD(MINUTE, 4, DATEADD(HOUR, 9, DATEADD(DAY, -56, GETDATE())))),
(1657, 'TIX-MEGA-1269-2', 1269, N'Trần Trang', 'mega_req_269@gmail.com', 'TIX-MEGA-1269-2|E1085|1256', 0, DATEADD(MINUTE, 4, DATEADD(HOUR, 9, DATEADD(DAY, -56, GETDATE())))),
(1658, 'TIX-MEGA-1270-0', 1270, N'Vũ Thành', 'mega_req_270@gmail.com', 'TIX-MEGA-1270-0|E1058|1175', 0, DATEADD(MINUTE, 48, DATEADD(HOUR, 16, DATEADD(DAY, -30, GETDATE())))),
(1659, 'TIX-MEGA-1270-1', 1270, N'Vũ Thành', 'mega_req_270@gmail.com', 'TIX-MEGA-1270-1|E1058|1175', 0, DATEADD(MINUTE, 48, DATEADD(HOUR, 16, DATEADD(DAY, -30, GETDATE())))),
(1660, 'TIX-MEGA-1271-0', 1271, N'Trần Phong', 'mega_req_271@gmail.com', 'TIX-MEGA-1271-0|E1096|1289', 0, DATEADD(MINUTE, 10, DATEADD(HOUR, 2, DATEADD(DAY, -1, GETDATE())))),
(1661, 'TIX-MEGA-1271-1', 1271, N'Trần Phong', 'mega_req_271@gmail.com', 'TIX-MEGA-1271-1|E1096|1289', 0, DATEADD(MINUTE, 10, DATEADD(HOUR, 2, DATEADD(DAY, -1, GETDATE())))),
(1662, 'TIX-MEGA-1272-0', 1272, N'Nguyễn Trang', 'mega_req_272@gmail.com', 'TIX-MEGA-1272-0|E1098|1294', 1, DATEADD(MINUTE, 59, DATEADD(HOUR, 12, DATEADD(DAY, -7, GETDATE())))),
(1663, 'TIX-MEGA-1273-0', 1273, N'Nguyễn Minh', 'mega_req_273@gmail.com', 'TIX-MEGA-1273-0|E1081|1243', 0, DATEADD(MINUTE, 1, DATEADD(HOUR, 7, DATEADD(DAY, -51, GETDATE())))),
(1664, 'TIX-MEGA-1273-1', 1273, N'Nguyễn Minh', 'mega_req_273@gmail.com', 'TIX-MEGA-1273-1|E1081|1243', 0, DATEADD(MINUTE, 1, DATEADD(HOUR, 7, DATEADD(DAY, -51, GETDATE())))),
(1665, 'TIX-MEGA-1273-2', 1273, N'Nguyễn Minh', 'mega_req_273@gmail.com', 'TIX-MEGA-1273-2|E1081|1243', 0, DATEADD(MINUTE, 1, DATEADD(HOUR, 7, DATEADD(DAY, -51, GETDATE())))),
(1666, 'TIX-MEGA-1273-3', 1273, N'Nguyễn Minh', 'mega_req_273@gmail.com', 'TIX-MEGA-1273-3|E1081|1243', 0, DATEADD(MINUTE, 1, DATEADD(HOUR, 7, DATEADD(DAY, -51, GETDATE())))),
(1667, 'TIX-MEGA-1274-0', 1274, N'Hoàng Hải', 'mega_req_274@gmail.com', 'TIX-MEGA-1274-0|E1034|1104', 0, DATEADD(MINUTE, 27, DATEADD(HOUR, 8, DATEADD(DAY, -17, GETDATE())))),
(1668, 'TIX-MEGA-1274-1', 1274, N'Hoàng Hải', 'mega_req_274@gmail.com', 'TIX-MEGA-1274-1|E1034|1104', 0, DATEADD(MINUTE, 27, DATEADD(HOUR, 8, DATEADD(DAY, -17, GETDATE())))),
(1669, 'TIX-MEGA-1275-0', 1275, N'Bùi Phong', 'mega_req_275@gmail.com', 'TIX-MEGA-1275-0|E1051|1153', 0, DATEADD(MINUTE, 49, DATEADD(HOUR, 18, DATEADD(DAY, -39, GETDATE())))),
(1670, 'TIX-MEGA-1275-1', 1275, N'Bùi Phong', 'mega_req_275@gmail.com', 'TIX-MEGA-1275-1|E1051|1153', 0, DATEADD(MINUTE, 49, DATEADD(HOUR, 18, DATEADD(DAY, -39, GETDATE())))),
(1671, 'TIX-MEGA-1276-0', 1276, N'Bùi Bảo', 'mega_req_276@gmail.com', 'TIX-MEGA-1276-0|E1015|1047', 0, DATEADD(MINUTE, 46, DATEADD(HOUR, 22, DATEADD(DAY, -2, GETDATE())))),
(1672, 'TIX-MEGA-1276-1', 1276, N'Bùi Bảo', 'mega_req_276@gmail.com', 'TIX-MEGA-1276-1|E1015|1047', 0, DATEADD(MINUTE, 46, DATEADD(HOUR, 22, DATEADD(DAY, -2, GETDATE())))),
(1673, 'TIX-MEGA-1276-2', 1276, N'Bùi Bảo', 'mega_req_276@gmail.com', 'TIX-MEGA-1276-2|E1015|1047', 0, DATEADD(MINUTE, 46, DATEADD(HOUR, 22, DATEADD(DAY, -2, GETDATE())))),
(1674, 'TIX-MEGA-1276-3', 1276, N'Bùi Bảo', 'mega_req_276@gmail.com', 'TIX-MEGA-1276-3|E1015|1047', 0, DATEADD(MINUTE, 46, DATEADD(HOUR, 22, DATEADD(DAY, -2, GETDATE())))),
(1675, 'TIX-MEGA-1277-0', 1277, N'Vũ Minh', 'mega_req_277@gmail.com', 'TIX-MEGA-1277-0|E1002|1008', 1, DATEADD(MINUTE, 22, DATEADD(HOUR, 17, DATEADD(DAY, -20, GETDATE())))),
(1676, 'TIX-MEGA-1277-1', 1277, N'Vũ Minh', 'mega_req_277@gmail.com', 'TIX-MEGA-1277-1|E1002|1008', 1, DATEADD(MINUTE, 22, DATEADD(HOUR, 17, DATEADD(DAY, -20, GETDATE())))),
(1677, 'TIX-MEGA-1278-0', 1278, N'Đỗ Khoa', 'mega_req_278@gmail.com', 'TIX-MEGA-1278-0|E1014|1043', 0, DATEADD(MINUTE, 46, DATEADD(HOUR, 9, DATEADD(DAY, -50, GETDATE())))),
(1678, 'TIX-MEGA-1278-1', 1278, N'Đỗ Khoa', 'mega_req_278@gmail.com', 'TIX-MEGA-1278-1|E1014|1043', 0, DATEADD(MINUTE, 46, DATEADD(HOUR, 9, DATEADD(DAY, -50, GETDATE())))),
(1679, 'TIX-MEGA-1279-0', 1279, N'Đặng Tâm', 'mega_req_279@gmail.com', 'TIX-MEGA-1279-0|E1086|1258', 0, DATEADD(MINUTE, 43, DATEADD(HOUR, 22, DATEADD(DAY, -6, GETDATE())))),
(1680, 'TIX-MEGA-1279-1', 1279, N'Đặng Tâm', 'mega_req_279@gmail.com', 'TIX-MEGA-1279-1|E1086|1258', 0, DATEADD(MINUTE, 43, DATEADD(HOUR, 22, DATEADD(DAY, -6, GETDATE())))),
(1681, 'TIX-MEGA-1279-2', 1279, N'Đặng Tâm', 'mega_req_279@gmail.com', 'TIX-MEGA-1279-2|E1086|1258', 0, DATEADD(MINUTE, 43, DATEADD(HOUR, 22, DATEADD(DAY, -6, GETDATE())))),
(1682, 'TIX-MEGA-1279-3', 1279, N'Đặng Tâm', 'mega_req_279@gmail.com', 'TIX-MEGA-1279-3|E1086|1258', 0, DATEADD(MINUTE, 43, DATEADD(HOUR, 22, DATEADD(DAY, -6, GETDATE())))),
(1683, 'TIX-MEGA-1280-0', 1280, N'Vũ Tâm', 'mega_req_280@gmail.com', 'TIX-MEGA-1280-0|E1078|1236', 1, DATEADD(MINUTE, 53, DATEADD(HOUR, 15, DATEADD(DAY, -8, GETDATE())))),
(1684, 'TIX-MEGA-1280-1', 1280, N'Vũ Tâm', 'mega_req_280@gmail.com', 'TIX-MEGA-1280-1|E1078|1236', 0, DATEADD(MINUTE, 53, DATEADD(HOUR, 15, DATEADD(DAY, -8, GETDATE())))),
(1685, 'TIX-MEGA-1280-2', 1280, N'Vũ Tâm', 'mega_req_280@gmail.com', 'TIX-MEGA-1280-2|E1078|1236', 0, DATEADD(MINUTE, 53, DATEADD(HOUR, 15, DATEADD(DAY, -8, GETDATE())))),
(1686, 'TIX-MEGA-1281-0', 1281, N'Đặng Phong', 'mega_req_281@gmail.com', 'TIX-MEGA-1281-0|E1069|1209', 0, DATEADD(MINUTE, 32, DATEADD(HOUR, 10, DATEADD(DAY, -48, GETDATE())))),
(1687, 'TIX-MEGA-1281-1', 1281, N'Đặng Phong', 'mega_req_281@gmail.com', 'TIX-MEGA-1281-1|E1069|1209', 0, DATEADD(MINUTE, 32, DATEADD(HOUR, 10, DATEADD(DAY, -48, GETDATE())))),
(1688, 'TIX-MEGA-1282-0', 1282, N'Trần Anh', 'mega_req_282@gmail.com', 'TIX-MEGA-1282-0|E1041|1123', 0, DATEADD(MINUTE, 56, DATEADD(HOUR, 17, DATEADD(DAY, -29, GETDATE())))),
(1689, 'TIX-MEGA-1282-1', 1282, N'Trần Anh', 'mega_req_282@gmail.com', 'TIX-MEGA-1282-1|E1041|1123', 0, DATEADD(MINUTE, 56, DATEADD(HOUR, 17, DATEADD(DAY, -29, GETDATE())))),
(1690, 'TIX-MEGA-1282-2', 1282, N'Trần Anh', 'mega_req_282@gmail.com', 'TIX-MEGA-1282-2|E1041|1123', 0, DATEADD(MINUTE, 56, DATEADD(HOUR, 17, DATEADD(DAY, -29, GETDATE())))),
(1691, 'TIX-MEGA-1282-3', 1282, N'Trần Anh', 'mega_req_282@gmail.com', 'TIX-MEGA-1282-3|E1041|1123', 0, DATEADD(MINUTE, 56, DATEADD(HOUR, 17, DATEADD(DAY, -29, GETDATE())))),
(1692, 'TIX-MEGA-1283-0', 1283, N'Đặng Tâm', 'mega_req_283@gmail.com', 'TIX-MEGA-1283-0|E1053|1161', 0, DATEADD(MINUTE, 37, DATEADD(HOUR, 13, DATEADD(DAY, -3, GETDATE())))),
(1693, 'TIX-MEGA-1283-1', 1283, N'Đặng Tâm', 'mega_req_283@gmail.com', 'TIX-MEGA-1283-1|E1053|1161', 0, DATEADD(MINUTE, 37, DATEADD(HOUR, 13, DATEADD(DAY, -3, GETDATE())))),
(1694, 'TIX-MEGA-1283-2', 1283, N'Đặng Tâm', 'mega_req_283@gmail.com', 'TIX-MEGA-1283-2|E1053|1161', 0, DATEADD(MINUTE, 37, DATEADD(HOUR, 13, DATEADD(DAY, -3, GETDATE())))),
(1695, 'TIX-MEGA-1284-0', 1284, N'Nguyễn Tâm', 'mega_req_284@gmail.com', 'TIX-MEGA-1284-0|E1052|1158', 0, DATEADD(MINUTE, 52, DATEADD(HOUR, 6, DATEADD(DAY, -54, GETDATE())))),
(1696, 'TIX-MEGA-1284-1', 1284, N'Nguyễn Tâm', 'mega_req_284@gmail.com', 'TIX-MEGA-1284-1|E1052|1158', 0, DATEADD(MINUTE, 52, DATEADD(HOUR, 6, DATEADD(DAY, -54, GETDATE())))),
(1697, 'TIX-MEGA-1284-2', 1284, N'Nguyễn Tâm', 'mega_req_284@gmail.com', 'TIX-MEGA-1284-2|E1052|1158', 0, DATEADD(MINUTE, 52, DATEADD(HOUR, 6, DATEADD(DAY, -54, GETDATE())))),
(1698, 'TIX-MEGA-1285-0', 1285, N'Vũ Thu', 'mega_req_285@gmail.com', 'TIX-MEGA-1285-0|E1071|1215', 0, DATEADD(MINUTE, 39, DATEADD(HOUR, 23, DATEADD(DAY, -55, GETDATE())))),
(1699, 'TIX-MEGA-1285-1', 1285, N'Vũ Thu', 'mega_req_285@gmail.com', 'TIX-MEGA-1285-1|E1071|1215', 0, DATEADD(MINUTE, 39, DATEADD(HOUR, 23, DATEADD(DAY, -55, GETDATE())))),
(1700, 'TIX-MEGA-1285-2', 1285, N'Vũ Thu', 'mega_req_285@gmail.com', 'TIX-MEGA-1285-2|E1071|1215', 0, DATEADD(MINUTE, 39, DATEADD(HOUR, 23, DATEADD(DAY, -55, GETDATE())))),
(1701, 'TIX-MEGA-1285-3', 1285, N'Vũ Thu', 'mega_req_285@gmail.com', 'TIX-MEGA-1285-3|E1071|1215', 0, DATEADD(MINUTE, 39, DATEADD(HOUR, 23, DATEADD(DAY, -55, GETDATE())))),
(1702, 'TIX-MEGA-1286-0', 1286, N'Trần Lan', 'mega_req_286@gmail.com', 'TIX-MEGA-1286-0|E1089|1269', 0, DATEADD(MINUTE, 6, DATEADD(HOUR, 23, DATEADD(DAY, -9, GETDATE())))),
(1703, 'TIX-MEGA-1286-1', 1286, N'Trần Lan', 'mega_req_286@gmail.com', 'TIX-MEGA-1286-1|E1089|1269', 0, DATEADD(MINUTE, 6, DATEADD(HOUR, 23, DATEADD(DAY, -9, GETDATE())))),
(1704, 'TIX-MEGA-1287-0', 1287, N'Lê Kiên', 'mega_req_287@gmail.com', 'TIX-MEGA-1287-0|E1092|1278', 0, DATEADD(MINUTE, 22, DATEADD(HOUR, 20, DATEADD(DAY, -58, GETDATE())))),
(1705, 'TIX-MEGA-1287-1', 1287, N'Lê Kiên', 'mega_req_287@gmail.com', 'TIX-MEGA-1287-1|E1092|1278', 0, DATEADD(MINUTE, 22, DATEADD(HOUR, 20, DATEADD(DAY, -58, GETDATE())))),
(1706, 'TIX-MEGA-1287-2', 1287, N'Lê Kiên', 'mega_req_287@gmail.com', 'TIX-MEGA-1287-2|E1092|1278', 0, DATEADD(MINUTE, 22, DATEADD(HOUR, 20, DATEADD(DAY, -58, GETDATE())))),
(1707, 'TIX-MEGA-1287-3', 1287, N'Lê Kiên', 'mega_req_287@gmail.com', 'TIX-MEGA-1287-3|E1092|1278', 1, DATEADD(MINUTE, 22, DATEADD(HOUR, 20, DATEADD(DAY, -58, GETDATE()))));
INSERT INTO Tickets (ticket_id, ticket_code, order_item_id, attendee_name, attendee_email, qr_code, is_checked_in, created_at) VALUES
(1708, 'TIX-MEGA-1288-0', 1288, N'Phạm Vân', 'mega_req_288@gmail.com', 'TIX-MEGA-1288-0|E1091|1275', 0, DATEADD(MINUTE, 22, DATEADD(HOUR, 6, DATEADD(DAY, -11, GETDATE())))),
(1709, 'TIX-MEGA-1288-1', 1288, N'Phạm Vân', 'mega_req_288@gmail.com', 'TIX-MEGA-1288-1|E1091|1275', 0, DATEADD(MINUTE, 22, DATEADD(HOUR, 6, DATEADD(DAY, -11, GETDATE())))),
(1710, 'TIX-MEGA-1288-2', 1288, N'Phạm Vân', 'mega_req_288@gmail.com', 'TIX-MEGA-1288-2|E1091|1275', 0, DATEADD(MINUTE, 22, DATEADD(HOUR, 6, DATEADD(DAY, -11, GETDATE())))),
(1711, 'TIX-MEGA-1289-0', 1289, N'Lê Thành', 'mega_req_289@gmail.com', 'TIX-MEGA-1289-0|E1059|1178', 0, DATEADD(MINUTE, 10, DATEADD(HOUR, 3, DATEADD(DAY, -5, GETDATE())))),
(1712, 'TIX-MEGA-1290-0', 1290, N'Nguyễn Anh', 'mega_req_290@gmail.com', 'TIX-MEGA-1290-0|E1052|1158', 0, DATEADD(MINUTE, 24, DATEADD(HOUR, 21, DATEADD(DAY, -11, GETDATE())))),
(1713, 'TIX-MEGA-1290-1', 1290, N'Nguyễn Anh', 'mega_req_290@gmail.com', 'TIX-MEGA-1290-1|E1052|1158', 1, DATEADD(MINUTE, 24, DATEADD(HOUR, 21, DATEADD(DAY, -11, GETDATE())))),
(1714, 'TIX-MEGA-1290-2', 1290, N'Nguyễn Anh', 'mega_req_290@gmail.com', 'TIX-MEGA-1290-2|E1052|1158', 0, DATEADD(MINUTE, 24, DATEADD(HOUR, 21, DATEADD(DAY, -11, GETDATE())))),
(1715, 'TIX-MEGA-1291-0', 1291, N'Trần Trang', 'mega_req_291@gmail.com', 'TIX-MEGA-1291-0|E1031|1094', 0, DATEADD(MINUTE, 22, DATEADD(HOUR, 10, DATEADD(DAY, -40, GETDATE())))),
(1716, 'TIX-MEGA-1291-1', 1291, N'Trần Trang', 'mega_req_291@gmail.com', 'TIX-MEGA-1291-1|E1031|1094', 0, DATEADD(MINUTE, 22, DATEADD(HOUR, 10, DATEADD(DAY, -40, GETDATE())))),
(1717, 'TIX-MEGA-1291-2', 1291, N'Trần Trang', 'mega_req_291@gmail.com', 'TIX-MEGA-1291-2|E1031|1094', 0, DATEADD(MINUTE, 22, DATEADD(HOUR, 10, DATEADD(DAY, -40, GETDATE())))),
(1718, 'TIX-MEGA-1291-3', 1291, N'Trần Trang', 'mega_req_291@gmail.com', 'TIX-MEGA-1291-3|E1031|1094', 0, DATEADD(MINUTE, 22, DATEADD(HOUR, 10, DATEADD(DAY, -40, GETDATE())))),
(1719, 'TIX-MEGA-1292-0', 1292, N'Nguyễn Anh', 'mega_req_292@gmail.com', 'TIX-MEGA-1292-0|E1008|1026', 0, DATEADD(MINUTE, 49, DATEADD(HOUR, 7, DATEADD(DAY, -9, GETDATE())))),
(1720, 'TIX-MEGA-1292-1', 1292, N'Nguyễn Anh', 'mega_req_292@gmail.com', 'TIX-MEGA-1292-1|E1008|1026', 0, DATEADD(MINUTE, 49, DATEADD(HOUR, 7, DATEADD(DAY, -9, GETDATE())))),
(1721, 'TIX-MEGA-1293-0', 1293, N'Huỳnh Tâm', 'mega_req_293@gmail.com', 'TIX-MEGA-1293-0|E1001|1004', 0, DATEADD(MINUTE, 42, DATEADD(HOUR, 17, DATEADD(DAY, -5, GETDATE())))),
(1722, 'TIX-MEGA-1293-1', 1293, N'Huỳnh Tâm', 'mega_req_293@gmail.com', 'TIX-MEGA-1293-1|E1001|1004', 0, DATEADD(MINUTE, 42, DATEADD(HOUR, 17, DATEADD(DAY, -5, GETDATE())))),
(1723, 'TIX-MEGA-1294-0', 1294, N'Nguyễn Hùng', 'mega_req_294@gmail.com', 'TIX-MEGA-1294-0|E1004|1014', 0, DATEADD(MINUTE, 54, DATEADD(HOUR, 2, DATEADD(DAY, -13, GETDATE())))),
(1724, 'TIX-MEGA-1295-0', 1295, N'Nguyễn Anh', 'mega_req_295@gmail.com', 'TIX-MEGA-1295-0|E1064|1192', 0, DATEADD(MINUTE, 15, DATEADD(HOUR, 11, DATEADD(DAY, -42, GETDATE())))),
(1725, 'TIX-MEGA-1295-1', 1295, N'Nguyễn Anh', 'mega_req_295@gmail.com', 'TIX-MEGA-1295-1|E1064|1192', 0, DATEADD(MINUTE, 15, DATEADD(HOUR, 11, DATEADD(DAY, -42, GETDATE())))),
(1726, 'TIX-MEGA-1295-2', 1295, N'Nguyễn Anh', 'mega_req_295@gmail.com', 'TIX-MEGA-1295-2|E1064|1192', 0, DATEADD(MINUTE, 15, DATEADD(HOUR, 11, DATEADD(DAY, -42, GETDATE())))),
(1727, 'TIX-MEGA-1295-3', 1295, N'Nguyễn Anh', 'mega_req_295@gmail.com', 'TIX-MEGA-1295-3|E1064|1192', 0, DATEADD(MINUTE, 15, DATEADD(HOUR, 11, DATEADD(DAY, -42, GETDATE())))),
(1728, 'TIX-MEGA-1296-0', 1296, N'Phạm Trang', 'mega_req_296@gmail.com', 'TIX-MEGA-1296-0|E1048|1146', 0, DATEADD(MINUTE, 32, DATEADD(HOUR, 6, DATEADD(DAY, -59, GETDATE())))),
(1729, 'TIX-MEGA-1296-1', 1296, N'Phạm Trang', 'mega_req_296@gmail.com', 'TIX-MEGA-1296-1|E1048|1146', 0, DATEADD(MINUTE, 32, DATEADD(HOUR, 6, DATEADD(DAY, -59, GETDATE())))),
(1730, 'TIX-MEGA-1297-0', 1297, N'Đỗ Phong', 'mega_req_297@gmail.com', 'TIX-MEGA-1297-0|E1053|1160', 0, DATEADD(MINUTE, 7, DATEADD(HOUR, 6, DATEADD(DAY, -26, GETDATE())))),
(1731, 'TIX-MEGA-1297-1', 1297, N'Đỗ Phong', 'mega_req_297@gmail.com', 'TIX-MEGA-1297-1|E1053|1160', 0, DATEADD(MINUTE, 7, DATEADD(HOUR, 6, DATEADD(DAY, -26, GETDATE())))),
(1732, 'TIX-MEGA-1298-0', 1298, N'Hoàng Lan', 'mega_req_298@gmail.com', 'TIX-MEGA-1298-0|E1030|1091', 0, DATEADD(MINUTE, 29, DATEADD(HOUR, 13, DATEADD(DAY, -27, GETDATE())))),
(1733, 'TIX-MEGA-1298-1', 1298, N'Hoàng Lan', 'mega_req_298@gmail.com', 'TIX-MEGA-1298-1|E1030|1091', 0, DATEADD(MINUTE, 29, DATEADD(HOUR, 13, DATEADD(DAY, -27, GETDATE())))),
(1734, 'TIX-MEGA-1299-0', 1299, N'Lê Linh', 'mega_req_299@gmail.com', 'TIX-MEGA-1299-0|E1094|1284', 0, DATEADD(MINUTE, 28, DATEADD(HOUR, 21, DATEADD(DAY, -59, GETDATE())))),
(1735, 'TIX-MEGA-1299-1', 1299, N'Lê Linh', 'mega_req_299@gmail.com', 'TIX-MEGA-1299-1|E1094|1284', 0, DATEADD(MINUTE, 28, DATEADD(HOUR, 21, DATEADD(DAY, -59, GETDATE())))),
(1736, 'TIX-MEGA-1300-0', 1300, N'Phạm Hải', 'mega_req_300@gmail.com', 'TIX-MEGA-1300-0|E1031|1093', 0, DATEADD(MINUTE, 37, DATEADD(HOUR, 12, DATEADD(DAY, -55, GETDATE())))),
(1737, 'TIX-MEGA-1300-1', 1300, N'Phạm Hải', 'mega_req_300@gmail.com', 'TIX-MEGA-1300-1|E1031|1093', 0, DATEADD(MINUTE, 37, DATEADD(HOUR, 12, DATEADD(DAY, -55, GETDATE())))),
(1738, 'TIX-MEGA-1301-0', 1301, N'Huỳnh Trang', 'mega_req_301@gmail.com', 'TIX-MEGA-1301-0|E1035|1106', 0, DATEADD(MINUTE, 19, DATEADD(HOUR, 17, DATEADD(DAY, -37, GETDATE())))),
(1739, 'TIX-MEGA-1301-1', 1301, N'Huỳnh Trang', 'mega_req_301@gmail.com', 'TIX-MEGA-1301-1|E1035|1106', 0, DATEADD(MINUTE, 19, DATEADD(HOUR, 17, DATEADD(DAY, -37, GETDATE())))),
(1740, 'TIX-MEGA-1301-2', 1301, N'Huỳnh Trang', 'mega_req_301@gmail.com', 'TIX-MEGA-1301-2|E1035|1106', 0, DATEADD(MINUTE, 19, DATEADD(HOUR, 17, DATEADD(DAY, -37, GETDATE())))),
(1741, 'TIX-MEGA-1301-3', 1301, N'Huỳnh Trang', 'mega_req_301@gmail.com', 'TIX-MEGA-1301-3|E1035|1106', 0, DATEADD(MINUTE, 19, DATEADD(HOUR, 17, DATEADD(DAY, -37, GETDATE())))),
(1742, 'TIX-MEGA-1302-0', 1302, N'Huỳnh Thành', 'mega_req_302@gmail.com', 'TIX-MEGA-1302-0|E1015|1047', 0, DATEADD(MINUTE, 48, DATEADD(HOUR, 19, DATEADD(DAY, -18, GETDATE())))),
(1743, 'TIX-MEGA-1303-0', 1303, N'Nguyễn Thu', 'mega_req_303@gmail.com', 'TIX-MEGA-1303-0|E1044|1132', 0, DATEADD(MINUTE, 44, DATEADD(HOUR, 4, DATEADD(DAY, -20, GETDATE())))),
(1744, 'TIX-MEGA-1303-1', 1303, N'Nguyễn Thu', 'mega_req_303@gmail.com', 'TIX-MEGA-1303-1|E1044|1132', 0, DATEADD(MINUTE, 44, DATEADD(HOUR, 4, DATEADD(DAY, -20, GETDATE())))),
(1745, 'TIX-MEGA-1303-2', 1303, N'Nguyễn Thu', 'mega_req_303@gmail.com', 'TIX-MEGA-1303-2|E1044|1132', 0, DATEADD(MINUTE, 44, DATEADD(HOUR, 4, DATEADD(DAY, -20, GETDATE())))),
(1746, 'TIX-MEGA-1304-0', 1304, N'Phạm Thu', 'mega_req_304@gmail.com', 'TIX-MEGA-1304-0|E1088|1266', 0, DATEADD(MINUTE, 18, DATEADD(HOUR, 19, DATEADD(DAY, -28, GETDATE())))),
(1747, 'TIX-MEGA-1304-1', 1304, N'Phạm Thu', 'mega_req_304@gmail.com', 'TIX-MEGA-1304-1|E1088|1266', 0, DATEADD(MINUTE, 18, DATEADD(HOUR, 19, DATEADD(DAY, -28, GETDATE())))),
(1748, 'TIX-MEGA-1304-2', 1304, N'Phạm Thu', 'mega_req_304@gmail.com', 'TIX-MEGA-1304-2|E1088|1266', 0, DATEADD(MINUTE, 18, DATEADD(HOUR, 19, DATEADD(DAY, -28, GETDATE())))),
(1749, 'TIX-MEGA-1304-3', 1304, N'Phạm Thu', 'mega_req_304@gmail.com', 'TIX-MEGA-1304-3|E1088|1266', 0, DATEADD(MINUTE, 18, DATEADD(HOUR, 19, DATEADD(DAY, -28, GETDATE())))),
(1750, 'TIX-MEGA-1305-0', 1305, N'Phạm Phong', 'mega_req_305@gmail.com', 'TIX-MEGA-1305-0|E1059|1177', 0, DATEADD(MINUTE, 55, DATEADD(HOUR, 22, DATEADD(DAY, -13, GETDATE())))),
(1751, 'TIX-MEGA-1305-1', 1305, N'Phạm Phong', 'mega_req_305@gmail.com', 'TIX-MEGA-1305-1|E1059|1177', 0, DATEADD(MINUTE, 55, DATEADD(HOUR, 22, DATEADD(DAY, -13, GETDATE())))),
(1752, 'TIX-MEGA-1306-0', 1306, N'Bùi Khoa', 'mega_req_306@gmail.com', 'TIX-MEGA-1306-0|E1008|1025', 0, DATEADD(MINUTE, 51, DATEADD(HOUR, 14, DATEADD(DAY, -35, GETDATE())))),
(1753, 'TIX-MEGA-1306-1', 1306, N'Bùi Khoa', 'mega_req_306@gmail.com', 'TIX-MEGA-1306-1|E1008|1025', 0, DATEADD(MINUTE, 51, DATEADD(HOUR, 14, DATEADD(DAY, -35, GETDATE())))),
(1754, 'TIX-MEGA-1306-2', 1306, N'Bùi Khoa', 'mega_req_306@gmail.com', 'TIX-MEGA-1306-2|E1008|1025', 1, DATEADD(MINUTE, 51, DATEADD(HOUR, 14, DATEADD(DAY, -35, GETDATE())))),
(1755, 'TIX-MEGA-1306-3', 1306, N'Bùi Khoa', 'mega_req_306@gmail.com', 'TIX-MEGA-1306-3|E1008|1025', 0, DATEADD(MINUTE, 51, DATEADD(HOUR, 14, DATEADD(DAY, -35, GETDATE())))),
(1756, 'TIX-MEGA-1307-0', 1307, N'Bùi Thu', 'mega_req_307@gmail.com', 'TIX-MEGA-1307-0|E1047|1141', 0, DATEADD(MINUTE, 17, DATEADD(HOUR, 19, DATEADD(DAY, -47, GETDATE())))),
(1757, 'TIX-MEGA-1307-1', 1307, N'Bùi Thu', 'mega_req_307@gmail.com', 'TIX-MEGA-1307-1|E1047|1141', 0, DATEADD(MINUTE, 17, DATEADD(HOUR, 19, DATEADD(DAY, -47, GETDATE())))),
(1758, 'TIX-MEGA-1308-0', 1308, N'Huỳnh Trang', 'mega_req_308@gmail.com', 'TIX-MEGA-1308-0|E1007|1022', 0, DATEADD(MINUTE, 23, DATEADD(HOUR, 21, DATEADD(DAY, -31, GETDATE())))),
(1759, 'TIX-MEGA-1308-1', 1308, N'Huỳnh Trang', 'mega_req_308@gmail.com', 'TIX-MEGA-1308-1|E1007|1022', 0, DATEADD(MINUTE, 23, DATEADD(HOUR, 21, DATEADD(DAY, -31, GETDATE())))),
(1760, 'TIX-MEGA-1308-2', 1308, N'Huỳnh Trang', 'mega_req_308@gmail.com', 'TIX-MEGA-1308-2|E1007|1022', 0, DATEADD(MINUTE, 23, DATEADD(HOUR, 21, DATEADD(DAY, -31, GETDATE())))),
(1761, 'TIX-MEGA-1309-0', 1309, N'Bùi Phong', 'mega_req_309@gmail.com', 'TIX-MEGA-1309-0|E1007|1023', 1, DATEADD(MINUTE, 13, DATEADD(HOUR, 16, DATEADD(DAY, -56, GETDATE())))),
(1762, 'TIX-MEGA-1309-1', 1309, N'Bùi Phong', 'mega_req_309@gmail.com', 'TIX-MEGA-1309-1|E1007|1023', 0, DATEADD(MINUTE, 13, DATEADD(HOUR, 16, DATEADD(DAY, -56, GETDATE())))),
(1763, 'TIX-MEGA-1310-0', 1310, N'Đặng Tâm', 'mega_req_310@gmail.com', 'TIX-MEGA-1310-0|E1064|1194', 0, DATEADD(MINUTE, 7, DATEADD(HOUR, 8, DATEADD(DAY, -39, GETDATE())))),
(1764, 'TIX-MEGA-1310-1', 1310, N'Đặng Tâm', 'mega_req_310@gmail.com', 'TIX-MEGA-1310-1|E1064|1194', 0, DATEADD(MINUTE, 7, DATEADD(HOUR, 8, DATEADD(DAY, -39, GETDATE())))),
(1765, 'TIX-MEGA-1310-2', 1310, N'Đặng Tâm', 'mega_req_310@gmail.com', 'TIX-MEGA-1310-2|E1064|1194', 0, DATEADD(MINUTE, 7, DATEADD(HOUR, 8, DATEADD(DAY, -39, GETDATE())))),
(1766, 'TIX-MEGA-1310-3', 1310, N'Đặng Tâm', 'mega_req_310@gmail.com', 'TIX-MEGA-1310-3|E1064|1194', 0, DATEADD(MINUTE, 7, DATEADD(HOUR, 8, DATEADD(DAY, -39, GETDATE())))),
(1767, 'TIX-MEGA-1311-0', 1311, N'Hoàng Thành', 'mega_req_311@gmail.com', 'TIX-MEGA-1311-0|E1004|1013', 0, DATEADD(MINUTE, 12, DATEADD(HOUR, 18, DATEADD(DAY, -26, GETDATE())))),
(1768, 'TIX-MEGA-1311-1', 1311, N'Hoàng Thành', 'mega_req_311@gmail.com', 'TIX-MEGA-1311-1|E1004|1013', 0, DATEADD(MINUTE, 12, DATEADD(HOUR, 18, DATEADD(DAY, -26, GETDATE())))),
(1769, 'TIX-MEGA-1311-2', 1311, N'Hoàng Thành', 'mega_req_311@gmail.com', 'TIX-MEGA-1311-2|E1004|1013', 0, DATEADD(MINUTE, 12, DATEADD(HOUR, 18, DATEADD(DAY, -26, GETDATE())))),
(1770, 'TIX-MEGA-1311-3', 1311, N'Hoàng Thành', 'mega_req_311@gmail.com', 'TIX-MEGA-1311-3|E1004|1013', 0, DATEADD(MINUTE, 12, DATEADD(HOUR, 18, DATEADD(DAY, -26, GETDATE())))),
(1771, 'TIX-MEGA-1312-0', 1312, N'Nguyễn Thu', 'mega_req_312@gmail.com', 'TIX-MEGA-1312-0|E1004|1012', 0, DATEADD(MINUTE, 29, DATEADD(HOUR, 11, DATEADD(DAY, -4, GETDATE())))),
(1772, 'TIX-MEGA-1313-0', 1313, N'Hoàng Kiên', 'mega_req_313@gmail.com', 'TIX-MEGA-1313-0|E1020|1062', 1, DATEADD(MINUTE, 13, DATEADD(HOUR, 12, DATEADD(DAY, -24, GETDATE())))),
(1773, 'TIX-MEGA-1314-0', 1314, N'Huỳnh Phong', 'mega_req_314@gmail.com', 'TIX-MEGA-1314-0|E1034|1103', 0, DATEADD(MINUTE, 22, DATEADD(HOUR, 20, DATEADD(DAY, -57, GETDATE())))),
(1774, 'TIX-MEGA-1314-1', 1314, N'Huỳnh Phong', 'mega_req_314@gmail.com', 'TIX-MEGA-1314-1|E1034|1103', 0, DATEADD(MINUTE, 22, DATEADD(HOUR, 20, DATEADD(DAY, -57, GETDATE())))),
(1775, 'TIX-MEGA-1314-2', 1314, N'Huỳnh Phong', 'mega_req_314@gmail.com', 'TIX-MEGA-1314-2|E1034|1103', 0, DATEADD(MINUTE, 22, DATEADD(HOUR, 20, DATEADD(DAY, -57, GETDATE())))),
(1776, 'TIX-MEGA-1315-0', 1315, N'Phạm Anh', 'mega_req_315@gmail.com', 'TIX-MEGA-1315-0|E1079|1238', 0, DATEADD(MINUTE, 53, DATEADD(HOUR, 23, DATEADD(DAY, -35, GETDATE())))),
(1777, 'TIX-MEGA-1315-1', 1315, N'Phạm Anh', 'mega_req_315@gmail.com', 'TIX-MEGA-1315-1|E1079|1238', 0, DATEADD(MINUTE, 53, DATEADD(HOUR, 23, DATEADD(DAY, -35, GETDATE())))),
(1778, 'TIX-MEGA-1315-2', 1315, N'Phạm Anh', 'mega_req_315@gmail.com', 'TIX-MEGA-1315-2|E1079|1238', 0, DATEADD(MINUTE, 53, DATEADD(HOUR, 23, DATEADD(DAY, -35, GETDATE())))),
(1779, 'TIX-MEGA-1316-0', 1316, N'Huỳnh Vân', 'mega_req_316@gmail.com', 'TIX-MEGA-1316-0|E1086|1260', 0, DATEADD(MINUTE, 34, DATEADD(HOUR, 13, DATEADD(DAY, -9, GETDATE())))),
(1780, 'TIX-MEGA-1316-1', 1316, N'Huỳnh Vân', 'mega_req_316@gmail.com', 'TIX-MEGA-1316-1|E1086|1260', 0, DATEADD(MINUTE, 34, DATEADD(HOUR, 13, DATEADD(DAY, -9, GETDATE())))),
(1781, 'TIX-MEGA-1317-0', 1317, N'Trần Hải', 'mega_req_317@gmail.com', 'TIX-MEGA-1317-0|E1043|1130', 0, DATEADD(MINUTE, 2, DATEADD(HOUR, 11, DATEADD(DAY, -42, GETDATE())))),
(1782, 'TIX-MEGA-1317-1', 1317, N'Trần Hải', 'mega_req_317@gmail.com', 'TIX-MEGA-1317-1|E1043|1130', 0, DATEADD(MINUTE, 2, DATEADD(HOUR, 11, DATEADD(DAY, -42, GETDATE())))),
(1783, 'TIX-MEGA-1317-2', 1317, N'Trần Hải', 'mega_req_317@gmail.com', 'TIX-MEGA-1317-2|E1043|1130', 0, DATEADD(MINUTE, 2, DATEADD(HOUR, 11, DATEADD(DAY, -42, GETDATE())))),
(1784, 'TIX-MEGA-1317-3', 1317, N'Trần Hải', 'mega_req_317@gmail.com', 'TIX-MEGA-1317-3|E1043|1130', 0, DATEADD(MINUTE, 2, DATEADD(HOUR, 11, DATEADD(DAY, -42, GETDATE())))),
(1785, 'TIX-MEGA-1318-0', 1318, N'Trần Anh', 'mega_req_318@gmail.com', 'TIX-MEGA-1318-0|E1056|1169', 0, DATEADD(MINUTE, 10, DATEADD(HOUR, 12, DATEADD(DAY, -3, GETDATE())))),
(1786, 'TIX-MEGA-1318-1', 1318, N'Trần Anh', 'mega_req_318@gmail.com', 'TIX-MEGA-1318-1|E1056|1169', 0, DATEADD(MINUTE, 10, DATEADD(HOUR, 12, DATEADD(DAY, -3, GETDATE())))),
(1787, 'TIX-MEGA-1318-2', 1318, N'Trần Anh', 'mega_req_318@gmail.com', 'TIX-MEGA-1318-2|E1056|1169', 0, DATEADD(MINUTE, 10, DATEADD(HOUR, 12, DATEADD(DAY, -3, GETDATE())))),
(1788, 'TIX-MEGA-1319-0', 1319, N'Nguyễn Thành', 'mega_req_319@gmail.com', 'TIX-MEGA-1319-0|E1065|1195', 0, DATEADD(MINUTE, 17, DATEADD(HOUR, 22, DATEADD(DAY, -35, GETDATE())))),
(1789, 'TIX-MEGA-1319-1', 1319, N'Nguyễn Thành', 'mega_req_319@gmail.com', 'TIX-MEGA-1319-1|E1065|1195', 0, DATEADD(MINUTE, 17, DATEADD(HOUR, 22, DATEADD(DAY, -35, GETDATE())))),
(1790, 'TIX-MEGA-1320-0', 1320, N'Phạm Minh', 'mega_req_320@gmail.com', 'TIX-MEGA-1320-0|E1067|1203', 0, DATEADD(MINUTE, 58, DATEADD(HOUR, 3, DATEADD(DAY, -25, GETDATE())))),
(1791, 'TIX-MEGA-1320-1', 1320, N'Phạm Minh', 'mega_req_320@gmail.com', 'TIX-MEGA-1320-1|E1067|1203', 0, DATEADD(MINUTE, 58, DATEADD(HOUR, 3, DATEADD(DAY, -25, GETDATE())))),
(1792, 'TIX-MEGA-1320-2', 1320, N'Phạm Minh', 'mega_req_320@gmail.com', 'TIX-MEGA-1320-2|E1067|1203', 0, DATEADD(MINUTE, 58, DATEADD(HOUR, 3, DATEADD(DAY, -25, GETDATE())))),
(1793, 'TIX-MEGA-1320-3', 1320, N'Phạm Minh', 'mega_req_320@gmail.com', 'TIX-MEGA-1320-3|E1067|1203', 0, DATEADD(MINUTE, 58, DATEADD(HOUR, 3, DATEADD(DAY, -25, GETDATE())))),
(1794, 'TIX-MEGA-1321-0', 1321, N'Phạm Minh', 'mega_req_321@gmail.com', 'TIX-MEGA-1321-0|E1011|1035', 0, DATEADD(MINUTE, 49, DATEADD(HOUR, 15, DATEADD(DAY, -18, GETDATE())))),
(1795, 'TIX-MEGA-1322-0', 1322, N'Nguyễn Minh', 'mega_req_322@gmail.com', 'TIX-MEGA-1322-0|E1080|1242', 0, DATEADD(MINUTE, 52, DATEADD(HOUR, 1, DATEADD(DAY, -6, GETDATE())))),
(1796, 'TIX-MEGA-1322-1', 1322, N'Nguyễn Minh', 'mega_req_322@gmail.com', 'TIX-MEGA-1322-1|E1080|1242', 0, DATEADD(MINUTE, 52, DATEADD(HOUR, 1, DATEADD(DAY, -6, GETDATE())))),
(1797, 'TIX-MEGA-1322-2', 1322, N'Nguyễn Minh', 'mega_req_322@gmail.com', 'TIX-MEGA-1322-2|E1080|1242', 0, DATEADD(MINUTE, 52, DATEADD(HOUR, 1, DATEADD(DAY, -6, GETDATE())))),
(1798, 'TIX-MEGA-1323-0', 1323, N'Hoàng Phong', 'mega_req_323@gmail.com', 'TIX-MEGA-1323-0|E1014|1043', 0, DATEADD(MINUTE, 14, DATEADD(HOUR, 6, DATEADD(DAY, -44, GETDATE())))),
(1799, 'TIX-MEGA-1323-1', 1323, N'Hoàng Phong', 'mega_req_323@gmail.com', 'TIX-MEGA-1323-1|E1014|1043', 0, DATEADD(MINUTE, 14, DATEADD(HOUR, 6, DATEADD(DAY, -44, GETDATE())))),
(1800, 'TIX-MEGA-1323-2', 1323, N'Hoàng Phong', 'mega_req_323@gmail.com', 'TIX-MEGA-1323-2|E1014|1043', 0, DATEADD(MINUTE, 14, DATEADD(HOUR, 6, DATEADD(DAY, -44, GETDATE())))),
(1801, 'TIX-MEGA-1324-0', 1324, N'Hoàng Trang', 'mega_req_324@gmail.com', 'TIX-MEGA-1324-0|E1060|1180', 0, DATEADD(MINUTE, 23, DATEADD(HOUR, 0, DATEADD(DAY, -27, GETDATE())))),
(1802, 'TIX-MEGA-1324-1', 1324, N'Hoàng Trang', 'mega_req_324@gmail.com', 'TIX-MEGA-1324-1|E1060|1180', 0, DATEADD(MINUTE, 23, DATEADD(HOUR, 0, DATEADD(DAY, -27, GETDATE())))),
(1803, 'TIX-MEGA-1325-0', 1325, N'Phạm Trang', 'mega_req_325@gmail.com', 'TIX-MEGA-1325-0|E1012|1038', 0, DATEADD(MINUTE, 59, DATEADD(HOUR, 21, DATEADD(DAY, -14, GETDATE())))),
(1804, 'TIX-MEGA-1325-1', 1325, N'Phạm Trang', 'mega_req_325@gmail.com', 'TIX-MEGA-1325-1|E1012|1038', 0, DATEADD(MINUTE, 59, DATEADD(HOUR, 21, DATEADD(DAY, -14, GETDATE())))),
(1805, 'TIX-MEGA-1325-2', 1325, N'Phạm Trang', 'mega_req_325@gmail.com', 'TIX-MEGA-1325-2|E1012|1038', 0, DATEADD(MINUTE, 59, DATEADD(HOUR, 21, DATEADD(DAY, -14, GETDATE())))),
(1806, 'TIX-MEGA-1325-3', 1325, N'Phạm Trang', 'mega_req_325@gmail.com', 'TIX-MEGA-1325-3|E1012|1038', 0, DATEADD(MINUTE, 59, DATEADD(HOUR, 21, DATEADD(DAY, -14, GETDATE())))),
(1807, 'TIX-MEGA-1326-0', 1326, N'Vũ Tâm', 'mega_req_326@gmail.com', 'TIX-MEGA-1326-0|E1025|1077', 0, DATEADD(MINUTE, 47, DATEADD(HOUR, 15, DATEADD(DAY, -33, GETDATE())))),
(1808, 'TIX-MEGA-1326-1', 1326, N'Vũ Tâm', 'mega_req_326@gmail.com', 'TIX-MEGA-1326-1|E1025|1077', 0, DATEADD(MINUTE, 47, DATEADD(HOUR, 15, DATEADD(DAY, -33, GETDATE())))),
(1809, 'TIX-MEGA-1326-2', 1326, N'Vũ Tâm', 'mega_req_326@gmail.com', 'TIX-MEGA-1326-2|E1025|1077', 0, DATEADD(MINUTE, 47, DATEADD(HOUR, 15, DATEADD(DAY, -33, GETDATE()))));
INSERT INTO Tickets (ticket_id, ticket_code, order_item_id, attendee_name, attendee_email, qr_code, is_checked_in, created_at) VALUES
(1810, 'TIX-MEGA-1327-0', 1327, N'Đỗ Anh', 'mega_req_327@gmail.com', 'TIX-MEGA-1327-0|E1073|1221', 1, DATEADD(MINUTE, 11, DATEADD(HOUR, 17, DATEADD(DAY, -35, GETDATE())))),
(1811, 'TIX-MEGA-1327-1', 1327, N'Đỗ Anh', 'mega_req_327@gmail.com', 'TIX-MEGA-1327-1|E1073|1221', 0, DATEADD(MINUTE, 11, DATEADD(HOUR, 17, DATEADD(DAY, -35, GETDATE())))),
(1812, 'TIX-MEGA-1328-0', 1328, N'Lê Lan', 'mega_req_328@gmail.com', 'TIX-MEGA-1328-0|E1033|1100', 0, DATEADD(MINUTE, 35, DATEADD(HOUR, 4, DATEADD(DAY, -33, GETDATE())))),
(1813, 'TIX-MEGA-1328-1', 1328, N'Lê Lan', 'mega_req_328@gmail.com', 'TIX-MEGA-1328-1|E1033|1100', 0, DATEADD(MINUTE, 35, DATEADD(HOUR, 4, DATEADD(DAY, -33, GETDATE())))),
(1814, 'TIX-MEGA-1329-0', 1329, N'Vũ Kiên', 'mega_req_329@gmail.com', 'TIX-MEGA-1329-0|E1061|1185', 0, DATEADD(MINUTE, 58, DATEADD(HOUR, 3, DATEADD(DAY, -44, GETDATE())))),
(1815, 'TIX-MEGA-1329-1', 1329, N'Vũ Kiên', 'mega_req_329@gmail.com', 'TIX-MEGA-1329-1|E1061|1185', 0, DATEADD(MINUTE, 58, DATEADD(HOUR, 3, DATEADD(DAY, -44, GETDATE())))),
(1816, 'TIX-MEGA-1329-2', 1329, N'Vũ Kiên', 'mega_req_329@gmail.com', 'TIX-MEGA-1329-2|E1061|1185', 0, DATEADD(MINUTE, 58, DATEADD(HOUR, 3, DATEADD(DAY, -44, GETDATE())))),
(1817, 'TIX-MEGA-1330-0', 1330, N'Bùi Thành', 'mega_req_330@gmail.com', 'TIX-MEGA-1330-0|E1073|1219', 0, DATEADD(MINUTE, 47, DATEADD(HOUR, 14, DATEADD(DAY, -32, GETDATE())))),
(1818, 'TIX-MEGA-1330-1', 1330, N'Bùi Thành', 'mega_req_330@gmail.com', 'TIX-MEGA-1330-1|E1073|1219', 0, DATEADD(MINUTE, 47, DATEADD(HOUR, 14, DATEADD(DAY, -32, GETDATE())))),
(1819, 'TIX-MEGA-1330-2', 1330, N'Bùi Thành', 'mega_req_330@gmail.com', 'TIX-MEGA-1330-2|E1073|1219', 0, DATEADD(MINUTE, 47, DATEADD(HOUR, 14, DATEADD(DAY, -32, GETDATE())))),
(1820, 'TIX-MEGA-1330-3', 1330, N'Bùi Thành', 'mega_req_330@gmail.com', 'TIX-MEGA-1330-3|E1073|1219', 0, DATEADD(MINUTE, 47, DATEADD(HOUR, 14, DATEADD(DAY, -32, GETDATE())))),
(1821, 'TIX-MEGA-1331-0', 1331, N'Hoàng Anh', 'mega_req_331@gmail.com', 'TIX-MEGA-1331-0|E1020|1060', 0, DATEADD(MINUTE, 27, DATEADD(HOUR, 22, DATEADD(DAY, -7, GETDATE())))),
(1822, 'TIX-MEGA-1331-1', 1331, N'Hoàng Anh', 'mega_req_331@gmail.com', 'TIX-MEGA-1331-1|E1020|1060', 0, DATEADD(MINUTE, 27, DATEADD(HOUR, 22, DATEADD(DAY, -7, GETDATE())))),
(1823, 'TIX-MEGA-1331-2', 1331, N'Hoàng Anh', 'mega_req_331@gmail.com', 'TIX-MEGA-1331-2|E1020|1060', 0, DATEADD(MINUTE, 27, DATEADD(HOUR, 22, DATEADD(DAY, -7, GETDATE())))),
(1824, 'TIX-MEGA-1332-0', 1332, N'Trần Hải', 'mega_req_332@gmail.com', 'TIX-MEGA-1332-0|E1080|1240', 0, DATEADD(MINUTE, 57, DATEADD(HOUR, 2, DATEADD(DAY, -46, GETDATE())))),
(1825, 'TIX-MEGA-1332-1', 1332, N'Trần Hải', 'mega_req_332@gmail.com', 'TIX-MEGA-1332-1|E1080|1240', 0, DATEADD(MINUTE, 57, DATEADD(HOUR, 2, DATEADD(DAY, -46, GETDATE())))),
(1826, 'TIX-MEGA-1332-2', 1332, N'Trần Hải', 'mega_req_332@gmail.com', 'TIX-MEGA-1332-2|E1080|1240', 0, DATEADD(MINUTE, 57, DATEADD(HOUR, 2, DATEADD(DAY, -46, GETDATE())))),
(1827, 'TIX-MEGA-1332-3', 1332, N'Trần Hải', 'mega_req_332@gmail.com', 'TIX-MEGA-1332-3|E1080|1240', 0, DATEADD(MINUTE, 57, DATEADD(HOUR, 2, DATEADD(DAY, -46, GETDATE())))),
(1828, 'TIX-MEGA-1333-0', 1333, N'Huỳnh Linh', 'mega_req_333@gmail.com', 'TIX-MEGA-1333-0|E1030|1092', 1, DATEADD(MINUTE, 53, DATEADD(HOUR, 0, DATEADD(DAY, -14, GETDATE())))),
(1829, 'TIX-MEGA-1333-1', 1333, N'Huỳnh Linh', 'mega_req_333@gmail.com', 'TIX-MEGA-1333-1|E1030|1092', 0, DATEADD(MINUTE, 53, DATEADD(HOUR, 0, DATEADD(DAY, -14, GETDATE())))),
(1830, 'TIX-MEGA-1333-2', 1333, N'Huỳnh Linh', 'mega_req_333@gmail.com', 'TIX-MEGA-1333-2|E1030|1092', 0, DATEADD(MINUTE, 53, DATEADD(HOUR, 0, DATEADD(DAY, -14, GETDATE())))),
(1831, 'TIX-MEGA-1334-0', 1334, N'Hoàng Kiên', 'mega_req_334@gmail.com', 'TIX-MEGA-1334-0|E1081|1243', 0, DATEADD(MINUTE, 29, DATEADD(HOUR, 23, DATEADD(DAY, -3, GETDATE())))),
(1832, 'TIX-MEGA-1334-1', 1334, N'Hoàng Kiên', 'mega_req_334@gmail.com', 'TIX-MEGA-1334-1|E1081|1243', 0, DATEADD(MINUTE, 29, DATEADD(HOUR, 23, DATEADD(DAY, -3, GETDATE())))),
(1833, 'TIX-MEGA-1335-0', 1335, N'Đặng Khoa', 'mega_req_335@gmail.com', 'TIX-MEGA-1335-0|E1019|1057', 0, DATEADD(MINUTE, 54, DATEADD(HOUR, 12, DATEADD(DAY, -53, GETDATE())))),
(1834, 'TIX-MEGA-1335-1', 1335, N'Đặng Khoa', 'mega_req_335@gmail.com', 'TIX-MEGA-1335-1|E1019|1057', 0, DATEADD(MINUTE, 54, DATEADD(HOUR, 12, DATEADD(DAY, -53, GETDATE())))),
(1835, 'TIX-MEGA-1336-0', 1336, N'Huỳnh Tâm', 'mega_req_336@gmail.com', 'TIX-MEGA-1336-0|E1098|1295', 0, DATEADD(MINUTE, 14, DATEADD(HOUR, 7, DATEADD(DAY, -13, GETDATE())))),
(1836, 'TIX-MEGA-1336-1', 1336, N'Huỳnh Tâm', 'mega_req_336@gmail.com', 'TIX-MEGA-1336-1|E1098|1295', 1, DATEADD(MINUTE, 14, DATEADD(HOUR, 7, DATEADD(DAY, -13, GETDATE())))),
(1837, 'TIX-MEGA-1336-2', 1336, N'Huỳnh Tâm', 'mega_req_336@gmail.com', 'TIX-MEGA-1336-2|E1098|1295', 0, DATEADD(MINUTE, 14, DATEADD(HOUR, 7, DATEADD(DAY, -13, GETDATE())))),
(1838, 'TIX-MEGA-1337-0', 1337, N'Lê Trang', 'mega_req_337@gmail.com', 'TIX-MEGA-1337-0|E1041|1125', 0, DATEADD(MINUTE, 48, DATEADD(HOUR, 3, DATEADD(DAY, -12, GETDATE())))),
(1839, 'TIX-MEGA-1337-1', 1337, N'Lê Trang', 'mega_req_337@gmail.com', 'TIX-MEGA-1337-1|E1041|1125', 0, DATEADD(MINUTE, 48, DATEADD(HOUR, 3, DATEADD(DAY, -12, GETDATE())))),
(1840, 'TIX-MEGA-1337-2', 1337, N'Lê Trang', 'mega_req_337@gmail.com', 'TIX-MEGA-1337-2|E1041|1125', 0, DATEADD(MINUTE, 48, DATEADD(HOUR, 3, DATEADD(DAY, -12, GETDATE())))),
(1841, 'TIX-MEGA-1338-0', 1338, N'Bùi Tâm', 'mega_req_338@gmail.com', 'TIX-MEGA-1338-0|E1089|1267', 0, DATEADD(MINUTE, 46, DATEADD(HOUR, 15, DATEADD(DAY, -21, GETDATE())))),
(1842, 'TIX-MEGA-1339-0', 1339, N'Hoàng Phong', 'mega_req_339@gmail.com', 'TIX-MEGA-1339-0|E1042|1128', 0, DATEADD(MINUTE, 5, DATEADD(HOUR, 18, DATEADD(DAY, -32, GETDATE())))),
(1843, 'TIX-MEGA-1339-1', 1339, N'Hoàng Phong', 'mega_req_339@gmail.com', 'TIX-MEGA-1339-1|E1042|1128', 0, DATEADD(MINUTE, 5, DATEADD(HOUR, 18, DATEADD(DAY, -32, GETDATE())))),
(1844, 'TIX-MEGA-1339-2', 1339, N'Hoàng Phong', 'mega_req_339@gmail.com', 'TIX-MEGA-1339-2|E1042|1128', 0, DATEADD(MINUTE, 5, DATEADD(HOUR, 18, DATEADD(DAY, -32, GETDATE())))),
(1845, 'TIX-MEGA-1340-0', 1340, N'Nguyễn Khoa', 'mega_req_340@gmail.com', 'TIX-MEGA-1340-0|E1075|1225', 1, DATEADD(MINUTE, 57, DATEADD(HOUR, 7, DATEADD(DAY, -42, GETDATE())))),
(1846, 'TIX-MEGA-1340-1', 1340, N'Nguyễn Khoa', 'mega_req_340@gmail.com', 'TIX-MEGA-1340-1|E1075|1225', 0, DATEADD(MINUTE, 57, DATEADD(HOUR, 7, DATEADD(DAY, -42, GETDATE())))),
(1847, 'TIX-MEGA-1340-2', 1340, N'Nguyễn Khoa', 'mega_req_340@gmail.com', 'TIX-MEGA-1340-2|E1075|1225', 0, DATEADD(MINUTE, 57, DATEADD(HOUR, 7, DATEADD(DAY, -42, GETDATE())))),
(1848, 'TIX-MEGA-1341-0', 1341, N'Phạm Trang', 'mega_req_341@gmail.com', 'TIX-MEGA-1341-0|E1016|1048', 0, DATEADD(MINUTE, 49, DATEADD(HOUR, 2, DATEADD(DAY, -58, GETDATE())))),
(1849, 'TIX-MEGA-1342-0', 1342, N'Đỗ Bảo', 'mega_req_342@gmail.com', 'TIX-MEGA-1342-0|E1076|1230', 0, DATEADD(MINUTE, 8, DATEADD(HOUR, 16, DATEADD(DAY, -18, GETDATE())))),
(1850, 'TIX-MEGA-1342-1', 1342, N'Đỗ Bảo', 'mega_req_342@gmail.com', 'TIX-MEGA-1342-1|E1076|1230', 0, DATEADD(MINUTE, 8, DATEADD(HOUR, 16, DATEADD(DAY, -18, GETDATE())))),
(1851, 'TIX-MEGA-1343-0', 1343, N'Vũ Thành', 'mega_req_343@gmail.com', 'TIX-MEGA-1343-0|E1038|1114', 0, DATEADD(MINUTE, 34, DATEADD(HOUR, 19, DATEADD(DAY, -57, GETDATE())))),
(1852, 'TIX-MEGA-1343-1', 1343, N'Vũ Thành', 'mega_req_343@gmail.com', 'TIX-MEGA-1343-1|E1038|1114', 0, DATEADD(MINUTE, 34, DATEADD(HOUR, 19, DATEADD(DAY, -57, GETDATE())))),
(1853, 'TIX-MEGA-1343-2', 1343, N'Vũ Thành', 'mega_req_343@gmail.com', 'TIX-MEGA-1343-2|E1038|1114', 1, DATEADD(MINUTE, 34, DATEADD(HOUR, 19, DATEADD(DAY, -57, GETDATE())))),
(1854, 'TIX-MEGA-1344-0', 1344, N'Trần Hùng', 'mega_req_344@gmail.com', 'TIX-MEGA-1344-0|E1004|1013', 0, DATEADD(MINUTE, 41, DATEADD(HOUR, 22, DATEADD(DAY, -34, GETDATE())))),
(1855, 'TIX-MEGA-1344-1', 1344, N'Trần Hùng', 'mega_req_344@gmail.com', 'TIX-MEGA-1344-1|E1004|1013', 0, DATEADD(MINUTE, 41, DATEADD(HOUR, 22, DATEADD(DAY, -34, GETDATE())))),
(1856, 'TIX-MEGA-1344-2', 1344, N'Trần Hùng', 'mega_req_344@gmail.com', 'TIX-MEGA-1344-2|E1004|1013', 0, DATEADD(MINUTE, 41, DATEADD(HOUR, 22, DATEADD(DAY, -34, GETDATE())))),
(1857, 'TIX-MEGA-1344-3', 1344, N'Trần Hùng', 'mega_req_344@gmail.com', 'TIX-MEGA-1344-3|E1004|1013', 0, DATEADD(MINUTE, 41, DATEADD(HOUR, 22, DATEADD(DAY, -34, GETDATE())))),
(1858, 'TIX-MEGA-1345-0', 1345, N'Vũ Tâm', 'mega_req_345@gmail.com', 'TIX-MEGA-1345-0|E1045|1136', 0, DATEADD(MINUTE, 58, DATEADD(HOUR, 23, DATEADD(DAY, -9, GETDATE())))),
(1859, 'TIX-MEGA-1345-1', 1345, N'Vũ Tâm', 'mega_req_345@gmail.com', 'TIX-MEGA-1345-1|E1045|1136', 0, DATEADD(MINUTE, 58, DATEADD(HOUR, 23, DATEADD(DAY, -9, GETDATE())))),
(1860, 'TIX-MEGA-1345-2', 1345, N'Vũ Tâm', 'mega_req_345@gmail.com', 'TIX-MEGA-1345-2|E1045|1136', 0, DATEADD(MINUTE, 58, DATEADD(HOUR, 23, DATEADD(DAY, -9, GETDATE())))),
(1861, 'TIX-MEGA-1345-3', 1345, N'Vũ Tâm', 'mega_req_345@gmail.com', 'TIX-MEGA-1345-3|E1045|1136', 0, DATEADD(MINUTE, 58, DATEADD(HOUR, 23, DATEADD(DAY, -9, GETDATE())))),
(1862, 'TIX-MEGA-1346-0', 1346, N'Hoàng Thu', 'mega_req_346@gmail.com', 'TIX-MEGA-1346-0|E1056|1170', 0, DATEADD(MINUTE, 59, DATEADD(HOUR, 9, DATEADD(DAY, -3, GETDATE())))),
(1863, 'TIX-MEGA-1346-1', 1346, N'Hoàng Thu', 'mega_req_346@gmail.com', 'TIX-MEGA-1346-1|E1056|1170', 0, DATEADD(MINUTE, 59, DATEADD(HOUR, 9, DATEADD(DAY, -3, GETDATE())))),
(1864, 'TIX-MEGA-1346-2', 1346, N'Hoàng Thu', 'mega_req_346@gmail.com', 'TIX-MEGA-1346-2|E1056|1170', 0, DATEADD(MINUTE, 59, DATEADD(HOUR, 9, DATEADD(DAY, -3, GETDATE())))),
(1865, 'TIX-MEGA-1347-0', 1347, N'Nguyễn Thành', 'mega_req_347@gmail.com', 'TIX-MEGA-1347-0|E1046|1139', 0, DATEADD(MINUTE, 46, DATEADD(HOUR, 12, DATEADD(DAY, -42, GETDATE())))),
(1866, 'TIX-MEGA-1347-1', 1347, N'Nguyễn Thành', 'mega_req_347@gmail.com', 'TIX-MEGA-1347-1|E1046|1139', 0, DATEADD(MINUTE, 46, DATEADD(HOUR, 12, DATEADD(DAY, -42, GETDATE())))),
(1867, 'TIX-MEGA-1347-2', 1347, N'Nguyễn Thành', 'mega_req_347@gmail.com', 'TIX-MEGA-1347-2|E1046|1139', 0, DATEADD(MINUTE, 46, DATEADD(HOUR, 12, DATEADD(DAY, -42, GETDATE())))),
(1868, 'TIX-MEGA-1347-3', 1347, N'Nguyễn Thành', 'mega_req_347@gmail.com', 'TIX-MEGA-1347-3|E1046|1139', 0, DATEADD(MINUTE, 46, DATEADD(HOUR, 12, DATEADD(DAY, -42, GETDATE())))),
(1869, 'TIX-MEGA-1348-0', 1348, N'Bùi Vân', 'mega_req_348@gmail.com', 'TIX-MEGA-1348-0|E1059|1179', 0, DATEADD(MINUTE, 26, DATEADD(HOUR, 6, DATEADD(DAY, -16, GETDATE())))),
(1870, 'TIX-MEGA-1348-1', 1348, N'Bùi Vân', 'mega_req_348@gmail.com', 'TIX-MEGA-1348-1|E1059|1179', 0, DATEADD(MINUTE, 26, DATEADD(HOUR, 6, DATEADD(DAY, -16, GETDATE())))),
(1871, 'TIX-MEGA-1349-0', 1349, N'Lê Phong', 'mega_req_349@gmail.com', 'TIX-MEGA-1349-0|E1041|1123', 0, DATEADD(MINUTE, 3, DATEADD(HOUR, 1, DATEADD(DAY, -48, GETDATE())))),
(1872, 'TIX-MEGA-1349-1', 1349, N'Lê Phong', 'mega_req_349@gmail.com', 'TIX-MEGA-1349-1|E1041|1123', 0, DATEADD(MINUTE, 3, DATEADD(HOUR, 1, DATEADD(DAY, -48, GETDATE())))),
(1873, 'TIX-MEGA-1350-0', 1350, N'Hoàng Hải', 'mega_req_350@gmail.com', 'TIX-MEGA-1350-0|E1033|1099', 0, DATEADD(MINUTE, 50, DATEADD(HOUR, 22, DATEADD(DAY, -15, GETDATE())))),
(1874, 'TIX-MEGA-1350-1', 1350, N'Hoàng Hải', 'mega_req_350@gmail.com', 'TIX-MEGA-1350-1|E1033|1099', 0, DATEADD(MINUTE, 50, DATEADD(HOUR, 22, DATEADD(DAY, -15, GETDATE())))),
(1875, 'TIX-MEGA-1350-2', 1350, N'Hoàng Hải', 'mega_req_350@gmail.com', 'TIX-MEGA-1350-2|E1033|1099', 0, DATEADD(MINUTE, 50, DATEADD(HOUR, 22, DATEADD(DAY, -15, GETDATE())))),
(1876, 'TIX-MEGA-1351-0', 1351, N'Đỗ Hùng', 'mega_req_351@gmail.com', 'TIX-MEGA-1351-0|E1098|1296', 0, DATEADD(MINUTE, 16, DATEADD(HOUR, 14, DATEADD(DAY, -30, GETDATE())))),
(1877, 'TIX-MEGA-1352-0', 1352, N'Trần Anh', 'mega_req_352@gmail.com', 'TIX-MEGA-1352-0|E1000|1002', 0, DATEADD(MINUTE, 59, DATEADD(HOUR, 20, DATEADD(DAY, -49, GETDATE())))),
(1878, 'TIX-MEGA-1352-1', 1352, N'Trần Anh', 'mega_req_352@gmail.com', 'TIX-MEGA-1352-1|E1000|1002', 0, DATEADD(MINUTE, 59, DATEADD(HOUR, 20, DATEADD(DAY, -49, GETDATE())))),
(1879, 'TIX-MEGA-1352-2', 1352, N'Trần Anh', 'mega_req_352@gmail.com', 'TIX-MEGA-1352-2|E1000|1002', 0, DATEADD(MINUTE, 59, DATEADD(HOUR, 20, DATEADD(DAY, -49, GETDATE())))),
(1880, 'TIX-MEGA-1353-0', 1353, N'Vũ Bảo', 'mega_req_353@gmail.com', 'TIX-MEGA-1353-0|E1041|1123', 0, DATEADD(MINUTE, 48, DATEADD(HOUR, 16, DATEADD(DAY, -39, GETDATE())))),
(1881, 'TIX-MEGA-1353-1', 1353, N'Vũ Bảo', 'mega_req_353@gmail.com', 'TIX-MEGA-1353-1|E1041|1123', 0, DATEADD(MINUTE, 48, DATEADD(HOUR, 16, DATEADD(DAY, -39, GETDATE())))),
(1882, 'TIX-MEGA-1353-2', 1353, N'Vũ Bảo', 'mega_req_353@gmail.com', 'TIX-MEGA-1353-2|E1041|1123', 0, DATEADD(MINUTE, 48, DATEADD(HOUR, 16, DATEADD(DAY, -39, GETDATE())))),
(1883, 'TIX-MEGA-1354-0', 1354, N'Trần Hùng', 'mega_req_354@gmail.com', 'TIX-MEGA-1354-0|E1018|1054', 0, DATEADD(MINUTE, 58, DATEADD(HOUR, 1, DATEADD(DAY, -55, GETDATE())))),
(1884, 'TIX-MEGA-1354-1', 1354, N'Trần Hùng', 'mega_req_354@gmail.com', 'TIX-MEGA-1354-1|E1018|1054', 0, DATEADD(MINUTE, 58, DATEADD(HOUR, 1, DATEADD(DAY, -55, GETDATE())))),
(1885, 'TIX-MEGA-1354-2', 1354, N'Trần Hùng', 'mega_req_354@gmail.com', 'TIX-MEGA-1354-2|E1018|1054', 0, DATEADD(MINUTE, 58, DATEADD(HOUR, 1, DATEADD(DAY, -55, GETDATE())))),
(1886, 'TIX-MEGA-1355-0', 1355, N'Hoàng Phong', 'mega_req_355@gmail.com', 'TIX-MEGA-1355-0|E1011|1033', 0, DATEADD(MINUTE, 28, DATEADD(HOUR, 5, DATEADD(DAY, -57, GETDATE())))),
(1887, 'TIX-MEGA-1355-1', 1355, N'Hoàng Phong', 'mega_req_355@gmail.com', 'TIX-MEGA-1355-1|E1011|1033', 0, DATEADD(MINUTE, 28, DATEADD(HOUR, 5, DATEADD(DAY, -57, GETDATE())))),
(1888, 'TIX-MEGA-1355-2', 1355, N'Hoàng Phong', 'mega_req_355@gmail.com', 'TIX-MEGA-1355-2|E1011|1033', 0, DATEADD(MINUTE, 28, DATEADD(HOUR, 5, DATEADD(DAY, -57, GETDATE())))),
(1889, 'TIX-MEGA-1356-0', 1356, N'Trần Vân', 'mega_req_356@gmail.com', 'TIX-MEGA-1356-0|E1070|1211', 0, DATEADD(MINUTE, 45, DATEADD(HOUR, 8, DATEADD(DAY, -24, GETDATE())))),
(1890, 'TIX-MEGA-1356-1', 1356, N'Trần Vân', 'mega_req_356@gmail.com', 'TIX-MEGA-1356-1|E1070|1211', 0, DATEADD(MINUTE, 45, DATEADD(HOUR, 8, DATEADD(DAY, -24, GETDATE())))),
(1891, 'TIX-MEGA-1356-2', 1356, N'Trần Vân', 'mega_req_356@gmail.com', 'TIX-MEGA-1356-2|E1070|1211', 0, DATEADD(MINUTE, 45, DATEADD(HOUR, 8, DATEADD(DAY, -24, GETDATE())))),
(1892, 'TIX-MEGA-1357-0', 1357, N'Lê Lan', 'mega_req_357@gmail.com', 'TIX-MEGA-1357-0|E1031|1093', 0, DATEADD(MINUTE, 23, DATEADD(HOUR, 13, DATEADD(DAY, -25, GETDATE())))),
(1893, 'TIX-MEGA-1357-1', 1357, N'Lê Lan', 'mega_req_357@gmail.com', 'TIX-MEGA-1357-1|E1031|1093', 1, DATEADD(MINUTE, 23, DATEADD(HOUR, 13, DATEADD(DAY, -25, GETDATE())))),
(1894, 'TIX-MEGA-1357-2', 1357, N'Lê Lan', 'mega_req_357@gmail.com', 'TIX-MEGA-1357-2|E1031|1093', 1, DATEADD(MINUTE, 23, DATEADD(HOUR, 13, DATEADD(DAY, -25, GETDATE())))),
(1895, 'TIX-MEGA-1357-3', 1357, N'Lê Lan', 'mega_req_357@gmail.com', 'TIX-MEGA-1357-3|E1031|1093', 0, DATEADD(MINUTE, 23, DATEADD(HOUR, 13, DATEADD(DAY, -25, GETDATE())))),
(1896, 'TIX-MEGA-1358-0', 1358, N'Phạm Lan', 'mega_req_358@gmail.com', 'TIX-MEGA-1358-0|E1003|1010', 0, DATEADD(MINUTE, 14, DATEADD(HOUR, 18, DATEADD(DAY, -29, GETDATE())))),
(1897, 'TIX-MEGA-1359-0', 1359, N'Đỗ Hùng', 'mega_req_359@gmail.com', 'TIX-MEGA-1359-0|E1054|1164', 0, DATEADD(MINUTE, 38, DATEADD(HOUR, 3, DATEADD(DAY, -3, GETDATE())))),
(1898, 'TIX-MEGA-1359-1', 1359, N'Đỗ Hùng', 'mega_req_359@gmail.com', 'TIX-MEGA-1359-1|E1054|1164', 0, DATEADD(MINUTE, 38, DATEADD(HOUR, 3, DATEADD(DAY, -3, GETDATE())))),
(1899, 'TIX-MEGA-1359-2', 1359, N'Đỗ Hùng', 'mega_req_359@gmail.com', 'TIX-MEGA-1359-2|E1054|1164', 0, DATEADD(MINUTE, 38, DATEADD(HOUR, 3, DATEADD(DAY, -3, GETDATE())))),
(1900, 'TIX-MEGA-1360-0', 1360, N'Đỗ Minh', 'mega_req_360@gmail.com', 'TIX-MEGA-1360-0|E1037|1112', 0, DATEADD(MINUTE, 52, DATEADD(HOUR, 16, DATEADD(DAY, -27, GETDATE())))),
(1901, 'TIX-MEGA-1361-0', 1361, N'Phạm Trang', 'mega_req_361@gmail.com', 'TIX-MEGA-1361-0|E1029|1087', 0, DATEADD(MINUTE, 35, DATEADD(HOUR, 15, DATEADD(DAY, -4, GETDATE())))),
(1902, 'TIX-MEGA-1361-1', 1361, N'Phạm Trang', 'mega_req_361@gmail.com', 'TIX-MEGA-1361-1|E1029|1087', 0, DATEADD(MINUTE, 35, DATEADD(HOUR, 15, DATEADD(DAY, -4, GETDATE())))),
(1903, 'TIX-MEGA-1361-2', 1361, N'Phạm Trang', 'mega_req_361@gmail.com', 'TIX-MEGA-1361-2|E1029|1087', 1, DATEADD(MINUTE, 35, DATEADD(HOUR, 15, DATEADD(DAY, -4, GETDATE())))),
(1904, 'TIX-MEGA-1361-3', 1361, N'Phạm Trang', 'mega_req_361@gmail.com', 'TIX-MEGA-1361-3|E1029|1087', 1, DATEADD(MINUTE, 35, DATEADD(HOUR, 15, DATEADD(DAY, -4, GETDATE())))),
(1905, 'TIX-MEGA-1362-0', 1362, N'Hoàng Minh', 'mega_req_362@gmail.com', 'TIX-MEGA-1362-0|E1057|1171', 0, DATEADD(MINUTE, 30, DATEADD(HOUR, 6, DATEADD(DAY, -57, GETDATE())))),
(1906, 'TIX-MEGA-1362-1', 1362, N'Hoàng Minh', 'mega_req_362@gmail.com', 'TIX-MEGA-1362-1|E1057|1171', 0, DATEADD(MINUTE, 30, DATEADD(HOUR, 6, DATEADD(DAY, -57, GETDATE())))),
(1907, 'TIX-MEGA-1362-2', 1362, N'Hoàng Minh', 'mega_req_362@gmail.com', 'TIX-MEGA-1362-2|E1057|1171', 0, DATEADD(MINUTE, 30, DATEADD(HOUR, 6, DATEADD(DAY, -57, GETDATE())))),
(1908, 'TIX-MEGA-1362-3', 1362, N'Hoàng Minh', 'mega_req_362@gmail.com', 'TIX-MEGA-1362-3|E1057|1171', 0, DATEADD(MINUTE, 30, DATEADD(HOUR, 6, DATEADD(DAY, -57, GETDATE())))),
(1909, 'TIX-MEGA-1363-0', 1363, N'Lê Phong', 'mega_req_363@gmail.com', 'TIX-MEGA-1363-0|E1084|1253', 0, DATEADD(MINUTE, 6, DATEADD(HOUR, 20, DATEADD(DAY, 0, GETDATE())))),
(1910, 'TIX-MEGA-1363-1', 1363, N'Lê Phong', 'mega_req_363@gmail.com', 'TIX-MEGA-1363-1|E1084|1253', 0, DATEADD(MINUTE, 6, DATEADD(HOUR, 20, DATEADD(DAY, 0, GETDATE()))));
INSERT INTO Tickets (ticket_id, ticket_code, order_item_id, attendee_name, attendee_email, qr_code, is_checked_in, created_at) VALUES
(1911, 'TIX-MEGA-1364-0', 1364, N'Huỳnh Khoa', 'mega_req_364@gmail.com', 'TIX-MEGA-1364-0|E1054|1162', 0, DATEADD(MINUTE, 15, DATEADD(HOUR, 1, DATEADD(DAY, -20, GETDATE())))),
(1912, 'TIX-MEGA-1364-1', 1364, N'Huỳnh Khoa', 'mega_req_364@gmail.com', 'TIX-MEGA-1364-1|E1054|1162', 0, DATEADD(MINUTE, 15, DATEADD(HOUR, 1, DATEADD(DAY, -20, GETDATE())))),
(1913, 'TIX-MEGA-1364-2', 1364, N'Huỳnh Khoa', 'mega_req_364@gmail.com', 'TIX-MEGA-1364-2|E1054|1162', 0, DATEADD(MINUTE, 15, DATEADD(HOUR, 1, DATEADD(DAY, -20, GETDATE())))),
(1914, 'TIX-MEGA-1364-3', 1364, N'Huỳnh Khoa', 'mega_req_364@gmail.com', 'TIX-MEGA-1364-3|E1054|1162', 0, DATEADD(MINUTE, 15, DATEADD(HOUR, 1, DATEADD(DAY, -20, GETDATE())))),
(1915, 'TIX-MEGA-1365-0', 1365, N'Phạm Thành', 'mega_req_365@gmail.com', 'TIX-MEGA-1365-0|E1066|1198', 0, DATEADD(MINUTE, 45, DATEADD(HOUR, 15, DATEADD(DAY, -49, GETDATE())))),
(1916, 'TIX-MEGA-1365-1', 1365, N'Phạm Thành', 'mega_req_365@gmail.com', 'TIX-MEGA-1365-1|E1066|1198', 1, DATEADD(MINUTE, 45, DATEADD(HOUR, 15, DATEADD(DAY, -49, GETDATE())))),
(1917, 'TIX-MEGA-1366-0', 1366, N'Phạm Phong', 'mega_req_366@gmail.com', 'TIX-MEGA-1366-0|E1093|1279', 0, DATEADD(MINUTE, 34, DATEADD(HOUR, 15, DATEADD(DAY, -2, GETDATE())))),
(1918, 'TIX-MEGA-1366-1', 1366, N'Phạm Phong', 'mega_req_366@gmail.com', 'TIX-MEGA-1366-1|E1093|1279', 0, DATEADD(MINUTE, 34, DATEADD(HOUR, 15, DATEADD(DAY, -2, GETDATE())))),
(1919, 'TIX-MEGA-1366-2', 1366, N'Phạm Phong', 'mega_req_366@gmail.com', 'TIX-MEGA-1366-2|E1093|1279', 0, DATEADD(MINUTE, 34, DATEADD(HOUR, 15, DATEADD(DAY, -2, GETDATE())))),
(1920, 'TIX-MEGA-1367-0', 1367, N'Trần Bảo', 'mega_req_367@gmail.com', 'TIX-MEGA-1367-0|E1089|1267', 0, DATEADD(MINUTE, 48, DATEADD(HOUR, 15, DATEADD(DAY, -34, GETDATE())))),
(1921, 'TIX-MEGA-1367-1', 1367, N'Trần Bảo', 'mega_req_367@gmail.com', 'TIX-MEGA-1367-1|E1089|1267', 0, DATEADD(MINUTE, 48, DATEADD(HOUR, 15, DATEADD(DAY, -34, GETDATE())))),
(1922, 'TIX-MEGA-1367-2', 1367, N'Trần Bảo', 'mega_req_367@gmail.com', 'TIX-MEGA-1367-2|E1089|1267', 0, DATEADD(MINUTE, 48, DATEADD(HOUR, 15, DATEADD(DAY, -34, GETDATE())))),
(1923, 'TIX-MEGA-1368-0', 1368, N'Bùi Hải', 'mega_req_368@gmail.com', 'TIX-MEGA-1368-0|E1000|1001', 0, DATEADD(MINUTE, 12, DATEADD(HOUR, 4, DATEADD(DAY, -5, GETDATE())))),
(1924, 'TIX-MEGA-1368-1', 1368, N'Bùi Hải', 'mega_req_368@gmail.com', 'TIX-MEGA-1368-1|E1000|1001', 0, DATEADD(MINUTE, 12, DATEADD(HOUR, 4, DATEADD(DAY, -5, GETDATE())))),
(1925, 'TIX-MEGA-1368-2', 1368, N'Bùi Hải', 'mega_req_368@gmail.com', 'TIX-MEGA-1368-2|E1000|1001', 0, DATEADD(MINUTE, 12, DATEADD(HOUR, 4, DATEADD(DAY, -5, GETDATE())))),
(1926, 'TIX-MEGA-1369-0', 1369, N'Lê Trang', 'mega_req_369@gmail.com', 'TIX-MEGA-1369-0|E1003|1009', 0, DATEADD(MINUTE, 17, DATEADD(HOUR, 22, DATEADD(DAY, -53, GETDATE())))),
(1927, 'TIX-MEGA-1369-1', 1369, N'Lê Trang', 'mega_req_369@gmail.com', 'TIX-MEGA-1369-1|E1003|1009', 0, DATEADD(MINUTE, 17, DATEADD(HOUR, 22, DATEADD(DAY, -53, GETDATE())))),
(1928, 'TIX-MEGA-1369-2', 1369, N'Lê Trang', 'mega_req_369@gmail.com', 'TIX-MEGA-1369-2|E1003|1009', 0, DATEADD(MINUTE, 17, DATEADD(HOUR, 22, DATEADD(DAY, -53, GETDATE())))),
(1929, 'TIX-MEGA-1370-0', 1370, N'Huỳnh Linh', 'mega_req_370@gmail.com', 'TIX-MEGA-1370-0|E1055|1165', 0, DATEADD(MINUTE, 6, DATEADD(HOUR, 15, DATEADD(DAY, -46, GETDATE())))),
(1930, 'TIX-MEGA-1370-1', 1370, N'Huỳnh Linh', 'mega_req_370@gmail.com', 'TIX-MEGA-1370-1|E1055|1165', 0, DATEADD(MINUTE, 6, DATEADD(HOUR, 15, DATEADD(DAY, -46, GETDATE())))),
(1931, 'TIX-MEGA-1370-2', 1370, N'Huỳnh Linh', 'mega_req_370@gmail.com', 'TIX-MEGA-1370-2|E1055|1165', 0, DATEADD(MINUTE, 6, DATEADD(HOUR, 15, DATEADD(DAY, -46, GETDATE())))),
(1932, 'TIX-MEGA-1370-3', 1370, N'Huỳnh Linh', 'mega_req_370@gmail.com', 'TIX-MEGA-1370-3|E1055|1165', 0, DATEADD(MINUTE, 6, DATEADD(HOUR, 15, DATEADD(DAY, -46, GETDATE())))),
(1933, 'TIX-MEGA-1371-0', 1371, N'Đặng Trang', 'mega_req_371@gmail.com', 'TIX-MEGA-1371-0|E1074|1224', 0, DATEADD(MINUTE, 17, DATEADD(HOUR, 18, DATEADD(DAY, -4, GETDATE())))),
(1934, 'TIX-MEGA-1372-0', 1372, N'Trần Linh', 'mega_req_372@gmail.com', 'TIX-MEGA-1372-0|E1051|1154', 0, DATEADD(MINUTE, 4, DATEADD(HOUR, 15, DATEADD(DAY, -59, GETDATE())))),
(1935, 'TIX-MEGA-1372-1', 1372, N'Trần Linh', 'mega_req_372@gmail.com', 'TIX-MEGA-1372-1|E1051|1154', 0, DATEADD(MINUTE, 4, DATEADD(HOUR, 15, DATEADD(DAY, -59, GETDATE())))),
(1936, 'TIX-MEGA-1373-0', 1373, N'Đặng Tâm', 'mega_req_373@gmail.com', 'TIX-MEGA-1373-0|E1007|1022', 0, DATEADD(MINUTE, 47, DATEADD(HOUR, 16, DATEADD(DAY, -52, GETDATE())))),
(1937, 'TIX-MEGA-1374-0', 1374, N'Phạm Tâm', 'mega_req_374@gmail.com', 'TIX-MEGA-1374-0|E1044|1132', 0, DATEADD(MINUTE, 46, DATEADD(HOUR, 21, DATEADD(DAY, -42, GETDATE())))),
(1938, 'TIX-MEGA-1374-1', 1374, N'Phạm Tâm', 'mega_req_374@gmail.com', 'TIX-MEGA-1374-1|E1044|1132', 0, DATEADD(MINUTE, 46, DATEADD(HOUR, 21, DATEADD(DAY, -42, GETDATE())))),
(1939, 'TIX-MEGA-1374-2', 1374, N'Phạm Tâm', 'mega_req_374@gmail.com', 'TIX-MEGA-1374-2|E1044|1132', 0, DATEADD(MINUTE, 46, DATEADD(HOUR, 21, DATEADD(DAY, -42, GETDATE())))),
(1940, 'TIX-MEGA-1375-0', 1375, N'Bùi Lan', 'mega_req_375@gmail.com', 'TIX-MEGA-1375-0|E1014|1042', 0, DATEADD(MINUTE, 59, DATEADD(HOUR, 22, DATEADD(DAY, -4, GETDATE())))),
(1941, 'TIX-MEGA-1376-0', 1376, N'Huỳnh Kiên', 'mega_req_376@gmail.com', 'TIX-MEGA-1376-0|E1013|1040', 0, DATEADD(MINUTE, 24, DATEADD(HOUR, 4, DATEADD(DAY, -33, GETDATE())))),
(1942, 'TIX-MEGA-1376-1', 1376, N'Huỳnh Kiên', 'mega_req_376@gmail.com', 'TIX-MEGA-1376-1|E1013|1040', 0, DATEADD(MINUTE, 24, DATEADD(HOUR, 4, DATEADD(DAY, -33, GETDATE())))),
(1943, 'TIX-MEGA-1376-2', 1376, N'Huỳnh Kiên', 'mega_req_376@gmail.com', 'TIX-MEGA-1376-2|E1013|1040', 0, DATEADD(MINUTE, 24, DATEADD(HOUR, 4, DATEADD(DAY, -33, GETDATE())))),
(1944, 'TIX-MEGA-1377-0', 1377, N'Đỗ Kiên', 'mega_req_377@gmail.com', 'TIX-MEGA-1377-0|E1001|1003', 0, DATEADD(MINUTE, 5, DATEADD(HOUR, 0, DATEADD(DAY, -41, GETDATE())))),
(1945, 'TIX-MEGA-1378-0', 1378, N'Vũ Anh', 'mega_req_378@gmail.com', 'TIX-MEGA-1378-0|E1039|1118', 0, DATEADD(MINUTE, 7, DATEADD(HOUR, 13, DATEADD(DAY, -39, GETDATE())))),
(1946, 'TIX-MEGA-1378-1', 1378, N'Vũ Anh', 'mega_req_378@gmail.com', 'TIX-MEGA-1378-1|E1039|1118', 0, DATEADD(MINUTE, 7, DATEADD(HOUR, 13, DATEADD(DAY, -39, GETDATE())))),
(1947, 'TIX-MEGA-1379-0', 1379, N'Đặng Trang', 'mega_req_379@gmail.com', 'TIX-MEGA-1379-0|E1081|1244', 0, DATEADD(MINUTE, 3, DATEADD(HOUR, 14, DATEADD(DAY, -6, GETDATE())))),
(1948, 'TIX-MEGA-1379-1', 1379, N'Đặng Trang', 'mega_req_379@gmail.com', 'TIX-MEGA-1379-1|E1081|1244', 0, DATEADD(MINUTE, 3, DATEADD(HOUR, 14, DATEADD(DAY, -6, GETDATE())))),
(1949, 'TIX-MEGA-1380-0', 1380, N'Vũ Khoa', 'mega_req_380@gmail.com', 'TIX-MEGA-1380-0|E1074|1222', 0, DATEADD(MINUTE, 49, DATEADD(HOUR, 21, DATEADD(DAY, -1, GETDATE())))),
(1950, 'TIX-MEGA-1380-1', 1380, N'Vũ Khoa', 'mega_req_380@gmail.com', 'TIX-MEGA-1380-1|E1074|1222', 0, DATEADD(MINUTE, 49, DATEADD(HOUR, 21, DATEADD(DAY, -1, GETDATE())))),
(1951, 'TIX-MEGA-1381-0', 1381, N'Bùi Phong', 'mega_req_381@gmail.com', 'TIX-MEGA-1381-0|E1036|1109', 0, DATEADD(MINUTE, 59, DATEADD(HOUR, 18, DATEADD(DAY, -58, GETDATE())))),
(1952, 'TIX-MEGA-1381-1', 1381, N'Bùi Phong', 'mega_req_381@gmail.com', 'TIX-MEGA-1381-1|E1036|1109', 0, DATEADD(MINUTE, 59, DATEADD(HOUR, 18, DATEADD(DAY, -58, GETDATE())))),
(1953, 'TIX-MEGA-1381-2', 1381, N'Bùi Phong', 'mega_req_381@gmail.com', 'TIX-MEGA-1381-2|E1036|1109', 0, DATEADD(MINUTE, 59, DATEADD(HOUR, 18, DATEADD(DAY, -58, GETDATE())))),
(1954, 'TIX-MEGA-1381-3', 1381, N'Bùi Phong', 'mega_req_381@gmail.com', 'TIX-MEGA-1381-3|E1036|1109', 0, DATEADD(MINUTE, 59, DATEADD(HOUR, 18, DATEADD(DAY, -58, GETDATE())))),
(1955, 'TIX-MEGA-1382-0', 1382, N'Đặng Vân', 'mega_req_382@gmail.com', 'TIX-MEGA-1382-0|E1006|1019', 0, DATEADD(MINUTE, 18, DATEADD(HOUR, 5, DATEADD(DAY, -58, GETDATE())))),
(1956, 'TIX-MEGA-1382-1', 1382, N'Đặng Vân', 'mega_req_382@gmail.com', 'TIX-MEGA-1382-1|E1006|1019', 0, DATEADD(MINUTE, 18, DATEADD(HOUR, 5, DATEADD(DAY, -58, GETDATE())))),
(1957, 'TIX-MEGA-1382-2', 1382, N'Đặng Vân', 'mega_req_382@gmail.com', 'TIX-MEGA-1382-2|E1006|1019', 0, DATEADD(MINUTE, 18, DATEADD(HOUR, 5, DATEADD(DAY, -58, GETDATE())))),
(1958, 'TIX-MEGA-1383-0', 1383, N'Huỳnh Lan', 'mega_req_383@gmail.com', 'TIX-MEGA-1383-0|E1026|1078', 0, DATEADD(MINUTE, 59, DATEADD(HOUR, 7, DATEADD(DAY, -4, GETDATE())))),
(1959, 'TIX-MEGA-1383-1', 1383, N'Huỳnh Lan', 'mega_req_383@gmail.com', 'TIX-MEGA-1383-1|E1026|1078', 0, DATEADD(MINUTE, 59, DATEADD(HOUR, 7, DATEADD(DAY, -4, GETDATE())))),
(1960, 'TIX-MEGA-1383-2', 1383, N'Huỳnh Lan', 'mega_req_383@gmail.com', 'TIX-MEGA-1383-2|E1026|1078', 0, DATEADD(MINUTE, 59, DATEADD(HOUR, 7, DATEADD(DAY, -4, GETDATE())))),
(1961, 'TIX-MEGA-1384-0', 1384, N'Trần Hùng', 'mega_req_384@gmail.com', 'TIX-MEGA-1384-0|E1098|1294', 0, DATEADD(MINUTE, 27, DATEADD(HOUR, 18, DATEADD(DAY, -19, GETDATE())))),
(1962, 'TIX-MEGA-1384-1', 1384, N'Trần Hùng', 'mega_req_384@gmail.com', 'TIX-MEGA-1384-1|E1098|1294', 0, DATEADD(MINUTE, 27, DATEADD(HOUR, 18, DATEADD(DAY, -19, GETDATE())))),
(1963, 'TIX-MEGA-1384-2', 1384, N'Trần Hùng', 'mega_req_384@gmail.com', 'TIX-MEGA-1384-2|E1098|1294', 0, DATEADD(MINUTE, 27, DATEADD(HOUR, 18, DATEADD(DAY, -19, GETDATE())))),
(1964, 'TIX-MEGA-1384-3', 1384, N'Trần Hùng', 'mega_req_384@gmail.com', 'TIX-MEGA-1384-3|E1098|1294', 1, DATEADD(MINUTE, 27, DATEADD(HOUR, 18, DATEADD(DAY, -19, GETDATE())))),
(1965, 'TIX-MEGA-1385-0', 1385, N'Nguyễn Anh', 'mega_req_385@gmail.com', 'TIX-MEGA-1385-0|E1004|1014', 1, DATEADD(MINUTE, 21, DATEADD(HOUR, 14, DATEADD(DAY, -41, GETDATE())))),
(1966, 'TIX-MEGA-1385-1', 1385, N'Nguyễn Anh', 'mega_req_385@gmail.com', 'TIX-MEGA-1385-1|E1004|1014', 0, DATEADD(MINUTE, 21, DATEADD(HOUR, 14, DATEADD(DAY, -41, GETDATE())))),
(1967, 'TIX-MEGA-1385-2', 1385, N'Nguyễn Anh', 'mega_req_385@gmail.com', 'TIX-MEGA-1385-2|E1004|1014', 0, DATEADD(MINUTE, 21, DATEADD(HOUR, 14, DATEADD(DAY, -41, GETDATE())))),
(1968, 'TIX-MEGA-1386-0', 1386, N'Huỳnh Hùng', 'mega_req_386@gmail.com', 'TIX-MEGA-1386-0|E1039|1119', 0, DATEADD(MINUTE, 44, DATEADD(HOUR, 21, DATEADD(DAY, -34, GETDATE())))),
(1969, 'TIX-MEGA-1386-1', 1386, N'Huỳnh Hùng', 'mega_req_386@gmail.com', 'TIX-MEGA-1386-1|E1039|1119', 0, DATEADD(MINUTE, 44, DATEADD(HOUR, 21, DATEADD(DAY, -34, GETDATE())))),
(1970, 'TIX-MEGA-1387-0', 1387, N'Lê Hùng', 'mega_req_387@gmail.com', 'TIX-MEGA-1387-0|E1087|1263', 0, DATEADD(MINUTE, 46, DATEADD(HOUR, 23, DATEADD(DAY, -6, GETDATE())))),
(1971, 'TIX-MEGA-1387-1', 1387, N'Lê Hùng', 'mega_req_387@gmail.com', 'TIX-MEGA-1387-1|E1087|1263', 0, DATEADD(MINUTE, 46, DATEADD(HOUR, 23, DATEADD(DAY, -6, GETDATE())))),
(1972, 'TIX-MEGA-1387-2', 1387, N'Lê Hùng', 'mega_req_387@gmail.com', 'TIX-MEGA-1387-2|E1087|1263', 0, DATEADD(MINUTE, 46, DATEADD(HOUR, 23, DATEADD(DAY, -6, GETDATE())))),
(1973, 'TIX-MEGA-1388-0', 1388, N'Huỳnh Linh', 'mega_req_388@gmail.com', 'TIX-MEGA-1388-0|E1038|1114', 0, DATEADD(MINUTE, 41, DATEADD(HOUR, 13, DATEADD(DAY, -47, GETDATE())))),
(1974, 'TIX-MEGA-1388-1', 1388, N'Huỳnh Linh', 'mega_req_388@gmail.com', 'TIX-MEGA-1388-1|E1038|1114', 0, DATEADD(MINUTE, 41, DATEADD(HOUR, 13, DATEADD(DAY, -47, GETDATE())))),
(1975, 'TIX-MEGA-1388-2', 1388, N'Huỳnh Linh', 'mega_req_388@gmail.com', 'TIX-MEGA-1388-2|E1038|1114', 0, DATEADD(MINUTE, 41, DATEADD(HOUR, 13, DATEADD(DAY, -47, GETDATE())))),
(1976, 'TIX-MEGA-1388-3', 1388, N'Huỳnh Linh', 'mega_req_388@gmail.com', 'TIX-MEGA-1388-3|E1038|1114', 0, DATEADD(MINUTE, 41, DATEADD(HOUR, 13, DATEADD(DAY, -47, GETDATE())))),
(1977, 'TIX-MEGA-1389-0', 1389, N'Hoàng Bảo', 'mega_req_389@gmail.com', 'TIX-MEGA-1389-0|E1038|1116', 0, DATEADD(MINUTE, 29, DATEADD(HOUR, 8, DATEADD(DAY, -56, GETDATE())))),
(1978, 'TIX-MEGA-1389-1', 1389, N'Hoàng Bảo', 'mega_req_389@gmail.com', 'TIX-MEGA-1389-1|E1038|1116', 0, DATEADD(MINUTE, 29, DATEADD(HOUR, 8, DATEADD(DAY, -56, GETDATE())))),
(1979, 'TIX-MEGA-1390-0', 1390, N'Đỗ Vân', 'mega_req_390@gmail.com', 'TIX-MEGA-1390-0|E1060|1180', 1, DATEADD(MINUTE, 34, DATEADD(HOUR, 16, DATEADD(DAY, -3, GETDATE())))),
(1980, 'TIX-MEGA-1391-0', 1391, N'Nguyễn Hùng', 'mega_req_391@gmail.com', 'TIX-MEGA-1391-0|E1059|1179', 0, DATEADD(MINUTE, 35, DATEADD(HOUR, 3, DATEADD(DAY, -30, GETDATE())))),
(1981, 'TIX-MEGA-1392-0', 1392, N'Bùi Vân', 'mega_req_392@gmail.com', 'TIX-MEGA-1392-0|E1061|1185', 0, DATEADD(MINUTE, 59, DATEADD(HOUR, 21, DATEADD(DAY, -23, GETDATE())))),
(1982, 'TIX-MEGA-1393-0', 1393, N'Vũ Minh', 'mega_req_393@gmail.com', 'TIX-MEGA-1393-0|E1094|1284', 0, DATEADD(MINUTE, 44, DATEADD(HOUR, 8, DATEADD(DAY, -39, GETDATE())))),
(1983, 'TIX-MEGA-1393-1', 1393, N'Vũ Minh', 'mega_req_393@gmail.com', 'TIX-MEGA-1393-1|E1094|1284', 0, DATEADD(MINUTE, 44, DATEADD(HOUR, 8, DATEADD(DAY, -39, GETDATE())))),
(1984, 'TIX-MEGA-1393-2', 1393, N'Vũ Minh', 'mega_req_393@gmail.com', 'TIX-MEGA-1393-2|E1094|1284', 0, DATEADD(MINUTE, 44, DATEADD(HOUR, 8, DATEADD(DAY, -39, GETDATE())))),
(1985, 'TIX-MEGA-1393-3', 1393, N'Vũ Minh', 'mega_req_393@gmail.com', 'TIX-MEGA-1393-3|E1094|1284', 0, DATEADD(MINUTE, 44, DATEADD(HOUR, 8, DATEADD(DAY, -39, GETDATE())))),
(1986, 'TIX-MEGA-1394-0', 1394, N'Hoàng Hải', 'mega_req_394@gmail.com', 'TIX-MEGA-1394-0|E1079|1239', 0, DATEADD(MINUTE, 48, DATEADD(HOUR, 23, DATEADD(DAY, -51, GETDATE())))),
(1987, 'TIX-MEGA-1394-1', 1394, N'Hoàng Hải', 'mega_req_394@gmail.com', 'TIX-MEGA-1394-1|E1079|1239', 0, DATEADD(MINUTE, 48, DATEADD(HOUR, 23, DATEADD(DAY, -51, GETDATE())))),
(1988, 'TIX-MEGA-1394-2', 1394, N'Hoàng Hải', 'mega_req_394@gmail.com', 'TIX-MEGA-1394-2|E1079|1239', 1, DATEADD(MINUTE, 48, DATEADD(HOUR, 23, DATEADD(DAY, -51, GETDATE())))),
(1989, 'TIX-MEGA-1395-0', 1395, N'Lê Thành', 'mega_req_395@gmail.com', 'TIX-MEGA-1395-0|E1013|1039', 0, DATEADD(MINUTE, 24, DATEADD(HOUR, 6, DATEADD(DAY, -30, GETDATE())))),
(1990, 'TIX-MEGA-1395-1', 1395, N'Lê Thành', 'mega_req_395@gmail.com', 'TIX-MEGA-1395-1|E1013|1039', 0, DATEADD(MINUTE, 24, DATEADD(HOUR, 6, DATEADD(DAY, -30, GETDATE())))),
(1991, 'TIX-MEGA-1395-2', 1395, N'Lê Thành', 'mega_req_395@gmail.com', 'TIX-MEGA-1395-2|E1013|1039', 0, DATEADD(MINUTE, 24, DATEADD(HOUR, 6, DATEADD(DAY, -30, GETDATE())))),
(1992, 'TIX-MEGA-1395-3', 1395, N'Lê Thành', 'mega_req_395@gmail.com', 'TIX-MEGA-1395-3|E1013|1039', 0, DATEADD(MINUTE, 24, DATEADD(HOUR, 6, DATEADD(DAY, -30, GETDATE())))),
(1993, 'TIX-MEGA-1396-0', 1396, N'Nguyễn Thu', 'mega_req_396@gmail.com', 'TIX-MEGA-1396-0|E1010|1031', 1, DATEADD(MINUTE, 7, DATEADD(HOUR, 7, DATEADD(DAY, -11, GETDATE())))),
(1994, 'TIX-MEGA-1397-0', 1397, N'Phạm Khoa', 'mega_req_397@gmail.com', 'TIX-MEGA-1397-0|E1001|1003', 0, DATEADD(MINUTE, 53, DATEADD(HOUR, 9, DATEADD(DAY, -30, GETDATE())))),
(1995, 'TIX-MEGA-1398-0', 1398, N'Lê Thành', 'mega_req_398@gmail.com', 'TIX-MEGA-1398-0|E1079|1239', 0, DATEADD(MINUTE, 55, DATEADD(HOUR, 22, DATEADD(DAY, -10, GETDATE())))),
(1996, 'TIX-MEGA-1398-1', 1398, N'Lê Thành', 'mega_req_398@gmail.com', 'TIX-MEGA-1398-1|E1079|1239', 0, DATEADD(MINUTE, 55, DATEADD(HOUR, 22, DATEADD(DAY, -10, GETDATE())))),
(1997, 'TIX-MEGA-1398-2', 1398, N'Lê Thành', 'mega_req_398@gmail.com', 'TIX-MEGA-1398-2|E1079|1239', 1, DATEADD(MINUTE, 55, DATEADD(HOUR, 22, DATEADD(DAY, -10, GETDATE())))),
(1998, 'TIX-MEGA-1399-0', 1399, N'Phạm Lan', 'mega_req_399@gmail.com', 'TIX-MEGA-1399-0|E1032|1096', 0, DATEADD(MINUTE, 54, DATEADD(HOUR, 21, DATEADD(DAY, -34, GETDATE())))),
(1999, 'TIX-MEGA-1399-1', 1399, N'Phạm Lan', 'mega_req_399@gmail.com', 'TIX-MEGA-1399-1|E1032|1096', 0, DATEADD(MINUTE, 54, DATEADD(HOUR, 21, DATEADD(DAY, -34, GETDATE())))),
(2000, 'TIX-MEGA-1399-2', 1399, N'Phạm Lan', 'mega_req_399@gmail.com', 'TIX-MEGA-1399-2|E1032|1096', 0, DATEADD(MINUTE, 54, DATEADD(HOUR, 21, DATEADD(DAY, -34, GETDATE())))),
(2001, 'TIX-MEGA-1400-0', 1400, N'Lê Hùng', 'mega_req_400@gmail.com', 'TIX-MEGA-1400-0|E1087|1263', 0, DATEADD(MINUTE, 20, DATEADD(HOUR, 21, DATEADD(DAY, -50, GETDATE())))),
(2002, 'TIX-MEGA-1400-1', 1400, N'Lê Hùng', 'mega_req_400@gmail.com', 'TIX-MEGA-1400-1|E1087|1263', 0, DATEADD(MINUTE, 20, DATEADD(HOUR, 21, DATEADD(DAY, -50, GETDATE())))),
(2003, 'TIX-MEGA-1401-0', 1401, N'Phạm Minh', 'mega_req_401@gmail.com', 'TIX-MEGA-1401-0|E1078|1234', 0, DATEADD(MINUTE, 5, DATEADD(HOUR, 1, DATEADD(DAY, -43, GETDATE())))),
(2004, 'TIX-MEGA-1401-1', 1401, N'Phạm Minh', 'mega_req_401@gmail.com', 'TIX-MEGA-1401-1|E1078|1234', 0, DATEADD(MINUTE, 5, DATEADD(HOUR, 1, DATEADD(DAY, -43, GETDATE())))),
(2005, 'TIX-MEGA-1401-2', 1401, N'Phạm Minh', 'mega_req_401@gmail.com', 'TIX-MEGA-1401-2|E1078|1234', 1, DATEADD(MINUTE, 5, DATEADD(HOUR, 1, DATEADD(DAY, -43, GETDATE())))),
(2006, 'TIX-MEGA-1401-3', 1401, N'Phạm Minh', 'mega_req_401@gmail.com', 'TIX-MEGA-1401-3|E1078|1234', 0, DATEADD(MINUTE, 5, DATEADD(HOUR, 1, DATEADD(DAY, -43, GETDATE())))),
(2007, 'TIX-MEGA-1402-0', 1402, N'Đỗ Trang', 'mega_req_402@gmail.com', 'TIX-MEGA-1402-0|E1095|1286', 0, DATEADD(MINUTE, 34, DATEADD(HOUR, 7, DATEADD(DAY, -55, GETDATE())))),
(2008, 'TIX-MEGA-1403-0', 1403, N'Vũ Khoa', 'mega_req_403@gmail.com', 'TIX-MEGA-1403-0|E1064|1192', 1, DATEADD(MINUTE, 33, DATEADD(HOUR, 7, DATEADD(DAY, -31, GETDATE())))),
(2009, 'TIX-MEGA-1404-0', 1404, N'Huỳnh Thu', 'mega_req_404@gmail.com', 'TIX-MEGA-1404-0|E1043|1129', 0, DATEADD(MINUTE, 39, DATEADD(HOUR, 13, DATEADD(DAY, -8, GETDATE())))),
(2010, 'TIX-MEGA-1404-1', 1404, N'Huỳnh Thu', 'mega_req_404@gmail.com', 'TIX-MEGA-1404-1|E1043|1129', 0, DATEADD(MINUTE, 39, DATEADD(HOUR, 13, DATEADD(DAY, -8, GETDATE())))),
(2011, 'TIX-MEGA-1404-2', 1404, N'Huỳnh Thu', 'mega_req_404@gmail.com', 'TIX-MEGA-1404-2|E1043|1129', 0, DATEADD(MINUTE, 39, DATEADD(HOUR, 13, DATEADD(DAY, -8, GETDATE()))));
INSERT INTO Tickets (ticket_id, ticket_code, order_item_id, attendee_name, attendee_email, qr_code, is_checked_in, created_at) VALUES
(2012, 'TIX-MEGA-1405-0', 1405, N'Bùi Hùng', 'mega_req_405@gmail.com', 'TIX-MEGA-1405-0|E1006|1020', 0, DATEADD(MINUTE, 1, DATEADD(HOUR, 21, DATEADD(DAY, -56, GETDATE())))),
(2013, 'TIX-MEGA-1405-1', 1405, N'Bùi Hùng', 'mega_req_405@gmail.com', 'TIX-MEGA-1405-1|E1006|1020', 0, DATEADD(MINUTE, 1, DATEADD(HOUR, 21, DATEADD(DAY, -56, GETDATE())))),
(2014, 'TIX-MEGA-1405-2', 1405, N'Bùi Hùng', 'mega_req_405@gmail.com', 'TIX-MEGA-1405-2|E1006|1020', 1, DATEADD(MINUTE, 1, DATEADD(HOUR, 21, DATEADD(DAY, -56, GETDATE())))),
(2015, 'TIX-MEGA-1406-0', 1406, N'Nguyễn Vân', 'mega_req_406@gmail.com', 'TIX-MEGA-1406-0|E1020|1062', 0, DATEADD(MINUTE, 23, DATEADD(HOUR, 20, DATEADD(DAY, -31, GETDATE())))),
(2016, 'TIX-MEGA-1406-1', 1406, N'Nguyễn Vân', 'mega_req_406@gmail.com', 'TIX-MEGA-1406-1|E1020|1062', 0, DATEADD(MINUTE, 23, DATEADD(HOUR, 20, DATEADD(DAY, -31, GETDATE())))),
(2017, 'TIX-MEGA-1406-2', 1406, N'Nguyễn Vân', 'mega_req_406@gmail.com', 'TIX-MEGA-1406-2|E1020|1062', 0, DATEADD(MINUTE, 23, DATEADD(HOUR, 20, DATEADD(DAY, -31, GETDATE())))),
(2018, 'TIX-MEGA-1406-3', 1406, N'Nguyễn Vân', 'mega_req_406@gmail.com', 'TIX-MEGA-1406-3|E1020|1062', 0, DATEADD(MINUTE, 23, DATEADD(HOUR, 20, DATEADD(DAY, -31, GETDATE())))),
(2019, 'TIX-MEGA-1407-0', 1407, N'Nguyễn Hải', 'mega_req_407@gmail.com', 'TIX-MEGA-1407-0|E1079|1238', 1, DATEADD(MINUTE, 43, DATEADD(HOUR, 21, DATEADD(DAY, -11, GETDATE())))),
(2020, 'TIX-MEGA-1407-1', 1407, N'Nguyễn Hải', 'mega_req_407@gmail.com', 'TIX-MEGA-1407-1|E1079|1238', 0, DATEADD(MINUTE, 43, DATEADD(HOUR, 21, DATEADD(DAY, -11, GETDATE())))),
(2021, 'TIX-MEGA-1407-2', 1407, N'Nguyễn Hải', 'mega_req_407@gmail.com', 'TIX-MEGA-1407-2|E1079|1238', 0, DATEADD(MINUTE, 43, DATEADD(HOUR, 21, DATEADD(DAY, -11, GETDATE())))),
(2022, 'TIX-MEGA-1408-0', 1408, N'Đỗ Anh', 'mega_req_408@gmail.com', 'TIX-MEGA-1408-0|E1059|1179', 0, DATEADD(MINUTE, 3, DATEADD(HOUR, 20, DATEADD(DAY, -54, GETDATE())))),
(2023, 'TIX-MEGA-1409-0', 1409, N'Bùi Thành', 'mega_req_409@gmail.com', 'TIX-MEGA-1409-0|E1023|1071', 0, DATEADD(MINUTE, 41, DATEADD(HOUR, 0, DATEADD(DAY, -35, GETDATE())))),
(2024, 'TIX-MEGA-1409-1', 1409, N'Bùi Thành', 'mega_req_409@gmail.com', 'TIX-MEGA-1409-1|E1023|1071', 0, DATEADD(MINUTE, 41, DATEADD(HOUR, 0, DATEADD(DAY, -35, GETDATE())))),
(2025, 'TIX-MEGA-1409-2', 1409, N'Bùi Thành', 'mega_req_409@gmail.com', 'TIX-MEGA-1409-2|E1023|1071', 0, DATEADD(MINUTE, 41, DATEADD(HOUR, 0, DATEADD(DAY, -35, GETDATE())))),
(2026, 'TIX-MEGA-1409-3', 1409, N'Bùi Thành', 'mega_req_409@gmail.com', 'TIX-MEGA-1409-3|E1023|1071', 0, DATEADD(MINUTE, 41, DATEADD(HOUR, 0, DATEADD(DAY, -35, GETDATE())))),
(2027, 'TIX-MEGA-1410-0', 1410, N'Nguyễn Thành', 'mega_req_410@gmail.com', 'TIX-MEGA-1410-0|E1098|1296', 0, DATEADD(MINUTE, 5, DATEADD(HOUR, 23, DATEADD(DAY, -21, GETDATE())))),
(2028, 'TIX-MEGA-1411-0', 1411, N'Trần Thành', 'mega_req_411@gmail.com', 'TIX-MEGA-1411-0|E1080|1242', 0, DATEADD(MINUTE, 11, DATEADD(HOUR, 2, DATEADD(DAY, -5, GETDATE())))),
(2029, 'TIX-MEGA-1412-0', 1412, N'Vũ Phong', 'mega_req_412@gmail.com', 'TIX-MEGA-1412-0|E1038|1115', 0, DATEADD(MINUTE, 38, DATEADD(HOUR, 20, DATEADD(DAY, -8, GETDATE())))),
(2030, 'TIX-MEGA-1413-0', 1413, N'Trần Anh', 'mega_req_413@gmail.com', 'TIX-MEGA-1413-0|E1020|1061', 0, DATEADD(MINUTE, 30, DATEADD(HOUR, 19, DATEADD(DAY, -29, GETDATE())))),
(2031, 'TIX-MEGA-1413-1', 1413, N'Trần Anh', 'mega_req_413@gmail.com', 'TIX-MEGA-1413-1|E1020|1061', 0, DATEADD(MINUTE, 30, DATEADD(HOUR, 19, DATEADD(DAY, -29, GETDATE())))),
(2032, 'TIX-MEGA-1413-2', 1413, N'Trần Anh', 'mega_req_413@gmail.com', 'TIX-MEGA-1413-2|E1020|1061', 0, DATEADD(MINUTE, 30, DATEADD(HOUR, 19, DATEADD(DAY, -29, GETDATE())))),
(2033, 'TIX-MEGA-1414-0', 1414, N'Trần Minh', 'mega_req_414@gmail.com', 'TIX-MEGA-1414-0|E1027|1083', 0, DATEADD(MINUTE, 1, DATEADD(HOUR, 7, DATEADD(DAY, -50, GETDATE())))),
(2034, 'TIX-MEGA-1415-0', 1415, N'Hoàng Lan', 'mega_req_415@gmail.com', 'TIX-MEGA-1415-0|E1080|1241', 0, DATEADD(MINUTE, 56, DATEADD(HOUR, 10, DATEADD(DAY, -43, GETDATE())))),
(2035, 'TIX-MEGA-1416-0', 1416, N'Đặng Thành', 'mega_req_416@gmail.com', 'TIX-MEGA-1416-0|E1008|1024', 0, DATEADD(MINUTE, 47, DATEADD(HOUR, 20, DATEADD(DAY, -57, GETDATE())))),
(2036, 'TIX-MEGA-1416-1', 1416, N'Đặng Thành', 'mega_req_416@gmail.com', 'TIX-MEGA-1416-1|E1008|1024', 0, DATEADD(MINUTE, 47, DATEADD(HOUR, 20, DATEADD(DAY, -57, GETDATE())))),
(2037, 'TIX-MEGA-1416-2', 1416, N'Đặng Thành', 'mega_req_416@gmail.com', 'TIX-MEGA-1416-2|E1008|1024', 0, DATEADD(MINUTE, 47, DATEADD(HOUR, 20, DATEADD(DAY, -57, GETDATE())))),
(2038, 'TIX-MEGA-1416-3', 1416, N'Đặng Thành', 'mega_req_416@gmail.com', 'TIX-MEGA-1416-3|E1008|1024', 0, DATEADD(MINUTE, 47, DATEADD(HOUR, 20, DATEADD(DAY, -57, GETDATE())))),
(2039, 'TIX-MEGA-1417-0', 1417, N'Phạm Anh', 'mega_req_417@gmail.com', 'TIX-MEGA-1417-0|E1098|1295', 0, DATEADD(MINUTE, 10, DATEADD(HOUR, 0, DATEADD(DAY, -6, GETDATE())))),
(2040, 'TIX-MEGA-1417-1', 1417, N'Phạm Anh', 'mega_req_417@gmail.com', 'TIX-MEGA-1417-1|E1098|1295', 0, DATEADD(MINUTE, 10, DATEADD(HOUR, 0, DATEADD(DAY, -6, GETDATE())))),
(2041, 'TIX-MEGA-1417-2', 1417, N'Phạm Anh', 'mega_req_417@gmail.com', 'TIX-MEGA-1417-2|E1098|1295', 0, DATEADD(MINUTE, 10, DATEADD(HOUR, 0, DATEADD(DAY, -6, GETDATE())))),
(2042, 'TIX-MEGA-1418-0', 1418, N'Vũ Bảo', 'mega_req_418@gmail.com', 'TIX-MEGA-1418-0|E1074|1222', 0, DATEADD(MINUTE, 56, DATEADD(HOUR, 20, DATEADD(DAY, -12, GETDATE())))),
(2043, 'TIX-MEGA-1418-1', 1418, N'Vũ Bảo', 'mega_req_418@gmail.com', 'TIX-MEGA-1418-1|E1074|1222', 0, DATEADD(MINUTE, 56, DATEADD(HOUR, 20, DATEADD(DAY, -12, GETDATE())))),
(2044, 'TIX-MEGA-1419-0', 1419, N'Huỳnh Vân', 'mega_req_419@gmail.com', 'TIX-MEGA-1419-0|E1082|1247', 0, DATEADD(MINUTE, 49, DATEADD(HOUR, 14, DATEADD(DAY, -6, GETDATE())))),
(2045, 'TIX-MEGA-1419-1', 1419, N'Huỳnh Vân', 'mega_req_419@gmail.com', 'TIX-MEGA-1419-1|E1082|1247', 0, DATEADD(MINUTE, 49, DATEADD(HOUR, 14, DATEADD(DAY, -6, GETDATE())))),
(2046, 'TIX-MEGA-1420-0', 1420, N'Lê Hùng', 'mega_req_420@gmail.com', 'TIX-MEGA-1420-0|E1075|1227', 0, DATEADD(MINUTE, 57, DATEADD(HOUR, 14, DATEADD(DAY, -9, GETDATE())))),
(2047, 'TIX-MEGA-1420-1', 1420, N'Lê Hùng', 'mega_req_420@gmail.com', 'TIX-MEGA-1420-1|E1075|1227', 1, DATEADD(MINUTE, 57, DATEADD(HOUR, 14, DATEADD(DAY, -9, GETDATE())))),
(2048, 'TIX-MEGA-1420-2', 1420, N'Lê Hùng', 'mega_req_420@gmail.com', 'TIX-MEGA-1420-2|E1075|1227', 0, DATEADD(MINUTE, 57, DATEADD(HOUR, 14, DATEADD(DAY, -9, GETDATE())))),
(2049, 'TIX-MEGA-1421-0', 1421, N'Trần Thu', 'mega_req_421@gmail.com', 'TIX-MEGA-1421-0|E1058|1174', 0, DATEADD(MINUTE, 54, DATEADD(HOUR, 4, DATEADD(DAY, -39, GETDATE())))),
(2050, 'TIX-MEGA-1422-0', 1422, N'Lê Hùng', 'mega_req_422@gmail.com', 'TIX-MEGA-1422-0|E1088|1264', 0, DATEADD(MINUTE, 47, DATEADD(HOUR, 2, DATEADD(DAY, -27, GETDATE())))),
(2051, 'TIX-MEGA-1422-1', 1422, N'Lê Hùng', 'mega_req_422@gmail.com', 'TIX-MEGA-1422-1|E1088|1264', 0, DATEADD(MINUTE, 47, DATEADD(HOUR, 2, DATEADD(DAY, -27, GETDATE())))),
(2052, 'TIX-MEGA-1423-0', 1423, N'Đỗ Hùng', 'mega_req_423@gmail.com', 'TIX-MEGA-1423-0|E1052|1158', 0, DATEADD(MINUTE, 45, DATEADD(HOUR, 3, DATEADD(DAY, -38, GETDATE())))),
(2053, 'TIX-MEGA-1423-1', 1423, N'Đỗ Hùng', 'mega_req_423@gmail.com', 'TIX-MEGA-1423-1|E1052|1158', 0, DATEADD(MINUTE, 45, DATEADD(HOUR, 3, DATEADD(DAY, -38, GETDATE())))),
(2054, 'TIX-MEGA-1424-0', 1424, N'Nguyễn Khoa', 'mega_req_424@gmail.com', 'TIX-MEGA-1424-0|E1052|1157', 0, DATEADD(MINUTE, 56, DATEADD(HOUR, 4, DATEADD(DAY, -5, GETDATE())))),
(2055, 'TIX-MEGA-1424-1', 1424, N'Nguyễn Khoa', 'mega_req_424@gmail.com', 'TIX-MEGA-1424-1|E1052|1157', 1, DATEADD(MINUTE, 56, DATEADD(HOUR, 4, DATEADD(DAY, -5, GETDATE())))),
(2056, 'TIX-MEGA-1425-0', 1425, N'Nguyễn Phong', 'mega_req_425@gmail.com', 'TIX-MEGA-1425-0|E1030|1090', 0, DATEADD(MINUTE, 52, DATEADD(HOUR, 15, DATEADD(DAY, -4, GETDATE())))),
(2057, 'TIX-MEGA-1425-1', 1425, N'Nguyễn Phong', 'mega_req_425@gmail.com', 'TIX-MEGA-1425-1|E1030|1090', 0, DATEADD(MINUTE, 52, DATEADD(HOUR, 15, DATEADD(DAY, -4, GETDATE())))),
(2058, 'TIX-MEGA-1425-2', 1425, N'Nguyễn Phong', 'mega_req_425@gmail.com', 'TIX-MEGA-1425-2|E1030|1090', 0, DATEADD(MINUTE, 52, DATEADD(HOUR, 15, DATEADD(DAY, -4, GETDATE())))),
(2059, 'TIX-MEGA-1425-3', 1425, N'Nguyễn Phong', 'mega_req_425@gmail.com', 'TIX-MEGA-1425-3|E1030|1090', 0, DATEADD(MINUTE, 52, DATEADD(HOUR, 15, DATEADD(DAY, -4, GETDATE())))),
(2060, 'TIX-MEGA-1426-0', 1426, N'Vũ Trang', 'mega_req_426@gmail.com', 'TIX-MEGA-1426-0|E1063|1189', 0, DATEADD(MINUTE, 5, DATEADD(HOUR, 14, DATEADD(DAY, -36, GETDATE())))),
(2061, 'TIX-MEGA-1426-1', 1426, N'Vũ Trang', 'mega_req_426@gmail.com', 'TIX-MEGA-1426-1|E1063|1189', 0, DATEADD(MINUTE, 5, DATEADD(HOUR, 14, DATEADD(DAY, -36, GETDATE())))),
(2062, 'TIX-MEGA-1426-2', 1426, N'Vũ Trang', 'mega_req_426@gmail.com', 'TIX-MEGA-1426-2|E1063|1189', 1, DATEADD(MINUTE, 5, DATEADD(HOUR, 14, DATEADD(DAY, -36, GETDATE())))),
(2063, 'TIX-MEGA-1427-0', 1427, N'Đặng Hải', 'mega_req_427@gmail.com', 'TIX-MEGA-1427-0|E1093|1281', 0, DATEADD(MINUTE, 0, DATEADD(HOUR, 4, DATEADD(DAY, -8, GETDATE())))),
(2064, 'TIX-MEGA-1427-1', 1427, N'Đặng Hải', 'mega_req_427@gmail.com', 'TIX-MEGA-1427-1|E1093|1281', 0, DATEADD(MINUTE, 0, DATEADD(HOUR, 4, DATEADD(DAY, -8, GETDATE())))),
(2065, 'TIX-MEGA-1427-2', 1427, N'Đặng Hải', 'mega_req_427@gmail.com', 'TIX-MEGA-1427-2|E1093|1281', 0, DATEADD(MINUTE, 0, DATEADD(HOUR, 4, DATEADD(DAY, -8, GETDATE())))),
(2066, 'TIX-MEGA-1428-0', 1428, N'Đặng Hùng', 'mega_req_428@gmail.com', 'TIX-MEGA-1428-0|E1095|1287', 0, DATEADD(MINUTE, 15, DATEADD(HOUR, 6, DATEADD(DAY, -4, GETDATE())))),
(2067, 'TIX-MEGA-1428-1', 1428, N'Đặng Hùng', 'mega_req_428@gmail.com', 'TIX-MEGA-1428-1|E1095|1287', 0, DATEADD(MINUTE, 15, DATEADD(HOUR, 6, DATEADD(DAY, -4, GETDATE())))),
(2068, 'TIX-MEGA-1428-2', 1428, N'Đặng Hùng', 'mega_req_428@gmail.com', 'TIX-MEGA-1428-2|E1095|1287', 0, DATEADD(MINUTE, 15, DATEADD(HOUR, 6, DATEADD(DAY, -4, GETDATE())))),
(2069, 'TIX-MEGA-1428-3', 1428, N'Đặng Hùng', 'mega_req_428@gmail.com', 'TIX-MEGA-1428-3|E1095|1287', 0, DATEADD(MINUTE, 15, DATEADD(HOUR, 6, DATEADD(DAY, -4, GETDATE())))),
(2070, 'TIX-MEGA-1429-0', 1429, N'Nguyễn Kiên', 'mega_req_429@gmail.com', 'TIX-MEGA-1429-0|E1094|1284', 0, DATEADD(MINUTE, 0, DATEADD(HOUR, 18, DATEADD(DAY, -12, GETDATE())))),
(2071, 'TIX-MEGA-1429-1', 1429, N'Nguyễn Kiên', 'mega_req_429@gmail.com', 'TIX-MEGA-1429-1|E1094|1284', 0, DATEADD(MINUTE, 0, DATEADD(HOUR, 18, DATEADD(DAY, -12, GETDATE())))),
(2072, 'TIX-MEGA-1430-0', 1430, N'Đặng Trang', 'mega_req_430@gmail.com', 'TIX-MEGA-1430-0|E1009|1029', 0, DATEADD(MINUTE, 47, DATEADD(HOUR, 19, DATEADD(DAY, -14, GETDATE())))),
(2073, 'TIX-MEGA-1431-0', 1431, N'Vũ Lan', 'mega_req_431@gmail.com', 'TIX-MEGA-1431-0|E1038|1115', 1, DATEADD(MINUTE, 48, DATEADD(HOUR, 20, DATEADD(DAY, -16, GETDATE())))),
(2074, 'TIX-MEGA-1432-0', 1432, N'Nguyễn Hải', 'mega_req_432@gmail.com', 'TIX-MEGA-1432-0|E1061|1183', 0, DATEADD(MINUTE, 21, DATEADD(HOUR, 12, DATEADD(DAY, -4, GETDATE())))),
(2075, 'TIX-MEGA-1432-1', 1432, N'Nguyễn Hải', 'mega_req_432@gmail.com', 'TIX-MEGA-1432-1|E1061|1183', 0, DATEADD(MINUTE, 21, DATEADD(HOUR, 12, DATEADD(DAY, -4, GETDATE())))),
(2076, 'TIX-MEGA-1432-2', 1432, N'Nguyễn Hải', 'mega_req_432@gmail.com', 'TIX-MEGA-1432-2|E1061|1183', 0, DATEADD(MINUTE, 21, DATEADD(HOUR, 12, DATEADD(DAY, -4, GETDATE())))),
(2077, 'TIX-MEGA-1433-0', 1433, N'Bùi Anh', 'mega_req_433@gmail.com', 'TIX-MEGA-1433-0|E1084|1253', 0, DATEADD(MINUTE, 1, DATEADD(HOUR, 16, DATEADD(DAY, -22, GETDATE())))),
(2078, 'TIX-MEGA-1434-0', 1434, N'Phạm Tâm', 'mega_req_434@gmail.com', 'TIX-MEGA-1434-0|E1029|1088', 0, DATEADD(MINUTE, 19, DATEADD(HOUR, 7, DATEADD(DAY, -4, GETDATE())))),
(2079, 'TIX-MEGA-1434-1', 1434, N'Phạm Tâm', 'mega_req_434@gmail.com', 'TIX-MEGA-1434-1|E1029|1088', 0, DATEADD(MINUTE, 19, DATEADD(HOUR, 7, DATEADD(DAY, -4, GETDATE())))),
(2080, 'TIX-MEGA-1434-2', 1434, N'Phạm Tâm', 'mega_req_434@gmail.com', 'TIX-MEGA-1434-2|E1029|1088', 0, DATEADD(MINUTE, 19, DATEADD(HOUR, 7, DATEADD(DAY, -4, GETDATE())))),
(2081, 'TIX-MEGA-1435-0', 1435, N'Đặng Anh', 'mega_req_435@gmail.com', 'TIX-MEGA-1435-0|E1025|1077', 0, DATEADD(MINUTE, 38, DATEADD(HOUR, 0, DATEADD(DAY, -47, GETDATE())))),
(2082, 'TIX-MEGA-1435-1', 1435, N'Đặng Anh', 'mega_req_435@gmail.com', 'TIX-MEGA-1435-1|E1025|1077', 0, DATEADD(MINUTE, 38, DATEADD(HOUR, 0, DATEADD(DAY, -47, GETDATE())))),
(2083, 'TIX-MEGA-1435-2', 1435, N'Đặng Anh', 'mega_req_435@gmail.com', 'TIX-MEGA-1435-2|E1025|1077', 1, DATEADD(MINUTE, 38, DATEADD(HOUR, 0, DATEADD(DAY, -47, GETDATE())))),
(2084, 'TIX-MEGA-1435-3', 1435, N'Đặng Anh', 'mega_req_435@gmail.com', 'TIX-MEGA-1435-3|E1025|1077', 0, DATEADD(MINUTE, 38, DATEADD(HOUR, 0, DATEADD(DAY, -47, GETDATE())))),
(2085, 'TIX-MEGA-1436-0', 1436, N'Huỳnh Hùng', 'mega_req_436@gmail.com', 'TIX-MEGA-1436-0|E1085|1255', 0, DATEADD(MINUTE, 14, DATEADD(HOUR, 6, DATEADD(DAY, -28, GETDATE())))),
(2086, 'TIX-MEGA-1436-1', 1436, N'Huỳnh Hùng', 'mega_req_436@gmail.com', 'TIX-MEGA-1436-1|E1085|1255', 0, DATEADD(MINUTE, 14, DATEADD(HOUR, 6, DATEADD(DAY, -28, GETDATE())))),
(2087, 'TIX-MEGA-1436-2', 1436, N'Huỳnh Hùng', 'mega_req_436@gmail.com', 'TIX-MEGA-1436-2|E1085|1255', 0, DATEADD(MINUTE, 14, DATEADD(HOUR, 6, DATEADD(DAY, -28, GETDATE())))),
(2088, 'TIX-MEGA-1436-3', 1436, N'Huỳnh Hùng', 'mega_req_436@gmail.com', 'TIX-MEGA-1436-3|E1085|1255', 0, DATEADD(MINUTE, 14, DATEADD(HOUR, 6, DATEADD(DAY, -28, GETDATE())))),
(2089, 'TIX-MEGA-1437-0', 1437, N'Vũ Phong', 'mega_req_437@gmail.com', 'TIX-MEGA-1437-0|E1051|1154', 0, DATEADD(MINUTE, 28, DATEADD(HOUR, 17, DATEADD(DAY, -38, GETDATE())))),
(2090, 'TIX-MEGA-1437-1', 1437, N'Vũ Phong', 'mega_req_437@gmail.com', 'TIX-MEGA-1437-1|E1051|1154', 0, DATEADD(MINUTE, 28, DATEADD(HOUR, 17, DATEADD(DAY, -38, GETDATE())))),
(2091, 'TIX-MEGA-1437-2', 1437, N'Vũ Phong', 'mega_req_437@gmail.com', 'TIX-MEGA-1437-2|E1051|1154', 0, DATEADD(MINUTE, 28, DATEADD(HOUR, 17, DATEADD(DAY, -38, GETDATE())))),
(2092, 'TIX-MEGA-1437-3', 1437, N'Vũ Phong', 'mega_req_437@gmail.com', 'TIX-MEGA-1437-3|E1051|1154', 0, DATEADD(MINUTE, 28, DATEADD(HOUR, 17, DATEADD(DAY, -38, GETDATE())))),
(2093, 'TIX-MEGA-1438-0', 1438, N'Phạm Thành', 'mega_req_438@gmail.com', 'TIX-MEGA-1438-0|E1055|1166', 0, DATEADD(MINUTE, 0, DATEADD(HOUR, 1, DATEADD(DAY, -18, GETDATE())))),
(2094, 'TIX-MEGA-1438-1', 1438, N'Phạm Thành', 'mega_req_438@gmail.com', 'TIX-MEGA-1438-1|E1055|1166', 1, DATEADD(MINUTE, 0, DATEADD(HOUR, 1, DATEADD(DAY, -18, GETDATE())))),
(2095, 'TIX-MEGA-1438-2', 1438, N'Phạm Thành', 'mega_req_438@gmail.com', 'TIX-MEGA-1438-2|E1055|1166', 1, DATEADD(MINUTE, 0, DATEADD(HOUR, 1, DATEADD(DAY, -18, GETDATE())))),
(2096, 'TIX-MEGA-1439-0', 1439, N'Đỗ Linh', 'mega_req_439@gmail.com', 'TIX-MEGA-1439-0|E1099|1297', 0, DATEADD(MINUTE, 47, DATEADD(HOUR, 22, DATEADD(DAY, -38, GETDATE())))),
(2097, 'TIX-MEGA-1440-0', 1440, N'Đặng Anh', 'mega_req_440@gmail.com', 'TIX-MEGA-1440-0|E1054|1162', 0, DATEADD(MINUTE, 26, DATEADD(HOUR, 8, DATEADD(DAY, -16, GETDATE())))),
(2098, 'TIX-MEGA-1440-1', 1440, N'Đặng Anh', 'mega_req_440@gmail.com', 'TIX-MEGA-1440-1|E1054|1162', 0, DATEADD(MINUTE, 26, DATEADD(HOUR, 8, DATEADD(DAY, -16, GETDATE())))),
(2099, 'TIX-MEGA-1440-2', 1440, N'Đặng Anh', 'mega_req_440@gmail.com', 'TIX-MEGA-1440-2|E1054|1162', 0, DATEADD(MINUTE, 26, DATEADD(HOUR, 8, DATEADD(DAY, -16, GETDATE())))),
(2100, 'TIX-MEGA-1441-0', 1441, N'Đỗ Phong', 'mega_req_441@gmail.com', 'TIX-MEGA-1441-0|E1065|1195', 0, DATEADD(MINUTE, 57, DATEADD(HOUR, 16, DATEADD(DAY, -7, GETDATE())))),
(2101, 'TIX-MEGA-1442-0', 1442, N'Phạm Hải', 'mega_req_442@gmail.com', 'TIX-MEGA-1442-0|E1004|1013', 0, DATEADD(MINUTE, 21, DATEADD(HOUR, 21, DATEADD(DAY, -52, GETDATE())))),
(2102, 'TIX-MEGA-1443-0', 1443, N'Phạm Tâm', 'mega_req_443@gmail.com', 'TIX-MEGA-1443-0|E1007|1022', 0, DATEADD(MINUTE, 30, DATEADD(HOUR, 11, DATEADD(DAY, -45, GETDATE())))),
(2103, 'TIX-MEGA-1444-0', 1444, N'Lê Anh', 'mega_req_444@gmail.com', 'TIX-MEGA-1444-0|E1003|1011', 0, DATEADD(MINUTE, 51, DATEADD(HOUR, 8, DATEADD(DAY, -7, GETDATE())))),
(2104, 'TIX-MEGA-1444-1', 1444, N'Lê Anh', 'mega_req_444@gmail.com', 'TIX-MEGA-1444-1|E1003|1011', 0, DATEADD(MINUTE, 51, DATEADD(HOUR, 8, DATEADD(DAY, -7, GETDATE())))),
(2105, 'TIX-MEGA-1444-2', 1444, N'Lê Anh', 'mega_req_444@gmail.com', 'TIX-MEGA-1444-2|E1003|1011', 0, DATEADD(MINUTE, 51, DATEADD(HOUR, 8, DATEADD(DAY, -7, GETDATE())))),
(2106, 'TIX-MEGA-1445-0', 1445, N'Đỗ Phong', 'mega_req_445@gmail.com', 'TIX-MEGA-1445-0|E1081|1243', 0, DATEADD(MINUTE, 22, DATEADD(HOUR, 22, DATEADD(DAY, -46, GETDATE())))),
(2107, 'TIX-MEGA-1446-0', 1446, N'Nguyễn Vân', 'mega_req_446@gmail.com', 'TIX-MEGA-1446-0|E1003|1009', 0, DATEADD(MINUTE, 37, DATEADD(HOUR, 10, DATEADD(DAY, -35, GETDATE())))),
(2108, 'TIX-MEGA-1446-1', 1446, N'Nguyễn Vân', 'mega_req_446@gmail.com', 'TIX-MEGA-1446-1|E1003|1009', 0, DATEADD(MINUTE, 37, DATEADD(HOUR, 10, DATEADD(DAY, -35, GETDATE())))),
(2109, 'TIX-MEGA-1446-2', 1446, N'Nguyễn Vân', 'mega_req_446@gmail.com', 'TIX-MEGA-1446-2|E1003|1009', 0, DATEADD(MINUTE, 37, DATEADD(HOUR, 10, DATEADD(DAY, -35, GETDATE())))),
(2110, 'TIX-MEGA-1446-3', 1446, N'Nguyễn Vân', 'mega_req_446@gmail.com', 'TIX-MEGA-1446-3|E1003|1009', 0, DATEADD(MINUTE, 37, DATEADD(HOUR, 10, DATEADD(DAY, -35, GETDATE())))),
(2111, 'TIX-MEGA-1447-0', 1447, N'Vũ Tâm', 'mega_req_447@gmail.com', 'TIX-MEGA-1447-0|E1023|1070', 0, DATEADD(MINUTE, 22, DATEADD(HOUR, 21, DATEADD(DAY, -48, GETDATE()))));
INSERT INTO Tickets (ticket_id, ticket_code, order_item_id, attendee_name, attendee_email, qr_code, is_checked_in, created_at) VALUES
(2112, 'TIX-MEGA-1448-0', 1448, N'Phạm Linh', 'mega_req_448@gmail.com', 'TIX-MEGA-1448-0|E1029|1088', 0, DATEADD(MINUTE, 29, DATEADD(HOUR, 1, DATEADD(DAY, -54, GETDATE())))),
(2113, 'TIX-MEGA-1448-1', 1448, N'Phạm Linh', 'mega_req_448@gmail.com', 'TIX-MEGA-1448-1|E1029|1088', 1, DATEADD(MINUTE, 29, DATEADD(HOUR, 1, DATEADD(DAY, -54, GETDATE())))),
(2114, 'TIX-MEGA-1448-2', 1448, N'Phạm Linh', 'mega_req_448@gmail.com', 'TIX-MEGA-1448-2|E1029|1088', 0, DATEADD(MINUTE, 29, DATEADD(HOUR, 1, DATEADD(DAY, -54, GETDATE())))),
(2115, 'TIX-MEGA-1449-0', 1449, N'Đỗ Phong', 'mega_req_449@gmail.com', 'TIX-MEGA-1449-0|E1007|1023', 0, DATEADD(MINUTE, 9, DATEADD(HOUR, 9, DATEADD(DAY, -50, GETDATE())))),
(2116, 'TIX-MEGA-1449-1', 1449, N'Đỗ Phong', 'mega_req_449@gmail.com', 'TIX-MEGA-1449-1|E1007|1023', 0, DATEADD(MINUTE, 9, DATEADD(HOUR, 9, DATEADD(DAY, -50, GETDATE())))),
(2117, 'TIX-MEGA-1449-2', 1449, N'Đỗ Phong', 'mega_req_449@gmail.com', 'TIX-MEGA-1449-2|E1007|1023', 0, DATEADD(MINUTE, 9, DATEADD(HOUR, 9, DATEADD(DAY, -50, GETDATE())))),
(2118, 'TIX-MEGA-1449-3', 1449, N'Đỗ Phong', 'mega_req_449@gmail.com', 'TIX-MEGA-1449-3|E1007|1023', 0, DATEADD(MINUTE, 9, DATEADD(HOUR, 9, DATEADD(DAY, -50, GETDATE())))),
(2119, 'TIX-MEGA-1450-0', 1450, N'Hoàng Vân', 'mega_req_450@gmail.com', 'TIX-MEGA-1450-0|E1009|1028', 0, DATEADD(MINUTE, 41, DATEADD(HOUR, 16, DATEADD(DAY, -19, GETDATE())))),
(2120, 'TIX-MEGA-1450-1', 1450, N'Hoàng Vân', 'mega_req_450@gmail.com', 'TIX-MEGA-1450-1|E1009|1028', 0, DATEADD(MINUTE, 41, DATEADD(HOUR, 16, DATEADD(DAY, -19, GETDATE())))),
(2121, 'TIX-MEGA-1451-0', 1451, N'Nguyễn Kiên', 'mega_req_451@gmail.com', 'TIX-MEGA-1451-0|E1042|1126', 0, DATEADD(MINUTE, 35, DATEADD(HOUR, 14, DATEADD(DAY, -57, GETDATE())))),
(2122, 'TIX-MEGA-1451-1', 1451, N'Nguyễn Kiên', 'mega_req_451@gmail.com', 'TIX-MEGA-1451-1|E1042|1126', 0, DATEADD(MINUTE, 35, DATEADD(HOUR, 14, DATEADD(DAY, -57, GETDATE())))),
(2123, 'TIX-MEGA-1451-2', 1451, N'Nguyễn Kiên', 'mega_req_451@gmail.com', 'TIX-MEGA-1451-2|E1042|1126', 0, DATEADD(MINUTE, 35, DATEADD(HOUR, 14, DATEADD(DAY, -57, GETDATE())))),
(2124, 'TIX-MEGA-1451-3', 1451, N'Nguyễn Kiên', 'mega_req_451@gmail.com', 'TIX-MEGA-1451-3|E1042|1126', 0, DATEADD(MINUTE, 35, DATEADD(HOUR, 14, DATEADD(DAY, -57, GETDATE())))),
(2125, 'TIX-MEGA-1452-0', 1452, N'Bùi Thành', 'mega_req_452@gmail.com', 'TIX-MEGA-1452-0|E1076|1229', 0, DATEADD(MINUTE, 41, DATEADD(HOUR, 10, DATEADD(DAY, -43, GETDATE())))),
(2126, 'TIX-MEGA-1452-1', 1452, N'Bùi Thành', 'mega_req_452@gmail.com', 'TIX-MEGA-1452-1|E1076|1229', 0, DATEADD(MINUTE, 41, DATEADD(HOUR, 10, DATEADD(DAY, -43, GETDATE())))),
(2127, 'TIX-MEGA-1452-2', 1452, N'Bùi Thành', 'mega_req_452@gmail.com', 'TIX-MEGA-1452-2|E1076|1229', 0, DATEADD(MINUTE, 41, DATEADD(HOUR, 10, DATEADD(DAY, -43, GETDATE())))),
(2128, 'TIX-MEGA-1452-3', 1452, N'Bùi Thành', 'mega_req_452@gmail.com', 'TIX-MEGA-1452-3|E1076|1229', 0, DATEADD(MINUTE, 41, DATEADD(HOUR, 10, DATEADD(DAY, -43, GETDATE())))),
(2129, 'TIX-MEGA-1453-0', 1453, N'Lê Linh', 'mega_req_453@gmail.com', 'TIX-MEGA-1453-0|E1060|1182', 0, DATEADD(MINUTE, 3, DATEADD(HOUR, 5, DATEADD(DAY, -11, GETDATE())))),
(2130, 'TIX-MEGA-1454-0', 1454, N'Vũ Phong', 'mega_req_454@gmail.com', 'TIX-MEGA-1454-0|E1058|1176', 0, DATEADD(MINUTE, 46, DATEADD(HOUR, 14, DATEADD(DAY, -10, GETDATE())))),
(2131, 'TIX-MEGA-1455-0', 1455, N'Vũ Khoa', 'mega_req_455@gmail.com', 'TIX-MEGA-1455-0|E1020|1061', 0, DATEADD(MINUTE, 16, DATEADD(HOUR, 6, DATEADD(DAY, -42, GETDATE())))),
(2132, 'TIX-MEGA-1455-1', 1455, N'Vũ Khoa', 'mega_req_455@gmail.com', 'TIX-MEGA-1455-1|E1020|1061', 0, DATEADD(MINUTE, 16, DATEADD(HOUR, 6, DATEADD(DAY, -42, GETDATE())))),
(2133, 'TIX-MEGA-1455-2', 1455, N'Vũ Khoa', 'mega_req_455@gmail.com', 'TIX-MEGA-1455-2|E1020|1061', 0, DATEADD(MINUTE, 16, DATEADD(HOUR, 6, DATEADD(DAY, -42, GETDATE())))),
(2134, 'TIX-MEGA-1456-0', 1456, N'Trần Tâm', 'mega_req_456@gmail.com', 'TIX-MEGA-1456-0|E1038|1114', 0, DATEADD(MINUTE, 57, DATEADD(HOUR, 13, DATEADD(DAY, -56, GETDATE())))),
(2135, 'TIX-MEGA-1456-1', 1456, N'Trần Tâm', 'mega_req_456@gmail.com', 'TIX-MEGA-1456-1|E1038|1114', 0, DATEADD(MINUTE, 57, DATEADD(HOUR, 13, DATEADD(DAY, -56, GETDATE())))),
(2136, 'TIX-MEGA-1457-0', 1457, N'Hoàng Minh', 'mega_req_457@gmail.com', 'TIX-MEGA-1457-0|E1062|1187', 0, DATEADD(MINUTE, 16, DATEADD(HOUR, 11, DATEADD(DAY, -37, GETDATE())))),
(2137, 'TIX-MEGA-1457-1', 1457, N'Hoàng Minh', 'mega_req_457@gmail.com', 'TIX-MEGA-1457-1|E1062|1187', 0, DATEADD(MINUTE, 16, DATEADD(HOUR, 11, DATEADD(DAY, -37, GETDATE())))),
(2138, 'TIX-MEGA-1457-2', 1457, N'Hoàng Minh', 'mega_req_457@gmail.com', 'TIX-MEGA-1457-2|E1062|1187', 0, DATEADD(MINUTE, 16, DATEADD(HOUR, 11, DATEADD(DAY, -37, GETDATE())))),
(2139, 'TIX-MEGA-1457-3', 1457, N'Hoàng Minh', 'mega_req_457@gmail.com', 'TIX-MEGA-1457-3|E1062|1187', 1, DATEADD(MINUTE, 16, DATEADD(HOUR, 11, DATEADD(DAY, -37, GETDATE())))),
(2140, 'TIX-MEGA-1458-0', 1458, N'Bùi Anh', 'mega_req_458@gmail.com', 'TIX-MEGA-1458-0|E1058|1174', 0, DATEADD(MINUTE, 23, DATEADD(HOUR, 8, DATEADD(DAY, -59, GETDATE())))),
(2141, 'TIX-MEGA-1459-0', 1459, N'Hoàng Khoa', 'mega_req_459@gmail.com', 'TIX-MEGA-1459-0|E1019|1059', 0, DATEADD(MINUTE, 39, DATEADD(HOUR, 4, DATEADD(DAY, -1, GETDATE())))),
(2142, 'TIX-MEGA-1459-1', 1459, N'Hoàng Khoa', 'mega_req_459@gmail.com', 'TIX-MEGA-1459-1|E1019|1059', 0, DATEADD(MINUTE, 39, DATEADD(HOUR, 4, DATEADD(DAY, -1, GETDATE())))),
(2143, 'TIX-MEGA-1459-2', 1459, N'Hoàng Khoa', 'mega_req_459@gmail.com', 'TIX-MEGA-1459-2|E1019|1059', 0, DATEADD(MINUTE, 39, DATEADD(HOUR, 4, DATEADD(DAY, -1, GETDATE())))),
(2144, 'TIX-MEGA-1460-0', 1460, N'Huỳnh Bảo', 'mega_req_460@gmail.com', 'TIX-MEGA-1460-0|E1088|1264', 0, DATEADD(MINUTE, 20, DATEADD(HOUR, 6, DATEADD(DAY, -12, GETDATE())))),
(2145, 'TIX-MEGA-1460-1', 1460, N'Huỳnh Bảo', 'mega_req_460@gmail.com', 'TIX-MEGA-1460-1|E1088|1264', 0, DATEADD(MINUTE, 20, DATEADD(HOUR, 6, DATEADD(DAY, -12, GETDATE())))),
(2146, 'TIX-MEGA-1461-0', 1461, N'Bùi Tâm', 'mega_req_461@gmail.com', 'TIX-MEGA-1461-0|E1007|1022', 0, DATEADD(MINUTE, 45, DATEADD(HOUR, 13, DATEADD(DAY, 0, GETDATE())))),
(2147, 'TIX-MEGA-1462-0', 1462, N'Lê Minh', 'mega_req_462@gmail.com', 'TIX-MEGA-1462-0|E1046|1139', 0, DATEADD(MINUTE, 18, DATEADD(HOUR, 15, DATEADD(DAY, -60, GETDATE())))),
(2148, 'TIX-MEGA-1462-1', 1462, N'Lê Minh', 'mega_req_462@gmail.com', 'TIX-MEGA-1462-1|E1046|1139', 0, DATEADD(MINUTE, 18, DATEADD(HOUR, 15, DATEADD(DAY, -60, GETDATE())))),
(2149, 'TIX-MEGA-1462-2', 1462, N'Lê Minh', 'mega_req_462@gmail.com', 'TIX-MEGA-1462-2|E1046|1139', 0, DATEADD(MINUTE, 18, DATEADD(HOUR, 15, DATEADD(DAY, -60, GETDATE())))),
(2150, 'TIX-MEGA-1462-3', 1462, N'Lê Minh', 'mega_req_462@gmail.com', 'TIX-MEGA-1462-3|E1046|1139', 0, DATEADD(MINUTE, 18, DATEADD(HOUR, 15, DATEADD(DAY, -60, GETDATE())))),
(2151, 'TIX-MEGA-1463-0', 1463, N'Vũ Khoa', 'mega_req_463@gmail.com', 'TIX-MEGA-1463-0|E1094|1284', 0, DATEADD(MINUTE, 32, DATEADD(HOUR, 7, DATEADD(DAY, -57, GETDATE())))),
(2152, 'TIX-MEGA-1464-0', 1464, N'Huỳnh Thu', 'mega_req_464@gmail.com', 'TIX-MEGA-1464-0|E1096|1288', 0, DATEADD(MINUTE, 33, DATEADD(HOUR, 9, DATEADD(DAY, -45, GETDATE())))),
(2153, 'TIX-MEGA-1464-1', 1464, N'Huỳnh Thu', 'mega_req_464@gmail.com', 'TIX-MEGA-1464-1|E1096|1288', 0, DATEADD(MINUTE, 33, DATEADD(HOUR, 9, DATEADD(DAY, -45, GETDATE())))),
(2154, 'TIX-MEGA-1464-2', 1464, N'Huỳnh Thu', 'mega_req_464@gmail.com', 'TIX-MEGA-1464-2|E1096|1288', 0, DATEADD(MINUTE, 33, DATEADD(HOUR, 9, DATEADD(DAY, -45, GETDATE())))),
(2155, 'TIX-MEGA-1464-3', 1464, N'Huỳnh Thu', 'mega_req_464@gmail.com', 'TIX-MEGA-1464-3|E1096|1288', 0, DATEADD(MINUTE, 33, DATEADD(HOUR, 9, DATEADD(DAY, -45, GETDATE())))),
(2156, 'TIX-MEGA-1465-0', 1465, N'Trần Hải', 'mega_req_465@gmail.com', 'TIX-MEGA-1465-0|E1029|1087', 1, DATEADD(MINUTE, 18, DATEADD(HOUR, 20, DATEADD(DAY, -33, GETDATE())))),
(2157, 'TIX-MEGA-1465-1', 1465, N'Trần Hải', 'mega_req_465@gmail.com', 'TIX-MEGA-1465-1|E1029|1087', 0, DATEADD(MINUTE, 18, DATEADD(HOUR, 20, DATEADD(DAY, -33, GETDATE())))),
(2158, 'TIX-MEGA-1466-0', 1466, N'Vũ Hùng', 'mega_req_466@gmail.com', 'TIX-MEGA-1466-0|E1093|1281', 0, DATEADD(MINUTE, 1, DATEADD(HOUR, 16, DATEADD(DAY, -54, GETDATE())))),
(2159, 'TIX-MEGA-1467-0', 1467, N'Phạm Thu', 'mega_req_467@gmail.com', 'TIX-MEGA-1467-0|E1029|1087', 1, DATEADD(MINUTE, 59, DATEADD(HOUR, 0, DATEADD(DAY, -5, GETDATE())))),
(2160, 'TIX-MEGA-1468-0', 1468, N'Trần Thành', 'mega_req_468@gmail.com', 'TIX-MEGA-1468-0|E1018|1056', 0, DATEADD(MINUTE, 42, DATEADD(HOUR, 2, DATEADD(DAY, -43, GETDATE())))),
(2161, 'TIX-MEGA-1468-1', 1468, N'Trần Thành', 'mega_req_468@gmail.com', 'TIX-MEGA-1468-1|E1018|1056', 0, DATEADD(MINUTE, 42, DATEADD(HOUR, 2, DATEADD(DAY, -43, GETDATE())))),
(2162, 'TIX-MEGA-1468-2', 1468, N'Trần Thành', 'mega_req_468@gmail.com', 'TIX-MEGA-1468-2|E1018|1056', 0, DATEADD(MINUTE, 42, DATEADD(HOUR, 2, DATEADD(DAY, -43, GETDATE())))),
(2163, 'TIX-MEGA-1468-3', 1468, N'Trần Thành', 'mega_req_468@gmail.com', 'TIX-MEGA-1468-3|E1018|1056', 0, DATEADD(MINUTE, 42, DATEADD(HOUR, 2, DATEADD(DAY, -43, GETDATE())))),
(2164, 'TIX-MEGA-1469-0', 1469, N'Huỳnh Kiên', 'mega_req_469@gmail.com', 'TIX-MEGA-1469-0|E1042|1126', 0, DATEADD(MINUTE, 43, DATEADD(HOUR, 21, DATEADD(DAY, -60, GETDATE())))),
(2165, 'TIX-MEGA-1469-1', 1469, N'Huỳnh Kiên', 'mega_req_469@gmail.com', 'TIX-MEGA-1469-1|E1042|1126', 0, DATEADD(MINUTE, 43, DATEADD(HOUR, 21, DATEADD(DAY, -60, GETDATE())))),
(2166, 'TIX-MEGA-1470-0', 1470, N'Lê Thu', 'mega_req_470@gmail.com', 'TIX-MEGA-1470-0|E1093|1279', 0, DATEADD(MINUTE, 26, DATEADD(HOUR, 2, DATEADD(DAY, -28, GETDATE())))),
(2167, 'TIX-MEGA-1470-1', 1470, N'Lê Thu', 'mega_req_470@gmail.com', 'TIX-MEGA-1470-1|E1093|1279', 0, DATEADD(MINUTE, 26, DATEADD(HOUR, 2, DATEADD(DAY, -28, GETDATE())))),
(2168, 'TIX-MEGA-1470-2', 1470, N'Lê Thu', 'mega_req_470@gmail.com', 'TIX-MEGA-1470-2|E1093|1279', 0, DATEADD(MINUTE, 26, DATEADD(HOUR, 2, DATEADD(DAY, -28, GETDATE())))),
(2169, 'TIX-MEGA-1471-0', 1471, N'Nguyễn Khoa', 'mega_req_471@gmail.com', 'TIX-MEGA-1471-0|E1010|1032', 0, DATEADD(MINUTE, 52, DATEADD(HOUR, 10, DATEADD(DAY, -8, GETDATE())))),
(2170, 'TIX-MEGA-1471-1', 1471, N'Nguyễn Khoa', 'mega_req_471@gmail.com', 'TIX-MEGA-1471-1|E1010|1032', 0, DATEADD(MINUTE, 52, DATEADD(HOUR, 10, DATEADD(DAY, -8, GETDATE())))),
(2171, 'TIX-MEGA-1472-0', 1472, N'Lê Linh', 'mega_req_472@gmail.com', 'TIX-MEGA-1472-0|E1074|1222', 0, DATEADD(MINUTE, 29, DATEADD(HOUR, 18, DATEADD(DAY, -8, GETDATE())))),
(2172, 'TIX-MEGA-1473-0', 1473, N'Nguyễn Trang', 'mega_req_473@gmail.com', 'TIX-MEGA-1473-0|E1074|1222', 0, DATEADD(MINUTE, 33, DATEADD(HOUR, 4, DATEADD(DAY, -38, GETDATE())))),
(2173, 'TIX-MEGA-1473-1', 1473, N'Nguyễn Trang', 'mega_req_473@gmail.com', 'TIX-MEGA-1473-1|E1074|1222', 0, DATEADD(MINUTE, 33, DATEADD(HOUR, 4, DATEADD(DAY, -38, GETDATE())))),
(2174, 'TIX-MEGA-1474-0', 1474, N'Hoàng Minh', 'mega_req_474@gmail.com', 'TIX-MEGA-1474-0|E1082|1247', 0, DATEADD(MINUTE, 19, DATEADD(HOUR, 21, DATEADD(DAY, -29, GETDATE())))),
(2175, 'TIX-MEGA-1475-0', 1475, N'Hoàng Hùng', 'mega_req_475@gmail.com', 'TIX-MEGA-1475-0|E1016|1050', 0, DATEADD(MINUTE, 37, DATEADD(HOUR, 14, DATEADD(DAY, -10, GETDATE())))),
(2176, 'TIX-MEGA-1475-1', 1475, N'Hoàng Hùng', 'mega_req_475@gmail.com', 'TIX-MEGA-1475-1|E1016|1050', 0, DATEADD(MINUTE, 37, DATEADD(HOUR, 14, DATEADD(DAY, -10, GETDATE())))),
(2177, 'TIX-MEGA-1475-2', 1475, N'Hoàng Hùng', 'mega_req_475@gmail.com', 'TIX-MEGA-1475-2|E1016|1050', 0, DATEADD(MINUTE, 37, DATEADD(HOUR, 14, DATEADD(DAY, -10, GETDATE())))),
(2178, 'TIX-MEGA-1475-3', 1475, N'Hoàng Hùng', 'mega_req_475@gmail.com', 'TIX-MEGA-1475-3|E1016|1050', 0, DATEADD(MINUTE, 37, DATEADD(HOUR, 14, DATEADD(DAY, -10, GETDATE())))),
(2179, 'TIX-MEGA-1476-0', 1476, N'Vũ Hùng', 'mega_req_476@gmail.com', 'TIX-MEGA-1476-0|E1028|1086', 1, DATEADD(MINUTE, 58, DATEADD(HOUR, 5, DATEADD(DAY, -46, GETDATE())))),
(2180, 'TIX-MEGA-1476-1', 1476, N'Vũ Hùng', 'mega_req_476@gmail.com', 'TIX-MEGA-1476-1|E1028|1086', 1, DATEADD(MINUTE, 58, DATEADD(HOUR, 5, DATEADD(DAY, -46, GETDATE())))),
(2181, 'TIX-MEGA-1477-0', 1477, N'Lê Bảo', 'mega_req_477@gmail.com', 'TIX-MEGA-1477-0|E1061|1184', 0, DATEADD(MINUTE, 26, DATEADD(HOUR, 13, DATEADD(DAY, -3, GETDATE())))),
(2182, 'TIX-MEGA-1478-0', 1478, N'Trần Trang', 'mega_req_478@gmail.com', 'TIX-MEGA-1478-0|E1002|1007', 0, DATEADD(MINUTE, 20, DATEADD(HOUR, 21, DATEADD(DAY, -14, GETDATE())))),
(2183, 'TIX-MEGA-1478-1', 1478, N'Trần Trang', 'mega_req_478@gmail.com', 'TIX-MEGA-1478-1|E1002|1007', 0, DATEADD(MINUTE, 20, DATEADD(HOUR, 21, DATEADD(DAY, -14, GETDATE())))),
(2184, 'TIX-MEGA-1478-2', 1478, N'Trần Trang', 'mega_req_478@gmail.com', 'TIX-MEGA-1478-2|E1002|1007', 0, DATEADD(MINUTE, 20, DATEADD(HOUR, 21, DATEADD(DAY, -14, GETDATE())))),
(2185, 'TIX-MEGA-1478-3', 1478, N'Trần Trang', 'mega_req_478@gmail.com', 'TIX-MEGA-1478-3|E1002|1007', 0, DATEADD(MINUTE, 20, DATEADD(HOUR, 21, DATEADD(DAY, -14, GETDATE())))),
(2186, 'TIX-MEGA-1479-0', 1479, N'Phạm Thành', 'mega_req_479@gmail.com', 'TIX-MEGA-1479-0|E1097|1291', 1, DATEADD(MINUTE, 20, DATEADD(HOUR, 23, DATEADD(DAY, -56, GETDATE())))),
(2187, 'TIX-MEGA-1479-1', 1479, N'Phạm Thành', 'mega_req_479@gmail.com', 'TIX-MEGA-1479-1|E1097|1291', 1, DATEADD(MINUTE, 20, DATEADD(HOUR, 23, DATEADD(DAY, -56, GETDATE())))),
(2188, 'TIX-MEGA-1479-2', 1479, N'Phạm Thành', 'mega_req_479@gmail.com', 'TIX-MEGA-1479-2|E1097|1291', 0, DATEADD(MINUTE, 20, DATEADD(HOUR, 23, DATEADD(DAY, -56, GETDATE())))),
(2189, 'TIX-MEGA-1479-3', 1479, N'Phạm Thành', 'mega_req_479@gmail.com', 'TIX-MEGA-1479-3|E1097|1291', 0, DATEADD(MINUTE, 20, DATEADD(HOUR, 23, DATEADD(DAY, -56, GETDATE())))),
(2190, 'TIX-MEGA-1480-0', 1480, N'Hoàng Hải', 'mega_req_480@gmail.com', 'TIX-MEGA-1480-0|E1086|1259', 0, DATEADD(MINUTE, 15, DATEADD(HOUR, 6, DATEADD(DAY, -32, GETDATE())))),
(2191, 'TIX-MEGA-1480-1', 1480, N'Hoàng Hải', 'mega_req_480@gmail.com', 'TIX-MEGA-1480-1|E1086|1259', 0, DATEADD(MINUTE, 15, DATEADD(HOUR, 6, DATEADD(DAY, -32, GETDATE())))),
(2192, 'TIX-MEGA-1480-2', 1480, N'Hoàng Hải', 'mega_req_480@gmail.com', 'TIX-MEGA-1480-2|E1086|1259', 0, DATEADD(MINUTE, 15, DATEADD(HOUR, 6, DATEADD(DAY, -32, GETDATE())))),
(2193, 'TIX-MEGA-1480-3', 1480, N'Hoàng Hải', 'mega_req_480@gmail.com', 'TIX-MEGA-1480-3|E1086|1259', 0, DATEADD(MINUTE, 15, DATEADD(HOUR, 6, DATEADD(DAY, -32, GETDATE())))),
(2194, 'TIX-MEGA-1481-0', 1481, N'Vũ Tâm', 'mega_req_481@gmail.com', 'TIX-MEGA-1481-0|E1051|1154', 0, DATEADD(MINUTE, 18, DATEADD(HOUR, 4, DATEADD(DAY, -45, GETDATE())))),
(2195, 'TIX-MEGA-1481-1', 1481, N'Vũ Tâm', 'mega_req_481@gmail.com', 'TIX-MEGA-1481-1|E1051|1154', 0, DATEADD(MINUTE, 18, DATEADD(HOUR, 4, DATEADD(DAY, -45, GETDATE())))),
(2196, 'TIX-MEGA-1482-0', 1482, N'Bùi Anh', 'mega_req_482@gmail.com', 'TIX-MEGA-1482-0|E1098|1295', 0, DATEADD(MINUTE, 57, DATEADD(HOUR, 17, DATEADD(DAY, -34, GETDATE())))),
(2197, 'TIX-MEGA-1482-1', 1482, N'Bùi Anh', 'mega_req_482@gmail.com', 'TIX-MEGA-1482-1|E1098|1295', 0, DATEADD(MINUTE, 57, DATEADD(HOUR, 17, DATEADD(DAY, -34, GETDATE())))),
(2198, 'TIX-MEGA-1483-0', 1483, N'Hoàng Lan', 'mega_req_483@gmail.com', 'TIX-MEGA-1483-0|E1059|1177', 0, DATEADD(MINUTE, 11, DATEADD(HOUR, 14, DATEADD(DAY, -47, GETDATE())))),
(2199, 'TIX-MEGA-1484-0', 1484, N'Trần Minh', 'mega_req_484@gmail.com', 'TIX-MEGA-1484-0|E1093|1280', 0, DATEADD(MINUTE, 38, DATEADD(HOUR, 15, DATEADD(DAY, -50, GETDATE())))),
(2200, 'TIX-MEGA-1485-0', 1485, N'Đỗ Hùng', 'mega_req_485@gmail.com', 'TIX-MEGA-1485-0|E1002|1006', 0, DATEADD(MINUTE, 4, DATEADD(HOUR, 4, DATEADD(DAY, -2, GETDATE())))),
(2201, 'TIX-MEGA-1486-0', 1486, N'Trần Tâm', 'mega_req_486@gmail.com', 'TIX-MEGA-1486-0|E1099|1299', 0, DATEADD(MINUTE, 23, DATEADD(HOUR, 17, DATEADD(DAY, -7, GETDATE())))),
(2202, 'TIX-MEGA-1486-1', 1486, N'Trần Tâm', 'mega_req_486@gmail.com', 'TIX-MEGA-1486-1|E1099|1299', 0, DATEADD(MINUTE, 23, DATEADD(HOUR, 17, DATEADD(DAY, -7, GETDATE())))),
(2203, 'TIX-MEGA-1486-2', 1486, N'Trần Tâm', 'mega_req_486@gmail.com', 'TIX-MEGA-1486-2|E1099|1299', 0, DATEADD(MINUTE, 23, DATEADD(HOUR, 17, DATEADD(DAY, -7, GETDATE())))),
(2204, 'TIX-MEGA-1487-0', 1487, N'Nguyễn Hải', 'mega_req_487@gmail.com', 'TIX-MEGA-1487-0|E1079|1237', 0, DATEADD(MINUTE, 23, DATEADD(HOUR, 22, DATEADD(DAY, -57, GETDATE())))),
(2205, 'TIX-MEGA-1487-1', 1487, N'Nguyễn Hải', 'mega_req_487@gmail.com', 'TIX-MEGA-1487-1|E1079|1237', 0, DATEADD(MINUTE, 23, DATEADD(HOUR, 22, DATEADD(DAY, -57, GETDATE())))),
(2206, 'TIX-MEGA-1487-2', 1487, N'Nguyễn Hải', 'mega_req_487@gmail.com', 'TIX-MEGA-1487-2|E1079|1237', 1, DATEADD(MINUTE, 23, DATEADD(HOUR, 22, DATEADD(DAY, -57, GETDATE())))),
(2207, 'TIX-MEGA-1488-0', 1488, N'Vũ Trang', 'mega_req_488@gmail.com', 'TIX-MEGA-1488-0|E1076|1228', 0, DATEADD(MINUTE, 24, DATEADD(HOUR, 9, DATEADD(DAY, -35, GETDATE())))),
(2208, 'TIX-MEGA-1488-1', 1488, N'Vũ Trang', 'mega_req_488@gmail.com', 'TIX-MEGA-1488-1|E1076|1228', 0, DATEADD(MINUTE, 24, DATEADD(HOUR, 9, DATEADD(DAY, -35, GETDATE())))),
(2209, 'TIX-MEGA-1488-2', 1488, N'Vũ Trang', 'mega_req_488@gmail.com', 'TIX-MEGA-1488-2|E1076|1228', 0, DATEADD(MINUTE, 24, DATEADD(HOUR, 9, DATEADD(DAY, -35, GETDATE())))),
(2210, 'TIX-MEGA-1489-0', 1489, N'Vũ Linh', 'mega_req_489@gmail.com', 'TIX-MEGA-1489-0|E1072|1216', 0, DATEADD(MINUTE, 11, DATEADD(HOUR, 13, DATEADD(DAY, -42, GETDATE())))),
(2211, 'TIX-MEGA-1490-0', 1490, N'Đỗ Trang', 'mega_req_490@gmail.com', 'TIX-MEGA-1490-0|E1040|1120', 0, DATEADD(MINUTE, 49, DATEADD(HOUR, 7, DATEADD(DAY, -51, GETDATE()))));
INSERT INTO Tickets (ticket_id, ticket_code, order_item_id, attendee_name, attendee_email, qr_code, is_checked_in, created_at) VALUES
(2212, 'TIX-MEGA-1491-0', 1491, N'Đỗ Lan', 'mega_req_491@gmail.com', 'TIX-MEGA-1491-0|E1003|1010', 0, DATEADD(MINUTE, 58, DATEADD(HOUR, 20, DATEADD(DAY, -31, GETDATE())))),
(2213, 'TIX-MEGA-1491-1', 1491, N'Đỗ Lan', 'mega_req_491@gmail.com', 'TIX-MEGA-1491-1|E1003|1010', 0, DATEADD(MINUTE, 58, DATEADD(HOUR, 20, DATEADD(DAY, -31, GETDATE())))),
(2214, 'TIX-MEGA-1491-2', 1491, N'Đỗ Lan', 'mega_req_491@gmail.com', 'TIX-MEGA-1491-2|E1003|1010', 0, DATEADD(MINUTE, 58, DATEADD(HOUR, 20, DATEADD(DAY, -31, GETDATE())))),
(2215, 'TIX-MEGA-1491-3', 1491, N'Đỗ Lan', 'mega_req_491@gmail.com', 'TIX-MEGA-1491-3|E1003|1010', 0, DATEADD(MINUTE, 58, DATEADD(HOUR, 20, DATEADD(DAY, -31, GETDATE())))),
(2216, 'TIX-MEGA-1492-0', 1492, N'Huỳnh Bảo', 'mega_req_492@gmail.com', 'TIX-MEGA-1492-0|E1028|1086', 0, DATEADD(MINUTE, 39, DATEADD(HOUR, 4, DATEADD(DAY, -18, GETDATE())))),
(2217, 'TIX-MEGA-1492-1', 1492, N'Huỳnh Bảo', 'mega_req_492@gmail.com', 'TIX-MEGA-1492-1|E1028|1086', 0, DATEADD(MINUTE, 39, DATEADD(HOUR, 4, DATEADD(DAY, -18, GETDATE())))),
(2218, 'TIX-MEGA-1492-2', 1492, N'Huỳnh Bảo', 'mega_req_492@gmail.com', 'TIX-MEGA-1492-2|E1028|1086', 0, DATEADD(MINUTE, 39, DATEADD(HOUR, 4, DATEADD(DAY, -18, GETDATE())))),
(2219, 'TIX-MEGA-1492-3', 1492, N'Huỳnh Bảo', 'mega_req_492@gmail.com', 'TIX-MEGA-1492-3|E1028|1086', 0, DATEADD(MINUTE, 39, DATEADD(HOUR, 4, DATEADD(DAY, -18, GETDATE())))),
(2220, 'TIX-MEGA-1493-0', 1493, N'Trần Lan', 'mega_req_493@gmail.com', 'TIX-MEGA-1493-0|E1046|1140', 0, DATEADD(MINUTE, 47, DATEADD(HOUR, 19, DATEADD(DAY, -51, GETDATE())))),
(2221, 'TIX-MEGA-1493-1', 1493, N'Trần Lan', 'mega_req_493@gmail.com', 'TIX-MEGA-1493-1|E1046|1140', 0, DATEADD(MINUTE, 47, DATEADD(HOUR, 19, DATEADD(DAY, -51, GETDATE())))),
(2222, 'TIX-MEGA-1494-0', 1494, N'Vũ Thu', 'mega_req_494@gmail.com', 'TIX-MEGA-1494-0|E1002|1006', 0, DATEADD(MINUTE, 14, DATEADD(HOUR, 12, DATEADD(DAY, -49, GETDATE())))),
(2223, 'TIX-MEGA-1494-1', 1494, N'Vũ Thu', 'mega_req_494@gmail.com', 'TIX-MEGA-1494-1|E1002|1006', 0, DATEADD(MINUTE, 14, DATEADD(HOUR, 12, DATEADD(DAY, -49, GETDATE())))),
(2224, 'TIX-MEGA-1495-0', 1495, N'Phạm Trang', 'mega_req_495@gmail.com', 'TIX-MEGA-1495-0|E1001|1003', 0, DATEADD(MINUTE, 30, DATEADD(HOUR, 16, DATEADD(DAY, -34, GETDATE())))),
(2225, 'TIX-MEGA-1496-0', 1496, N'Nguyễn Bảo', 'mega_req_496@gmail.com', 'TIX-MEGA-1496-0|E1010|1032', 0, DATEADD(MINUTE, 5, DATEADD(HOUR, 2, DATEADD(DAY, -25, GETDATE())))),
(2226, 'TIX-MEGA-1497-0', 1497, N'Nguyễn Trang', 'mega_req_497@gmail.com', 'TIX-MEGA-1497-0|E1015|1046', 0, DATEADD(MINUTE, 54, DATEADD(HOUR, 3, DATEADD(DAY, -59, GETDATE())))),
(2227, 'TIX-MEGA-1497-1', 1497, N'Nguyễn Trang', 'mega_req_497@gmail.com', 'TIX-MEGA-1497-1|E1015|1046', 0, DATEADD(MINUTE, 54, DATEADD(HOUR, 3, DATEADD(DAY, -59, GETDATE())))),
(2228, 'TIX-MEGA-1497-2', 1497, N'Nguyễn Trang', 'mega_req_497@gmail.com', 'TIX-MEGA-1497-2|E1015|1046', 0, DATEADD(MINUTE, 54, DATEADD(HOUR, 3, DATEADD(DAY, -59, GETDATE())))),
(2229, 'TIX-MEGA-1497-3', 1497, N'Nguyễn Trang', 'mega_req_497@gmail.com', 'TIX-MEGA-1497-3|E1015|1046', 0, DATEADD(MINUTE, 54, DATEADD(HOUR, 3, DATEADD(DAY, -59, GETDATE())))),
(2230, 'TIX-MEGA-1498-0', 1498, N'Phạm Phong', 'mega_req_498@gmail.com', 'TIX-MEGA-1498-0|E1010|1032', 0, DATEADD(MINUTE, 45, DATEADD(HOUR, 8, DATEADD(DAY, -1, GETDATE())))),
(2231, 'TIX-MEGA-1499-0', 1499, N'Nguyễn Kiên', 'mega_req_499@gmail.com', 'TIX-MEGA-1499-0|E1030|1091', 0, DATEADD(MINUTE, 5, DATEADD(HOUR, 1, DATEADD(DAY, -20, GETDATE())))),
(2232, 'TIX-MEGA-1499-1', 1499, N'Nguyễn Kiên', 'mega_req_499@gmail.com', 'TIX-MEGA-1499-1|E1030|1091', 0, DATEADD(MINUTE, 5, DATEADD(HOUR, 1, DATEADD(DAY, -20, GETDATE())))),
(2233, 'TIX-MEGA-1499-2', 1499, N'Nguyễn Kiên', 'mega_req_499@gmail.com', 'TIX-MEGA-1499-2|E1030|1091', 0, DATEADD(MINUTE, 5, DATEADD(HOUR, 1, DATEADD(DAY, -20, GETDATE())))),
(2234, 'TIX-MEGA-1499-3', 1499, N'Nguyễn Kiên', 'mega_req_499@gmail.com', 'TIX-MEGA-1499-3|E1030|1091', 0, DATEADD(MINUTE, 5, DATEADD(HOUR, 1, DATEADD(DAY, -20, GETDATE()))));
SET IDENTITY_INSERT Tickets OFF;
GO
SET IDENTITY_INSERT PaymentTransactions ON;
INSERT INTO PaymentTransactions (transaction_id, order_id, payment_method, seepay_transaction_id, amount, status, completed_at) VALUES
(1000, 1000, 'seepay', 'SP-MEGA-1000', 1000000, 'completed', DATEADD(MINUTE, 52, DATEADD(HOUR, 18, DATEADD(DAY, -40, GETDATE())))),
(1001, 1001, 'seepay', 'SP-MEGA-1001', 800000, 'completed', DATEADD(MINUTE, 8, DATEADD(HOUR, 10, DATEADD(DAY, -30, GETDATE())))),
(1002, 1002, 'seepay', 'SP-MEGA-1002', 500000, 'completed', DATEADD(MINUTE, 24, DATEADD(HOUR, 12, DATEADD(DAY, -12, GETDATE())))),
(1003, 1003, 'seepay', 'SP-MEGA-1003', 450000, 'completed', DATEADD(MINUTE, 1, DATEADD(HOUR, 6, DATEADD(DAY, -28, GETDATE())))),
(1004, 1004, 'seepay', 'SP-MEGA-1004', 800000, 'completed', DATEADD(MINUTE, 56, DATEADD(HOUR, 9, DATEADD(DAY, -31, GETDATE())))),
(1005, 1005, 'seepay', 'SP-MEGA-1005', 1500000, 'cancelled', NULL),
(1006, 1006, 'seepay', 'SP-MEGA-1006', 150000, 'completed', DATEADD(MINUTE, 9, DATEADD(HOUR, 18, DATEADD(DAY, -5, GETDATE())))),
(1007, 1007, 'seepay', 'SP-MEGA-1007', 150000, 'cancelled', NULL),
(1008, 1008, 'seepay', 'SP-MEGA-1008', 800000, 'completed', DATEADD(MINUTE, 45, DATEADD(HOUR, 12, DATEADD(DAY, -56, GETDATE())))),
(1009, 1009, 'seepay', 'SP-MEGA-1009', 800000, 'completed', DATEADD(MINUTE, 28, DATEADD(HOUR, 8, DATEADD(DAY, -58, GETDATE())))),
(1010, 1010, 'seepay', 'SP-MEGA-1010', 1000000, 'completed', DATEADD(MINUTE, 49, DATEADD(HOUR, 22, DATEADD(DAY, -14, GETDATE())))),
(1011, 1011, 'seepay', 'SP-MEGA-1011', 450000, 'refunded', DATEADD(MINUTE, 58, DATEADD(HOUR, 19, DATEADD(DAY, -29, GETDATE())))),
(1012, 1012, 'seepay', 'SP-MEGA-1012', 2000000, 'completed', DATEADD(MINUTE, 31, DATEADD(HOUR, 6, DATEADD(DAY, -24, GETDATE())))),
(1013, 1013, 'seepay', 'SP-MEGA-1013', 2000000, 'completed', DATEADD(MINUTE, 17, DATEADD(HOUR, 8, DATEADD(DAY, -37, GETDATE())))),
(1014, 1014, 'seepay', 'SP-MEGA-1014', 400000, 'refunded', DATEADD(MINUTE, 41, DATEADD(HOUR, 21, DATEADD(DAY, -22, GETDATE())))),
(1015, 1015, 'seepay', 'SP-MEGA-1015', 500000, 'cancelled', NULL),
(1016, 1016, 'seepay', 'SP-MEGA-1016', 300000, 'refunded', DATEADD(MINUTE, 47, DATEADD(HOUR, 12, DATEADD(DAY, -54, GETDATE())))),
(1017, 1017, 'seepay', 'SP-MEGA-1017', 150000, 'refunded', DATEADD(MINUTE, 22, DATEADD(HOUR, 18, DATEADD(DAY, -59, GETDATE())))),
(1018, 1018, 'seepay', 'SP-MEGA-1018', 1500000, 'completed', DATEADD(MINUTE, 19, DATEADD(HOUR, 21, DATEADD(DAY, -17, GETDATE())))),
(1019, 1019, 'seepay', 'SP-MEGA-1019', 200000, 'refunded', DATEADD(MINUTE, 49, DATEADD(HOUR, 3, DATEADD(DAY, -9, GETDATE())))),
(1020, 1020, 'seepay', 'SP-MEGA-1020', 200000, 'pending', NULL),
(1021, 1021, 'seepay', 'SP-MEGA-1021', 600000, 'pending', NULL),
(1022, 1022, 'seepay', 'SP-MEGA-1022', 1000000, 'pending', NULL),
(1023, 1023, 'seepay', 'SP-MEGA-1023', 1500000, 'completed', DATEADD(MINUTE, 10, DATEADD(HOUR, 6, DATEADD(DAY, -14, GETDATE())))),
(1024, 1024, 'seepay', 'SP-MEGA-1024', 200000, 'cancelled', NULL),
(1025, 1025, 'seepay', 'SP-MEGA-1025', 450000, 'completed', DATEADD(MINUTE, 45, DATEADD(HOUR, 22, DATEADD(DAY, -7, GETDATE())))),
(1026, 1026, 'seepay', 'SP-MEGA-1026', 1000000, 'pending', NULL),
(1027, 1027, 'seepay', 'SP-MEGA-1027', 150000, 'cancelled', NULL),
(1028, 1028, 'seepay', 'SP-MEGA-1028', 150000, 'completed', DATEADD(MINUTE, 52, DATEADD(HOUR, 12, DATEADD(DAY, -58, GETDATE())))),
(1029, 1029, 'seepay', 'SP-MEGA-1029', 1500000, 'pending', NULL),
(1030, 1030, 'seepay', 'SP-MEGA-1030', 200000, 'pending', NULL),
(1031, 1031, 'seepay', 'SP-MEGA-1031', 450000, 'refunded', DATEADD(MINUTE, 51, DATEADD(HOUR, 20, DATEADD(DAY, -9, GETDATE())))),
(1032, 1032, 'seepay', 'SP-MEGA-1032', 500000, 'cancelled', NULL),
(1033, 1033, 'seepay', 'SP-MEGA-1033', 450000, 'pending', NULL),
(1034, 1034, 'seepay', 'SP-MEGA-1034', 300000, 'completed', DATEADD(MINUTE, 1, DATEADD(HOUR, 11, DATEADD(DAY, -55, GETDATE())))),
(1035, 1035, 'seepay', 'SP-MEGA-1035', 800000, 'completed', DATEADD(MINUTE, 6, DATEADD(HOUR, 9, DATEADD(DAY, -1, GETDATE())))),
(1036, 1036, 'seepay', 'SP-MEGA-1036', 800000, 'completed', DATEADD(MINUTE, 26, DATEADD(HOUR, 23, DATEADD(DAY, -8, GETDATE())))),
(1037, 1037, 'seepay', 'SP-MEGA-1037', 450000, 'cancelled', NULL),
(1038, 1038, 'seepay', 'SP-MEGA-1038', 200000, 'cancelled', NULL),
(1039, 1039, 'seepay', 'SP-MEGA-1039', 600000, 'pending', NULL),
(1040, 1040, 'seepay', 'SP-MEGA-1040', 450000, 'completed', DATEADD(MINUTE, 38, DATEADD(HOUR, 22, DATEADD(DAY, -7, GETDATE())))),
(1041, 1041, 'seepay', 'SP-MEGA-1041', 450000, 'completed', DATEADD(MINUTE, 50, DATEADD(HOUR, 2, DATEADD(DAY, -52, GETDATE())))),
(1042, 1042, 'seepay', 'SP-MEGA-1042', 2000000, 'completed', DATEADD(MINUTE, 10, DATEADD(HOUR, 13, DATEADD(DAY, -17, GETDATE())))),
(1043, 1043, 'seepay', 'SP-MEGA-1043', 300000, 'completed', DATEADD(MINUTE, 39, DATEADD(HOUR, 17, DATEADD(DAY, -2, GETDATE())))),
(1044, 1044, 'seepay', 'SP-MEGA-1044', 1500000, 'completed', DATEADD(MINUTE, 20, DATEADD(HOUR, 14, DATEADD(DAY, -13, GETDATE())))),
(1045, 1045, 'seepay', 'SP-MEGA-1045', 400000, 'completed', DATEADD(MINUTE, 7, DATEADD(HOUR, 4, DATEADD(DAY, -50, GETDATE())))),
(1046, 1046, 'seepay', 'SP-MEGA-1046', 200000, 'completed', DATEADD(MINUTE, 56, DATEADD(HOUR, 12, DATEADD(DAY, -26, GETDATE())))),
(1047, 1047, 'seepay', 'SP-MEGA-1047', 600000, 'pending', NULL),
(1048, 1048, 'seepay', 'SP-MEGA-1048', 300000, 'completed', DATEADD(MINUTE, 57, DATEADD(HOUR, 5, DATEADD(DAY, -39, GETDATE())))),
(1049, 1049, 'seepay', 'SP-MEGA-1049', 600000, 'cancelled', NULL),
(1050, 1050, 'seepay', 'SP-MEGA-1050', 600000, 'completed', DATEADD(MINUTE, 6, DATEADD(HOUR, 14, DATEADD(DAY, -18, GETDATE())))),
(1051, 1051, 'seepay', 'SP-MEGA-1051', 800000, 'completed', DATEADD(MINUTE, 57, DATEADD(HOUR, 8, DATEADD(DAY, -48, GETDATE())))),
(1052, 1052, 'seepay', 'SP-MEGA-1052', 1500000, 'completed', DATEADD(MINUTE, 54, DATEADD(HOUR, 7, DATEADD(DAY, -41, GETDATE())))),
(1053, 1053, 'seepay', 'SP-MEGA-1053', 200000, 'completed', DATEADD(MINUTE, 40, DATEADD(HOUR, 5, DATEADD(DAY, -57, GETDATE())))),
(1054, 1054, 'seepay', 'SP-MEGA-1054', 1500000, 'completed', DATEADD(MINUTE, 0, DATEADD(HOUR, 12, DATEADD(DAY, -5, GETDATE())))),
(1055, 1055, 'seepay', 'SP-MEGA-1055', 200000, 'completed', DATEADD(MINUTE, 9, DATEADD(HOUR, 17, DATEADD(DAY, -56, GETDATE())))),
(1056, 1056, 'seepay', 'SP-MEGA-1056', 500000, 'completed', DATEADD(MINUTE, 16, DATEADD(HOUR, 23, DATEADD(DAY, -46, GETDATE())))),
(1057, 1057, 'seepay', 'SP-MEGA-1057', 150000, 'completed', DATEADD(MINUTE, 50, DATEADD(HOUR, 21, DATEADD(DAY, -5, GETDATE())))),
(1058, 1058, 'seepay', 'SP-MEGA-1058', 300000, 'completed', DATEADD(MINUTE, 27, DATEADD(HOUR, 2, DATEADD(DAY, -7, GETDATE())))),
(1059, 1059, 'seepay', 'SP-MEGA-1059', 1500000, 'pending', NULL),
(1060, 1060, 'seepay', 'SP-MEGA-1060', 600000, 'completed', DATEADD(MINUTE, 57, DATEADD(HOUR, 2, DATEADD(DAY, -37, GETDATE())))),
(1061, 1061, 'seepay', 'SP-MEGA-1061', 800000, 'cancelled', NULL),
(1062, 1062, 'seepay', 'SP-MEGA-1062', 600000, 'refunded', DATEADD(MINUTE, 38, DATEADD(HOUR, 7, DATEADD(DAY, 0, GETDATE())))),
(1063, 1063, 'seepay', 'SP-MEGA-1063', 600000, 'refunded', DATEADD(MINUTE, 8, DATEADD(HOUR, 22, DATEADD(DAY, -59, GETDATE())))),
(1064, 1064, 'seepay', 'SP-MEGA-1064', 2000000, 'completed', DATEADD(MINUTE, 29, DATEADD(HOUR, 1, DATEADD(DAY, -34, GETDATE())))),
(1065, 1065, 'seepay', 'SP-MEGA-1065', 1500000, 'completed', DATEADD(MINUTE, 16, DATEADD(HOUR, 1, DATEADD(DAY, -57, GETDATE())))),
(1066, 1066, 'seepay', 'SP-MEGA-1066', 450000, 'refunded', DATEADD(MINUTE, 32, DATEADD(HOUR, 14, DATEADD(DAY, -32, GETDATE())))),
(1067, 1067, 'seepay', 'SP-MEGA-1067', 800000, 'completed', DATEADD(MINUTE, 7, DATEADD(HOUR, 14, DATEADD(DAY, -34, GETDATE())))),
(1068, 1068, 'seepay', 'SP-MEGA-1068', 1000000, 'pending', NULL),
(1069, 1069, 'seepay', 'SP-MEGA-1069', 600000, 'refunded', DATEADD(MINUTE, 8, DATEADD(HOUR, 1, DATEADD(DAY, -51, GETDATE())))),
(1070, 1070, 'seepay', 'SP-MEGA-1070', 500000, 'pending', NULL),
(1071, 1071, 'seepay', 'SP-MEGA-1071', 1000000, 'pending', NULL),
(1072, 1072, 'seepay', 'SP-MEGA-1072', 500000, 'completed', DATEADD(MINUTE, 53, DATEADD(HOUR, 8, DATEADD(DAY, -55, GETDATE())))),
(1073, 1073, 'seepay', 'SP-MEGA-1073', 600000, 'refunded', DATEADD(MINUTE, 24, DATEADD(HOUR, 2, DATEADD(DAY, 0, GETDATE())))),
(1074, 1074, 'seepay', 'SP-MEGA-1074', 400000, 'cancelled', NULL),
(1075, 1075, 'seepay', 'SP-MEGA-1075', 400000, 'pending', NULL),
(1076, 1076, 'seepay', 'SP-MEGA-1076', 300000, 'pending', NULL),
(1077, 1077, 'seepay', 'SP-MEGA-1077', 400000, 'completed', DATEADD(MINUTE, 36, DATEADD(HOUR, 14, DATEADD(DAY, -7, GETDATE())))),
(1078, 1078, 'seepay', 'SP-MEGA-1078', 200000, 'refunded', DATEADD(MINUTE, 37, DATEADD(HOUR, 0, DATEADD(DAY, -36, GETDATE())))),
(1079, 1079, 'seepay', 'SP-MEGA-1079', 400000, 'refunded', DATEADD(MINUTE, 51, DATEADD(HOUR, 8, DATEADD(DAY, -38, GETDATE())))),
(1080, 1080, 'seepay', 'SP-MEGA-1080', 600000, 'pending', NULL),
(1081, 1081, 'seepay', 'SP-MEGA-1081', 500000, 'completed', DATEADD(MINUTE, 46, DATEADD(HOUR, 12, DATEADD(DAY, -52, GETDATE())))),
(1082, 1082, 'seepay', 'SP-MEGA-1082', 500000, 'completed', DATEADD(MINUTE, 6, DATEADD(HOUR, 21, DATEADD(DAY, -53, GETDATE())))),
(1083, 1083, 'seepay', 'SP-MEGA-1083', 2000000, 'completed', DATEADD(MINUTE, 32, DATEADD(HOUR, 4, DATEADD(DAY, -15, GETDATE())))),
(1084, 1084, 'seepay', 'SP-MEGA-1084', 150000, 'pending', NULL),
(1085, 1085, 'seepay', 'SP-MEGA-1085', 600000, 'pending', NULL),
(1086, 1086, 'seepay', 'SP-MEGA-1086', 150000, 'completed', DATEADD(MINUTE, 26, DATEADD(HOUR, 22, DATEADD(DAY, -52, GETDATE())))),
(1087, 1087, 'seepay', 'SP-MEGA-1087', 2000000, 'completed', DATEADD(MINUTE, 14, DATEADD(HOUR, 19, DATEADD(DAY, -11, GETDATE())))),
(1088, 1088, 'seepay', 'SP-MEGA-1088', 500000, 'completed', DATEADD(MINUTE, 2, DATEADD(HOUR, 1, DATEADD(DAY, -38, GETDATE())))),
(1089, 1089, 'seepay', 'SP-MEGA-1089', 500000, 'completed', DATEADD(MINUTE, 13, DATEADD(HOUR, 12, DATEADD(DAY, -11, GETDATE())))),
(1090, 1090, 'seepay', 'SP-MEGA-1090', 1000000, 'completed', DATEADD(MINUTE, 32, DATEADD(HOUR, 1, DATEADD(DAY, -2, GETDATE())))),
(1091, 1091, 'seepay', 'SP-MEGA-1091', 450000, 'cancelled', NULL),
(1092, 1092, 'seepay', 'SP-MEGA-1092', 500000, 'refunded', DATEADD(MINUTE, 37, DATEADD(HOUR, 20, DATEADD(DAY, -16, GETDATE())))),
(1093, 1093, 'seepay', 'SP-MEGA-1093', 2000000, 'refunded', DATEADD(MINUTE, 54, DATEADD(HOUR, 0, DATEADD(DAY, -4, GETDATE())))),
(1094, 1094, 'seepay', 'SP-MEGA-1094', 600000, 'completed', DATEADD(MINUTE, 44, DATEADD(HOUR, 23, DATEADD(DAY, -34, GETDATE())))),
(1095, 1095, 'seepay', 'SP-MEGA-1095', 600000, 'completed', DATEADD(MINUTE, 2, DATEADD(HOUR, 13, DATEADD(DAY, -29, GETDATE())))),
(1096, 1096, 'seepay', 'SP-MEGA-1096', 200000, 'completed', DATEADD(MINUTE, 13, DATEADD(HOUR, 7, DATEADD(DAY, -7, GETDATE())))),
(1097, 1097, 'seepay', 'SP-MEGA-1097', 500000, 'pending', NULL),
(1098, 1098, 'seepay', 'SP-MEGA-1098', 600000, 'pending', NULL),
(1099, 1099, 'seepay', 'SP-MEGA-1099', 300000, 'refunded', DATEADD(MINUTE, 56, DATEADD(HOUR, 22, DATEADD(DAY, -12, GETDATE()))));
INSERT INTO PaymentTransactions (transaction_id, order_id, payment_method, seepay_transaction_id, amount, status, completed_at) VALUES
(1100, 1100, 'seepay', 'SP-MEGA-1100', 400000, 'completed', DATEADD(MINUTE, 35, DATEADD(HOUR, 10, DATEADD(DAY, -19, GETDATE())))),
(1101, 1101, 'seepay', 'SP-MEGA-1101', 600000, 'cancelled', NULL),
(1102, 1102, 'seepay', 'SP-MEGA-1102', 2000000, 'completed', DATEADD(MINUTE, 41, DATEADD(HOUR, 6, DATEADD(DAY, -7, GETDATE())))),
(1103, 1103, 'seepay', 'SP-MEGA-1103', 200000, 'refunded', DATEADD(MINUTE, 40, DATEADD(HOUR, 4, DATEADD(DAY, -49, GETDATE())))),
(1104, 1104, 'seepay', 'SP-MEGA-1104', 300000, 'completed', DATEADD(MINUTE, 53, DATEADD(HOUR, 8, DATEADD(DAY, -17, GETDATE())))),
(1105, 1105, 'seepay', 'SP-MEGA-1105', 1000000, 'completed', DATEADD(MINUTE, 35, DATEADD(HOUR, 1, DATEADD(DAY, -5, GETDATE())))),
(1106, 1106, 'seepay', 'SP-MEGA-1106', 450000, 'completed', DATEADD(MINUTE, 2, DATEADD(HOUR, 17, DATEADD(DAY, -27, GETDATE())))),
(1107, 1107, 'seepay', 'SP-MEGA-1107', 300000, 'cancelled', NULL),
(1108, 1108, 'seepay', 'SP-MEGA-1108', 300000, 'cancelled', NULL),
(1109, 1109, 'seepay', 'SP-MEGA-1109', 500000, 'cancelled', NULL),
(1110, 1110, 'seepay', 'SP-MEGA-1110', 200000, 'completed', DATEADD(MINUTE, 24, DATEADD(HOUR, 19, DATEADD(DAY, -45, GETDATE())))),
(1111, 1111, 'seepay', 'SP-MEGA-1111', 200000, 'pending', NULL),
(1112, 1112, 'seepay', 'SP-MEGA-1112', 600000, 'cancelled', NULL),
(1113, 1113, 'seepay', 'SP-MEGA-1113', 2000000, 'cancelled', NULL),
(1114, 1114, 'seepay', 'SP-MEGA-1114', 150000, 'cancelled', NULL),
(1115, 1115, 'seepay', 'SP-MEGA-1115', 600000, 'pending', NULL),
(1116, 1116, 'seepay', 'SP-MEGA-1116', 600000, 'completed', DATEADD(MINUTE, 56, DATEADD(HOUR, 12, DATEADD(DAY, -22, GETDATE())))),
(1117, 1117, 'seepay', 'SP-MEGA-1117', 500000, 'completed', DATEADD(MINUTE, 10, DATEADD(HOUR, 17, DATEADD(DAY, -25, GETDATE())))),
(1118, 1118, 'seepay', 'SP-MEGA-1118', 1000000, 'completed', DATEADD(MINUTE, 6, DATEADD(HOUR, 14, DATEADD(DAY, -10, GETDATE())))),
(1119, 1119, 'seepay', 'SP-MEGA-1119', 1500000, 'pending', NULL),
(1120, 1120, 'seepay', 'SP-MEGA-1120', 2000000, 'refunded', DATEADD(MINUTE, 6, DATEADD(HOUR, 17, DATEADD(DAY, -51, GETDATE())))),
(1121, 1121, 'seepay', 'SP-MEGA-1121', 150000, 'pending', NULL),
(1122, 1122, 'seepay', 'SP-MEGA-1122', 1500000, 'cancelled', NULL),
(1123, 1123, 'seepay', 'SP-MEGA-1123', 150000, 'pending', NULL),
(1124, 1124, 'seepay', 'SP-MEGA-1124', 200000, 'completed', DATEADD(MINUTE, 18, DATEADD(HOUR, 4, DATEADD(DAY, -47, GETDATE())))),
(1125, 1125, 'seepay', 'SP-MEGA-1125', 1500000, 'cancelled', NULL),
(1126, 1126, 'seepay', 'SP-MEGA-1126', 450000, 'completed', DATEADD(MINUTE, 41, DATEADD(HOUR, 22, DATEADD(DAY, -4, GETDATE())))),
(1127, 1127, 'seepay', 'SP-MEGA-1127', 600000, 'pending', NULL),
(1128, 1128, 'seepay', 'SP-MEGA-1128', 150000, 'completed', DATEADD(MINUTE, 30, DATEADD(HOUR, 18, DATEADD(DAY, -58, GETDATE())))),
(1129, 1129, 'seepay', 'SP-MEGA-1129', 300000, 'cancelled', NULL),
(1130, 1130, 'seepay', 'SP-MEGA-1130', 150000, 'completed', DATEADD(MINUTE, 34, DATEADD(HOUR, 18, DATEADD(DAY, -31, GETDATE())))),
(1131, 1131, 'seepay', 'SP-MEGA-1131', 2000000, 'completed', DATEADD(MINUTE, 31, DATEADD(HOUR, 5, DATEADD(DAY, -24, GETDATE())))),
(1132, 1132, 'seepay', 'SP-MEGA-1132', 600000, 'completed', DATEADD(MINUTE, 21, DATEADD(HOUR, 1, DATEADD(DAY, -41, GETDATE())))),
(1133, 1133, 'seepay', 'SP-MEGA-1133', 600000, 'completed', DATEADD(MINUTE, 39, DATEADD(HOUR, 10, DATEADD(DAY, -40, GETDATE())))),
(1134, 1134, 'seepay', 'SP-MEGA-1134', 200000, 'completed', DATEADD(MINUTE, 40, DATEADD(HOUR, 6, DATEADD(DAY, -7, GETDATE())))),
(1135, 1135, 'seepay', 'SP-MEGA-1135', 450000, 'refunded', DATEADD(MINUTE, 10, DATEADD(HOUR, 13, DATEADD(DAY, -52, GETDATE())))),
(1136, 1136, 'seepay', 'SP-MEGA-1136', 500000, 'completed', DATEADD(MINUTE, 26, DATEADD(HOUR, 8, DATEADD(DAY, -18, GETDATE())))),
(1137, 1137, 'seepay', 'SP-MEGA-1137', 1000000, 'completed', DATEADD(MINUTE, 27, DATEADD(HOUR, 10, DATEADD(DAY, -57, GETDATE())))),
(1138, 1138, 'seepay', 'SP-MEGA-1138', 800000, 'completed', DATEADD(MINUTE, 43, DATEADD(HOUR, 6, DATEADD(DAY, -39, GETDATE())))),
(1139, 1139, 'seepay', 'SP-MEGA-1139', 500000, 'pending', NULL),
(1140, 1140, 'seepay', 'SP-MEGA-1140', 600000, 'pending', NULL),
(1141, 1141, 'seepay', 'SP-MEGA-1141', 600000, 'completed', DATEADD(MINUTE, 48, DATEADD(HOUR, 16, DATEADD(DAY, -56, GETDATE())))),
(1142, 1142, 'seepay', 'SP-MEGA-1142', 2000000, 'refunded', DATEADD(MINUTE, 26, DATEADD(HOUR, 2, DATEADD(DAY, -15, GETDATE())))),
(1143, 1143, 'seepay', 'SP-MEGA-1143', 1500000, 'pending', NULL),
(1144, 1144, 'seepay', 'SP-MEGA-1144', 600000, 'pending', NULL),
(1145, 1145, 'seepay', 'SP-MEGA-1145', 500000, 'completed', DATEADD(MINUTE, 29, DATEADD(HOUR, 10, DATEADD(DAY, -38, GETDATE())))),
(1146, 1146, 'seepay', 'SP-MEGA-1146', 800000, 'completed', DATEADD(MINUTE, 28, DATEADD(HOUR, 9, DATEADD(DAY, -32, GETDATE())))),
(1147, 1147, 'seepay', 'SP-MEGA-1147', 500000, 'pending', NULL),
(1148, 1148, 'seepay', 'SP-MEGA-1148', 150000, 'completed', DATEADD(MINUTE, 41, DATEADD(HOUR, 6, DATEADD(DAY, -60, GETDATE())))),
(1149, 1149, 'seepay', 'SP-MEGA-1149', 600000, 'refunded', DATEADD(MINUTE, 12, DATEADD(HOUR, 10, DATEADD(DAY, -52, GETDATE())))),
(1150, 1150, 'seepay', 'SP-MEGA-1150', 300000, 'completed', DATEADD(MINUTE, 39, DATEADD(HOUR, 0, DATEADD(DAY, -14, GETDATE())))),
(1151, 1151, 'seepay', 'SP-MEGA-1151', 450000, 'completed', DATEADD(MINUTE, 54, DATEADD(HOUR, 15, DATEADD(DAY, -60, GETDATE())))),
(1152, 1152, 'seepay', 'SP-MEGA-1152', 1000000, 'completed', DATEADD(MINUTE, 38, DATEADD(HOUR, 10, DATEADD(DAY, -9, GETDATE())))),
(1153, 1153, 'seepay', 'SP-MEGA-1153', 600000, 'pending', NULL),
(1154, 1154, 'seepay', 'SP-MEGA-1154', 1000000, 'pending', NULL),
(1155, 1155, 'seepay', 'SP-MEGA-1155', 200000, 'completed', DATEADD(MINUTE, 15, DATEADD(HOUR, 10, DATEADD(DAY, -29, GETDATE())))),
(1156, 1156, 'seepay', 'SP-MEGA-1156', 1500000, 'cancelled', NULL),
(1157, 1157, 'seepay', 'SP-MEGA-1157', 300000, 'pending', NULL),
(1158, 1158, 'seepay', 'SP-MEGA-1158', 2000000, 'cancelled', NULL),
(1159, 1159, 'seepay', 'SP-MEGA-1159', 400000, 'refunded', DATEADD(MINUTE, 0, DATEADD(HOUR, 22, DATEADD(DAY, -9, GETDATE())))),
(1160, 1160, 'seepay', 'SP-MEGA-1160', 1000000, 'refunded', DATEADD(MINUTE, 24, DATEADD(HOUR, 22, DATEADD(DAY, -13, GETDATE())))),
(1161, 1161, 'seepay', 'SP-MEGA-1161', 2000000, 'pending', NULL),
(1162, 1162, 'seepay', 'SP-MEGA-1162', 2000000, 'completed', DATEADD(MINUTE, 21, DATEADD(HOUR, 10, DATEADD(DAY, -41, GETDATE())))),
(1163, 1163, 'seepay', 'SP-MEGA-1163', 150000, 'completed', DATEADD(MINUTE, 57, DATEADD(HOUR, 12, DATEADD(DAY, -51, GETDATE())))),
(1164, 1164, 'seepay', 'SP-MEGA-1164', 300000, 'completed', DATEADD(MINUTE, 22, DATEADD(HOUR, 6, DATEADD(DAY, -58, GETDATE())))),
(1165, 1165, 'seepay', 'SP-MEGA-1165', 600000, 'cancelled', NULL),
(1166, 1166, 'seepay', 'SP-MEGA-1166', 800000, 'completed', DATEADD(MINUTE, 9, DATEADD(HOUR, 12, DATEADD(DAY, -47, GETDATE())))),
(1167, 1167, 'seepay', 'SP-MEGA-1167', 1500000, 'cancelled', NULL),
(1168, 1168, 'seepay', 'SP-MEGA-1168', 150000, 'cancelled', NULL),
(1169, 1169, 'seepay', 'SP-MEGA-1169', 200000, 'cancelled', NULL),
(1170, 1170, 'seepay', 'SP-MEGA-1170', 500000, 'completed', DATEADD(MINUTE, 57, DATEADD(HOUR, 18, DATEADD(DAY, -53, GETDATE())))),
(1171, 1171, 'seepay', 'SP-MEGA-1171', 1000000, 'pending', NULL),
(1172, 1172, 'seepay', 'SP-MEGA-1172', 200000, 'completed', DATEADD(MINUTE, 23, DATEADD(HOUR, 7, DATEADD(DAY, -59, GETDATE())))),
(1173, 1173, 'seepay', 'SP-MEGA-1173', 400000, 'completed', DATEADD(MINUTE, 24, DATEADD(HOUR, 22, DATEADD(DAY, -12, GETDATE())))),
(1174, 1174, 'seepay', 'SP-MEGA-1174', 300000, 'cancelled', NULL),
(1175, 1175, 'seepay', 'SP-MEGA-1175', 1500000, 'completed', DATEADD(MINUTE, 27, DATEADD(HOUR, 6, DATEADD(DAY, -43, GETDATE())))),
(1176, 1176, 'seepay', 'SP-MEGA-1176', 300000, 'refunded', DATEADD(MINUTE, 0, DATEADD(HOUR, 17, DATEADD(DAY, -1, GETDATE())))),
(1177, 1177, 'seepay', 'SP-MEGA-1177', 1500000, 'cancelled', NULL),
(1178, 1178, 'seepay', 'SP-MEGA-1178', 300000, 'pending', NULL),
(1179, 1179, 'seepay', 'SP-MEGA-1179', 2000000, 'pending', NULL),
(1180, 1180, 'seepay', 'SP-MEGA-1180', 1000000, 'completed', DATEADD(MINUTE, 54, DATEADD(HOUR, 21, DATEADD(DAY, -21, GETDATE())))),
(1181, 1181, 'seepay', 'SP-MEGA-1181', 200000, 'pending', NULL),
(1182, 1182, 'seepay', 'SP-MEGA-1182', 300000, 'completed', DATEADD(MINUTE, 30, DATEADD(HOUR, 16, DATEADD(DAY, -26, GETDATE())))),
(1183, 1183, 'seepay', 'SP-MEGA-1183', 1000000, 'pending', NULL),
(1184, 1184, 'seepay', 'SP-MEGA-1184', 500000, 'refunded', DATEADD(MINUTE, 20, DATEADD(HOUR, 16, DATEADD(DAY, -32, GETDATE())))),
(1185, 1185, 'seepay', 'SP-MEGA-1185', 200000, 'completed', DATEADD(MINUTE, 17, DATEADD(HOUR, 16, DATEADD(DAY, -40, GETDATE())))),
(1186, 1186, 'seepay', 'SP-MEGA-1186', 2000000, 'completed', DATEADD(MINUTE, 15, DATEADD(HOUR, 20, DATEADD(DAY, -12, GETDATE())))),
(1187, 1187, 'seepay', 'SP-MEGA-1187', 150000, 'cancelled', NULL),
(1188, 1188, 'seepay', 'SP-MEGA-1188', 450000, 'refunded', DATEADD(MINUTE, 10, DATEADD(HOUR, 3, DATEADD(DAY, -11, GETDATE())))),
(1189, 1189, 'seepay', 'SP-MEGA-1189', 2000000, 'completed', DATEADD(MINUTE, 16, DATEADD(HOUR, 8, DATEADD(DAY, -7, GETDATE())))),
(1190, 1190, 'seepay', 'SP-MEGA-1190', 200000, 'completed', DATEADD(MINUTE, 3, DATEADD(HOUR, 1, DATEADD(DAY, -1, GETDATE())))),
(1191, 1191, 'seepay', 'SP-MEGA-1191', 400000, 'completed', DATEADD(MINUTE, 15, DATEADD(HOUR, 23, DATEADD(DAY, -46, GETDATE())))),
(1192, 1192, 'seepay', 'SP-MEGA-1192', 400000, 'refunded', DATEADD(MINUTE, 40, DATEADD(HOUR, 3, DATEADD(DAY, -43, GETDATE())))),
(1193, 1193, 'seepay', 'SP-MEGA-1193', 600000, 'pending', NULL),
(1194, 1194, 'seepay', 'SP-MEGA-1194', 600000, 'cancelled', NULL),
(1195, 1195, 'seepay', 'SP-MEGA-1195', 800000, 'completed', DATEADD(MINUTE, 23, DATEADD(HOUR, 18, DATEADD(DAY, -30, GETDATE())))),
(1196, 1196, 'seepay', 'SP-MEGA-1196', 300000, 'completed', DATEADD(MINUTE, 1, DATEADD(HOUR, 10, DATEADD(DAY, -19, GETDATE())))),
(1197, 1197, 'seepay', 'SP-MEGA-1197', 1000000, 'pending', NULL),
(1198, 1198, 'seepay', 'SP-MEGA-1198', 150000, 'pending', NULL),
(1199, 1199, 'seepay', 'SP-MEGA-1199', 800000, 'pending', NULL);
INSERT INTO PaymentTransactions (transaction_id, order_id, payment_method, seepay_transaction_id, amount, status, completed_at) VALUES
(1200, 1200, 'seepay', 'SP-MEGA-1200', 200000, 'cancelled', NULL),
(1201, 1201, 'seepay', 'SP-MEGA-1201', 1500000, 'refunded', DATEADD(MINUTE, 25, DATEADD(HOUR, 4, DATEADD(DAY, -14, GETDATE())))),
(1202, 1202, 'seepay', 'SP-MEGA-1202', 2000000, 'refunded', DATEADD(MINUTE, 16, DATEADD(HOUR, 22, DATEADD(DAY, -56, GETDATE())))),
(1203, 1203, 'seepay', 'SP-MEGA-1203', 400000, 'pending', NULL),
(1204, 1204, 'seepay', 'SP-MEGA-1204', 450000, 'pending', NULL),
(1205, 1205, 'seepay', 'SP-MEGA-1205', 1500000, 'completed', DATEADD(MINUTE, 14, DATEADD(HOUR, 9, DATEADD(DAY, -25, GETDATE())))),
(1206, 1206, 'seepay', 'SP-MEGA-1206', 150000, 'pending', NULL),
(1207, 1207, 'seepay', 'SP-MEGA-1207', 800000, 'completed', DATEADD(MINUTE, 29, DATEADD(HOUR, 15, DATEADD(DAY, -11, GETDATE())))),
(1208, 1208, 'seepay', 'SP-MEGA-1208', 600000, 'pending', NULL),
(1209, 1209, 'seepay', 'SP-MEGA-1209', 200000, 'cancelled', NULL),
(1210, 1210, 'seepay', 'SP-MEGA-1210', 150000, 'completed', DATEADD(MINUTE, 36, DATEADD(HOUR, 1, DATEADD(DAY, -45, GETDATE())))),
(1211, 1211, 'seepay', 'SP-MEGA-1211', 500000, 'completed', DATEADD(MINUTE, 24, DATEADD(HOUR, 12, DATEADD(DAY, -56, GETDATE())))),
(1212, 1212, 'seepay', 'SP-MEGA-1212', 400000, 'refunded', DATEADD(MINUTE, 7, DATEADD(HOUR, 23, DATEADD(DAY, -28, GETDATE())))),
(1213, 1213, 'seepay', 'SP-MEGA-1213', 150000, 'completed', DATEADD(MINUTE, 18, DATEADD(HOUR, 4, DATEADD(DAY, -29, GETDATE())))),
(1214, 1214, 'seepay', 'SP-MEGA-1214', 200000, 'completed', DATEADD(MINUTE, 35, DATEADD(HOUR, 20, DATEADD(DAY, -58, GETDATE())))),
(1215, 1215, 'seepay', 'SP-MEGA-1215', 600000, 'refunded', DATEADD(MINUTE, 22, DATEADD(HOUR, 19, DATEADD(DAY, -52, GETDATE())))),
(1216, 1216, 'seepay', 'SP-MEGA-1216', 150000, 'completed', DATEADD(MINUTE, 1, DATEADD(HOUR, 14, DATEADD(DAY, -54, GETDATE())))),
(1217, 1217, 'seepay', 'SP-MEGA-1217', 450000, 'refunded', DATEADD(MINUTE, 6, DATEADD(HOUR, 5, DATEADD(DAY, -26, GETDATE())))),
(1218, 1218, 'seepay', 'SP-MEGA-1218', 600000, 'pending', NULL),
(1219, 1219, 'seepay', 'SP-MEGA-1219', 150000, 'completed', DATEADD(MINUTE, 44, DATEADD(HOUR, 17, DATEADD(DAY, -19, GETDATE())))),
(1220, 1220, 'seepay', 'SP-MEGA-1220', 150000, 'refunded', DATEADD(MINUTE, 22, DATEADD(HOUR, 19, DATEADD(DAY, -51, GETDATE())))),
(1221, 1221, 'seepay', 'SP-MEGA-1221', 800000, 'completed', DATEADD(MINUTE, 42, DATEADD(HOUR, 8, DATEADD(DAY, -46, GETDATE())))),
(1222, 1222, 'seepay', 'SP-MEGA-1222', 1500000, 'completed', DATEADD(MINUTE, 2, DATEADD(HOUR, 6, DATEADD(DAY, -50, GETDATE())))),
(1223, 1223, 'seepay', 'SP-MEGA-1223', 500000, 'completed', DATEADD(MINUTE, 36, DATEADD(HOUR, 11, DATEADD(DAY, -3, GETDATE())))),
(1224, 1224, 'seepay', 'SP-MEGA-1224', 600000, 'cancelled', NULL),
(1225, 1225, 'seepay', 'SP-MEGA-1225', 500000, 'completed', DATEADD(MINUTE, 42, DATEADD(HOUR, 13, DATEADD(DAY, -55, GETDATE())))),
(1226, 1226, 'seepay', 'SP-MEGA-1226', 450000, 'completed', DATEADD(MINUTE, 54, DATEADD(HOUR, 5, DATEADD(DAY, -33, GETDATE())))),
(1227, 1227, 'seepay', 'SP-MEGA-1227', 1500000, 'pending', NULL),
(1228, 1228, 'seepay', 'SP-MEGA-1228', 200000, 'cancelled', NULL),
(1229, 1229, 'seepay', 'SP-MEGA-1229', 1000000, 'refunded', DATEADD(MINUTE, 31, DATEADD(HOUR, 8, DATEADD(DAY, -57, GETDATE())))),
(1230, 1230, 'seepay', 'SP-MEGA-1230', 1500000, 'cancelled', NULL),
(1231, 1231, 'seepay', 'SP-MEGA-1231', 300000, 'completed', DATEADD(MINUTE, 22, DATEADD(HOUR, 4, DATEADD(DAY, -40, GETDATE())))),
(1232, 1232, 'seepay', 'SP-MEGA-1232', 1000000, 'refunded', DATEADD(MINUTE, 10, DATEADD(HOUR, 3, DATEADD(DAY, -14, GETDATE())))),
(1233, 1233, 'seepay', 'SP-MEGA-1233', 600000, 'refunded', DATEADD(MINUTE, 55, DATEADD(HOUR, 12, DATEADD(DAY, -38, GETDATE())))),
(1234, 1234, 'seepay', 'SP-MEGA-1234', 600000, 'completed', DATEADD(MINUTE, 13, DATEADD(HOUR, 22, DATEADD(DAY, -55, GETDATE())))),
(1235, 1235, 'seepay', 'SP-MEGA-1235', 450000, 'cancelled', NULL),
(1236, 1236, 'seepay', 'SP-MEGA-1236', 450000, 'cancelled', NULL),
(1237, 1237, 'seepay', 'SP-MEGA-1237', 450000, 'completed', DATEADD(MINUTE, 33, DATEADD(HOUR, 8, DATEADD(DAY, -24, GETDATE())))),
(1238, 1238, 'seepay', 'SP-MEGA-1238', 600000, 'completed', DATEADD(MINUTE, 18, DATEADD(HOUR, 8, DATEADD(DAY, -6, GETDATE())))),
(1239, 1239, 'seepay', 'SP-MEGA-1239', 600000, 'completed', DATEADD(MINUTE, 27, DATEADD(HOUR, 13, DATEADD(DAY, -57, GETDATE())))),
(1240, 1240, 'seepay', 'SP-MEGA-1240', 450000, 'pending', NULL),
(1241, 1241, 'seepay', 'SP-MEGA-1241', 600000, 'pending', NULL),
(1242, 1242, 'seepay', 'SP-MEGA-1242', 450000, 'completed', DATEADD(MINUTE, 16, DATEADD(HOUR, 7, DATEADD(DAY, -1, GETDATE())))),
(1243, 1243, 'seepay', 'SP-MEGA-1243', 1000000, 'refunded', DATEADD(MINUTE, 5, DATEADD(HOUR, 4, DATEADD(DAY, -57, GETDATE())))),
(1244, 1244, 'seepay', 'SP-MEGA-1244', 600000, 'completed', DATEADD(MINUTE, 30, DATEADD(HOUR, 10, DATEADD(DAY, -49, GETDATE())))),
(1245, 1245, 'seepay', 'SP-MEGA-1245', 1000000, 'pending', NULL),
(1246, 1246, 'seepay', 'SP-MEGA-1246', 1000000, 'cancelled', NULL),
(1247, 1247, 'seepay', 'SP-MEGA-1247', 600000, 'cancelled', NULL),
(1248, 1248, 'seepay', 'SP-MEGA-1248', 450000, 'completed', DATEADD(MINUTE, 52, DATEADD(HOUR, 22, DATEADD(DAY, -38, GETDATE())))),
(1249, 1249, 'seepay', 'SP-MEGA-1249', 600000, 'completed', DATEADD(MINUTE, 50, DATEADD(HOUR, 0, DATEADD(DAY, -25, GETDATE())))),
(1250, 1250, 'seepay', 'SP-MEGA-1250', 500000, 'completed', DATEADD(MINUTE, 9, DATEADD(HOUR, 19, DATEADD(DAY, -52, GETDATE())))),
(1251, 1251, 'seepay', 'SP-MEGA-1251', 400000, 'pending', NULL),
(1252, 1252, 'seepay', 'SP-MEGA-1252', 600000, 'refunded', DATEADD(MINUTE, 21, DATEADD(HOUR, 13, DATEADD(DAY, -58, GETDATE())))),
(1253, 1253, 'seepay', 'SP-MEGA-1253', 200000, 'pending', NULL),
(1254, 1254, 'seepay', 'SP-MEGA-1254', 150000, 'completed', DATEADD(MINUTE, 59, DATEADD(HOUR, 14, DATEADD(DAY, -52, GETDATE())))),
(1255, 1255, 'seepay', 'SP-MEGA-1255', 2000000, 'completed', DATEADD(MINUTE, 30, DATEADD(HOUR, 20, DATEADD(DAY, -41, GETDATE())))),
(1256, 1256, 'seepay', 'SP-MEGA-1256', 600000, 'completed', DATEADD(MINUTE, 8, DATEADD(HOUR, 17, DATEADD(DAY, -24, GETDATE())))),
(1257, 1257, 'seepay', 'SP-MEGA-1257', 1500000, 'refunded', DATEADD(MINUTE, 3, DATEADD(HOUR, 23, DATEADD(DAY, -31, GETDATE())))),
(1258, 1258, 'seepay', 'SP-MEGA-1258', 1000000, 'refunded', DATEADD(MINUTE, 16, DATEADD(HOUR, 2, DATEADD(DAY, -44, GETDATE())))),
(1259, 1259, 'seepay', 'SP-MEGA-1259', 1500000, 'cancelled', NULL),
(1260, 1260, 'seepay', 'SP-MEGA-1260', 150000, 'completed', DATEADD(MINUTE, 59, DATEADD(HOUR, 22, DATEADD(DAY, -15, GETDATE())))),
(1261, 1261, 'seepay', 'SP-MEGA-1261', 600000, 'pending', NULL),
(1262, 1262, 'seepay', 'SP-MEGA-1262', 300000, 'completed', DATEADD(MINUTE, 31, DATEADD(HOUR, 23, DATEADD(DAY, -60, GETDATE())))),
(1263, 1263, 'seepay', 'SP-MEGA-1263', 450000, 'completed', DATEADD(MINUTE, 20, DATEADD(HOUR, 3, DATEADD(DAY, -11, GETDATE())))),
(1264, 1264, 'seepay', 'SP-MEGA-1264', 200000, 'completed', DATEADD(MINUTE, 9, DATEADD(HOUR, 20, DATEADD(DAY, -8, GETDATE())))),
(1265, 1265, 'seepay', 'SP-MEGA-1265', 500000, 'cancelled', NULL),
(1266, 1266, 'seepay', 'SP-MEGA-1266', 600000, 'cancelled', NULL),
(1267, 1267, 'seepay', 'SP-MEGA-1267', 800000, 'completed', DATEADD(MINUTE, 3, DATEADD(HOUR, 12, DATEADD(DAY, -36, GETDATE())))),
(1268, 1268, 'seepay', 'SP-MEGA-1268', 600000, 'completed', DATEADD(MINUTE, 1, DATEADD(HOUR, 8, DATEADD(DAY, -48, GETDATE())))),
(1269, 1269, 'seepay', 'SP-MEGA-1269', 1500000, 'pending', NULL),
(1270, 1270, 'seepay', 'SP-MEGA-1270', 1000000, 'completed', DATEADD(MINUTE, 55, DATEADD(HOUR, 21, DATEADD(DAY, -23, GETDATE())))),
(1271, 1271, 'seepay', 'SP-MEGA-1271', 1000000, 'refunded', DATEADD(MINUTE, 1, DATEADD(HOUR, 14, DATEADD(DAY, -55, GETDATE())))),
(1272, 1272, 'seepay', 'SP-MEGA-1272', 200000, 'completed', DATEADD(MINUTE, 32, DATEADD(HOUR, 17, DATEADD(DAY, -7, GETDATE())))),
(1273, 1273, 'seepay', 'SP-MEGA-1273', 800000, 'pending', NULL),
(1274, 1274, 'seepay', 'SP-MEGA-1274', 300000, 'pending', NULL),
(1275, 1275, 'seepay', 'SP-MEGA-1275', 400000, 'cancelled', NULL),
(1276, 1276, 'seepay', 'SP-MEGA-1276', 600000, 'pending', NULL),
(1277, 1277, 'seepay', 'SP-MEGA-1277', 300000, 'completed', DATEADD(MINUTE, 16, DATEADD(HOUR, 4, DATEADD(DAY, -33, GETDATE())))),
(1278, 1278, 'seepay', 'SP-MEGA-1278', 1000000, 'cancelled', NULL),
(1279, 1279, 'seepay', 'SP-MEGA-1279', 800000, 'completed', DATEADD(MINUTE, 58, DATEADD(HOUR, 16, DATEADD(DAY, -32, GETDATE())))),
(1280, 1280, 'seepay', 'SP-MEGA-1280', 450000, 'completed', DATEADD(MINUTE, 2, DATEADD(HOUR, 22, DATEADD(DAY, -52, GETDATE())))),
(1281, 1281, 'seepay', 'SP-MEGA-1281', 300000, 'completed', DATEADD(MINUTE, 14, DATEADD(HOUR, 7, DATEADD(DAY, -35, GETDATE())))),
(1282, 1282, 'seepay', 'SP-MEGA-1282', 800000, 'refunded', DATEADD(MINUTE, 10, DATEADD(HOUR, 14, DATEADD(DAY, -41, GETDATE())))),
(1283, 1283, 'seepay', 'SP-MEGA-1283', 450000, 'cancelled', NULL),
(1284, 1284, 'seepay', 'SP-MEGA-1284', 450000, 'cancelled', NULL),
(1285, 1285, 'seepay', 'SP-MEGA-1285', 600000, 'cancelled', NULL),
(1286, 1286, 'seepay', 'SP-MEGA-1286', 300000, 'completed', DATEADD(MINUTE, 53, DATEADD(HOUR, 20, DATEADD(DAY, -16, GETDATE())))),
(1287, 1287, 'seepay', 'SP-MEGA-1287', 600000, 'completed', DATEADD(MINUTE, 56, DATEADD(HOUR, 22, DATEADD(DAY, -12, GETDATE())))),
(1288, 1288, 'seepay', 'SP-MEGA-1288', 450000, 'completed', DATEADD(MINUTE, 41, DATEADD(HOUR, 2, DATEADD(DAY, -49, GETDATE())))),
(1289, 1289, 'seepay', 'SP-MEGA-1289', 500000, 'completed', DATEADD(MINUTE, 42, DATEADD(HOUR, 15, DATEADD(DAY, -40, GETDATE())))),
(1290, 1290, 'seepay', 'SP-MEGA-1290', 450000, 'completed', DATEADD(MINUTE, 20, DATEADD(HOUR, 13, DATEADD(DAY, -36, GETDATE())))),
(1291, 1291, 'seepay', 'SP-MEGA-1291', 2000000, 'cancelled', NULL),
(1292, 1292, 'seepay', 'SP-MEGA-1292', 300000, 'pending', NULL),
(1293, 1293, 'seepay', 'SP-MEGA-1293', 1000000, 'cancelled', NULL),
(1294, 1294, 'seepay', 'SP-MEGA-1294', 150000, 'cancelled', NULL),
(1295, 1295, 'seepay', 'SP-MEGA-1295', 800000, 'pending', NULL),
(1296, 1296, 'seepay', 'SP-MEGA-1296', 300000, 'completed', DATEADD(MINUTE, 55, DATEADD(HOUR, 8, DATEADD(DAY, -2, GETDATE())))),
(1297, 1297, 'seepay', 'SP-MEGA-1297', 1000000, 'completed', DATEADD(MINUTE, 9, DATEADD(HOUR, 17, DATEADD(DAY, -46, GETDATE())))),
(1298, 1298, 'seepay', 'SP-MEGA-1298', 1000000, 'pending', NULL),
(1299, 1299, 'seepay', 'SP-MEGA-1299', 300000, 'completed', DATEADD(MINUTE, 41, DATEADD(HOUR, 23, DATEADD(DAY, -22, GETDATE()))));
INSERT INTO PaymentTransactions (transaction_id, order_id, payment_method, seepay_transaction_id, amount, status, completed_at) VALUES
(1300, 1300, 'seepay', 'SP-MEGA-1300', 400000, 'cancelled', NULL),
(1301, 1301, 'seepay', 'SP-MEGA-1301', 2000000, 'completed', DATEADD(MINUTE, 22, DATEADD(HOUR, 23, DATEADD(DAY, -7, GETDATE())))),
(1302, 1302, 'seepay', 'SP-MEGA-1302', 150000, 'cancelled', NULL),
(1303, 1303, 'seepay', 'SP-MEGA-1303', 600000, 'completed', DATEADD(MINUTE, 28, DATEADD(HOUR, 21, DATEADD(DAY, -34, GETDATE())))),
(1304, 1304, 'seepay', 'SP-MEGA-1304', 600000, 'completed', DATEADD(MINUTE, 37, DATEADD(HOUR, 0, DATEADD(DAY, -60, GETDATE())))),
(1305, 1305, 'seepay', 'SP-MEGA-1305', 400000, 'completed', DATEADD(MINUTE, 53, DATEADD(HOUR, 14, DATEADD(DAY, -28, GETDATE())))),
(1306, 1306, 'seepay', 'SP-MEGA-1306', 2000000, 'completed', DATEADD(MINUTE, 39, DATEADD(HOUR, 21, DATEADD(DAY, -21, GETDATE())))),
(1307, 1307, 'seepay', 'SP-MEGA-1307', 400000, 'refunded', DATEADD(MINUTE, 11, DATEADD(HOUR, 18, DATEADD(DAY, -18, GETDATE())))),
(1308, 1308, 'seepay', 'SP-MEGA-1308', 1500000, 'pending', NULL),
(1309, 1309, 'seepay', 'SP-MEGA-1309', 300000, 'completed', DATEADD(MINUTE, 5, DATEADD(HOUR, 1, DATEADD(DAY, -50, GETDATE())))),
(1310, 1310, 'seepay', 'SP-MEGA-1310', 600000, 'pending', NULL),
(1311, 1311, 'seepay', 'SP-MEGA-1311', 2000000, 'refunded', DATEADD(MINUTE, 10, DATEADD(HOUR, 7, DATEADD(DAY, -44, GETDATE())))),
(1312, 1312, 'seepay', 'SP-MEGA-1312', 200000, 'completed', DATEADD(MINUTE, 8, DATEADD(HOUR, 16, DATEADD(DAY, -28, GETDATE())))),
(1313, 1313, 'seepay', 'SP-MEGA-1313', 150000, 'completed', DATEADD(MINUTE, 35, DATEADD(HOUR, 11, DATEADD(DAY, -5, GETDATE())))),
(1314, 1314, 'seepay', 'SP-MEGA-1314', 1500000, 'refunded', DATEADD(MINUTE, 11, DATEADD(HOUR, 22, DATEADD(DAY, -35, GETDATE())))),
(1315, 1315, 'seepay', 'SP-MEGA-1315', 1500000, 'completed', DATEADD(MINUTE, 46, DATEADD(HOUR, 9, DATEADD(DAY, -17, GETDATE())))),
(1316, 1316, 'seepay', 'SP-MEGA-1316', 300000, 'pending', NULL),
(1317, 1317, 'seepay', 'SP-MEGA-1317', 2000000, 'pending', NULL),
(1318, 1318, 'seepay', 'SP-MEGA-1318', 1500000, 'completed', DATEADD(MINUTE, 33, DATEADD(HOUR, 9, DATEADD(DAY, -10, GETDATE())))),
(1319, 1319, 'seepay', 'SP-MEGA-1319', 400000, 'cancelled', NULL),
(1320, 1320, 'seepay', 'SP-MEGA-1320', 600000, 'cancelled', NULL),
(1321, 1321, 'seepay', 'SP-MEGA-1321', 150000, 'cancelled', NULL),
(1322, 1322, 'seepay', 'SP-MEGA-1322', 450000, 'cancelled', NULL),
(1323, 1323, 'seepay', 'SP-MEGA-1323', 1500000, 'cancelled', NULL),
(1324, 1324, 'seepay', 'SP-MEGA-1324', 400000, 'completed', DATEADD(MINUTE, 19, DATEADD(HOUR, 4, DATEADD(DAY, -59, GETDATE())))),
(1325, 1325, 'seepay', 'SP-MEGA-1325', 600000, 'completed', DATEADD(MINUTE, 27, DATEADD(HOUR, 13, DATEADD(DAY, -58, GETDATE())))),
(1326, 1326, 'seepay', 'SP-MEGA-1326', 450000, 'completed', DATEADD(MINUTE, 26, DATEADD(HOUR, 17, DATEADD(DAY, -25, GETDATE())))),
(1327, 1327, 'seepay', 'SP-MEGA-1327', 300000, 'completed', DATEADD(MINUTE, 56, DATEADD(HOUR, 15, DATEADD(DAY, -3, GETDATE())))),
(1328, 1328, 'seepay', 'SP-MEGA-1328', 1000000, 'refunded', DATEADD(MINUTE, 30, DATEADD(HOUR, 18, DATEADD(DAY, -36, GETDATE())))),
(1329, 1329, 'seepay', 'SP-MEGA-1329', 450000, 'cancelled', NULL),
(1330, 1330, 'seepay', 'SP-MEGA-1330', 800000, 'pending', NULL),
(1331, 1331, 'seepay', 'SP-MEGA-1331', 600000, 'refunded', DATEADD(MINUTE, 41, DATEADD(HOUR, 16, DATEADD(DAY, -3, GETDATE())))),
(1332, 1332, 'seepay', 'SP-MEGA-1332', 800000, 'cancelled', NULL),
(1333, 1333, 'seepay', 'SP-MEGA-1333', 450000, 'completed', DATEADD(MINUTE, 56, DATEADD(HOUR, 2, DATEADD(DAY, -54, GETDATE())))),
(1334, 1334, 'seepay', 'SP-MEGA-1334', 400000, 'pending', NULL),
(1335, 1335, 'seepay', 'SP-MEGA-1335', 400000, 'refunded', DATEADD(MINUTE, 20, DATEADD(HOUR, 10, DATEADD(DAY, -36, GETDATE())))),
(1336, 1336, 'seepay', 'SP-MEGA-1336', 1500000, 'completed', DATEADD(MINUTE, 4, DATEADD(HOUR, 12, DATEADD(DAY, -8, GETDATE())))),
(1337, 1337, 'seepay', 'SP-MEGA-1337', 450000, 'cancelled', NULL),
(1338, 1338, 'seepay', 'SP-MEGA-1338', 200000, 'cancelled', NULL),
(1339, 1339, 'seepay', 'SP-MEGA-1339', 450000, 'refunded', DATEADD(MINUTE, 58, DATEADD(HOUR, 0, DATEADD(DAY, -27, GETDATE())))),
(1340, 1340, 'seepay', 'SP-MEGA-1340', 600000, 'completed', DATEADD(MINUTE, 12, DATEADD(HOUR, 23, DATEADD(DAY, -60, GETDATE())))),
(1341, 1341, 'seepay', 'SP-MEGA-1341', 200000, 'completed', DATEADD(MINUTE, 6, DATEADD(HOUR, 13, DATEADD(DAY, -37, GETDATE())))),
(1342, 1342, 'seepay', 'SP-MEGA-1342', 300000, 'refunded', DATEADD(MINUTE, 48, DATEADD(HOUR, 13, DATEADD(DAY, -19, GETDATE())))),
(1343, 1343, 'seepay', 'SP-MEGA-1343', 600000, 'completed', DATEADD(MINUTE, 42, DATEADD(HOUR, 10, DATEADD(DAY, -18, GETDATE())))),
(1344, 1344, 'seepay', 'SP-MEGA-1344', 2000000, 'refunded', DATEADD(MINUTE, 31, DATEADD(HOUR, 3, DATEADD(DAY, -32, GETDATE())))),
(1345, 1345, 'seepay', 'SP-MEGA-1345', 2000000, 'completed', DATEADD(MINUTE, 52, DATEADD(HOUR, 4, DATEADD(DAY, -55, GETDATE())))),
(1346, 1346, 'seepay', 'SP-MEGA-1346', 450000, 'refunded', DATEADD(MINUTE, 0, DATEADD(HOUR, 5, DATEADD(DAY, -1, GETDATE())))),
(1347, 1347, 'seepay', 'SP-MEGA-1347', 2000000, 'completed', DATEADD(MINUTE, 29, DATEADD(HOUR, 16, DATEADD(DAY, -29, GETDATE())))),
(1348, 1348, 'seepay', 'SP-MEGA-1348', 300000, 'completed', DATEADD(MINUTE, 10, DATEADD(HOUR, 15, DATEADD(DAY, -36, GETDATE())))),
(1349, 1349, 'seepay', 'SP-MEGA-1349', 400000, 'refunded', DATEADD(MINUTE, 23, DATEADD(HOUR, 18, DATEADD(DAY, -23, GETDATE())))),
(1350, 1350, 'seepay', 'SP-MEGA-1350', 600000, 'cancelled', NULL),
(1351, 1351, 'seepay', 'SP-MEGA-1351', 150000, 'cancelled', NULL),
(1352, 1352, 'seepay', 'SP-MEGA-1352', 450000, 'pending', NULL),
(1353, 1353, 'seepay', 'SP-MEGA-1353', 600000, 'pending', NULL),
(1354, 1354, 'seepay', 'SP-MEGA-1354', 600000, 'refunded', DATEADD(MINUTE, 43, DATEADD(HOUR, 18, DATEADD(DAY, -1, GETDATE())))),
(1355, 1355, 'seepay', 'SP-MEGA-1355', 600000, 'completed', DATEADD(MINUTE, 48, DATEADD(HOUR, 10, DATEADD(DAY, -39, GETDATE())))),
(1356, 1356, 'seepay', 'SP-MEGA-1356', 1500000, 'cancelled', NULL),
(1357, 1357, 'seepay', 'SP-MEGA-1357', 800000, 'completed', DATEADD(MINUTE, 3, DATEADD(HOUR, 22, DATEADD(DAY, -53, GETDATE())))),
(1358, 1358, 'seepay', 'SP-MEGA-1358', 500000, 'completed', DATEADD(MINUTE, 29, DATEADD(HOUR, 21, DATEADD(DAY, -6, GETDATE())))),
(1359, 1359, 'seepay', 'SP-MEGA-1359', 450000, 'pending', NULL),
(1360, 1360, 'seepay', 'SP-MEGA-1360', 500000, 'completed', DATEADD(MINUTE, 9, DATEADD(HOUR, 16, DATEADD(DAY, -16, GETDATE())))),
(1361, 1361, 'seepay', 'SP-MEGA-1361', 800000, 'completed', DATEADD(MINUTE, 8, DATEADD(HOUR, 8, DATEADD(DAY, -13, GETDATE())))),
(1362, 1362, 'seepay', 'SP-MEGA-1362', 800000, 'completed', DATEADD(MINUTE, 6, DATEADD(HOUR, 13, DATEADD(DAY, 0, GETDATE())))),
(1363, 1363, 'seepay', 'SP-MEGA-1363', 1000000, 'pending', NULL),
(1364, 1364, 'seepay', 'SP-MEGA-1364', 800000, 'pending', NULL),
(1365, 1365, 'seepay', 'SP-MEGA-1365', 400000, 'completed', DATEADD(MINUTE, 43, DATEADD(HOUR, 11, DATEADD(DAY, -2, GETDATE())))),
(1366, 1366, 'seepay', 'SP-MEGA-1366', 600000, 'refunded', DATEADD(MINUTE, 20, DATEADD(HOUR, 13, DATEADD(DAY, -9, GETDATE())))),
(1367, 1367, 'seepay', 'SP-MEGA-1367', 600000, 'completed', DATEADD(MINUTE, 6, DATEADD(HOUR, 22, DATEADD(DAY, -31, GETDATE())))),
(1368, 1368, 'seepay', 'SP-MEGA-1368', 1500000, 'refunded', DATEADD(MINUTE, 50, DATEADD(HOUR, 12, DATEADD(DAY, -30, GETDATE())))),
(1369, 1369, 'seepay', 'SP-MEGA-1369', 600000, 'cancelled', NULL),
(1370, 1370, 'seepay', 'SP-MEGA-1370', 800000, 'cancelled', NULL),
(1371, 1371, 'seepay', 'SP-MEGA-1371', 150000, 'completed', DATEADD(MINUTE, 8, DATEADD(HOUR, 4, DATEADD(DAY, -41, GETDATE())))),
(1372, 1372, 'seepay', 'SP-MEGA-1372', 1000000, 'pending', NULL),
(1373, 1373, 'seepay', 'SP-MEGA-1373', 500000, 'refunded', DATEADD(MINUTE, 54, DATEADD(HOUR, 14, DATEADD(DAY, -51, GETDATE())))),
(1374, 1374, 'seepay', 'SP-MEGA-1374', 600000, 'pending', NULL),
(1375, 1375, 'seepay', 'SP-MEGA-1375', 200000, 'cancelled', NULL),
(1376, 1376, 'seepay', 'SP-MEGA-1376', 1500000, 'pending', NULL),
(1377, 1377, 'seepay', 'SP-MEGA-1377', 200000, 'cancelled', NULL),
(1378, 1378, 'seepay', 'SP-MEGA-1378', 1000000, 'pending', NULL),
(1379, 1379, 'seepay', 'SP-MEGA-1379', 1000000, 'cancelled', NULL),
(1380, 1380, 'seepay', 'SP-MEGA-1380', 400000, 'refunded', DATEADD(MINUTE, 43, DATEADD(HOUR, 19, DATEADD(DAY, -57, GETDATE())))),
(1381, 1381, 'seepay', 'SP-MEGA-1381', 2000000, 'completed', DATEADD(MINUTE, 36, DATEADD(HOUR, 15, DATEADD(DAY, -4, GETDATE())))),
(1382, 1382, 'seepay', 'SP-MEGA-1382', 1500000, 'completed', DATEADD(MINUTE, 26, DATEADD(HOUR, 11, DATEADD(DAY, -35, GETDATE())))),
(1383, 1383, 'seepay', 'SP-MEGA-1383', 600000, 'completed', DATEADD(MINUTE, 15, DATEADD(HOUR, 16, DATEADD(DAY, -53, GETDATE())))),
(1384, 1384, 'seepay', 'SP-MEGA-1384', 800000, 'completed', DATEADD(MINUTE, 35, DATEADD(HOUR, 5, DATEADD(DAY, -15, GETDATE())))),
(1385, 1385, 'seepay', 'SP-MEGA-1385', 450000, 'completed', DATEADD(MINUTE, 56, DATEADD(HOUR, 18, DATEADD(DAY, -60, GETDATE())))),
(1386, 1386, 'seepay', 'SP-MEGA-1386', 300000, 'completed', DATEADD(MINUTE, 44, DATEADD(HOUR, 9, DATEADD(DAY, -32, GETDATE())))),
(1387, 1387, 'seepay', 'SP-MEGA-1387', 450000, 'completed', DATEADD(MINUTE, 59, DATEADD(HOUR, 4, DATEADD(DAY, -39, GETDATE())))),
(1388, 1388, 'seepay', 'SP-MEGA-1388', 800000, 'completed', DATEADD(MINUTE, 17, DATEADD(HOUR, 11, DATEADD(DAY, -9, GETDATE())))),
(1389, 1389, 'seepay', 'SP-MEGA-1389', 300000, 'pending', NULL),
(1390, 1390, 'seepay', 'SP-MEGA-1390', 200000, 'completed', DATEADD(MINUTE, 3, DATEADD(HOUR, 4, DATEADD(DAY, -49, GETDATE())))),
(1391, 1391, 'seepay', 'SP-MEGA-1391', 150000, 'refunded', DATEADD(MINUTE, 25, DATEADD(HOUR, 22, DATEADD(DAY, -50, GETDATE())))),
(1392, 1392, 'seepay', 'SP-MEGA-1392', 150000, 'completed', DATEADD(MINUTE, 13, DATEADD(HOUR, 22, DATEADD(DAY, -31, GETDATE())))),
(1393, 1393, 'seepay', 'SP-MEGA-1393', 600000, 'completed', DATEADD(MINUTE, 6, DATEADD(HOUR, 4, DATEADD(DAY, -39, GETDATE())))),
(1394, 1394, 'seepay', 'SP-MEGA-1394', 450000, 'completed', DATEADD(MINUTE, 25, DATEADD(HOUR, 11, DATEADD(DAY, -56, GETDATE())))),
(1395, 1395, 'seepay', 'SP-MEGA-1395', 800000, 'completed', DATEADD(MINUTE, 38, DATEADD(HOUR, 20, DATEADD(DAY, -45, GETDATE())))),
(1396, 1396, 'seepay', 'SP-MEGA-1396', 500000, 'completed', DATEADD(MINUTE, 23, DATEADD(HOUR, 1, DATEADD(DAY, -24, GETDATE())))),
(1397, 1397, 'seepay', 'SP-MEGA-1397', 200000, 'pending', NULL),
(1398, 1398, 'seepay', 'SP-MEGA-1398', 450000, 'completed', DATEADD(MINUTE, 5, DATEADD(HOUR, 2, DATEADD(DAY, -32, GETDATE())))),
(1399, 1399, 'seepay', 'SP-MEGA-1399', 600000, 'pending', NULL);
INSERT INTO PaymentTransactions (transaction_id, order_id, payment_method, seepay_transaction_id, amount, status, completed_at) VALUES
(1400, 1400, 'seepay', 'SP-MEGA-1400', 300000, 'completed', DATEADD(MINUTE, 9, DATEADD(HOUR, 20, DATEADD(DAY, -35, GETDATE())))),
(1401, 1401, 'seepay', 'SP-MEGA-1401', 800000, 'completed', DATEADD(MINUTE, 10, DATEADD(HOUR, 18, DATEADD(DAY, -35, GETDATE())))),
(1402, 1402, 'seepay', 'SP-MEGA-1402', 500000, 'completed', DATEADD(MINUTE, 34, DATEADD(HOUR, 8, DATEADD(DAY, -16, GETDATE())))),
(1403, 1403, 'seepay', 'SP-MEGA-1403', 200000, 'completed', DATEADD(MINUTE, 36, DATEADD(HOUR, 0, DATEADD(DAY, -12, GETDATE())))),
(1404, 1404, 'seepay', 'SP-MEGA-1404', 600000, 'cancelled', NULL),
(1405, 1405, 'seepay', 'SP-MEGA-1405', 450000, 'completed', DATEADD(MINUTE, 54, DATEADD(HOUR, 20, DATEADD(DAY, -39, GETDATE())))),
(1406, 1406, 'seepay', 'SP-MEGA-1406', 600000, 'completed', DATEADD(MINUTE, 49, DATEADD(HOUR, 22, DATEADD(DAY, -1, GETDATE())))),
(1407, 1407, 'seepay', 'SP-MEGA-1407', 1500000, 'completed', DATEADD(MINUTE, 39, DATEADD(HOUR, 12, DATEADD(DAY, -54, GETDATE())))),
(1408, 1408, 'seepay', 'SP-MEGA-1408', 150000, 'completed', DATEADD(MINUTE, 10, DATEADD(HOUR, 0, DATEADD(DAY, -53, GETDATE())))),
(1409, 1409, 'seepay', 'SP-MEGA-1409', 600000, 'refunded', DATEADD(MINUTE, 37, DATEADD(HOUR, 23, DATEADD(DAY, -12, GETDATE())))),
(1410, 1410, 'seepay', 'SP-MEGA-1410', 150000, 'completed', DATEADD(MINUTE, 21, DATEADD(HOUR, 13, DATEADD(DAY, -18, GETDATE())))),
(1411, 1411, 'seepay', 'SP-MEGA-1411', 150000, 'pending', NULL),
(1412, 1412, 'seepay', 'SP-MEGA-1412', 500000, 'completed', DATEADD(MINUTE, 33, DATEADD(HOUR, 1, DATEADD(DAY, -58, GETDATE())))),
(1413, 1413, 'seepay', 'SP-MEGA-1413', 1500000, 'refunded', DATEADD(MINUTE, 15, DATEADD(HOUR, 12, DATEADD(DAY, -35, GETDATE())))),
(1414, 1414, 'seepay', 'SP-MEGA-1414', 150000, 'refunded', DATEADD(MINUTE, 36, DATEADD(HOUR, 16, DATEADD(DAY, -30, GETDATE())))),
(1415, 1415, 'seepay', 'SP-MEGA-1415', 500000, 'completed', DATEADD(MINUTE, 53, DATEADD(HOUR, 19, DATEADD(DAY, -43, GETDATE())))),
(1416, 1416, 'seepay', 'SP-MEGA-1416', 800000, 'completed', DATEADD(MINUTE, 50, DATEADD(HOUR, 15, DATEADD(DAY, -60, GETDATE())))),
(1417, 1417, 'seepay', 'SP-MEGA-1417', 1500000, 'completed', DATEADD(MINUTE, 58, DATEADD(HOUR, 21, DATEADD(DAY, -17, GETDATE())))),
(1418, 1418, 'seepay', 'SP-MEGA-1418', 400000, 'completed', DATEADD(MINUTE, 27, DATEADD(HOUR, 19, DATEADD(DAY, -53, GETDATE())))),
(1419, 1419, 'seepay', 'SP-MEGA-1419', 1000000, 'completed', DATEADD(MINUTE, 18, DATEADD(HOUR, 21, DATEADD(DAY, -1, GETDATE())))),
(1420, 1420, 'seepay', 'SP-MEGA-1420', 450000, 'completed', DATEADD(MINUTE, 7, DATEADD(HOUR, 22, DATEADD(DAY, -7, GETDATE())))),
(1421, 1421, 'seepay', 'SP-MEGA-1421', 200000, 'pending', NULL),
(1422, 1422, 'seepay', 'SP-MEGA-1422', 400000, 'cancelled', NULL),
(1423, 1423, 'seepay', 'SP-MEGA-1423', 300000, 'cancelled', NULL),
(1424, 1424, 'seepay', 'SP-MEGA-1424', 1000000, 'completed', DATEADD(MINUTE, 44, DATEADD(HOUR, 10, DATEADD(DAY, -43, GETDATE())))),
(1425, 1425, 'seepay', 'SP-MEGA-1425', 800000, 'refunded', DATEADD(MINUTE, 26, DATEADD(HOUR, 3, DATEADD(DAY, -5, GETDATE())))),
(1426, 1426, 'seepay', 'SP-MEGA-1426', 600000, 'completed', DATEADD(MINUTE, 25, DATEADD(HOUR, 18, DATEADD(DAY, -32, GETDATE())))),
(1427, 1427, 'seepay', 'SP-MEGA-1427', 450000, 'refunded', DATEADD(MINUTE, 7, DATEADD(HOUR, 18, DATEADD(DAY, -56, GETDATE())))),
(1428, 1428, 'seepay', 'SP-MEGA-1428', 600000, 'cancelled', NULL),
(1429, 1429, 'seepay', 'SP-MEGA-1429', 300000, 'refunded', DATEADD(MINUTE, 9, DATEADD(HOUR, 22, DATEADD(DAY, -8, GETDATE())))),
(1430, 1430, 'seepay', 'SP-MEGA-1430', 150000, 'completed', DATEADD(MINUTE, 1, DATEADD(HOUR, 4, DATEADD(DAY, -27, GETDATE())))),
(1431, 1431, 'seepay', 'SP-MEGA-1431', 500000, 'completed', DATEADD(MINUTE, 6, DATEADD(HOUR, 3, DATEADD(DAY, -48, GETDATE())))),
(1432, 1432, 'seepay', 'SP-MEGA-1432', 600000, 'cancelled', NULL),
(1433, 1433, 'seepay', 'SP-MEGA-1433', 500000, 'pending', NULL),
(1434, 1434, 'seepay', 'SP-MEGA-1434', 1500000, 'refunded', DATEADD(MINUTE, 40, DATEADD(HOUR, 4, DATEADD(DAY, -5, GETDATE())))),
(1435, 1435, 'seepay', 'SP-MEGA-1435', 600000, 'completed', DATEADD(MINUTE, 29, DATEADD(HOUR, 5, DATEADD(DAY, -41, GETDATE())))),
(1436, 1436, 'seepay', 'SP-MEGA-1436', 800000, 'refunded', DATEADD(MINUTE, 37, DATEADD(HOUR, 14, DATEADD(DAY, -27, GETDATE())))),
(1437, 1437, 'seepay', 'SP-MEGA-1437', 2000000, 'pending', NULL),
(1438, 1438, 'seepay', 'SP-MEGA-1438', 1500000, 'completed', DATEADD(MINUTE, 42, DATEADD(HOUR, 15, DATEADD(DAY, 0, GETDATE())))),
(1439, 1439, 'seepay', 'SP-MEGA-1439', 200000, 'completed', DATEADD(MINUTE, 11, DATEADD(HOUR, 16, DATEADD(DAY, -10, GETDATE())))),
(1440, 1440, 'seepay', 'SP-MEGA-1440', 600000, 'pending', NULL),
(1441, 1441, 'seepay', 'SP-MEGA-1441', 200000, 'refunded', DATEADD(MINUTE, 21, DATEADD(HOUR, 13, DATEADD(DAY, -25, GETDATE())))),
(1442, 1442, 'seepay', 'SP-MEGA-1442', 500000, 'pending', NULL),
(1443, 1443, 'seepay', 'SP-MEGA-1443', 500000, 'pending', NULL),
(1444, 1444, 'seepay', 'SP-MEGA-1444', 450000, 'cancelled', NULL),
(1445, 1445, 'seepay', 'SP-MEGA-1445', 200000, 'cancelled', NULL),
(1446, 1446, 'seepay', 'SP-MEGA-1446', 800000, 'completed', DATEADD(MINUTE, 57, DATEADD(HOUR, 12, DATEADD(DAY, -4, GETDATE())))),
(1447, 1447, 'seepay', 'SP-MEGA-1447', 500000, 'completed', DATEADD(MINUTE, 59, DATEADD(HOUR, 6, DATEADD(DAY, -27, GETDATE())))),
(1448, 1448, 'seepay', 'SP-MEGA-1448', 1500000, 'completed', DATEADD(MINUTE, 39, DATEADD(HOUR, 15, DATEADD(DAY, -51, GETDATE())))),
(1449, 1449, 'seepay', 'SP-MEGA-1449', 600000, 'refunded', DATEADD(MINUTE, 54, DATEADD(HOUR, 12, DATEADD(DAY, 0, GETDATE())))),
(1450, 1450, 'seepay', 'SP-MEGA-1450', 1000000, 'cancelled', NULL),
(1451, 1451, 'seepay', 'SP-MEGA-1451', 800000, 'refunded', DATEADD(MINUTE, 49, DATEADD(HOUR, 1, DATEADD(DAY, -3, GETDATE())))),
(1452, 1452, 'seepay', 'SP-MEGA-1452', 2000000, 'cancelled', NULL),
(1453, 1453, 'seepay', 'SP-MEGA-1453', 150000, 'completed', DATEADD(MINUTE, 48, DATEADD(HOUR, 12, DATEADD(DAY, -16, GETDATE())))),
(1454, 1454, 'seepay', 'SP-MEGA-1454', 150000, 'completed', DATEADD(MINUTE, 3, DATEADD(HOUR, 12, DATEADD(DAY, -9, GETDATE())))),
(1455, 1455, 'seepay', 'SP-MEGA-1455', 1500000, 'refunded', DATEADD(MINUTE, 57, DATEADD(HOUR, 20, DATEADD(DAY, -10, GETDATE())))),
(1456, 1456, 'seepay', 'SP-MEGA-1456', 400000, 'completed', DATEADD(MINUTE, 17, DATEADD(HOUR, 20, DATEADD(DAY, -46, GETDATE())))),
(1457, 1457, 'seepay', 'SP-MEGA-1457', 2000000, 'completed', DATEADD(MINUTE, 28, DATEADD(HOUR, 0, DATEADD(DAY, -37, GETDATE())))),
(1458, 1458, 'seepay', 'SP-MEGA-1458', 200000, 'pending', NULL),
(1459, 1459, 'seepay', 'SP-MEGA-1459', 450000, 'cancelled', NULL),
(1460, 1460, 'seepay', 'SP-MEGA-1460', 400000, 'completed', DATEADD(MINUTE, 28, DATEADD(HOUR, 12, DATEADD(DAY, -57, GETDATE())))),
(1461, 1461, 'seepay', 'SP-MEGA-1461', 500000, 'cancelled', NULL),
(1462, 1462, 'seepay', 'SP-MEGA-1462', 2000000, 'refunded', DATEADD(MINUTE, 25, DATEADD(HOUR, 16, DATEADD(DAY, -60, GETDATE())))),
(1463, 1463, 'seepay', 'SP-MEGA-1463', 150000, 'pending', NULL),
(1464, 1464, 'seepay', 'SP-MEGA-1464', 800000, 'refunded', DATEADD(MINUTE, 21, DATEADD(HOUR, 7, DATEADD(DAY, -32, GETDATE())))),
(1465, 1465, 'seepay', 'SP-MEGA-1465', 400000, 'completed', DATEADD(MINUTE, 14, DATEADD(HOUR, 20, DATEADD(DAY, -45, GETDATE())))),
(1466, 1466, 'seepay', 'SP-MEGA-1466', 150000, 'completed', DATEADD(MINUTE, 47, DATEADD(HOUR, 7, DATEADD(DAY, -27, GETDATE())))),
(1467, 1467, 'seepay', 'SP-MEGA-1467', 200000, 'completed', DATEADD(MINUTE, 53, DATEADD(HOUR, 4, DATEADD(DAY, -11, GETDATE())))),
(1468, 1468, 'seepay', 'SP-MEGA-1468', 600000, 'refunded', DATEADD(MINUTE, 55, DATEADD(HOUR, 2, DATEADD(DAY, -23, GETDATE())))),
(1469, 1469, 'seepay', 'SP-MEGA-1469', 400000, 'cancelled', NULL),
(1470, 1470, 'seepay', 'SP-MEGA-1470', 600000, 'refunded', DATEADD(MINUTE, 40, DATEADD(HOUR, 3, DATEADD(DAY, -10, GETDATE())))),
(1471, 1471, 'seepay', 'SP-MEGA-1471', 300000, 'refunded', DATEADD(MINUTE, 6, DATEADD(HOUR, 17, DATEADD(DAY, -58, GETDATE())))),
(1472, 1472, 'seepay', 'SP-MEGA-1472', 200000, 'cancelled', NULL),
(1473, 1473, 'seepay', 'SP-MEGA-1473', 400000, 'pending', NULL),
(1474, 1474, 'seepay', 'SP-MEGA-1474', 500000, 'completed', DATEADD(MINUTE, 23, DATEADD(HOUR, 14, DATEADD(DAY, -20, GETDATE())))),
(1475, 1475, 'seepay', 'SP-MEGA-1475', 600000, 'refunded', DATEADD(MINUTE, 11, DATEADD(HOUR, 11, DATEADD(DAY, -30, GETDATE())))),
(1476, 1476, 'seepay', 'SP-MEGA-1476', 300000, 'completed', DATEADD(MINUTE, 24, DATEADD(HOUR, 12, DATEADD(DAY, 0, GETDATE())))),
(1477, 1477, 'seepay', 'SP-MEGA-1477', 500000, 'refunded', DATEADD(MINUTE, 38, DATEADD(HOUR, 21, DATEADD(DAY, -21, GETDATE())))),
(1478, 1478, 'seepay', 'SP-MEGA-1478', 2000000, 'completed', DATEADD(MINUTE, 25, DATEADD(HOUR, 19, DATEADD(DAY, -51, GETDATE())))),
(1479, 1479, 'seepay', 'SP-MEGA-1479', 800000, 'completed', DATEADD(MINUTE, 39, DATEADD(HOUR, 14, DATEADD(DAY, -45, GETDATE())))),
(1480, 1480, 'seepay', 'SP-MEGA-1480', 2000000, 'refunded', DATEADD(MINUTE, 10, DATEADD(HOUR, 17, DATEADD(DAY, -58, GETDATE())))),
(1481, 1481, 'seepay', 'SP-MEGA-1481', 1000000, 'completed', DATEADD(MINUTE, 16, DATEADD(HOUR, 9, DATEADD(DAY, -36, GETDATE())))),
(1482, 1482, 'seepay', 'SP-MEGA-1482', 1000000, 'pending', NULL),
(1483, 1483, 'seepay', 'SP-MEGA-1483', 200000, 'completed', DATEADD(MINUTE, 34, DATEADD(HOUR, 9, DATEADD(DAY, -17, GETDATE())))),
(1484, 1484, 'seepay', 'SP-MEGA-1484', 500000, 'completed', DATEADD(MINUTE, 37, DATEADD(HOUR, 20, DATEADD(DAY, -32, GETDATE())))),
(1485, 1485, 'seepay', 'SP-MEGA-1485', 200000, 'completed', DATEADD(MINUTE, 53, DATEADD(HOUR, 1, DATEADD(DAY, -41, GETDATE())))),
(1486, 1486, 'seepay', 'SP-MEGA-1486', 450000, 'pending', NULL),
(1487, 1487, 'seepay', 'SP-MEGA-1487', 600000, 'completed', DATEADD(MINUTE, 53, DATEADD(HOUR, 22, DATEADD(DAY, -45, GETDATE())))),
(1488, 1488, 'seepay', 'SP-MEGA-1488', 600000, 'pending', NULL),
(1489, 1489, 'seepay', 'SP-MEGA-1489', 200000, 'refunded', DATEADD(MINUTE, 6, DATEADD(HOUR, 6, DATEADD(DAY, -40, GETDATE())))),
(1490, 1490, 'seepay', 'SP-MEGA-1490', 200000, 'refunded', DATEADD(MINUTE, 11, DATEADD(HOUR, 11, DATEADD(DAY, -32, GETDATE())))),
(1491, 1491, 'seepay', 'SP-MEGA-1491', 2000000, 'cancelled', NULL),
(1492, 1492, 'seepay', 'SP-MEGA-1492', 600000, 'completed', DATEADD(MINUTE, 47, DATEADD(HOUR, 18, DATEADD(DAY, -57, GETDATE())))),
(1493, 1493, 'seepay', 'SP-MEGA-1493', 300000, 'cancelled', NULL),
(1494, 1494, 'seepay', 'SP-MEGA-1494', 400000, 'completed', DATEADD(MINUTE, 15, DATEADD(HOUR, 11, DATEADD(DAY, -17, GETDATE())))),
(1495, 1495, 'seepay', 'SP-MEGA-1495', 200000, 'refunded', DATEADD(MINUTE, 6, DATEADD(HOUR, 17, DATEADD(DAY, -10, GETDATE())))),
(1496, 1496, 'seepay', 'SP-MEGA-1496', 150000, 'completed', DATEADD(MINUTE, 57, DATEADD(HOUR, 20, DATEADD(DAY, -30, GETDATE())))),
(1497, 1497, 'seepay', 'SP-MEGA-1497', 2000000, 'refunded', DATEADD(MINUTE, 24, DATEADD(HOUR, 15, DATEADD(DAY, -41, GETDATE())))),
(1498, 1498, 'seepay', 'SP-MEGA-1498', 150000, 'completed', DATEADD(MINUTE, 50, DATEADD(HOUR, 18, DATEADD(DAY, -29, GETDATE())))),
(1499, 1499, 'seepay', 'SP-MEGA-1499', 2000000, 'cancelled', NULL);
SET IDENTITY_INSERT PaymentTransactions OFF;
GO
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
SELECT 'VoucherUsages', COUNT(*) FROM VoucherUsages UNION ALL
SELECT 'EventStaff', COUNT(*) FROM EventStaff UNION ALL
SELECT 'Permissions', COUNT(*) FROM Permissions UNION ALL
SELECT 'RolePermissions', COUNT(*) FROM RolePermissions UNION ALL
SELECT 'SupportTickets', COUNT(*) FROM SupportTickets UNION ALL
SELECT 'TicketMessages', COUNT(*) FROM TicketMessages UNION ALL
SELECT 'ChatSessions', COUNT(*) FROM ChatSessions UNION ALL
SELECT 'ChatMessages', COUNT(*) FROM ChatMessages UNION ALL
SELECT 'Media', COUNT(*) FROM Media UNION ALL
SELECT 'SiteSettings', COUNT(*) FROM SiteSettings UNION ALL
SELECT 'ActivityLog', COUNT(*) FROM ActivityLog UNION ALL
SELECT 'Notifications', COUNT(*) FROM Notifications
ORDER BY [Table];

PRINT '';
PRINT 'EVENT STATUS DISTRIBUTION:';
SELECT status, COUNT(*) AS total FROM Events GROUP BY status ORDER BY status;

PRINT '';
PRINT 'ORDER STATUS DISTRIBUTION:';
SELECT status, COUNT(*) AS total FROM Orders GROUP BY status ORDER BY status;

PRINT '';
PRINT 'VOUCHER SCOPE DISTRIBUTION:';
SELECT voucher_scope, COUNT(*) AS total FROM Vouchers GROUP BY voucher_scope ORDER BY voucher_scope;

PRINT '';
PRINT '=== SETTLEMENT REPORT (đối soát) ===';
SELECT
    voucher_scope AS [Loại voucher],
    voucher_fund_source AS [Nguồn tiền],
    COUNT(*) AS [Số đơn],
    FORMAT(SUM(total_amount), 'N0') AS [Giá vé gốc],
    FORMAT(SUM(event_discount_amount), 'N0') AS [BTC giảm giá],
    FORMAT(SUM(system_discount_amount), 'N0') AS [HT trợ giá],
    FORMAT(SUM(final_amount), 'N0') AS [Khách trả],
    FORMAT(SUM(organizer_payout_amount), 'N0') AS [BTC nhận]
FROM Orders WHERE status = 'paid'
GROUP BY voucher_scope, voucher_fund_source
ORDER BY voucher_scope;

PRINT '';
PRINT 'PER-ORGANIZER SETTLEMENT:';
SELECT
    u.full_name AS [BTC],
    COUNT(o.order_id) AS [Đơn paid],
    FORMAT(SUM(o.total_amount), 'N0') AS [Giá vé gốc],
    FORMAT(SUM(o.event_discount_amount), 'N0') AS [Voucher SK (BTC chịu)],
    FORMAT(SUM(o.system_discount_amount), 'N0') AS [Voucher HT (sàn bù)],
    FORMAT(SUM(o.organizer_payout_amount), 'N0') AS [BTC thực nhận]
FROM Orders o
JOIN Events e ON o.event_id = e.event_id
JOIN Users u ON e.organizer_id = u.user_id
WHERE o.status = 'paid'
GROUP BY u.full_name
ORDER BY SUM(o.organizer_payout_amount) DESC;

PRINT '';
PRINT 'CUSTOMER VIP TIERS:';
SELECT u.full_name, u.email,
    ISNULL(SUM(o.final_amount), 0) AS total_spent,
    COUNT(o.order_id) AS order_count,
    CASE
        WHEN ISNULL(SUM(o.final_amount), 0) >= 5000000 THEN 'Diamond'
        WHEN COUNT(o.order_id) >= 5 OR ISNULL(SUM(o.final_amount), 0) >= 2000000 THEN 'Gold'
        WHEN COUNT(o.order_id) >= 1 THEN 'Silver'
        ELSE 'New'
    END AS tier
FROM Users u
LEFT JOIN Orders o ON o.user_id = u.user_id AND o.status = 'paid'
WHERE u.role = 'customer' AND u.is_deleted = 0
GROUP BY u.user_id, u.full_name, u.email
ORDER BY total_spent DESC;

PRINT '';
PRINT 'TICKET SOLD QUANTITY CONSISTENCY (should show discrepancy rows):';
;WITH SoldByTicketType AS (
    SELECT oi.ticket_type_id, SUM(CASE WHEN o.status IN ('paid','refunded') THEN oi.quantity ELSE 0 END) AS sold_from_orders
    FROM OrderItems oi JOIN Orders o ON o.order_id = oi.order_id GROUP BY oi.ticket_type_id
)
SELECT tt.ticket_type_id, tt.event_id, tt.sold_quantity AS in_tickettypes, ISNULL(s.sold_from_orders, 0) AS from_orders
FROM TicketTypes tt LEFT JOIN SoldByTicketType s ON s.ticket_type_id = tt.ticket_type_id
WHERE tt.sold_quantity <> ISNULL(s.sold_from_orders, 0);

PRINT '';
PRINT 'ORDER AMOUNT CONSISTENCY (expect 0 rows for errors):';
;WITH OrderCalc AS (SELECT order_id, SUM(subtotal) AS calc_total FROM OrderItems GROUP BY order_id)
SELECT o.order_id, o.order_code, o.total_amount, oc.calc_total
FROM Orders o JOIN OrderCalc oc ON oc.order_id = o.order_id WHERE o.total_amount <> oc.calc_total;

PRINT '';
PRINT 'SETTLEMENT CONSISTENCY (expect 0 rows):';
SELECT order_id, order_code, voucher_scope, organizer_payout_amount,
    total_amount - event_discount_amount AS expected_payout
FROM Orders
WHERE status = 'paid' AND organizer_payout_amount <> (total_amount - event_discount_amount);

PRINT '';
PRINT 'SUPPORT TICKET STATUS:';
SELECT status, COUNT(*) AS total FROM SupportTickets GROUP BY status ORDER BY status;

PRINT '';
PRINT 'ACTIVITY LOG ACTIONS:';
SELECT action, COUNT(*) AS total FROM ActivityLog GROUP BY action ORDER BY total DESC;

PRINT '';
PRINT 'NOTIFICATION STATUS:';
SELECT type, SUM(CASE WHEN is_read=0 THEN 1 ELSE 0 END) AS unread, SUM(CASE WHEN is_read=1 THEN 1 ELSE 0 END) AS [read], COUNT(*) AS total FROM Notifications GROUP BY type ORDER BY type;

PRINT '';
PRINT '============================================';
PRINT 'LOGIN ACCOUNTS:';
PRINT '============================================';
PRINT '  admin@ticketbox.vn      / Admin@123     (admin)';
PRINT '  support@ticketbox.vn    / Admin@123     (support_agent)';
PRINT '  agent2@ticketbox.vn     / Admin@123     (support_agent)';
PRINT '  organizer@ticketbox.vn  / Organizer@123 (organizer — Live Nation)';
PRINT '  events@vietravel.vn     / Organizer@123 (organizer)';
PRINT '  hello@techviet.org      / Organizer@123 (organizer)';
PRINT '  info@saigonsports.vn    / Organizer@123 (organizer)';
PRINT '  contact@sunsetent.vn    / Organizer@123 (organizer)';
PRINT '  customer@ticketbox.vn   / Customer@123  (customer — VIP An)';
PRINT '  All other customers     / Customer@123';
PRINT '';
PRINT '  Edge cases:';
PRINT '  banned.user@test.com    → is_active=0 (banned)';
PRINT '  deleted.user@test.com   → is_deleted=1 (soft deleted)';
PRINT '  yen.hoang@yahoo.com     → email_verified=0';
PRINT '  minimal@test.com        → no gender/dob/avatar';
PRINT '  long.trinh@gmail.com    → 2 orders (system voucher)';
PRINT '';
PRINT '  Voucher test:';
PRINT '  SYSTEM vouchers: SYSLAUNCH50, SYSVIP10, SYSFLASH200K, SYSWELCOME30';
PRINT '  EVENT vouchers:  HAT2026VIP, LIVENATION15, AITECH50K, RUN2026, FOODIE20, SUNSET10';
PRINT '  EXPIRED:         EXPIRED2025 (inactive)';
PRINT '============================================';
GO