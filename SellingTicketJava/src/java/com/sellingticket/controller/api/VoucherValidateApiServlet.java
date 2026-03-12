package com.sellingticket.controller.api;

import com.sellingticket.model.User;
import com.sellingticket.service.VoucherService;
import com.sellingticket.service.VoucherService.VoucherResult;
import static com.sellingticket.util.ServletUtil.*;

import java.io.IOException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * Voucher Validation API — Read-only JSON endpoint for checking voucher codes.
 * Requires authenticated user. Does NOT modify state (no usage increment).
 *
 * POST /api/voucher/validate
 * Body: code=SYSVIP10&eventId=17&amount=250000
 * Response: { valid, discountAmount, voucherScope, fundSource, message }
 */
@WebServlet(name = "VoucherValidateApiServlet", urlPatterns = {"/api/voucher/validate"})
public class VoucherValidateApiServlet extends HttpServlet {

    private VoucherService voucherService;

    @Override
    public void init() {
        voucherService = new VoucherService();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        response.setContentType("application/json;charset=UTF-8");

        // Require authenticated user (prevent anonymous probing of voucher codes)
        User user = getSessionUser(request);
        if (user == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().write("{\"valid\":false,\"message\":\"Vui lòng đăng nhập để sử dụng mã giảm giá\"}");
            return;
        }

        String code = request.getParameter("code");
        if (code == null || code.trim().isEmpty() || code.trim().length() > 50) {
            response.getWriter().write("{\"valid\":false,\"message\":\"Mã giảm giá không hợp lệ\"}");
            return;
        }
        code = code.trim();
        int eventId = parseIntOrDefault(request.getParameter("eventId"), -1);
        double amount = 0;
        try {
            amount = Double.parseDouble(request.getParameter("amount"));
        } catch (Exception ignored) {}

        VoucherResult result = voucherService.validateVoucher(code, eventId, amount);
        String json = "{\"valid\":" + result.valid
                + ",\"discountAmount\":" + result.discountAmount
                + ",\"voucherScope\":\"" + esc(result.voucherScope) + "\""
                + ",\"fundSource\":\"" + esc(result.fundSource) + "\""
                + ",\"message\":\"" + esc(result.message) + "\"}";
        response.getWriter().write(json);
    }

    private static String esc(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n");
    }
}
