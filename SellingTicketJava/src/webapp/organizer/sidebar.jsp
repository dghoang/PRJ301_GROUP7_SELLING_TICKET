<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>

<%-- Organizer Sidebar Include - Pass 'activePage' parameter to highlight current page --%>
<div class="card glass-strong border-0 rounded-4 sticky-top" style="top: 80px;">
    <div class="card-body p-3">
        <h6 class="fw-bold text-primary mb-3"><i class="fas fa-store me-2"></i>Organizer</h6>
        <nav class="nav flex-column gap-1">
            <a href="${pageContext.request.contextPath}/organizer" 
               class="nav-link rounded-3 ${param.activePage == 'dashboard' ? 'active bg-primary text-white' : 'text-dark'}">
                <i class="fas fa-tachometer-alt me-2"></i>Dashboard
            </a>
            <a href="${pageContext.request.contextPath}/organizer/create-event" 
               class="nav-link rounded-3 ${param.activePage == 'create-event' ? 'active bg-primary text-white' : 'text-dark'}">
                <i class="fas fa-plus-circle me-2"></i>Tạo sự kiện
            </a>
            <a href="${pageContext.request.contextPath}/organizer/events" 
               class="nav-link rounded-3 ${param.activePage == 'events' ? 'active bg-primary text-white' : 'text-dark'}">
                <i class="fas fa-calendar me-2"></i>Sự kiện của tôi
            </a>
            <a href="${pageContext.request.contextPath}/organizer/tickets" 
               class="nav-link rounded-3 ${param.activePage == 'tickets' ? 'active bg-primary text-white' : 'text-dark'}">
                <i class="fas fa-ticket-alt me-2"></i>Quản lý vé
            </a>
            <a href="${pageContext.request.contextPath}/organizer/orders" 
               class="nav-link rounded-3 ${param.activePage == 'orders' ? 'active bg-primary text-white' : 'text-dark'}">
                <i class="fas fa-shopping-cart me-2"></i>Đơn hàng
            </a>
            <a href="${pageContext.request.contextPath}/organizer/vouchers" 
               class="nav-link rounded-3 ${param.activePage == 'vouchers' ? 'active bg-primary text-white' : 'text-dark'}">
                <i class="fas fa-tag me-2"></i>Vouchers
            </a>
            <a href="${pageContext.request.contextPath}/organizer/statistics" 
               class="nav-link rounded-3 ${param.activePage == 'statistics' ? 'active bg-primary text-white' : 'text-dark'}">
                <i class="fas fa-chart-line me-2"></i>Thống kê
            </a>
            <a href="${pageContext.request.contextPath}/organizer/check-in" 
               class="nav-link rounded-3 ${param.activePage == 'check-in' ? 'active bg-primary text-white' : 'text-dark'}">
                <i class="fas fa-qrcode me-2"></i>Check-in
            </a>
            <a href="${pageContext.request.contextPath}/organizer/team" 
               class="nav-link rounded-3 ${param.activePage == 'team' ? 'active bg-primary text-white' : 'text-dark'}">
                <i class="fas fa-users me-2"></i>Điều hành viên
            </a>
            <a href="${pageContext.request.contextPath}/organizer/settings" 
               class="nav-link rounded-3 ${param.activePage == 'settings' ? 'active bg-primary text-white' : 'text-dark'}">
                <i class="fas fa-cog me-2"></i>Cài đặt
            </a>
        </nav>
    </div>
</div>
