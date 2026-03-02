<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<jsp:include page="header.jsp" />

<style>
/* ========== TICKETBOX PROFESSIONAL LAYOUT ========== */

/* Ticket Banner Section - Dark Header */
.ticket-banner-section {
    background: linear-gradient(135deg, #0f0f23 0%, #1a1a2e 50%, #16213e 100%);
    padding: 2rem 0;
    margin-top: -80px;
    padding-top: 120px;
    min-height: 520px;
}

/* Info Panel - Left Side */
.info-panel {
    background: #1f1f3a;
    border-radius: 20px;
    padding: 2rem;
    height: 100%;
    border: 1px solid rgba(255, 255, 255, 0.08);
}

.event-title-area h1 {
    color: white;
    font-size: 1.5rem;
    font-weight: 700;
    line-height: 1.4;
    margin-bottom: 1.5rem;
}

/* Time Badge */
.time-badge {
    display: inline-flex;
    align-items: center;
    gap: 0.5rem;
    background: rgba(236, 72, 153, 0.15);
    color: #f472b6;
    padding: 0.5rem 1rem;
    border-radius: 10px;
    font-size: 0.9rem;
    font-weight: 600;
    margin-bottom: 0.75rem;
}

.time-badge i {
    color: #ec4899;
}

/* Date Options */
.date-option {
    display: inline-flex;
    align-items: center;
    gap: 0.35rem;
    background: rgba(255, 255, 255, 0.08);
    color: rgba(255, 255, 255, 0.7);
    padding: 6px 12px;
    border-radius: 8px;
    font-size: 0.8rem;
    border: 1px solid rgba(255, 255, 255, 0.1);
    margin-bottom: 1.25rem;
    cursor: pointer;
    transition: all 0.2s ease;
}

.date-option:hover {
    background: rgba(255, 255, 255, 0.12);
    color: white;
}

/* Location */
.location-info {
    margin-bottom: 1.5rem;
}

.location-info .label {
    color: #10b981;
    font-size: 0.85rem;
    font-weight: 600;
    margin-bottom: 0.5rem;
    display: flex;
    align-items: center;
    gap: 0.35rem;
}

.location-info .venue {
    color: white;
    font-size: 0.95rem;
    font-weight: 600;
    margin-bottom: 0.35rem;
}

.location-info .address {
    color: rgba(255, 255, 255, 0.6);
    font-size: 0.85rem;
    line-height: 1.5;
}

/* Price Section */
.price-section {
    background: rgba(255, 255, 255, 0.05);
    border-radius: 14px;
    padding: 1.25rem;
    margin-bottom: 1.25rem;
    border: 1px solid rgba(255, 255, 255, 0.08);
}

.price-section .label {
    color: rgba(255, 255, 255, 0.6);
    font-size: 0.8rem;
    margin-bottom: 0.35rem;
}

.price-section .price {
    font-size: 1.75rem;
    font-weight: 800;
    background: linear-gradient(135deg, #10b981, #34d399);
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
    background-clip: text;
}

.price-section .price-arrow {
    color: #10b981;
    margin-left: 0.5rem;
}

/* CTA Button */
.btn-book-ticket {
    width: 100%;
    padding: 1rem 1.5rem;
    background: linear-gradient(135deg, #10b981, #059669);
    color: white;
    border: none;
    border-radius: 14px;
    font-size: 1rem;
    font-weight: 700;
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 0.5rem;
    cursor: pointer;
    transition: all 0.3s ease;
    text-decoration: none;
}

.btn-book-ticket:hover {
    background: linear-gradient(135deg, #059669, #047857);
    transform: translateY(-2px);
    box-shadow: 0 10px 30px rgba(16, 185, 129, 0.3);
    color: white;
}

/* Ticket Banner - Right Side */
.ticket-banner-wrapper {
    position: relative;
    border-radius: 20px;
    overflow: hidden;
    box-shadow: 0 30px 80px rgba(0, 0, 0, 0.4);
}

.ticket-banner-img {
    width: 100%;
    height: 400px;
    object-fit: cover;
}

.ticket-banner-overlay {
    position: absolute;
    bottom: 0;
    left: 0;
    right: 0;
    padding: 2rem;
    background: linear-gradient(to top, rgba(0,0,0,0.9) 0%, rgba(0,0,0,0.6) 50%, transparent 100%);
}

.ticket-banner-badge {
    display: inline-flex;
    align-items: center;
    gap: 0.35rem;
    background: linear-gradient(135deg, #ef4444, #dc2626);
    color: white;
    padding: 6px 14px;
    border-radius: 8px;
    font-size: 0.75rem;
    font-weight: 700;
    text-transform: uppercase;
    margin-bottom: 0.75rem;
}

.ticket-organizer {
    display: flex;
    align-items: center;
    gap: 0.75rem;
}

.ticket-organizer-logo {
    width: 48px;
    height: 48px;
    background: linear-gradient(135deg, #9333ea, #db2777);
    border-radius: 12px;
    display: flex;
    align-items: center;
    justify-content: center;
    color: white;
    font-weight: 700;
    font-size: 1rem;
}

.ticket-organizer-name {
    color: white;
    font-size: 0.9rem;
    font-weight: 600;
}

.ticket-organizer-label {
    color: rgba(255, 255, 255, 0.6);
    font-size: 0.75rem;
}

/* Promo Badge */
.promo-badge {
    position: absolute;
    bottom: 1.5rem;
    right: 1.5rem;
    background: linear-gradient(135deg, #fbbf24, #f59e0b);
    color: #78350f;
    padding: 0.75rem 1rem;
    border-radius: 12px;
    font-weight: 800;
    font-size: 0.85rem;
    box-shadow: 0 8px 25px rgba(245, 158, 11, 0.3);
    transform: rotate(3deg);
}

.promo-badge span {
    font-size: 1.25rem;
    display: block;
}

/* ========== CONTENT SECTION ========== */
.content-section {
    background: #f8fafc;
    padding: 3rem 0;
}

.content-card {
    background: white;
    border-radius: 24px;
    box-shadow: 0 10px 40px rgba(0, 0, 0, 0.05);
    overflow: hidden;
}

.section-title {
    display: flex;
    align-items: center;
    gap: 0.75rem;
    font-weight: 700;
    font-size: 1.2rem;
    margin-bottom: 1.25rem;
    color: #1f2937;
}

.section-title i {
    width: 40px;
    height: 40px;
    background: linear-gradient(135deg, rgba(147, 51, 234, 0.1), rgba(219, 39, 119, 0.1));
    border-radius: 12px;
    display: flex;
    align-items: center;
    justify-content: center;
    color: #9333ea;
}

/* Organizer Card */
.organizer-card {
    display: flex;
    gap: 1rem;
    background: linear-gradient(135deg, #f8f5ff, #fdf2f8);
    padding: 1.5rem;
    border-radius: 18px;
    border: 1px solid rgba(147, 51, 234, 0.1);
}

.organizer-avatar {
    width: 72px;
    height: 72px;
    background: linear-gradient(135deg, #9333ea, #db2777);
    border-radius: 16px;
    display: flex;
    align-items: center;
    justify-content: center;
    color: white;
    font-size: 1.5rem;
    font-weight: 700;
    flex-shrink: 0;
}

.organizer-info h5 {
    font-weight: 700;
    color: #1f2937;
    margin-bottom: 0.35rem;
}

.organizer-info p {
    color: #6b7280;
    font-size: 0.9rem;
    margin-bottom: 0.75rem;
}

.organizer-stats {
    display: flex;
    gap: 0.5rem;
    flex-wrap: wrap;
}

.organizer-stat {
    display: inline-flex;
    align-items: center;
    gap: 0.35rem;
    background: white;
    padding: 6px 12px;
    border-radius: 8px;
    font-size: 0.8rem;
    color: #6b7280;
    border: 1px solid #e5e7eb;
}

.organizer-stat i {
    color: #f59e0b;
}

/* Ticket Selection */
/* Ticket Selection - Premium Design */
.ticket-selection {
    background: transparent; /* Remove container bg */
    border: none;
    border-radius: 0;
}

.ticket-selection-header {
    display: none; /* Hide old header */
}

/* Premium Ticket Card */
/* Premium Ticket Card - Corner Cutout Design */
.ticket-card {
    display: flex;
    background: white;
    border-radius: 0; /* Handled by mask */
    position: relative;
    margin-bottom: 1.5rem;
    transition: all 0.3s ease;
    cursor: pointer;
    
    /* Corner Cutout Mask */
    --r: 12px; /* Radius of corner cutouts */
    -webkit-mask: 
        radial-gradient(circle var(--r) at top left, transparent 98%, black) top left,
        radial-gradient(circle var(--r) at top right, transparent 98%, black) top right,
        radial-gradient(circle var(--r) at bottom left, transparent 98%, black) bottom left,
        radial-gradient(circle var(--r) at bottom right, transparent 98%, black) bottom right;
    -webkit-mask-size: 51% 51%;
    -webkit-mask-repeat: no-repeat;
    mask: 
        radial-gradient(circle var(--r) at top left, transparent 98%, black) top left,
        radial-gradient(circle var(--r) at top right, transparent 98%, black) top right,
        radial-gradient(circle var(--r) at bottom left, transparent 98%, black) bottom left,
        radial-gradient(circle var(--r) at bottom right, transparent 98%, black) bottom right;
    mask-size: 51% 51%;
    mask-repeat: no-repeat;

    /* Drop shadow follows the mask shape */
    filter: drop-shadow(0 8px 16px rgba(0,0,0,0.08));
}

.ticket-card::before {
    /* Color accent bar on the left */
    content: '';
    position: absolute;
    top: 0; left: 0; bottom: 0;
    width: 6px;
    background: #e5e7eb;
    transition: all 0.3s ease;
    z-index: 1;
}

/* Hover Effects */
.ticket-card:hover {
    transform: translateY(-4px);
    filter: drop-shadow(0 15px 30px rgba(0,0,0,0.15));
}

.ticket-card.selected {
    filter: drop-shadow(0 0 0 2px #9333ea) drop-shadow(0 15px 30px rgba(147, 51, 234, 0.15));
    /* Box-shadow simulation via filter for selected state is tricky, 
       so we use a pseudo-border or rely on the left strip and color change */
}
.ticket-card.selected::before {
    background: #9333ea;
}

/* Ticket Types Colors */
.ticket-card.type-standard::before { background: linear-gradient(to bottom, #9ca3af, #4b5563); }
.ticket-card.type-vip::before { background: linear-gradient(to bottom, #d946ef, #7c3aed); }
.ticket-card.type-vvip::before { background: linear-gradient(to bottom, #f59e0b, #b45309); }


/* Left Section: Info */
.ticket-main {
    flex: 1;
    padding: 1.5rem 1.5rem 1.5rem 2.25rem; /* Extra left padding for strip */
    display: flex;
    align-items: center;
    gap: 1.5rem;
    background: white;
}

/* Divider with Notches - Improved */
.ticket-divider-vertical {
    width: 20px;
    background: white;
    position: relative;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
}
.ticket-divider-vertical::after {
    content: '';
    position: absolute;
    top: 10%; bottom: 10%;
    border-left: 2px dashed #e5e7eb;
}
/* We use the mask of the card for corners, but we need deeper cuts for the divider?
   No, let's use Overlays for the divider notches to match the page background (#f8fafc) 
   Because the card has a mask, anything 'outside' is cut. 
   To create 'inward' cuts in the middle, we need transparent holes. 
   Masks are best. Let's add middle cutouts to the mask!
*/

/* Complex Mask for Ticket Shape (Corners + Middle Notches) */
.ticket-card {
    --r: 12px; /* Corner radius */
    --n: 12px; /* Notch radius */
    --d: 260px; /* Distance to split/notch from right (approx width of stub) */
    /* 
       We can't easily do dynamic width mask in CSS without container queries or calc knowing explicit widths.
       So we will stick to the 'Overlay' technique for the middle notches for simplicity and robustness.
       The Overlay circles must match the PAGE background (#f8fafc).
    */
    background: white;
}

.ticket-divider-vertical::before, .ticket-divider-center-notch-bottom {
    /* Top notch */
    content: '';
    position: absolute;
    top: -12px; left: 50%; transform: translateX(-50%);
    width: 24px; height: 24px;
    background: #f8fafc; /* Match Page BG */
    border-radius: 50%;
    z-index: 5;
    box-shadow: inset 0 -2px 4px rgba(0,0,0,0.05); /* Inner shadow for depth */
}
/* Bottom notch via pseudo element on divider */
.ticket-divider-vertical span {
    position: absolute;
    bottom: -12px; left: 50%; transform: translateX(-50%);
    width: 24px; height: 24px;
    background: #f8fafc;
    border-radius: 50%;
    z-index: 5;
    box-shadow: inset 0 2px 4px rgba(0,0,0,0.05);
}

/* Right Section: Price & Action */
.ticket-stub-action {
    width: 260px;
    padding: 1.5rem;
    display: flex;
    flex-direction: column;
    justify-content: center;
    align-items: flex-end;
    background: #f9fafb; /* Slightly darker stub area */
    border-left: 1px dashed rgba(0,0,0,0.05); 
}

/* Icon Styling */
.ticket-icon-large {
    width: 64px;
    height: 64px;
    border-radius: 18px;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 1.75rem;
    color: white;
    box-shadow: 0 10px 20px rgba(0,0,0,0.1);
}

.icon-standard { background: linear-gradient(135deg, #6b7280, #1f2937); }
.icon-vip { background: linear-gradient(135deg, #9333ea, #db2777); }
.icon-vvip { background: linear-gradient(135deg, #f59e0b, #b45309); }

/* Typography */
.ticket-name-lg {
    font-size: 1.25rem;
    font-weight: 800;
    color: #111827;
    margin-bottom: 0.25rem;
}

.ticket-desc-lg {
    font-size: 0.9rem;
    color: #6b7280;
    line-height: 1.4;
}

.ticket-price-lg {
    font-size: 1.5rem;
    font-weight: 800;
    color: #9333ea;
    margin-bottom: 0.5rem;
}

.ticket-status-badge {
    padding: 4px 10px;
    border-radius: 6px;
    font-size: 0.75rem;
    font-weight: 700;
    text-transform: uppercase;
    display: inline-block;
    margin-bottom: 0.5rem;
}
.bg-status-success { background: rgba(16, 185, 129, 0.1); color: #059669; }
.bg-status-warning { background: rgba(245, 158, 11, 0.1); color: #d97706; }
.bg-status-danger { background: rgba(239, 68, 68, 0.1); color: #dc2626; }

/* Quantity Control */
.qty-control-lg {
    display: flex;
    align-items: center;
    background: white;
    border: 1px solid #e5e7eb;
    border-radius: 10px;
    overflow: hidden;
    box-shadow: 0 2px 5px rgba(0,0,0,0.05);
}

.qty-btn-lg {
    width: 36px;
    height: 36px;
    border: none;
    background: white;
    font-size: 1.2rem;
    color: #9333ea;
    cursor: pointer;
    transition: background 0.2s;
}
.qty-btn-lg:hover { background: #f3f4f6; }
.qty-val-lg { min-width: 30px; text-align: center; font-weight: 700; font-size: 1rem; }

/* Mobile */
@media (max-width: 768px) {
    .ticket-card { flex-direction: column; }
    .ticket-card::before { width: 100%; height: 6px; bottom: auto; }
    .ticket-left { padding-left: 1.5rem; border-right: none; border-bottom: 2px dashed #e5e7eb; }
    .ticket-divider-vertical { display: none; }
    .ticket-stub-action { width: 100%; align-items: center; flex-direction: row; justify-content: space-between; background: white; padding-top: 1rem; }
    .ticket-main { border-bottom: 2px dashed #f3f4f6; padding-bottom: 1rem; }
}

/* Sidebar Sticky Card */
.sticky-sidebar-card {
    background: white;
    border-radius: 20px;
    box-shadow: 0 15px 50px rgba(0, 0, 0, 0.08);
    overflow: hidden;
    position: sticky;
    top: 100px;
}

.sidebar-price-section {
    text-align: center;
    padding: 1.5rem;
    border-bottom: 1px solid #f3f4f6;
}

.sidebar-price-label {
    color: #6b7280;
    font-size: 0.85rem;
    margin-bottom: 0.35rem;
}

.sidebar-price-value {
    font-size: 2rem;
    font-weight: 800;
    background: linear-gradient(135deg, #9333ea, #db2777);
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
    background-clip: text;
}

/* Countdown */
.countdown-section {
    padding: 1rem;
    background: linear-gradient(135deg, rgba(147, 51, 234, 0.05), rgba(219, 39, 119, 0.05));
}

.countdown-grid {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: 0.5rem;
}

.countdown-box {
    text-align: center;
    background: white;
    padding: 0.75rem 0.5rem;
    border-radius: 12px;
}

.countdown-num {
    font-size: 1.5rem;
    font-weight: 800;
    background: linear-gradient(135deg, #9333ea, #db2777);
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
    background-clip: text;
    display: block;
}

.countdown-lbl {
    font-size: 0.6rem;
    text-transform: uppercase;
    color: #9ca3af;
    font-weight: 600;
}

/* Book Button */
.sidebar-book-btn {
    display: block;
    width: calc(100% - 2rem);
    margin: 1rem;
    padding: 1rem;
    background: linear-gradient(135deg, #9333ea, #db2777);
    color: white;
    border: none;
    border-radius: 14px;
    font-size: 1.1rem;
    font-weight: 700;
    text-align: center;
    text-decoration: none;
    transition: all 0.3s ease;
}

.sidebar-book-btn:hover {
    transform: translateY(-2px);
    box-shadow: 0 15px 40px rgba(147, 51, 234, 0.3);
    color: white;
}

/* Related Events */
.related-events-section {
    padding: 1rem;
    border-top: 1px solid #f3f4f6;
}

.related-event-card {
    display: flex;
    gap: 0.75rem;
    padding: 0.75rem;
    border-radius: 12px;
    text-decoration: none;
    color: inherit;
    transition: all 0.3s ease;
    margin-bottom: 0.5rem;
}

.related-event-card:hover {
    background: linear-gradient(135deg, rgba(147, 51, 234, 0.05), rgba(219, 39, 119, 0.05));
    transform: translateX(4px);
}

.related-event-img {
    width: 60px;
    height: 60px;
    border-radius: 10px;
    object-fit: cover;
    flex-shrink: 0;
}

.related-event-title {
    font-weight: 600;
    font-size: 0.85rem;
    color: #1f2937;
    margin-bottom: 0.25rem;
    display: -webkit-box;
    -webkit-line-clamp: 2;
    -webkit-box-orient: vertical;
    overflow: hidden;
}

.related-event-meta {
    font-size: 0.75rem;
    color: #9ca3af;
}

/* Responsive */
@media (max-width: 992px) {
    .ticket-banner-section { padding-top: 100px; min-height: auto; }
    .info-panel { margin-bottom: 1.5rem; }
    .ticket-banner-img { height: 280px; }
    .sticky-sidebar-card { position: static; margin-top: 1.5rem; }
}

@media (max-width: 576px) {
    .event-title-area h1 { font-size: 1.25rem; }
    .ticket-banner-img { height: 220px; }
}
</style>

<!-- ========== TICKET BANNER SECTION ========== -->
<div class="ticket-banner-section">
    <div class="container">
        <div class="row g-4">
            <!-- Left: Info Panel -->
            <div class="col-lg-5">
                <div class="info-panel">
                    <!-- Title -->
                    <div class="event-title-area">
                        <h1><c:out value="${event.title}" default="TÊN SỰ KIỆN TRƯỜNG HÙNG MINH : LỤA MÁU"/></h1>
                    </div>
                    
                    <!-- Time -->
                    <div class="time-badge">
                        <i class="fas fa-clock"></i>
                        <span>
                            <fmt:formatDate value="${event.startDate}" pattern="HH:mm"/> - 
                            <fmt:formatDate value="${event.endDate}" pattern="HH:mm"/>, 
                            <fmt:formatDate value="${event.startDate}" pattern="dd 'Tháng' MM, yyyy"/>
                        </span>
                    </div>
                    
                    <!-- Date Options -->
                    <div class="date-option">
                        <i class="fas fa-calendar-plus"></i>
                        + 1 ngày khác
                    </div>
                    
                    <!-- Location -->
                    <div class="location-info">
                        <div class="label">
                            <i class="fas fa-map-marker-alt"></i>
                            <c:out value="${event.location}" default="SÂN KHẤU NGHỆ THUẬT"/>
                        </div>
                        <div class="venue"><c:out value="${event.organizerName}" default="Trường Hùng Minh"/></div>
                        <div class="address"><c:out value="${event.address}" default="22 Vĩnh Viễn, Phường 02, Quận 10, Thành Phố Hồ Chí Minh"/></div>
                    </div>
                    
                    <!-- Price -->
                    <div class="price-section">
                        <div class="label">Giá từ</div>
                        <span class="price">
                            <c:choose>
                                <c:when test="${event.minPrice == 0}">Miễn phí</c:when>
                                <c:otherwise><fmt:formatNumber value="${event.minPrice}" pattern="#,###"/>đ</c:otherwise>
                            </c:choose>
                            <i class="fas fa-chevron-right price-arrow"></i>
                        </span>
                    </div>
                    
                    <!-- CTA Button -->
                    <a href="#ticket-section" class="btn-book-ticket" onclick="document.getElementById('ticket-section').scrollIntoView({behavior:'smooth'}); return false;">
                        <i class="fas fa-ticket-alt"></i>
                        Chọn vé & Mua ngay
                    </a>
                </div>
            </div>
            
            <!-- Right: Ticket Banner -->
            <div class="col-lg-7">
                <div class="ticket-banner-wrapper">
                    <c:choose>
                        <c:when test="${not empty event.bannerImage}">
                            <img src="${event.bannerImage}" alt="${event.title}" class="ticket-banner-img">
                        </c:when>
                        <c:otherwise>
                            <img src="https://images.unsplash.com/photo-1459749411175-04bf5292ceea?w=900" alt="Event Banner" class="ticket-banner-img">
                        </c:otherwise>
                    </c:choose>
                    
                    <!-- Overlay with Organizer -->
                    <div class="ticket-banner-overlay">
                        <span class="ticket-banner-badge">
                            <i class="fas fa-fire"></i> HOT
                        </span>
                        <div class="ticket-organizer">
                            <div class="ticket-organizer-logo">
                                <i class="fas fa-theater-masks"></i>
                            </div>
                            <div>
                                <div class="ticket-organizer-name"><c:out value="${event.organizerName}" default="Ban tổ chức sự kiện"/></div>
                                <div class="ticket-organizer-label">Đơn vị tổ chức</div>
                            </div>
                        </div>
                    </div>
                    
                    <!-- Promo Badge -->
                    <div class="promo-badge">
                        <span>GIẢM 30K</span>
                        Nhập mã: THM2026
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- ========== CONTENT SECTION ========== -->
<div class="content-section">
    <div class="container">
        <div class="row g-4">
            <!-- Main Content -->
            <div class="col-lg-8">
                <div class="content-card">
                    <!-- Description -->
                    <div class="p-4 p-lg-5 border-bottom">
                        <h5 class="section-title">
                            <i class="fas fa-info-circle"></i>
                            Giới thiệu sự kiện
                        </h5>
                        <div class="text-muted lh-lg event-html-content" style="white-space: normal; overflow-wrap: break-word;">
                            <c:out value="${event.description}" escapeXml="false" default="Thông tin chi tiết về sự kiện sẽ được cập nhật. Đây là một sự kiện đặc biệt với nhiều hoạt động hấp dẫn, mang đến cho khán giả những trải nghiệm tuyệt vời và đáng nhớ."/>
                        </div>
                    </div>
                    
                    <!-- Organizer -->
                    <div class="p-4 p-lg-5 border-bottom">
                        <h5 class="section-title">
                            <i class="fas fa-building"></i>
                            Ban tổ chức
                        </h5>
                        <div class="organizer-card">
                            <div class="organizer-avatar">T</div>
                            <div class="organizer-info">
                                <h5><c:out value="${event.organizerName}" default="Ban tổ chức sự kiện"/></h5>
                                <p>Đơn vị tổ chức sự kiện chuyên nghiệp hàng đầu</p>
                                <div class="organizer-stats">
                                    <span class="organizer-stat"><i class="fas fa-star"></i> 4.9</span>
                                    <span class="organizer-stat"><i class="fas fa-calendar-check"></i> 50+ sự kiện</span>
                                    <span class="organizer-stat"><i class="fas fa-users"></i> 100K+ người theo dõi</span>
                                </div>
                            </div>
                        </div>
                    </div>
                    
                    <!-- Tickets -->
                    <div class="p-4 p-lg-5" id="ticket-section">
                        <h5 class="section-title">
                            <i class="fas fa-ticket-alt"></i>
                            Chọn loại vé
                        </h5>
                        
                        <div class="ticket-selection">
                            <c:choose>
                                <c:when test="${not empty ticketTypes}">
                                    <c:forEach var="ticket" items="${ticketTypes}" varStatus="loop">
                                        <c:set var="remaining" value="${ticket.quantity - ticket.soldQuantity}"/>
                                        <!-- Determine Card Type -->
                                        <c:set var="cardType" value="type-standard"/>
                                        <c:set var="iconClass" value="icon-standard"/>
                                        <c:choose>
                                            <c:when test="${loop.index == 1}">
                                                <c:set var="cardType" value="type-vip"/>
                                                <c:set var="iconClass" value="icon-vip"/>
                                            </c:when>
                                            <c:when test="${loop.index > 1}">
                                                <c:set var="cardType" value="type-vvip"/>
                                                <c:set var="iconClass" value="icon-vvip"/>
                                            </c:when>
                                        </c:choose>

                                        <div class="ticket-card ${cardType}" onclick="selectTicket(this, ${ticket.ticketTypeId})" 
                                             data-ticket-id="${ticket.ticketTypeId}" data-price="${ticket.price}">
                                            
                                            <!-- Main Info -->
                                            <div class="ticket-main">
                                                <div class="ticket-icon-large ${iconClass}">
                                                    <c:choose>
                                                        <c:when test="${loop.index == 0}"><i class="fas fa-ticket-alt"></i></c:when>
                                                        <c:when test="${loop.index == 1}"><i class="fas fa-crown"></i></c:when>
                                                        <c:otherwise><i class="fas fa-gem"></i></c:otherwise>
                                                    </c:choose>
                                                </div>
                                                <div>
                                                    <h4 class="ticket-name-lg">${ticket.name}</h4>
                                                    <p class="ticket-desc-lg mb-0">${ticket.description}</p>
                                                </div>
                                            </div>
                                            
                                            <!-- Divider -->
                                            <div class="ticket-divider-vertical">
                                                <span></span>
                                            </div>
                                            
                                            <!-- Stub / Action -->
                                            <div class="ticket-stub-action">
                                                <div class="ticket-price-lg">
                                                    <c:choose>
                                                        <c:when test="${ticket.price == 0}">Miễn phí</c:when>
                                                        <c:otherwise><fmt:formatNumber value="${ticket.price}" pattern="#,###"/>đ</c:otherwise>
                                                    </c:choose>
                                                </div>
                                                
                                                <c:choose>
                                                    <c:when test="${remaining > 50}">
                                                        <span class="ticket-status-badge bg-status-success">Còn vé</span>
                                                    </c:when>
                                                    <c:when test="${remaining > 0}">
                                                        <span class="ticket-status-badge bg-status-warning">Sắp hết (${remaining})</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="ticket-status-badge bg-status-danger">Hết vé</span>
                                                    </c:otherwise>
                                                </c:choose>
                                                
                                                <c:if test="${remaining > 0}">
                                                    <div class="qty-control-lg mt-2" onclick="event.stopPropagation();">
                                                        <button type="button" class="qty-btn-lg" onclick="changeQty(${ticket.ticketTypeId}, -1)">−</button>
                                                        <span class="qty-val-lg" id="qty-${ticket.ticketTypeId}">0</span>
                                                        <button type="button" class="qty-btn-lg" onclick="changeQty(${ticket.ticketTypeId}, 1)">+</button>
                                                    </div>
                                                </c:if>
                                            </div>
                                        </div>
                                    </c:forEach>
                                    
                                    <!-- Total + Terms + Buy Button -->
                                    <div class="p-4 mt-2" style="background: white; border-radius: 16px; border: 1px solid #e5e7eb; box-shadow: 0 4px 15px rgba(0,0,0,0.05);">
                                        <div class="d-flex justify-content-between align-items-center mb-3">
                                            <div class="d-flex align-items-center gap-3">
                                                <div style="width: 48px; height: 48px; background: #f3f4f6; border-radius: 12px; display: flex; align-items: center; justify-content: center; color: #6b7280;">
                                                    <i class="fas fa-shopping-cart"></i>
                                                </div>
                                                <div>
                                                    <div class="text-muted small">Tổng số lượng</div>
                                                    <div class="fw-bold fs-5" id="total-tickets">0 vé</div>
                                                </div>
                                            </div>
                                            <div class="text-end">
                                                <div class="text-muted small">Tạm tính</div>
                                                <div class="fw-bold fs-3" style="color: #9333ea;" id="total-price">0đ</div>
                                            </div>
                                        </div>

                                        <!-- Terms Agreement -->
                                        <div class="form-check mb-3 p-3" style="background: #f8f5ff; border-radius: 12px; border: 1px solid rgba(147,51,234,0.1);">
                                            <input class="form-check-input" type="checkbox" id="agreeTerms" style="margin-top: 0.35em;">
                                            <label class="form-check-label small" for="agreeTerms">
                                                Tôi đồng ý với <a href="#" class="fw-bold" style="color: #9333ea;" onclick="event.preventDefault(); document.getElementById('termsModal').style.display='flex';">Điều khoản sử dụng</a>,
                                                <a href="#" class="fw-bold" style="color: #9333ea;" onclick="event.preventDefault(); document.getElementById('termsModal').style.display='flex';">Chính sách bảo mật</a>
                                                và xác nhận thông tin mua vé là chính xác.
                                            </label>
                                        </div>

                                        <!-- Buy Button -->
                                        <button type="button" class="btn w-100 py-3 fw-bold rounded-pill" id="buyBtn"
                                                style="background: linear-gradient(135deg, #9333ea, #db2777); color: white; font-size: 1.1rem; border: none; box-shadow: 0 8px 25px rgba(147,51,234,0.3); transition: all 0.3s ease;"
                                                onclick="proceedToCheckout()" disabled>
                                            <i class="fas fa-lock me-2"></i>Chọn vé để tiếp tục
                                        </button>
                                        <p class="text-center text-muted small mt-2 mb-0">
                                            <i class="fas fa-shield-alt text-success me-1"></i>
                                            Thanh toán an toàn & bảo mật 100% · Không hoàn vé
                                        </p>
                                    </div>
                                </c:when>
                                <c:otherwise>
                                    <div class="text-center py-5 text-muted">
                                        <i class="fas fa-ticket-alt fa-3x mb-3 opacity-25"></i>
                                        <p>Chưa có thông tin vé cho sự kiện này</p>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </div>
            </div>
            
            <!-- Sidebar -->
            <div class="col-lg-4">
                <div class="sticky-sidebar-card">
                    <!-- Price -->
                    <div class="sidebar-price-section">
                        <div class="sidebar-price-label">Giá từ</div>
                        <div class="sidebar-price-value">
                            <c:choose>
                                <c:when test="${event.minPrice == 0}">Miễn phí</c:when>
                                <c:otherwise><fmt:formatNumber value="${event.minPrice}" pattern="#,###"/>đ</c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                    
                    <!-- Countdown -->
                    <div class="countdown-section">
                        <p class="text-center text-muted small mb-2">
                            <i class="fas fa-clock me-1"></i>Thời gian còn lại
                        </p>
                        <div class="countdown-grid">
                            <div class="countdown-box">
                                <span class="countdown-num" id="days">00</span>
                                <span class="countdown-lbl">Ngày</span>
                            </div>
                            <div class="countdown-box">
                                <span class="countdown-num" id="hours">00</span>
                                <span class="countdown-lbl">Giờ</span>
                            </div>
                            <div class="countdown-box">
                                <span class="countdown-num" id="minutes">00</span>
                                <span class="countdown-lbl">Phút</span>
                            </div>
                            <div class="countdown-box">
                                <span class="countdown-num" id="seconds">00</span>
                                <span class="countdown-lbl">Giây</span>
                            </div>
                        </div>
                    </div>
                    
                    <!-- Book Button -->
                    <a href="#ticket-section" class="sidebar-book-btn" onclick="document.getElementById('ticket-section').scrollIntoView({behavior:'smooth'}); return false;">
                        <i class="fas fa-ticket-alt me-2"></i>Mua vé ngay
                    </a>
                    
                    <p class="text-center text-muted small px-3 pb-3 mb-0">
                        <i class="fas fa-shield-alt text-success me-1"></i>
                        Thanh toán an toàn & bảo mật 100%
                    </p>
                    
                    <!-- Related Events -->
                    <div class="related-events-section">
                        <h6 class="fw-bold mb-3">
                            <i class="fas fa-calendar-alt me-2" style="color: #9333ea;"></i>Sự kiện tương tự
                        </h6>
                        
                        <c:choose>
                            <c:when test="${not empty relatedEvents}">
                                <c:forEach var="related" items="${relatedEvents}" end="2">
                                    <a href="${pageContext.request.contextPath}/event/${related.slug}" class="related-event-card">
                                        <img src="${not empty related.bannerImage ? related.bannerImage : 'https://images.unsplash.com/photo-1459749411175-04bf5292ceea?w=200'}" 
                                             alt="${related.title}" class="related-event-img">
                                        <div>
                                            <div class="related-event-title">${related.title}</div>
                                            <div class="related-event-meta">
                                                <i class="fas fa-calendar-alt me-1"></i>
                                                <fmt:formatDate value="${related.startDate}" pattern="dd/MM/yyyy"/>
                                            </div>
                                        </div>
                                    </a>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <a href="#" class="related-event-card">
                                    <img src="https://images.unsplash.com/photo-1540039155733-5bb30b53aa14?w=200" alt="Event" class="related-event-img">
                                    <div>
                                        <div class="related-event-title">Rock Festival 2026</div>
                                        <div class="related-event-meta"><i class="fas fa-calendar-alt me-1"></i>15/03/2026</div>
                                    </div>
                                </a>
                                <a href="#" class="related-event-card">
                                    <img src="https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=200" alt="Event" class="related-event-img">
                                    <div>
                                        <div class="related-event-title">Jazz Night Live</div>
                                        <div class="related-event-meta"><i class="fas fa-calendar-alt me-1"></i>20/03/2026</div>
                                    </div>
                                </a>
                                <a href="#" class="related-event-card">
                                    <img src="https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=200" alt="Event" class="related-event-img">
                                    <div>
                                        <div class="related-event-title">EDM Party Night</div>
                                        <div class="related-event-meta"><i class="fas fa-calendar-alt me-1"></i>25/03/2026</div>
                                    </div>
                                </a>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
// Ticket cart
let ticketCart = {};

function changeQty(ticketId, delta) {
    const qtyEl = document.getElementById('qty-' + ticketId);
    let current = parseInt(qtyEl.textContent) || 0;
    current += delta;
    if (current < 0) current = 0;
    if (current > 10) current = 10;
    qtyEl.textContent = current;
    
    const card = qtyEl.closest('.ticket-card');
    const price = parseFloat(card.dataset.price) || 0;
    ticketCart[ticketId] = { qty: current, price: price };
    
    if (current > 0) {
        card.classList.add('selected');
    } else {
        card.classList.remove('selected');
    }
    
    updateTotal();
}

function selectTicket(el, ticketId) {
    // Optional: Only select if clicking card, not inside buttons
    // But since we have specific qty controls, we just highlight
    // document.querySelectorAll('.ticket-card').forEach(c => c.classList.remove('selected'));
    // el.classList.add('selected');
}

function updateTotal() {
    let totalQty = 0;
    let totalPrice = 0;
    
    Object.values(ticketCart).forEach(item => {
        totalQty += item.qty;
        totalPrice += item.qty * item.price;
    });
    
    const totalTicketsEl = document.getElementById('total-tickets');
    const totalPriceEl = document.getElementById('total-price');
    const buyBtn = document.getElementById('buyBtn');
    const agreeTerms = document.getElementById('agreeTerms');
    
    if (totalTicketsEl) totalTicketsEl.textContent = totalQty + ' vé';
    if (totalPriceEl) totalPriceEl.textContent = totalPrice.toLocaleString('vi-VN') + 'đ';
    
    if (buyBtn) {
        const termsOk = agreeTerms ? agreeTerms.checked : false;
        if (totalQty > 0 && termsOk) {
            buyBtn.disabled = false;
            buyBtn.innerHTML = '<i class="fas fa-shopping-cart me-2"></i>Mua ' + totalQty + ' vé — ' + totalPrice.toLocaleString('vi-VN') + 'đ';
            buyBtn.style.opacity = '1';
            buyBtn.style.cursor = 'pointer';
        } else if (totalQty > 0) {
            buyBtn.disabled = true;
            buyBtn.innerHTML = '<i class="fas fa-check-square me-2"></i>Vui lòng chấp nhận điều khoản';
            buyBtn.style.opacity = '0.6';
        } else {
            buyBtn.disabled = true;
            buyBtn.innerHTML = '<i class="fas fa-lock me-2"></i>Chọn vé để tiếp tục';
            buyBtn.style.opacity = '0.6';
        }
    }
}

function proceedToCheckout() {
    var agreeTerms = document.getElementById('agreeTerms');
    if (!agreeTerms || !agreeTerms.checked) {
        agreeTerms.parentElement.style.animation = 'shake 0.5s';
        setTimeout(function() { agreeTerms.parentElement.style.animation = ''; }, 500);
        return;
    }
    
    var selectedTicketId = null;
    var selectedQty = 0;
    for (var tid in ticketCart) {
        if (ticketCart[tid].qty > 0) {
            selectedTicketId = tid;
            selectedQty = ticketCart[tid].qty;
            break;
        }
    }
    
    if (!selectedTicketId) {
        if (typeof showToast === 'function') showToast('Vui lòng chọn ít nhất 1 vé', 'error');
        return;
    }
    
    var ctx = document.querySelector('meta[name="ctx"]');
    var ctxPath = ctx ? ctx.content : '';
    var checkoutUrl = ctxPath + '/checkout?eventId=${event.eventId}&ticketTypeId=' + selectedTicketId + '&quantity=' + selectedQty;
    window.location.href = checkoutUrl;
}

// Terms checkbox
document.addEventListener('DOMContentLoaded', function() {
    var agreeEl = document.getElementById('agreeTerms');
    if (agreeEl) agreeEl.addEventListener('change', updateTotal);
});

// Countdown using real event date
document.addEventListener('DOMContentLoaded', function() {
    var targetDate = new Date('${event.startDate}');
    if (isNaN(targetDate.getTime())) { targetDate = new Date(); targetDate.setDate(targetDate.getDate() + 9); }
    
    function updateCountdown() {
        var now = new Date();
        var diff = targetDate - now;
        if (diff <= 0) { 
            ['days','hours','minutes','seconds'].forEach(function(id) { document.getElementById(id).textContent = '00'; });
            return;
        }
        document.getElementById('days').textContent = String(Math.floor(diff / 86400000)).padStart(2, '0');
        document.getElementById('hours').textContent = String(Math.floor((diff % 86400000) / 3600000)).padStart(2, '0');
        document.getElementById('minutes').textContent = String(Math.floor((diff % 3600000) / 60000)).padStart(2, '0');
        document.getElementById('seconds').textContent = String(Math.floor((diff % 60000) / 1000)).padStart(2, '0');
    }
    updateCountdown();
    setInterval(updateCountdown, 1000);
});
</script>

<!-- Context Path Meta -->
<meta name="ctx" content="${pageContext.request.contextPath}">

<!-- Terms & Conditions Modal -->
<div id="termsModal" style="display:none; position:fixed; top:0; left:0; width:100%; height:100%; z-index:9999; background:rgba(0,0,0,0.5); backdrop-filter:blur(4px);">
    <div style="display:flex; align-items:center; justify-content:center; height:100%; padding:1rem;">
        <div style="background:white; border-radius:24px; max-width:600px; width:100%; max-height:80vh; overflow-y:auto; box-shadow:0 25px 60px rgba(0,0,0,0.2);">
            <div class="p-4 border-bottom d-flex justify-content-between align-items-center">
                <h5 class="fw-bold mb-0"><i class="fas fa-file-contract me-2" style="color:#9333ea;"></i>Điều khoản & Điều kiện</h5>
                <button type="button" class="btn-close" onclick="document.getElementById('termsModal').style.display='none';"></button>
            </div>
            <div class="p-4">
                <h6 class="fw-bold">1. Điều khoản mua vé</h6>
                <ul class="small text-muted mb-3">
                    <li>Vé đã mua <strong>không được hoàn lại</strong> trừ khi sự kiện bị hủy bởi ban tổ chức.</li>
                    <li>Mỗi giao dịch giới hạn tối đa <strong>10 vé</strong>.</li>
                    <li>Vé chỉ hợp lệ khi xuất trình mã QR tại cổng check-in.</li>
                    <li>Mỗi vé chỉ sử dụng <strong>một lần duy nhất</strong>. Không chuyển nhượng, sao chép.</li>
                </ul>
                <h6 class="fw-bold">2. Chính sách bảo mật</h6>
                <ul class="small text-muted mb-3">
                    <li>Thông tin cá nhân chỉ dùng để xử lý đơn hàng và liên hệ khi cần.</li>
                    <li>Dữ liệu được mã hóa và bảo vệ theo tiêu chuẩn SSL/TLS.</li>
                    <li>Chúng tôi không chia sẻ thông tin với bên thứ ba không liên quan.</li>
                </ul>
                <h6 class="fw-bold">3. Quy định tham dự</h6>
                <ul class="small text-muted mb-3">
                    <li>Khách tham dự cần tuân thủ nội quy của địa điểm tổ chức.</li>
                    <li>Ban tổ chức có quyền từ chối khách vi phạm nội quy.</li>
                    <li>Chương trình có thể thay đổi không báo trước.</li>
                </ul>
            </div>
            <div class="p-4 border-top text-end">
                <button type="button" class="btn rounded-pill px-4 py-2 fw-bold" 
                        style="background:linear-gradient(135deg,#9333ea,#db2777);color:white;"
                        onclick="document.getElementById('termsModal').style.display='none'; document.getElementById('agreeTerms').checked=true; updateTotal();">
                    <i class="fas fa-check me-2"></i>Tôi đồng ý
                </button>
            </div>
        </div>
    </div>
</div>

<style>
@keyframes shake {
    0%, 100% { transform: translateX(0); }
    25% { transform: translateX(-8px); }
    75% { transform: translateX(8px); }
}
</style>

<jsp:include page="footer.jsp" />

