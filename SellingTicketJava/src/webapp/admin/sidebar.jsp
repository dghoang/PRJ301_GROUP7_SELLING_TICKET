<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>

<%-- Admin Sidebar Include - Pass 'activePage' parameter to highlight current page --%>
<div class="card glass-strong border-0 rounded-4 sticky-top" style="top: 80px;">
    <div class="card-body p-3">
        <h6 class="fw-bold text-primary mb-3"><i class="fas fa-shield-alt me-2"></i>Admin</h6>
        <nav class="nav flex-column gap-1">
            <a href="${pageContext.request.contextPath}/admin" 
               class="nav-link rounded-3 ${param.activePage == 'dashboard' ? 'active bg-primary text-white' : 'text-dark'}">
                <i class="fas fa-tachometer-alt me-2"></i>Dashboard
            </a>
            <a href="${pageContext.request.contextPath}/admin/users" 
               class="nav-link rounded-3 ${param.activePage == 'users' ? 'active bg-primary text-white' : 'text-dark'}">
                <i class="fas fa-users me-2"></i>Người dùng
            </a>
            <a href="${pageContext.request.contextPath}/admin/events" 
               class="nav-link rounded-3 ${param.activePage == 'events' ? 'active bg-primary text-white' : 'text-dark'}">
                <i class="fas fa-calendar me-2"></i>Sự kiện
            </a>
            <a href="${pageContext.request.contextPath}/admin/event-approval" 
               class="nav-link rounded-3 ${param.activePage == 'event-approval' ? 'active bg-primary text-white' : 'text-dark'}">
                <i class="fas fa-check-circle me-2"></i>Duyệt sự kiện
            </a>
            <a href="${pageContext.request.contextPath}/admin/categories" 
               class="nav-link rounded-3 ${param.activePage == 'categories' ? 'active bg-primary text-white' : 'text-dark'}">
                <i class="fas fa-tags me-2"></i>Danh mục
            </a>
            <a href="${pageContext.request.contextPath}/admin/reports" 
               class="nav-link rounded-3 ${param.activePage == 'reports' ? 'active bg-primary text-white' : 'text-dark'}">
                <i class="fas fa-chart-bar me-2"></i>Báo cáo
            </a>
            <a href="${pageContext.request.contextPath}/admin/settings" 
               class="nav-link rounded-3 ${param.activePage == 'settings' ? 'active bg-primary text-white' : 'text-dark'}">
                <i class="fas fa-cog me-2"></i>Cài đặt
            </a>
        </nav>
    </div>
</div>
