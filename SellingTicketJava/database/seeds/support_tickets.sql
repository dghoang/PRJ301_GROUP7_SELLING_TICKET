-- =====================================================
-- SUPPORT TICKET + CHAT SYSTEM v2
-- Enhanced: Routing, VIP Tiers, Anti-Spam, Pagination
-- =====================================================

-- Update Users role constraint to include support_agent
ALTER TABLE Users DROP CONSTRAINT IF EXISTS CK_Users_role;
ALTER TABLE Users ADD CONSTRAINT CK_Users_role
    CHECK (role IN ('customer', 'organizer', 'admin', 'support_agent'));

-- =====================================================
-- SUPPORT TICKETS
-- =====================================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'SupportTickets')
CREATE TABLE SupportTickets (
    ticket_id INT IDENTITY(1,1) PRIMARY KEY,
    ticket_code NVARCHAR(20) NOT NULL UNIQUE,
    user_id INT NOT NULL FOREIGN KEY REFERENCES Users(user_id),
    order_id INT NULL FOREIGN KEY REFERENCES Orders(order_id),
    event_id INT NULL FOREIGN KEY REFERENCES Events(event_id),
    category NVARCHAR(30) NOT NULL DEFAULT 'other'
        CHECK (category IN (
            'payment_error', 'missing_ticket', 'cancellation', 'refund',
            'event_issue', 'account_issue', 'technical', 'feedback', 'other'
        )),
    subject NVARCHAR(200) NOT NULL,
    description NVARCHAR(MAX) NOT NULL,
    status NVARCHAR(20) NOT NULL DEFAULT 'open'
        CHECK (status IN ('open', 'in_progress', 'resolved', 'closed')),
    priority NVARCHAR(10) NOT NULL DEFAULT 'normal'
        CHECK (priority IN ('low', 'normal', 'high', 'urgent')),
    routed_to NVARCHAR(20) NOT NULL DEFAULT 'admin'
        CHECK (routed_to IN ('admin', 'organizer')),
    assigned_to INT NULL FOREIGN KEY REFERENCES Users(user_id),
    resolved_at DATETIME NULL,
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME DEFAULT GETDATE()
);

-- Indexes for fast filtering
CREATE INDEX IX_SupportTickets_user ON SupportTickets(user_id);
CREATE INDEX IX_SupportTickets_status ON SupportTickets(status);
CREATE INDEX IX_SupportTickets_event ON SupportTickets(event_id);
CREATE INDEX IX_SupportTickets_routed ON SupportTickets(routed_to, status);
CREATE INDEX IX_SupportTickets_priority ON SupportTickets(priority, created_at);

-- =====================================================
-- TICKET MESSAGES (conversation thread)
-- =====================================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'TicketMessages')
CREATE TABLE TicketMessages (
    message_id INT IDENTITY(1,1) PRIMARY KEY,
    ticket_id INT NOT NULL FOREIGN KEY REFERENCES SupportTickets(ticket_id),
    sender_id INT NOT NULL FOREIGN KEY REFERENCES Users(user_id),
    content NVARCHAR(MAX) NOT NULL,
    is_internal BIT DEFAULT 0,
    created_at DATETIME DEFAULT GETDATE()
);

CREATE INDEX IX_TicketMessages_ticket ON TicketMessages(ticket_id, created_at);

-- =====================================================
-- CHAT SESSIONS (anti-spam: max 1 active per customer, 30 min cooldown)
-- =====================================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'ChatSessions')
CREATE TABLE ChatSessions (
    session_id INT IDENTITY(1,1) PRIMARY KEY,
    customer_id INT NOT NULL FOREIGN KEY REFERENCES Users(user_id),
    agent_id INT NULL FOREIGN KEY REFERENCES Users(user_id),
    event_id INT NULL FOREIGN KEY REFERENCES Events(event_id),
    status NVARCHAR(10) DEFAULT 'waiting'
        CHECK (status IN ('waiting', 'active', 'closed')),
    created_at DATETIME DEFAULT GETDATE(),
    closed_at DATETIME NULL
);

-- Indexes for anti-spam queries
CREATE INDEX IX_ChatSessions_customer_status ON ChatSessions(customer_id, status);
CREATE INDEX IX_ChatSessions_customer_closed ON ChatSessions(customer_id, status, closed_at);
CREATE INDEX IX_ChatSessions_status ON ChatSessions(status);

-- =====================================================
-- CHAT MESSAGES (cursor pagination via message_id, capped at TOP 50)
-- =====================================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'ChatMessages')
CREATE TABLE ChatMessages (
    message_id INT IDENTITY(1,1) PRIMARY KEY,
    session_id INT NOT NULL FOREIGN KEY REFERENCES ChatSessions(session_id),
    sender_id INT NOT NULL FOREIGN KEY REFERENCES Users(user_id),
    content NVARCHAR(500) NOT NULL, -- Max 500 chars enforced at DB level
    created_at DATETIME DEFAULT GETDATE()
);

-- Covering index for cursor-based polling (WHERE session_id=? AND message_id > ?)
CREATE INDEX IX_ChatMessages_cursor ON ChatMessages(session_id, message_id) INCLUDE (sender_id, content, created_at);

-- =====================================================
-- MIGRATION: Add routed_to to existing SupportTickets
-- (Safe to run multiple times)
-- =====================================================
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('SupportTickets') AND name = 'routed_to')
BEGIN
    ALTER TABLE SupportTickets ADD routed_to NVARCHAR(20) NOT NULL DEFAULT 'admin';
    ALTER TABLE SupportTickets ADD CONSTRAINT CK_SupportTickets_routed CHECK (routed_to IN ('admin', 'organizer'));
END

-- Update existing category constraint for new categories
IF EXISTS (SELECT * FROM sys.check_constraints WHERE name = 'CK__SupportTi__categ')
    ALTER TABLE SupportTickets DROP CONSTRAINT CK__SupportTi__categ;
