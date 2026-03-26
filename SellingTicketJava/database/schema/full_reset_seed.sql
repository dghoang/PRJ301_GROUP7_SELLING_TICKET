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
 DATEADD(DAY,-2,GETDATE()), '27.72.100.11'),

('hello@techviet.org',
 '$2a$12$Bs2nPLu8UK8GZsy1flBiGewDcqwu4x/KqtksjeYEWRQtcBxgiyNVC',
 N'TechViet Community', '0281234567', NULL, NULL, 'organizer',
 'https://ui-avatars.com/api/?name=TechViet&background=06b6d4&color=fff&size=200',
 1, 0, 1, N'Cộng đồng công nghệ Việt Nam — Tổ chức hackathon, tech talk, và hội nghị IT.',
 'https://techviet.org', 'https://facebook.com/techviet', 'techviet.community',
 DATEADD(DAY,-1,GETDATE()), '14.241.120.88'),

('info@saigonsports.vn',
 '$2a$12$Bs2nPLu8UK8GZsy1flBiGewDcqwu4x/KqtksjeYEWRQtcBxgiyNVC',
 N'Saigon Sports Club', '0287654321', NULL, NULL, 'organizer',
 'https://ui-avatars.com/api/?name=SaigonSports&background=ef4444&color=fff&size=200',
 1, 0, 1, N'Câu lạc bộ thể thao Sài Gòn — Marathon, bóng rổ, và các giải đấu cộng đồng.',
 'https://saigonsports.vn', 'https://facebook.com/saigonsports', 'saigonsportsclub',
 DATEADD(DAY,-4,GETDATE()), '42.118.170.30'),

('contact@sunsetent.vn',
 '$2a$12$Bs2nPLu8UK8GZsy1flBiGewDcqwu4x/KqtksjeYEWRQtcBxgiyNVC',
 N'Sunset Entertainment', '0288765432', NULL, NULL, 'organizer',
 'https://ui-avatars.com/api/?name=Sunset&background=f59e0b&color=fff&size=200',
 1, 0, 1, N'Chuyên tổ chức sự kiện âm nhạc và lễ hội ngoài trời.',
 'https://sunsetent.vn', 'https://facebook.com/sunsetent', 'sunsetent.vn',
 DATEADD(DAY,-3,GETDATE()), '42.117.8.15'),

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
 DATEADD(DAY,-1,GETDATE()), '42.115.232.10'),

('cuong.le@yahoo.com',
 '$2a$12$07H.CL1nHx2kzH7oo1odGOClkIg/oK3s7.D/wxcRIL6xjhIo9sYhK',
 N'Lê Hoàng Cường', '0976543210', 'male', '1995-12-03', 'customer',
 'https://ui-avatars.com/api/?name=Cuong&background=8b5cf6&color=fff&size=200',
 1, 0, 1, NULL, NULL, NULL, NULL,
 DATEADD(DAY,-5,GETDATE()), '171.232.15.1'),

('duc.pham@outlook.com',
 '$2a$12$07H.CL1nHx2kzH7oo1odGOClkIg/oK3s7.D/wxcRIL6xjhIo9sYhK',
 N'Phạm Minh Đức', '0965432109', 'male', '1997-03-25', 'customer',
 'https://ui-avatars.com/api/?name=Duc&background=14b8a6&color=fff&size=200',
 1, 0, 1, NULL, NULL, NULL, NULL,
 DATEADD(DAY,-2,GETDATE()), '113.176.80.44'),

('ha.vu@gmail.com',
 '$2a$12$07H.CL1nHx2kzH7oo1odGOClkIg/oK3s7.D/wxcRIL6xjhIo9sYhK',
 N'Vũ Thị Hà', '0945678901', 'female', '2001-11-08', 'customer',
 'https://ui-avatars.com/api/?name=Ha&background=a855f7&color=fff&size=200',
 1, 0, 1, NULL, NULL, NULL, NULL,
 DATEADD(DAY,-3,GETDATE()), '115.73.214.5'),

('khai.do@gmail.com',
 '$2a$12$07H.CL1nHx2kzH7oo1odGOClkIg/oK3s7.D/wxcRIL6xjhIo9sYhK',
 N'Đỗ Quang Khải', '0934567890', 'male', '1999-04-16', 'customer',
 'https://ui-avatars.com/api/?name=Khai&background=0ea5e9&color=fff&size=200',
 1, 0, 1, NULL, NULL, NULL, NULL,
 DATEADD(DAY,-7,GETDATE()), '103.197.184.11'),

('tung.ngo@gmail.com',
 '$2a$12$07H.CL1nHx2kzH7oo1odGOClkIg/oK3s7.D/wxcRIL6xjhIo9sYhK',
 N'Ngô Thanh Tùng', '0923456789', 'male', '2002-01-30', 'customer',
 'https://ui-avatars.com/api/?name=Tung&background=f97316&color=fff&size=200',
 1, 0, 1, NULL, NULL, NULL, NULL,
 DATEADD(DAY,-10,GETDATE()), '14.169.55.22'),

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
 DATEADD(DAY,-1,GETDATE()), '27.72.59.131'),

('chau.ly@gmail.com',
 '$2a$12$07H.CL1nHx2kzH7oo1odGOClkIg/oK3s7.D/wxcRIL6xjhIo9sYhK',
 N'Lý Minh Châu', '0978901234', 'female', '1994-12-05', 'customer',
 'https://ui-avatars.com/api/?name=Chau&background=06b6d4&color=fff&size=200',
 1, 0, 1, NULL, NULL, NULL, NULL,
 DATEADD(DAY,-2,GETDATE()), '113.22.100.77'),

('long.trinh@gmail.com',
 '$2a$12$07H.CL1nHx2kzH7oo1odGOClkIg/oK3s7.D/wxcRIL6xjhIo9sYhK',
 N'Trịnh Hoàng Long', '0939876543', 'male', '2000-07-14', 'customer',
 'https://ui-avatars.com/api/?name=Long&background=84cc16&color=fff&size=200',
 1, 0, 1, NULL, NULL, NULL, NULL,
 DATEADD(DAY,-1,GETDATE()), '103.9.76.55'),

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
 DATEADD(DAY,-1,GETDATE()), '115.78.233.44'),

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
INSERT INTO Events (organizer_id, category_id, title, slug, short_description, description, banner_image, location, address, start_date, end_date, status, is_featured, views, pin_order, display_priority, max_tickets_per_order, max_total_tickets) VALUES
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
 '2026-04-20 19:00', '2026-04-20 22:30', 'approved', 1, 15800, 5, 100, 4, 1750),

(4, 1,
 N'Mỹ Tâm — My Soul 1981 Liveshow',
 'my-tam-my-soul-1981-liveshow',
 N'Đẳng cấp nữ hoàng Vpop — liveshow kỷ niệm 25 năm ca hát.',
 N'<h2>My Soul 1981 — Kỷ niệm 25 năm</h2><p>Mỹ Tâm mang đến đêm nhạc xúc động với hơn 40 ca khúc xuyên suốt sự nghiệp.</p>',
 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=800',
 N'Nhà hát Hòa Bình', N'240 Đường 3/2, Quận 10, TP.HCM',
 '2026-05-10 19:30', '2026-05-10 23:00', 'approved', 1, 9200, 4, 95, 4, 900),

(4, 1,
 N'Sơn Tùng M-TP — Sky Tour 2026',
 'son-tung-mtp-sky-tour-2026',
 N'Chuyến lưu diễn toàn quốc của Sơn Tùng M-TP.',
 N'<h2>Sky Tour 2026</h2><p>Sơn Tùng M-TP cùng ban nhạc trở lại sân khấu sau 2 năm vắng bóng. Sân khấu hoành tráng, hiệu ứng laser & pyro.</p>',
 'https://images.unsplash.com/photo-1470229722913-7c0e2dbbafd3?w=800',
 N'Phú Thọ Stadium', N'1 Lý Thường Kiệt, Quận 11, TP.HCM',
 '2026-06-15 19:00', '2026-06-15 22:00', 'approved', 1, 26000, 3, 90, 4, 4330),

(4, 1,
 N'Đêm nhạc Acoustic — Bên Nhau Trọn Đời',
 'dem-nhac-acoustic-ben-nhau-tron-doi',
 N'Đêm nhạc acoustic lãng mạn dành cho các cặp đôi.',
 N'<h2>Acoustic Night</h2><p>Không gian ấm cúng với guitar, piano. Guest: Bùi Anh Tuấn, Văn Mai Hương, Vũ.</p>',
 'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=800',
 N'Saigon Opera House', N'7 Lam Sơn, Quận 1, TP.HCM',
 '2026-03-28 20:00', '2026-03-28 22:30', 'approved', 0, 3800, 0, 70, 2, 350),

(8, 1,
 N'EDM Rave — Neon Jungle Festival',
 'edm-rave-neon-jungle-2026',
 N'Đại tiệc EDM với DJ quốc tế — Tiësto, Martin Garrix.',
 N'<h2>Neon Jungle Festival 2026</h2><p>Festival EDM lớn nhất Đông Nam Á lần đầu tại Việt Nam!</p><ul><li>Tiësto</li><li>Martin Garrix</li><li>DJ Snake</li><li>Hoaprox</li></ul>',
 'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=800',
 N'Đại Nam Wonderland', N'Bình Dương',
 '2026-07-04 17:00', '2026-07-05 02:00', 'pending', 0, 0, 0, 0, 6, 5700),

(8, 1,
 N'Indie Sunset Sessions Vol.3',
 'indie-sunset-sessions-vol3',
 N'Đêm nhạc indie ngoài trời tại bãi biển Vũng Tàu.',
 N'<h2>Indie Sunset Sessions</h2><p>Tận hưởng nhạc indie với hoàng hôn biển. Line-up: Ngọt, Cá Hồi Hoang, Chillies, Da LAB.</p>',
 'https://images.unsplash.com/photo-1501386761578-eac5c94b800a?w=800',
 N'Bãi Sau, Vũng Tàu', N'Đường Thùy Vân, TP Vũng Tàu',
 '2026-04-12 16:00', '2026-04-12 22:00', 'approved', 0, 4200, 0, 65, 4, 2000),

(8, 1,
 N'Karaoke Đại Hội — Event Test',
 'karaoke-dai-hoi-test',
 N'Sự kiện test bị từ chối do thiếu thông tin.',
 N'<p>Nội dung không phù hợp.</p>',
 'https://images.unsplash.com/photo-1516450360452-9312f5e86fc7?w=800',
 N'Quán Karaoke ABC', N'123 Nguyễn Trãi, Quận 5, TP.HCM',
 '2026-03-01 20:00', '2026-03-01 23:00', 'rejected', 0, 50, 0, 0, 0, 0),

-- ============ THỂ THAO (category_id=2) — 5 events ============
(7, 2,
 N'Vietnam Marathon — Đà Nẵng 2026',
 'vietnam-marathon-da-nang-2026',
 N'Giải marathon quốc tế lớn nhất tại thành phố đáng sống.',
 N'<h2>Vietnam Marathon 2026</h2><p>Chạy dọc bờ biển Mỹ Khê. Cự ly: 5K, 21K Half, 42K Full.</p><p>Huy chương finisher, bib cá nhân hóa, tiệc bia sau race.</p>',
 'https://images.unsplash.com/photo-1513593771513-7b58b6c4af38?w=800',
 N'Biển Mỹ Khê, Đà Nẵng', N'Đường Võ Nguyên Giáp, Sơn Trà, Đà Nẵng',
 '2026-05-03 04:30', '2026-05-03 12:00', 'approved', 1, 7800, 2, 85, 2, 10000),

