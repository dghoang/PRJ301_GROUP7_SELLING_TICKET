-- =============================================
-- TICKETBOX SEED DATA — Orders, OrderItems & Tickets
-- Run this AFTER ticketbox_schema.sql + mock_data.sql
-- =============================================

USE SellingTicketDB;
GO

-- =============================================
-- ORDER 1: Customer mua vé VIP Đêm nhạc Acoustic (Event 1)
-- =============================================
IF NOT EXISTS (SELECT 1 FROM Orders WHERE order_code = 'ORD-SEED-001')
BEGIN
    INSERT INTO Orders (order_code, user_id, event_id, total_amount, discount_amount, final_amount, status, payment_method, payment_date, buyer_name, buyer_email, buyer_phone)
    VALUES ('ORD-SEED-001', 3, 1, 1500000, 0, 1500000, 'paid', 'bank_transfer', GETDATE(),
            N'Nguyễn Văn A', 'customer@ticketbox.vn', '0912345678');

    INSERT INTO OrderItems (order_id, ticket_type_id, quantity, unit_price, subtotal)
    SELECT order_id, 1, 1, 1500000, 1500000 FROM Orders WHERE order_code = 'ORD-SEED-001';

    -- Individual ticket
    INSERT INTO Tickets (ticket_code, order_item_id, attendee_name, attendee_email, qr_code)
    SELECT 'TIX-SEED-0001', oi.order_item_id, N'Nguyễn Văn A', 'customer@ticketbox.vn', 'JWT_PENDING'
    FROM OrderItems oi JOIN Orders o ON oi.order_id = o.order_id WHERE o.order_code = 'ORD-SEED-001';

    PRINT 'Order SEED-001 created (Acoustic VIP, paid).';
END
GO

-- =============================================
-- ORDER 2: Customer mua 2 vé thường Đêm nhạc Acoustic (Event 1)
-- =============================================
IF NOT EXISTS (SELECT 1 FROM Orders WHERE order_code = 'ORD-SEED-002')
BEGIN
    INSERT INTO Orders (order_code, user_id, event_id, total_amount, discount_amount, final_amount, status, payment_method, buyer_name, buyer_email, buyer_phone)
    VALUES ('ORD-SEED-002', 3, 1, 1000000, 0, 1000000, 'pending', 'seepay',
            N'Nguyễn Văn A', 'customer@ticketbox.vn', '0912345678');

    INSERT INTO OrderItems (order_id, ticket_type_id, quantity, unit_price, subtotal)
    SELECT order_id, 2, 2, 500000, 1000000 FROM Orders WHERE order_code = 'ORD-SEED-002';

    -- 2 individual tickets
    INSERT INTO Tickets (ticket_code, order_item_id, attendee_name, attendee_email, qr_code)
    SELECT 'TIX-SEED-0002', oi.order_item_id, N'Nguyễn Văn A', 'customer@ticketbox.vn', 'JWT_PENDING'
    FROM OrderItems oi JOIN Orders o ON oi.order_id = o.order_id WHERE o.order_code = 'ORD-SEED-002';

    INSERT INTO Tickets (ticket_code, order_item_id, attendee_name, attendee_email, qr_code)
    SELECT 'TIX-SEED-0003', oi.order_item_id, N'Nguyễn Văn A', 'customer@ticketbox.vn', 'JWT_PENDING'
    FROM OrderItems oi JOIN Orders o ON oi.order_id = o.order_id WHERE o.order_code = 'ORD-SEED-002';

    PRINT 'Order SEED-002 created (Acoustic Standard x2, pending).';
END
GO

-- =============================================
-- ORDER 3: Customer mua vé Workshop UI/UX (Event 2) — đã check-in
-- =============================================
IF NOT EXISTS (SELECT 1 FROM Orders WHERE order_code = 'ORD-SEED-003')
BEGIN
    INSERT INTO Orders (order_code, user_id, event_id, total_amount, discount_amount, final_amount, status, payment_method, payment_date, buyer_name, buyer_email, buyer_phone)
    VALUES ('ORD-SEED-003', 3, 2, 600000, 0, 600000, 'checked_in', 'bank_transfer', DATEADD(DAY, -5, GETDATE()),
            N'Nguyễn Văn A', 'customer@ticketbox.vn', '0912345678');

    INSERT INTO OrderItems (order_id, ticket_type_id, quantity, unit_price, subtotal)
    SELECT order_id, 4, 1, 600000, 600000 FROM Orders WHERE order_code = 'ORD-SEED-003';

    INSERT INTO Tickets (ticket_code, order_item_id, attendee_name, attendee_email, qr_code, is_checked_in, checked_in_at)
    SELECT 'TIX-SEED-0004', oi.order_item_id, N'Nguyễn Văn A', 'customer@ticketbox.vn', 'JWT_PENDING', 1, DATEADD(DAY, -5, GETDATE())
    FROM OrderItems oi JOIN Orders o ON oi.order_id = o.order_id WHERE o.order_code = 'ORD-SEED-003';

    PRINT 'Order SEED-003 created (Workshop Standard, checked_in).';
