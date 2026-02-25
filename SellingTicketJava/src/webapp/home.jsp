<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<jsp:include page="header.jsp" />

<!-- Hero Section - Enhanced with Animations -->
<section class="hero-section position-relative overflow-hidden">
    <!-- Animated Background Blobs -->
    <div class="hero-blob blob-1"></div>
    <div class="hero-blob blob-2"></div>
    
    <!-- Floating Decorations -->
    <div class="floating-element" style="top: 15%; left: 10%;">
        <i class="fas fa-ticket-alt text-primary" style="font-size: 2rem;"></i>
    </div>
    <div class="floating-element" style="top: 25%; right: 15%;">
        <i class="fas fa-music text-secondary" style="font-size: 1.5rem;"></i>
    </div>
    <div class="floating-element" style="bottom: 30%; left: 15%;">
        <i class="fas fa-star text-warning" style="font-size: 1.25rem;"></i>
    </div>

    <div class="container position-relative" style="z-index: 10;">
        <div class="row justify-content-center text-center">
            <div class="col-lg-8">
                <!-- Animated Badge -->
                <div class="d-inline-flex align-items-center gap-2 glass px-4 py-2 rounded-pill mb-4 animate-fadeInDown">
                    <i class="fas fa-fire text-danger animate-pulse"></i>
                    <span class="fw-medium small">Nền tảng vé sự kiện số 1 Việt Nam</span>
                    <span class="badge badge-hot">HOT</span>
                </div>

                <!-- Animated Heading -->
                <h1 class="display-3 fw-bold mb-4 animate-fadeInUp">
                    Khám phá & Đặt vé <br>
                    <span class="gradient-text-animate">Sự kiện đỉnh cao</span>
                </h1>

                <!-- Subheading -->
                <p class="lead text-muted mb-5 animate-fadeInUp stagger-2">
                    Trải nghiệm những khoảnh khắc đáng nhớ với hàng ngàn sự kiện 
                    âm nhạc, thể thao, workshop và nhiều hơn nữa.
                </p>

                <!-- Enhanced Search Bar -->
                <div class="glass-strong p-3 rounded-4 mb-5 mx-auto animate-fadeInUp stagger-3" style="max-width: 700px;">
                    <form action="search" method="get" class="d-flex flex-column flex-sm-row gap-2">
                        <div class="flex-grow-1 d-flex align-items-center bg-white rounded-3 px-3 py-2 shadow-sm">
                            <i class="fas fa-search text-muted me-2"></i>
                            <input type="text" name="q" class="form-control border-0 shadow-none" 
                                   placeholder="Tìm sự kiện, nghệ sĩ, địa điểm...">
                        </div>
                        <button type="submit" class="btn btn-gradient rounded-3 px-4 py-2 hover-glow">
                            <i class="fas fa-search me-2"></i>Tìm kiếm
                        </button>
                    </form>
                </div>

                <!-- Animated Stats (from DB) -->
                <div class="d-flex justify-content-center gap-4 gap-md-5 flex-wrap">
                    <div class="stat-card animate-on-scroll stagger-1">
                        <div class="stat-number" data-counter="${totalEvents}">0</div>
                        <div class="stat-label">Sự kiện</div>
                    </div>
                    <div class="stat-card animate-on-scroll stagger-2">
                        <div class="stat-number" data-counter="${totalUsers}">0</div>
                        <div class="stat-label">Người dùng</div>
                    </div>
                    <div class="stat-card animate-on-scroll stagger-3">
                        <div class="stat-number" data-counter="${totalTicketsSold}">0</div>
                        <div class="stat-label">Vé đã bán</div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</section>