(7, 2,
 N'Giải bóng rổ 3x3 Saigon Open',
 'bong-ro-3x3-saigon-open-2026',
 N'Giải bóng rổ đường phố 3x3 hấp dẫn nhất Sài Gòn.',
 N'<h2>Bóng rổ 3x3 Saigon Open</h2><p>64 đội tranh tài, giải thưởng 200 triệu đồng. Luật FIBA 3x3.</p>',
 'https://images.unsplash.com/photo-1546519638-68e109498ffc?w=800',
 N'Nhà thi đấu Phú Thọ', N'1 Lý Thường Kiệt, Quận 11, TP.HCM',
 '2026-04-12 08:00', '2026-04-13 18:00', 'approved', 0, 2500, 0, 60, 0, 564),

(7, 2,
 N'Saigon Night Run 10K',
 'saigon-night-run-10k-2026',
 N'Chạy đêm qua các con phố lung linh Sài Gòn.',
 N'<h2>Saigon Night Run 10K</h2><p>Chạy bộ 10km xuyên trung tâm TP.HCM vào ban đêm. Áo chạy phát quang đặc biệt.</p>',
 'https://images.unsplash.com/photo-1552674605-db6ffd4facb5?w=800',
 N'Phố đi bộ Nguyễn Huệ', N'Nguyễn Huệ, Quận 1, TP.HCM',
 '2026-03-22 19:00', '2026-03-22 22:00', 'approved', 0, 5100, 0, 65, 2, 3000),

(7, 2,
 N'Giải Bơi Lội TP.HCM Mùa Hè 2026',
 'giai-boi-loi-tphcm-mua-he-2026',
 N'Giải đấu phong trào cho VĐV nghiệp dư và bán chuyên.',
 N'<h2>Giải Bơi Lội TP.HCM</h2><p>Thi đấu tự do, ếch, bướm theo nhóm tuổi.</p>',
 'https://images.unsplash.com/photo-1519315901367-f34ff9154487?w=800',
 N'CLB Bơi Lội Yết Kiêu', N'1 Nguyễn Thị Minh Khai, Quận 1, TP.HCM',
 '2026-07-19 07:00', '2026-07-19 17:00', 'pending', 0, 0, 0, 0, 0, 1900),

(7, 2,
 N'Saigon Fun Run 5K 2025',
 'saigon-fun-run-5k-2025',
 N'Giải chạy cộng đồng 5K đã diễn ra thành công.',
 N'<p>Sự kiện đã kết thúc tháng 11/2025.</p>',
 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=800',
 N'Công viên Gia Định', N'Quận Gò Vấp, TP.HCM',
 '2025-11-15 06:00', '2025-11-15 10:00', 'approved', 0, 2200, 0, 30, 2, 1000),

-- ============ WORKSHOP (category_id=3) — 4 events ============
(6, 3,
 N'Workshop UI/UX Design — Từ Zero đến Portfolio',
 'workshop-uiux-zero-to-portfolio',
 N'2 ngày thực hành Figma, Design System với mentor từ Google & Grab.',
 N'<h2>UI/UX Workshop: Zero → Portfolio</h2><p>Mentor: Nguyễn Quốc Huy (Ex-Google), Trần Minh Anh (Grab Design Lead)</p>',
 'https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=800',
 N'Dreamplex Coworking', N'21 Nguyễn Trung Ngạn, Quận 1, TP.HCM',
 '2026-04-05 09:00', '2026-04-06 17:00', 'approved', 1, 4100, 0, 80, 2, 100),

(6, 3,
 N'Data Science Bootcamp — Python cho người mới',
 'data-science-bootcamp-python-2026',
 N'3 buổi tối học Python, Pandas, Matplotlib từ cơ bản.',
 N'<h2>Data Science Bootcamp</h2><p>Dành cho người mới bắt đầu. Bao gồm tài liệu và certificate.</p>',
 'https://images.unsplash.com/photo-1504384308090-c894fdcc538d?w=800',
 N'Campus Landmark', N'Vinhomes Central Park, Bình Thạnh, TP.HCM',
 '2026-04-15 18:30', '2026-04-17 21:00', 'approved', 0, 2100, 0, 55, 2, 100),

(6, 3,
 N'AI for Business Workshop Draft 2026',
 'ai-for-business-workshop-draft-2026',
 N'Workshop ứng dụng AI cho doanh nghiệp — đang chuẩn bị.',
 N'<p>Đang xây dựng giáo trình và danh sách diễn giả.</p>',
 NULL, N'TBD', N'TBD',
 '2026-09-15 09:00', '2026-09-15 17:00', 'draft', 0, 0, 0, 0, 0, 0),

(6, 3,
 N'Khoá học Digital Marketing Intensive',
 'digital-marketing-intensive-2026',
 N'5 buổi chuyên sâu về Facebook Ads, Google Ads, SEO & Content.',
 N'<h2>Digital Marketing Intensive</h2><p>Từ chiến lược đến thực thi. Phù hợp cho startups và SMEs.</p>',
 'https://images.unsplash.com/photo-1432888498266-38ffec3eaf0a?w=800',
 N'WeWork Landmark 81', N'Landmark 81, Bình Thạnh, TP.HCM',
 '2026-05-20 09:00', '2026-05-24 17:00', 'approved', 0, 1500, 0, 50, 2, 60),

-- ============ ẨM THỰC (category_id=4) — 3 events ============
(5, 4,
 N'Lễ hội Ẩm thực Đường phố Sài Gòn 2026',
 'le-hoi-am-thuc-duong-pho-saigon-2026',
 N'100+ gian hàng — Món ngon 3 miền & quốc tế.',
 N'<h2>Street Food Festival Saigon 2026</h2><p>Hơn 100 gian hàng Bắc-Trung-Nam + quốc tế. Sân khấu acoustic mỗi tối. Thi ăn nhanh.</p>',
 'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=800',
 N'Công viên 23/9', N'Phạm Ngũ Lão, Quận 1, TP.HCM',
 '2026-05-01 10:00', '2026-05-04 22:00', 'approved', 1, 11500, 0, 88, 6, 10500),

(5, 4,
 N'Cooking Class — Phở Bò Hà Nội Truyền Thống',
 'cooking-class-pho-bo-ha-noi',
 N'Học nấu phở bò Hà Nội chuẩn vị với đầu bếp 30 năm kinh nghiệm.',
 N'<h2>Cooking Class: Phở Bò</h2><p>3 tiếng, bao gồm nguyên liệu và thưởng thức tại chỗ.</p>',
 'https://images.unsplash.com/photo-1503764654157-72d979d9af2f?w=800',
 N'Cooking Studio Saigon', N'15 Lý Tự Trọng, Quận 1, TP.HCM',
 '2026-03-30 09:00', '2026-03-30 12:00', 'approved', 0, 1600, 0, 45, 2, 20),

(5, 4,
 N'Food Truck Weekend Draft 2026',
 'food-truck-weekend-draft-2026',
 N'Sự kiện food truck cuối tuần — đang chuẩn bị.',
 N'<p>Đang hoàn thiện line-up gian hàng.</p>',
 NULL, N'TBD', N'TBD',
 '2026-09-05 10:00', '2026-09-06 22:00', 'draft', 0, 0, 0, 0, 0, 0),

-- ============ NGHỆ THUẬT (category_id=5) — 3 events ============
(4, 5,
 N'Triển lãm Nghệ thuật Đương đại — Beyond Borders',
 'trien-lam-nghe-thuat-beyond-borders',
 N'30 nghệ sĩ Việt & quốc tế — Hội họa, điêu khắc, digital art.',
 N'<h2>Beyond Borders</h2><p>Triển lãm kết hợp truyền thống VN và hiện đại quốc tế. Main Gallery + Digital Room + Workshop Zone.</p>',
 'https://images.unsplash.com/photo-1531243269054-5ebf6f34081e?w=800',
 N'Bảo tàng Mỹ thuật TP.HCM', N'97A Phó Đức Chính, Quận 1, TP.HCM',
 '2026-04-01 09:00', '2026-04-30 18:00', 'approved', 0, 6200, 0, 72, 4, 3200),

(4, 5,
 N'Tấm Cám: The Musical',
 'tam-cam-the-musical-2026',
 N'Vở nhạc kịch cổ tích Việt Nam hoành tráng nhất 2026.',
 N'<h2>Tấm Cám: The Musical</h2><p>Cổ tích Việt Nam qua nhạc kịch hiện đại với dàn 50 diễn viên.</p>',
 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=800',
 N'Nhà hát Lớn Hà Nội', N'1 Tràng Tiền, Hoàn Kiếm, Hà Nội',
 '2026-05-20 19:30', '2026-05-20 21:30', 'approved', 0, 3200, 0, 68, 4, 510),

(8, 5,
 N'Triển lãm Ảnh Không Phép 2026',
 'trien-lam-anh-khong-phep',
 N'Sự kiện bị từ chối do chưa có giấy phép triển lãm.',
 N'<p>Thiếu giấy phép từ Sở VHTTDL.</p>',
 'https://images.unsplash.com/photo-1513364776144-60967b0f800f?w=800',
 N'Galerie ABC', N'Quận 3, TP.HCM',
 '2026-06-01 10:00', '2026-06-15 18:00', 'rejected', 0, 0, 0, 0, 0, 0),

-- ============ KINH DOANH (category_id=6) — 3 events ============
(6, 6,
 N'Startup Pitch Day — Vietnam Founders Summit',
 'startup-pitch-day-vietnam-founders-2026',
 N'20 startup pitch trước 50+ nhà đầu tư — Demo Day lớn nhất Q2.',
 N'<h2>Vietnam Founders Summit</h2><p>Kết nối startup — nhà đầu tư. Keynote + Pitches + Networking Cocktail.</p>',
 'https://images.unsplash.com/photo-1475721027785-f74eccf877e2?w=800',
 N'GEM Center', N'8 Nguyễn Bỉnh Khiêm, Quận 1, TP.HCM',
 '2026-05-15 09:00', '2026-05-15 18:00', 'approved', 0, 4700, 0, 75, 5, 370),

(5, 6,
 N'Hội nghị Du lịch & Hospitality Vietnam 2026',
 'hoi-nghi-du-lich-hospitality-2026',
 N'Xu hướng du lịch 2026-2030, AI trong hospitality.',
 N'<h2>Tourism & Hospitality Conference</h2><p>Diễn giả từ Marriott, Accor, Vinpearl.</p>',
 'https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=800',
 N'Vinpearl Luxury Landmark 81', N'Landmark 81, Bình Thạnh, TP.HCM',
 '2026-06-10 08:30', '2026-06-11 17:00', 'pending', 0, 0, 0, 0, 2, 300),

(6, 6,
 N'Crypto Investment Night 2026',
 'crypto-investment-night-2026',
 N'Bị từ chối do thiếu thông tin pháp lý về đầu tư tài sản số.',
 N'<p>Chưa cung cấp đủ cảnh báo rủi ro theo quy định.</p>',
 'https://images.unsplash.com/photo-1621761191319-c6fb62004040?w=800',
 N'Khách sạn Rex', N'141 Nguyễn Huệ, Quận 1, TP.HCM',
 '2026-04-18 18:30', '2026-04-18 21:30', 'rejected', 0, 0, 0, 0, 0, 0),

-- ============ CÔNG NGHỆ (category_id=7) — 5 events ============
(6, 7,
 N'Vietnam AI Summit 2026',
 'vietnam-ai-summit-2026',
 N'Hội nghị AI lớn nhất — Speakers từ OpenAI, Google DeepMind.',
 N'<h2>Vietnam AI Summit</h2><p>Topics: LLM, AI Healthcare, FinTech, Responsible AI. Hands-on workshop.</p>',
 'https://images.unsplash.com/photo-1485827404703-89b55fcc595e?w=800',
 N'Trung tâm Hội nghị GEM', N'8 Nguyễn Bỉnh Khiêm, Quận 1, TP.HCM',
 '2026-06-20 08:00', '2026-06-21 17:00', 'approved', 1, 8900, 1, 92, 3, 700),