END
GO

-- =============================================
-- ORDER 4: Customer mua vé EDM Festival (Event 3) — cancelled
-- =============================================
IF NOT EXISTS (SELECT 1 FROM Orders WHERE order_code = 'ORD-SEED-004')
BEGIN
    INSERT INTO Orders (order_code, user_id, event_id, total_amount, discount_amount, final_amount, status, payment_method, buyer_name, buyer_email, buyer_phone)
    VALUES ('ORD-SEED-004', 3, 3, 800000, 0, 800000, 'cancelled', 'seepay',
            N'Nguyễn Văn A', 'customer@ticketbox.vn', '0912345678');

    INSERT INTO OrderItems (order_id, ticket_type_id, quantity, unit_price, subtotal)
    SELECT order_id, 5, 1, 800000, 800000 FROM Orders WHERE order_code = 'ORD-SEED-004';

    PRINT 'Order SEED-004 created (EDM GA, cancelled).';
END
GO

-- =============================================
-- ORDER 5: Customer mua vé VIP Rock Concert (Event 4) — paid
-- =============================================
IF NOT EXISTS (SELECT 1 FROM Orders WHERE order_code = 'ORD-SEED-005')
BEGIN
    INSERT INTO Orders (order_code, user_id, event_id, total_amount, discount_amount, final_amount, status, payment_method, payment_date, buyer_name, buyer_email, buyer_phone)
    VALUES ('ORD-SEED-005', 3, 4, 2000000, 0, 2000000, 'paid', 'bank_transfer', DATEADD(DAY, -2, GETDATE()),
            N'Nguyễn Văn A', 'customer@ticketbox.vn', '0912345678');

    INSERT INTO OrderItems (order_id, ticket_type_id, quantity, unit_price, subtotal)
    SELECT order_id, 7, 1, 2000000, 2000000 FROM Orders WHERE order_code = 'ORD-SEED-005';

    INSERT INTO Tickets (ticket_code, order_item_id, attendee_name, attendee_email, qr_code)
    SELECT 'TIX-SEED-0005', oi.order_item_id, N'Nguyễn Văn A', 'customer@ticketbox.vn', 'JWT_PENDING'
    FROM OrderItems oi JOIN Orders o ON oi.order_id = o.order_id WHERE o.order_code = 'ORD-SEED-005';

    PRINT 'Order SEED-005 created (Rock VIP Front Row, paid).';
END
GO

-- =============================================
-- ORDER 6: Customer mua vé Marathon 21K (Event 8) — paid
-- =============================================
IF NOT EXISTS (SELECT 1 FROM Orders WHERE order_code = 'ORD-SEED-006')
BEGIN
    INSERT INTO Orders (order_code, user_id, event_id, total_amount, discount_amount, final_amount, status, payment_method, payment_date, buyer_name, buyer_email, buyer_phone)
    VALUES ('ORD-SEED-006', 3, 8, 700000, 0, 700000, 'paid', 'seepay', DATEADD(DAY, -3, GETDATE()),
            N'Nguyễn Văn A', 'customer@ticketbox.vn', '0912345678');

    INSERT INTO OrderItems (order_id, ticket_type_id, quantity, unit_price, subtotal)
    SELECT order_id, 14, 2, 350000, 700000 FROM Orders WHERE order_code = 'ORD-SEED-006';

    INSERT INTO Tickets (ticket_code, order_item_id, attendee_name, attendee_email, qr_code)
    SELECT 'TIX-SEED-0006', oi.order_item_id, N'Nguyễn Văn A', 'customer@ticketbox.vn', 'JWT_PENDING'
    FROM OrderItems oi JOIN Orders o ON oi.order_id = o.order_id WHERE o.order_code = 'ORD-SEED-006';

    INSERT INTO Tickets (ticket_code, order_item_id, attendee_name, attendee_email, qr_code)
    SELECT 'TIX-SEED-0007', oi.order_item_id, N'Trần Thị B', 'tranthib@gmail.com', 'JWT_PENDING'
    FROM OrderItems oi JOIN Orders o ON oi.order_id = o.order_id WHERE o.order_code = 'ORD-SEED-006';

    PRINT 'Order SEED-006 created (Marathon 21K x2, paid).';
END
GO

-- =============================================
-- ORDER 7: Customer mua vé Food Festival (Event 10) — paid
-- =============================================
IF NOT EXISTS (SELECT 1 FROM Orders WHERE order_code = 'ORD-SEED-007')
BEGIN
    INSERT INTO Orders (order_code, user_id, event_id, total_amount, discount_amount, final_amount, status, payment_method, payment_date, buyer_name, buyer_email, buyer_phone)
    VALUES ('ORD-SEED-007', 3, 10, 250000, 0, 250000, 'paid', 'bank_transfer', DATEADD(DAY, -1, GETDATE()),
            N'Nguyễn Văn A', 'customer@ticketbox.vn', '0912345678');

    INSERT INTO OrderItems (order_id, ticket_type_id, quantity, unit_price, subtotal)
    SELECT order_id, 18, 1, 250000, 250000 FROM Orders WHERE order_code = 'ORD-SEED-007';

    INSERT INTO Tickets (ticket_code, order_item_id, attendee_name, attendee_email, qr_code)
    SELECT 'TIX-SEED-0008', oi.order_item_id, N'Nguyễn Văn A', 'customer@ticketbox.vn', 'JWT_PENDING'
    FROM OrderItems oi JOIN Orders o ON oi.order_id = o.order_id WHERE o.order_code = 'ORD-SEED-007';

    PRINT 'Order SEED-007 created (Food Weekend Pass, paid).';
