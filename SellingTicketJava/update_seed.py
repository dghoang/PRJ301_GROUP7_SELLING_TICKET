import re
import sys

file_path = r'database\schema\full_reset_seed.sql'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Update Events INSERT header
# INSERT INTO Events (..., max_total_tickets) VALUES
# becomes INSERT INTO Events (..., max_total_tickets, is_deleted) VALUES
content = content.replace(
    'max_total_tickets) VALUES',
    'max_total_tickets, is_deleted) VALUES'
)

# 2. Update Events values 
# They end with max_total_tickets: e.g. 1750), or 4330),
# We will find the specific lines between the Events INSERT and the next CREATE or INSERT
# Actually we can just do a regex that finds lines ending in ), where it's part of Events.
# But instead of regex, let's locate the Events block:
events_start = content.find('INSERT INTO Events')
events_end = content.find('-- ============ THỂ THAO', events_start) # Just to get a bound, wait, there are many categories.
events_end = content.find('INSERT INTO TicketTypes', events_start)
if events_end == -1:
    events_end = content.find('CREATE TABLE', events_start)
if events_end == -1:
    events_end = content.find('INSERT INTO', events_start + 50)

# Modify each '),' to ', 0),' ONLY within the Events block.
events_block = content[events_start:events_end]
# A typical line ends with: 4, 1750), or 0, 0),
new_events_block = re.sub(r'(\d+)\),\s*\n', r'\1, 0),\n', events_block)
# Also handle the last one which might end with ; instead of ,
new_events_block = re.sub(r'(\d+)\);\s*\n', r'\1, 0);\n', new_events_block)

content = content[:events_start] + new_events_block + content[events_end:]


# 3. Update Orders 1-35. They start around line 950 to 1600.
# Currently they use:
# INSERT INTO Orders (order_code, user_id, event_id, total_amount, discount_amount, final_amount, status, payment_method, payment_date, buyer_name, buyer_email, buyer_phone, created_at)
# Or similar.
# We will replace the Orders headers up to order 35.
# Let's just find and replace all old Orders headers.
# Old header:
header_old_1 = 'INSERT INTO Orders (order_code, user_id, event_id, total_amount, discount_amount, final_amount, status, payment_method, payment_date, buyer_name, buyer_email, buyer_phone, created_at)'
header_new_1 = 'INSERT INTO Orders (order_code, user_id, event_id, total_amount, discount_amount, final_amount, status, payment_method, payment_date, buyer_name, buyer_email, buyer_phone, voucher_scope, voucher_fund_source, event_discount_amount, system_discount_amount, platform_fee_amount, organizer_payout_amount, created_at)'

content = content.replace(header_old_1, header_new_1)

# Another header variant (some don't have payment_date):
header_old_2 = 'INSERT INTO Orders (order_code, user_id, event_id, total_amount, discount_amount, final_amount, status, payment_method, buyer_name, buyer_email, buyer_phone, created_at)'
header_new_2 = 'INSERT INTO Orders (order_code, user_id, event_id, total_amount, discount_amount, final_amount, status, payment_method, buyer_name, buyer_email, buyer_phone, voucher_scope, voucher_fund_source, event_discount_amount, system_discount_amount, platform_fee_amount, organizer_payout_amount, created_at)'
content = content.replace(header_old_2, header_new_2)

# Now for the values of Orders 1-35.
# They look like: VALUES ('ORD-2026-0001', 15, 1, 7500000, 0, 7500000, 'paid', 'seepay', DATEADD(DAY,-30,@now2), N'Ngô Thanh Tùng', 'tung.ngo@gmail.com', '0923456789', DATEADD(DAY,-30,@now2));
# We need to insert: 'NONE', 'NONE', 0, 0, 0, <total_amount> before the last DATEADD or GETDATE.
# Let's use a regex to match the Orders 1-35 VALUES line and extract the total_amount (which is the 4th value)
def replacer(match):
    prefix = match.group(1)
    total_amount = match.group(2)
    suffix = match.group(3)
    # The suffix starts with the created_at value, like DATEADD(...)
    return f"{prefix}{total_amount}{suffix}, 'NONE', 'NONE', 0, 0, 0, {total_amount}, "

# Actually regex is tricky because of the variable number of arguments and commas.
# Instead, since we know there's an UPDATE block at the bottom for those 35 orders,
# we can read the file, and do it manually!
with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)
print("Regex replace done for Events. Run script successfully.")
