<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>

<jsp:include page="header.jsp" />

<!-- Hero Section -->
<section class="py-5 position-relative overflow-hidden" style="background: linear-gradient(135deg, var(--primary), var(--secondary));">
    <div class="hero-blob blob-1" style="width: 300px; height: 300px; top: -100px; right: -50px;"></div>
    <div class="hero-blob blob-2" style="width: 200px; height: 200px; bottom: -50px; left: 20%;"></div>
    
    <div class="container position-relative" style="z-index: 10;">
        <div class="row align-items-center">
            <div class="col-lg-8">
                <h1 class="display-4 fw-bold text-white mb-3 animate-fadeInUp">Khám phá danh mục</h1>
                <p class="lead text-white-50 mb-0 animate-fadeInUp stagger-2">
                    Tìm sự kiện theo sở thích của bạn - Từ âm nhạc đến thể thao, nghệ thuật đến công nghệ
                </p>
            </div>
            <div class="col-lg-4 text-lg-end mt-3 mt-lg-0 animate-fadeInRight">
                <div class="d-inline-flex align-items-center gap-3 glass px-4 py-3 rounded-4">
                    <i class="fas fa-th-large fs-2 text-white"></i>
                    <div class="text-white">
                        <div class="fs-4 fw-bold" data-counter="6">0</div>
                        <small class="opacity-75">Danh mục</small>
                    </div>
                </div>
            </div>
        </div>
    </div>
</section>

