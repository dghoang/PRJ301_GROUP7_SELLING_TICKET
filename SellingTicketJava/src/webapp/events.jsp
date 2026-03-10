<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<c:set var="pageTitle" value="Khám phá sự kiện" scope="request" />
<jsp:include page="header.jsp" />

<style>
/* ===== EVENTS PAGE - TICKETBOX STYLE ===== */

/* Hero Section */
.events-hero {
    background: linear-gradient(135deg, #9333ea 0%, #db2777 50%, #f97316 100%);
    padding: 3rem 0 6rem;
    position: relative;
    overflow: hidden;
}
.events-hero::before {
    content: '';
    position: absolute;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    background: url("data:image/svg+xml,%3Csvg width='60' height='60' viewBox='0 0 60 60' xmlns='http://www.w3.org/2000/svg'%3E%3Cg fill='none' fill-rule='evenodd'%3E%3Cg fill='%23ffffff' fill-opacity='0.05'%3E%3Cpath d='M36 34v-4h-2v4h-4v2h4v4h2v-4h4v-2h-4zm0-30V0h-2v4h-4v2h4v4h2V6h4V4h-4zM6 34v-4H4v4H0v2h4v4h2v-4h4v-2H6zM6 4V0H4v4H0v2h4v4h2V6h4V4H6z'/%3E%3C/g%3E%3C/g%3E%3C/svg%3E");
}
.hero-badge {
    display: inline-block;
    background: rgba(255, 255, 255, 0.2);
    backdrop-filter: blur(10px);
    padding: 0.5rem 1.25rem;
    border-radius: 50px;
    margin-bottom: 1.5rem;
}
.hero-title {
    font-size: 3rem;
    font-weight: 800;
    font-style: italic;
    color: white;
    margin-bottom: 1rem;
    text-shadow: 0 2px 20px rgba(0, 0, 0, 0.1);
}
.hero-subtitle {
    font-size: 1.1rem;
    color: rgba(255, 255, 255, 0.85);
    max-width: 600px;
}

/* Search Box */
.search-container {
    margin-top: -4rem;
    position: relative;
    z-index: 10;
}
.search-box {
    background: white;
    border-radius: 20px;
    padding: 1.5rem 2rem;
    box-shadow: 0 20px 60px rgba(0, 0, 0, 0.12);
}
.search-label {
    font-size: 0.8rem;
    font-weight: 600;
    color: #6b7280;
    margin-bottom: 0.5rem;
    display: flex;
    align-items: center;
    gap: 0.4rem;
}
.search-input {
    border: none;
    background: #f3f4f6;
    border-radius: 12px;
    padding: 0.9rem 1rem;
    font-size: 0.95rem;
    width: 100%;
    transition: all 0.3s ease;
}
.search-input:focus {
    outline: none;
    background: #e5e7eb;
    box-shadow: 0 0 0 3px rgba(147, 51, 234, 0.1);
}
.search-select {
    border: none;
    background: #f3f4f6;
    border-radius: 12px;
    padding: 0.9rem 1rem;
    font-size: 0.95rem;
    width: 100%;
    cursor: pointer;
    appearance: none;
    background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='16' height='16' viewBox='0 0 24 24' fill='none' stroke='%236b7280' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'%3E%3Cpolyline points='6 9 12 15 18 9'%3E%3C/polyline%3E%3C/svg%3E");
    background-repeat: no-repeat;
    background-position: right 1rem center;
}
.search-select:focus {
    outline: none;
    background-color: #e5e7eb;
}
.search-btn {
    background: linear-gradient(135deg, #9333ea, #db2777);
    color: white;
    border: none;
    border-radius: 12px;
    padding: 0.9rem 2rem;
    font-size: 1rem;
    font-weight: 600;
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 0.5rem;
    transition: all 0.3s ease;
    width: 100%;
    height: 100%;
    min-height: 52px;
}
.search-btn:hover {
    transform: translateY(-2px);
    box-shadow: 0 10px 30px rgba(147, 51, 234, 0.3);
}

/* Category Pills */
.category-section {
    padding: 1.5rem 0;
}
.category-pill {
    display: inline-flex;
    align-items: center;
    gap: 0.5rem;
    padding: 0.65rem 1.25rem;
    border-radius: 50px;
    font-size: 0.9rem;
    font-weight: 500;
    text-decoration: none;
    transition: all 0.3s ease;
    border: 1px solid #e5e7eb;
    background: white;
    color: #374151;
}
.category-pill:hover {
    border-color: #9333ea;
    color: #9333ea;
    transform: translateY(-2px);
    box-shadow: 0 4px 12px rgba(147, 51, 234, 0.15);
}
.category-pill.active {
    background: linear-gradient(135deg, #9333ea, #db2777);
    color: white;
    border-color: transparent;
    box-shadow: 0 4px 15px rgba(147, 51, 234, 0.3);
}
.category-pill i {
    font-size: 0.85rem;
}

/* Results Section */
.results-section {
    padding: 2rem 0 4rem;
}
.results-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 2rem;
    flex-wrap: wrap;
    gap: 1rem;
}
.results-count {
    font-size: 1rem;
    color: #6b7280;
}
.results-count strong {
    color: #111827;
    font-weight: 700;
}
.sort-select {
    padding: 0.5rem 2rem 0.5rem 1rem;
    border: 1px solid #e5e7eb;
    border-radius: 10px;
    font-size: 0.9rem;
    background: white;
    cursor: pointer;
}

/* Event Cards */
.event-card {
    background: white;
    border-radius: 16px;
    overflow: hidden;
    transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
    border: 1px solid #f3f4f6;
    height: 100%;
    display: flex;
    flex-direction: column;
}
.event-card:hover {
    transform: translateY(-8px);
    box-shadow: 0 25px 50px rgba(0, 0, 0, 0.12);
}
.event-card:hover .event-img {
    transform: scale(1.08);
}

.event-img-wrapper {
    position: relative;
    height: 200px;
    overflow: hidden;
}
.event-img {
    width: 100%;
    height: 100%;
    object-fit: cover;
    transition: transform 0.6s ease;
}

/* Date Badge - Like Ticketbox */
.date-badge {
    position: absolute;
    top: 12px;
    left: 12px;
    background: white;
    border-radius: 12px;
    padding: 8px 12px;
    text-align: center;
    box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1);
    z-index: 3;
}
.date-badge .day {
    font-size: 1.5rem;
    font-weight: 800;
    line-height: 1;
    background: linear-gradient(135deg, #9333ea, #db2777);
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
    background-clip: text;
}
.date-badge .month {
    font-size: 0.7rem;
    text-transform: uppercase;
    color: #6b7280;
    font-weight: 600;
    letter-spacing: 0.5px;
}

/* Category & Hot Badge */
.event-badges {
    position: absolute;
    top: 12px;
    right: 12px;
    display: flex;
    flex-direction: column;
    gap: 6px;
    z-index: 3;
}
.badge-hot {
    background: linear-gradient(135deg, #ef4444, #f97316);
    color: white;
    padding: 4px 10px;
    border-radius: 8px;
    font-size: 0.7rem;
    font-weight: 700;
    letter-spacing: 0.5px;
}
.badge-featured {
    background: linear-gradient(135deg, #fbbf24, #f59e0b);
    color: white;
    padding: 4px 10px;
    border-radius: 8px;
    font-size: 0.7rem;
    font-weight: 700;
}

/* Price Tag */
.price-tag {
    position: absolute;
    bottom: 12px;
    right: 12px;
    background: rgba(255, 255, 255, 0.95);
    backdrop-filter: blur(10px);
    padding: 6px 14px;
    border-radius: 10px;
    font-weight: 700;
    font-size: 0.9rem;
    color: #9333ea;
    box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1);
    z-index: 3;
}
.price-tag.free {
    background: linear-gradient(135deg, #10b981, #06b6d4);
    color: white;
}

/* Event Content */
.event-content {
    padding: 1.25rem;
    flex: 1;
    display: flex;
    flex-direction: column;
}
.event-category {
    display: inline-block;
    background: linear-gradient(135deg, rgba(147, 51, 234, 0.1), rgba(219, 39, 119, 0.1));
    color: #9333ea;
    padding: 4px 12px;
    border-radius: 20px;
    font-size: 0.75rem;
    font-weight: 600;
    margin-bottom: 0.75rem;
    width: fit-content;
}
.event-title {
    font-size: 1rem;
    font-weight: 700;
    color: #111827;
    margin-bottom: 0.75rem;
    line-height: 1.4;
    display: -webkit-box;
    -webkit-line-clamp: 2;
    -webkit-box-orient: vertical;
    overflow: hidden;
    min-height: 2.8rem;
}
.event-title a {
    color: inherit;
    text-decoration: none;
    transition: color 0.2s;
}
.event-title a:hover {
    color: #9333ea;
}
.event-meta {
    margin-top: auto;
    display: flex;
    flex-direction: column;
    gap: 0.4rem;
}
.event-meta-item {
    display: flex;
    align-items: center;
    gap: 0.5rem;
    font-size: 0.85rem;
    color: #6b7280;
}
.event-meta-item i {
    width: 16px;
    color: #9333ea;
}

/* Empty State */
.empty-state {
    text-align: center;
    padding: 5rem 2rem;
}
.empty-icon {
    width: 140px;
    height: 140px;
    background: linear-gradient(135deg, rgba(147, 51, 234, 0.1), rgba(219, 39, 119, 0.1));
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    margin: 0 auto 2rem;
}
.empty-icon i {
    font-size: 4rem;
    background: linear-gradient(135deg, #9333ea, #db2777);
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
}

/* CTA Section */
.cta-section {
    background: linear-gradient(135deg, rgba(147, 51, 234, 0.05), rgba(219, 39, 119, 0.05));
    border-radius: 24px;
    padding: 3.5rem 2rem;
    text-align: center;
    border: 1px solid rgba(147, 51, 234, 0.1);
    margin-top: 3rem;
}
.cta-icon {
    width: 80px;
    height: 80px;
    background: linear-gradient(135deg, #9333ea, #db2777);
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    margin: 0 auto 1.5rem;
}
.cta-icon i {
    font-size: 2rem;
    color: white;
}

/* Pagination */
.pagination-section {
    display: flex;
    justify-content: center;
    margin-top: 3rem;
}
.pagination {
    display: flex;
    gap: 0.5rem;
}
.page-link {
    width: 42px;
    height: 42px;
    display: flex;
    align-items: center;
    justify-content: center;
    border-radius: 12px;
    border: 1px solid #e5e7eb;
    background: white;
    color: #374151;
    font-weight: 500;
    transition: all 0.3s ease;
}
.page-link:hover {
    border-color: #9333ea;
    color: #9333ea;
}
.page-item.active .page-link {
    background: linear-gradient(135deg, #9333ea, #db2777);
    color: white;
    border-color: transparent;
}

/* Responsive */
@media (max-width: 768px) {
    .hero-title { font-size: 2rem; }
    .search-box { padding: 1.25rem; border-radius: 16px; }
    .category-pill { padding: 0.5rem 1rem; font-size: 0.85rem; }
}
</style>

<!-- Hero Section -->
<section class="events-hero">
    <div class="container position-relative" style="z-index: 2;">
        <div class="hero-badge">
            <i class="fas fa-fire-alt text-white me-2"></i>
            <span class="text-white fw-medium">Hơn 500+ sự kiện đang chờ bạn</span>
        </div>
        <h1 class="hero-title">Khám phá sự kiện</h1>
        <p class="hero-subtitle">
            Tìm kiếm và đặt vé cho hàng ngàn sự kiện hấp dẫn trên khắp Việt Nam
        </p>
    </div>
</section>

<!-- Search Box -->
<div class="container search-container">
    <div class="search-box">
        <form action="${pageContext.request.contextPath}/events" method="get">
            <div class="row g-3 align-items-end">
                <div class="col-lg-4 col-md-6">
                    <label class="search-label">
                        <i class="fas fa-search"></i>Tìm kiếm
                    </label>
                    <input type="text" name="search" class="search-input" 
                           placeholder="Tên sự kiện, nghệ sĩ, địa điểm..." value="${searchQuery}">
                </div>
                <div class="col-lg-3 col-md-6">
                    <label class="search-label">
                        <i class="fas fa-folder"></i>Danh mục
                    </label>
                    <select name="category" class="search-select">
                        <option value="">Tất cả danh mục</option>
                        <c:forEach var="cat" items="${categories}">
                            <option value="${cat.slug}" ${selectedCategory == cat.slug ? 'selected' : ''}>${cat.name}</option>
                        </c:forEach>
                    </select>
                </div>
                <div class="col-lg-3 col-md-6">
                    <label class="search-label">
                        <i class="fas fa-calendar"></i>Thời gian
                    </label>
                    <select name="date" class="search-select">
                        <option value="">Tất cả thời gian</option>
                        <option value="today">Hôm nay</option>
                        <option value="week">Tuần này</option>
                        <option value="month">Tháng này</option>
                    </select>
                </div>
                <div class="col-lg-2 col-md-6">
                    <button type="submit" class="search-btn">
                        <i class="fas fa-search"></i>Tìm
                    </button>
                </div>
            </div>
        </form>
    </div>
</div>

<!-- Category Pills -->
<section class="category-section">
    <div class="container">
        <div class="d-flex flex-wrap gap-2">
            <a href="${pageContext.request.contextPath}/events" 
               class="category-pill ${empty selectedCategory ? 'active' : ''}">
                <i class="fas fa-border-all"></i>Tất cả
            </a>
            <c:forEach var="cat" items="${categories}">
                <a href="${pageContext.request.contextPath}/events?category=${cat.slug}" 
                   class="category-pill ${selectedCategory == cat.slug ? 'active' : ''}">
                    <i class="fas ${cat.icon}"></i>${cat.name}
                </a>
            </c:forEach>
        </div>
    </div>
</section>

<!-- Results Section -->
<section class="results-section">
    <div class="container">
        <!-- Results Header -->
        <div class="results-header">
            <span class="results-count">
                <c:choose>
                    <c:when test="${not empty events}">
                        Tìm thấy <strong>${events.size()}</strong> sự kiện
                    </c:when>
                    <c:otherwise>
                        Không có sự kiện
                    </c:otherwise>
                </c:choose>
            </span>
            <select class="sort-select" onchange="this.form.submit()" name="sort">
                <option value="newest">Mới nhất</option>
                <option value="popular">Phổ biến nhất</option>
                <option value="price_asc">Giá thấp → cao</option>
                <option value="price_desc">Giá cao → thấp</option>
            </select>
        </div>

        <!-- Events Grid -->
        <c:choose>
            <c:when test="${not empty events}">
                <div class="row g-4">
                    <c:forEach var="event" items="${events}">
                        <div class="col-sm-6 col-lg-4 col-xl-3">
                            <div class="event-card">
                                <div class="event-img-wrapper skeleton">
                                    <img src="${not empty event.bannerImage ? event.bannerImage : 'https://images.unsplash.com/photo-1459749411175-04bf5292ceea?w=400'}" 
                                         alt="${event.title}" class="event-img" loading="lazy" onload="this.parentElement.classList.remove('skeleton')">
                                    
                                    <!-- Date Badge -->
                                    <div class="date-badge">
                                        <div class="day"><fmt:formatDate value="${event.startDate}" pattern="dd"/></div>
                                        <div class="month">Th<fmt:formatDate value="${event.startDate}" pattern="MM"/></div>
                                    </div>
                                    
                                    <!-- Badges -->
                                    <div class="event-badges">
                                        <c:if test="${event.featured}">
                                            <span class="badge-hot">HOT</span>
                                        </c:if>
                                    </div>
                                    
                                    <!-- Price -->
                                    <div class="price-tag ${event.minPrice == 0 ? 'free' : ''}">
                                        <c:choose>
                                            <c:when test="${event.minPrice == 0}">Miễn phí</c:when>
                                            <c:otherwise><fmt:formatNumber value="${event.minPrice}" pattern="#,###"/>đ</c:otherwise>
                                        </c:choose>
                                    </div>
                                </div>
                                
                                <div class="event-content">
                                    <span class="event-category">${event.categoryName}</span>
                                    <h3 class="event-title">
                                        <a href="${pageContext.request.contextPath}/event/${event.slug}">${event.title}</a>
                                    </h3>
                                    <div class="event-meta">
                                        <div class="event-meta-item">
                                            <i class="fas fa-map-marker-alt"></i>
                                            <span>${event.location}</span>
                                        </div>
                                        <div class="event-meta-item">
                                            <i class="fas fa-clock"></i>
                                            <span><fmt:formatDate value="${event.startDate}" pattern="HH:mm, dd/MM/yyyy"/></span>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </c:forEach>
                </div>

                <!-- Pagination -->
                <nav class="pagination-section">
                    <ul class="pagination">
                        <li class="page-item ${currentPage == 1 ? 'disabled' : ''}">
                            <a class="page-link" href="?page=${currentPage - 1}&category=${selectedCategory}&search=${searchQuery}">
                                <i class="fas fa-chevron-left"></i>
                            </a>
                        </li>
                        <c:forEach begin="1" end="5" var="i">
                            <li class="page-item ${currentPage == i ? 'active' : ''}">
                                <a class="page-link" href="?page=${i}&category=${selectedCategory}&search=${searchQuery}">${i}</a>
                            </li>
                        </c:forEach>
                        <li class="page-item">
                            <a class="page-link" href="?page=${currentPage + 1}&category=${selectedCategory}&search=${searchQuery}">
                                <i class="fas fa-chevron-right"></i>
                            </a>
                        </li>
                    </ul>
                </nav>
            </c:when>
            <c:otherwise>
                <!-- Empty State -->
                <div class="empty-state">
                    <div class="empty-icon">
                        <i class="fas fa-calendar-times"></i>
                    </div>
                    <h3 class="fw-bold mb-3">Không tìm thấy sự kiện</h3>
                    <p class="text-muted mb-4" style="max-width: 400px; margin: 0 auto;">
                        Hiện tại chưa có sự kiện nào phù hợp với tiêu chí tìm kiếm của bạn. 
                        Hãy thử thay đổi bộ lọc hoặc tìm kiếm khác.
                    </p>
                    <a href="${pageContext.request.contextPath}/events" class="btn btn-gradient btn-lg rounded-pill px-5">
                        <i class="fas fa-redo me-2"></i>Xem tất cả sự kiện
                    </a>
                </div>
            </c:otherwise>
        </c:choose>

        <!-- CTA Section -->
        <div class="cta-section">
            <div class="cta-icon">
                <i class="fas fa-bullhorn"></i>
            </div>
            <h3 class="fw-bold mb-3">Bạn muốn tổ chức sự kiện?</h3>
            <p class="text-muted mb-4 mx-auto" style="max-width: 500px;">
                Đăng ký làm nhà tổ chức để quản lý và bán vé cho sự kiện của bạn 
                với các công cụ mạnh mẽ và dễ sử dụng nhất.
            </p>
            <a href="${pageContext.request.contextPath}/organizer/create-event" 
               class="btn btn-gradient btn-lg rounded-pill px-5"
               onclick="return requireLogin(this)">
                <i class="fas fa-plus-circle me-2"></i>Tạo sự kiện ngay
            </a>
        </div>
    </div>
</section>

<jsp:include page="footer.jsp" />