(6, 7,
 N'Hackathon — Build for Vietnam 2026',
 'hackathon-build-for-vietnam-2026',
 N'48 giờ code non-stop — Giải thưởng 500 triệu đồng.',
 N'<h2>Build for Vietnam Hackathon</h2><p>Tracks: FinTech, HealthTech, EdTech, Open.</p>',
 'https://images.unsplash.com/photo-1504384764586-bb4cdc1707b0?w=800',
 N'VNG Campus', N'182 Lê Đại Hành, Quận 11, TP.HCM',
 '2026-05-24 09:00', '2026-05-26 17:00', 'approved', 0, 4500, 0, 78, 5, 130),

(6, 7,
 N'Tech Career Fair 2026',
 'tech-career-fair-2026',
 N'Ngày hội nghề nghiệp công nghệ toàn quốc.',
 N'<h2>Tech Career Fair</h2><p>50+ doanh nghiệp tuyển dụng. Student & Professional passes.</p>',
 'https://images.unsplash.com/photo-1552664730-d307ca884978?w=800',
 N'TT Hội nghị Quốc gia', N'57 Phạm Hùng, Nam Từ Liêm, Hà Nội',
 '2026-08-12 08:00', '2026-08-12 18:00', 'pending', 0, 0, 0, 0, 3, 1500),

(6, 7,
 N'Cloud Computing Workshop 2026 (Draft)',
 'cloud-computing-workshop-draft-2026',
 N'Workshop về AWS, GCP, Azure — đang soạn nội dung.',
 N'<p>Đang lên giáo trình.</p>',
 NULL, N'TBD', N'TBD',
 '2026-10-01 09:00', '2026-10-01 17:00', 'draft', 0, 0, 0, 0, 0, 0),

(4, 1,
 N'Beach Countdown Party 2026 Cancelled',
 'beach-countdown-party-2026-cancelled',
 N'Sự kiện countdown bị hủy do thời tiết xấu.',
 N'<p>BTC hủy để đảm bảo an toàn.</p>',
 'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=800',
 N'Bãi biển Cửa Đại', N'Hội An, Quảng Nam',
 '2026-12-31 20:00', '2027-01-01 01:00', 'cancelled', 0, 300, 0, 0, 4, 2000);
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
VALUES ('ORD-2026-0001', 9, 1, 7500000, 0, 7500000, 'paid', 'seepay', DATEADD(DAY,-30,@now), N'Nguyễn Văn An', 'customer@ticketbox.vn', '0912345678', DATEADD(DAY,-30,@now), 'NONE', 0, 375000, 7125000);
INSERT INTO OrderItems (order_id, ticket_type_id, quantity, unit_price, subtotal) VALUES (1, 2, 2, 3000000, 6000000),(1, 3, 1, 1500000, 1500000);

INSERT INTO Orders (order_code, user_id, event_id, total_amount, discount_amount, final_amount, status, payment_method, payment_date, buyer_name, buyer_email, buyer_phone, created_at, platform_fee_amount, organizer_payout_amount)
VALUES ('ORD-2026-0002', 9, 3, 4000000, 0, 4000000, 'paid', 'seepay', DATEADD(DAY,-25,@now), N'Nguyễn Văn An', 'customer@ticketbox.vn', '0912345678', DATEADD(DAY,-25,@now), 200000, 3800000);
INSERT INTO OrderItems (order_id, ticket_type_id, quantity, unit_price, subtotal) VALUES (2, 10, 2, 2000000, 4000000);

INSERT INTO Orders (order_code, user_id, event_id, total_amount, discount_amount, final_amount, status, payment_method, payment_date, buyer_name, buyer_email, buyer_phone, created_at, platform_fee_amount, organizer_payout_amount)
VALUES ('ORD-2026-0003', 9, 17, 500000, 0, 500000, 'paid', 'seepay', DATEADD(DAY,-22,@now), N'Nguyễn Văn An', 'customer@ticketbox.vn', '0912345678', DATEADD(DAY,-22,@now), 25000, 475000);
INSERT INTO OrderItems (order_id, ticket_type_id, quantity, unit_price, subtotal) VALUES (3, 41, 2, 250000, 500000);

INSERT INTO Orders (order_code, user_id, event_id, total_amount, discount_amount, final_amount, status, payment_method, payment_date, buyer_name, buyer_email, buyer_phone, created_at)
VALUES ('ORD-2026-0004', 9, 14, 600000, 0, 600000, 'paid', 'seepay', DATEADD(DAY,-18,@now), N'Nguyễn Văn An', 'customer@ticketbox.vn', '0912345678', DATEADD(DAY,-18,@now));
INSERT INTO OrderItems (order_id, ticket_type_id, quantity, unit_price, subtotal) VALUES (4, 34, 1, 600000, 600000);

INSERT INTO Orders (order_code, user_id, event_id, total_amount, discount_amount, final_amount, status, payment_method, payment_date, buyer_name, buyer_email, buyer_phone, created_at)
VALUES ('ORD-2026-0005', 9, 26, 500000, 0, 500000, 'paid', 'seepay', DATEADD(DAY,-10,@now), N'Nguyễn Văn An', 'customer@ticketbox.vn', '0912345678', DATEADD(DAY,-10,@now));
INSERT INTO OrderItems (order_id, ticket_type_id, quantity, unit_price, subtotal) VALUES (5, 55, 1, 500000, 500000);

INSERT INTO Orders (order_code, user_id, event_id, total_amount, discount_amount, final_amount, status, payment_method, payment_date, buyer_name, buyer_email, buyer_phone, created_at)
VALUES ('ORD-2026-0006', 9, 6, 1000000, 0, 1000000, 'paid', 'seepay', DATEADD(DAY,-8,@now), N'Nguyễn Văn An', 'customer@ticketbox.vn', '0912345678', DATEADD(DAY,-8,@now));
INSERT INTO OrderItems (order_id, ticket_type_id, quantity, unit_price, subtotal) VALUES (6, 20, 2, 500000, 1000000);

INSERT INTO Orders (order_code, user_id, event_id, total_amount, discount_amount, final_amount, status, payment_method, payment_expires_at, buyer_name, buyer_email, buyer_phone, created_at)
VALUES ('ORD-2026-0007', 9, 2, 2000000, 0, 2000000, 'pending', 'seepay', DATEADD(HOUR,2,@now), N'Nguyễn Văn An', 'customer@ticketbox.vn', '0912345678', @now);
INSERT INTO OrderItems (order_id, ticket_type_id, quantity, unit_price, subtotal) VALUES (7, 6, 1, 2000000, 2000000);

-- === CUSTOMER 10 (Bình) — Gold tier: 4 paid = ~11.5M ===
INSERT INTO Orders (order_code, user_id, event_id, total_amount, discount_amount, final_amount, status, payment_method, payment_date, buyer_name, buyer_email, buyer_phone, created_at)
VALUES ('ORD-2026-0008', 10, 1, 5000000, 0, 5000000, 'paid', 'seepay', DATEADD(DAY,-28,@now), N'Trần Thị Bình', 'binh.tran@gmail.com', '0987654321', DATEADD(DAY,-28,@now));
INSERT INTO OrderItems (order_id, ticket_type_id, quantity, unit_price, subtotal) VALUES (8, 1, 1, 5000000, 5000000);

INSERT INTO Orders (order_code, user_id, event_id, total_amount, discount_amount, final_amount, status, payment_method, payment_date, buyer_name, buyer_email, buyer_phone, created_at)
VALUES ('ORD-2026-0009', 10, 26, 3000000, 0, 3000000, 'paid', 'seepay', DATEADD(DAY,-15,@now), N'Trần Thị Bình', 'binh.tran@gmail.com', '0987654321', DATEADD(DAY,-15,@now));
INSERT INTO OrderItems (order_id, ticket_type_id, quantity, unit_price, subtotal) VALUES (9, 53, 1, 3000000, 3000000);

INSERT INTO Orders (order_code, user_id, event_id, total_amount, discount_amount, final_amount, status, payment_method, payment_date, buyer_name, buyer_email, buyer_phone, created_at)
VALUES ('ORD-2026-0010', 10, 23, 200000, 0, 200000, 'paid', 'seepay', DATEADD(DAY,-12,@now), N'Trần Thị Bình', 'binh.tran@gmail.com', '0987654321', DATEADD(DAY,-12,@now));
INSERT INTO OrderItems (order_id, ticket_type_id, quantity, unit_price, subtotal) VALUES (10, 50, 1, 200000, 200000);

INSERT INTO Orders (order_code, user_id, event_id, total_amount, discount_amount, final_amount, status, payment_method, payment_date, buyer_name, buyer_email, buyer_phone, created_at, voucher_id, voucher_scope, voucher_fund_source, event_discount_amount, platform_fee_amount, organizer_payout_amount)
VALUES ('ORD-2026-0011', 10, 20, 600000, 90000, 510000, 'paid', 'seepay', DATEADD(DAY,-7,@now), N'Trần Thị Bình', 'binh.tran@gmail.com', '0987654321', DATEADD(DAY,-7,@now), 2, 'EVENT', 'ORGANIZER', 90000, 30000, 480000);
INSERT INTO OrderItems (order_id, ticket_type_id, quantity, unit_price, subtotal) VALUES (11, 44, 2, 300000, 600000);

-- === CUSTOMER 11 (Cường) — has cancelled + paid ===
INSERT INTO Orders (order_code, user_id, event_id, total_amount, discount_amount, final_amount, status, payment_method, payment_date, buyer_name, buyer_email, buyer_phone, created_at)
VALUES ('ORD-2026-0012', 11, 2, 4000000, 0, 4000000, 'paid', 'seepay', DATEADD(DAY,-20,@now), N'Lê Hoàng Cường', 'cuong.le@yahoo.com', '0976543210', DATEADD(DAY,-20,@now));
INSERT INTO OrderItems (order_id, ticket_type_id, quantity, unit_price, subtotal) VALUES (12, 6, 2, 2000000, 4000000);

INSERT INTO Orders (order_code, user_id, event_id, total_amount, discount_amount, final_amount, status, payment_method, buyer_name, buyer_email, buyer_phone, created_at)
VALUES ('ORD-2026-0013', 11, 3, 800000, 0, 800000, 'cancelled', 'seepay', N'Lê Hoàng Cường', 'cuong.le@yahoo.com', '0976543210', DATEADD(DAY,-18,@now));
INSERT INTO OrderItems (order_id, ticket_type_id, quantity, unit_price, subtotal) VALUES (13, 11, 1, 800000, 800000);

INSERT INTO Orders (order_code, user_id, event_id, total_amount, discount_amount, final_amount, status, payment_method, payment_date, buyer_name, buyer_email, buyer_phone, created_at)
VALUES ('ORD-2026-0014', 11, 10, 800000, 0, 800000, 'paid', 'seepay', DATEADD(DAY,-35,@now), N'Lê Hoàng Cường', 'cuong.le@yahoo.com', '0976543210', DATEADD(DAY,-35,@now));
INSERT INTO OrderItems (order_id, ticket_type_id, quantity, unit_price, subtotal) VALUES (14, 28, 2, 400000, 800000);

-- === CUSTOMER 12 (Đức) — sports/tech, free ticket orders ===
INSERT INTO Orders (order_code, user_id, event_id, total_amount, discount_amount, final_amount, status, payment_method, payment_date, buyer_name, buyer_email, buyer_phone, created_at)
VALUES ('ORD-2026-0015', 12, 8, 800000, 0, 800000, 'paid', 'seepay', DATEADD(DAY,-45,@now), N'Phạm Minh Đức', 'duc.pham@outlook.com', '0965432109', DATEADD(DAY,-45,@now));
INSERT INTO OrderItems (order_id, ticket_type_id, quantity, unit_price, subtotal) VALUES (15, 23, 1, 800000, 800000);

INSERT INTO Orders (order_code, user_id, event_id, total_amount, discount_amount, final_amount, status, payment_method, payment_date, buyer_name, buyer_email, buyer_phone, created_at)
VALUES ('ORD-2026-0016', 12, 27, 0, 0, 0, 'paid', 'cash', DATEADD(DAY,-8,@now), N'Phạm Minh Đức', 'duc.pham@outlook.com', '0965432109', DATEADD(DAY,-8,@now));
INSERT INTO OrderItems (order_id, ticket_type_id, quantity, unit_price, subtotal) VALUES (16, 57, 1, 0, 0);

