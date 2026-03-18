<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>

<%-- Staff Sidebar Include - Pass 'activePage' parameter to highlight current page --%>
<div class="card glass-strong border-0 rounded-4 sticky-top" style="top: 80px;">
    <div class="card-body p-3">
        <div class="d-flex align-items-center gap-2 mb-3 px-2">
            <div class="dash-icon-box" style="width: 36px; height: 36px; background: linear-gradient(135deg, #10b981, #059669); border-radius: 10px;">
                <i class="fas fa-id-badge text-white" style="font-size: 0.85rem;"></i>
            </div>
            <div>
                <span class="fw-bold d-block" style="color: #10b981;">Staff Portal</span>
                <c:choose>
                    <c:when test="${not empty staffHighestRole}">
                        <c:choose>
                            <c:when test="${staffHighestRole == 'manager'}">
                                <span class="badge rounded-pill" style="font-size:0.65rem;background:rgba(16,185,129,0.15);color:#10b981;"><i class="fas fa-crown me-1"></i>Manager</span>
                            </c:when>
                            <c:when test="${staffHighestRole == 'scanner'}">
                                <span class="badge rounded-pill" style="font-size:0.65rem;background:rgba(59,130,246,0.15);color:#3b82f6;"><i class="fas fa-qrcode me-1"></i>Scanner</span>
                            </c:when>
                            <c:otherwise>
                                <span class="badge rounded-pill" style="font-size:0.65rem;background:rgba(107,114,128,0.15);color:#6b7280;"><i class="fas fa-user me-1"></i>Staff</span>
                            </c:otherwise>
                        </c:choose>
                    </c:when>
                </c:choose>
            </div>
        </div>
        <nav class="nav flex-column sidebar-nav gap-1">
            <a href="${pageContext.request.contextPath}/staff/dashboard" 
               class="nav-link rounded-3 d-flex align-items-center gap-2 ${param.activePage == 'dashboard' ? 'active' : ''}">
                <i class="fas fa-tachometer-alt" style="width: 20px; text-align: center;"></i>Dashboard
            </a>
            <a href="${pageContext.request.contextPath}/staff/check-in" 
               class="nav-link rounded-3 d-flex align-items-center gap-2 ${param.activePage == 'check-in' ? 'active' : ''}">
                <i class="fas fa-qrcode" style="width: 20px; text-align: center;"></i>Check-in
            </a>
            <a href="${pageContext.request.contextPath}/notifications" 
               class="nav-link rounded-3 d-flex align-items-center gap-2 ${param.activePage == 'notifications' ? 'active' : ''}">
                <i class="fas fa-bell" style="width: 20px; text-align: center;"></i>Thông báo
            </a>
            <hr class="my-2">
            <a href="${pageContext.request.contextPath}/" class="nav-link rounded-3 d-flex align-items-center gap-2 text-muted">
                <i class="fas fa-arrow-left" style="width: 20px; text-align: center;"></i>Về trang chủ
            </a>
        </nav>
    </div>
</div>
