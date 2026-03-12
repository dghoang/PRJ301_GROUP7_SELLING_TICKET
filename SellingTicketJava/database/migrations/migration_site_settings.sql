-- Migration: Create SiteSettings key-value table for persistent admin configuration
-- Run this once against your TicketBox database.

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'SiteSettings')
BEGIN
    CREATE TABLE SiteSettings (
        setting_key   NVARCHAR(100) PRIMARY KEY,
        setting_value NVARCHAR(MAX) NOT NULL,
        updated_at    DATETIME DEFAULT GETDATE()
    );

    -- Default values
    INSERT INTO SiteSettings (setting_key, setting_value) VALUES
        ('chat_enabled', 'true'),
        ('chat_auto_accept', 'true'),
        ('chat_cooldown_minutes', '30'),
        ('site_name', 'Ticketbox'),
        ('require_event_approval', 'true'),
        ('allow_organizer_registration', 'true');
END
GO
