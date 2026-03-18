<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<jsp:include page="../header.jsp" />

<div class="container-fluid py-4">
    <div class="row">
        <!-- Sidebar -->
        <div class="col-lg-2">
            <jsp:include page="sidebar.jsp">
                <jsp:param name="activePage" value="check-in"/>
            </jsp:include>
        </div>

        <!-- Main Content -->
        <div class="col-lg-10">
            <c:choose>
                <%-- NO EVENT SELECTED — Show Event Selector --%>
                <c:when test="${noEventSelected}">
                    <div class="row justify-content-center">
                        <div class="col-lg-8">
                            <!-- Header -->
                            <div class="text-center mb-4 animate-fadeInDown">
                                <div class="d-inline-flex align-items-center justify-content-center rounded-circle mb-3"
                                     style="width: 72px; height: 72px; background: linear-gradient(135deg, #10b981, #059669);">
                                    <i class="fas fa-qrcode text-white fa-2x"></i>
                                </div>
                                <h3 class="fw-bold mb-1">Chọn sự kiện để Check-in</h3>
                                <p class="text-muted">Vui lòng chọn sự kiện bạn muốn thực hiện check-in</p>
                            </div>

                            <!-- Event List -->
                            <c:forEach var="ev" items="${assignedEvents}" varStatus="loop">
                            <a href="${pageContext.request.contextPath}/staff/check-in?eventId=${ev.eventId}"
                               class="card glass-strong border-0 rounded-4 mb-3 text-decoration-none animate-fadeInDown hover-glow"
                               style="animation-delay: ${loop.index * 0.08}s; transition: all 0.3s;">
                                <div class="card-body p-4">
                                    <div class="d-flex align-items-center gap-3">
                                        <div class="flex-shrink-0 d-flex align-items-center justify-content-center rounded-3"
                                             style="width: 52px; height: 52px; background: linear-gradient(135deg, #10b981, #059669);">
                                            <i class="fas fa-calendar-check text-white fa-lg"></i>
                                        </div>
                                        <div class="flex-grow-1 min-width-0">
                                            <h6 class="fw-bold mb-1 text-dark">${ev.eventName}</h6>
                                            <div class="d-flex flex-wrap gap-3 text-muted small">
                                                <span><i class="fas fa-map-marker-alt me-1"></i>${ev.venue}</span>
                                                <span><i class="fas fa-clock me-1"></i><fmt:formatDate value="${ev.startDate}" pattern="dd/MM/yyyy HH:mm"/></span>
                                            </div>
                                        </div>
                                        <div class="flex-shrink-0 d-flex align-items-center gap-3">
                                            <div class="text-center">
                                                <div class="fw-bold fs-5" style="color: #3b82f6;">${ev.ticketsSold}</div>
                                                <div class="text-muted" style="font-size: 0.65rem;">Vé bán</div>
                                            </div>
                                            <div class="text-center">
                                                <div class="fw-bold fs-5" style="color: #10b981;">${ev.ticketsChecked}</div>
                                                <div class="text-muted" style="font-size: 0.65rem;">Check-in</div>
                                            </div>
                                            <i class="fas fa-chevron-right text-muted"></i>
                                        </div>
                                    </div>
                                    <c:if test="${ev.ticketsSold > 0}">
                                    <div class="progress mt-3" style="height: 5px; border-radius: 3px;">
                                        <div class="progress-bar" role="progressbar"
                                             style="width: ${ev.ticketsChecked * 100 / ev.ticketsSold}%; background: linear-gradient(90deg, #10b981, #059669); border-radius: 3px;"></div>
                                    </div>
                                    </c:if>
                                </div>
                            </a>
                            </c:forEach>

                            <c:if test="${empty assignedEvents}">
                            <div class="card glass-strong border-0 rounded-4">
                                <div class="card-body text-center py-5 text-muted">
                                    <i class="fas fa-inbox fa-3x mb-3 opacity-25"></i>
                                    <p class="mb-1 fw-semibold">Chưa có sự kiện nào</p>
                                    <p class="mb-0 small">Bạn chưa được phân công sự kiện nào để check-in.</p>
                                </div>
                            </div>
                            </c:if>
                        </div>
                    </div>
                </c:when>

                <%-- EVENT SELECTED — Show Check-in Interface --%>
                <c:otherwise>
                    <div class="row justify-content-center">
                        <div class="col-lg-8 col-xl-7">
                            <!-- Event Header -->
                            <div class="card glass-strong border-0 rounded-4 mb-3 animate-fadeInDown">
                                <div class="card-body p-4">
                                    <div class="d-flex align-items-start justify-content-between">
                                        <div class="d-flex align-items-center gap-3">
                                            <div class="d-flex align-items-center justify-content-center rounded-3"
                                                 style="width: 52px; height: 52px; background: linear-gradient(135deg, #10b981, #059669);">
                                                <i class="fas fa-calendar-check text-white fa-lg"></i>
                                            </div>
                                            <div>
                                                <h5 class="fw-bold mb-1">${selectedEvent.eventName}</h5>
                                                <div class="d-flex flex-wrap gap-3 text-muted small">
                                                    <span><i class="fas fa-map-marker-alt me-1"></i>${selectedEvent.venue}</span>
                                                    <span><i class="fas fa-clock me-1"></i><fmt:formatDate value="${selectedEvent.startDate}" pattern="dd/MM/yyyy HH:mm"/></span>
                                                </div>
                                            </div>
                                        </div>
                                        <a href="${pageContext.request.contextPath}/staff/check-in" class="btn btn-sm btn-outline-secondary rounded-pill">
                                            <i class="fas fa-exchange-alt me-1"></i>Đổi sự kiện
                                        </a>
                                    </div>

                                    <!-- Stats Bar -->
                                    <div class="row g-2 mt-3">
                                        <div class="col-4">
                                            <div class="text-center p-2 rounded-3" style="background: rgba(59,130,246,0.08);">
                                                <div class="fw-bold fs-5" style="color: #3b82f6;" id="stat-sold">${selectedEvent.ticketsSold}</div>
                                                <div class="text-muted" style="font-size: 0.7rem;">Vé đã bán</div>
                                            </div>
                                        </div>
                                        <div class="col-4">
                                            <div class="text-center p-2 rounded-3" style="background: rgba(16,185,129,0.08);">
                                                <div class="fw-bold fs-5" style="color: #10b981;" id="stat-checked">${selectedEvent.ticketsChecked}</div>
                                                <div class="text-muted" style="font-size: 0.7rem;">Đã check-in</div>
                                            </div>
                                        </div>
                                        <div class="col-4">
                                            <div class="text-center p-2 rounded-3" style="background: rgba(245,158,11,0.08);">
                                                <c:set var="sold" value="${selectedEvent.ticketsSold}" />
                                                <c:set var="checked" value="${selectedEvent.ticketsChecked}" />
                                                <div class="fw-bold fs-5" style="color: #f59e0b;" id="stat-pct">
                                                    <c:choose>
                                                        <c:when test="${sold > 0}"><fmt:formatNumber value="${checked * 100.0 / sold}" maxFractionDigits="1"/>%</c:when>
                                                        <c:otherwise>0%</c:otherwise>
                                                    </c:choose>
                                                </div>
                                                <div class="text-muted" style="font-size: 0.7rem;">Tỷ lệ</div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <!-- Check-in Form -->
                            <div class="card glass-strong border-0 rounded-4 mb-3 animate-fadeInDown" style="animation-delay: 0.1s;">
                                <div class="card-body p-4">
                                    <form id="checkin-form" onsubmit="return false;">
                                        <input type="hidden" name="eventId" value="${eventId}"/>
                                        <div class="mb-3">
                                            <label class="form-label fw-semibold"><i class="fas fa-barcode me-1"></i>Mã vé</label>
                                            <div class="input-group input-group-lg">
                                                <span class="input-group-text glass border-0"><i class="fas fa-search"></i></span>
                                                <input type="text" id="ticket-code" name="ticketCode"
                                                       class="form-control glass border-0 rounded-end-3"
                                                       placeholder="Nhập hoặc quét mã vé..." autofocus required>
                                            </div>
                                            <div class="form-text"><i class="fas fa-keyboard me-1"></i>Nhấn Enter hoặc click nút để check-in</div>
                                        </div>
                                        <button type="submit" id="btn-checkin" class="btn w-100 py-3 fw-semibold text-white rounded-3"
                                                style="background: linear-gradient(135deg, #10b981, #059669); font-size: 1.1rem; transition: all 0.3s;">
                                            <i class="fas fa-check-circle me-2"></i>Check-in
                                        </button>
                                    </form>

                                    <!-- Result Area -->
                                    <div id="result-area" class="mt-4 d-none">
                                        <div id="result-content" class="alert rounded-3 d-flex align-items-center gap-3"></div>
                                    </div>
                                </div>
                            </div>

                            <!-- Session Check-in History -->
                            <div class="card glass-strong border-0 rounded-4 animate-fadeInDown" style="animation-delay: 0.15s;">
                                <div class="card-header bg-transparent border-0 py-3 px-4 d-flex justify-content-between align-items-center">
                                    <h6 class="mb-0 fw-bold"><i class="fas fa-history me-2"></i>Lịch sử check-in phiên này</h6>
                                    <span class="badge rounded-pill px-3 py-1 fw-bold" style="background: linear-gradient(135deg, #10b981, #059669); color: white;">
                                        <span id="checkin-count">0</span> vé
                                    </span>
                                </div>
                                <div class="card-body p-0" id="history-body">
                                    <div class="text-center py-4 text-muted" id="history-empty">
                                        <i class="fas fa-clipboard-list opacity-25 mb-2" style="font-size: 1.5rem;"></i>
                                        <p class="mb-0 small">Chưa có check-in nào trong phiên này</p>
                                    </div>
                                    <div class="table-responsive d-none" id="history-table">
                                        <table class="table table-hover align-middle mb-0">
                                            <thead>
                                                <tr class="text-muted small" style="border-bottom: 2px solid rgba(0,0,0,0.05);">
                                                    <th class="ps-4">#</th>
                                                    <th>Mã vé</th>
                                                    <th>Thời gian</th>
                                                    <th class="text-center">Trạng thái</th>
                                                </tr>
                                            </thead>
                                            <tbody id="history-rows"></tbody>
                                        </table>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
