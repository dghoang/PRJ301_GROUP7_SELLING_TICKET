-- Migration: Canonicalize EventStaff.role values to manager/staff/scanner.
-- This script is idempotent and safe to re-run.
-- Fixed order: DROP constraints FIRST, then backfill data, then ADD new constraints.

-- ============================================================
-- STEP 1: Drop ALL existing CHECK constraints on EventStaff.role
--         (covers auto-named constraints AND named CK_EventStaff_Role)
-- ============================================================
DECLARE @constraintName NVARCHAR(200);

-- Drop any auto-generated or previously named check constraint
DECLARE cur CURSOR FOR
    SELECT cc.name
    FROM sys.check_constraints cc
    JOIN sys.columns c
        ON cc.parent_object_id = c.object_id
       AND cc.parent_column_id = c.column_id
    WHERE OBJECT_NAME(cc.parent_object_id) = 'EventStaff'
      AND c.name = 'role';

OPEN cur;
FETCH NEXT FROM cur INTO @constraintName;
WHILE @@FETCH_STATUS = 0
BEGIN
    EXEC('ALTER TABLE EventStaff DROP CONSTRAINT [' + @constraintName + ']');
    PRINT 'Dropped EventStaff role CHECK constraint: ' + @constraintName;
    FETCH NEXT FROM cur INTO @constraintName;
END
CLOSE cur;
DEALLOCATE cur;
GO

-- ============================================================
-- STEP 2: Backfill legacy role values (safe now — no constraint)
-- ============================================================
UPDATE EventStaff SET role = 'staff'   WHERE role IN ('editor', 'viewer');
UPDATE EventStaff SET role = 'scanner' WHERE role = 'checkin';
PRINT 'Backfilled legacy EventStaff role values.';
GO

-- ============================================================
-- STEP 3: Add canonical CHECK constraint
-- ============================================================
IF NOT EXISTS (
    SELECT 1 FROM sys.check_constraints
    WHERE name = 'CK_EventStaff_Role'
      AND OBJECT_NAME(parent_object_id) = 'EventStaff'
)
BEGIN
    ALTER TABLE EventStaff
    ADD CONSTRAINT CK_EventStaff_Role
    CHECK (role IN ('manager', 'staff', 'scanner'));
    PRINT 'Added CK_EventStaff_Role constraint.';
END
ELSE
    PRINT 'CK_EventStaff_Role already exists — skipped.';
GO

-- ============================================================
-- STEP 4: Fix default constraint to canonical value
-- ============================================================
DECLARE @defaultConstraint NVARCHAR(200);
SELECT @defaultConstraint = dc.name
FROM sys.default_constraints dc
JOIN sys.columns c
    ON dc.parent_object_id = c.object_id
   AND dc.parent_column_id = c.column_id
WHERE OBJECT_NAME(dc.parent_object_id) = 'EventStaff'
  AND c.name = 'role';

IF @defaultConstraint IS NOT NULL
BEGIN
    EXEC('ALTER TABLE EventStaff DROP CONSTRAINT [' + @defaultConstraint + ']');
    PRINT 'Dropped old EventStaff role default: ' + @defaultConstraint;
END
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.default_constraints
    WHERE name = 'DF_EventStaff_Role'
      AND OBJECT_NAME(parent_object_id) = 'EventStaff'
)
BEGIN
    ALTER TABLE EventStaff
    ADD CONSTRAINT DF_EventStaff_Role DEFAULT 'staff' FOR role;
    PRINT 'Added DF_EventStaff_Role default constraint.';
END
ELSE
    PRINT 'DF_EventStaff_Role already exists — skipped.';
GO

-- ============================================================
-- VERIFY: Show current state
-- ============================================================
SELECT
    c.name        AS column_name,
    dc.name       AS default_constraint,
    dc.definition AS default_value,
    cc.name       AS check_constraint,
    cc.definition AS check_definition
FROM sys.columns c
LEFT JOIN sys.default_constraints dc
    ON dc.parent_object_id = c.object_id AND dc.parent_column_id = c.column_id
LEFT JOIN sys.check_constraints cc
    ON cc.parent_object_id = c.object_id AND cc.parent_column_id = c.column_id
WHERE OBJECT_NAME(c.object_id) = 'EventStaff'
  AND c.name = 'role';

SELECT role, COUNT(*) AS cnt FROM EventStaff GROUP BY role ORDER BY role;

PRINT 'EventStaff role canonical migration completed.';
