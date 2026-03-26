import re

file_path = r'database\schema\ticketbox_schema.sql'
try:
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
except UnicodeDecodeError:
    with open(file_path, 'r', encoding='utf-16') as f:
        content = f.read()

# 1. Inject Events ALTER statement
events_replacement = """PRINT 'Table Events created.';
END
ELSE
BEGIN
    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('Events') AND name = 'is_deleted')
    BEGIN
        ALTER TABLE Events ADD is_deleted BIT DEFAULT 0;
        PRINT 'Added is_deleted to Events';
    END
    PRINT 'Table Events already exists - columns verified.';
END
GO"""

content = re.sub(r"PRINT 'Table Events created\.';\s*END\s*GO", events_replacement, content)

# 2. Inject Orders ALTER statement
orders_replacement = """PRINT 'Table Orders created.';
END
ELSE
BEGIN
    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('Orders') AND name = 'system_discount_amount')
    BEGIN
        ALTER TABLE Orders ADD system_discount_amount DECIMAL(18,2) DEFAULT 0;
        ALTER TABLE Orders ADD event_discount_amount DECIMAL(18,2) DEFAULT 0;
        ALTER TABLE Orders ADD platform_fee_amount DECIMAL(18,2) DEFAULT 0;
        ALTER TABLE Orders ADD organizer_payout_amount DECIMAL(18,2) DEFAULT 0;
        ALTER TABLE Orders ADD voucher_scope NVARCHAR(10);
        PRINT 'Added discount and payout columns to Orders';
    END
    PRINT 'Table Orders already exists - columns verified.';
END
GO"""

content = re.sub(r"PRINT 'Table Orders created\.';\s*END\s*GO", orders_replacement, content)

# Write back preserving Windows line endings
with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)

print("Injected ALTER TABLE scripts to ticketbox_schema.sql")
