<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<jsp:include page="../header.jsp" />

<div class="container-fluid py-4">
    <div class="row">
        <%-- Sidebar --%>
        <div class="col-lg-2">
            <jsp:include page="sidebar.jsp">
                <jsp:param name="activePage" value="tickets"/>
            </jsp:include>
        </div>

        <%-- Main Content --%>
        <div class="col-lg-10">
            <div class="d-flex justify-content-between align-items-center mb-4 animate-fadeInDown">
                <div>
                    <h2 class="fw-bold mb-1">Quản lý loại vé</h2>
                    <p class="text-muted mb-0">Tạo và quản lý các loại vé cho sự kiện của bạn</p>
                </div>
                <button class="btn btn-gradient rounded-pill px-4 hover-glow" data-bs-toggle="modal" data-bs-target="#ticketModal">
                    <i class="fas fa-plus me-2"></i>Thêm loại vé
                </button>
            </div>

            <%-- Event Filter --%>
            <div class="card glass-strong border-0 rounded-4 mb-4 animate-on-scroll">
                <div class="card-body p-3">
                    <div class="row align-items-center">
                        <div class="col-md-6">
                            <label class="form-label small fw-medium mb-2">Chọn sự kiện</label>
                            <select class="form-select glass-input rounded-3"
                                    onchange="if(this.value) window.location.href='${pageContext.request.contextPath}/organizer/tickets?eventId='+this.value; else window.location.href='${pageContext.request.contextPath}/organizer/tickets'">
                                <option value="">Tất cả sự kiện</option>
                                <c:forEach var="e" items="${events}">
                                    <option value="${e.eventId}" ${param.eventId == e.eventId ? 'selected' : ''}>${e.title}</option>
                                </c:forEach>
                            </select>
                        </div>
                    </div>
                </div>
            </div>

            <%-- Ticket Types Table --%>
            <c:choose>
                <c:when test="${empty ticketTypes}">
                    <div class="card glass-strong border-0 rounded-4 animate-on-scroll">
                        <div class="card-body p-5 text-center">
                            <div class="dash-icon-box mx-auto mb-3" style="width: 80px; height: 80px; background: linear-gradient(135deg, #3b82f6, #6366f1); border-radius: 20px;">
                                <i class="fas fa-ticket-alt fa-2x text-white"></i>
                            </div>
                            <h4 class="fw-bold">Chưa có loại vé nào</h4>
                            <p class="text-muted mb-4">Tạo sự kiện trước, sau đó thêm loại vé!</p>
                            <a href="${pageContext.request.contextPath}/organizer/create-event" class="btn btn-gradient rounded-pill px-4 hover-glow">
                                <i class="fas fa-plus me-2"></i>Tạo sự kiện
                            </a>
                        </div>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="card glass-strong border-0 rounded-4 animate-on-scroll">
                        <div class="card-body p-0">
                            <div class="table-responsive">
                                <table class="table table-glass align-middle mb-0">
                                    <thead>
                                        <tr>
                                            <th class="ps-4">Loại vé</th>
                                            <th>Sự kiện</th>
                                            <th>Giá</th>
                                            <th>Số lượng</th>
                                            <th>Đã bán</th>
                                            <th>Trạng thái</th>
                                            <th class="text-end pe-4">Thao tác</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="tt" items="${ticketTypes}">
                                        <tr class="hover-lift" style="transition: all 0.2s;">
                                            <td class="ps-4">
                                                <div class="d-flex align-items-center gap-3">
                                                    <div class="rounded-3 p-2 text-white" style="background: linear-gradient(135deg, #3b82f6, #6366f1);">
                                                        <i class="fas fa-ticket-alt"></i>
                                                    </div>
                                                    <div>
                                                        <p class="fw-bold mb-0">${tt.typeName}</p>
                                                        <small class="text-muted">${tt.description}</small>
                                                    </div>
                                                </div>
                                            </td>
                                            <td>${tt.eventTitle}</td>
                                            <td class="fw-bold"><fmt:formatNumber value="${tt.price}" type="number" groupingUsed="true"/> đ</td>
                                            <td>${tt.quantity}</td>
                                            <td>
                                                <c:set var="soldPercent" value="${tt.quantity > 0 ? (tt.soldCount * 100 / tt.quantity) : 0}"/>
                                                <div class="d-flex align-items-center gap-2">
                                                    <div class="progress flex-grow-1" style="height: 6px; width: 80px;">
                                                        <div class="progress-bar" style="width: ${soldPercent}%; background: linear-gradient(90deg, #10b981, #06b6d4);"></div>
                                                    </div>
                                                    <span class="small fw-medium">${tt.soldCount}</span>
                                                </div>
                                            </td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${tt.soldCount >= tt.quantity}">
                                                        <span class="badge bg-danger bg-opacity-10 text-danger rounded-pill px-3 py-2">Hết vé</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="badge rounded-pill px-3 py-2" style="background: linear-gradient(135deg, #10b981, #06b6d4); color: white;">Đang bán</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td class="text-end pe-4">
                                                <div class="d-flex gap-1 justify-content-end">
                                                    <button class="btn btn-sm glass rounded-circle" title="Sửa"
                                                            onclick="editTicket(${tt.ticketTypeId}, '${tt.typeName}', ${tt.price}, ${tt.quantity})">
                                                        <i class="fas fa-edit text-primary"></i>
                                                    </button>
                                                    <form method="POST" action="${pageContext.request.contextPath}/organizer/tickets" style="display:inline;">
                                                        <input type="hidden" name="csrf_token" value="${csrf_token}"/>
                                                        <input type="hidden" name="action" value="delete"/>
                                                        <input type="hidden" name="ticketTypeId" value="${tt.ticketTypeId}"/>
                                                        <button type="submit" class="btn btn-sm glass rounded-circle"
                                                                onclick="return confirm('Xóa loại vé ${tt.typeName}?')" title="Xóa">
                                                            <i class="fas fa-trash text-danger"></i>
                                                        </button>
                                                    </form>
                                                </div>
                                            </td>
                                        </tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
