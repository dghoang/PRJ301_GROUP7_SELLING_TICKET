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
                <h1 class="display-4 fw-bold text-white mb-3 animate-fadeInUp" data-i18n="categories.hero_title">Khám phá danh mục</h1>
                <p class="lead text-white-50 mb-0 animate-fadeInUp stagger-2" data-i18n="categories.hero_subtitle">
                    Tìm sự kiện theo sở thích của bạn - Từ âm nhạc đến thể thao, nghệ thuật đến công nghệ
                </p>
            </div>
            <div class="col-lg-4 text-lg-end mt-3 mt-lg-0 animate-fadeInRight">
                <div class="d-inline-flex align-items-center gap-3 glass px-4 py-3 rounded-4">
                    <i class="fas fa-th-large fs-2 text-white"></i>
                    <div class="text-white">
                        <div class="fs-4 fw-bold" data-counter="${categories.size()}">${categories.size()}</div>
                        <small class="opacity-75" data-i18n="categories.count_label">Danh mục</small>
                    </div>
                </div>
            </div>
        </div>
    </div>
</section>

<div class="container py-5">
    <c:choose>
        <c:when test="${not empty categories}">
            <div class="row g-4" data-stagger-children="0.1">
                <c:forEach var="cat" items="${categories}" varStatus="loop">
                    <c:set var="gradientColors" value="${
                        loop.index % 6 == 0 ? '#ec4899, #db2777' :
                        loop.index % 6 == 1 ? '#10b981, #059669' :
                        loop.index % 6 == 2 ? '#3b82f6, #2563eb' :
                        loop.index % 6 == 3 ? '#f59e0b, #d97706' :
                        loop.index % 6 == 4 ? '#a855f7, #9333ea' :
                        '#6366f1, #4f46e5'
                    }" />
                    <c:set var="defaultImages" value="${
                        loop.index % 6 == 0 ? 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=600' :
                        loop.index % 6 == 1 ? 'https://images.unsplash.com/photo-1571902943202-507ec2618e8f?w=600' :
                        loop.index % 6 == 2 ? 'https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=600' :
                        loop.index % 6 == 3 ? 'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=600' :
                        loop.index % 6 == 4 ? 'https://images.unsplash.com/photo-1513364776144-60967b0f800f?w=600' :
                        'https://images.unsplash.com/photo-1515187029135-18ee286d815b?w=600'
                    }" />
                    <div class="col-md-6 col-lg-4 animate-on-scroll">
                        <a href="${pageContext.request.contextPath}/events?category=${cat.slug}" class="text-decoration-none">
                            <div class="card glass-strong border-0 rounded-4 overflow-hidden h-100 hover-lift">
                                <div class="position-relative">
                                    <img src="${not empty cat.image ? cat.image : defaultImages}" 
                                         class="card-img-top" style="height: 220px; object-fit: cover;" 
                                         alt="${cat.name}" loading="lazy">
                                    <div class="position-absolute top-0 start-0 end-0 bottom-0" 
                                         style="background: linear-gradient(transparent 30%, rgba(${
                                            loop.index % 6 == 0 ? '236, 72, 153' :
                                            loop.index % 6 == 1 ? '16, 185, 129' :
                                            loop.index % 6 == 2 ? '59, 130, 246' :
                                            loop.index % 6 == 3 ? '245, 158, 11' :
                                            loop.index % 6 == 4 ? '168, 85, 247' :
                                            '99, 102, 241'
                                         }, 0.9));"></div>
                                    <div class="position-absolute bottom-0 start-0 end-0 p-4">
                                        <div class="d-flex align-items-center gap-3">
                                            <div class="rounded-3 d-flex align-items-center justify-content-center" 
                                                 style="width: 52px; height: 52px; background: rgba(255,255,255,0.2); backdrop-filter: blur(10px);">
                                                <i class="fas ${not empty cat.icon ? cat.icon : 'fa-calendar'} text-white fs-4"></i>
                                            </div>
                                            <div>
                                                <h4 class="text-white fw-bold mb-0">${cat.name}</h4>
                                                <c:if test="${not empty cat.description}">
                                                    <small class="text-white-50">${cat.description}</small>
                                                </c:if>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <div class="card-body">
                                    <c:if test="${not empty cat.description}">
                                        <p class="text-muted mb-3">${cat.description}</p>
                                    </c:if>
                                    <div class="d-flex align-items-center justify-content-between">
                                        <span class="badge rounded-pill px-3 py-2" 
                                              style="background: linear-gradient(135deg, ${gradientColors});">
                                            <i class="fas fa-calendar-alt me-1"></i>${cat.eventCount} <span data-i18n="categories.events_count">sự kiện</span>
                                        </span>
                                        <span class="text-primary fw-medium"><span data-i18n="categories.explore">Khám phá</span> <i class="fas fa-arrow-right ms-1"></i></span>
                                    </div>
                                </div>
                            </div>
                        </a>
                    </div>
                </c:forEach>
            </div>
        </c:when>
        <c:otherwise>
            <div class="text-center py-5">
                <i class="fas fa-folder-open fa-3x text-muted mb-3"></i>
                <h4 class="text-muted" data-i18n="categories.no_categories">Chưa có danh mục nào</h4>
                <p class="text-muted" data-i18n="categories.no_categories_desc">Các danh mục sự kiện sẽ sớm được cập nhật.</p>
            </div>
        </c:otherwise>
    </c:choose>
    
    <!-- CTA Section -->
    <div class="text-center mt-5 pt-4 animate-on-scroll">
        <div class="glass-strong p-5 rounded-4">
            <h3 class="fw-bold mb-3" data-i18n="categories.cta_title">Không tìm thấy danh mục phù hợp?</h3>
            <p class="text-muted mb-4" data-i18n="categories.cta_desc">Khám phá tất cả sự kiện hoặc tìm kiếm theo từ khóa</p>
            <a href="${pageContext.request.contextPath}/events" class="btn btn-gradient rounded-pill px-5 py-3 hover-glow">
                <i class="fas fa-search me-2"></i><span data-i18n="categories.cta_btn">Xem tất cả sự kiện</span>
            </a>
        </div>
    </div>
</div>

<jsp:include page="footer.jsp" />
