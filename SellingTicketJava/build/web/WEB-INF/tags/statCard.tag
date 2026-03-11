<%-- 
    Custom Tag: Stat Card
    Reusable dashboard statistic card.
    Usage: <tags:statCard icon="ticket-alt" label="Tổng vé" value="1234" color="primary" />
--%>
<%@tag description="Dashboard Stat Card" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@attribute name="icon" required="true" type="java.lang.String" %>
<%@attribute name="label" required="true" type="java.lang.String" %>
<%@attribute name="value" required="true" type="java.lang.String" %>
<%@attribute name="color" required="false" type="java.lang.String" description="primary|success|warning|danger|info" %>
<%@attribute name="trend" required="false" type="java.lang.String" description="+12% or -5%" %>

<c:set var="clr" value="${empty color ? 'primary' : color}" />
<c:set var="gradients" value="${clr == 'success' ? '16,185,129' : clr == 'warning' ? '245,158,11' : clr == 'danger' ? '239,68,68' : clr == 'info' ? '6,182,212' : '59,130,246'}" />

<div class="card glass-strong border-0 rounded-4 h-100 animate-on-scroll">
    <div class="card-body p-4">
        <div class="d-flex align-items-center justify-content-between mb-3">
            <div class="rounded-3 d-flex align-items-center justify-content-center"
                 style="width: 48px; height: 48px; background: rgba(${gradients}, 0.12);">
                <i class="fas fa-${icon}" style="color: rgb(${gradients}); font-size: 1.2rem;"></i>
            </div>
            <c:if test="${not empty trend}">
                <span class="badge rounded-pill px-2 py-1 small" 
                      style="background: rgba(${fn:startsWith(trend, '+') ? '16,185,129' : '239,68,68'}, 0.1); 
                             color: ${fn:startsWith(trend, '+') ? '#059669' : '#dc2626'};">
                    <i class="fas fa-arrow-${fn:startsWith(trend, '+') ? 'up' : 'down'} me-1"></i>${trend}
                </span>
            </c:if>
        </div>
        <div class="fs-3 fw-bold mb-1">${value}</div>
        <div class="text-muted small">${label}</div>
    </div>
</div>
