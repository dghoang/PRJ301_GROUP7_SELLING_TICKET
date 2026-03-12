-- =============================================
-- SOFT DELETE MIGRATION — Add is_deleted columns
-- Run this AFTER ticketbox_schema.sql
-- =============================================

USE SellingTicketDB;
GO

-- Events: add is_deleted
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('Events') AND name = 'is_deleted')
BEGIN
    ALTER TABLE Events ADD is_deleted BIT DEFAULT 0;
    PRINT 'Events.is_deleted added.';
END
GO

-- Orders: add is_deleted
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('Orders') AND name = 'is_deleted')
BEGIN
    ALTER TABLE Orders ADD is_deleted BIT DEFAULT 0;
    PRINT 'Orders.is_deleted added.';
END
GO

-- Users: add is_deleted
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('Users') AND name = 'is_deleted')
BEGIN
    ALTER TABLE Users ADD is_deleted BIT DEFAULT 0;
    PRINT 'Users.is_deleted added.';
END
GO

-- Categories: add is_deleted
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('Categories') AND name = 'is_deleted')
BEGIN
    ALTER TABLE Categories ADD is_deleted BIT DEFAULT 0;
    PRINT 'Categories.is_deleted added.';
END
GO

-- Vouchers: add is_deleted (has is_active, but soft delete is separate)
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('Vouchers') AND name = 'is_deleted')
BEGIN
    ALTER TABLE Vouchers ADD is_deleted BIT DEFAULT 0;
    PRINT 'Vouchers.is_deleted added.';
END
GO

-- TicketTypes: add is_deleted
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('TicketTypes') AND name = 'is_deleted')
BEGIN
    ALTER TABLE TicketTypes ADD is_deleted BIT DEFAULT 0;
    PRINT 'TicketTypes.is_deleted added.';
END
GO

-- Update indexes to include is_deleted for common queries
IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Events_Status' AND object_id = OBJECT_ID('Events'))
    DROP INDEX IX_Events_Status ON Events;
CREATE NONCLUSTERED INDEX IX_Events_Status ON Events(status, is_deleted)
    INCLUDE (title, start_date, organizer_id);
GO

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Orders_User' AND object_id = OBJECT_ID('Orders'))
    DROP INDEX IX_Orders_User ON Orders;
CREATE NONCLUSTERED INDEX IX_Orders_User ON Orders(user_id, is_deleted, created_at DESC)
    INCLUDE (status, final_amount);
GO

PRINT '';
PRINT '============================================';
PRINT '  Soft Delete Migration Complete!';
PRINT '  6 tables updated with is_deleted column';
PRINT '============================================';
GO

-- =============================================
-- EVENT PINNING & DISPLAY PRIORITY
-- =============================================

-- pin_order: 0 = not pinned, higher = higher visibility
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('Events') AND name = 'pin_order')
BEGIN
    ALTER TABLE Events ADD pin_order INT DEFAULT 0;
    PRINT 'Events.pin_order added.';
END
GO

-- display_priority: composite score for sorting (auto-calculated or manual)
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('Events') AND name = 'display_priority')
BEGIN
    ALTER TABLE Events ADD display_priority INT DEFAULT 0;
    PRINT 'Events.display_priority added.';
END
GO

-- Index for homepage sorting: pinned first, then by priority, then by start_date
IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Events_Display' AND object_id = OBJECT_ID('Events'))
    DROP INDEX IX_Events_Display ON Events;
CREATE NONCLUSTERED INDEX IX_Events_Display ON Events(pin_order DESC, display_priority DESC, start_date ASC)
    WHERE status = 'approved' AND is_deleted = 0;
GO

PRINT 'Event pinning columns and indexes complete.';
GO
