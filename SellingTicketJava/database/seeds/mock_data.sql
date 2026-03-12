-- =============================================
-- TICKETBOX MOCK DATA - Comprehensive Sample Data
-- Run this AFTER ticketbox_schema.sql
-- =============================================

USE SellingTicketDB;
GO

-- =============================================
-- CLEAR EXISTING DATA (Optional - for fresh start)
-- =============================================
-- DELETE FROM VoucherUsages;
-- DELETE FROM Vouchers;
-- DELETE FROM Tickets;
-- DELETE FROM OrderItems;
-- DELETE FROM Orders;
-- DELETE FROM TicketTypes;
-- DELETE FROM Events;
-- DELETE FROM Categories;
-- DELETE FROM Users WHERE user_id > 3;

-- =============================================
-- INSERT ADDITIONAL EVENTS
-- =============================================

-- More Music Events
INSERT INTO Events (organizer_id, category_id, title, slug, description, banner_image, location, address, start_date, end_date, status, is_featured, views) VALUES
(2, 1, N'Rock Việt Live Concert 2026', 'rock-viet-live-2026', 
 N'Đêm nhạc rock hoành tráng với sự tham gia của các ban nhạc rock hàng đầu Việt Nam: Bức Tường, Microwave, Ngũ Cung', 
 'https://images.unsplash.com/photo-1459749411175-04bf5292ceea?w=800', 
 N'Nhà hát Hòa Bình', N'240 Đường 3/2, Quận 10, TP.HCM', 
 '2026-03-20 19:00:00', '2026-03-20 23:00:00', 'approved', 1, 2500);

INSERT INTO Events (organizer_id, category_id, title, slug, description, banner_image, location, address, start_date, end_date, status, is_featured, views) VALUES
(2, 1, N'Jazz Night - Blue Moon Session', 'jazz-night-blue-moon', 
 N'Đêm nhạc jazz đỉnh cao với các nghệ sĩ quốc tế và Việt Nam', 
 'https://images.unsplash.com/photo-1514320291840-2e0a9bf2a9ae?w=800', 
 N'Saigon Opera House', N'7 Công Trường Lam Sơn, Quận 1, TP.HCM', 
 '2026-03-25 20:00:00', '2026-03-25 23:00:00', 'approved', 0, 850);

-- Workshop Events
INSERT INTO Events (organizer_id, category_id, title, slug, description, banner_image, location, address, start_date, end_date, status, is_featured, views) VALUES
(2, 3, N'Digital Marketing Masterclass 2026', 'digital-marketing-masterclass', 
 N'Workshop chuyên sâu về Digital Marketing: SEO, Google Ads, Facebook Ads, Content Marketing', 
 'https://images.unsplash.com/photo-1505373877841-8d25f7d46678?w=800', 
 N'Dreamplex', N'195 Điện Biên Phủ, Quận 3, TP.HCM', 
 '2026-03-15 09:00:00', '2026-03-15 17:00:00', 'approved', 1, 1200);

INSERT INTO Events (organizer_id, category_id, title, slug, description, banner_image, location, address, start_date, end_date, status, is_featured, views) VALUES
(2, 3, N'AI & Machine Learning Conference', 'ai-ml-conference-2026', 
 N'Hội thảo về Trí tuệ nhân tạo và Machine Learning với các chuyên gia hàng đầu', 
 'https://images.unsplash.com/photo-1475721027785-f74eccf877e2?w=800', 
 N'GEM Center', N'8 Nguyễn Bỉnh Khiêm, Quận 1, TP.HCM', 
 '2026-04-01 08:30:00', '2026-04-01 18:00:00', 'approved', 1, 1800);

-- Sports Events
INSERT INTO Events (organizer_id, category_id, title, slug, description, banner_image, location, address, start_date, end_date, status, is_featured, views) VALUES
(2, 2, N'Marathon Mùa Xuân 2026', 'marathon-mua-xuan-2026', 
 N'Giải chạy marathon lớn nhất mùa xuân với các cự ly 5K, 10K, 21K, 42K', 
 'https://images.unsplash.com/photo-1571902943202-507ec2618e8f?w=800', 
 N'Phố đi bộ Nguyễn Huệ', N'Nguyễn Huệ, Quận 1, TP.HCM', 
 '2026-03-10 05:00:00', '2026-03-10 12:00:00', 'approved', 1, 3000);

