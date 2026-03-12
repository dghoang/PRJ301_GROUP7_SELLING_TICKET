-- =============================================
-- EVENT STAFF TABLE
-- For collaborative event management
-- =============================================

USE SellingTicketDB;
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('EventStaff') AND type = 'U')
BEGIN
    CREATE TABLE EventStaff (
        staff_id INT IDENTITY(1,1) PRIMARY KEY,
        event_id INT NOT NULL,
        user_id INT NOT NULL,
        role NVARCHAR(20) DEFAULT 'editor' CHECK (role IN ('manager', 'editor', 'checkin')),
        granted_by INT,
        created_at DATETIME DEFAULT GETDATE(),
        
        FOREIGN KEY (event_id) REFERENCES Events(event_id) ON DELETE CASCADE,
        FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE,
        FOREIGN KEY (granted_by) REFERENCES Users(user_id),
        UNIQUE (event_id, user_id)
    );
    
    CREATE INDEX IX_EventStaff_User ON EventStaff(user_id);
    CREATE INDEX IX_EventStaff_Event ON EventStaff(event_id);
    
    PRINT 'Table EventStaff created.';
END
GO