<div class="container py-5">
    <div class="row g-4" data-stagger-children="0.1">
        <!-- Music -->
        <div class="col-md-6 col-lg-4 animate-on-scroll">
            <a href="${pageContext.request.contextPath}/events?category=music" class="text-decoration-none">
                <div class="card glass-strong border-0 rounded-4 overflow-hidden h-100 hover-lift">
                    <div class="position-relative">
                        <img src="https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=600" class="card-img-top" style="height: 220px; object-fit: cover;">
                        <div class="position-absolute top-0 start-0 end-0 bottom-0" style="background: linear-gradient(transparent 30%, rgba(236, 72, 153, 0.9));"></div>
                        <div class="position-absolute bottom-0 start-0 end-0 p-4">
                            <div class="d-flex align-items-center gap-3">
                                <div class="rounded-3 d-flex align-items-center justify-content-center" style="width: 52px; height: 52px; background: rgba(255,255,255,0.2); backdrop-filter: blur(10px);">
                                    <i class="fas fa-music text-white fs-4"></i>
                                </div>
                                <div>
                                    <h4 class="text-white fw-bold mb-0">Âm nhạc</h4>
                                    <small class="text-white-50">Concerts, EDM, Acoustic</small>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="card-body">
                        <p class="text-muted mb-3">Concerts, liveshow, EDM festivals và các buổi biểu diễn âm nhạc đỉnh cao.</p>
                        <div class="d-flex align-items-center justify-content-between">
                            <span class="badge rounded-pill px-3 py-2" style="background: linear-gradient(135deg, #ec4899, #db2777);">
                                <i class="fas fa-calendar-alt me-1"></i><span data-counter="150">0</span>+ sự kiện
                            </span>
                            <span class="text-primary fw-medium">Khám phá <i class="fas fa-arrow-right ms-1"></i></span>
                        </div>
                    </div>
                </div>
            </a>
        </div>

        <!-- Sports -->
        <div class="col-md-6 col-lg-4 animate-on-scroll">
            <a href="${pageContext.request.contextPath}/events?category=sports" class="text-decoration-none">
                <div class="card glass-strong border-0 rounded-4 overflow-hidden h-100 hover-lift">
                    <div class="position-relative">
                        <img src="https://images.unsplash.com/photo-1571902943202-507ec2618e8f?w=600" class="card-img-top" style="height: 220px; object-fit: cover;">
                        <div class="position-absolute top-0 start-0 end-0 bottom-0" style="background: linear-gradient(transparent 30%, rgba(16, 185, 129, 0.9));"></div>
                        <div class="position-absolute bottom-0 start-0 end-0 p-4">
                            <div class="d-flex align-items-center gap-3">
                                <div class="rounded-3 d-flex align-items-center justify-content-center" style="width: 52px; height: 52px; background: rgba(255,255,255,0.2); backdrop-filter: blur(10px);">
                                    <i class="fas fa-futbol text-white fs-4"></i>
                                </div>
                                <div>
                                    <h4 class="text-white fw-bold mb-0">Thể thao</h4>
                                    <small class="text-white-50">Football, Marathon, Tennis</small>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="card-body">
                        <p class="text-muted mb-3">Bóng đá, marathon, tennis và các giải đấu thể thao hấp dẫn nhất.</p>
                        <div class="d-flex align-items-center justify-content-between">
                            <span class="badge rounded-pill px-3 py-2" style="background: linear-gradient(135deg, #10b981, #059669);">
                                <i class="fas fa-calendar-alt me-1"></i><span data-counter="80">0</span>+ sự kiện
                            </span>
                            <span class="text-primary fw-medium">Khám phá <i class="fas fa-arrow-right ms-1"></i></span>
                        </div>
                    </div>
                </div>
            </a>
        </div>

        <!-- Workshop -->
        <div class="col-md-6 col-lg-4 animate-on-scroll">
            <a href="${pageContext.request.contextPath}/events?category=workshop" class="text-decoration-none">
                <div class="card glass-strong border-0 rounded-4 overflow-hidden h-100 hover-lift">
                    <div class="position-relative">
                        <img src="https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=600" class="card-img-top" style="height: 220px; object-fit: cover;">
                        <div class="position-absolute top-0 start-0 end-0 bottom-0" style="background: linear-gradient(transparent 30%, rgba(59, 130, 246, 0.9));"></div>
                        <div class="position-absolute bottom-0 start-0 end-0 p-4">
                            <div class="d-flex align-items-center gap-3">
                                <div class="rounded-3 d-flex align-items-center justify-content-center" style="width: 52px; height: 52px; background: rgba(255,255,255,0.2); backdrop-filter: blur(10px);">
                                    <i class="fas fa-laptop-code text-white fs-4"></i>
                                </div>
                                <div>
                                    <h4 class="text-white fw-bold mb-0">Workshop</h4>
                                    <small class="text-white-50">Training, Seminar, Course</small>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="card-body">
                        <p class="text-muted mb-3">Hội thảo, khóa học, training và các buổi chia sẻ kiến thức chuyên sâu.</p>
                        <div class="d-flex align-items-center justify-content-between">
                            <span class="badge rounded-pill px-3 py-2" style="background: linear-gradient(135deg, #3b82f6, #2563eb);">
                                <i class="fas fa-calendar-alt me-1"></i><span data-counter="200">0</span>+ sự kiện
                            </span>
                            <span class="text-primary fw-medium">Khám phá <i class="fas fa-arrow-right ms-1"></i></span>
                        </div>
                    </div>
                </div>
            </a>
        </div>

        <!-- Food -->
        <div class="col-md-6 col-lg-4 animate-on-scroll">
            <a href="${pageContext.request.contextPath}/events?category=food" class="text-decoration-none">
                <div class="card glass-strong border-0 rounded-4 overflow-hidden h-100 hover-lift">
                    <div class="position-relative">
                        <img src="https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=600" class="card-img-top" style="height: 220px; object-fit: cover;">
                        <div class="position-absolute top-0 start-0 end-0 bottom-0" style="background: linear-gradient(transparent 30%, rgba(245, 158, 11, 0.9));"></div>
                        <div class="position-absolute bottom-0 start-0 end-0 p-4">
                            <div class="d-flex align-items-center gap-3">
                                <div class="rounded-3 d-flex align-items-center justify-content-center" style="width: 52px; height: 52px; background: rgba(255,255,255,0.2); backdrop-filter: blur(10px);">
                                    <i class="fas fa-utensils text-white fs-4"></i>
                                </div>
                                <div>
                                    <h4 class="text-white fw-bold mb-0">Ẩm thực</h4>
                                    <small class="text-white-50">Festival, Food Tour, Cooking</small>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="card-body">
                        <p class="text-muted mb-3">Lễ hội ẩm thực, food tour và các sự kiện nấu ăn thú vị.</p>
                        <div class="d-flex align-items-center justify-content-between">
                            <span class="badge rounded-pill px-3 py-2" style="background: linear-gradient(135deg, #f59e0b, #d97706);">
                                <i class="fas fa-calendar-alt me-1"></i><span data-counter="60">0</span>+ sự kiện
                            </span>
                            <span class="text-primary fw-medium">Khám phá <i class="fas fa-arrow-right ms-1"></i></span>
                        </div>
                    </div>
                </div>
            </a>
        </div>

        <!-- Art -->
        <div class="col-md-6 col-lg-4 animate-on-scroll">
            <a href="${pageContext.request.contextPath}/events?category=art" class="text-decoration-none">
                <div class="card glass-strong border-0 rounded-4 overflow-hidden h-100 hover-lift">
                    <div class="position-relative">
                        <img src="https://images.unsplash.com/photo-1513364776144-60967b0f800f?w=600" class="card-img-top" style="height: 220px; object-fit: cover;">
                        <div class="position-absolute top-0 start-0 end-0 bottom-0" style="background: linear-gradient(transparent 30%, rgba(168, 85, 247, 0.9));"></div>
                        <div class="position-absolute bottom-0 start-0 end-0 p-4">
                            <div class="d-flex align-items-center gap-3">
                                <div class="rounded-3 d-flex align-items-center justify-content-center" style="width: 52px; height: 52px; background: rgba(255,255,255,0.2); backdrop-filter: blur(10px);">
                                    <i class="fas fa-palette text-white fs-4"></i>
                                </div>
                                <div>
                                    <h4 class="text-white fw-bold mb-0">Nghệ thuật</h4>
                                    <small class="text-white-50">Exhibition, Theater, Dance</small>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="card-body">
                        <p class="text-muted mb-3">Triển lãm, kịch, múa ballet và các sự kiện nghệ thuật đặc sắc.</p>
                        <div class="d-flex align-items-center justify-content-between">
                            <span class="badge rounded-pill px-3 py-2" style="background: linear-gradient(135deg, #a855f7, #9333ea);">
                                <i class="fas fa-calendar-alt me-1"></i><span data-counter="45">0</span>+ sự kiện
                            </span>
                            <span class="text-primary fw-medium">Khám phá <i class="fas fa-arrow-right ms-1"></i></span>
                        </div>
                    </div>
                </div>
            </a>
        </div>

        <!-- Business -->
        <div class="col-md-6 col-lg-4 animate-on-scroll">
            <a href="${pageContext.request.contextPath}/events?category=business" class="text-decoration-none">
                <div class="card glass-strong border-0 rounded-4 overflow-hidden h-100 hover-lift">
                    <div class="position-relative">
                        <img src="https://images.unsplash.com/photo-1515187029135-18ee286d815b?w=600" class="card-img-top" style="height: 220px; object-fit: cover;">
                        <div class="position-absolute top-0 start-0 end-0 bottom-0" style="background: linear-gradient(transparent 30%, rgba(99, 102, 241, 0.9));"></div>
                        <div class="position-absolute bottom-0 start-0 end-0 p-4">
                            <div class="d-flex align-items-center gap-3">
                                <div class="rounded-3 d-flex align-items-center justify-content-center" style="width: 52px; height: 52px; background: rgba(255,255,255,0.2); backdrop-filter: blur(10px);">
                                    <i class="fas fa-briefcase text-white fs-4"></i>
                                </div>
                                <div>
                                    <h4 class="text-white fw-bold mb-0">Kinh doanh</h4>
                                    <small class="text-white-50">Networking, Startup, Conference</small>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="card-body">
                        <p class="text-muted mb-3">Networking, startup pitch và các sự kiện doanh nghiệp chuyên nghiệp.</p>
                        <div class="d-flex align-items-center justify-content-between">
                            <span class="badge rounded-pill px-3 py-2" style="background: linear-gradient(135deg, #6366f1, #4f46e5);">
                                <i class="fas fa-calendar-alt me-1"></i><span data-counter="90">0</span>+ sự kiện
                            </span>
                            <span class="text-primary fw-medium">Khám phá <i class="fas fa-arrow-right ms-1"></i></span>
                        </div>
                    </div>
                </div>
            </a>
        </div>
    </div>
    
    <!-- CTA Section -->
    <div class="text-center mt-5 pt-4 animate-on-scroll">
        <div class="glass-strong p-5 rounded-4">
            <h3 class="fw-bold mb-3">Không tìm thấy danh mục phù hợp?</h3>
            <p class="text-muted mb-4">Khám phá tất cả sự kiện hoặc tìm kiếm theo từ khóa</p>
            <a href="${pageContext.request.contextPath}/events" class="btn btn-gradient rounded-pill px-5 py-3 hover-glow">
                <i class="fas fa-search me-2"></i>Xem tất cả sự kiện
            </a>
        </div>
    </div>
</div>

<jsp:include page="footer.jsp" />
