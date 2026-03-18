-- Migration: ActivityLog + Notifications tables
-- Date: 2026-03-18
-- Description: Adds audit trail and in-app notification support

-- ============================================
-- ActivityLog: audit trail for admin actions
-- ============================================
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='ActivityLog' AND xtype='U')
BEGIN
    CREATE TABLE ActivityLog (
        log_id       INT IDENTITY(1,1) PRIMARY KEY,
        user_id      INT NOT NULL,
        action       VARCHAR(100) NOT NULL,
        entity_type  VARCHAR(50),
        entity_id    INT,
        details      NVARCHAR(500),
        ip_address   VARCHAR(45),
        created_at   DATETIME DEFAULT GETDATE(),
        CONSTRAINT FK_ActivityLog_User FOREIGN KEY (user_id) REFERENCES Users(user_id)
    );

    CREATE INDEX IX_ActivityLog_CreatedAt ON ActivityLog(created_at DESC);
    CREATE INDEX IX_ActivityLog_UserId    ON ActivityLog(user_id);
    CREATE INDEX IX_ActivityLog_Action    ON ActivityLog(action);

    PRINT 'Created table: ActivityLog';
END
GO

-- ============================================
-- Notifications: in-app notification center
-- ============================================
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='Notifications' AND xtype='U')
BEGIN
    CREATE TABLE Notifications (
        notification_id INT IDENTITY(1,1) PRIMARY KEY,
        user_id         INT NOT NULL,
        type            VARCHAR(50) NOT NULL,
        title           NVARCHAR(200) NOT NULL,
        message         NVARCHAR(500),
        link            VARCHAR(300),
        is_read         BIT DEFAULT 0,
        created_at      DATETIME DEFAULT GETDATE(),
        CONSTRAINT FK_Notifications_User FOREIGN KEY (user_id) REFERENCES Users(user_id)
    );

    CREATE INDEX IX_Notifications_UserRead ON Notifications(user_id, is_read);
    CREATE INDEX IX_Notifications_CreatedAt ON Notifications(created_at DESC);

    PRINT 'Created table: Notifications';
END
GO
