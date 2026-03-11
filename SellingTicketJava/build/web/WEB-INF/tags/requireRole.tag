<%-- 
    Custom Tag: Permission Gate
    Conditionally renders content based on user role and event permissions.
    Usage: <tags:requireRole role="admin,organizer">Protected content</tags:requireRole>
--%>
<%@tag description="Role-based content gate" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@attribute name="role" required="true" type="java.lang.String" description="Comma-separated allowed roles: admin,organizer,customer" %>
<%@attribute name="negate" required="false" type="java.lang.Boolean" description="If true, shows content when user does NOT have the role" %>

<c:set var="userRole" value="${sessionScope.user.role}" />
<c:set var="hasRole" value="false" />
<c:forTokens var="r" items="${role}" delims=",">
    <c:if test="${r == userRole}">
        <c:set var="hasRole" value="true" />
    </c:if>
</c:forTokens>

<c:choose>
    <c:when test="${negate}">
        <c:if test="${!hasRole}">
            <jsp:doBody />
        </c:if>
    </c:when>
    <c:otherwise>
        <c:if test="${hasRole}">
            <jsp:doBody />
        </c:if>
    </c:otherwise>
</c:choose>
