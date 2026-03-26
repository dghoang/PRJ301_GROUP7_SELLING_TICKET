USE SellingTicketDB;
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('Events') AND name = 'is_deleted')
BEGIN
    ALTER TABLE Events ADD is_deleted BIT DEFAULT 0;
    PRINT 'Added is_deleted to Events';
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('Orders') AND name = 'system_discount_amount')
BEGIN
    ALTER TABLE Orders ADD system_discount_amount DECIMAL(18,2) DEFAULT 0;
    ALTER TABLE Orders ADD event_discount_amount DECIMAL(18,2) DEFAULT 0;
    ALTER TABLE Orders ADD platform_fee_amount DECIMAL(18,2) DEFAULT 0;
    ALTER TABLE Orders ADD organizer_payout_amount DECIMAL(18,2) DEFAULT 0;
    ALTER TABLE Orders ADD voucher_scope NVARCHAR(10);
    PRINT 'Added discount and payout columns to Orders';
END
GO
