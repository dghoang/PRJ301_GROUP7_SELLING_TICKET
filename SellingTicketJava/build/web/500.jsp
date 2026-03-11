<%@page contentType="text/html" pageEncoding="UTF-8" isErrorPage="true"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>

<jsp:include page="header.jsp" />

<style>
@keyframes pulse500 {
    0%, 100% { transform: scale(1); opacity: 1; }
    50% { transform: scale(1.05); opacity: 0.8; }
}
@keyframes shake {
    0%, 100% { transform: translateX(0); }
    10%, 30%, 50%, 70%, 90% { transform: translateX(-5px); }
    20%, 40%, 60%, 80% { transform: translateX(5px); }
}
.pulse-500 {
    animation: pulse500 3s ease-in-out infinite;
}
.shake-icon {
    animation: shake 0.8s ease-in-out;
}
</style>

<div class="container py-5 d-flex align-items-center justify-content-center" style="min-height: 70vh;">
    <div class="text-center position-relative">
        <!-- Floating blobs -->
        <div class="position-absolute" style="top: -50px; left: -100px; width: 150px; height: 150px; background: linear-gradient(135deg, rgba(220, 38, 38, 0.2), rgba(234, 88, 12, 0.2)); border-radius: 50%; filter: blur(40px); animation: floatSmooth 8s ease-in-out infinite;"></div>
        <div class="position-absolute" style="bottom: -30px; right: -80px; width: 120px; height: 120px; background: linear-gradient(135deg, rgba(234, 88, 12, 0.2), rgba(245, 158, 11, 0.2)); border-radius: 50%; filter: blur(40px); animation: floatSmooth 6s ease-in-out infinite reverse;"></div>
        
        <!-- 500 Number -->
        <div class="pulse-500 mb-4">
            <span class="display-1 fw-bold" style="font-size: 8rem; background: linear-gradient(135deg, #dc2626, #ea580c, #f59e0b); -webkit-background-clip: text; -webkit-text-fill-color: transparent;">500</span>
        </div>
        
        <!-- Icon -->
        <div class="shake-icon mb-4">
            <div class="rounded-circle glass-strong d-inline-flex align-items-center justify-content-center mx-auto shadow" style="width: 100px; height: 100px;">
                <i class="fas fa-exclamation-triangle fa-3x text-warning"></i>
            </div>
        </div>
        
        <h2 class="fw-bold mb-3 animate-fadeInUp">Lỗi hệ thống</h2>
        <p class="text-muted mb-5 animate-fadeInUp stagger-2" style="max-width: 400px; margin: 0 auto;">
            Đã xảy ra lỗi không mong muốn. Chúng tôi đã ghi nhận và sẽ khắc phục sớm nhất có thể.
        </p>
        
        <!-- Actions -->
        <div class="d-flex justify-content-center gap-3 flex-wrap animate-fadeInUp stagger-3">
            <a href="${pageContext.request.contextPath}/home" class="btn btn-gradient btn-lg rounded-pill px-5 py-3 hover-glow">
                <i class="fas fa-home me-2"></i>Về trang chủ
            </a>
            <a href="javascript:location.reload();" class="btn glass btn-lg rounded-pill px-5 py-3 hover-lift">
                <i class="fas fa-redo me-2"></i>Thử lại
            </a>
        </div>
        
        <!-- Help link -->
        <div class="mt-5 animate-fadeInUp stagger-4">
            <a href="${pageContext.request.contextPath}/faq" class="text-muted text-decoration-none d-inline-flex align-items-center gap-2 hover-lift">
                <i class="fas fa-question-circle"></i> Cần hỗ trợ? Xem FAQ
            </a>
        </div>
    </div>
</div>

<jsp:include page="footer.jsp" />
