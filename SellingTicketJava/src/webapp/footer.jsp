<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>

    </main>
    
    <!-- Footer -->
    <footer class="mt-auto glass-strong border-top">
        <div class="container py-5">
            <div class="row g-4">
                <!-- Brand -->
                <div class="col-lg-4">
                    <div class="d-flex align-items-center gap-2 mb-3">
                        <div class="rounded-3 d-flex align-items-center justify-content-center text-white btn-gradient" style="width: 40px; height: 40px;">
                            <i class="fas fa-ticket-alt"></i>
                        </div>
                        <span class="fw-bold fs-5 text-gradient">Ticketbox</span>
                    </div>
                    <p class="text-muted small mb-4" style="max-width: 280px;">
                        Nền tảng đặt vé sự kiện hàng đầu Việt Nam. Khám phá và đặt vé cho các sự kiện âm nhạc, thể thao, hội thảo và nhiều hơn nữa.
                    </p>
                    <div class="d-flex gap-2">
                        <a href="#" class="btn btn-sm glass rounded-3 hover-scale" style="width: 40px; height: 40px; display: flex; align-items: center; justify-content: center;">
                            <i class="fab fa-facebook-f text-primary"></i>
                        </a>
                        <a href="#" class="btn btn-sm glass rounded-3 hover-scale" style="width: 40px; height: 40px; display: flex; align-items: center; justify-content: center;">
                            <i class="fab fa-instagram text-danger"></i>
                        </a>
                        <a href="#" class="btn btn-sm glass rounded-3 hover-scale" style="width: 40px; height: 40px; display: flex; align-items: center; justify-content: center;">
                            <i class="fab fa-youtube text-danger"></i>
                        </a>
                        <a href="#" class="btn btn-sm glass rounded-3 hover-scale" style="width: 40px; height: 40px; display: flex; align-items: center; justify-content: center;">
                            <i class="fab fa-tiktok"></i>
                        </a>
                    </div>
                </div>
                
                <!-- Discovery -->
                <div class="col-6 col-lg-2">
                    <h6 class="fw-bold mb-3">Khám phá</h6>
                    <ul class="list-unstyled small">
                        <li class="mb-2"><a href="${pageContext.request.contextPath}/events" class="text-muted text-decoration-none hover-primary">Sự kiện</a></li>
                        <li class="mb-2"><a href="${pageContext.request.contextPath}/events?category=music" class="text-muted text-decoration-none hover-primary">Âm nhạc</a></li>
                        <li class="mb-2"><a href="${pageContext.request.contextPath}/events?category=sports" class="text-muted text-decoration-none hover-primary">Thể thao</a></li>
                        <li class="mb-2"><a href="${pageContext.request.contextPath}/events?category=workshop" class="text-muted text-decoration-none hover-primary">Workshop</a></li>
                    </ul>
                </div>
                
                <!-- Organizer -->
                <div class="col-6 col-lg-2">
                    <h6 class="fw-bold mb-3">Ban tổ chức</h6>
                    <ul class="list-unstyled small">
                        <li class="mb-2"><a href="${pageContext.request.contextPath}/organizer/create-event" class="text-muted text-decoration-none hover-primary" onclick="return requireLogin(this)">Tạo sự kiện</a></li>
                        <li class="mb-2"><a href="${pageContext.request.contextPath}/organizer/events" class="text-muted text-decoration-none hover-primary" onclick="return requireLogin(this)">Quản lý sự kiện</a></li>
                        <li class="mb-2"><a href="#" class="text-muted text-decoration-none hover-primary">Tính năng</a></li>
                    </ul>
                </div>
                
                <!-- Support -->
                <div class="col-6 col-lg-2">
                    <h6 class="fw-bold mb-3">Hỗ trợ</h6>
                    <ul class="list-unstyled small">
                        <li class="mb-2"><a href="${pageContext.request.contextPath}/faq" class="text-muted text-decoration-none hover-primary">Trung tâm trợ giúp</a></li>
                        <li class="mb-2"><a href="#" class="text-muted text-decoration-none hover-primary">Điều khoản</a></li>
                        <li class="mb-2"><a href="#" class="text-muted text-decoration-none hover-primary">Chính sách</a></li>
                    </ul>
                </div>
                
                <!-- Contact -->
                <div class="col-6 col-lg-2">
                    <h6 class="fw-bold mb-3">Liên hệ</h6>
                    <ul class="list-unstyled small">
                        <li class="mb-3">
                            <a href="mailto:support@ticketbox.vn" class="text-muted text-decoration-none d-flex align-items-center gap-2 hover-primary">
                                <i class="fas fa-envelope text-primary"></i>support@ticketbox.vn
                            </a>
                        </li>
                        <li class="mb-3">
                            <a href="tel:19006408" class="text-muted text-decoration-none d-flex align-items-center gap-2 hover-primary">
                                <i class="fas fa-phone text-primary"></i>1900 6408
                            </a>
                        </li>
                    </ul>
                </div>
            </div>
            
            <hr class="my-4 opacity-25">
            
            <div class="d-flex flex-column flex-md-row justify-content-between align-items-center gap-3">
                <p class="small text-muted mb-0">&copy; 2026 Ticketbox. All rights reserved.</p>
                <div class="d-flex gap-3">
                    <a href="#" class="small text-muted text-decoration-none hover-primary">Privacy</a>
                    <a href="#" class="small text-muted text-decoration-none hover-primary">Terms</a>
                    <a href="#" class="small text-muted text-decoration-none hover-primary">Cookies</a>
                </div>
            </div>
        </div>
    </footer>

    <!-- Bootstrap 5 JS Bundle -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    
    <!-- Toast Notifications -->
    <script src="${pageContext.request.contextPath}/assets/js/toast.js"></script>
    
    <!-- Animations JS -->
    <script src="${pageContext.request.contextPath}/assets/js/animations.js"></script>
    
    <script>
    // Check login status (set by JSP)
    const isLoggedIn = "${sessionScope.account != null}" === "true";
    
    // Require login function for protected links
    function requireLogin(element) {
        if (!isLoggedIn) {
            event.preventDefault();
            showWarning('Vui lòng đăng nhập để tiếp tục');
            setTimeout(() => {
                window.location.href = '${pageContext.request.contextPath}/login?redirect=' + encodeURIComponent(element.href);
            }, 1500);
            return false;
        }
        return true;
    }
    </script>
    
    <style>
    .hover-primary:hover {
        color: var(--primary) !important;
        transition: color 0.2s ease;
    }
    </style>
</body>
</html>