<!-- Categories Section - Dynamic from DB -->
<section class="py-5">
    <div class="container">
        <div class="d-flex justify-content-between align-items-center mb-4 animate-on-scroll">
            <div>
                <h2 class="fw-bold mb-1">
                    <i class="fas fa-compass text-primary me-2"></i>Khám phá theo danh mục
                </h2>
                <p class="text-muted mb-0">Tìm kiếm sự kiện phù hợp với sở thích của bạn</p>
            </div>
            <a href="categories" class="text-decoration-none fw-bold text-primary hover-scale d-inline-flex align-items-center gap-2">
                Xem tất cả <i class="fas fa-arrow-right"></i>
            </a>
        </div>

        <div class="row g-3" data-stagger-children="0.1">
            <c:forEach var="cat" items="${categories}">
                <div class="col-6 col-md-4 col-lg-3 animate-on-scroll">
                    <a href="events?category=${cat.slug}" class="category-card-enhanced shadow-sm">
                        <div class="category-icon-enhanced category-icon-${cat.slug}">
                            <i class="fas ${not empty cat.icon ? cat.icon : 'fa-calendar'}"></i>
                        </div>
                        <span class="category-name">${cat.name}</span>
                        <small class="text-muted mt-1">${cat.eventCount} sự kiện</small>
                    </a>
                </div>
            </c:forEach>
        </div>
    </div>
</section>

<!-- Featured Event Banner - Dynamic from DB -->
<c:if test="${not empty featuredEvents}">
    <c:set var="bannerEvent" value="${featuredEvents[0]}" />
    <section class="py-4">
        <div class="container">
            <div class="featured-event-banner animate-on-scroll shadow-lg hover-lift">
                <img src="${not empty bannerEvent.bannerImage ? bannerEvent.bannerImage : 'https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=1200'}" alt="${bannerEvent.title}">
                <div class="featured-event-overlay">
                    <span class="badge badge-hot mb-2">
                        <i class="fas fa-fire me-1"></i>SỰ KIỆN HOT
                    </span>
                    <h2>${bannerEvent.title}</h2>
                    <div class="d-flex flex-wrap gap-3 text-white-50 mb-3">
                        <span><i class="far fa-calendar me-2"></i><fmt:formatDate value="${bannerEvent.startDate}" pattern="dd/MM/yyyy"/></span>
                        <span><i class="fas fa-map-marker-alt me-2"></i>${bannerEvent.location}</span>
                    </div>
                    <!-- Countdown -->
                    <div class="d-flex gap-2 mb-3" data-countdown="<fmt:formatDate value='${bannerEvent.startDate}' pattern="yyyy-MM-dd'T'HH:mm:ss"/>">
                        <div class="countdown-box">
                            <span class="countdown-number countdown-days">00</span>
                            <span class="countdown-label">Ngày</span>
                        </div>
                        <div class="countdown-box">
                            <span class="countdown-number countdown-hours">00</span>
                            <span class="countdown-label">Giờ</span>
                        </div>
                        <div class="countdown-box">
                            <span class="countdown-number countdown-minutes">00</span>
                            <span class="countdown-label">Phút</span>
                        </div>
                        <div class="countdown-box">
                            <span class="countdown-number countdown-seconds">00</span>
                            <span class="countdown-label">Giây</span>
                        </div>
                    </div>
                    <a href="event-detail?id=${bannerEvent.eventId}" class="btn btn-gradient rounded-pill px-4 hover-glow">
                        <i class="fas fa-ticket-alt me-2"></i>Mua vé ngay
                    </a>
                </div>
            </div>
        </div>
    </section>
</c:if>

