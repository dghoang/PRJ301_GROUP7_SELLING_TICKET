-- Migration: Add event ticket settings columns
-- Date: 2026-03-11

-- Add max_tickets_per_order (0 = use system default of 10)
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'Events' AND COLUMN_NAME = 'max_tickets_per_order')
BEGIN
    ALTER TABLE Events ADD max_tickets_per_order INT NOT NULL DEFAULT 0;
END;

-- Add max_total_tickets (0 = unlimited, sum of all ticket types)
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'Events' AND COLUMN_NAME = 'max_total_tickets')
BEGIN
    ALTER TABLE Events ADD max_total_tickets INT NOT NULL DEFAULT 0;
END;

-- Add pre_order_enabled (allow buying before sale_start)
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'Events' AND COLUMN_NAME = 'pre_order_enabled')
BEGIN
    ALTER TABLE Events ADD pre_order_enabled BIT NOT NULL DEFAULT 0;
END;

PRINT 'Migration completed: event settings columns added';
