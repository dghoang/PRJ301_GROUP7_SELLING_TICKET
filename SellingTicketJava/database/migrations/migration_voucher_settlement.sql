-- ============================================================
-- Migration: Voucher scope/funding + Order settlement columns
-- For reconciliation between platform and organizers.
-- ============================================================

-- 1. Voucher scope metadata
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('Vouchers') AND name = 'voucher_scope')
BEGIN
    ALTER TABLE Vouchers ADD voucher_scope NVARCHAR(10) DEFAULT 'EVENT';  -- EVENT | SYSTEM
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('Vouchers') AND name = 'fund_source')
BEGIN
    ALTER TABLE Vouchers ADD fund_source NVARCHAR(10) DEFAULT 'ORGANIZER';  -- ORGANIZER | SYSTEM
END
GO

-- Backfill existing vouchers: event-bound → EVENT/ORGANIZER, global → SYSTEM/SYSTEM
UPDATE Vouchers SET voucher_scope = 'EVENT', fund_source = 'ORGANIZER' WHERE event_id IS NOT NULL AND event_id > 0 AND voucher_scope IS NULL;
UPDATE Vouchers SET voucher_scope = 'SYSTEM', fund_source = 'SYSTEM' WHERE (event_id IS NULL OR event_id <= 0) AND voucher_scope IS NULL;
GO

-- 2. Order settlement columns for reconciliation
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('Orders') AND name = 'voucher_id')
BEGIN
    ALTER TABLE Orders ADD voucher_id INT NULL;
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('Orders') AND name = 'voucher_scope')
BEGIN
    ALTER TABLE Orders ADD voucher_scope NVARCHAR(10) DEFAULT 'NONE';  -- NONE | EVENT | SYSTEM
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('Orders') AND name = 'voucher_fund_source')
BEGIN
    ALTER TABLE Orders ADD voucher_fund_source NVARCHAR(10) DEFAULT 'NONE';  -- NONE | ORGANIZER | SYSTEM
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('Orders') AND name = 'event_discount_amount')
BEGIN
    ALTER TABLE Orders ADD event_discount_amount DECIMAL(18,2) DEFAULT 0;  -- deducted from organizer revenue
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('Orders') AND name = 'system_discount_amount')
BEGIN
    ALTER TABLE Orders ADD system_discount_amount DECIMAL(18,2) DEFAULT 0;  -- platform subsidy
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('Orders') AND name = 'platform_fee_amount')
BEGIN
    ALTER TABLE Orders ADD platform_fee_amount DECIMAL(18,2) DEFAULT 0;
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('Orders') AND name = 'organizer_payout_amount')
BEGIN
    ALTER TABLE Orders ADD organizer_payout_amount DECIMAL(18,2) DEFAULT 0;
END
GO

-- Backfill: existing orders with vouchers are assumed EVENT-scoped (conservative).
-- Orders without vouchers: organizer_payout = total_amount (no platform fee yet).
UPDATE Orders SET voucher_scope = 'NONE', voucher_fund_source = 'NONE',
    event_discount_amount = 0, system_discount_amount = 0,
    platform_fee_amount = 0, organizer_payout_amount = total_amount
WHERE voucher_scope IS NULL AND (discount_amount = 0 OR discount_amount IS NULL);

UPDATE Orders SET voucher_scope = 'EVENT', voucher_fund_source = 'ORGANIZER',
    event_discount_amount = discount_amount, system_discount_amount = 0,
    platform_fee_amount = 0, organizer_payout_amount = total_amount - discount_amount
WHERE voucher_scope IS NULL AND discount_amount > 0;
GO

PRINT 'Migration voucher_settlement completed successfully.';
GO
