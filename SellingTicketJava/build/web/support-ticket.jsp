<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>

<jsp:include page="header.jsp" />

<div class="container py-5" style="max-width: 720px;">
    <nav aria-label="breadcrumb" class="mb-4 animate-fadeInDown">
        <ol class="breadcrumb mb-0">
            <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/support/my-tickets" class="text-decoration-none">Hỗ trợ</a></li>
            <li class="breadcrumb-item active">Tạo yêu cầu</li>
        </ol>
    </nav>

    <div class="glass-strong p-4 p-md-5 rounded-4 animate-fadeInUp">
        <div class="text-center mb-4">
            <div class="d-inline-flex align-items-center justify-content-center rounded-circle mb-3" style="width:64px;height:64px;background:linear-gradient(135deg,#f59e0b,#f97316);">
                <i class="fas fa-headset text-white fa-lg"></i>
            </div>
            <h3 class="fw-bold mb-1">Báo cáo vấn đề</h3>
            <p class="text-muted">Mô tả vấn đề bạn gặp phải, chúng tôi sẽ hỗ trợ sớm nhất</p>
        </div>

        <c:if test="${param.error != null}">
            <div class="alert rounded-4 border-0 mb-4" style="background:rgba(239,68,68,0.1);border-left:4px solid #ef4444 !important;">
                <i class="fas fa-exclamation-circle text-danger me-2"></i>Không thể tạo yêu cầu. Vui lòng thử lại.
            </div>
        </c:if>

        <form method="POST" action="${pageContext.request.contextPath}/support/create">
            <input type="hidden" name="csrf_token" value="${sessionScope.csrf_token}">
            <c:if test="${not empty orderId}">
                <input type="hidden" name="orderId" value="${orderId}">
                <div class="alert glass rounded-4 border-0 mb-4 py-2 px-3">
                    <small class="text-muted"><i class="fas fa-link me-1"></i>Liên kết đến đơn hàng #${orderId}</small>
                </div>
            </c:if>
            <c:if test="${not empty eventId}">
                <input type="hidden" name="eventId" value="${eventId}">
            </c:if>

            <div class="mb-4">
                <label class="form-label fw-medium">Loại vấn đề <span class="text-danger">*</span></label>
                <div class="row g-2">
                    <div class="col-6">
                        <input type="radio" class="btn-check" name="category" id="cat_payment" value="payment_error" required>
                        <label class="btn glass w-100 rounded-3 py-3 text-start" for="cat_payment">
                            <i class="fas fa-credit-card text-danger me-2"></i>Lỗi thanh toán
                        </label>
                    </div>
                    <div class="col-6">
                        <input type="radio" class="btn-check" name="category" id="cat_ticket" value="missing_ticket">
                        <label class="btn glass w-100 rounded-3 py-3 text-start" for="cat_ticket">
                            <i class="fas fa-ticket-alt text-warning me-2"></i>Không nhận được vé
                        </label>
                    </div>
                    <div class="col-6">
                        <input type="radio" class="btn-check" name="category" id="cat_cancel" value="cancellation">
                        <label class="btn glass w-100 rounded-3 py-3 text-start" for="cat_cancel">
                            <i class="fas fa-ban text-info me-2"></i>Yêu cầu hủy vé
                        </label>
                    </div>
                    <div class="col-6">
                        <input type="radio" class="btn-check" name="category" id="cat_refund" value="refund">
                        <label class="btn glass w-100 rounded-3 py-3 text-start" for="cat_refund">
                            <i class="fas fa-undo text-success me-2"></i>Yêu cầu hoàn tiền
                        </label>
                    </div>
                    <div class="col-6">
                        <input type="radio" class="btn-check" name="category" id="cat_event" value="event_issue">
                        <label class="btn glass w-100 rounded-3 py-3 text-start" for="cat_event">
                            <i class="fas fa-calendar-times text-primary me-2"></i>Vấn đề sự kiện
                        </label>
                    </div>
                    <div class="col-6">
                        <input type="radio" class="btn-check" name="category" id="cat_account" value="account_issue">
                        <label class="btn glass w-100 rounded-3 py-3 text-start" for="cat_account">
                            <i class="fas fa-user-cog text-secondary me-2"></i>Vấn đề tài khoản
                        </label>
                    </div>
                    <div class="col-4">
                        <input type="radio" class="btn-check" name="category" id="cat_tech" value="technical">
                        <label class="btn glass w-100 rounded-3 py-3 text-start" for="cat_tech">
                            <i class="fas fa-bug text-danger me-2"></i>Lỗi kỹ thuật
                        </label>
                    </div>
                    <div class="col-4">
                        <input type="radio" class="btn-check" name="category" id="cat_feedback" value="feedback">
                        <label class="btn glass w-100 rounded-3 py-3 text-start" for="cat_feedback">
                            <i class="fas fa-lightbulb text-warning me-2"></i>Góp ý
                        </label>
                    </div>
                    <div class="col-4">
                        <input type="radio" class="btn-check" name="category" id="cat_other" value="other">
                        <label class="btn glass w-100 rounded-3 py-3 text-start" for="cat_other">
                            <i class="fas fa-ellipsis-h text-muted me-2"></i>Khác
                        </label>
                    </div>
                </div>
            </div>

            <div class="mb-4">
                <label for="subject" class="form-label fw-medium">Tiêu đề <span class="text-danger">*</span></label>
                <input type="text" id="subject" name="subject" class="form-control glass rounded-3" placeholder="Mô tả ngắn gọn vấn đề..." required maxlength="200">
            </div>

            <div class="mb-4">
                <label for="description" class="form-label fw-medium">Chi tiết <span class="text-danger">*</span></label>
                <textarea id="description" name="description" class="form-control glass rounded-3" rows="6"
                    placeholder="Mô tả chi tiết vấn đề bạn gặp phải: thời gian, mã đơn hàng, thông báo lỗi..." required></textarea>
                <small class="text-muted">Càng chi tiết, chúng tôi càng hỗ trợ nhanh hơn</small>
            </div>

            <div class="d-flex gap-3">
                <a href="${pageContext.request.contextPath}/support/my-tickets" class="btn glass rounded-pill px-4 py-2">
                    <i class="fas fa-arrow-left me-2"></i>Quay lại
                </a>
                <button type="submit" class="btn flex-grow-1 rounded-pill py-2 fw-medium" style="background:linear-gradient(135deg,#f59e0b,#f97316);color:white;">
                    <i class="fas fa-paper-plane me-2"></i>Gửi yêu cầu hỗ trợ
                </button>
            </div>
        </form>
    </div>
</div>

<style>
.btn-check:checked + .btn { border-color: #f59e0b !important; background: rgba(245,158,11,0.08) !important; box-shadow: 0 0 0 2px rgba(245,158,11,0.3); }
</style>

<jsp:include page="footer.jsp" />
