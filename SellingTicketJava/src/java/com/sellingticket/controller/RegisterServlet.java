package com.sellingticket.controller;

import com.sellingticket.service.UserService;
import java.io.IOException;
import java.time.LocalDate;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.util.Date;
import java.util.Set;
import java.util.logging.Level;
import java.util.logging.Logger;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(name = "RegisterServlet", urlPatterns = {"/register"})
public class RegisterServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(RegisterServlet.class.getName());
    private static final DateTimeFormatter DATE_FORMAT = DateTimeFormatter.ofPattern("yyyy-MM-dd");
    private static final Set<String> VALID_GENDERS = Set.of("male", "female", "other");

    private final UserService userService = new UserService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("register.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String fullName = sanitize(request.getParameter("fullName"));
        String email = sanitize(request.getParameter("email"));
        String phone = sanitize(request.getParameter("phone"));
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");
        String gender = sanitize(request.getParameter("gender"));

        // === VALIDATION ===

        // Required fields
        if (isBlank(fullName) || isBlank(email) || isBlank(password) || isBlank(confirmPassword)) {
            showError(request, response, "Vui lòng điền đầy đủ thông tin bắt buộc!");
            return;
        }

        // Length limits
        if (fullName.length() > 100) {
            showError(request, response, "Họ tên tối đa 100 ký tự!");
            return;
        }
        if (email.length() > 255) {
            showError(request, response, "Email tối đa 255 ký tự!");
            return;
        }

        // Email format (RFC 5322 subset)
        if (!email.matches("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$")) {
            showError(request, response, "Email không hợp lệ!");
            return;
        }

        // Phone format (Vietnam: 10 digits starting with 0, or empty)
        if (!isBlank(phone) && !phone.matches("^0[0-9]{9}$")) {
            showError(request, response, "Số điện thoại không hợp lệ (10 chữ số, bắt đầu bằng 0)!");
            return;
        }

        // Password strength: min 8 chars, max 128, 1 uppercase, 1 digit, 1 special char
        if (password.length() < 8) {
            showError(request, response, "Mật khẩu phải có ít nhất 8 ký tự!");
            return;
        }
        if (password.length() > 128) {
            showError(request, response, "Mật khẩu tối đa 128 ký tự!");
            return;
        }
        if (!password.matches(".*[A-Z].*")) {
            showError(request, response, "Mật khẩu phải có ít nhất 1 chữ hoa!");
            return;
        }
        if (!password.matches(".*[0-9].*")) {
            showError(request, response, "Mật khẩu phải có ít nhất 1 chữ số!");
            return;
        }
        if (!password.matches(".*[^a-zA-Z0-9\\s].*")) {
            showError(request, response, "Mật khẩu phải có ít nhất 1 ký tự đặc biệt (!@#$%...)!");
            return;
        }

        // Password match
        if (!password.equals(confirmPassword)) {
            showError(request, response, "Mật khẩu không khớp!");
            return;
        }

        // Gender whitelist
        if (!isBlank(gender) && !VALID_GENDERS.contains(gender)) {
            showError(request, response, "Giới tính không hợp lệ!");
            return;
        }

        // Normalize email to lowercase before all checks
        email = email.toLowerCase();

        // Email uniqueness
        if (userService.isEmailExists(email)) {
            showError(request, response, "Email đã tồn tại!");
            return;
        }

        // === REGISTER ===
        Date dob = parseDateOrNull(request.getParameter("birthDate"));
        String safeGender = VALID_GENDERS.contains(gender) ? gender : null;
        String safePhone = isBlank(phone) ? null : phone;

        boolean success = userService.registerFull(email, password, fullName, safePhone, safeGender, dob);

        if (success) {
            LOGGER.log(Level.INFO, "New user registered: {0}", email);
            request.getSession().setAttribute("toastMessage", "Đăng ký thành công! Vui lòng đăng nhập.");
            request.getSession().setAttribute("toastType", "success");
            response.sendRedirect(request.getContextPath() + "/login");
        } else {
            LOGGER.log(Level.WARNING, "Registration failed for: {0}", email);
            showError(request, response, "Đăng ký thất bại. Vui lòng thử lại.");
        }
    }

    private void showError(HttpServletRequest request, HttpServletResponse response, String message)
            throws ServletException, IOException {
        request.setAttribute("error", message);
        request.getRequestDispatcher("register.jsp").forward(request, response);
    }

    private Date parseDateOrNull(String dateStr) {
        if (dateStr == null || dateStr.trim().isEmpty()) return null;
        try {
            LocalDate ld = LocalDate.parse(dateStr.trim(), DATE_FORMAT);
            // Reject future dates, too old, and under 13 years old
            if (ld.isAfter(LocalDate.now()) || ld.isBefore(LocalDate.of(1900, 1, 1))) {
                return null;
            }
            if (ld.isAfter(LocalDate.now().minusYears(13))) {
                return null; // Must be at least 13 years old
            }
            return Date.from(ld.atStartOfDay(ZoneId.systemDefault()).toInstant());
        } catch (DateTimeParseException e) {
            LOGGER.log(Level.FINE, "Invalid date format: {0}", dateStr);
            return null;
        }
    }

    private String sanitize(String s) {
        return s == null ? null : s.trim();
    }

    private boolean isBlank(String s) {
        return s == null || s.trim().isEmpty();
    }
}