INSERT INTO Orders (order_code, user_id, event_id, total_amount, discount_amount, final_amount, status, payment_method, payment_date, buyer_name, buyer_email, buyer_phone, created_at)
VALUES ('ORD-2026-0017', 12, 4, 1200000, 0, 1200000, 'paid', 'seepay', DATEADD(DAY,-6,@now), N'Phạm Minh Đức', 'duc.pham@outlook.com', '0965432109', DATEADD(DAY,-6,@now));
INSERT INTO OrderItems (order_id, ticket_type_id, quantity, unit_price, subtotal) VALUES (17, 12, 1, 1200000, 1200000);

-- === CUSTOMER 13 (Hà) — diverse events ===
INSERT INTO Orders (order_code, user_id, event_id, total_amount, discount_amount, final_amount, status, payment_method, payment_date, buyer_name, buyer_email, buyer_phone, created_at)
VALUES ('ORD-2026-0018', 13, 8, 300000, 0, 300000, 'paid', 'seepay', DATEADD(DAY,-42,@now), N'Vũ Thị Hà', 'ha.vu@gmail.com', '0945678901', DATEADD(DAY,-42,@now));
INSERT INTO OrderItems (order_id, ticket_type_id, quantity, unit_price, subtotal) VALUES (18, 24, 1, 300000, 300000);

INSERT INTO Orders (order_code, user_id, event_id, total_amount, discount_amount, final_amount, status, payment_method, payment_date, buyer_name, buyer_email, buyer_phone, created_at)
VALUES ('ORD-2026-0019', 13, 20, 300000, 0, 300000, 'paid', 'seepay', DATEADD(DAY,-9,@now), N'Vũ Thị Hà', 'ha.vu@gmail.com', '0945678901', DATEADD(DAY,-9,@now));
INSERT INTO OrderItems (order_id, ticket_type_id, quantity, unit_price, subtotal) VALUES (19, 44, 1, 300000, 300000);

INSERT INTO Orders (order_code, user_id, event_id, total_amount, discount_amount, final_amount, status, payment_method, payment_date, buyer_name, buyer_email, buyer_phone, created_at)
VALUES ('ORD-2026-0020', 13, 18, 500000, 0, 500000, 'paid', 'seepay', DATEADD(DAY,-5,@now), N'Vũ Thị Hà', 'ha.vu@gmail.com', '0945678901', DATEADD(DAY,-5,@now));
INSERT INTO OrderItems (order_id, ticket_type_id, quantity, unit_price, subtotal) VALUES (20, 42, 1, 500000, 500000);

-- === CUSTOMER 14 (Khải) — tech-focused ===
INSERT INTO Orders (order_code, user_id, event_id, total_amount, discount_amount, final_amount, status, payment_method, payment_date, buyer_name, buyer_email, buyer_phone, created_at)
VALUES ('ORD-2026-0021', 14, 13, 1200000, 0, 1200000, 'paid', 'seepay', DATEADD(DAY,-15,@now), N'Đỗ Quang Khải', 'khai.do@gmail.com', '0934567890', DATEADD(DAY,-15,@now));
INSERT INTO OrderItems (order_id, ticket_type_id, quantity, unit_price, subtotal) VALUES (21, 32, 1, 1200000, 1200000);

INSERT INTO Orders (order_code, user_id, event_id, total_amount, discount_amount, final_amount, status, payment_method, payment_date, buyer_name, buyer_email, buyer_phone, created_at)
VALUES ('ORD-2026-0022', 14, 21, 2400000, 0, 2400000, 'paid', 'seepay', DATEADD(DAY,-10,@now), N'Đỗ Quang Khải', 'khai.do@gmail.com', '0934567890', DATEADD(DAY,-10,@now));
INSERT INTO OrderItems (order_id, ticket_type_id, quantity, unit_price, subtotal) VALUES (22, 46, 2, 1200000, 2400000);

-- === CUSTOMER 15 (Tùng) — low spend, 1 order ===
INSERT INTO Orders (order_code, user_id, event_id, total_amount, discount_amount, final_amount, status, payment_method, payment_date, buyer_name, buyer_email, buyer_phone, created_at)
VALUES ('ORD-2026-0023', 15, 17, 50000, 0, 50000, 'paid', 'seepay', DATEADD(DAY,-4,@now), N'Ngô Thanh Tùng', 'tung.ngo@gmail.com', '0923456789', DATEADD(DAY,-4,@now));
INSERT INTO OrderItems (order_id, ticket_type_id, quantity, unit_price, subtotal) VALUES (23, 39, 1, 50000, 50000);

-- === CUSTOMER 17 (Bảo) — regular buyer, uses vouchers ===
INSERT INTO Orders (order_code, user_id, event_id, total_amount, discount_amount, final_amount, status, payment_method, payment_date, buyer_name, buyer_email, buyer_phone, created_at)
VALUES ('ORD-2026-0024', 17, 6, 2400000, 360000, 2040000, 'paid', 'seepay', DATEADD(DAY,-12,@now), N'Bùi Quốc Bảo', 'bao.bui@gmail.com', '0913579246', DATEADD(DAY,-12,@now));
INSERT INTO OrderItems (order_id, ticket_type_id, quantity, unit_price, subtotal) VALUES (24, 21, 2, 1200000, 2400000);

INSERT INTO Orders (order_code, user_id, event_id, total_amount, discount_amount, final_amount, status, payment_method, payment_date, buyer_name, buyer_email, buyer_phone, created_at)
VALUES ('ORD-2026-0025', 17, 26, 1500000, 50000, 1450000, 'paid', 'seepay', DATEADD(DAY,-6,@now), N'Bùi Quốc Bảo', 'bao.bui@gmail.com', '0913579246', DATEADD(DAY,-6,@now));
INSERT INTO OrderItems (order_id, ticket_type_id, quantity, unit_price, subtotal) VALUES (25, 54, 1, 1500000, 1500000);

-- === CUSTOMER 18 (Châu) — refund scenario ===
INSERT INTO Orders (order_code, user_id, event_id, total_amount, discount_amount, final_amount, status, payment_method, payment_date, buyer_name, buyer_email, buyer_phone, created_at)
VALUES ('ORD-2026-0026', 18, 3, 2000000, 0, 2000000, 'refunded', 'seepay', DATEADD(DAY,-20,@now), N'Lý Minh Châu', 'chau.ly@gmail.com', '0978901234', DATEADD(DAY,-20,@now));
INSERT INTO OrderItems (order_id, ticket_type_id, quantity, unit_price, subtotal) VALUES (26, 10, 1, 2000000, 2000000);

INSERT INTO Orders (order_code, user_id, event_id, total_amount, discount_amount, final_amount, status, payment_method, payment_date, buyer_name, buyer_email, buyer_phone, created_at)
VALUES ('ORD-2026-0027', 18, 1, 1500000, 0, 1500000, 'refunded', 'seepay', DATEADD(DAY,-14,@now), N'Lý Minh Châu', 'chau.ly@gmail.com', '0978901234', DATEADD(DAY,-14,@now));
INSERT INTO OrderItems (order_id, ticket_type_id, quantity, unit_price, subtotal) VALUES (27, 3, 1, 1500000, 1500000);

INSERT INTO Orders (order_code, user_id, event_id, total_amount, discount_amount, final_amount, status, payment_method, payment_date, buyer_name, buyer_email, buyer_phone, created_at)
VALUES ('ORD-2026-0028', 18, 17, 80000, 0, 80000, 'paid', 'seepay', DATEADD(DAY,-3,@now), N'Lý Minh Châu', 'chau.ly@gmail.com', '0978901234', DATEADD(DAY,-3,@now));
INSERT INTO OrderItems (order_id, ticket_type_id, quantity, unit_price, subtotal) VALUES (28, 40, 1, 80000, 80000);

-- === CUSTOMER 20 (Diễm) — multiple events ===
INSERT INTO Orders (order_code, user_id, event_id, total_amount, discount_amount, final_amount, status, payment_method, payment_date, buyer_name, buyer_email, buyer_phone, created_at)
VALUES ('ORD-2026-0029', 20, 2, 3500000, 0, 3500000, 'paid', 'seepay', DATEADD(DAY,-16,@now), N'Phan Ngọc Diễm', 'diem.phan@gmail.com', '0967890123', DATEADD(DAY,-16,@now));
INSERT INTO OrderItems (order_id, ticket_type_id, quantity, unit_price, subtotal) VALUES (29, 5, 1, 3500000, 3500000);

INSERT INTO Orders (order_code, user_id, event_id, total_amount, discount_amount, final_amount, status, payment_method, payment_date, buyer_name, buyer_email, buyer_phone, created_at)
VALUES ('ORD-2026-0030', 20, 16, 2500000, 0, 2500000, 'paid', 'seepay', DATEADD(DAY,-9,@now), N'Phan Ngọc Diễm', 'diem.phan@gmail.com', '0967890123', DATEADD(DAY,-9,@now));
INSERT INTO OrderItems (order_id, ticket_type_id, quantity, unit_price, subtotal) VALUES (30, 37, 1, 2500000, 2500000);

-- === CUSTOMER 21 (Kiên) — checked-in tickets ===
INSERT INTO Orders (order_code, user_id, event_id, total_amount, discount_amount, final_amount, status, payment_method, payment_date, buyer_name, buyer_email, buyer_phone, created_at)
VALUES ('ORD-2025-0031', 21, 12, 500000, 0, 500000, 'paid', 'seepay', '2025-10-20', N'Đặng Trung Kiên', 'kien.dang@gmail.com', '0941234567', '2025-10-20');
INSERT INTO OrderItems (order_id, ticket_type_id, quantity, unit_price, subtotal) VALUES (31, 30, 1, 500000, 500000);

INSERT INTO Orders (order_code, user_id, event_id, total_amount, discount_amount, final_amount, status, payment_method, payment_date, buyer_name, buyer_email, buyer_phone, created_at)
VALUES ('ORD-2026-0032', 21, 10, 400000, 0, 400000, 'paid', 'seepay', DATEADD(DAY,-30,@now), N'Đặng Trung Kiên', 'kien.dang@gmail.com', '0941234567', DATEADD(DAY,-30,@now));
INSERT INTO OrderItems (order_id, ticket_type_id, quantity, unit_price, subtotal) VALUES (32, 28, 1, 400000, 400000);

-- === EDGE CASE ORDERS ===
INSERT INTO Orders (order_code, user_id, event_id, total_amount, discount_amount, final_amount, status, payment_method, buyer_name, buyer_email, buyer_phone, created_at)
VALUES ('ORD-2026-0033', 11, 6, 500000, 0, 500000, 'cancelled', 'seepay', N'Lê Hoàng Cường', 'cuong.le@yahoo.com', '0976543210', DATEADD(DAY,-10,@now));
INSERT INTO OrderItems (order_id, ticket_type_id, quantity, unit_price, subtotal) VALUES (33, 20, 1, 500000, 500000);

INSERT INTO Orders (order_code, user_id, event_id, total_amount, discount_amount, final_amount, status, payment_method, payment_date, buyer_name, buyer_email, buyer_phone, created_at)
VALUES ('ORD-2026-0034', 25, 1, 5000000, 0, 5000000, 'paid', 'seepay', DATEADD(DAY,-26,@now), N'Nguyễn Hoàng Phúc', 'fullprofile@gmail.com', '0918765432', DATEADD(DAY,-26,@now));
INSERT INTO OrderItems (order_id, ticket_type_id, quantity, unit_price, subtotal) VALUES (34, 1, 1, 5000000, 5000000);

