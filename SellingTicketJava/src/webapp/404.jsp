<%@page contentType="text/html" pageEncoding="UTF-8" isErrorPage="true"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>

<jsp:include page="header.jsp" />

<style>
@keyframes float404 {
    0%, 100% { transform: translateY(0) rotate(-2deg); }
    50% { transform: translateY(-20px) rotate(2deg); }
}
@keyframes scaleIn {
    0% { transform: scale(0); opacity: 0; }
    100% { transform: scale(1); opacity: 1; }
}
.floating-404 {
    animation: float404 4s ease-in-out infinite;
}
.scale-in {
    animation: scaleIn 0.5s ease-out forwards;
}
</style>

<div class="container py-5 d-flex align-items-center justify-content-center" style="min-height: 70vh;">
    <div class="text-center position-relative">
        <!-- Floating blobs -->
        <div class="position-absolute" style="top: -50px; left: -100px; width: 150px; height: 150px; background: linear-gradient(135deg, rgba(147, 51, 234, 0.2), rgba(219, 39, 119, 0.2)); border-radius: 50%; filter: blur(40px); animation: floatSmooth 8s ease-in-out infinite;"></div>
        <div class="position-absolute" style="bottom: -30px; right: -80px; width: 120px; height: 120px; background: linear-gradient(135deg, rgba(6, 182, 212, 0.2), rgba(59, 130, 246, 0.2)); border-radius: 50%; filter: blur(40px); animation: floatSmooth 6s ease-in-out infinite reverse;"></div>
        
        <!-- 404 Number -->
        <div class="floating-404 mb-4">
            <span class="display-1 fw-bold gradient-text-animate" style="font-size: 8rem;">404</span>
        </div>
        
        <!-- Icon -->
        <div class="scale-in mb-4" style="animation-delay: 0.2s;">
            <div class="rounded-circle glass-strong d-inline-flex align-items-center justify-content-center mx-auto shadow" style="width: 100px; height: 100px;">
                <i class="fas fa-map-signs fa-3x text-primary"></i>
            </div>
        </div>
        
        <h2 class="fw-bold mb-3 animate-fadeInUp">Không tìm thấy trang</h2>
        <p class="text-muted mb-5 animate-fadeInUp stagger-2" style="max-width: 400px; margin: 0 auto;">
            Trang bạn đang tìm kiếm không tồn tại hoặc đã bị di chuyển đến vị trí khác.
        </p>
        
        <!-- Actions -->
        <div class="d-flex justify-content-center gap-3 flex-wrap animate-fadeInUp stagger-3">
            <a href="${pageContext.request.contextPath}/home" class="btn btn-gradient btn-lg rounded-pill px-5 py-3 hover-glow">
                <i class="fas fa-home me-2"></i>Về trang chủ
            </a>
            <a href="${pageContext.request.contextPath}/events" class="btn glass btn-lg rounded-pill px-5 py-3 hover-lift">
                <i class="fas fa-search me-2"></i>Khám phá sự kiện
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
