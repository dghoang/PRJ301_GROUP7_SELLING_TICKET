-- Migration: normalize user status for soft-deleted accounts.
-- Rule: if is_deleted = 1 then is_active must be 0.

IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('Users') AND name = 'is_deleted')
BEGIN
    UPDATE Users
    SET is_active = 0,
        updated_at = GETDATE()
    WHERE is_deleted = 1
      AND is_active = 1;

    PRINT 'Users status normalized: deleted users are now inactive.';
END
ELSE
BEGIN
    PRINT 'Users.is_deleted column not found - skipped.';
END
GO

PRINT 'User deleted-status consistency migration completed.';