INSERT INTO Orders (order_code, user_id, event_id, total_amount, discount_amount, final_amount, status, payment_method, payment_date, buyer_name, buyer_email, buyer_phone, created_at)
VALUES ('ORD-2026-0035', 18, 6, 500000, 0, 500000, 'refunded', 'seepay', DATEADD(DAY,-15,@now), N'Lý Minh Châu', 'chau.ly@gmail.com', '0978901234', DATEADD(DAY,-15,@now));
INSERT INTO OrderItems (order_id, ticket_type_id, quantity, unit_price, subtotal) VALUES (35, 20, 1, 500000, 500000);
GO

PRINT '=== 35 orders + order items seeded ===';
GO

-- =============================================
-- =============================================
INSERT INTO Tickets (ticket_code, order_item_id, attendee_name, attendee_email, qr_code, is_checked_in, checked_in_at, checked_in_by) VALUES
('TIX-HAT-001', 1, N'Nguyễn Văn An', 'customer@ticketbox.vn', 'TIX-HAT-001|E1|VIP|20260420', 0, NULL, NULL),
('TIX-HAT-002', 1, N'Nguyễn Thị Mai', 'mai@gmail.com', 'TIX-HAT-002|E1|VIP|20260420', 0, NULL, NULL),
('TIX-HAT-003', 2, N'Nguyễn Văn An', 'customer@ticketbox.vn', 'TIX-HAT-003|E1|CAT1|20260420', 0, NULL, NULL),
('TIX-STU-001', 3, N'Nguyễn Văn An', 'customer@ticketbox.vn', 'TIX-STU-001|E3|GOLD|20260615', 0, NULL, NULL),
('TIX-STU-002', 3, N'Trần Minh Tú', 'tu.tran@gmail.com', 'TIX-STU-002|E3|GOLD|20260615', 0, NULL, NULL),
('TIX-FDF-001', 4, N'Nguyễn Văn An', 'customer@ticketbox.vn', 'TIX-FDF-001|E17|VIP|20260501', 0, NULL, NULL),
('TIX-FDF-002', 4, N'Nguyễn Thị Mai', 'mai@gmail.com', 'TIX-FDF-002|E17|VIP|20260501', 0, NULL, NULL),
('TIX-DS-001', 5, N'Nguyễn Văn An', 'customer@ticketbox.vn', 'TIX-DS-001|E14|FULL|20260415', 0, NULL, NULL),
('TIX-AIS-001', 6, N'Nguyễn Văn An', 'customer@ticketbox.vn', 'TIX-AIS-001|E26|STU|20260620', 0, NULL, NULL),
('TIX-IND-001', 7, N'Nguyễn Văn An', 'customer@ticketbox.vn', 'TIX-IND-001|E6|GA|20260412', 0, NULL, NULL),
('TIX-IND-002', 7, N'Trần Minh Tú', 'tu.tran@gmail.com', 'TIX-IND-002|E6|GA|20260412', 0, NULL, NULL),
('TIX-HAT-004', 8, N'Trần Thị Bình', 'binh.tran@gmail.com', 'TIX-HAT-004|E1|SVIP|20260420', 0, NULL, NULL),
('TIX-AIS-002', 9, N'Trần Thị Bình', 'binh.tran@gmail.com', 'TIX-AIS-002|E26|VIP|20260620', 0, NULL, NULL),
('TIX-SPD-001', 10, N'Trần Thị Bình', 'binh.tran@gmail.com', 'TIX-SPD-001|E23|GA|20260515', 0, NULL, NULL),
('TIX-ART-001', 11, N'Trần Thị Bình', 'binh.tran@gmail.com', 'TIX-ART-001|E20|WS|20260415', 0, NULL, NULL),
('TIX-ART-002', 11, N'Nguyễn Hoàng Long', 'long@gmail.com', 'TIX-ART-002|E20|WS|20260415', 0, NULL, NULL),
('TIX-MTM-001', 12, N'Lê Hoàng Cường', 'cuong.le@yahoo.com', 'TIX-MTM-001|E2|A|20260510', 0, NULL, NULL),
('TIX-MTM-002', 12, N'Lê Thị Lan', 'lan.le@gmail.com', 'TIX-MTM-002|E2|A|20260510', 0, NULL, NULL),
('TIX-NR-001', 14, N'Lê Hoàng Cường', 'cuong.le@yahoo.com', 'TIX-NR-001|E10|10K|20260322', 0, NULL, NULL),
('TIX-NR-002', 14, N'Lê Thị Lan', 'lan.le@gmail.com', 'TIX-NR-002|E10|10K|20260322', 0, NULL, NULL),
('TIX-MRT-001', 15, N'Phạm Minh Đức', 'duc.pham@outlook.com', 'TIX-MRT-001|E8|HALF|20260503', 0, NULL, NULL),
('TIX-HKT-001', 16, N'Team Codecraft', 'duc.pham@outlook.com', 'TIX-HKT-001|E27|TEAM|20260524', 0, NULL, NULL),
('TIX-ACS-001', 17, N'Phạm Minh Đức & Ngọc Anh', 'duc.pham@outlook.com', 'TIX-ACS-001|E4|COUPLE|20260328', 0, NULL, NULL),
('TIX-MRT-002', 18, N'Vũ Thị Hà', 'ha.vu@gmail.com', 'TIX-MRT-002|E8|5K|20260503', 0, NULL, NULL),
('TIX-ART-003', 19, N'Vũ Thị Hà', 'ha.vu@gmail.com', 'TIX-ART-003|E20|WS|20260415', 0, NULL, NULL),
('TIX-CK-001', 20, N'Vũ Thị Hà', 'ha.vu@gmail.com', 'TIX-CK-001|E18|STD|20260330', 0, NULL, NULL),
('TIX-UXW-001', 21, N'Đỗ Quang Khải', 'khai.do@gmail.com', 'TIX-UXW-001|E13|STD|20260405', 0, NULL, NULL),
('TIX-TC-001', 22, N'Đỗ Quang Khải', 'khai.do@gmail.com', 'TIX-TC-001|E21|A|20260520', 0, NULL, NULL),
('TIX-TC-002', 22, N'Đỗ Thị Hương', 'huong.do@gmail.com', 'TIX-TC-002|E21|A|20260520', 0, NULL, NULL),
('TIX-FDF-003', 23, N'Ngô Thanh Tùng', 'tung.ngo@gmail.com', 'TIX-FDF-003|E17|STD|20260501', 0, NULL, NULL),
('TIX-IND-003', 24, N'Bùi Quốc Bảo', 'bao.bui@gmail.com', 'TIX-IND-003|E6|VIP|20260412', 0, NULL, NULL),
('TIX-IND-004', 24, N'Nguyễn Thùy Linh', 'linh.nguyen@gmail.com', 'TIX-IND-004|E6|VIP|20260412', 0, NULL, NULL),
('TIX-AIS-003', 25, N'Bùi Quốc Bảo', 'bao.bui@gmail.com', 'TIX-AIS-003|E26|STD|20260620', 0, NULL, NULL),
('TIX-FDF-004', 28, N'Lý Minh Châu', 'chau.ly@gmail.com', 'TIX-FDF-004|E17|WE|20260503', 0, NULL, NULL),
('TIX-MTM-003', 29, N'Phan Ngọc Diễm', 'diem.phan@gmail.com', 'TIX-MTM-003|E2|VIP|20260510', 0, NULL, NULL),
('TIX-DM-001', 30, N'Phan Ngọc Diễm', 'diem.phan@gmail.com', 'TIX-DM-001|E16|FULL|20260520', 0, NULL, NULL),
('TIX-FR-001', 31, N'Đặng Trung Kiên', 'kien.dang@gmail.com', 'TIX-FR-001|E12|VIP|20251115', 1, '2025-11-15 06:15:00', 7),
('TIX-NR-003', 32, N'Đặng Trung Kiên', 'kien.dang@gmail.com', 'TIX-NR-003|E10|10K|20260322', 0, NULL, NULL),
('TIX-HAT-005', 34, N'Nguyễn Hoàng Phúc', 'fullprofile@gmail.com', 'TIX-HAT-005|E1|SVIP|20260420', 0, NULL, NULL);
GO

PRINT '=== 40 tickets seeded (1 checked-in) ===';
GO

-- =============================================
-- =============================================
INSERT INTO PaymentTransactions (order_id, payment_method, seepay_transaction_id, amount, status, completed_at) VALUES
(1,  'seepay', 'SP-202602-001', 7500000, 'completed', DATEADD(DAY,-30,GETDATE())),
(2,  'seepay', 'SP-202602-002', 4000000, 'completed', DATEADD(DAY,-25,GETDATE())),
(3,  'seepay', 'SP-202602-003', 500000,  'completed', DATEADD(DAY,-22,GETDATE())),
(4,  'seepay', 'SP-202602-004', 600000,  'completed', DATEADD(DAY,-18,GETDATE())),
(5,  'seepay', 'SP-202603-005', 500000,  'completed', DATEADD(DAY,-10,GETDATE())),
(6,  'seepay', 'SP-202603-006', 1000000, 'completed', DATEADD(DAY,-8,GETDATE())),
(7,  'seepay', NULL,            2000000, 'pending',   NULL),
(8,  'seepay', 'SP-202602-008', 5000000, 'completed', DATEADD(DAY,-28,GETDATE())),
(9,  'seepay', 'SP-202602-009', 3000000, 'completed', DATEADD(DAY,-15,GETDATE())),
(10, 'seepay', 'SP-202603-010', 200000,  'completed', DATEADD(DAY,-12,GETDATE())),
(11, 'seepay', 'SP-202603-011', 510000,  'completed', DATEADD(DAY,-7,GETDATE())),
(12, 'seepay', 'SP-202602-012', 4000000, 'completed', DATEADD(DAY,-20,GETDATE())),
(13, 'seepay', NULL,            800000,  'cancelled', NULL),
(14, 'seepay', 'SP-202601-014', 800000,  'completed', DATEADD(DAY,-35,GETDATE())),
(15, 'seepay', 'SP-202601-015', 800000,  'completed', DATEADD(DAY,-45,GETDATE())),
(16, 'cash',   NULL,            0,       'completed', DATEADD(DAY,-8,GETDATE())),
(17, 'seepay', 'SP-202603-017', 1200000, 'completed', DATEADD(DAY,-6,GETDATE())),
(18, 'seepay', 'SP-202601-018', 300000,  'completed', DATEADD(DAY,-42,GETDATE())),
(19, 'seepay', 'SP-202603-019', 300000,  'completed', DATEADD(DAY,-9,GETDATE())),
(20, 'seepay', 'SP-202603-020', 500000,  'completed', DATEADD(DAY,-5,GETDATE())),
(21, 'seepay', 'SP-202602-021', 1200000, 'completed', DATEADD(DAY,-15,GETDATE())),
(22, 'seepay', 'SP-202603-022', 2400000, 'completed', DATEADD(DAY,-10,GETDATE())),
(23, 'seepay', 'SP-202603-023', 50000,   'completed', DATEADD(DAY,-4,GETDATE())),
(24, 'seepay', 'SP-202603-024', 2040000, 'completed', DATEADD(DAY,-12,GETDATE())),
(25, 'seepay', 'SP-202603-025', 1450000, 'completed', DATEADD(DAY,-6,GETDATE())),
(26, 'seepay', 'SP-202602-026', 2000000, 'refunded',  DATEADD(DAY,-20,GETDATE())),
(27, 'seepay', 'SP-202602-027', 1500000, 'refunded',  DATEADD(DAY,-14,GETDATE())),
(28, 'seepay', 'SP-202603-028', 80000,   'completed', DATEADD(DAY,-3,GETDATE())),
(29, 'seepay', 'SP-202602-029', 3500000, 'completed', DATEADD(DAY,-16,GETDATE())),
(30, 'seepay', 'SP-202603-030', 2500000, 'completed', DATEADD(DAY,-9,GETDATE())),
(31, 'seepay', 'SP-202510-031', 500000,  'completed', '2025-10-20'),
(32, 'seepay', 'SP-202602-032', 400000,  'completed', DATEADD(DAY,-30,GETDATE())),
(33, 'seepay', NULL,            500000,  'cancelled', NULL),
(34, 'seepay', 'SP-202602-034', 5000000, 'completed', DATEADD(DAY,-26,GETDATE())),
(35, 'seepay', 'SP-202602-035', 500000,  'refunded',  DATEADD(DAY,-15,GETDATE()));
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
(2, 11, 90000,  DATEADD(DAY,-7,GETDATE())),   -- LIVENATION15 on O11 (Bình — Triển lãm)
(6, 24, 360000, DATEADD(DAY,-12,GETDATE())),  -- SUNSET10 on O24 (Bảo — Indie Sunset) — wait, 10% of 2.4M = 240K
(3, 25, 50000,  DATEADD(DAY,-6,GETDATE()));    -- AITECH50K on O25 (Bảo — AI Summit)
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
 'resolved', 'high', 'admin', 2, DATEADD(DAY,-29,GETDATE()), DATEADD(DAY,-29,GETDATE())),