INSERT INTO Events (organizer_id, category_id, title, slug, description, banner_image, location, address, start_date, end_date, status, is_featured, views) VALUES
(2, 2, N'Giải Tennis Mở rộng TP.HCM', 'tennis-open-hcm-2026', 
 N'Giải tennis chuyên nghiệp với sự tham gia của các tay vợt hàng đầu Việt Nam', 
 'https://images.unsplash.com/photo-1622279457486-62dcc4a431d6?w=800', 
 N'Sân Tennis Phú Thọ', N'1 Lý Thường Kiệt, Quận 10, TP.HCM', 
 '2026-04-15 08:00:00', '2026-04-20 18:00:00', 'approved', 0, 650);

-- Food Events
INSERT INTO Events (organizer_id, category_id, title, slug, description, banner_image, location, address, start_date, end_date, status, is_featured, views) VALUES
(2, 4, N'Lễ hội Ẩm thực Quốc tế 2026', 'food-festival-2026', 
 N'Lễ hội ẩm thực lớn nhất với hơn 100 gian hàng từ 30 quốc gia', 
 'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=800', 
 N'SECC', N'799 Nguyễn Văn Linh, Quận 7, TP.HCM', 
 '2026-04-10 10:00:00', '2026-04-12 22:00:00', 'approved', 1, 4500);

INSERT INTO Events (organizer_id, category_id, title, slug, description, banner_image, location, address, start_date, end_date, status, is_featured, views) VALUES
(2, 4, N'Wine & Dine Experience', 'wine-dine-2026', 
 N'Trải nghiệm ẩm thực cao cấp kết hợp rượu vang hảo hạng', 
 'https://images.unsplash.com/photo-1423483641154-5411ec9c0ddf?w=800', 
 N'Rex Hotel', N'141 Nguyễn Huệ, Quận 1, TP.HCM', 
 '2026-03-28 18:00:00', '2026-03-28 22:00:00', 'approved', 0, 320);

-- Art Events
INSERT INTO Events (organizer_id, category_id, title, slug, description, banner_image, location, address, start_date, end_date, status, is_featured, views) VALUES
(2, 5, N'Triển lãm Nghệ thuật Đương đại', 'contemporary-art-2026', 
 N'Triển lãm tranh và điêu khắc của các nghệ sĩ đương đại Việt Nam', 
 'https://images.unsplash.com/photo-1531243269054-5ebf6f34081e?w=800', 
 N'Bảo tàng Mỹ thuật TP.HCM', N'97A Phó Đức Chính, Quận 1, TP.HCM', 
 '2026-03-01 09:00:00', '2026-04-30 18:00:00', 'approved', 0, 1100);

INSERT INTO Events (organizer_id, category_id, title, slug, description, banner_image, location, address, start_date, end_date, status, is_featured, views) VALUES
(2, 5, N'Ballet Swan Lake - Hồ Thiên Nga', 'ballet-swan-lake-2026', 
 N'Vở ballet kinh điển Swan Lake do đoàn ballet Việt Nam biểu diễn', 
 'https://images.unsplash.com/photo-1518834107812-67b0b7c58434?w=800', 
 N'Nhà hát Lớn TP.HCM', N'7 Công Trường Lam Sơn, Quận 1, TP.HCM', 
 '2026-04-05 19:30:00', '2026-04-05 21:30:00', 'approved', 1, 890);

-- Business Events
INSERT INTO Events (organizer_id, category_id, title, slug, description, banner_image, location, address, start_date, end_date, status, is_featured, views) VALUES
(2, 6, N'Startup Summit Vietnam 2026', 'startup-summit-2026', 
 N'Hội nghị thượng đỉnh khởi nghiệp lớn nhất Việt Nam với các nhà đầu tư và startup', 
 'https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=800', 
 N'GEM Center', N'8 Nguyễn Bỉnh Khiêm, Quận 1, TP.HCM', 
 '2026-04-15 08:00:00', '2026-04-15 18:00:00', 'approved', 1, 2200);

INSERT INTO Events (organizer_id, category_id, title, slug, description, banner_image, location, address, start_date, end_date, status, is_featured, views) VALUES
(2, 6, N'Tech Networking Night', 'tech-networking-2026', 
 N'Đêm giao lưu cho cộng đồng tech và startup', 
 'https://images.unsplash.com/photo-1511578314322-379afb476865?w=800', 
 N'The Hive Saigon', N'56 Nguyễn Thị Minh Khai, Quận 3, TP.HCM', 
 '2026-03-22 18:00:00', '2026-03-22 21:00:00', 'approved', 0, 450);

-- =============================================
-- INSERT TICKET TYPES FOR NEW EVENTS
-- =============================================

