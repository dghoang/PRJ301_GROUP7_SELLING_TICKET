<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>

<style>
.organizer-sidebar {
    background: rgba(255,255,255,0.7);
    backdrop-filter: blur(16px);
    border: 1px solid rgba(255,255,255,0.5);
    border-radius: var(--radius-xl);
    padding: 1rem 0.75rem;
    position: sticky;
    top: 92px;
}
.sidebar-section-title {
    font-size: 0.65rem;
    text-transform: uppercase;
    letter-spacing: 0.1em;
    color: var(--text-light);
    font-weight: 600;
    padding: 0.5rem 0.75rem 0.25rem;
}
.organizer-sidebar .nav-link {
    display: flex;
    align-items: center;
    gap: 0.75rem;
    padding: 0.6rem 0.75rem !important;
    border-radius: var(--radius-sm) !important;
    color: var(--text-muted) !important;
    font-weight: 500;
    font-size: 0.85rem;
    transition: all 0.2s;
    margin-bottom: 2px;
    border-bottom: none !important;
    position: relative;
}
.organizer-sidebar .nav-link::after { display: none !important; }
.organizer-sidebar .nav-link:hover {
    background: rgba(147,51,234,0.06);
    color: var(--primary) !important;
}
.organizer-sidebar .nav-link.active {
    background: linear-gradient(135deg, var(--primary), var(--secondary)) !important;
    color: white !important;
    box-shadow: 0 4px 12px rgba(147,51,234,0.25);
}
.organizer-sidebar .nav-link .sidebar-icon {
    width: 28px;
    height: 28px;
    display: flex;
    align-items: center;
    justify-content: center;
    border-radius: 8px;
    font-size: 0.8rem;
    flex-shrink: 0;
}
.organizer-sidebar .nav-link:not(.active) .sidebar-icon {
    background: rgba(0,0,0,0.04);
}
.organizer-sidebar .nav-link.active .sidebar-icon {
    background: rgba(255,255,255,0.2);
}
.sidebar-divider {
    height: 1px;
    background: rgba(0,0,0,0.06);
    margin: 0.5rem 0.75rem;
}

/* Mobile toggle */
.sidebar-toggle-mobile {
    display: none;
    position: fixed;
    bottom: 1.5rem; left: 1.5rem;
    z-index: 1040;
    width: 48px; height: 48px;
    border-radius: 50%;
    background: linear-gradient(135deg, var(--primary), var(--secondary));
    color: white;
    border: none;
    box-shadow: 0 8px 24px rgba(147,51,234,0.35);
    font-size: 1.2rem;
}
@media (max-width: 991.98px) {
    .sidebar-toggle-mobile { display: flex !important; align-items: center; justify-content: center; }
}
</style>

<!-- Mobile Toggle -->
<button class="sidebar-toggle-mobile d-lg-none" type="button" data-bs-toggle="offcanvas" data-bs-target="#sidebarOffcanvas">
    <i class="fas fa-bars"></i>
</button>

<!-- Desktop Sidebar -->
<div class="organizer-sidebar d-none d-lg-block">
    <div class="sidebar-section-title">Sự kiện</div>
    <nav class="sidebar-nav nav flex-column">
        <a class="nav-link ${param.activePage == 'dashboard' ? 'active' : ''}" href="${pageContext.request.contextPath}/organizer/dashboard">
            <span class="sidebar-icon"><i class="fas fa-th-large"></i></span>Dashboard
        </a>
        <a class="nav-link ${param.activePage == 'events' ? 'active' : ''}" href="${pageContext.request.contextPath}/organizer/events">
            <span class="sidebar-icon"><i class="fas fa-calendar-alt"></i></span>Sự kiện
        </a>
        <a class="nav-link ${param.activePage == 'create-event' ? 'active' : ''}" href="${pageContext.request.contextPath}/organizer/create-event">
            <span class="sidebar-icon"><i class="fas fa-plus-circle"></i></span>Tạo mới
        </a>
    </nav>

    <div class="sidebar-divider"></div>
    <div class="sidebar-section-title">Vận hành</div>
    <nav class="sidebar-nav nav flex-column">
        <a class="nav-link ${param.activePage == 'orders' ? 'active' : ''}" href="${pageContext.request.contextPath}/organizer/orders">
            <span class="sidebar-icon"><i class="fas fa-shopping-bag"></i></span>Đơn hàng
        </a>
        <a class="nav-link ${param.activePage == 'tickets' ? 'active' : ''}" href="${pageContext.request.contextPath}/organizer/tickets">
            <span class="sidebar-icon"><i class="fas fa-ticket-alt"></i></span>Vé
        </a>
        <a class="nav-link ${param.activePage == 'checkin' ? 'active' : ''}" href="${pageContext.request.contextPath}/organizer/check-in">
            <span class="sidebar-icon"><i class="fas fa-qrcode"></i></span>Check-in
        </a>
        <a class="nav-link ${param.activePage == 'vouchers' ? 'active' : ''}" href="${pageContext.request.contextPath}/organizer/vouchers">
            <span class="sidebar-icon"><i class="fas fa-gift"></i></span>Voucher
        </a>
    </nav>

    <div class="sidebar-divider"></div>
    <div class="sidebar-section-title">Phân tích</div>
    <nav class="sidebar-nav nav flex-column">
        <a class="nav-link ${param.activePage == 'statistics' ? 'active' : ''}" href="${pageContext.request.contextPath}/organizer/statistics">
            <span class="sidebar-icon"><i class="fas fa-chart-line"></i></span>Thống kê
        </a>
        <a class="nav-link ${param.activePage == 'team' ? 'active' : ''}" href="${pageContext.request.contextPath}/organizer/team">
            <span class="sidebar-icon"><i class="fas fa-users"></i></span>Nhân sự
        </a>
        <a class="nav-link ${param.activePage == 'settings' ? 'active' : ''}" href="${pageContext.request.contextPath}/organizer/settings">
            <span class="sidebar-icon"><i class="fas fa-cog"></i></span>Cài đặt
        </a>
    </nav>
