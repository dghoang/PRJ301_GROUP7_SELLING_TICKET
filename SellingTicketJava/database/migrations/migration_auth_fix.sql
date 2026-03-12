-- =============================================
-- MIGRATION: Auth Flow Fix
-- Adds missing columns to Users table
-- Safe to run multiple times (IF NOT EXISTS)
-- =============================================

USE SellingTicketDB;
GO

-- 1. Add 'gender' column if missing
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('Users') AND name = 'gender')
BEGIN
    ALTER TABLE Users ADD gender NVARCHAR(10);
    PRINT 'Added column: gender';
END
GO

-- 2. Add 'date_of_birth' column if missing
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('Users') AND name = 'date_of_birth')
BEGIN
    ALTER TABLE Users ADD date_of_birth DATE;
    PRINT 'Added column: date_of_birth';
END
GO

-- 3. Rename 'avatar_url' -> 'avatar' if old name exists
IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('Users') AND name = 'avatar_url')
BEGIN
    EXEC sp_rename 'Users.avatar_url', 'avatar', 'COLUMN';
    PRINT 'Renamed column: avatar_url -> avatar';
END
GO

-- 4. Add 'avatar' column if neither name exists
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('Users') AND name = 'avatar')
BEGIN
    ALTER TABLE Users ADD avatar NVARCHAR(500);
    PRINT 'Added column: avatar';
END
GO

PRINT '✅ Migration complete!';
GO
