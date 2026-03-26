import re
import sys

file_path = r'database\schema\full_reset_seed.sql'
with open(file_path, 'r', encoding='utf-8') as f:
    lines = f.readlines()

out_lines = []
in_events = False

for line in lines:
    if line.startswith('INSERT INTO Events') and 'is_deleted' not in line:
        line = line.replace('max_total_tickets) VALUES', 'max_total_tickets, is_deleted) VALUES')
        in_events = True
        out_lines.append(line)
        continue

    if in_events:
        if line.strip().startswith('-- ============') or line.strip() == '':
            out_lines.append(line)
            continue
            
        if line.startswith('INSERT INTO'):
            in_events = False
            out_lines.append(line)
            continue

        if line.strip().endswith('),'):
            # replace last ) with , 0)
            line = re.sub(r'\),\s*$', r', 0),\n', line)
            out_lines.append(line)
            continue
            
        if line.strip().endswith(');'):
            # replace last ); with , 0);
            line = re.sub(r'\);\s*$', r', 0);\n', line)
            out_lines.append(line)
            continue

    out_lines.append(line)

with open(file_path, 'w', encoding='utf-8') as f:
    f.writelines(out_lines)
print("Added is_deleted=0 to ALL Events inserted in full_reset_seed.sql")
