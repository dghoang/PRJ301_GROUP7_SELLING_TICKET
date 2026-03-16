package com.sellingticket.controller;

import com.sellingticket.service.UserService;
import java.io.IOException;
import java.util.LinkedHashMap;
import java.time.LocalDate;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.util.Date;
import java.util.Map;
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
    private static final ZoneId ZONE_VN = ZoneId.of("Asia/Ho_Chi_Minh");
    private static final int MIN_REGISTER_AGE = 16;

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
        String birthDateRaw = sanitize(request.getParameter("birthDate"));

        // Normalize email early for checks and form re-render.
        if (!isBlank(email)) {
            email = email.toLowerCase();
        }

        Map<String, String> fieldErrors = new LinkedHashMap<>();

        // === VALIDATION ===

        // Required fields
        if (isBlank(fullName)) {
            fieldErrors.put("fullName", "Vui lòng nhập họ và tên.");
        }
        if (isBlank(email)) {
            fieldErrors.put("email", "Vui lòng nhập email.");
        }
        if (isBlank(password)) {
            fieldErrors.put("password", "Vui lòng nhập mật khẩu.");
        }
        if (isBlank(confirmPassword)) {
            fieldErrors.put("confirmPassword", "Vui lòng xác nhận mật khẩu.");
        }
        if (isBlank(birthDateRaw)) {
            fieldErrors.put("birthDate", "Vui lòng chọn ngày sinh.");
        }

        // Length limits
        if (!isBlank(fullName) && fullName.length() > 100) {
            fieldErrors.put("fullName", "Họ tên tối đa 100 ký tự.");
        }
        if (!isBlank(email) && email.length() > 255) {
            fieldErrors.put("email", "Email tối đa 255 ký tự.");
        }

        // Email format (RFC 5322 subset)
        boolean emailFormatValid = !isBlank(email)
                && email.matches("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$");
        if (!isBlank(email) && !emailFormatValid) {
            fieldErrors.put("email", "Email không hợp lệ.");
        }

        // Email uniqueness
        if (emailFormatValid && userService.isEmailExists(email)) {
            fieldErrors.put("email", "Email đã tồn tại.");
        }

        // Phone format (Vietnam: 10 digits starting with 0, or empty)
        if (!isBlank(phone) && !phone.matches("^0[0-9]{9}$")) {
            fieldErrors.put("phone", "Số điện thoại không hợp lệ (10 chữ số, bắt đầu bằng 0).");
        }

        // Birth date: valid date, not future, and at least MIN_REGISTER_AGE years old.
        Date dob = null;
        if (!isBlank(birthDateRaw)) {
            LocalDate birthDate = parseBirthDate(birthDateRaw);
            if (birthDate == null) {
                fieldErrors.put("birthDate", "Ngày sinh không hợp lệ.");
            } else {
                LocalDate today = LocalDate.now(ZONE_VN);
                if (birthDate.isAfter(today)) {
                    fieldErrors.put("birthDate", "Ngày sinh không thể ở tương lai.");
                } else if (birthDate.isAfter(today.minusYears(MIN_REGISTER_AGE))) {
                    fieldErrors.put("birthDate", "Bạn phải đủ 16 tuổi để tạo tài khoản.");
                } else if (birthDate.isBefore(LocalDate.of(1900, 1, 1))) {
                    fieldErrors.put("birthDate", "Ngày sinh không hợp lệ.");
                } else {
                    dob = Date.from(birthDate.atStartOfDay(ZONE_VN).toInstant());
                }
            }
        }

        // Password strength: min 8 chars, max 128, 1 uppercase, 1 digit, 1 special char
        if (!isBlank(password) && password.length() < 8) {
            fieldErrors.put("password", "Mật khẩu phải có ít nhất 8 ký tự.");
        }
        if (!isBlank(password) && password.length() > 128) {
            fieldErrors.put("password", "Mật khẩu tối đa 128 ký tự.");
        }
        if (!isBlank(password) && !password.matches(".*[A-Z].*")) {
            fieldErrors.put("password", "Mật khẩu phải có ít nhất 1 chữ hoa.");
        }
        if (!isBlank(password) && !password.matches(".*[0-9].*")) {
            fieldErrors.put("password", "Mật khẩu phải có ít nhất 1 chữ số.");
        }
        if (!isBlank(password) && !password.matches(".*[^a-zA-Z0-9\\s].*")) {
            fieldErrors.put("password", "Mật khẩu phải có ít nhất 1 ký tự đặc biệt.");
        }

        // Password match
        if (!isBlank(password) && !isBlank(confirmPassword) && !password.equals(confirmPassword)) {
            fieldErrors.put("confirmPassword", "Mật khẩu xác nhận không khớp.");
        }

        // Gender whitelist
        if (!isBlank(gender) && !VALID_GENDERS.contains(gender)) {
            fieldErrors.put("gender", "Giới tính không hợp lệ.");
        }

        if (!fieldErrors.isEmpty()) {
            showFieldErrors(request, response, fieldErrors, fullName, email, phone, birthDateRaw, gender);
            return;
        }

        // === REGISTER ===
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
            Map<String, String> finalErrors = new LinkedHashMap<>();
            if (userService.isEmailExists(email)) {
                finalErrors.put("email", "Email đã tồn tại.");
                showFieldErrors(request, response, finalErrors, fullName, email, phone, birthDateRaw, gender);
                return;
            }
            showError(request, response, "Đăng ký thất bại. Vui lòng thử lại.");
        }
    }

    private void showError(HttpServletRequest request, HttpServletResponse response, String message)
            throws ServletException, IOException {
        request.setAttribute("error", message);
        request.getRequestDispatcher("register.jsp").forward(request, response);
    }

    private void showFieldErrors(HttpServletRequest request, HttpServletResponse response,
            Map<String, String> fieldErrors,
            String fullName, String email, String phone, String birthDate, String gender)
            throws ServletException, IOException {
        request.setAttribute("error", "Vui lòng kiểm tra lại thông tin đã nhập.");
        request.setAttribute("fieldErrors", fieldErrors);
        request.setAttribute("formFullName", fullName);
        request.setAttribute("formEmail", email);
        request.setAttribute("formPhone", phone);
        request.setAttribute("formBirthDate", birthDate);
        request.setAttribute("formGender", gender);
        request.getRequestDispatcher("register.jsp").forward(request, response);
    }

    private LocalDate parseBirthDate(String dateStr) {
        if (dateStr == null || dateStr.trim().isEmpty()) return null;
        try {
            return LocalDate.parse(dateStr.trim(), DATE_FORMAT);
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
