import re
import sys

file_path = r'database\schema\full_reset_seed.sql'
with open(file_path, 'r', encoding='utf-8') as f:
    lines = f.readlines()

in_events = False
in_orders_1_35 = False

new_lines = []
for index, line in enumerate(lines):
    # 1. Events Header
    if line.startswith('INSERT INTO Events') and 'is_deleted' not in line:
        line = line.replace('max_total_tickets) VALUES', 'max_total_tickets, is_deleted) VALUES')
        in_events = True
        new_lines.append(line)
        continue

    # 2. Events Values
    if in_events:
        if line.strip().startswith('-- ============ THỂ THAO') or line.strip().startswith('-- ============ WORKSHOP') or line.strip().startswith('-- ============ ẨM THỰC') or line.strip().startswith('-- ============ CÔNG NGHỆ') or line.strip().startswith('-- ============ KINH DOANH') or line.strip().startswith('-- ============ NGHỆ THUẬT') or line.strip() == '':
            new_lines.append(line)
            continue
        
        # If it's the end of Events insertions (like INSERT INTO TicketTypes)
        if line.startswith('INSERT INTO'):
            in_events = False
            new_lines.append(line)
            continue
            
        # Match lines like "0, 0, 0, 6, 5700)," or "... 4330),"
        if '),\n' in line or ');\n' in line or '), \n' in line:
            # Replace the closing parenthesis with ", 0)"
            line = re.sub(r'\),\s*\n', r', 0),\n', line)
            line = re.sub(r'\);\s*\n', r', 0);\n', line)
            new_lines.append(line)
            continue
        
        # It's a line inside Events values but not the end of a tuple
        new_lines.append(line)
        continue

    # 3. Orders 1-35 Headers
    if line.startswith('INSERT INTO Orders (order_code, user_id, event_id, total_amount, discount_amount, final_amount, status, payment_method, payment_date, buyer_name, buyer_email, buyer_phone, created_at)'):
        line = "INSERT INTO Orders (order_code, user_id, event_id, total_amount, discount_amount, final_amount, status, payment_method, payment_date, buyer_name, buyer_email, buyer_phone, voucher_scope, voucher_fund_source, event_discount_amount, system_discount_amount, platform_fee_amount, organizer_payout_amount, created_at)\n"
        new_lines.append(line)
        continue
    if line.startswith('INSERT INTO Orders (order_code, user_id, event_id, total_amount, discount_amount, final_amount, status, payment_method, buyer_name, buyer_email, buyer_phone, created_at)'):
        line = "INSERT INTO Orders (order_code, user_id, event_id, total_amount, discount_amount, final_amount, status, payment_method, buyer_name, buyer_email, buyer_phone, voucher_scope, voucher_fund_source, event_discount_amount, system_discount_amount, platform_fee_amount, organizer_payout_amount, created_at)\n"
        new_lines.append(line)
        continue

    # 4. Orders 1-35 Values
    if line.startswith('VALUES (\'ORD-2026-000') or line.startswith('VALUES (\'ORD-2026-001') or line.startswith('VALUES (\'ORD-2026-002') or line.startswith('VALUES (\'ORD-2026-003'):
        # Extract total_amount. It is the 4th item.
        # Format: VALUES ('ORD-2026-0001', 15, 1, 7500000, 0, 7500000, ...
        match = re.search(r"VALUES \('[A-Z0-9\-]+', \d+, \d+, (\d+)", line)
        if match:
            total_amount = int(match.group(1))
            order_code = re.search(r"ORD-2026-00(\d{2})", line).group(1)
            order_id = int(order_code)
            
            # The line ends with DATEADD(...) or GETDATE(...) or similar, followed by );. Example: DATEADD(DAY,-30,@now2));
            # Let's split by the last comma before the date (wait, DATEADD has a comma inside it).
            # So, find the created_at part which should be " DATEADD(" or " GETDATE(".
            match_suffix = re.search(r"(,\s*(DATEADD|GETDATE)[^;]+;\n)", line)
            
            if match_suffix:
                suffix = match_suffix.group(1)
                prefix = line[:match_suffix.start()]
                
                # Check specifics for orders 11, 24, 25 based on the original SQL update script at the bottom.
                if order_id == 11:
                    new_val = f", 'EVENT', 'ORGANIZER', 90000, 0, 0, {600000 - 90000}"
                    # oh wait, Orders also needs voucher_id explicitly in the header if it's there. But the header does not have voucher_id because it was patched inside the UPDATE block!
                    # If we add voucher_id, we need a separate header. It's easier to just leave the UPDATE block for voucher_id OR we can just inject voucher_id too.
                    # Since voucher_id is missing from our new header, maybe it's best to add voucher_id to the header?
                    # Let's keep it simple: We'll modify the python script to just add the discount columns, and the UPDATE script at the bottom will still update voucher_id, but the rest is fully declared. 
                    # Wait, if we leave the UPDATE block at the bottom, we shouldn't change the INSERT header!
                if order_id in [11, 24, 25]:
                    if order_id == 11:
                        add_str = f", 'EVENT', 'ORGANIZER', 90000, 0, 0, {600000 - 90000}"
                    elif order_id == 24:
                        add_str = f", 'EVENT', 'ORGANIZER', 360000, 0, 0, {2400000 - 360000}"
                    elif order_id == 25:
                        add_str = f", 'EVENT', 'ORGANIZER', 50000, 0, 0, {1500000 - 50000}"
                else:
                    add_str = f", 'NONE', 'NONE', 0, 0, 0, {total_amount}"
                
                line = prefix + add_str + suffix

        new_lines.append(line)
        continue

    # Removing the UPDATE statements at the bottom, maybe? No, let them be for voucher_id since it uses it.
    new_lines.append(line)

with open(file_path, 'w', encoding='utf-8') as f:
    f.writelines(new_lines)
print("Finished rewriting full_reset_seed.sql")
