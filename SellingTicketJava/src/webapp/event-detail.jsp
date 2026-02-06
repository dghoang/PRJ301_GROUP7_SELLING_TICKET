<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>

<jsp:include page="header.jsp" />

<style>
    .event-hero {
        position: relative;
        height: 60vh;
        min-height: 400px;
        margin-top: -80px;
        overflow: hidden;
    }
    .event-hero img {
        width: 100%;
        height: 100%;
        object-fit: cover;
        transition: transform 0.3s ease;
    }
    .event-hero::after {
        content: '';
        position: absolute;
        bottom: 0;
        left: 0;
        right: 0;
        height: 70%;
        background: linear-gradient(to top, var(--bs-body-bg) 0%, transparent 100%);
    }
    .content-overlap {
        position: relative;
        z-index: 10;
        margin-top: -150px;
    }
    
    /* Ticket type hover effect */
    .ticket-type {
        transition: all 0.3s ease;
        border: 2px solid transparent;
    }
    .ticket-type:hover {
        transform: translateX(5px);
        border-color: var(--primary);
        background: rgba(147, 51, 234, 0.05) !important;
    }
    .ticket-type.selected {
        border-color: var(--primary);
        background: rgba(147, 51, 234, 0.1) !important;
    }
    
    /* Schedule button styles */
    .schedule-btn {
        transition: all 0.3s ease;
    }
    .schedule-btn:not(:disabled):hover {
        transform: translateY(-2px);
        box-shadow: 0 5px 20px rgba(0, 0, 0, 0.1);
    }
    .schedule-btn.active {
        background: linear-gradient(135deg, var(--primary), var(--secondary)) !important;
        color: white !important;
        border: none !important;
        box-shadow: 0 5px 20px rgba(147, 51, 234, 0.3);
    }
    
    /* Quick info icon */
    .info-icon {
        width: 52px;
        height: 52px;
        border-radius: var(--radius-lg);
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 1.25rem;
        transition: all 0.3s ease;
    }
    .info-icon:hover {
        transform: scale(1.1);
    }
    
    /* Share button animation */
    .share-popup {
        position: absolute;
        top: 100%;
        right: 0;
        margin-top: 0.5rem;
        padding: 1rem;
        border-radius: var(--radius-lg);
        opacity: 0;
        visibility: hidden;
        transform: translateY(-10px);
        transition: all 0.3s ease;
        z-index: 100;
    }
    .share-popup.show {
        opacity: 1;
        visibility: visible;
        transform: translateY(0);
    }
</style>

<!-- Banner with Parallax Effect -->
<div class="event-hero" data-parallax="0.3">
    <img src="${not empty event.bannerImage ? event.bannerImage : 'https://images.unsplash.com/photo-1459749411175-04bf5292ceea?w=1200'}" 
         alt="${event.title}">
    <div class="position-absolute top-0 start-0 w-100 h-100" 
         style="background: linear-gradient(135deg, rgba(147, 51, 234, 0.2), rgba(219, 39, 119, 0.2));"></div>
</div>

