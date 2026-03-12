-- =============================================
-- MIGRATION: Add rejection_reason to Events
-- Safe to re-run (idempotent)
-- =============================================
USE SellingTicketDB;
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('Events') AND name = 'rejection_reason')
    ALTER TABLE Events ADD rejection_reason NVARCHAR(MAX);
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('Events') AND name = 'rejected_at')
    ALTER TABLE Events ADD rejected_at DATETIME;
GO

PRINT 'Migration complete: rejection_reason + rejected_at added to Events.';
GO
