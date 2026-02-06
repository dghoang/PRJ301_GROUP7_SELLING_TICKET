<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>

<jsp:include page="header.jsp" />

<!-- Hero Section -->
<section class="py-5 position-relative overflow-hidden" style="background: linear-gradient(135deg, #1e1b4b 0%, #312e81 100%);">
    <div class="hero-blob blob-1" style="width: 400px; height: 400px; top: -150px; right: -100px; opacity: 0.3;"></div>
    <div class="hero-blob blob-2" style="width: 300px; height: 300px; bottom: -100px; left: -50px; opacity: 0.3;"></div>
    
    <div class="container position-relative" style="z-index: 10;">
        <div class="row align-items-center py-4">
            <div class="col-lg-6">
                <span class="badge glass rounded-pill px-3 py-2 mb-3 animate-fadeInDown">
                    <i class="fas fa-star text-warning me-2"></i>Nền tảng đặt vé #1 Việt Nam
                </span>
                <h1 class="display-4 fw-bold text-white mb-4 animate-fadeInUp">Về Ticketbox</h1>
                <p class="lead text-white-50 mb-0 animate-fadeInUp stagger-2">
                    Kết nối triệu người yêu sự kiện với những trải nghiệm đáng nhớ nhất
                </p>
            </div>
            <div class="col-lg-6 text-lg-end mt-4 mt-lg-0 animate-fadeInRight">
                <div class="d-flex justify-content-lg-end gap-4">
                    <div class="text-center text-white">
                        <div class="fs-2 fw-bold" data-counter="5">0</div>
                        <small class="opacity-75">Năm hoạt động</small>
                    </div>
                    <div class="text-center text-white">
                        <div class="fs-2 fw-bold" data-counter="50">0</div>
                        <small class="opacity-75">Đối tác</small>
                    </div>
                    <div class="text-center text-white">
                        <div class="fs-2 fw-bold" data-counter="63">0</div>
                        <small class="opacity-75">Tỉnh thành</small>
                    </div>
                </div>
            </div>
        </div>
    </div>
</section>

