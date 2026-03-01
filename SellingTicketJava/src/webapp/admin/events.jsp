<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@taglib prefix="fn" uri="jakarta.tags.functions" %>

<jsp:include page="../header.jsp" />

<div class="container-fluid py-4">
    <div class="row">
        <div class="col-lg-2">
            <jsp:include page="sidebar.jsp">
                <jsp:param name="activePage" value="events"/>
            </jsp:include>
        </div>

        <div class="col-lg-10">
            <div class="d-flex justify-content-between align-items-center mb-4 animate-fadeInDown">
                <div>
                    <h2 class="fw-bold mb-1"><i class="fas fa-calendar-alt text-primary me-2"></i>Quản lý sự kiện</h2>
                    <p class="text-muted mb-0">Xem, duyệt và quản lý tất cả sự kiện</p>
                </div>
            </div>

            <%-- Stats Row --%>
            <div class="row g-3 mb-4">
                <div class="col-md-4 animate-on-scroll">
                    <div class="card glass-strong border-0 rounded-4 hover-lift">
                        <div class="card-body d-flex align-items-center gap-3 p-3">
                            <div class="dash-icon-box" style="width:42px;height:42px;background:linear-gradient(135deg,#f59e0b,#f97316);border-radius:12px;">
                                <i class="fas fa-clock text-white"></i>
                            </div>
                            <div>
                                <h4 class="fw-bold mb-0">${pendingCount != null ? pendingCount : 0}</h4>
                                <small class="text-muted">Chờ duyệt</small>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-md-4 animate-on-scroll stagger-1">
                    <div class="card glass-strong border-0 rounded-4 hover-lift">
                        <div class="card-body d-flex align-items-center gap-3 p-3">
                            <div class="dash-icon-box" style="width:42px;height:42px;background:linear-gradient(135deg,#10b981,#06b6d4);border-radius:12px;">
                                <i class="fas fa-check text-white"></i>
                            </div>
                            <div>
                                <h4 class="fw-bold mb-0">${approvedCount != null ? approvedCount : 0}</h4>
                                <small class="text-muted">Đã duyệt</small>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-md-4 animate-on-scroll stagger-2">
                    <div class="card glass-strong border-0 rounded-4 hover-lift">
                        <div class="card-body d-flex align-items-center gap-3 p-3">
                            <div class="dash-icon-box" style="width:42px;height:42px;background:linear-gradient(135deg,#ef4444,#f97316);border-radius:12px;">
                                <i class="fas fa-times text-white"></i>
                            </div>
                            <div>
                                <h4 class="fw-bold mb-0">${rejectedCount != null ? rejectedCount : 0}</h4>
                                <small class="text-muted">Từ chối</small>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <%-- Filter Tabs --%>
            <div class="card glass-strong border-0 rounded-4 mb-4 animate-on-scroll">
                <div class="card-body d-flex gap-3 flex-wrap align-items-center p-3">
                    <div class="btn-group btn-group-sm">
                        <a href="${pageContext.request.contextPath}/admin/events" class="btn btn-outline-primary rounded-start-pill ${empty statusFilter ? 'active' : ''}">
                            Tất cả
                        </a>
                        <a href="${pageContext.request.contextPath}/admin/events?status=pending" class="btn btn-outline-primary ${statusFilter == 'pending' ? 'active' : ''}">
                            Chờ duyệt <span class="badge bg-danger ms-1">${pendingCount}</span>
                        </a>
                        <a href="${pageContext.request.contextPath}/admin/events?status=approved" class="btn btn-outline-primary ${statusFilter == 'approved' ? 'active' : ''}">
                            Đã duyệt
                        </a>
                        <a href="${pageContext.request.contextPath}/admin/events?status=rejected" class="btn btn-outline-primary rounded-end-pill ${statusFilter == 'rejected' ? 'active' : ''}">
                            Từ chối
                        </a>
                    </div>
                    <form class="input-group ms-auto" style="max-width: 280px;" method="GET" action="${pageContext.request.contextPath}/admin/events">
                        <c:if test="${not empty statusFilter}">
                            <input type="hidden" name="status" value="${statusFilter}"/>
                        </c:if>
                        <span class="input-group-text glass border-0"><i class="fas fa-search text-muted"></i></span>
                        <input type="text" name="q" class="form-control glass border-0" placeholder="Tìm kiếm sự kiện..." value="${param.q}">
                    </form>
                </div>
            </div>

            <%-- Toast messages --%>
            <c:if test="${param.success != null}">
                <div class="alert alert-success alert-dismissible fade show rounded-4 border-0" role="alert" style="background: rgba(16,185,129,0.1); color: #059669;">
                    <i class="fas fa-check-circle me-2"></i>
                    <c:choose>
                        <c:when test="${param.success == 'approved'}">Sự kiện đã được duyệt thành công!</c:when>
                        <c:when test="${param.success == 'rejected'}">Sự kiện đã bị từ chối!</c:when>
                        <c:when test="${param.success == 'deleted'}">Sự kiện đã được xóa!</c:when>
                        <c:otherwise>Thao tác thành công!</c:otherwise>
                    </c:choose>
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            </c:if>
            <c:if test="${param.error != null}">
                <div class="alert alert-danger alert-dismissible fade show rounded-4 border-0" role="alert" style="background: rgba(239,68,68,0.1); color: #dc2626;">
                    <i class="fas fa-exclamation-circle me-2"></i>Đã có lỗi xảy ra. Vui lòng thử lại.
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            </c:if>

            <%-- Events Table --%>
            <div class="card glass-strong border-0 rounded-4 animate-on-scroll">
                <div class="card-body p-0">
                    <div class="table-responsive">
                        <table class="table table-glass align-middle mb-0">
                            <thead>
                                <tr>
                                    <th>Sự kiện</th>
                                    <th>Organizer</th>
                                    <th>Danh mục</th>
                                    <th>Ngày</th>
                                    <th>Trạng thái</th>
                                    <th class="text-center">Thao tác</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="event" items="${events}">
                                <tr class="hover-lift" style="transition: all 0.2s;">
                                    <td>
                                        <div class="d-flex align-items-center gap-3">
                                            <img src="${event.bannerUrl != null ? event.bannerUrl : 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=100'}"
                                                 class="rounded-3 shadow-sm" style="width:50px;height:50px;object-fit:cover;" alt="">
                                            <div>
                                                <a href="${pageContext.request.contextPath}/admin/events/${event.eventId}" class="fw-medium text-decoration-none">${event.title}</a>
                                                <div class="text-muted small"><i class="fas fa-map-marker-alt me-1"></i>${event.location}</div>
                                            </div>
                                        </div>
                                    </td>
                                    <td class="text-muted">${event.organizerName}</td>
                                    <td><span class="badge glass rounded-pill px-3 py-1">${event.categoryName}</span></td>
                                    <td class="text-muted small">
                                        <fmt:formatDate value="${event.startDate}" pattern="dd/MM/yyyy HH:mm"/>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${event.status == 'approved'}">
                                                <span class="badge bg-success rounded-pill px-3 py-2"><i class="fas fa-check me-1"></i>Đã duyệt</span>
                                            </c:when>
                                            <c:when test="${event.status == 'pending'}">
                                                <span class="badge rounded-pill px-3 py-2" style="background:linear-gradient(135deg,#f59e0b,#f97316);color:white;"><i class="fas fa-clock me-1"></i>Chờ duyệt</span>
                                            </c:when>
                                            <c:when test="${event.status == 'rejected'}">
                                                <span class="badge bg-danger rounded-pill px-3 py-2"><i class="fas fa-times me-1"></i>Từ chối</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge bg-secondary rounded-pill px-3 py-2">${event.status}</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td class="text-center">
                                        <div class="d-flex gap-1 justify-content-center flex-wrap">
                                            <a href="${pageContext.request.contextPath}/admin/events/${event.eventId}" class="btn btn-sm glass rounded-pill px-2" title="Xem chi tiết">
                                                <i class="fas fa-eye text-primary"></i>
                                            </a>
                                            <c:if test="${event.status == 'pending'}">
                                                <form method="POST" action="${pageContext.request.contextPath}/admin/events/approve" class="d-inline">
                                                    <input type="hidden" name="csrf_token" value="${sessionScope.csrf_token}"/>
                                                    <input type="hidden" name="eventId" value="${event.eventId}"/>
                                                    <button type="submit" class="btn btn-sm rounded-pill px-2" style="background:linear-gradient(135deg,#10b981,#06b6d4);color:white;" title="Duyệt">
                                                        <i class="fas fa-check"></i>
                                                    </button>
                                                </form>
                                                <button class="btn btn-sm btn-outline-danger rounded-pill px-2" title="Từ chối"
                                                        data-bs-toggle="modal" data-bs-target="#rejectModal"
                                                        onclick="document.getElementById('rejectEventId').value='${event.eventId}'; document.getElementById('rejectEventName').textContent='${event.title}'">
                                                    <i class="fas fa-times"></i>
                                                </button>
                                            </c:if>
                                            <c:if test="${event.status != 'pending'}">
                                                <form method="POST" action="${pageContext.request.contextPath}/admin/events/delete" class="d-inline"
                                                      onsubmit="return confirm('Bạn có chắc muốn xóa sự kiện này?')">
                                                    <input type="hidden" name="csrf_token" value="${sessionScope.csrf_token}"/>
                                                    <input type="hidden" name="eventId" value="${event.eventId}"/>
                                                    <button type="submit" class="btn btn-sm glass rounded-pill px-2" title="Xóa">
                                                        <i class="fas fa-trash text-danger"></i>
                                                    </button>
                                                </form>
                                            </c:if>
                                            <button class="btn btn-sm rounded-pill px-2 ${event.featured ? 'pinned' : ''}" title="${event.featured ? 'Bỏ nổi bật' : 'Đánh dấu nổi bật'}"
                                                    style="background:${event.featured ? 'linear-gradient(135deg,#f59e0b,#d97706)' : 'rgba(245,158,11,0.1)'};color:${event.featured ? 'white' : '#d97706'};border:${event.featured ? 'none' : '1px solid rgba(245,158,11,0.3)'};"
                                                    onclick="toggleFeatured(${event.eventId}, ${event.featured}, this)">
                                                <i class="fas fa-star"></i>
                                            </button>
                                        </div>
                                    </td>
                                </tr>
                                </c:forEach>
                                <c:if test="${empty events}">
                                <tr>
                                    <td colspan="6" class="text-center py-5 text-muted">
                                        <i class="fas fa-calendar-times fa-3x mb-3 opacity-25"></i>
                                        <p class="mb-0 fw-medium">Không có sự kiện nào</p>
                                        <small>Thay đổi bộ lọc để xem các sự kiện khác</small>
                                    </td>
                                </tr>
                                </c:if>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>

            <%-- Pagination --%>
            <c:if test="${currentPage != null}">
            <div class="d-flex justify-content-center mt-4">
                <nav>
                    <ul class="pagination pagination-sm">
                        <c:if test="${currentPage > 1}">
                            <li class="page-item">
                                <a class="page-link glass rounded-start-pill" href="${pageContext.request.contextPath}/admin/events?page=${currentPage - 1}&status=${statusFilter}">
                                    <i class="fas fa-chevron-left"></i>
                                </a>
                            </li>
                        </c:if>
                        <li class="page-item active">
                            <span class="page-link" style="background:linear-gradient(135deg,var(--primary),var(--secondary));border:none;">${currentPage}</span>
                        </li>
                        <li class="page-item">
                            <a class="page-link glass rounded-end-pill" href="${pageContext.request.contextPath}/admin/events?page=${currentPage + 1}&status=${statusFilter}">
                                <i class="fas fa-chevron-right"></i>
                            </a>
                        </li>
                    </ul>
                </nav>
            </div>
            </c:if>
        </div>
    </div>
