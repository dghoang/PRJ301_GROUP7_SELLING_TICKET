<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<jsp:include page="../header.jsp" />

<div class="container-fluid py-4">
    <div class="row">
        <%-- Sidebar --%>
        <div class="col-lg-2">
            <jsp:include page="sidebar.jsp">
                <jsp:param name="activePage" value="event-approval"/>
            </jsp:include>
        </div>

        <%-- Main Content --%>
        <div class="col-lg-10">
            <div class="d-flex justify-content-between align-items-center mb-4 animate-fadeInDown">
                <div>
                    <h2 class="fw-bold mb-1">Duyệt sự kiện</h2>
                    <p class="text-muted mb-0">Xét duyệt các sự kiện mới từ ban tổ chức</p>
                </div>
            </div>

            <%-- Stats Cards --%>
            <div class="row g-4 mb-4">
                <div class="col-md-4 animate-on-scroll">
                    <div class="card glass-strong border-0 rounded-4 hover-lift">
                        <div class="card-body d-flex align-items-center gap-3 p-4">
                            <div class="dash-icon-box" style="background: linear-gradient(135deg, #f59e0b, #f97316);">
                                <i class="fas fa-clock fa-lg text-white"></i>
                            </div>
                            <div>
                                <h3 class="fw-bold mb-0">${fn:length(pendingEvents)}</h3>
                                <small class="text-muted">Chờ duyệt</small>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-md-4 animate-on-scroll stagger-1">
                    <div class="card glass-strong border-0 rounded-4 hover-lift">
                        <div class="card-body d-flex align-items-center gap-3 p-4">
                            <div class="dash-icon-box" style="background: linear-gradient(135deg, #10b981, #06b6d4);">
                                <i class="fas fa-check fa-lg text-white"></i>
                            </div>
                            <div>
                                <h3 class="fw-bold mb-0">${approvedCount != null ? approvedCount : 0}</h3>
                                <small class="text-muted">Đã duyệt</small>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-md-4 animate-on-scroll stagger-2">
                    <div class="card glass-strong border-0 rounded-4 hover-lift">
                        <div class="card-body d-flex align-items-center gap-3 p-4">
                            <div class="dash-icon-box" style="background: linear-gradient(135deg, #ef4444, #f97316);">
                                <i class="fas fa-times fa-lg text-white"></i>
                            </div>
                            <div>
                                <h3 class="fw-bold mb-0">${rejectedCount != null ? rejectedCount : 0}</h3>
                                <small class="text-muted">Từ chối</small>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <%-- Event List --%>
            <c:choose>
                <c:when test="${empty pendingEvents}">
                    <div class="card glass-strong border-0 rounded-4 animate-on-scroll">
                        <div class="card-body p-5 text-center">
                            <div class="dash-icon-box mx-auto mb-3" style="width: 80px; height: 80px; background: linear-gradient(135deg, #10b981, #06b6d4); border-radius: 20px;">
                                <i class="fas fa-check-circle fa-2x text-white"></i>
                            </div>
                            <h4 class="fw-bold">Không có sự kiện chờ duyệt</h4>
                            <p class="text-muted">Tất cả sự kiện đã được xử lý!</p>
                        </div>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="row g-4">
                        <c:forEach var="e" items="${pendingEvents}" varStatus="loop">
                        <div class="col-lg-6 animate-on-scroll stagger-${loop.index % 4}">
                            <div class="card glass-strong border-0 rounded-4 hover-lift overflow-hidden" style="transition: all 0.3s;">
                                <c:if test="${not empty e.bannerUrl}">
                                    <div class="position-relative">
                                        <img src="${e.bannerUrl}" class="card-img-top" style="height: 180px; object-fit: cover;" alt="${e.title}">
                                        <span class="badge position-absolute top-0 end-0 m-3 px-3 py-2 rounded-pill" style="background: linear-gradient(135deg, #f59e0b, #f97316); color: white;">
                                            <i class="fas fa-clock me-1"></i>Chờ duyệt
                                        </span>
                                    </div>
                                </c:if>
                                <div class="card-body p-4">
                                    <h5 class="fw-bold mb-1">${e.title}</h5>
                                    <p class="text-muted small mb-3">Bởi: <strong>${e.organizerName}</strong></p>

                                    <div class="row g-2 mb-3">
                                        <div class="col-6">
                                            <div class="d-flex align-items-center text-muted small">
                                                <i class="far fa-calendar me-2 text-primary"></i>
                                                <fmt:formatDate value="${e.startDate}" pattern="dd/MM/yyyy"/>
                                            </div>
                                        </div>
                                        <div class="col-6">
                                            <div class="d-flex align-items-center text-muted small">
                                                <i class="fas fa-map-marker-alt me-2 text-primary"></i>${e.location}
                                            </div>
                                        </div>
                                    </div>

                                    <div class="d-flex gap-2">
                                        <form method="POST" action="${pageContext.request.contextPath}/admin/events/approve" class="flex-grow-1">
                                            <input type="hidden" name="csrf_token" value="${sessionScope.csrf_token}"/>
                                            <input type="hidden" name="eventId" value="${e.eventId}"/>
                                            <button type="submit" class="btn w-100 rounded-pill" style="background: linear-gradient(135deg, #10b981, #06b6d4); color: white; border: none;">
                                                <i class="fas fa-check me-2"></i>Duyệt
                                            </button>
                                        </form>
                                        <button class="btn btn-outline-danger rounded-pill flex-grow-1"
                                                data-bs-toggle="modal" data-bs-target="#rejectModal"
                                                onclick="document.getElementById('rejectEventId').value='${e.eventId}'; document.getElementById('rejectEventName').textContent='${e.title}'">
                                            <i class="fas fa-times me-2"></i>Từ chối
                                        </button>
                                        <a href="${pageContext.request.contextPath}/admin/events/${e.eventId}" class="btn glass rounded-pill" title="Xem chi tiết">
                                            <i class="fas fa-eye"></i>
                                        </a>
                                    </div>
                                </div>
                            </div>
                        </div>
                        </c:forEach>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
