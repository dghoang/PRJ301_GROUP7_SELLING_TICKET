<%-- 
    Custom Tag: Empty State
    Shows a styled empty state with icon and message.
    Usage: <tags:emptyState icon="inbox" title="Không có dữ liệu" message="..." />
--%>
<%@tag description="Empty State Display" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@attribute name="icon" required="false" type="java.lang.String" description="FontAwesome icon name (default: inbox)" %>
<%@attribute name="title" required="true" type="java.lang.String" %>
<%@attribute name="message" required="false" type="java.lang.String" %>
<%@attribute name="actionUrl" required="false" type="java.lang.String" %>
<%@attribute name="actionLabel" required="false" type="java.lang.String" %>

<c:set var="iconName" value="${empty icon ? 'inbox' : icon}" />

<div class="text-center py-5">
    <div class="d-inline-flex align-items-center justify-content-center rounded-circle mb-3"
         style="width: 72px; height: 72px; background: rgba(59,130,246,0.08);">
        <i class="fas fa-${iconName} fa-2x" style="color: #3b82f6; opacity: 0.5;"></i>
    </div>
    <h6 class="fw-bold mb-2"><c:out value="${title}" /></h6>
    <c:if test="${not empty message}">
        <p class="text-muted small mb-3" style="max-width: 360px; margin: 0 auto;"><c:out value="${message}" /></p>
    </c:if>
    <c:if test="${not empty actionUrl}">
        <a href="${actionUrl}" class="btn btn-gradient rounded-pill px-4 hover-glow">
            <c:out value="${empty actionLabel ? 'Bắt đầu' : actionLabel}" />
        </a>
    </c:if>
</div>