-- Rock Concert (event_id = 4)
INSERT INTO TicketTypes (event_id, name, description, price, quantity, sold_quantity) VALUES
(4, N'VIP Front Row', N'Hàng ghế VIP đầu tiên, gặp gỡ nghệ sĩ', 2000000, 50, 35),
(4, N'VIP', N'Khu VIP với view đẹp', 1200000, 150, 89),
(4, N'Standard', N'Vé thường', 500000, 500, 245);

-- Jazz Night (event_id = 5)
INSERT INTO TicketTypes (event_id, name, description, price, quantity, sold_quantity) VALUES
(5, N'VIP Table', N'Bàn VIP 4 người với rượu vang', 4000000, 20, 12),
(5, N'Standard', N'Ghế ngồi thường', 800000, 100, 45);

-- Digital Marketing Workshop (event_id = 6)
INSERT INTO TicketTypes (event_id, name, description, price, quantity, sold_quantity) VALUES
(6, N'Early Bird', N'Vé ưu đãi đặt sớm', 350000, 30, 30),
(6, N'Standard', N'Vé tiêu chuẩn', 500000, 70, 28);

-- AI Conference (event_id = 7)
INSERT INTO TicketTypes (event_id, name, description, price, quantity, sold_quantity) VALUES
(7, N'Full Access', N'Truy cập đầy đủ + workshop hands-on', 1500000, 50, 32),
(7, N'Conference Only', N'Chỉ tham dự hội thảo', 800000, 150, 78);

-- Marathon (event_id = 8)
INSERT INTO TicketTypes (event_id, name, description, price, quantity, sold_quantity) VALUES
(8, N'42K Full Marathon', N'Cự ly 42K đầy đủ', 500000, 500, 280),
(8, N'21K Half Marathon', N'Cự ly 21K', 350000, 1000, 650),
(8, N'10K Fun Run', N'Cự ly 10K', 200000, 2000, 1200),
(8, N'5K Family', N'Cự ly 5K cho gia đình', 150000, 1500, 890);

-- Tennis (event_id = 9)
INSERT INTO TicketTypes (event_id, name, description, price, quantity, sold_quantity) VALUES
(9, N'VIP Courtside', N'Ghế VIP cạnh sân', 500000, 50, 22),
(9, N'General', N'Ghế thường', 150000, 200, 85);

-- Food Festival (event_id = 10)
INSERT INTO TicketTypes (event_id, name, description, price, quantity, sold_quantity) VALUES
(10, N'Weekend Pass', N'Vé cả 3 ngày', 250000, 500, 320),
(10, N'Single Day', N'Vé 1 ngày', 100000, 2000, 1200);

-- Wine & Dine (event_id = 11)
INSERT INTO TicketTypes (event_id, name, description, price, quantity, sold_quantity) VALUES
(11, N'Full Experience', N'5 món + 5 loại rượu vang', 2500000, 30, 18);

-- Art Exhibition (event_id = 12)
INSERT INTO TicketTypes (event_id, name, description, price, quantity, sold_quantity) VALUES
(12, N'Adult', N'Người lớn', 100000, 500, 220),
(12, N'Student', N'Học sinh/Sinh viên', 50000, 300, 180);

-- Ballet (event_id = 13)
INSERT INTO TicketTypes (event_id, name, description, price, quantity, sold_quantity) VALUES
(13, N'VIP Balcony', N'Ban công VIP tầng 1', 1500000, 40, 28),
(13, N'Premium', N'Ghế Premium tầng trệt', 800000, 100, 65),
(13, N'Standard', N'Ghế thường', 400000, 200, 145);

-- Startup Summit (event_id = 14)
INSERT INTO TicketTypes (event_id, name, description, price, quantity, sold_quantity) VALUES
(14, N'Investor Pass', N'Dành cho nhà đầu tư + networking đặc biệt', 3000000, 30, 22),
(14, N'Startup Pass', N'Dành cho startup + pitch opportunity', 1500000, 100, 78),
(14, N'Attendee', N'Tham dự thông thường', 500000, 300, 195);

-- Tech Networking (event_id = 15)
INSERT INTO TicketTypes (event_id, name, description, price, quantity, sold_quantity) VALUES
(15, N'Standard', N'Vé vào cửa + đồ uống', 0, 150, 89);

-- =============================================
-- ADD MORE CATEGORIES IF NEEDED
-- =============================================
INSERT INTO Categories (name, slug, icon, description) VALUES
(N'Công nghệ', 'tech', 'fa-laptop-code', N'Hội thảo công nghệ, hackathon');

PRINT 'Mock data inserted successfully!';
GO
