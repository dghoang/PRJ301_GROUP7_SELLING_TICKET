-- Migration: Performance indexes for organizer check-in flow.
-- Safe to run multiple times.

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = 'IX_Tickets_OrderItem_CheckedIn'
      AND object_id = OBJECT_ID('Tickets')
)
BEGIN
    CREATE NONCLUSTERED INDEX IX_Tickets_OrderItem_CheckedIn
    ON Tickets(order_item_id, is_checked_in)
    INCLUDE (ticket_id, checked_in_at, checked_in_by);
    PRINT 'IX_Tickets_OrderItem_CheckedIn created.';
END
ELSE
BEGIN
    PRINT 'IX_Tickets_OrderItem_CheckedIn already exists.';
END
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = 'IX_OrderItems_Order_TicketType'
      AND object_id = OBJECT_ID('OrderItems')
)
BEGIN
    CREATE NONCLUSTERED INDEX IX_OrderItems_Order_TicketType
    ON OrderItems(order_id, ticket_type_id)
    INCLUDE (order_item_id);
    PRINT 'IX_OrderItems_Order_TicketType created.';
END
ELSE
BEGIN
    PRINT 'IX_OrderItems_Order_TicketType already exists.';
END
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = 'IX_Orders_Event_Status'
      AND object_id = OBJECT_ID('Orders')
)
BEGIN
    CREATE NONCLUSTERED INDEX IX_Orders_Event_Status
    ON Orders(event_id, status)
    INCLUDE (order_id, order_code, buyer_name, buyer_email, created_at);
    PRINT 'IX_Orders_Event_Status created.';
END
ELSE
BEGIN
    PRINT 'IX_Orders_Event_Status already exists.';
END
GO

PRINT 'Check-in performance indexes migration completed.';
