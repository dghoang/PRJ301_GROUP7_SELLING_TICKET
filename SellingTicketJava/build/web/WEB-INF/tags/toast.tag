<%-- 
    Custom Tag: Toast Message Display
    Shows flash/toast messages from session with auto-dismiss.
    Usage: <tags:toast />
--%>
<%@tag description="Flash Toast Message Display" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>

<c:if test="${not empty sessionScope.toastMessage}">
    <div class="alert glass-strong border-0 rounded-4 alert-dismissible fade show mb-4 animate-fadeInDown" role="alert"
         style="background: rgba(${sessionScope.toastType == 'success' ? '16,185,129' : sessionScope.toastType == 'warning' ? '245,158,11' : '239,68,68'},0.1); 
                border-left: 4px solid ${sessionScope.toastType == 'success' ? '#10b981' : sessionScope.toastType == 'warning' ? '#f59e0b' : '#ef4444'} !important;">
        <div class="d-flex align-items-center gap-2">
            <c:choose>
                <c:when test="${sessionScope.toastType == 'success'}">
                    <i class="fas fa-check-circle text-success fs-5"></i>
                </c:when>
                <c:when test="${sessionScope.toastType == 'warning'}">
                    <i class="fas fa-exclamation-triangle text-warning fs-5"></i>
                </c:when>
                <c:otherwise>
                    <i class="fas fa-exclamation-circle text-danger fs-5"></i>
                </c:otherwise>
            </c:choose>
            <span class="fw-medium">${sessionScope.toastMessage}</span>
        </div>
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    </div>
    <c:remove var="toastMessage" scope="session"/>
    <c:remove var="toastType" scope="session"/>
</c:if>
