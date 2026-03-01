<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>

<%-- Admin Sidebar Include - Pass 'activePage' parameter to highlight current page --%>
<div class="card glass-strong border-0 rounded-4 sticky-top" style="top: 80px;">
    <div class="card-body p-3">
        <div class="d-flex align-items-center gap-2 mb-3 px-2">
            <div class="dash-icon-box" style="width: 36px; height: 36px; background: linear-gradient(135deg, var(--primary), var(--secondary)); border-radius: 10px;">
                <i class="fas fa-shield-alt text-white" style="font-size: 0.85rem;"></i>
            </div>
            <span class="fw-bold text-primary">Admin Panel</span>
        </div>
        <nav class="nav flex-column sidebar-nav gap-1">
            <a href="${pageContext.request.contextPath}/admin" 
               class="nav-link rounded-3 d-flex align-items-center gap-2 ${param.activePage == 'dashboard' ? 'active' : ''}">
                <i class="fas fa-tachometer-alt" style="width: 20px; text-align: center;"></i>Dashboard
            </a>
            <a href="${pageContext.request.contextPath}/admin/users" 
               class="nav-link rounded-3 d-flex align-items-center gap-2 ${param.activePage == 'users' ? 'active' : ''}">
                <i class="fas fa-users" style="width: 20px; text-align: center;"></i>Người dùng
            </a>
            <a href="${pageContext.request.contextPath}/admin/events" 
               class="nav-link rounded-3 d-flex align-items-center gap-2 ${param.activePage == 'events' ? 'active' : ''}">
                <i class="fas fa-calendar" style="width: 20px; text-align: center;"></i>Sự kiện
            </a>
            <a href="${pageContext.request.contextPath}/admin/event-approval" 
               class="nav-link rounded-3 d-flex align-items-center gap-2 ${param.activePage == 'event-approval' ? 'active' : ''}">
                <i class="fas fa-check-circle" style="width: 20px; text-align: center;"></i>Duyệt sự kiện
                <c:if test="${pendingCount != null && pendingCount > 0}">
                    <span class="badge rounded-pill ms-auto" style="background: linear-gradient(135deg, #ef4444, #f97316); font-size: 0.65rem;">${pendingCount}</span>
                </c:if>
            </a>
            <a href="${pageContext.request.contextPath}/admin/categories" 
               class="nav-link rounded-3 d-flex align-items-center gap-2 ${param.activePage == 'categories' ? 'active' : ''}">
                <i class="fas fa-tags" style="width: 20px; text-align: center;"></i>Danh mục
            </a>
            <a href="${pageContext.request.contextPath}/admin/orders" 
               class="nav-link rounded-3 d-flex align-items-center gap-2 ${param.activePage == 'orders' ? 'active' : ''}">
                <i class="fas fa-shopping-bag" style="width: 20px; text-align: center;"></i>Đơn hàng
            </a>
            <a href="${pageContext.request.contextPath}/admin/reports" 
               class="nav-link rounded-3 d-flex align-items-center gap-2 ${param.activePage == 'reports' ? 'active' : ''}">
                <i class="fas fa-chart-bar" style="width: 20px; text-align: center;"></i>Báo cáo
            </a>
            <a href="${pageContext.request.contextPath}/admin/settings" 
               class="nav-link rounded-3 d-flex align-items-center gap-2 ${param.activePage == 'settings' ? 'active' : ''}">
                <i class="fas fa-cog" style="width: 20px; text-align: center;"></i>Cài đặt
            </a>
        </nav>
    </div>
</div>
