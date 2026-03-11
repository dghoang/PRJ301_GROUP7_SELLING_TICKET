<%-- 
    Custom Tag: CSRF Hidden Field
    Outputs a hidden CSRF token input for forms.
    Usage: <tags:csrf />
--%>
<%@tag description="CSRF Token Hidden Input" pageEncoding="UTF-8"%>
<input type="hidden" name="csrf_token" value="${sessionScope.csrf_token}" />
