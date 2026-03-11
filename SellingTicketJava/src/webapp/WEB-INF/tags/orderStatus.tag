<%-- 
    Custom Tag: Order Status Badge
    Displays a styled status badge based on order status.
    Usage: <tags:orderStatus status="${order.status}" />
--%>
<%@tag description="Order Status Badge" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@attribute name="status" required="true" type="java.lang.String" %>
<%@attribute name="size" required="false" type="java.lang.String" %>

<c:set var="sizeClass" value="${size == 'sm' ? 'px-2 py-1 small' : size == 'lg' ? 'px-4 py-2 fs-6' : 'px-3 py-2'}" />

<c:choose>
    <c:when test="${status == 'paid'}">
        <span class="badge rounded-pill ${sizeClass}" style="background: rgba(16,185,129,0.15); color: #059669;">
            <i class="fas fa-check-circle me-1"></i>Đã thanh toán
        </span>
    </c:when>
    <c:when test="${status == 'pending'}">
        <span class="badge rounded-pill ${sizeClass}" style="background: rgba(245,158,11,0.15); color: #d97706;">
            <i class="fas fa-hourglass-half me-1"></i>Chờ thanh toán
        </span>
    </c:when>
    <c:when test="${status == 'cancelled'}">
        <span class="badge rounded-pill ${sizeClass}" style="background: rgba(239,68,68,0.15); color: #dc2626;">
            <i class="fas fa-times-circle me-1"></i>Đã hủy
        </span>
    </c:when>
    <c:when test="${status == 'refunded'}">
        <span class="badge rounded-pill ${sizeClass}" style="background: rgba(139,92,246,0.15); color: #7c3aed;">
            <i class="fas fa-undo me-1"></i>Đã hoàn tiền
        </span>
    </c:when>
    <c:when test="${status == 'refund_requested'}">
        <span class="badge rounded-pill ${sizeClass}" style="background: rgba(245,158,11,0.15); color: #d97706;">
            <i class="fas fa-hand-holding-usd me-1"></i>Yêu cầu hoàn
        </span>
    </c:when>
    <c:when test="${status == 'checked_in'}">
        <span class="badge rounded-pill ${sizeClass}" style="background: rgba(6,182,212,0.15); color: #0891b2;">
            <i class="fas fa-door-open me-1"></i>Đã check-in
        </span>
    </c:when>
    <c:otherwise>
        <span class="badge rounded-pill ${sizeClass}" style="background: rgba(107,114,128,0.1); color: #6b7280;">
            ${status}
        </span>
    </c:otherwise>
</c:choose>