<!-- Featured Events Grid - Dynamic from DB -->
<c:if test="${not empty featuredEvents}">
<section class="py-5">
    <div class="container">
        <div class="d-flex justify-content-between align-items-center mb-4 animate-on-scroll">
            <div>
                <h2 class="fw-bold mb-1">
                    <i class="fas fa-fire text-danger me-2"></i>Sự kiện nổi bật
                </h2>
                <p class="text-muted mb-0">Đừng bỏ lỡ những sự kiện hot nhất tuần này</p>
            </div>
            <a href="events?type=featured" class="text-decoration-none fw-bold text-primary hover-scale d-inline-flex align-items-center gap-2">
                Xem tất cả <i class="fas fa-arrow-right"></i>
            </a>
        </div>

        <div class="row g-4" data-stagger-children="0.1">
            <c:forEach var="event" items="${featuredEvents}" end="3">
                <div class="col-md-6 col-lg-3 animate-on-scroll">
                    <div class="event-card-enhanced shadow-sm h-100">
                        <div class="event-img-wrapper position-relative">
                            <img src="${not empty event.bannerImage ? event.bannerImage : 'https://images.unsplash.com/photo-1459749411175-04bf5292ceea?w=400'}" alt="${event.title}" class="event-img" loading="lazy">
                            <c:if test="${event.featured}">
                                <span class="badge badge-hot position-absolute top-0 start-0 m-2">HOT</span>
                            </c:if>
                            <div class="event-price">
                                <c:choose>
                                    <c:when test="${event.minPrice == 0}">Miễn phí</c:when>
                                    <c:otherwise><i class="fas fa-ticket-alt me-1"></i><fmt:formatNumber value="${event.minPrice}" pattern="#,###"/> đ</c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                        <div class="p-3">
                            <div class="d-flex align-items-center gap-2 mb-2">
                                <span class="badge rounded-pill" style="background: rgba(147, 51, 234, 0.15); color: var(--primary);">
                                    ${event.categoryName}
                                </span>
                            </div>
                            <h5 class="fw-bold mb-2 text-truncate-2">
                                <a href="event-detail?id=${event.eventId}" class="text-dark text-decoration-none stretched-link">
                                    ${event.title}
                                </a>
                            </h5>
                            <div class="text-muted small">
                                <div class="mb-1"><i class="far fa-calendar text-primary me-2"></i><fmt:formatDate value="${event.startDate}" pattern="dd/MM/yyyy"/></div>
                                <div><i class="fas fa-map-marker-alt text-primary me-2"></i>${event.location}</div>
                            </div>
                        </div>
                    </div>
                </div>
            </c:forEach>
        </div>
    </div>
</section>
</c:if>

<!-- Upcoming Events - Dynamic from DB -->
<c:if test="${not empty upcomingEvents}">
<section class="py-5 glass-gradient">
    <div class="container">
        <div class="text-center mb-5 animate-on-scroll">
            <h2 class="fw-bold mb-2">
                <i class="fas fa-calendar-check text-primary me-2"></i>Sắp diễn ra
            </h2>
            <p class="text-muted">Những sự kiện đang được mong chờ nhất</p>
        </div>

        <div class="row g-4">
            <c:forEach var="event" items="${upcomingEvents}" end="2">
                <div class="col-lg-4 animate-on-scroll">
                    <a href="event-detail?id=${event.eventId}" class="text-decoration-none">
                        <div class="glass-strong rounded-4 p-4 h-100 hover-lift">
                            <div class="d-flex gap-3">
                                <div class="text-center">
                                    <div class="rounded-3" style="background: linear-gradient(135deg, var(--primary), var(--secondary)); min-width: 70px; padding: 1rem;">
                                        <div class="display-6 fw-bold lh-1 text-white"><fmt:formatDate value="${event.startDate}" pattern="dd"/></div>
                                        <div class="small text-uppercase text-white">Th<fmt:formatDate value="${event.startDate}" pattern="MM"/></div>
                                    </div>
                                </div>
                                <div class="flex-grow-1">
                                    <h5 class="fw-bold mb-2 text-dark">${event.title}</h5>
                                    <div class="text-muted small mb-2">
                                        <i class="fas fa-clock me-1"></i><fmt:formatDate value="${event.startDate}" pattern="HH:mm"/>
                                    </div>
                                    <div class="text-muted small">
                                        <i class="fas fa-map-marker-alt me-1"></i>${event.location}
                                    </div>
                                </div>
                            </div>
                        </div>
                    </a>
                </div>
            </c:forEach>
        </div>
    </div>
</section>
</c:if>

