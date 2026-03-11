<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<jsp:include page="../header.jsp" />

<style>
.detail-banner { width: 100%; max-height: 320px; object-fit: cover; border-radius: var(--radius-lg); box-shadow: 0 12px 40px rgba(0,0,0,0.12); }
.info-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 1rem; }
.info-item { background: rgba(255,255,255,0.6); border-radius: var(--radius-md); padding: 1rem; border: 1px solid rgba(0,0,0,0.04); }
.info-item .label { font-size: 0.75rem; text-transform: uppercase; letter-spacing: 0.06em; color: var(--text-muted); margin-bottom: 0.25rem; }
.info-item .value { font-weight: 600; font-size: 1rem; }
.desc-content img { max-width: 100%; border-radius: 8px; }
.desc-content video { max-width: 100%; border-radius: 8px; }
.rejection-box { background: rgba(239, 68, 68, 0.06); border-left: 4px solid #ef4444; border-radius: 0 var(--radius-md) var(--radius-md) 0; padding: 1.25rem; }
/* Rich editor styles for reject modal */
.desc-toolbar-modal button { width:30px;height:30px;border:none;background:transparent;border-radius:6px;cursor:pointer;color:var(--text-muted);display:flex;align-items:center;justify-content:center;transition:all 0.2s; }
.desc-toolbar-modal button:hover { background:rgba(147,51,234,0.1);color:var(--primary); }
.desc-editor-modal { border:1px solid rgba(0,0,0,0.08);border-radius:0 0 var(--radius-sm) var(--radius-sm);min-height:180px;padding:1.25rem;background:white;outline:none;font-size:1rem;line-height:1.6;overflow-y:auto;max-height:400px; }
.desc-editor-modal:focus { border-color:var(--primary);box-shadow:0 0 0 3px rgba(147,51,234,0.1); }
</style>

<div class="container-fluid py-4">
    <div class="row">
        <div class="col-lg-2">
            <jsp:include page="sidebar.jsp">
                <jsp:param name="activePage" value="events"/>
            </jsp:include>
        </div>

        <div class="col-lg-10">
            <%-- Breadcrumb --%>
            <nav aria-label="breadcrumb" class="mb-3 animate-fadeInDown">
                <ol class="breadcrumb mb-0">
                    <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/admin/events" class="text-decoration-none">Sự kiện</a></li>
                    <li class="breadcrumb-item active">${event.title}</li>
                </ol>
            </nav>

            <div class="row g-4">
                <%-- Main Content --%>
                <div class="col-lg-8">
                    <%-- Banner --%>
                    <div class="card glass-strong border-0 rounded-4 overflow-hidden mb-4 animate-on-scroll">
                        <c:if test="${not empty event.bannerImage}">
                            <img src="${event.bannerImage}" alt="${event.title}" class="detail-banner w-100">
                        </c:if>
                        <div class="card-body p-4">
                            <div class="d-flex justify-content-between align-items-start mb-3">
                                <div>
                                    <h3 class="fw-bold mb-1">${event.title}</h3>
                                    <p class="text-muted mb-0">
                                        <span class="badge glass rounded-pill px-3 py-1 me-2">${event.categoryName}</span>
                                        bởi <strong>${event.organizerName}</strong>
                                    </p>
                                </div>
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
                            </div>

                            <%-- Event Info Grid --%>
                            <div class="info-grid mb-4">
                                <div class="info-item">
                                    <div class="label"><i class="fas fa-calendar-alt me-1"></i>Bắt đầu</div>
                                    <div class="value"><fmt:formatDate value="${event.startDate}" pattern="dd/MM/yyyy HH:mm"/></div>
                                </div>
                                <div class="info-item">
                                    <div class="label"><i class="fas fa-calendar-check me-1"></i>Kết thúc</div>
                                    <div class="value">
                                        <c:choose>
                                            <c:when test="${event.endDate != null}"><fmt:formatDate value="${event.endDate}" pattern="dd/MM/yyyy HH:mm"/></c:when>
                                            <c:otherwise>—</c:otherwise>
                                        </c:choose>
                                    </div>
                                </div>
                                <div class="info-item">
                                    <div class="label"><i class="fas fa-map-marker-alt me-1"></i>Địa điểm</div>
                                    <div class="value">${event.location}</div>
                                </div>
                                <div class="info-item">
                                    <div class="label"><i class="fas fa-map me-1"></i>Địa chỉ</div>
                                    <div class="value">${not empty event.address ? event.address : '—'}</div>
                                </div>
                                <div class="info-item">
                                    <div class="label"><i class="fas fa-eye me-1"></i>Lượt xem</div>
                                    <div class="value"><fmt:formatNumber value="${event.views}" type="number"/></div>
                                </div>
                                <div class="info-item">
                                    <div class="label"><i class="fas fa-clock me-1"></i>Ngày tạo</div>
                                    <div class="value"><fmt:formatDate value="${event.createdAt}" pattern="dd/MM/yyyy HH:mm"/></div>
                                </div>
                            </div>

                            <%-- Rejection Reason --%>
                            <c:if test="${event.status == 'rejected' && not empty event.rejectionReason}">
                                <div class="rejection-box mb-4">
                                    <h6 class="fw-bold mb-2 text-danger"><i class="fas fa-exclamation-triangle me-2"></i>Lý do từ chối</h6>
                                    <div class="desc-content">${event.rejectionReason}</div>
                                    <c:if test="${event.rejectedAt != null}">
                                        <small class="text-muted mt-2 d-block">Từ chối lúc: <fmt:formatDate value="${event.rejectedAt}" pattern="dd/MM/yyyy HH:mm"/></small>
                                    </c:if>
                                </div>
                            </c:if>
                        </div>
                    </div>

                    <%-- Description --%>
                    <div class="card glass-strong border-0 rounded-4 mb-4 animate-on-scroll">
                        <div class="card-body p-4">
                            <h5 class="fw-bold mb-3"><i class="fas fa-align-left text-primary me-2"></i>Mô tả sự kiện</h5>
                            <div class="desc-content" style="line-height: 1.8;">
                                ${event.description}
                            </div>
                        </div>
                    </div>

                    <%-- Tickets --%>
                    <c:if test="${not empty event.ticketTypes}">
                    <div class="card glass-strong border-0 rounded-4 animate-on-scroll">
                        <div class="card-body p-4">
                            <h5 class="fw-bold mb-3"><i class="fas fa-ticket-alt text-primary me-2"></i>Loại vé</h5>
                            <div class="table-responsive">
                                <table class="table table-glass align-middle mb-0">
                                    <thead><tr>
                                        <th>Tên vé</th><th class="text-end">Giá</th><th class="text-end">Tổng</th><th class="text-end">Đã bán</th><th class="text-end">Còn lại</th>
                                    </tr></thead>
                                    <tbody>
                                        <c:forEach var="tt" items="${event.ticketTypes}">
                                        <tr>
                                            <td class="fw-medium">${tt.name}</td>
                                            <td class="text-end"><fmt:formatNumber value="${tt.price}" type="number"/> đ</td>
                                            <td class="text-end">${tt.quantity}</td>
                                            <td class="text-end">${tt.soldQuantity}</td>
                                            <td class="text-end fw-medium">${tt.quantity - tt.soldQuantity}</td>
                                        </tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                    </c:if>
                </div>

                <%-- Sidebar Actions --%>
                <div class="col-lg-4">
                    <div class="card glass-strong border-0 rounded-4 mb-4 animate-on-scroll stagger-1">
                        <div class="card-body p-4">
                            <h5 class="fw-bold mb-3"><i class="fas fa-cog text-primary me-2"></i>Thao tác</h5>

                            <c:if test="${event.status == 'pending'}">
                                <form method="POST" action="${pageContext.request.contextPath}/admin/events/approve" class="mb-2">
                                    <input type="hidden" name="csrf_token" value="${sessionScope.csrf_token}"/>
                                    <input type="hidden" name="eventId" value="${event.eventId}"/>
                                    <button type="submit" class="btn w-100 rounded-pill py-2 fw-medium" style="background:linear-gradient(135deg,#10b981,#06b6d4);color:white;">
                                        <i class="fas fa-check me-2"></i>Duyệt sự kiện
                                    </button>
                                </form>
                                <button class="btn btn-outline-danger w-100 rounded-pill py-2 mb-2 fw-medium" data-bs-toggle="modal" data-bs-target="#rejectDetailModal">
                                    <i class="fas fa-times me-2"></i>Từ chối sự kiện
                                </button>
                            </c:if>

                            <div class="d-grid gap-2">
                                <a href="${pageContext.request.contextPath}/admin/events" class="btn glass rounded-pill py-2">
                                    <i class="fas fa-arrow-left me-2"></i>Quay lại danh sách
                                </a>

                                <form method="POST" action="${pageContext.request.contextPath}/admin/events/delete"
                                      onsubmit="return confirm('Bạn có chắc muốn xóa sự kiện này?')">
                                    <input type="hidden" name="csrf_token" value="${sessionScope.csrf_token}"/>
                                    <input type="hidden" name="eventId" value="${event.eventId}"/>
                                    <button type="submit" class="btn btn-outline-danger w-100 rounded-pill py-2">
                                        <i class="fas fa-trash me-2"></i>Xóa sự kiện
                                    </button>
                                </form>
                            </div>
                        </div>
                    </div>

                    <%-- Event Stats --%>
                    <div class="card glass-strong border-0 rounded-4 mb-4 animate-on-scroll stagger-2">
                        <div class="card-body p-4">
                            <h5 class="fw-bold mb-3"><i class="fas fa-chart-bar text-primary me-2"></i>Thống kê</h5>
                            <div class="d-flex justify-content-between py-2 border-bottom" style="border-color: rgba(0,0,0,0.05) !important;">
                                <span class="text-muted">Tổng vé</span>
                                <strong>${event.totalTickets}</strong>
                            </div>
                            <div class="d-flex justify-content-between py-2 border-bottom" style="border-color: rgba(0,0,0,0.05) !important;">
                                <span class="text-muted">Đã bán</span>
                                <strong class="text-success">${event.soldTickets}</strong>
                            </div>
                            <div class="d-flex justify-content-between py-2 border-bottom" style="border-color: rgba(0,0,0,0.05) !important;">
                                <span class="text-muted">Doanh thu</span>
                                <strong class="text-success"><fmt:formatNumber value="${event.revenue}" type="number"/> đ</strong>
                            </div>
                            <div class="d-flex justify-content-between py-2 border-bottom" style="border-color: rgba(0,0,0,0.05) !important;">
                                <span class="text-muted">Lượt xem</span>
                                <strong>${event.views}</strong>
                            </div>
                            <div class="d-flex justify-content-between py-2">
                                <span class="text-muted">Nổi bật</span>
                                <strong>${event.featured ? '✅ Có' : '❌ Không'}</strong>
                            </div>
                        </div>
                    </div>

                    <%-- Organizer Info --%>
                    <div class="card glass-strong border-0 rounded-4 mb-4 animate-on-scroll stagger-3">
                        <div class="card-body p-4">
                            <h5 class="fw-bold mb-3"><i class="fas fa-user text-primary me-2"></i>Người tổ chức</h5>
                            <p class="fw-medium mb-1">${event.organizerName}</p>
                            <small class="text-muted">ID: ${event.organizerId}</small>
                        </div>
                    </div>

                    <%-- Admin Quick Edit --%>
                    <div class="card glass-strong border-0 rounded-4 animate-on-scroll stagger-3">
                        <div class="card-body p-4">
                            <h5 class="fw-bold mb-3"><i class="fas fa-edit text-primary me-2"></i>Chỉnh sửa nhanh</h5>
                            <form method="POST" action="${pageContext.request.contextPath}/admin/events/update">
                                <input type="hidden" name="csrf_token" value="${sessionScope.csrf_token}"/>
                                <input type="hidden" name="eventId" value="${event.eventId}"/>
                                <div class="mb-3">
                                    <label class="form-label small fw-medium">Tiêu đề</label>
                                    <input type="text" name="title" class="form-control glass rounded-3" value="${event.title}" required>
                                </div>
                                <div class="mb-3">
                                    <label class="form-label small fw-medium">Địa điểm</label>
                                    <input type="text" name="location" class="form-control glass rounded-3" value="${event.location}">
                                </div>
                                <div class="mb-3">
                                    <label class="form-label small fw-medium">Trạng thái</label>
                                    <select name="status" class="form-select glass rounded-3">
                                        <option value="pending" ${event.status == 'pending' ? 'selected' : ''}>Chờ duyệt</option>
                                        <option value="approved" ${event.status == 'approved' ? 'selected' : ''}>Đã duyệt</option>
                                        <option value="rejected" ${event.status == 'rejected' ? 'selected' : ''}>Từ chối</option>
                                    </select>
                                </div>
                                <div class="mb-3">
                                    <div class="form-check form-switch">
                                        <input class="form-check-input" type="checkbox" name="featured" id="editFeatured" ${event.featured ? 'checked' : ''}>
                                        <label class="form-check-label small fw-medium" for="editFeatured">Nổi bật trên trang chủ</label>
                                    </div>
                                </div>
                                <button type="submit" class="btn w-100 rounded-pill py-2 fw-medium" style="background:linear-gradient(135deg,#3b82f6,#6366f1);color:white;">
                                    <i class="fas fa-save me-2"></i>Lưu thay đổi
                                </button>
                            </form>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<%-- Reject Modal with Rich Editor --%>
<c:if test="${event.status == 'pending'}">
<div class="modal fade" id="rejectDetailModal" tabindex="-1">
    <div class="modal-dialog modal-lg modal-dialog-centered">
        <div class="modal-content glass-strong border-0 rounded-4">
            <form method="POST" action="${pageContext.request.contextPath}/admin/events/reject"
                  onsubmit="document.getElementById('dtlRejectReason').value=document.getElementById('dtlRejectEditor').innerHTML;">
                <input type="hidden" name="csrf_token" value="${sessionScope.csrf_token}"/>
                <input type="hidden" name="eventId" value="${event.eventId}"/>
                <div class="modal-header border-0">
                    <h5 class="modal-title fw-bold"><i class="fas fa-times-circle text-danger me-2"></i>Từ chối: ${event.title}</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <label class="form-label fw-medium">Lý do từ chối <span class="text-danger">*</span></label>
                    <div class="desc-toolbar-modal" style="display:flex;gap:0.25rem;flex-wrap:wrap;padding:0.5rem;background:rgba(0,0,0,0.02);border-radius:8px 8px 0 0;border:1px solid rgba(0,0,0,0.08);border-bottom:none;align-items:center;">
                        <button type="button" onclick="dtlFmt('bold')" title="In đậm"><i class="fas fa-bold"></i></button>
                        <button type="button" onclick="dtlFmt('italic')" title="In nghiêng"><i class="fas fa-italic"></i></button>
                        <button type="button" onclick="dtlFmt('underline')" title="Gạch chân"><i class="fas fa-underline"></i></button>
                        <span style="width:1px;background:rgba(0,0,0,0.1);margin:0 4px;height:20px;align-self:center;"></span>
                        <button type="button" onclick="dtlFmt('insertUnorderedList')" title="Danh sách"><i class="fas fa-list-ul"></i></button>
                        <button type="button" onclick="dtlFmt('insertOrderedList')" title="Số"><i class="fas fa-list-ol"></i></button>
                        <span style="width:1px;background:rgba(0,0,0,0.1);margin:0 4px;height:20px;align-self:center;"></span>
                        <select class="form-select form-select-sm" style="width:auto;background-color:transparent;border:none;font-size:0.85rem;"
                                onchange="dtlFmt('formatBlock',this.value);this.selectedIndex=0;">
                            <option value="" hidden>Tiêu đề</option>
                            <option value="H3">Tiêu đề</option>
                            <option value="P">Bình thường</option>
                        </select>
                        <button type="button" onclick="dtlFmt('foreColor','#ef4444')" title="Màu đỏ"><i class="fas fa-palette" style="color:#ef4444;"></i></button>
                        <button type="button" onclick="dtlFmt('removeFormat')" title="Xóa format"><i class="fas fa-eraser"></i></button>
                    </div>
                    <div contenteditable="true" id="dtlRejectEditor" spellcheck="false" class="desc-editor-modal"></div>
                    <textarea name="reason" id="dtlRejectReason" class="d-none" required></textarea>
                </div>
                <div class="modal-footer border-0">
                    <button type="button" class="btn btn-light rounded-pill px-4" data-bs-dismiss="modal">Hủy</button>
                    <button type="submit" class="btn btn-danger rounded-pill px-4"><i class="fas fa-times me-2"></i>Xác nhận từ chối</button>
                </div>
            </form>
        </div>
    </div>
</div>
</c:if>

<script>
function dtlFmt(cmd, val) { document.execCommand(cmd, false, val); document.getElementById('dtlRejectEditor').focus(); }
</script>

<jsp:include page="../footer.jsp" />