<div class="container py-5">
    <!-- Mission Section -->
    <div class="row align-items-center mb-5 g-5">
        <div class="col-lg-6 animate-on-scroll">
            <div class="position-relative">
                <img src="https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=800" class="rounded-4 shadow-lg w-100" alt="About" data-parallax="0.1">
                <!-- Floating badge -->
                <div class="position-absolute bottom-0 end-0 translate-middle-y me-n3 animate-pulse">
                    <div class="glass-strong rounded-4 p-3 shadow-lg">
                        <div class="d-flex align-items-center gap-3">
                            <div class="rounded-circle bg-success d-flex align-items-center justify-content-center" style="width: 48px; height: 48px;">
                                <i class="fas fa-check text-white"></i>
                            </div>
                            <div>
                                <div class="fw-bold" data-counter="10000">0</div>
                                <small class="text-muted">Sự kiện thành công</small>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <div class="col-lg-6 animate-on-scroll">
            <span class="badge rounded-pill px-3 py-2 mb-3" style="background: linear-gradient(135deg, var(--primary), var(--secondary));">
                <i class="fas fa-heart me-1"></i>Sứ mệnh
            </span>
            <h2 class="display-6 fw-bold mb-4">Mang sự kiện đến <span class="gradient-text-animate">gần hơn</span> với bạn</h2>
            <p class="text-muted mb-4 fs-5">
                Ticketbox ra đời với sứ mệnh kết nối mọi người thông qua các sự kiện. 
                Chúng tôi tin rằng mỗi khoảnh khắc đặc biệt trong cuộc sống đều xứng đáng được trải nghiệm.
            </p>
            <p class="text-muted mb-4">
                Từ những buổi hòa nhạc đến các workshop học tập, từ giải đấu thể thao đến lễ hội ẩm thực - 
                Ticketbox mang đến cho bạn cơ hội tiếp cận hàng nghìn sự kiện chất lượng chỉ với vài cú click.
            </p>
            <div class="d-flex gap-4 flex-wrap">
                <div class="text-center">
                    <h3 class="fw-bold gradient-text-animate mb-0" data-counter="500">0</h3>
                    <small class="text-muted">Sự kiện/tháng</small>
                </div>
                <div class="text-center">
                    <h3 class="fw-bold gradient-text-animate mb-0" data-counter="1000000">0</h3>
                    <small class="text-muted">Người dùng</small>
                </div>
                <div class="text-center">
                    <h3 class="fw-bold gradient-text-animate mb-0">4.9<i class="fas fa-star text-warning ms-1 fs-6"></i></h3>
                    <small class="text-muted">Đánh giá</small>
                </div>
            </div>
        </div>
    </div>

    <!-- Values Section -->
    <div class="text-center mb-5 animate-on-scroll">
        <span class="badge rounded-pill px-3 py-2 mb-3" style="background: linear-gradient(135deg, var(--primary), var(--secondary));">
            <i class="fas fa-gem me-1"></i>Giá trị cốt lõi
        </span>
        <h2 class="display-6 fw-bold">Điều khiến chúng tôi khác biệt</h2>
    </div>
    <div class="row g-4 mb-5" data-stagger-children="0.15">
        <div class="col-md-4 animate-on-scroll">
            <div class="card glass-strong border-0 rounded-4 h-100 text-center p-4 hover-lift card-3d">
                <div class="rounded-circle d-inline-flex align-items-center justify-content-center mx-auto mb-4" style="width: 80px; height: 80px; background: linear-gradient(135deg, rgba(147, 51, 234, 0.1), rgba(219, 39, 119, 0.1));">
                    <i class="fas fa-shield-alt text-primary fa-2x"></i>
                </div>
                <h5 class="fw-bold mb-3">An toàn & Tin cậy</h5>
                <p class="text-muted">Bảo vệ thông tin khách hàng với công nghệ mã hóa tiên tiến. Đảm bảo giao dịch an toàn 100%.</p>
            </div>
        </div>
        <div class="col-md-4 animate-on-scroll">
            <div class="card glass-strong border-0 rounded-4 h-100 text-center p-4 hover-lift card-3d">
                <div class="rounded-circle d-inline-flex align-items-center justify-content-center mx-auto mb-4" style="width: 80px; height: 80px; background: linear-gradient(135deg, rgba(16, 185, 129, 0.1), rgba(6, 182, 212, 0.1));">
                    <i class="fas fa-bolt text-success fa-2x"></i>
                </div>
                <h5 class="fw-bold mb-3">Nhanh chóng</h5>
                <p class="text-muted">Đặt vé chỉ trong vài giây với giao diện thân thiện. Nhận vé điện tử ngay tức thì qua email.</p>
            </div>
        </div>
        <div class="col-md-4 animate-on-scroll">
            <div class="card glass-strong border-0 rounded-4 h-100 text-center p-4 hover-lift card-3d">
                <div class="rounded-circle d-inline-flex align-items-center justify-content-center mx-auto mb-4" style="width: 80px; height: 80px; background: linear-gradient(135deg, rgba(245, 158, 11, 0.1), rgba(239, 68, 68, 0.1));">
                    <i class="fas fa-heart text-warning fa-2x"></i>
                </div>
                <h5 class="fw-bold mb-3">Tận tâm</h5>
                <p class="text-muted">Đội ngũ hỗ trợ 24/7 sẵn sàng giải đáp mọi thắc mắc. Cam kết mang đến trải nghiệm tốt nhất.</p>
            </div>
        </div>
    </div>

    <!-- Team Section -->
    <div class="text-center mb-5 animate-on-scroll">
        <span class="badge rounded-pill px-3 py-2 mb-3" style="background: linear-gradient(135deg, var(--primary), var(--secondary));">
            <i class="fas fa-users me-1"></i>Đội ngũ
        </span>
        <h2 class="display-6 fw-bold">Những người đứng sau Ticketbox</h2>
    </div>
    <div class="row g-4 justify-content-center" data-stagger-children="0.1">
        <div class="col-6 col-md-3 animate-on-scroll">
            <div class="text-center hover-lift">
                <div class="position-relative d-inline-block mb-3">
                    <img src="https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200" class="rounded-circle shadow" style="width: 120px; height: 120px; object-fit: cover; border: 4px solid white;">
                    <div class="position-absolute bottom-0 end-0 rounded-circle bg-success d-flex align-items-center justify-content-center" style="width: 32px; height: 32px; border: 3px solid white;">
                        <i class="fas fa-check text-white" style="font-size: 12px;"></i>
                    </div>
                </div>
                <h6 class="fw-bold mb-1">Nguyễn Văn A</h6>
                <span class="badge glass rounded-pill px-3 py-1">CEO & Founder</span>
            </div>
        </div>
        <div class="col-6 col-md-3 animate-on-scroll">
            <div class="text-center hover-lift">
                <div class="position-relative d-inline-block mb-3">
                    <img src="https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200" class="rounded-circle shadow" style="width: 120px; height: 120px; object-fit: cover; border: 4px solid white;">
                    <div class="position-absolute bottom-0 end-0 rounded-circle bg-success d-flex align-items-center justify-content-center" style="width: 32px; height: 32px; border: 3px solid white;">
                        <i class="fas fa-check text-white" style="font-size: 12px;"></i>
                    </div>
                </div>
                <h6 class="fw-bold mb-1">Trần Thị B</h6>
                <span class="badge glass rounded-pill px-3 py-1">CTO</span>
            </div>
        </div>
        <div class="col-6 col-md-3 animate-on-scroll">
            <div class="text-center hover-lift">
                <div class="position-relative d-inline-block mb-3">
                    <img src="https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=200" class="rounded-circle shadow" style="width: 120px; height: 120px; object-fit: cover; border: 4px solid white;">
                    <div class="position-absolute bottom-0 end-0 rounded-circle bg-success d-flex align-items-center justify-content-center" style="width: 32px; height: 32px; border: 3px solid white;">
                        <i class="fas fa-check text-white" style="font-size: 12px;"></i>
                    </div>
                </div>
                <h6 class="fw-bold mb-1">Lê Văn C</h6>
                <span class="badge glass rounded-pill px-3 py-1">CMO</span>
            </div>
        </div>
    </div>
    
    <!-- CTA -->
    <div class="text-center mt-5 pt-4 animate-on-scroll">
        <div class="p-5 rounded-4" style="background: linear-gradient(135deg, var(--primary), var(--secondary));">
            <h3 class="fw-bold text-white mb-3">Sẵn sàng khám phá sự kiện?</h3>
            <p class="text-white-50 mb-4">Hàng nghìn sự kiện đang chờ đón bạn</p>
            <a href="${pageContext.request.contextPath}/events" class="btn btn-light rounded-pill px-5 py-3 fw-bold hover-lift">
                <i class="fas fa-rocket me-2"></i>Khám phá ngay
            </a>
        </div>
    </div>
</div>

<jsp:include page="footer.jsp" />
