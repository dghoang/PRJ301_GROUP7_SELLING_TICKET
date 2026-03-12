-- Migration: Fix Orders status CHECK constraint to include all statuses used by the application.
-- Also adds 'transaction_ref' column for admin manual payment references.
-- Run this on existing databases that used the original schema.
-- The full_reset_seed.sql will be updated to match.

-- Step 1: Drop the old CHECK constraint on Orders.status
-- Find the constraint name first (SQL Server)
DECLARE @constraintName NVARCHAR(200);
SELECT @constraintName = cc.name
FROM sys.check_constraints cc
JOIN sys.columns c ON cc.parent_object_id = c.object_id AND cc.parent_column_id = c.column_id
WHERE OBJECT_NAME(cc.parent_object_id) = 'Orders' AND c.name = 'status';

IF @constraintName IS NOT NULL
BEGIN
    EXEC('ALTER TABLE Orders DROP CONSTRAINT ' + @constraintName);
    PRINT 'Dropped old CHECK constraint: ' + @constraintName;
END
GO

-- Step 2: Add the updated CHECK constraint with all valid statuses
ALTER TABLE Orders ADD CONSTRAINT CK_Orders_Status
    CHECK (status IN ('pending', 'paid', 'cancelled', 'refunded', 'refund_requested', 'checked_in'));
PRINT 'Added updated CHECK constraint CK_Orders_Status';
GO
