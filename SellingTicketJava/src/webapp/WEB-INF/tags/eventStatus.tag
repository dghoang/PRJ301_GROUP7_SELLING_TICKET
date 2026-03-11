<%-- 
    Custom Tag: Event Status Badge
    Displays a styled status badge based on event status.
    Usage: <tags:eventStatus status="${event.status}" />
--%>
<%@tag description="Event Status Badge" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@attribute name="status" required="true" type="java.lang.String" %>
<%@attribute name="size" required="false" type="java.lang.String" description="sm|md|lg, default md" %>

<c:set var="badgeSize" value="${empty size ? 'md' : size}" />
<c:set var="sizeClass" value="${badgeSize == 'sm' ? 'px-2 py-1 small' : badgeSize == 'lg' ? 'px-4 py-2 fs-6' : 'px-3 py-2'}" />

<c:choose>
    <c:when test="${status == 'approved'}">
        <span class="badge rounded-pill ${sizeClass}" style="background: rgba(16,185,129,0.15); color: #059669;">
            <i class="fas fa-check-circle me-1"></i>Đã duyệt
        </span>
    </c:when>
    <c:when test="${status == 'pending'}">
        <span class="badge rounded-pill ${sizeClass}" style="background: rgba(245,158,11,0.15); color: #d97706;">
            <i class="fas fa-clock me-1"></i>Chờ duyệt
        </span>
    </c:when>
    <c:when test="${status == 'draft'}">
        <span class="badge rounded-pill ${sizeClass}" style="background: rgba(107,114,128,0.15); color: #6b7280;">
            <i class="fas fa-pencil-alt me-1"></i>Bản nháp
        </span>
    </c:when>
    <c:when test="${status == 'rejected'}">
        <span class="badge rounded-pill ${sizeClass}" style="background: rgba(239,68,68,0.15); color: #dc2626;">
            <i class="fas fa-times-circle me-1"></i>Từ chối
        </span>
    </c:when>
    <c:when test="${status == 'cancelled'}">
        <span class="badge rounded-pill ${sizeClass}" style="background: rgba(107,114,128,0.15); color: #6b7280;">
            <i class="fas fa-ban me-1"></i>Đã hủy
        </span>
    </c:when>
    <c:when test="${status == 'ended' || status == 'completed'}">
        <span class="badge rounded-pill ${sizeClass}" style="background: rgba(59,130,246,0.15); color: #2563eb;">
            <i class="fas fa-flag-checkered me-1"></i>Đã kết thúc
        </span>
    </c:when>
    <c:otherwise>
        <span class="badge rounded-pill ${sizeClass}" style="background: rgba(107,114,128,0.1); color: #6b7280;">
            <i class="fas fa-question-circle me-1"></i>${status}
        </span>
    </c:otherwise>
</c:choose>