('SPT-002', 10, NULL, 2, 'event_issue',
 N'Hỏi dress code liveshow Mỹ Tâm',
 N'Liveshow có yêu cầu dress code không? Khu VIP có tặng đồ uống không?',
 'closed', 'low', 'organizer', NULL, DATEADD(DAY,-18,GETDATE()), DATEADD(DAY,-19,GETDATE())),

('SPT-003', 11, 13, 3, 'cancellation',
 N'Yêu cầu hủy đơn hàng ORD-2026-0013',
 N'Thay đổi lịch cá nhân, xin hủy đơn và hoàn tiền. Đã thanh toán qua SeePay.',
 'in_progress', 'normal', 'admin', 2, NULL, DATEADD(DAY,-17,GETDATE())),

('SPT-004', 12, NULL, 27, 'technical',
 N'Không tải được QR code vé Hackathon',
 N'QR code bị lỗi trắng trên Chrome Android 14. Đã clear cache.',
 'open', 'normal', 'admin', NULL, NULL, DATEADD(DAY,-3,GETDATE())),

('SPT-005', 13, NULL, NULL, 'feedback',
 N'Góp ý giao diện trang Vé của tôi',
 N'Trang Vé đẹp, muốn có thêm filter theo trạng thái vé. Cảm ơn team!',
 'open', 'low', 'admin', NULL, NULL, DATEADD(DAY,-1,GETDATE())),

('SPT-006', 18, 26, 3, 'refund',
 N'Yêu cầu hoàn tiền vé Sơn Tùng Sky Tour',
 N'Tôi không thể tham dự do bệnh. Xin hoàn tiền theo chính sách. Đơn: ORD-2026-0026.',
 'resolved', 'high', 'admin', 2, DATEADD(DAY,-18,GETDATE()), DATEADD(DAY,-19,GETDATE())),

('SPT-007', 16, NULL, NULL, 'account_issue',
 N'Email chưa xác minh — không nhận được mã',
 N'Tôi đăng ký tài khoản nhưng không nhận được email xác minh. Đã kiểm tra spam.',
 'in_progress', 'normal', 'admin', 3, NULL, DATEADD(DAY,-2,GETDATE())),

('SPT-008', 17, 24, 6, 'missing_ticket',
 N'Đã thanh toán nhưng thiếu 1 vé',
 N'Đơn ORD-2026-0024 mua 2 vé VIP Beach Lounge nhưng chỉ nhận được 1 email vé.',
 'open', 'high', 'admin', NULL, NULL, DATEADD(DAY,-1,GETDATE())),

('SPT-009', 20, NULL, 16, 'event_issue',
 N'Digital Marketing workshop có online không?',
 N'Tôi ở Hà Nội, có thể tham dự online được không?',
 'resolved', 'low', 'organizer', NULL, DATEADD(DAY,-7,GETDATE()), DATEADD(DAY,-8,GETDATE())),

('SPT-010', 18, 27, 1, 'refund',
 N'Hoàn tiền vé Hà Anh Tuấn — trùng lịch',
 N'Đơn ORD-2026-0027 trùng lịch công tác nước ngoài. Xin hoàn theo chính sách.',
 'open', 'urgent', 'admin', NULL, NULL, DATEADD(DAY,-1,GETDATE()));
GO

-- =============================================
-- =============================================
INSERT INTO TicketMessages (ticket_id, sender_id, content, is_internal, created_at) VALUES
(1, 9, N'Tôi đã thanh toán ORD-2026-0001, tiền đã trừ nhưng 30 phút chưa nhận email vé.', 0, DATEADD(DAY,-29,GETDATE())),
(1, 2, N'[Internal] SeePay dashboard: SP-202602-001 completed. Vé đã phát hành. Email bị spam filter.', 1, DATEADD(MINUTE,-1430,GETDATE())),
(1, 2, N'Chào anh An! Đơn hàng đã xác nhận thành công. Email đã gửi lại, kiểm tra spam nhé. Xin lỗi vì bất tiện!', 0, DATEADD(MINUTE,-1425,GETDATE())),
(1, 9, N'Đã nhận được email rồi ạ. Cảm ơn hỗ trợ nhanh!', 0, DATEADD(DAY,-28,GETDATE())),

(3, 11, N'Do thay đổi lịch, xin hủy ORD-2026-0013 và hoàn tiền.', 0, DATEADD(DAY,-17,GETDATE())),
(3, 2, N'Chào anh Cường, đã tiếp nhận. Hủy trước 7 ngày hoàn 80%. Xử lý trong 3-5 ngày làm việc.', 0, DATEADD(DAY,-16,GETDATE())),
(3, 11, N'Vâng, mong được xử lý sớm ạ. Cảm ơn.', 0, DATEADD(DAY,-16,GETDATE())),

(4, 12, N'QR code vé hackathon hiện ô trắng. Chrome Android 14, đã clear cache.', 0, DATEADD(DAY,-3,GETDATE())),

(6, 18, N'Bị bệnh không thể tham dự. Xin hoàn tiền ORD-2026-0026.', 0, DATEADD(DAY,-19,GETDATE())),
(6, 2, N'[Internal] Verify medical reason. Process refund 80%.', 1, DATEADD(DAY,-19,GETDATE())),
(6, 2, N'Chào chị Châu, đã xử lý hoàn tiền 80% (1.600.000đ). Tiền sẽ về trong 5-7 ngày.', 0, DATEADD(DAY,-18,GETDATE())),
(6, 18, N'Đã nhận được thông báo hoàn tiền. Cảm ơn!', 0, DATEADD(DAY,-18,GETDATE())),

(7, 16, N'Không nhận được email xác minh sau khi đăng ký. Đã kiểm tra spam.', 0, DATEADD(DAY,-2,GETDATE())),
(7, 3, N'Chào bạn, em kiểm tra hệ thống. Email yen.hoang@yahoo.com đã gửi nhưng bị bounce. Bạn kiểm tra lại email nhé.', 0, DATEADD(DAY,-2,GETDATE())),

(8, 17, N'Đơn ORD-2026-0024 mua 2 vé nhưng chỉ nhận 1 email. Kiểm tra giúp.', 0, DATEADD(DAY,-1,GETDATE())),

(9, 20, N'Workshop Digital Marketing có hỗ trợ online không ạ?', 0, DATEADD(DAY,-8,GETDATE())),

(10, 18, N'Trùng lịch công tác, xin hoàn vé HAT ORD-2026-0027. Rất gấp ạ.', 0, DATEADD(DAY,-1,GETDATE()));
GO

PRINT '=== 10 support tickets + 18 messages seeded ===';
GO

-- =============================================
-- =============================================
INSERT INTO ChatSessions (customer_id, agent_id, event_id, status, created_at, closed_at) VALUES
(9, 2, 1, 'closed', DATEADD(DAY,-28,GETDATE()), DATEADD(DAY,-28,GETDATE())),
(10, 2, NULL, 'closed', DATEADD(DAY,-18,GETDATE()), DATEADD(DAY,-18,GETDATE())),
(12, 2, 27, 'active', DATEADD(HOUR,-2,GETDATE()), NULL),
(15, NULL, NULL, 'waiting', DATEADD(MINUTE,-30,GETDATE()), NULL),
(18, 3, NULL, 'closed', DATEADD(DAY,-17,GETDATE()), DATEADD(DAY,-17,GETDATE())),
(20, 2, 2, 'active', DATEADD(MINUTE,-45,GETDATE()), NULL);

INSERT INTO ChatMessages (session_id, sender_id, content, created_at) VALUES
(1, 9,  N'Xin chào, tôi muốn hỏi về vé VIP Gold cho concert Hà Anh Tuấn ạ', DATEADD(DAY,-28,GETDATE())),
(1, 2,  N'Chào anh! VIP Gold: chỗ ngồi khu VIP trung tâm + đồ uống miễn phí tại lounge. Giá 3.000.000đ/vé ạ.', DATEADD(DAY,-28,GETDATE())),
(1, 9,  N'Lounge mở cửa từ mấy giờ ạ?', DATEADD(DAY,-28,GETDATE())),
(1, 2,  N'VIP Lounge mở từ 17:00 nhé anh. Check-in sớm để tận hưởng đồ uống trước show!', DATEADD(DAY,-28,GETDATE())),
(1, 9,  N'OK cảm ơn nhiều nhé!', DATEADD(DAY,-28,GETDATE())),

(2, 10, N'Mình muốn hỏi chính sách hoàn vé ạ?', DATEADD(DAY,-18,GETDATE())),
(2, 2,  N'Chào bạn! Hủy trước 7 ngày → hoàn 80%, 3-7 ngày → 50%, dưới 3 ngày → không hoàn.', DATEADD(DAY,-18,GETDATE())),
(2, 10, N'Mình chỉ hỏi thôi ạ. Cảm ơn!', DATEADD(DAY,-18,GETDATE())),

(3, 12, N'QR code vé hackathon bị lỗi, không hiển thị được ạ', DATEADD(HOUR,-2,GETDATE())),
(3, 2,  N'Chào anh! Anh thử đổi sang trình duyệt khác xem sao ạ? Hoặc gửi mã vé em tra giúp.', DATEADD(HOUR,-1,GETDATE())),
(3, 12, N'Mã vé là TIX-HKT-001 ạ', DATEADD(MINUTE,-55,GETDATE())),
(3, 2,  N'Em đã kiểm tra, QR code vẫn hợp lệ. Anh thử mở trên Safari hoặc Firefox nhé.', DATEADD(MINUTE,-50,GETDATE())),

(4, 15, N'Cho hỏi thanh toán bằng chuyển khoản ngân hàng được không ạ?', DATEADD(MINUTE,-30,GETDATE())),