<!-- Testimonials -->
<section class="py-5">
    <div class="container">
        <div class="text-center mb-5 animate-on-scroll">
            <h2 class="fw-bold mb-2">
                <i class="fas fa-quote-left text-primary me-2"></i>Khách hàng nói gì
            </h2>
            <p class="text-muted">Hơn 500,000+ người dùng tin tưởng</p>
        </div>

        <div class="row g-4">
            <div class="col-md-4 animate-on-scroll">
                <div class="glass-strong rounded-4 p-4 h-100">
                    <div class="d-flex gap-1 mb-3">
                        <i class="fas fa-star text-warning"></i>
                        <i class="fas fa-star text-warning"></i>
                        <i class="fas fa-star text-warning"></i>
                        <i class="fas fa-star text-warning"></i>
                        <i class="fas fa-star text-warning"></i>
                    </div>
                    <p class="text-muted mb-3">"Đặt vé nhanh chóng, thanh toán an toàn. Mình đã mua được vé concert yêu thích chỉ trong 2 phút!"</p>
                    <div class="d-flex align-items-center gap-3">
                        <div class="avatar-placeholder rounded-circle" style="width: 48px; height: 48px; font-size: 1.25rem;">
                            M
                        </div>
                        <div>
                            <h6 class="fw-bold mb-0">Minh Tuấn</h6>
                            <small class="text-muted">Khách hàng VIP</small>
                        </div>
                    </div>
                </div>
            </div>

            <div class="col-md-4 animate-on-scroll">
                <div class="glass-strong rounded-4 p-4 h-100">
                    <div class="d-flex gap-1 mb-3">
                        <i class="fas fa-star text-warning"></i>
                        <i class="fas fa-star text-warning"></i>
                        <i class="fas fa-star text-warning"></i>
                        <i class="fas fa-star text-warning"></i>
                        <i class="fas fa-star text-warning"></i>
                    </div>
                    <p class="text-muted mb-3">"Giao diện đẹp, dễ sử dụng. Hỗ trợ khách hàng cực kỳ nhiệt tình. 10 điểm không có nhưng!"</p>
                    <div class="d-flex align-items-center gap-3">
                        <div class="avatar-placeholder rounded-circle" style="width: 48px; height: 48px; font-size: 1.25rem;">
                            L
                        </div>
                        <div>
                            <h6 class="fw-bold mb-0">Lan Anh</h6>
                            <small class="text-muted">Fan âm nhạc</small>
                        </div>
                    </div>
                </div>
            </div>

            <div class="col-md-4 animate-on-scroll">
                <div class="glass-strong rounded-4 p-4 h-100">
                    <div class="d-flex gap-1 mb-3">
                        <i class="fas fa-star text-warning"></i>
                        <i class="fas fa-star text-warning"></i>
                        <i class="fas fa-star text-warning"></i>
                        <i class="fas fa-star text-warning"></i>
                        <i class="fas fa-star-half-alt text-warning"></i>
                    </div>
                    <p class="text-muted mb-3">"Là ban tổ chức sự kiện, Ticketbox giúp mình quản lý vé hiệu quả và tiếp cận được nhiều khách hàng hơn."</p>
                    <div class="d-flex align-items-center gap-3">
                        <div class="avatar-placeholder rounded-circle" style="width: 48px; height: 48px; font-size: 1.25rem;">
                            H
                        </div>
                        <div>
                            <h6 class="fw-bold mb-0">Hoàng Nam</h6>
                            <small class="text-muted">Ban tổ chức</small>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</section>

<!-- CTA Section - Enhanced -->
<section class="py-5 my-5">
    <div class="container">
        <div class="glass-gradient p-5 rounded-4 text-center position-relative overflow-hidden animate-on-scroll">
            <!-- Floating decorations -->
            <div class="floating-element" style="top: 10%; left: 5%;">
                <i class="fas fa-ticket-alt text-primary opacity-25" style="font-size: 3rem;"></i>
            </div>
            <div class="floating-element" style="bottom: 10%; right: 5%;">
                <i class="fas fa-star text-warning opacity-25" style="font-size: 2rem;"></i>
            </div>
            
            <div class="position-relative" style="z-index: 2;">
                <span class="badge badge-new mb-3">DÀNH CHO NHÀ TỔ CHỨC</span>
                <h2 class="fw-bold mb-3">Bạn là Nhà tổ chức sự kiện?</h2>
                <p class="text-muted mb-4 mx-auto" style="max-width: 600px;">
                    Đăng tải sự kiện, quản lý vé và tiếp cận hàng ngàn khán giả tiềm năng ngay hôm nay với Ticketbox.
                </p>
                <div class="d-flex justify-content-center gap-3 flex-wrap">
                    <a href="register-organizer" class="btn btn-gradient rounded-pill px-4 py-2 hover-glow">
                        <i class="fas fa-rocket me-2"></i>Đăng ký ngay
                    </a>
                    <a href="#" class="btn btn-outline-dark rounded-pill px-4 py-2">
                        <i class="fas fa-tag me-2"></i>Xem bảng giá
                    </a>
                </div>
            </div>
        </div>
    </div>
</section>

<jsp:include page="footer.jsp" />
