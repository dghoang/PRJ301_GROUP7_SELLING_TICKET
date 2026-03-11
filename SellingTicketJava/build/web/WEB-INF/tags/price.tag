<%-- 
    Custom Tag: Price Format
    Formats a price as Vietnamese currency (VND).
    Usage: <tags:price value="${ticketType.price}" />
--%>
<%@tag description="Vietnamese Price Formatter" pageEncoding="UTF-8"%>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@attribute name="value" required="true" type="java.lang.Double" %>
<%@attribute name="showFree" required="false" type="java.lang.Boolean" description="Show 'Miễn phí' when price is 0" %>

<c:choose xmlns:c="jakarta.tags.core">
    <c:when test="${showFree && (value == null || value == 0)}">
        <span class="text-success fw-bold">Miễn phí</span>
    </c:when>
    <c:otherwise>
        <fmt:formatNumber value="${value}" pattern="#,###" /> đ
    </c:otherwise>
</c:choose>