(5, 18, N'Tôi đã yêu cầu hoàn tiền, bao lâu thì nhận được ạ?', DATEADD(DAY,-17,GETDATE())),
(5, 3,  N'Hoàn tiền qua SeePay thường mất 5-7 ngày làm việc kể từ khi xác nhận ạ.', DATEADD(DAY,-17,GETDATE())),
(5, 18, N'Vâng cảm ơn.', DATEADD(DAY,-17,GETDATE())),

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
(1, 'APPROVE_EVENT', 'Event', 1, N'Approved event: Hà Anh Tuấn Concert 2026', '192.168.1.100', DATEADD(DAY,-40,GETDATE())),
(1, 'APPROVE_EVENT', 'Event', 2, N'Approved event: Mỹ Tâm Liveshow My Soul 1981', '192.168.1.100', DATEADD(DAY,-39,GETDATE())),
(1, 'APPROVE_EVENT', 'Event', 3, N'Approved event: Sơn Tùng M-TP Sky Tour Encore', '192.168.1.100', DATEADD(DAY,-38,GETDATE())),
(1, 'REJECT_EVENT', 'Event', 7, N'Rejected event: Karaoke Đại Hội Test — Nội dung không đủ thông tin', '192.168.1.100', DATEADD(DAY,-35,GETDATE())),
(1, 'REJECT_EVENT', 'Event', 22, N'Rejected event: Triển lãm Ảnh Không Phép — Chưa có giấy phép', '192.168.1.100', DATEADD(DAY,-34,GETDATE())),
(1, 'REJECT_EVENT', 'Event', 25, N'Rejected event: Crypto Investment Night — Thiếu thông tin pháp lý', '192.168.1.100', DATEADD(DAY,-33,GETDATE())),
(1, 'APPROVE_EVENT', 'Event', 26, N'Approved event: Vietnam AI Summit 2026 (featured)', '192.168.1.100', DATEADD(DAY,-30,GETDATE())),
(1, 'FEATURE_EVENT', 'Event', 26, N'Marked event as featured', '192.168.1.100', DATEADD(DAY,-30,GETDATE())),
(1, 'PIN_EVENT', 'Event', 26, N'Pinned event: Vietnam AI Summit 2026', '192.168.1.100', DATEADD(DAY,-30,GETDATE())),
(1, 'LOCK_USER', 'User', 22, N'Locked user: Nguyễn Bị Khóa (banned.user@test.com) — vi phạm chính sách', '192.168.1.100', DATEADD(DAY,-28,GETDATE())),
(1, 'DELETE_USER', 'User', 23, N'Soft-deleted user: Trần Đã Xóa (deleted.user@test.com)', '192.168.1.100', DATEADD(DAY,-27,GETDATE())),
(1, 'CHANGE_ROLE', 'User', 4, N'Changed role: organizer@ticketbox.vn → organizer (verified organizer)', '192.168.1.100', DATEADD(DAY,-45,GETDATE())),
(2, 'RESOLVE_TICKET', 'SupportTicket', 1, N'Resolved support ticket SPT-001: Payment email issue', '10.0.0.50', DATEADD(DAY,-29,GETDATE())),
(2, 'PROCESS_REFUND', 'Order', 26, N'Processed refund for ORD-2026-0026 (80% = 1,600,000đ)', '10.0.0.50', DATEADD(DAY,-18,GETDATE())),
(2, 'RESOLVE_TICKET', 'SupportTicket', 6, N'Resolved support ticket SPT-006: Refund completed', '10.0.0.50', DATEADD(DAY,-18,GETDATE())),
(3, 'ASSIGN_TICKET',  'SupportTicket', 7, N'Self-assigned support ticket SPT-007', '10.0.0.51', DATEADD(DAY,-2,GETDATE())),
(1, 'CREATE_VOUCHER', 'Voucher', 9, N'Created system voucher SYSLAUNCH50 (50K fixed)', '192.168.1.100', DATEADD(DAY,-50,GETDATE())),
(1, 'CREATE_VOUCHER', 'Voucher', 10, N'Created system voucher SYSVIP10 (10% up to 500K)', '192.168.1.100', DATEADD(DAY,-48,GETDATE())),
(1, 'CANCEL_ORDER', 'Order', 48, N'Admin cancelled ORD-2026-0048 — customer request', '192.168.1.100', DATEADD(DAY,-7,GETDATE())),
(1, 'UPDATE_SETTINGS', 'SiteSettings', NULL, N'Updated chat_enabled=true, require_event_approval=true', '192.168.1.100', DATEADD(DAY,-55,GETDATE())),
(1, 'SYSTEM_STARTUP', NULL, NULL, N'System initialized — all services online', '127.0.0.1', DATEADD(DAY,-60,GETDATE())),
(1, 'APPROVE_EVENT', 'Event', 8, N'Approved event: Vietnam Marathon Đà Nẵng 2026', '192.168.1.100', DATEADD(DAY,-25,GETDATE())),
(1, 'APPROVE_EVENT', 'Event', 17, N'Approved event: Lễ hội Ẩm thực Đường phố Sài Gòn 2026', '192.168.1.100', DATEADD(DAY,-22,GETDATE())),
(1, 'APPROVE_EVENT', 'Event', 13, N'Approved event: Workshop UI/UX Design', '192.168.1.100', DATEADD(DAY,-20,GETDATE())),
(2, 'CLOSE_TICKET',  'SupportTicket', 2, N'Closed support ticket SPT-002', '10.0.0.50', DATEADD(DAY,-18,GETDATE())),
(1, 'APPROVE_EVENT', 'Event', 27, N'Approved event: Hackathon Build for Vietnam 2026', '192.168.1.100', DATEADD(DAY,-15,GETDATE())),
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
(1, 'new_event',    N'Sự kiện mới chờ duyệt',        N'EDM Neon Jungle Festival 2026 đang chờ admin duyệt.', '/admin/events/5', 1, DATEADD(DAY,-20,GETDATE())),
(1, 'new_event',    N'Sự kiện mới chờ duyệt',        N'Giải Bơi Lội TP.HCM Mùa Hè 2026 đang chờ duyệt.',     '/admin/events/11', 0, DATEADD(DAY,-10,GETDATE())),
(1, 'new_event',    N'Sự kiện mới chờ duyệt',        N'Hội nghị Du lịch & Hospitality 2026 chờ duyệt.',       '/admin/events/24', 0, DATEADD(DAY,-8,GETDATE())),
(1, 'new_event',    N'Sự kiện mới chờ duyệt',        N'Tech Career Fair 2026 đang chờ admin duyệt.',           '/admin/events/28', 0, DATEADD(DAY,-5,GETDATE())),
(1, 'support',      N'Support ticket cấp bách',       N'SPT-010: Yêu cầu hoàn tiền urgent từ Lý Minh Châu.',  '/admin/support/10', 0, DATEADD(DAY,-1,GETDATE())),
(1, 'support',      N'Support ticket mới',            N'SPT-008: Thiếu vé — Bùi Quốc Bảo cần kiểm tra.',      '/admin/support/8', 0, DATEADD(DAY,-1,GETDATE())),
(1, 'system',       N'Hệ thống khởi động thành công', N'Tất cả services đã online. Version 2026-03-18.',       '/admin/dashboard', 1, DATEADD(DAY,-60,GETDATE())),
(1, 'order',        N'Đơn hàng bị hủy',              N'ORD-2026-0048 (Lê Hoàng Cường) đã bị hủy.',           '/admin/orders/48', 1, DATEADD(DAY,-7,GETDATE())),
(1, 'refund',       N'Hoàn tiền xử lý',              N'ORD-2026-0049 (Lý Minh Châu) đã hoàn tiền thành công.','/admin/orders/49', 1, DATEADD(DAY,-8,GETDATE())),
(2, 'support',      N'Ticket mới được gán',           N'SPT-001: Thanh toán thành công nhưng chưa nhận vé.',   '/admin/support/1', 1, DATEADD(DAY,-29,GETDATE())),
(2, 'support',      N'Ticket mới được gán',           N'SPT-003: Yêu cầu hủy đơn ORD-2026-0013.',             '/admin/support/3', 1, DATEADD(DAY,-17,GETDATE())),
(2, 'support',      N'Ticket mới được gán',           N'SPT-006: Yêu cầu hoàn tiền vé Sơn Tùng.',             '/admin/support/6', 1, DATEADD(DAY,-19,GETDATE())),
(2, 'chat',         N'Chat mới cần hỗ trợ',           N'Phạm Minh Đức đang hỏi về QR code vé Hackathon.',     '/admin/chat', 0, DATEADD(HOUR,-2,GETDATE())),
(2, 'chat',         N'Chat mới cần hỗ trợ',           N'Phan Ngọc Diễm hỏi về liveshow Mỹ Tâm.',              '/admin/chat', 0, DATEADD(MINUTE,-45,GETDATE())),
(3, 'support',      N'Ticket mới được gán',           N'SPT-007: Email chưa xác minh — cần kiểm tra.',        '/admin/support/7', 0, DATEADD(DAY,-2,GETDATE())),
(4, 'event_approved', N'Sự kiện được duyệt',          N'Hà Anh Tuấn Concert 2026 đã được admin duyệt!',       '/organizer/events/1', 1, DATEADD(DAY,-40,GETDATE())),
(4, 'event_approved', N'Sự kiện được duyệt',          N'Mỹ Tâm Liveshow My Soul 1981 đã được duyệt!',         '/organizer/events/2', 1, DATEADD(DAY,-39,GETDATE())),
(4, 'new_order',    N'Đơn hàng mới',                  N'ORD-2026-0001: 7,500,000đ cho Hà Anh Tuấn Concert.',  '/organizer/events/1/orders', 1, DATEADD(DAY,-30,GETDATE())),
(4, 'event_rejected', N'Sự kiện bị từ chối',          N'Karaoke Đại Hội Test bị từ chối. Lý do: thiếu thông tin.', '/organizer/events/7', 1, DATEADD(DAY,-35,GETDATE())),
(6, 'event_approved', N'Sự kiện được duyệt',          N'Vietnam AI Summit 2026 đã được duyệt + featured!',    '/organizer/events/26', 1, DATEADD(DAY,-30,GETDATE())),
(6, 'new_order',    N'Đơn hàng mới',                  N'ORD-2026-0043: 1,450,000đ cho AI Summit.',             '/organizer/events/26/orders', 0, DATEADD(DAY,-4,GETDATE())),
(7, 'event_approved', N'Sự kiện được duyệt',          N'Vietnam Marathon Đà Nẵng 2026 đã được duyệt!',        '/organizer/events/8', 1, DATEADD(DAY,-25,GETDATE())),
(7, 'new_order',    N'Đơn hàng mới',                  N'ORD-2026-0042: 1,100,000đ cho Marathon Full 42K.',     '/organizer/events/8/orders', 0, DATEADD(DAY,-3,GETDATE())),
(5, 'event_approved', N'Sự kiện được duyệt',          N'Lễ hội Ẩm thực Đường phố Sài Gòn 2026 đã được duyệt!', '/organizer/events/17', 1, DATEADD(DAY,-22,GETDATE())),
(5, 'support_routed', N'Support ticket chuyển đến bạn', N'SPT-002: Khách hỏi dress code liveshow — chuyển cho BTC.', '/organizer/support/2', 1, DATEADD(DAY,-19,GETDATE()));
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
(36, 'seepay', 'SP-202603-036', 1350000, 'completed', DATEADD(DAY,-5,GETDATE())),
(37, 'seepay', 'SP-202603-037', 1950000, 'completed', DATEADD(DAY,-4,GETDATE())),
(38, 'seepay', 'SP-202603-038', 220000,  'completed', DATEADD(DAY,-3,GETDATE())),
(39, 'seepay', 'SP-202603-039', 600000,  'completed', DATEADD(DAY,-2,GETDATE())),
(40, 'seepay', 'SP-202603-040', 2700000, 'completed', DATEADD(DAY,-2,GETDATE())),
(41, 'seepay', 'SP-202603-041', 1950000, 'completed', DATEADD(DAY,-1,GETDATE())),
(42, 'seepay', 'SP-202603-042', 1100000, 'completed', DATEADD(DAY,-3,GETDATE())),
(43, 'seepay', 'SP-202603-043', 1450000, 'completed', DATEADD(DAY,-4,GETDATE())),
(44, 'seepay', 'SP-202603-044', 128000,  'completed', DATEADD(DAY,-2,GETDATE())),
(45, 'seepay', 'SP-202603-045', 1440000, 'completed', DATEADD(DAY,-3,GETDATE())),
(46, 'seepay', 'SP-202603-046', 1500000, 'completed', DATEADD(DAY,-5,GETDATE())),
(47, 'seepay', 'SP-202603-047', 100000,  'completed', DATEADD(DAY,-6,GETDATE())),
(48, 'seepay', NULL,            2950000, 'cancelled', NULL),
(49, 'seepay', 'SP-202603-049', 450000,  'refunded',  DATEADD(DAY,-8,GETDATE())),
(50, 'seepay', NULL,            470000,  'pending',   NULL);
GO