</div>

<!-- Mobile Offcanvas -->
<div class="offcanvas offcanvas-start d-lg-none" tabindex="-1" id="sidebarOffcanvas"
     style="width:280px; background: rgba(255,255,255,0.95); backdrop-filter: blur(20px);">
    <div class="offcanvas-header border-0">
        <h6 class="offcanvas-title fw-bold">
            <span class="text-gradient">Organizer</span>
        </h6>
        <button type="button" class="btn-close" data-bs-dismiss="offcanvas"></button>
    </div>
    <div class="offcanvas-body p-2">
        <div class="sidebar-section-title">Sự kiện</div>
        <nav class="nav flex-column sidebar-nav">
            <a class="nav-link ${param.activePage == 'dashboard' ? 'active' : ''}" href="${pageContext.request.contextPath}/organizer/dashboard">
                <span class="sidebar-icon"><i class="fas fa-th-large"></i></span>Dashboard
            </a>
            <a class="nav-link ${param.activePage == 'events' ? 'active' : ''}" href="${pageContext.request.contextPath}/organizer/events">
                <span class="sidebar-icon"><i class="fas fa-calendar-alt"></i></span>Sự kiện
            </a>
            <a class="nav-link ${param.activePage == 'create-event' ? 'active' : ''}" href="${pageContext.request.contextPath}/organizer/create-event">
                <span class="sidebar-icon"><i class="fas fa-plus-circle"></i></span>Tạo mới
            </a>
        </nav>
        <div class="sidebar-divider"></div>
        <div class="sidebar-section-title">Vận hành</div>
        <nav class="nav flex-column sidebar-nav">
            <a class="nav-link ${param.activePage == 'orders' ? 'active' : ''}" href="${pageContext.request.contextPath}/organizer/orders">
                <span class="sidebar-icon"><i class="fas fa-shopping-bag"></i></span>Đơn hàng
            </a>
            <a class="nav-link ${param.activePage == 'tickets' ? 'active' : ''}" href="${pageContext.request.contextPath}/organizer/tickets">
                <span class="sidebar-icon"><i class="fas fa-ticket-alt"></i></span>Vé
            </a>
            <a class="nav-link ${param.activePage == 'checkin' ? 'active' : ''}" href="${pageContext.request.contextPath}/organizer/check-in">
                <span class="sidebar-icon"><i class="fas fa-qrcode"></i></span>Check-in
            </a>
            <a class="nav-link ${param.activePage == 'vouchers' ? 'active' : ''}" href="${pageContext.request.contextPath}/organizer/vouchers">
                <span class="sidebar-icon"><i class="fas fa-gift"></i></span>Voucher
            </a>
        </nav>
        <div class="sidebar-divider"></div>
        <div class="sidebar-section-title">Phân tích</div>
        <nav class="nav flex-column sidebar-nav">
            <a class="nav-link ${param.activePage == 'statistics' ? 'active' : ''}" href="${pageContext.request.contextPath}/organizer/statistics">
                <span class="sidebar-icon"><i class="fas fa-chart-line"></i></span>Thống kê
            </a>
            <a class="nav-link ${param.activePage == 'team' ? 'active' : ''}" href="${pageContext.request.contextPath}/organizer/team">
                <span class="sidebar-icon"><i class="fas fa-users"></i></span>Nhân sự
            </a>
            <a class="nav-link ${param.activePage == 'settings' ? 'active' : ''}" href="${pageContext.request.contextPath}/organizer/settings">
                <span class="sidebar-icon"><i class="fas fa-cog"></i></span>Cài đặt
            </a>
        </nav>
    </div>
</div>
