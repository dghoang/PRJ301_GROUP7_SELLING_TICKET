-- Migration: Add display_order to Categories for admin-controlled ordering.
-- Safe to run multiple times.

IF NOT EXISTS (
    SELECT 1
    FROM sys.columns
    WHERE object_id = OBJECT_ID('Categories')
      AND name = 'display_order'
)
BEGIN
    ALTER TABLE Categories ADD display_order INT NOT NULL CONSTRAINT DF_Categories_DisplayOrder DEFAULT 0;
    PRINT 'Categories.display_order added.';
END
ELSE
BEGIN
    PRINT 'Categories.display_order already exists.';
END
GO

;WITH OrderedCategories AS (
    SELECT category_id,
           ROW_NUMBER() OVER (ORDER BY created_at, category_id) AS rn
    FROM Categories
)
UPDATE c
SET c.display_order = oc.rn
FROM Categories c
JOIN OrderedCategories oc ON oc.category_id = c.category_id
WHERE c.display_order = 0;
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IX_Categories_DisplayOrder'
      AND object_id = OBJECT_ID('Categories')
)
BEGIN
    CREATE INDEX IX_Categories_DisplayOrder ON Categories(display_order, name);
    PRINT 'IX_Categories_DisplayOrder created.';
END
ELSE
BEGIN
    PRINT 'IX_Categories_DisplayOrder already exists.';
END
GO

PRINT 'Category display order migration completed.';
