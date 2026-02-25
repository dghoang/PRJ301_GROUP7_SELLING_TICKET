-- ============================================================
-- Database Performance Indexes for SellingTicket
-- Run this script against your SQL Server database.
-- These indexes target the most frequent query patterns.
-- ============================================================

-- Events: FK indexes + status/date filtering  
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Events_Status_StartDate')
    CREATE NONCLUSTERED INDEX IX_Events_Status_StartDate 
    ON Events (status, start_date ASC)
    INCLUDE (title, slug, banner_image, category_id, organizer_id, is_featured, is_private, views);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Events_OrganizerID')
    CREATE NONCLUSTERED INDEX IX_Events_OrganizerID 
    ON Events (organizer_id)
    INCLUDE (status, created_at);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Events_CategoryID')
    CREATE NONCLUSTERED INDEX IX_Events_CategoryID 
    ON Events (category_id);
GO

-- TicketTypes: FK index + price aggregation
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_TicketTypes_EventID')
    CREATE NONCLUSTERED INDEX IX_TicketTypes_EventID 
    ON TicketTypes (event_id)
    INCLUDE (price, quantity, sold_quantity, is_active);
GO

-- Orders: FK indexes + status filtering
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Orders_UserID')
    CREATE NONCLUSTERED INDEX IX_Orders_UserID 
    ON Orders (user_id)
    INCLUDE (status, created_at);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Orders_EventID_Status')
    CREATE NONCLUSTERED INDEX IX_Orders_EventID_Status 
    ON Orders (event_id, status)
    INCLUDE (final_amount, created_at);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Orders_Status')
    CREATE NONCLUSTERED INDEX IX_Orders_Status 
    ON Orders (status)
    INCLUDE (final_amount);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Orders_OrderCode')
    CREATE UNIQUE NONCLUSTERED INDEX IX_Orders_OrderCode 
    ON Orders (order_code);
GO

-- OrderItems: FK index
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_OrderItems_OrderID')
    CREATE NONCLUSTERED INDEX IX_OrderItems_OrderID 
    ON OrderItems (order_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_OrderItems_TicketTypeID')
    CREATE NONCLUSTERED INDEX IX_OrderItems_TicketTypeID 
    ON OrderItems (ticket_type_id);
GO

-- Users: email lookup for login
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Users_Email')
    CREATE UNIQUE NONCLUSTERED INDEX IX_Users_Email 
    ON Users (email);
GO

-- Categories: slug lookup
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Categories_Slug')
    CREATE UNIQUE NONCLUSTERED INDEX IX_Categories_Slug 
    ON Categories (slug);
GO

-- Events: slug lookup (public URL routing)
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Events_Slug')
    CREATE UNIQUE NONCLUSTERED INDEX IX_Events_Slug 
    ON Events (slug);
GO

-- EventStaff: composite FK index
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_EventStaff_EventID_UserID')
    CREATE NONCLUSTERED INDEX IX_EventStaff_EventID_UserID 
    ON EventStaff (event_id, user_id)
    INCLUDE (role);
GO

PRINT 'All indexes created successfully.';
