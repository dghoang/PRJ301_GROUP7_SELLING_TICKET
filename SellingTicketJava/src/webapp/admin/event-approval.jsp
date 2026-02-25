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
                                        <a href="${pageContext.request.contextPath}/event/${e.eventId}" class="btn glass rounded-pill">
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

<%-- Reject Modal --%>
<div class="modal fade modal-glass" id="rejectModal" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content glass-strong border-0 rounded-4">
            <form method="POST" action="${pageContext.request.contextPath}/admin/events/reject">
                <input type="hidden" name="eventId" id="rejectEventId"/>
                <div class="modal-header border-0">
                    <h5 class="modal-title fw-bold"><i class="fas fa-times-circle text-danger me-2"></i>Từ chối sự kiện</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <p>Bạn có chắc chắn muốn từ chối sự kiện <strong id="rejectEventName"></strong>?</p>
                    <div class="mb-3">
                        <label class="form-label fw-medium">Lý do từ chối <span class="text-danger">*</span></label>
                        <textarea class="form-control glass-input rounded-3" name="reason" rows="3" placeholder="Nhập lý do từ chối..." required></textarea>
                    </div>
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

<%@taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="../footer.jsp" />