INSERT INTO VoucherUsages (voucher_id, order_id, discount_applied, used_at) VALUES
(10, 36, 150000, DATEADD(DAY,-5,GETDATE())),  -- SYSVIP10 on O36
(9,  37, 50000,  DATEADD(DAY,-4,GETDATE())),  -- SYSLAUNCH50 on O37
(12, 38, 30000,  DATEADD(DAY,-3,GETDATE())),  -- SYSWELCOME30 on O38
(11, 39, 200000, DATEADD(DAY,-2,GETDATE())),  -- SYSFLASH200K on O39
(10, 40, 300000, DATEADD(DAY,-2,GETDATE())),  -- SYSVIP10 on O40
(9,  41, 50000,  DATEADD(DAY,-1,GETDATE())),  -- SYSLAUNCH50 on O41
(4,  42, 100000, DATEADD(DAY,-3,GETDATE())),  -- RUN2026 on O42
(3,  43, 50000,  DATEADD(DAY,-4,GETDATE())),  -- AITECH50K on O43
(5,  44, 32000,  DATEADD(DAY,-2,GETDATE())),  -- FOODIE20 on O44
(1,  45, 160000, DATEADD(DAY,-3,GETDATE())),  -- HAT2026VIP on O45
(9,  48, 50000,  DATEADD(DAY,-7,GETDATE())),  -- SYSLAUNCH50 on O48 (cancelled)
(10, 49, 50000,  DATEADD(DAY,-8,GETDATE())),  -- SYSVIP10 on O49 (refunded)
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
(1, 'login',            'user',    1,  N'Admin đăng nhập',                    '192.168.1.100', DATEADD(DAY,-30,GETDATE())),
(1, 'approve_event',    'event',   1,  N'Phê duyệt sự kiện: Đêm nhạc Hà Anh Tuấn',  '192.168.1.100', DATEADD(DAY,-28,GETDATE())),
(1, 'approve_event',    'event',   2,  N'Phê duyệt sự kiện: Rock Storm 2026', '192.168.1.100', DATEADD(DAY,-27,GETDATE())),
(1, 'approve_event',    'event',   3,  N'Phê duyệt sự kiện: Food Festival',   '192.168.1.100', DATEADD(DAY,-26,GETDATE())),
(1, 'approve_event',    'event',   4,  N'Phê duyệt sự kiện: AI Summit',       '192.168.1.100', DATEADD(DAY,-25,GETDATE())),
(1, 'approve_event',    'event',   5,  N'Phê duyệt sự kiện: Run Marathon',    '192.168.1.100', DATEADD(DAY,-24,GETDATE())),
(1, 'feature_event',    'event',   1,  N'Đánh dấu nổi bật sự kiện #1',       '192.168.1.100', DATEADD(DAY,-28,GETDATE())),
(1, 'feature_event',    'event',   2,  N'Đánh dấu nổi bật sự kiện #2',       '192.168.1.100', DATEADD(DAY,-27,GETDATE())),
(1, 'update_settings',  'setting', NULL, N'Cập nhật platform_fee_percent = 5', '192.168.1.100', DATEADD(DAY,-20,GETDATE())),
(1, 'ban_user',         'user',    22, N'Khóa tài khoản: banned.user@test.com','192.168.1.100', DATEADD(DAY,-15,GETDATE())),
(1, 'resolve_ticket',   'ticket',  1,  N'Xử lý xong support ticket #1',       '192.168.1.100', DATEADD(DAY,-10,GETDATE())),
(1, 'refund_order',     'order',   49, N'Hoàn tiền đơn hàng O49',             '192.168.1.100', DATEADD(DAY,-8, GETDATE())),

(2, 'login',            'user',    2,  N'Support agent đăng nhập',            '10.0.0.50',     DATEADD(DAY,-25,GETDATE())),
(2, 'assign_ticket',    'ticket',  2,  N'Tiếp nhận xử lý ticket #2',         '10.0.0.50',     DATEADD(DAY,-12,GETDATE())),
(3, 'login',            'user',    3,  N'Support agent 2 đăng nhập',          '10.0.0.51',     DATEADD(DAY,-20,GETDATE())),

(4, 'login',            'user',    4,  N'Organizer Live Nation đăng nhập',     '172.16.0.10',   DATEADD(DAY,-29,GETDATE())),
(4, 'create_event',     'event',   1,  N'Tạo sự kiện: Đêm nhạc Hà Anh Tuấn', '172.16.0.10',   DATEADD(DAY,-29,GETDATE())),
(4, 'create_event',     'event',   2,  N'Tạo sự kiện: Rock Storm 2026',       '172.16.0.10',   DATEADD(DAY,-28,GETDATE())),
(4, 'upload_media',     'event',   1,  N'Upload banner sự kiện #1',           '172.16.0.10',   DATEADD(DAY,-29,GETDATE())),
(4, 'update_event',     'event',   1,  N'Cập nhật chi tiết sự kiện #1',       '172.16.0.10',   DATEADD(DAY,-20,GETDATE())),
(5, 'login',            'user',    5,  N'VieTravel organizer đăng nhập',       '172.16.0.11',   DATEADD(DAY,-25,GETDATE())),
(5, 'create_event',     'event',   3,  N'Tạo sự kiện: Food Festival',         '172.16.0.11',   DATEADD(DAY,-25,GETDATE())),
(6, 'login',            'user',    6,  N'TechViet organizer đăng nhập',        '172.16.0.12',   DATEADD(DAY,-26,GETDATE())),
(6, 'create_event',     'event',   4,  N'Tạo sự kiện: AI Summit',             '172.16.0.12',   DATEADD(DAY,-26,GETDATE())),

(9, 'login',            'user',    9,  N'Customer An đăng nhập',              '203.162.4.10',  DATEADD(DAY,-20,GETDATE())),
(9, 'purchase_ticket',  'order',   1,  N'Mua vé sự kiện #1',                 '203.162.4.10',  DATEADD(DAY,-19,GETDATE())),
(10,'login',            'user',    10, N'Customer Bình đăng nhập',            '203.162.4.11',  DATEADD(DAY,-18,GETDATE())),
(10,'purchase_ticket',  'order',   2,  N'Mua vé sự kiện #2',                 '203.162.4.11',  DATEADD(DAY,-17,GETDATE())),
(11,'login',            'user',    11, N'Customer Chi đăng nhập',             '203.162.4.12',  DATEADD(DAY,-16,GETDATE())),
(11,'purchase_ticket',  'order',   3,  N'Mua vé sự kiện #1',                 '203.162.4.12',  DATEADD(DAY,-15,GETDATE()));
GO

PRINT '=== ActivityLog seeded (30 entries) ===';
GO

-- =============================================
-- =============================================
INSERT INTO Notifications (user_id, type, title, message, link, is_read, created_at) VALUES
(1, 'event_pending',     N'Sự kiện mới chờ phê duyệt',      N'Sự kiện "Summer Beats 2026" cần được phê duyệt',            '/admin/events?status=pending',  1, DATEADD(DAY,-25,GETDATE())),
(1, 'support_ticket',    N'Support ticket mới',               N'Khách hàng báo cáo lỗi thanh toán — ticket #TK-001',        '/admin/support/1',              1, DATEADD(DAY,-15,GETDATE())),
(1, 'system_alert',      N'Doanh thu tuần vượt mốc',         N'Tổng doanh thu tuần đạt 50,000,000 VND',                     '/admin/dashboard',              0, DATEADD(DAY,-5, GETDATE())),
(1, 'refund_request',    N'Yêu cầu hoàn tiền',               N'Đơn hàng O49 yêu cầu hoàn tiền 600,000 VND',                '/admin/orders/49',              1, DATEADD(DAY,-8, GETDATE())),

(2, 'ticket_assigned',   N'Ticket được giao cho bạn',         N'Ticket #TK-002 đã được giao cho bạn xử lý',                '/support/tickets/2',            1, DATEADD(DAY,-12,GETDATE())),
(2, 'ticket_reply',      N'Khách hàng phản hồi',             N'Có phản hồi mới trong ticket #TK-002',                      '/support/tickets/2',            0, DATEADD(DAY,-10,GETDATE())),
(3, 'ticket_assigned',   N'Ticket được giao cho bạn',         N'Ticket #TK-003 đã được giao cho bạn xử lý',                '/support/tickets/3',            0, DATEADD(DAY,-8, GETDATE())),

(4, 'event_approved',    N'Sự kiện được phê duyệt',          N'Sự kiện "Đêm nhạc Hà Anh Tuấn" đã được phê duyệt',         '/organizer/events/1',           1, DATEADD(DAY,-28,GETDATE())),
(4, 'ticket_sold',       N'Có vé được bán',                  N'2 vé VIP sự kiện "Đêm nhạc Hà Anh Tuấn" vừa được bán',     '/organizer/events/1/orders',    1, DATEADD(DAY,-19,GETDATE())),
(4, 'ticket_sold',       N'Có vé được bán',                  N'3 vé Rock Storm 2026 vừa được bán',                         '/organizer/events/2/orders',    0, DATEADD(DAY,-17,GETDATE())),
(4, 'payout_ready',      N'Thanh toán sẵn sàng',             N'Tổng 4,500,000 VND sẵn sàng thanh toán cho tháng 2',        '/organizer/payouts',            0, DATEADD(DAY,-3, GETDATE())),
(5, 'event_approved',    N'Sự kiện được phê duyệt',          N'Sự kiện "Food Festival Sài Gòn" đã được phê duyệt',        '/organizer/events/3',           1, DATEADD(DAY,-26,GETDATE())),
(6, 'event_approved',    N'Sự kiện được phê duyệt',          N'Sự kiện "AI Summit 2026" đã được phê duyệt',               '/organizer/events/4',           1, DATEADD(DAY,-25,GETDATE())),

(9,  'order_confirmed',  N'Đặt vé thành công',               N'Bạn đã đặt thành công 2 vé VIP — Đêm nhạc Hà Anh Tuấn',   '/my-tickets',                   1, DATEADD(DAY,-19,GETDATE())),
(9,  'event_reminder',   N'Sự kiện sắp diễn ra',             N'Đêm nhạc Hà Anh Tuấn diễn ra sau 3 ngày nữa!',            '/events/1',                     0, DATEADD(DAY,-4, GETDATE())),
(10, 'order_confirmed',  N'Đặt vé thành công',               N'Bạn đã đặt thành công 1 vé — Rock Storm 2026',             '/my-tickets',                   1, DATEADD(DAY,-17,GETDATE())),
(11, 'order_confirmed',  N'Đặt vé thành công',               N'Bạn đã đặt thành công 3 vé — Đêm nhạc Hà Anh Tuấn',       '/my-tickets',                   1, DATEADD(DAY,-15,GETDATE())),
(12, 'order_confirmed',  N'Đặt vé thành công',               N'Đặt vé Food Festival thành công',                          '/my-tickets',                   1, DATEADD(DAY,-14,GETDATE())),
(13, 'order_confirmed',  N'Đặt vé thành công',               N'Đặt vé AI Summit 2026 thành công',                         '/my-tickets',                   0, DATEADD(DAY,-12,GETDATE())),
(14, 'order_confirmed',  N'Đặt vé thành công',               N'Đặt vé Run Marathon thành công',                           '/my-tickets',                   1, DATEADD(DAY,-11,GETDATE())),
(15, 'order_cancelled',  N'Đơn hàng bị hủy',                 N'Đơn hàng O48 đã bị hủy — liên hệ support',                '/support',                      1, DATEADD(DAY,-7, GETDATE())),
(16, 'refund_completed', N'Hoàn tiền thành công',             N'Đơn hàng O49 đã được hoàn tiền 600,000 VND',              '/my-orders',                    0, DATEADD(DAY,-6, GETDATE())),
(17, 'promotion',        N'Khuyến mãi đặc biệt',             N'Giảm 50% cho sự kiện tiếp theo! Dùng mã SYSLAUNCH50',     '/events',                       0, DATEADD(DAY,-10,GETDATE())),
(18, 'promotion',        N'Khuyến mãi đặc biệt',             N'Flash sale vé Rock Storm — chỉ hôm nay!',                 '/events/2',                     0, DATEADD(DAY,-9, GETDATE()));
GO

PRINT '=== Notifications seeded (24 entries) ===';
GO

-- =============================================
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