<div class="container content-overlap pb-5">
    <div class="row g-4">
        <!-- Main Content -->
        <div class="col-lg-8">
            <!-- Event Info Card -->
            <div class="glass-strong p-4 p-lg-5 rounded-4 mb-4 animate-on-scroll">
                <!-- Category & Actions -->
                <div class="d-flex align-items-center justify-content-between mb-4">
                    <div class="d-flex align-items-center gap-2 flex-wrap">
                        <span class="badge rounded-pill px-3 py-2 fw-medium animate-fadeInLeft"
                              style="background: linear-gradient(135deg, var(--primary), var(--secondary)); color: white;">
                            <i class="fas fa-music me-1"></i>${not empty event.categoryName ? event.categoryName : 'Âm nhạc'}
                        </span>
                        <span class="badge badge-hot animate-fadeInLeft stagger-2">
                            <i class="fas fa-fire me-1"></i>HOT
                        </span>
                    </div>
                    <div class="d-flex gap-2 position-relative">
                        <button class="btn glass rounded-3 text-muted hover-scale" onclick="toggleLike(this)" 
                                title="Yêu thích">
                            <i class="far fa-heart fs-5"></i>
                        </button>
                        <button class="btn glass rounded-3 text-muted hover-scale" onclick="toggleShare()" 
                                title="Chia sẻ">
                            <i class="fas fa-share-alt fs-5"></i>
                        </button>
                        
                        <!-- Share Popup -->
                        <div class="share-popup glass-strong" id="sharePopup">
                            <p class="fw-bold mb-2 small">Chia sẻ sự kiện</p>
                            <div class="d-flex gap-2">
                                <a href="#" class="btn btn-sm rounded-circle" style="background: #1877f2; color: white; width: 36px; height: 36px;">
                                    <i class="fab fa-facebook-f"></i>
                                </a>
                                <a href="#" class="btn btn-sm rounded-circle" style="background: #1da1f2; color: white; width: 36px; height: 36px;">
                                    <i class="fab fa-twitter"></i>
                                </a>
                                <button onclick="copyLink()" class="btn btn-sm glass rounded-circle" style="width: 36px; height: 36px;">
                                    <i class="fas fa-link"></i>
                                </button>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Title -->
                <h1 class="display-5 fw-bold mb-4 animate-fadeInUp">
                    ${not empty event.title ? event.title : 'Đêm nhạc Rock Việt - Live Concert 2026'}
                </h1>

                <!-- Quick Info -->
                <div class="row g-3 mb-5" data-stagger-children="0.1">
                    <div class="col-sm-6 animate-on-scroll">
                        <div class="d-flex align-items-center gap-3">
                            <div class="info-icon" style="background: linear-gradient(135deg, rgba(147, 51, 234, 0.1), rgba(219, 39, 119, 0.1));">
                                <i class="fas fa-calendar-alt text-primary"></i>
                            </div>
                            <div>
                                <h6 class="fw-bold text-dark mb-0">
                                    ${not empty event.startDate ? event.startDate : '20/03/2026'}
                                </h6>
                                <small class="text-muted">19:00 - 22:00</small>
                            </div>
                        </div>
                    </div>
                    <div class="col-sm-6 animate-on-scroll">
                        <div class="d-flex align-items-center gap-3">
                            <div class="info-icon" style="background: linear-gradient(135deg, rgba(16, 185, 129, 0.1), rgba(6, 182, 212, 0.1));">
                                <i class="fas fa-map-marker-alt text-success"></i>
                            </div>
                            <div>
                                <h6 class="fw-bold text-dark mb-0">
                                    ${not empty event.location ? event.location : 'Nhà hát Hòa Bình'}
                                </h6>
                                <small class="text-muted">Quận 10, TP. Hồ Chí Minh</small>
                            </div>
                        </div>
                    </div>
                    <div class="col-sm-6 animate-on-scroll">
                        <div class="d-flex align-items-center gap-3">
                            <div class="info-icon" style="background: linear-gradient(135deg, rgba(245, 158, 11, 0.1), rgba(239, 68, 68, 0.1));">
                                <i class="fas fa-users text-warning"></i>
                            </div>
                            <div>
                                <h6 class="fw-bold text-dark mb-0" data-counter="${not empty event.eventCount ? event.eventCount : 2500}">0</h6>
                                <small class="text-muted">người quan tâm</small>
                            </div>
                        </div>
                    </div>
                    <div class="col-sm-6 animate-on-scroll">
                        <div class="d-flex align-items-center gap-3">
                            <div class="info-icon" style="background: linear-gradient(135deg, rgba(99, 102, 241, 0.1), rgba(139, 92, 246, 0.1));">
                                <i class="fas fa-ticket-alt text-indigo"></i>
                            </div>
                            <div>
                                <h6 class="fw-bold text-dark mb-0">Còn vé</h6>
                                <small class="text-muted">Mở bán đến 19/03/2026</small>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Description -->
                <div class="mb-4 animate-on-scroll">
                    <h5 class="fw-bold mb-3 d-flex align-items-center gap-2">
                        <i class="fas fa-info-circle text-primary"></i>
                        Giới thiệu sự kiện
                    </h5>
                    <div class="text-muted lh-lg" style="white-space: pre-line;">
                        ${not empty event.description ? event.description : 
                        'Đêm nhạc Rock Việt - Live Concert 2026 là sự kiện âm nhạc lớn nhất trong năm, quy tụ những ban nhạc rock hàng đầu Việt Nam.\n\n🎸 Line-up nghệ sĩ:\n• Bức Tường\n• Microwave\n• Ngũ Cung\n• Da LAB\n• Cá Hồi Hoang\n\n✨ Highlights:\n• 4 giờ âm nhạc rock đỉnh cao\n• Hệ thống âm thanh, ánh sáng chuyên nghiệp\n• Không gian checkin cực chất\n• Khu vực food court đa dạng'}
                    </div>
                </div>
            </div>

            <!-- Organizer -->
            <div class="glass-strong p-4 rounded-4 mb-4 animate-on-scroll hover-lift">
                <h5 class="fw-bold mb-3 d-flex align-items-center gap-2">
                    <i class="fas fa-building text-primary"></i>
                    Ban tổ chức
                </h5>
                <div class="d-flex align-items-start gap-3">
                    <div class="avatar-placeholder rounded-3" style="width: 64px; height: 64px; font-size: 1.5rem;">
                        ${not empty event.organizerName ? event.organizerName.substring(0, 1) : 'T'}
                    </div>
                    <div class="flex-grow-1">
                        <h6 class="fw-bold mb-1">${not empty event.organizerName ? event.organizerName : 'TK Entertainment'}</h6>
                        <small class="text-muted d-block mb-2">
                            Đơn vị tổ chức sự kiện âm nhạc hàng đầu Việt Nam với hơn 10 năm kinh nghiệm.
                        </small>
                        <div class="d-flex gap-2">
                            <span class="badge glass rounded-pill"><i class="fas fa-calendar-check me-1"></i>50+ sự kiện</span>
                            <span class="badge glass rounded-pill"><i class="fas fa-star me-1 text-warning"></i>4.9</span>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Ticket Types -->
            <div class="glass-strong p-4 rounded-4 animate-on-scroll">
                <h5 class="fw-bold mb-3 d-flex align-items-center gap-2">
                    <i class="fas fa-ticket-alt text-primary"></i>
                    Loại vé
                </h5>
                <div class="d-flex flex-column gap-3" data-stagger-children="0.1">
                    <!-- Ticket Type 1 -->
                    <div class="ticket-type d-flex align-items-center justify-content-between p-3 rounded-3 glass cursor-pointer animate-on-scroll"
                         onclick="selectTicket(this, 'regular')">
                        <div class="d-flex align-items-center gap-3">
                            <div class="rounded-3 d-flex align-items-center justify-content-center" 
                                 style="width: 48px; height: 48px; background: rgba(107, 114, 128, 0.1);">
                                <i class="fas fa-ticket-alt text-muted"></i>
                            </div>
                            <div>
                                <h6 class="fw-bold mb-1">Vé thường</h6>
                                <small class="text-muted">Ghế ngồi khu vực B, C</small>
                            </div>
                        </div>
                        <div class="text-end">
                            <h5 class="fw-bold text-primary mb-0">350.000 đ</h5>
                            <small class="text-success"><i class="fas fa-check-circle me-1"></i>Còn 500 vé</small>
                        </div>
                    </div>
                    
                    <!-- Ticket Type 2 -->
                    <div class="ticket-type d-flex align-items-center justify-content-between p-3 rounded-3 glass cursor-pointer animate-on-scroll"
                         onclick="selectTicket(this, 'vip')">
                        <div class="d-flex align-items-center gap-3">
                            <div class="rounded-3 d-flex align-items-center justify-content-center" 
                                 style="width: 48px; height: 48px; background: linear-gradient(135deg, rgba(147, 51, 234, 0.1), rgba(219, 39, 119, 0.1));">
                                <i class="fas fa-crown text-primary"></i>
                            </div>
                            <div>
                                <h6 class="fw-bold mb-1">Vé VIP <span class="badge badge-hot ms-2">HOT</span></h6>
                                <small class="text-muted">Ghế ngồi khu vực A + đồ uống</small>
                            </div>
                        </div>
                        <div class="text-end">
                            <h5 class="fw-bold text-primary mb-0">750.000 đ</h5>
                            <small class="text-warning"><i class="fas fa-exclamation-circle me-1"></i>Còn 100 vé</small>
                        </div>
                    </div>
                    
                    <!-- Ticket Type 3 -->
                    <div class="ticket-type d-flex align-items-center justify-content-between p-3 rounded-3 glass cursor-pointer animate-on-scroll"
                         onclick="selectTicket(this, 'vvip')">
                        <div class="d-flex align-items-center gap-3">
                            <div class="rounded-3 d-flex align-items-center justify-content-center" 
                                 style="width: 48px; height: 48px; background: linear-gradient(135deg, rgba(245, 158, 11, 0.2), rgba(239, 68, 68, 0.2));">
                                <i class="fas fa-gem text-warning"></i>
                            </div>
                            <div>
                                <h6 class="fw-bold mb-1">Vé VVIP <span class="badge badge-new ms-2">PREMIUM</span></h6>
                                <small class="text-muted">Hàng đầu + Giao lưu nghệ sĩ + Quà tặng</small>
                            </div>
                        </div>
                        <div class="text-end">
                            <h5 class="fw-bold text-primary mb-0">1.500.000 đ</h5>
                            <small class="text-danger"><i class="fas fa-fire me-1"></i>Chỉ còn 20 vé</small>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Sidebar - Sticky -->
        <div class="col-lg-4">
            <div class="sticky-top" style="top: 100px;">
                <div class="glass-strong p-4 rounded-4 animate-on-scroll">
                    <!-- Schedule Selection -->
                    <h5 class="fw-bold mb-3 d-flex align-items-center gap-2">
                        <i class="far fa-calendar text-primary"></i>
                        Chọn lịch diễn
                    </h5>
                    
                    <div class="d-flex flex-column gap-2 mb-4">
                        <button onclick="selectSchedule(this, 's1')" 
                                class="btn w-100 p-3 rounded-3 text-start schedule-btn active">
                            <div class="d-flex justify-content-between align-items-center">
                                <span class="fw-bold"><i class="far fa-calendar me-2"></i>20/03/2026</span>
                                <span class="badge bg-success bg-opacity-10 text-success rounded-pill">Còn vé</span>
                            </div>
                            <small class="d-block mt-1 ms-4 opacity-75">
                                <i class="far fa-clock me-1"></i>19:00 - 22:00
                            </small>
                        </button>
                        
                        <button onclick="selectSchedule(this, 's2')" 
                                class="btn w-100 p-3 rounded-3 text-start glass schedule-btn border">
                            <div class="d-flex justify-content-between align-items-center">
                                <span class="fw-bold"><i class="far fa-calendar me-2"></i>21/03/2026</span>
                                <span class="badge bg-warning bg-opacity-10 text-warning rounded-pill">Sắp hết</span>
                            </div>
                            <small class="d-block mt-1 ms-4 opacity-75">
                                <i class="far fa-clock me-1"></i>19:00 - 22:00
                            </small>
                        </button>

                        <button disabled 
                                class="btn w-100 p-3 rounded-3 text-start glass schedule-btn opacity-50">
                            <div class="d-flex justify-content-between align-items-center">
                                <span class="fw-bold"><i class="far fa-calendar me-2"></i>22/03/2026</span>
                                <span class="badge bg-danger bg-opacity-10 text-danger rounded-pill">Hết vé</span>
                            </div>
                            <small class="d-block mt-1 ms-4 opacity-75">
                                <i class="far fa-clock me-1"></i>19:00 - 22:00
                            </small>
                        </button>
                    </div>

                    <!-- Countdown -->
                    <div class="mb-4 p-3 rounded-3" style="background: linear-gradient(135deg, rgba(147, 51, 234, 0.05), rgba(219, 39, 119, 0.05));">
                        <p class="small text-muted mb-2 text-center">
                            <i class="fas fa-clock me-1"></i>Thời gian còn lại
                        </p>
                        <div class="d-flex justify-content-center gap-2" data-countdown="2026-03-20T19:00:00">
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
                    </div>

                    <!-- Price Range -->
                    <div class="d-flex align-items-center justify-content-between py-3 border-top border-bottom mb-3">
                        <span class="text-muted">Giá từ</span>
                        <h3 class="fw-bold mb-0 gradient-text-animate">
                            <c:choose>
                                <c:when test="${event.minPrice == 0}">Miễn phí</c:when>
                                <c:otherwise>${not empty event.minPrice ? event.minPrice : '350.000'} đ</c:otherwise>
                            </c:choose>
                        </h3>
                    </div>

                    <!-- Buy Button -->
                    <a href="${pageContext.request.contextPath}/ticket-selection?id=${event.id}" 
                       class="btn btn-gradient w-100 py-3 rounded-3 fw-bold text-white d-flex align-items-center justify-content-center gap-2 animate-pulse hover-glow">
                        <i class="fas fa-ticket-alt"></i>
                        Mua vé ngay
                        <i class="fas fa-chevron-right"></i>
                    </a>
                    
                    <!-- Security Note -->
                    <div class="text-center mt-3">
                        <small class="text-muted">
                            <i class="fas fa-shield-alt text-success me-1"></i>
                            Thanh toán an toàn & bảo mật
                        </small>
                    </div>
                </div>
                
                <!-- Related Events -->
                <div class="glass-strong p-4 rounded-4 mt-4 animate-on-scroll">
                    <h6 class="fw-bold mb-3">
                        <i class="fas fa-fire text-danger me-2"></i>Sự kiện tương tự
                    </h6>
                    <div class="d-flex flex-column gap-3">
                        <a href="#" class="d-flex gap-3 text-decoration-none text-dark hover-lift">
                            <img src="https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=100" 
                                 alt="Related" class="rounded-3" style="width: 60px; height: 60px; object-fit: cover;">
                            <div class="flex-grow-1">
                                <h6 class="fw-bold mb-1 small">Jazz Night Live</h6>
                                <small class="text-muted">25/03/2026</small>
                            </div>
                        </a>
                        <a href="#" class="d-flex gap-3 text-decoration-none text-dark hover-lift">
                            <img src="https://images.unsplash.com/photo-1501281668745-f7f57925c3b4?w=100" 
                                 alt="Related" class="rounded-3" style="width: 60px; height: 60px; object-fit: cover;">
                            <div class="flex-grow-1">
                                <h6 class="fw-bold mb-1 small">EDM Festival</h6>
                                <small class="text-muted">30/03/2026</small>
                            </div>
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
function toggleLike(btn) {
    const icon = btn.querySelector('i');
    if (icon.classList.contains('far')) {
        icon.classList.replace('far', 'fas');
        icon.classList.add('text-danger');
        btn.classList.add('animate-bounce');
        setTimeout(() => btn.classList.remove('animate-bounce'), 500);
    } else {
        icon.classList.replace('fas', 'far');
        icon.classList.remove('text-danger');
    }
}

function toggleShare() {
    const popup = document.getElementById('sharePopup');
    popup.classList.toggle('show');
}

function copyLink() {
    navigator.clipboard.writeText(window.location.href);
    showSuccess('Đã copy link vào clipboard!');
    toggleShare();
}

function selectSchedule(btn, scheduleId) {
    document.querySelectorAll('.schedule-btn').forEach(b => {
        b.classList.remove('active');
        if (!b.disabled) {
            b.classList.add('glass', 'border');
        }
    });
    
    btn.classList.add('active');
    btn.classList.remove('glass', 'border');
}

function selectTicket(el, type) {
    document.querySelectorAll('.ticket-type').forEach(t => {
        t.classList.remove('selected');
    });
    el.classList.add('selected');
}

// Close share popup when clicking outside
document.addEventListener('click', function(e) {
    if (!e.target.closest('.share-popup') && !e.target.closest('[onclick="toggleShare()"]')) {
        document.getElementById('sharePopup').classList.remove('show');
    }
});
</script>

<jsp:include page="footer.jsp" />