</div>

<%-- Add/Edit Ticket Modal --%>
<div class="modal fade modal-glass" id="ticketModal" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered modal-lg">
        <div class="modal-content glass-strong border-0 rounded-4">
            <form method="POST" action="${pageContext.request.contextPath}/organizer/tickets" id="ticketForm">
                <input type="hidden" name="csrf_token" value="${csrf_token}"/>
                <input type="hidden" name="action" value="create" id="ticketAction"/>
                <input type="hidden" name="ticketTypeId" value="" id="ticketId"/>
                <div class="modal-header border-0 pb-0">
                    <h5 class="modal-title fw-bold" id="ticketModalTitle"><i class="fas fa-ticket-alt text-primary me-2"></i>Thêm loại vé mới</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <div class="row">
                        <div class="col-md-6 mb-3">
                            <label class="form-label fw-medium">Sự kiện <span class="text-danger">*</span></label>
                            <select class="form-select glass-input rounded-3" name="eventId" required>
                                <option value="" disabled selected>Chọn sự kiện</option>
                                <c:forEach var="e" items="${events}">
                                    <option value="${e.eventId}">${e.title}</option>
                                </c:forEach>
                            </select>
                        </div>
                        <div class="col-md-6 mb-3">
                            <label class="form-label fw-medium">Tên loại vé <span class="text-danger">*</span></label>
                            <input type="text" class="form-control glass-input rounded-3" name="typeName" id="inputTypeName" placeholder="VD: VIP, Premium, Standard..." required>
                        </div>
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-medium">Mô tả</label>
                        <textarea class="form-control glass-input rounded-3" name="description" rows="2" placeholder="Mô tả quyền lợi loại vé..."></textarea>
                    </div>
                    <div class="row">
                        <div class="col-md-4 mb-3">
                            <label class="form-label fw-medium">Giá vé <span class="text-danger">*</span></label>
                            <div class="input-group">
                                <input type="number" class="form-control glass-input rounded-start-3" name="price" id="inputPrice" placeholder="0" required>
                                <span class="input-group-text bg-transparent border-0">đ</span>
                            </div>
                        </div>
                        <div class="col-md-4 mb-3">
                            <label class="form-label fw-medium">Số lượng <span class="text-danger">*</span></label>
                            <input type="number" class="form-control glass-input rounded-3" name="quantity" id="inputQuantity" placeholder="0" required>
                        </div>
                        <div class="col-md-4 mb-3">
                            <label class="form-label fw-medium">Tối đa/đơn</label>
                            <input type="number" class="form-control glass-input rounded-3" name="maxPerOrder" placeholder="10" value="10">
                        </div>
                    </div>
                </div>
                <div class="modal-footer border-0 pt-0">
                    <button type="button" class="btn btn-light rounded-pill px-4" data-bs-dismiss="modal">Hủy</button>
                    <button type="submit" class="btn btn-gradient rounded-pill px-4 hover-glow">
                        <i class="fas fa-save me-2"></i>Lưu loại vé
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
function editTicket(id, name, price, qty) {
    document.getElementById('ticketAction').value = 'update';
    document.getElementById('ticketId').value = id;
    document.getElementById('inputTypeName').value = name;
    document.getElementById('inputPrice').value = price;
    document.getElementById('inputQuantity').value = qty;
    document.getElementById('ticketModalTitle').innerHTML = '<i class="fas fa-edit text-primary me-2"></i>Chỉnh sửa loại vé';
    new bootstrap.Modal(document.getElementById('ticketModal')).show();
}
</script>

<jsp:include page="../footer.jsp" />