</div>

<%-- Reject Modal with Rich Editor --%>
<style>
.approve-toolbar button { width:30px;height:30px;border:none;background:transparent;border-radius:6px;cursor:pointer;color:var(--text-muted);display:flex;align-items:center;justify-content:center;transition:all 0.2s; }
.approve-toolbar button:hover { background:rgba(147,51,234,0.1);color:var(--primary); }
.approve-editor { border:1px solid rgba(0,0,0,0.08);border-radius:0 0 8px 8px;min-height:200px;padding:1.25rem;background:white;outline:none;font-size:1rem;line-height:1.6;overflow-y:auto;max-height:400px; }
.approve-editor:focus { border-color:var(--primary);box-shadow:0 0 0 3px rgba(147,51,234,0.1); }
</style>
<div class="modal fade modal-glass" id="rejectModal" tabindex="-1">
    <div class="modal-dialog modal-lg modal-dialog-centered">
        <div class="modal-content glass-strong border-0 rounded-4">
            <form method="POST" action="${pageContext.request.contextPath}/admin/event-approval"
                  onsubmit="document.getElementById('approveRejectReason').value=document.getElementById('approveRejectEditor').innerHTML;">
                <input type="hidden" name="csrf_token" value="${sessionScope.csrf_token}"/>
                <input type="hidden" name="action" value="reject"/>
                <input type="hidden" name="eventId" id="rejectEventId"/>
                <div class="modal-header border-0">
                    <h5 class="modal-title fw-bold"><i class="fas fa-times-circle text-danger me-2"></i>Từ chối sự kiện</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <p>Bạn có chắc chắn muốn từ chối sự kiện <strong id="rejectEventName"></strong>?</p>
                    <label class="form-label fw-medium">Lý do từ chối <span class="text-danger">*</span></label>
                    <div class="approve-toolbar" style="display:flex;gap:0.25rem;flex-wrap:wrap;padding:0.5rem;background:rgba(0,0,0,0.02);border-radius:8px 8px 0 0;border:1px solid rgba(0,0,0,0.08);border-bottom:none;align-items:center;">
                        <button type="button" onclick="appFmt('bold')" title="In đậm"><i class="fas fa-bold"></i></button>
                        <button type="button" onclick="appFmt('italic')" title="In nghiêng"><i class="fas fa-italic"></i></button>
                        <button type="button" onclick="appFmt('underline')" title="Gạch chân"><i class="fas fa-underline"></i></button>
                        <button type="button" onclick="appFmt('strikethrough')" title="Gạch ngang"><i class="fas fa-strikethrough"></i></button>
                        <span style="width:1px;background:rgba(0,0,0,0.1);margin:0 4px;height:20px;align-self:center;"></span>
                        <button type="button" onclick="appFmt('insertUnorderedList')" title="Danh sách"><i class="fas fa-list-ul"></i></button>
                        <button type="button" onclick="appFmt('insertOrderedList')" title="Số"><i class="fas fa-list-ol"></i></button>
                        <span style="width:1px;background:rgba(0,0,0,0.1);margin:0 4px;height:20px;align-self:center;"></span>
                        <select class="form-select form-select-sm" style="width:auto;background-color:transparent;border:none;font-size:0.85rem;"
                                onchange="appFmt('formatBlock',this.value);this.selectedIndex=0;">
                            <option value="" hidden>Tiêu đề</option>
                            <option value="H3">Tiêu đề</option>
                            <option value="P">Bình thường</option>
                        </select>
                        <button type="button" onclick="appFmt('foreColor','#ef4444')" title="Màu đỏ"><i class="fas fa-palette" style="color:#ef4444;"></i></button>
                        <button type="button" onclick="appFmt('foreColor','#f59e0b')" title="Màu cam"><i class="fas fa-palette" style="color:#f59e0b;"></i></button>
                        <button type="button" onclick="appFmt('removeFormat')" title="Xóa format"><i class="fas fa-eraser"></i></button>
                    </div>
                    <div contenteditable="true" id="approveRejectEditor" spellcheck="false" class="approve-editor"
                         placeholder="Nhập lý do từ chối chi tiết..."></div>
                    <textarea name="reason" id="approveRejectReason" class="d-none" required></textarea>
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
function appFmt(cmd, val) { document.execCommand(cmd, false, val); document.getElementById('approveRejectEditor').focus(); }
</script>

<jsp:include page="../footer.jsp" />
