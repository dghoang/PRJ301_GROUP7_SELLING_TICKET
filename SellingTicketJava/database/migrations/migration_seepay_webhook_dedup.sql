-- Migration: Add persistent SePay webhook idempotency table.
-- Prevents replay after server restart and avoids in-memory clear-all behavior.

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('SeepayWebhookDedup') AND type = 'U')
BEGIN
    CREATE TABLE SeepayWebhookDedup (
        dedup_id INT IDENTITY(1,1) PRIMARY KEY,
        sepay_transaction_id NVARCHAR(100) NOT NULL UNIQUE,
        order_code NVARCHAR(100),
        process_result NVARCHAR(30) NOT NULL DEFAULT 'processed',
        created_at DATETIME NOT NULL DEFAULT GETDATE()
    );

    CREATE INDEX IX_SeepayWebhookDedup_CreatedAt ON SeepayWebhookDedup(created_at DESC);
    PRINT 'Table SeepayWebhookDedup created.';
END
GO

-- Cleanup old dedup entries (keep 30 days) to avoid unbounded growth.
DELETE FROM SeepayWebhookDedup WHERE created_at < DATEADD(DAY, -30, GETDATE());
GO

PRINT 'Seepay webhook dedup migration completed.';