END
GO

-- =============================================
-- ORDER 8: Customer mua vé Ballet (Event 13) — paid
-- =============================================
IF NOT EXISTS (SELECT 1 FROM Orders WHERE order_code = 'ORD-SEED-008')
BEGIN
    INSERT INTO Orders (order_code, user_id, event_id, total_amount, discount_amount, final_amount, status, payment_method, payment_date, buyer_name, buyer_email, buyer_phone)
    VALUES ('ORD-SEED-008', 3, 13, 1600000, 0, 1600000, 'paid', 'seepay', DATEADD(DAY, -1, GETDATE()),
            N'Nguyễn Văn A', 'customer@ticketbox.vn', '0912345678');

    INSERT INTO OrderItems (order_id, ticket_type_id, quantity, unit_price, subtotal)
    SELECT order_id, 22, 2, 800000, 1600000 FROM Orders WHERE order_code = 'ORD-SEED-008';

    INSERT INTO Tickets (ticket_code, order_item_id, attendee_name, attendee_email, qr_code)
    SELECT 'TIX-SEED-0009', oi.order_item_id, N'Nguyễn Văn A', 'customer@ticketbox.vn', 'JWT_PENDING'
    FROM OrderItems oi JOIN Orders o ON oi.order_id = o.order_id WHERE o.order_code = 'ORD-SEED-008';

    INSERT INTO Tickets (ticket_code, order_item_id, attendee_name, attendee_email, qr_code)
    SELECT 'TIX-SEED-0010', oi.order_item_id, N'Nguyễn Thị C', 'nguyenthic@gmail.com', 'JWT_PENDING'
    FROM OrderItems oi JOIN Orders o ON oi.order_id = o.order_id WHERE o.order_code = 'ORD-SEED-008';

    PRINT 'Order SEED-008 created (Ballet Premium x2, paid).';
END
GO

-- =============================================
-- ORDER 9: Customer mua vé Startup Summit (Event 14) — refunded
-- =============================================
IF NOT EXISTS (SELECT 1 FROM Orders WHERE order_code = 'ORD-SEED-009')
BEGIN
    INSERT INTO Orders (order_code, user_id, event_id, total_amount, discount_amount, final_amount, status, payment_method, payment_date, buyer_name, buyer_email, buyer_phone)
    VALUES ('ORD-SEED-009', 3, 14, 500000, 0, 500000, 'refunded', 'seepay', DATEADD(DAY, -7, GETDATE()),
            N'Nguyễn Văn A', 'customer@ticketbox.vn', '0912345678');

    INSERT INTO OrderItems (order_id, ticket_type_id, quantity, unit_price, subtotal)
    SELECT order_id, 27, 1, 500000, 500000 FROM Orders WHERE order_code = 'ORD-SEED-009';

    PRINT 'Order SEED-009 created (Startup Attendee, refunded).';
END
GO

-- =============================================
-- ORDER 10: Customer mua vé AI Conference (Event 7) — paid
-- =============================================
IF NOT EXISTS (SELECT 1 FROM Orders WHERE order_code = 'ORD-SEED-010')
BEGIN
    INSERT INTO Orders (order_code, user_id, event_id, total_amount, discount_amount, final_amount, status, payment_method, payment_date, buyer_name, buyer_email, buyer_phone)
    VALUES ('ORD-SEED-010', 3, 7, 1500000, 0, 1500000, 'paid', 'bank_transfer', DATEADD(DAY, -4, GETDATE()),
            N'Nguyễn Văn A', 'customer@ticketbox.vn', '0912345678');

    INSERT INTO OrderItems (order_id, ticket_type_id, quantity, unit_price, subtotal)
    SELECT order_id, 12, 1, 1500000, 1500000 FROM Orders WHERE order_code = 'ORD-SEED-010';

    INSERT INTO Tickets (ticket_code, order_item_id, attendee_name, attendee_email, qr_code)
    SELECT 'TIX-SEED-0011', oi.order_item_id, N'Nguyễn Văn A', 'customer@ticketbox.vn', 'JWT_PENDING'
    FROM OrderItems oi JOIN Orders o ON oi.order_id = o.order_id WHERE o.order_code = 'ORD-SEED-010';

    PRINT 'Order SEED-010 created (AI Conference Full Access, paid).';
END
GO

PRINT '';
PRINT '============================================';
PRINT '  Seed Orders & Tickets Complete!';
PRINT '  10 orders | ~15 tickets | Mixed statuses';
PRINT '  QR JWT tokens will be generated by app.';
PRINT '============================================';
GO