</div>

<%-- Reject Modal with Rich Editor --%>
<div class="modal fade" id="rejectModal" tabindex="-1">
    <div class="modal-dialog modal-lg modal-dialog-centered">
        <div class="modal-content glass-strong border-0 rounded-4">
            <form method="POST" action="${pageContext.request.contextPath}/admin/events/reject" onsubmit="document.getElementById('evtRejectReason').value=document.getElementById('evtRejectEditor').innerHTML;">
                <input type="hidden" name="csrf_token" value="${sessionScope.csrf_token}"/>
                <input type="hidden" name="eventId" id="rejectEventId"/>
                <div class="modal-header border-0">
                    <h5 class="modal-title fw-bold"><i class="fas fa-times-circle text-danger me-2"></i>Từ chối sự kiện</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <p>Sự kiện: <strong id="rejectEventName"></strong></p>
                    <label class="form-label fw-medium">Lý do từ chối <span class="text-danger">*</span></label>
                    <div class="desc-toolbar" style="display:flex;gap:0.25rem;flex-wrap:wrap;padding:0.5rem;background:rgba(0,0,0,0.02);border-radius:8px 8px 0 0;border:1px solid rgba(0,0,0,0.08);border-bottom:none;">
                        <button type="button" onclick="rFmt('bold')" title="In đậm" class="btn btn-sm btn-light"><i class="fas fa-bold"></i></button>
                        <button type="button" onclick="rFmt('italic')" title="In nghiêng" class="btn btn-sm btn-light"><i class="fas fa-italic"></i></button>
                        <button type="button" onclick="rFmt('underline')" title="Gạch chân" class="btn btn-sm btn-light"><i class="fas fa-underline"></i></button>
                        <span style="width:1px;background:rgba(0,0,0,0.1);margin:0 4px;height:20px;align-self:center;"></span>
                        <button type="button" onclick="rFmt('insertUnorderedList')" title="Danh sách" class="btn btn-sm btn-light"><i class="fas fa-list-ul"></i></button>
                        <button type="button" onclick="rFmt('insertOrderedList')" title="Số" class="btn btn-sm btn-light"><i class="fas fa-list-ol"></i></button>
                        <span style="width:1px;background:rgba(0,0,0,0.1);margin:0 4px;height:20px;align-self:center;"></span>
                        <select class="form-select form-select-sm" style="width:auto;" onchange="rFmt('formatBlock',this.value);this.selectedIndex=0;">
                            <option value="" hidden>Tiêu đề</option>
                            <option value="H3">Tiêu đề</option>
                            <option value="P">Bình thường</option>
                        </select>
                        <button type="button" onclick="rFmt('foreColor','#ef4444')" title="Màu đỏ" class="btn btn-sm btn-light"><i class="fas fa-palette" style="color:#ef4444;"></i></button>
                    </div>
                    <div contenteditable="true" id="evtRejectEditor" spellcheck="false" style="border:1px solid rgba(0,0,0,0.08);border-radius:0 0 8px 8px;min-height:180px;padding:1rem;background:white;outline:none;font-size:0.95rem;line-height:1.6;max-height:400px;overflow-y:auto;"
                         onfocus="this.style.borderColor='var(--primary)';this.style.boxShadow='0 0 0 3px rgba(147,51,234,0.1)';"
                         onblur="this.style.borderColor='rgba(0,0,0,0.08)';this.style.boxShadow='none';"></div>
                    <textarea name="reason" id="evtRejectReason" class="d-none" required></textarea>
                </div>
                <div class="modal-footer border-0">
                    <button type="button" class="btn btn-light rounded-pill px-4" data-bs-dismiss="modal">Hủy</button>
                    <button type="submit" class="btn btn-danger rounded-pill px-4">
                        <i class="fas fa-times me-2"></i>Xác nhận từ chối
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
function rFmt(cmd, val) { document.execCommand(cmd, false, val); document.getElementById('evtRejectEditor').focus(); }

function toggleFeatured(eventId, currentState, btn) {
    var basePath = document.querySelector('meta[name="ctx"]')?.content || '';
    fetch(basePath + '/admin/events/feature', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: 'eventId=' + eventId + '&featured=' + (!currentState)
    })
    .then(function(res) { if (res.ok) location.reload(); });
}
</script>

<jsp:include page="../footer.jsp" />
