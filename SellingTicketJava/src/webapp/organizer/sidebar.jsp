<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>

<%-- Organizer Sidebar Include --%>
<div class="card glass-strong border-0 rounded-4 sticky-top" style="top: 80px;">
    <div class="card-body p-3">
        <div class="d-flex align-items-center gap-2 mb-3 px-2">
            <div class="dash-icon-box" style="width: 36px; height: 36px; background: linear-gradient(135deg, #10b981, #06b6d4); border-radius: 10px;">
                <i class="fas fa-microphone-alt text-white" style="font-size: 0.85rem;"></i>
            </div>
            <span class="fw-bold" style="color: #10b981;">Organizer</span>
        </div>
        <nav class="nav flex-column sidebar-nav gap-1">
            <a href="${pageContext.request.contextPath}/organizer" 
               class="nav-link rounded-3 d-flex align-items-center gap-2 ${param.activePage == 'dashboard' ? 'active' : ''}">
                <i class="fas fa-tachometer-alt" style="width: 20px; text-align: center;"></i>Dashboard
            </a>
            <a href="${pageContext.request.contextPath}/organizer/events" 
               class="nav-link rounded-3 d-flex align-items-center gap-2 ${param.activePage == 'events' ? 'active' : ''}">
                <i class="fas fa-calendar" style="width: 20px; text-align: center;"></i>Sự kiện
            </a>
            <a href="${pageContext.request.contextPath}/organizer/create-event" 
               class="nav-link rounded-3 d-flex align-items-center gap-2 ${param.activePage == 'create-event' ? 'active' : ''}">
                <i class="fas fa-plus-circle" style="width: 20px; text-align: center;"></i>Tạo sự kiện
            </a>
            <a href="${pageContext.request.contextPath}/organizer/orders" 
               class="nav-link rounded-3 d-flex align-items-center gap-2 ${param.activePage == 'orders' ? 'active' : ''}">
                <i class="fas fa-shopping-cart" style="width: 20px; text-align: center;"></i>Đơn hàng
                <span class="badge rounded-pill ms-auto" style="background: linear-gradient(135deg, #f59e0b, #f97316); font-size: 0.65rem;">5</span>
            </a>
            <a href="${pageContext.request.contextPath}/organizer/tickets" 
               class="nav-link rounded-3 d-flex align-items-center gap-2 ${param.activePage == 'tickets' ? 'active' : ''}">
                <i class="fas fa-ticket-alt" style="width: 20px; text-align: center;"></i>Vé
            </a>
            <a href="${pageContext.request.contextPath}/organizer/vouchers" 
               class="nav-link rounded-3 d-flex align-items-center gap-2 ${param.activePage == 'vouchers' ? 'active' : ''}">
                <i class="fas fa-tags" style="width: 20px; text-align: center;"></i>Voucher
            </a>
            <a href="${pageContext.request.contextPath}/organizer/check-in" 
               class="nav-link rounded-3 d-flex align-items-center gap-2 ${param.activePage == 'check-in' ? 'active' : ''}">
                <i class="fas fa-qrcode" style="width: 20px; text-align: center;"></i>Check-in
            </a>
            <a href="${pageContext.request.contextPath}/organizer/statistics" 
               class="nav-link rounded-3 d-flex align-items-center gap-2 ${param.activePage == 'statistics' ? 'active' : ''}">
                <i class="fas fa-chart-line" style="width: 20px; text-align: center;"></i>Thống kê
            </a>
            <a href="${pageContext.request.contextPath}/organizer/team" 
               class="nav-link rounded-3 d-flex align-items-center gap-2 ${param.activePage == 'team' ? 'active' : ''}">
                <i class="fas fa-user-friends" style="width: 20px; text-align: center;"></i>Đội ngũ
            </a>
            <a href="${pageContext.request.contextPath}/organizer/settings" 
               class="nav-link rounded-3 d-flex align-items-center gap-2 ${param.activePage == 'settings' ? 'active' : ''}">
                <i class="fas fa-cog" style="width: 20px; text-align: center;"></i>Cài đặt
            </a>
        </nav>
    </div>
</div>
