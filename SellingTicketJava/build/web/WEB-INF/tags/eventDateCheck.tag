<%-- 
    Custom Tag: Event Date Validator
    Shows warning/error if event is in the past or about to expire.
    Usage: <tags:eventDateCheck event="${event}" />
--%>
<%@tag description="Event Date Check" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@attribute name="event" required="true" type="com.sellingticket.model.Event" %>
<%@attribute name="showCountdown" required="false" type="java.lang.Boolean" %>

<jsp:useBean id="now" class="java.util.Date" />

<c:choose>
    <c:when test="${event.endDate != null && event.endDate.time < now.time}">
        <div class="alert border-0 rounded-4 mb-3" style="background: rgba(239,68,68,0.08); border-left: 4px solid #ef4444 !important;">
            <div class="d-flex align-items-center gap-2">
                <i class="fas fa-exclamation-triangle text-danger"></i>
                <div>
                    <strong class="text-danger">Sự kiện đã kết thúc</strong>
                    <p class="text-muted small mb-0">Kết thúc: <fmt:formatDate value="${event.endDate}" pattern="dd/MM/yyyy HH:mm" /></p>
                </div>
            </div>
        </div>
    </c:when>
    <c:when test="${event.startDate != null && event.startDate.time < now.time && (event.endDate == null || event.endDate.time >= now.time)}">
        <div class="alert border-0 rounded-4 mb-3" style="background: rgba(16,185,129,0.08); border-left: 4px solid #10b981 !important;">
            <div class="d-flex align-items-center gap-2">
                <i class="fas fa-play-circle text-success"></i>
                <div>
                    <strong class="text-success">Sự kiện đang diễn ra</strong>
                    <c:if test="${event.endDate != null}">
                        <p class="text-muted small mb-0">Kết thúc: <fmt:formatDate value="${event.endDate}" pattern="dd/MM/yyyy HH:mm" /></p>
                    </c:if>
                </div>
            </div>
        </div>
    </c:when>
    <c:when test="${event.startDate != null && event.startDate.time >= now.time}">
        <div class="alert border-0 rounded-4 mb-3" style="background: rgba(59,130,246,0.08); border-left: 4px solid #3b82f6 !important;">
            <div class="d-flex align-items-center gap-2">
                <i class="fas fa-calendar-check text-primary"></i>
                <div>
                    <strong class="text-primary">Sự kiện sắp diễn ra</strong>
                    <p class="text-muted small mb-0">Bắt đầu: <fmt:formatDate value="${event.startDate}" pattern="dd/MM/yyyy HH:mm" /></p>
                </div>
            </div>
        </div>
        <c:if test="${showCountdown}">
            <div class="text-center mb-3" id="eventCountdown" data-start="${event.startDate.time}">
                <span class="badge rounded-pill px-3 py-2" style="background: linear-gradient(135deg, #3b82f6, #06b6d4); color: white;">
                    <i class="fas fa-hourglass-half me-1"></i><span id="countdownText">Đang tính...</span>
                </span>
            </div>
            <script>
            (function() {
                var el = document.getElementById('eventCountdown');
                var startMs = parseInt(el.dataset.start);
                function update() {
                    var diff = startMs - Date.now();
                    if (diff <= 0) { document.getElementById('countdownText').textContent = 'Đã bắt đầu!'; return; }
                    var d = Math.floor(diff / 86400000);
                    var h = Math.floor((diff % 86400000) / 3600000);
                    var m = Math.floor((diff % 3600000) / 60000);
                    var s = Math.floor((diff % 60000) / 1000);
                    document.getElementById('countdownText').textContent = 
                        (d > 0 ? d + ' ngày ' : '') + h + 'h ' + m + 'm ' + s + 's';
                }
                update();
                setInterval(update, 1000);
            })();
            </script>
        </c:if>
    </c:when>
</c:choose>
