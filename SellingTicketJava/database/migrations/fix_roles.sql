-- =============================================
-- UTILITY: Fix User Roles for Testing
-- Run this script in SQL Server to grant yourself access
-- =============================================

USE SellingTicketDB;
GO

-- 1. Update your own account to ORGANIZER
-- Replace 'your_email@example.com' with the email you registered with
UPDATE Users SET role = 'organizer' WHERE email = 'duong@gmail.com'; 

-- 2. Update another account to ADMIN (if needed)
UPDATE Users SET role = 'admin' WHERE email = 'admin@sellingticket.com';

-- 3. Verify roles
SELECT user_id, email, full_name, role FROM Users;
GO
