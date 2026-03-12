-- =============================================
-- MIGRATION: Fix BCrypt password hashes
-- Run this ONCE to fix seed user passwords
-- =============================================
-- Old seed data used plain text passwords (e.g. 'admin123')
-- which are incompatible with BCrypt verification.
-- New passwords follow validation rules: 8+ chars, 1 uppercase, 1 digit
--
-- | Email                    | New Password   |
-- |--------------------------|----------------|
-- | admin@ticketbox.vn       | Admin@123      |
-- | organizer@ticketbox.vn   | Organizer@123  |
-- | customer@ticketbox.vn    | Customer@123   |
-- =============================================

USE SellingTicketDB;
GO

UPDATE Users
SET password_hash = '$2a$12$odAx650SUPsEauwOWzajb.FUMCDzKZWYPLeG2.NlCs3NBxH2N/Pg.'
WHERE email = 'admin@ticketbox.vn';

UPDATE Users
SET password_hash = '$2a$12$Bs2nPLu8UK8GZsy1flBiGewDcqwu4x/KqtksjeYEWRQtcBxgiyNVC'
WHERE email = 'organizer@ticketbox.vn';

UPDATE Users
SET password_hash = '$2a$12$07H.CL1nHx2kzH7oo1odGOClkIg/oK3s7.D/wxcRIL6xjhIo9sYhK'
WHERE email = 'customer@ticketbox.vn';

PRINT 'All seed user passwords updated to BCrypt hashes.';
PRINT 'Login credentials:';
PRINT '  admin@ticketbox.vn     / Admin@123';
PRINT '  organizer@ticketbox.vn / Organizer@123';
PRINT '  customer@ticketbox.vn  / Customer@123';
GO