</div>

<c:if test="${!noEventSelected}">
<script>
(function() {
    var count    = 0;
    var form     = document.getElementById('checkin-form');
    var input    = document.getElementById('ticket-code');
    var resArea  = document.getElementById('result-area');
    var resCont  = document.getElementById('result-content');
    var btn      = document.getElementById('btn-checkin');
    var histRows = document.getElementById('history-rows');
    var histTable = document.getElementById('history-table');
    var histEmpty = document.getElementById('history-empty');
    var statChecked = document.getElementById('stat-checked');
    var statPct    = document.getElementById('stat-pct');
    var totalSold  = parseInt('${selectedEvent.ticketsSold}') || 0;
    var totalChecked = parseInt('${selectedEvent.ticketsChecked}') || 0;

    function updateStats() {
        if (statChecked) statChecked.textContent = totalChecked;
        if (statPct && totalSold > 0) {
            statPct.textContent = (totalChecked * 100 / totalSold).toFixed(1) + '%';
        }
    }

    function addHistoryRow(code, success) {
        var now = new Date();
        var time = now.getHours().toString().padStart(2,'0') + ':' +
                   now.getMinutes().toString().padStart(2,'0') + ':' +
                   now.getSeconds().toString().padStart(2,'0');
        var row = document.createElement('tr');
        row.style.animation = 'fadeInDown 0.3s ease-out';
        row.innerHTML = '<td class="ps-4 fw-semibold">' + (count + (success ? 0 : 1)) + '</td>' +
                        '<td><code class="small">' + code + '</code></td>' +
                        '<td class="small text-muted">' + time + '</td>' +
                        '<td class="text-center">' +
                            (success ? '<span class="badge rounded-pill" style="background:rgba(16,185,129,0.15);color:#10b981;">Thành công</span>'
                                     : '<span class="badge rounded-pill" style="background:rgba(239,68,68,0.15);color:#ef4444;">Thất bại</span>') +
                        '</td>';
        histRows.insertBefore(row, histRows.firstChild);
        histTable.classList.remove('d-none');
        histEmpty.classList.add('d-none');
    }

    form.addEventListener('submit', function() {
        var code = input.value.trim();
        if (!code) return;

        btn.disabled = true;
        btn.innerHTML = '<span class="spinner-border spinner-border-sm me-2"></span>Đang xử lý...';

        var eventId = form.querySelector('[name=eventId]').value;
        var ctx = document.body.dataset.contextPath || '';

        fetch(ctx + '/staff/check-in', {
            method: 'POST',
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
            body: 'ticketCode=' + encodeURIComponent(code) + '&eventId=' + eventId
        })
        .then(function(r) { return r.json(); })
        .then(function(data) {
            resArea.classList.remove('d-none');
            if (data.success) {
                resCont.className = 'alert rounded-3 d-flex align-items-center gap-3';
                resCont.style.cssText = 'background:rgba(16,185,129,0.1);border:1px solid rgba(16,185,129,0.2);color:#065f46;';
                resCont.innerHTML = '<div class="d-flex align-items-center justify-content-center rounded-circle flex-shrink-0" style="width:48px;height:48px;background:linear-gradient(135deg,#10b981,#059669);">' +
                    '<i class="fas fa-check text-white fa-lg"></i></div>' +
                    '<div><strong>Check-in thành công!</strong><br><span class="small">Mã vé: <code>' + code + '</code></span></div>';
                count++;
                totalChecked++;
                updateStats();
                document.getElementById('checkin-count').textContent = count;
                addHistoryRow(code, true);
            } else {
                resCont.className = 'alert rounded-3 d-flex align-items-center gap-3';
                resCont.style.cssText = 'background:rgba(239,68,68,0.1);border:1px solid rgba(239,68,68,0.2);color:#991b1b;';
                resCont.innerHTML = '<div class="d-flex align-items-center justify-content-center rounded-circle flex-shrink-0" style="width:48px;height:48px;background:rgba(239,68,68,0.15);">' +
                    '<i class="fas fa-times" style="color:#ef4444;font-size:1.2rem;"></i></div>' +
                    '<div><strong>Thất bại</strong><br><span class="small">' + (data.error || 'Mã vé không hợp lệ.') + '</span></div>';
                addHistoryRow(code, false);
            }
            input.value = '';
            input.focus();
        })
        .catch(function() {
            resArea.classList.remove('d-none');
            resCont.className = 'alert alert-warning rounded-3';
            resCont.style.cssText = '';
            resCont.innerHTML = '<i class="fas fa-exclamation-triangle me-2"></i>Lỗi kết nối. Vui lòng thử lại.';
        })
        .finally(function() {
            btn.disabled = false;
            btn.innerHTML = '<i class="fas fa-check-circle me-2"></i>Check-in';
        });
    });
})();
</script>
</c:if>

<jsp:include page="../footer.jsp" />
