package com.sellingticket.controller;

import com.sellingticket.dao.UserDAO;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Date;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(name = "RegisterServlet", urlPatterns = {"/register"})
public class RegisterServlet extends HttpServlet {

    private static final SimpleDateFormat DATE_FORMAT = new SimpleDateFormat("yyyy-MM-dd");

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("register.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String fullName = request.getParameter("fullName");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");

        if (!password.equals(confirmPassword)) {
            showError(request, response, "Mật khẩu không khớp!");
            return;
        }

        UserDAO dao = new UserDAO();
        if (dao.isEmailExists(email)) {
            showError(request, response, "Email đã tồn tại!");
            return;
        }

        Date dob = parseDateOrNull(request.getParameter("birthDate"));
        String gender = request.getParameter("gender");

        boolean success = dao.registerFull(email, password, fullName, phone, gender, dob);
        if (success) {
            response.sendRedirect("login.jsp?registered=true");
        } else {
            showError(request, response, "Đăng ký thất bại. Vui lòng thử lại.");
        }
    }

    private void showError(HttpServletRequest request, HttpServletResponse response, String message)
            throws ServletException, IOException {
        request.setAttribute("error", message);
        request.getRequestDispatcher("register.jsp").forward(request, response);
    }

    private Date parseDateOrNull(String dateStr) {
        if (dateStr == null || dateStr.isEmpty()) return null;
        try {
            return DATE_FORMAT.parse(dateStr);
        } catch (Exception e) {
            return null;
        }
    }
}
