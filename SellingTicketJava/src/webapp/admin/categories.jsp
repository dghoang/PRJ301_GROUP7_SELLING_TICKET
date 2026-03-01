<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>

<jsp:include page="../header.jsp" />

<div class="container-fluid py-4">
    <div class="row">
        <!-- Sidebar -->
        <div class="col-lg-2">
            <jsp:include page="sidebar.jsp">
                <jsp:param name="activePage" value="categories"/>
            </jsp:include>
        </div>

        <!-- Main Content -->
        <div class="col-lg-10">
            <div class="d-flex justify-content-between align-items-center mb-4 animate-fadeInDown">
                <div>
                    <h2 class="fw-bold mb-1">Quản lý danh mục</h2>
                    <p class="text-muted mb-0">Tạo và quản lý các danh mục sự kiện</p>
                </div>
                <button class="btn btn-gradient rounded-pill px-4" data-bs-toggle="modal" data-bs-target="#categoryModal"
                        onclick="openAddModal()">
                    <i class="fas fa-plus me-2"></i>Thêm danh mục
                </button>
            </div>

            <%-- Success/Error Alerts --%>
            <c:if test="${param.success != null}">
                <div class="alert glass-strong border-0 rounded-4 alert-dismissible fade show mb-4 animate-fadeInDown" role="alert"
                     style="background: rgba(16,185,129,0.1); border-left: 4px solid #10b981 !important;">
                    <i class="fas fa-check-circle text-success me-2"></i>
                    <c:choose>
                        <c:when test="${param.success == 'created'}">Danh mục đã được tạo thành công!</c:when>
                        <c:when test="${param.success == 'updated'}">Danh mục đã được cập nhật!</c:when>
                        <c:when test="${param.success == 'deleted'}">Danh mục đã được xóa!</c:when>
                        <c:otherwise>Thao tác thành công!</c:otherwise>
                    </c:choose>
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            </c:if>
            <c:if test="${param.error != null}">
                <div class="alert glass-strong border-0 rounded-4 alert-dismissible fade show mb-4 animate-fadeInDown" role="alert"
                     style="background: rgba(239,68,68,0.1); border-left: 4px solid #ef4444 !important;">
                    <i class="fas fa-exclamation-circle text-danger me-2"></i>
                    <c:choose>
                        <c:when test="${param.error == 'has_events'}">Không thể xóa danh mục đang có sự kiện!</c:when>
                        <c:when test="${param.error == 'create_failed'}">Tạo danh mục thất bại. Kiểm tra lại thông tin!</c:when>
                        <c:when test="${param.error == 'update_failed'}">Cập nhật danh mục thất bại!</c:when>
                        <c:when test="${param.error == 'delete_failed'}">Xóa danh mục thất bại!</c:when>
                        <c:otherwise>Có lỗi xảy ra!</c:otherwise>
                    </c:choose>
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            </c:if>

            <%-- Stats --%>
            <div class="row g-3 mb-4">
                <div class="col-md-4 animate-on-scroll">
                    <div class="card glass-strong border-0 rounded-4 hover-lift">
                        <div class="card-body d-flex align-items-center gap-3 p-3">
                            <div class="dash-icon-box" style="width: 44px; height: 44px; background: linear-gradient(135deg, #9333ea, #a855f7);">
                                <i class="fas fa-tags text-white"></i>
                            </div>
                            <div>
                                <h4 class="fw-bold mb-0">${categories.size()}</h4>
                                <small class="text-muted">Tổng danh mục</small>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-md-4 animate-on-scroll stagger-1">
                    <div class="card glass-strong border-0 rounded-4 hover-lift">
                        <div class="card-body d-flex align-items-center gap-3 p-3">
                            <div class="dash-icon-box" style="width: 44px; height: 44px; background: linear-gradient(135deg, #10b981, #06b6d4);">
                                <i class="fas fa-calendar-check text-white"></i>
                            </div>
                            <div>
                                <c:set var="totalCatEvents" value="0"/>
                                <c:forEach var="cat" items="${categories}">
                                    <c:set var="totalCatEvents" value="${totalCatEvents + cat.eventCount}"/>
                                </c:forEach>
                                <h4 class="fw-bold mb-0">${totalCatEvents}</h4>
                                <small class="text-muted">Tổng sự kiện</small>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-md-4 animate-on-scroll stagger-2">
                    <div class="card glass-strong border-0 rounded-4 hover-lift">
                        <div class="card-body d-flex align-items-center gap-3 p-3">
                            <div class="dash-icon-box" style="width: 44px; height: 44px; background: linear-gradient(135deg, #f59e0b, #f97316);">
                                <i class="fas fa-chart-pie text-white"></i>
                            </div>
                            <div>
                                <h4 class="fw-bold mb-0">
                                    <c:choose>
                                        <c:when test="${totalCatEvents > 0 && categories.size() > 0}">
                                            ~${Math.round(totalCatEvents / categories.size())}
                                        </c:when>
                                        <c:otherwise>0</c:otherwise>
                                    </c:choose>
                                </h4>
                                <small class="text-muted">TB sự kiện/danh mục</small>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <%-- Categories Grid --%>
            <c:choose>
                <c:when test="${empty categories}">
                    <div class="card glass-strong border-0 rounded-4 animate-on-scroll">
                        <div class="card-body p-5 text-center">
                            <div class="dash-icon-box mx-auto mb-3" style="width: 80px; height: 80px; background: linear-gradient(135deg, #9333ea, #a855f7); border-radius: 20px;">
                                <i class="fas fa-tags fa-2x text-white"></i>
                            </div>
                            <h4 class="fw-bold">Chưa có danh mục nào</h4>
                            <p class="text-muted">Hãy tạo danh mục đầu tiên để phân loại sự kiện!</p>
                            <button class="btn btn-gradient rounded-pill px-4" data-bs-toggle="modal" data-bs-target="#categoryModal"
                                    onclick="openAddModal()">
                                <i class="fas fa-plus me-2"></i>Tạo danh mục
                            </button>
                        </div>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="row g-4">
                        <c:forEach var="cat" items="${categories}" varStatus="loop">
                        <div class="col-md-4 col-lg-3 animate-on-scroll stagger-${loop.index % 4}">
                            <div class="card glass-strong border-0 rounded-4 card-hover hover-lift h-100" style="transition: all 0.3s;">
                                <div class="card-body p-4 text-center">
                                    <div class="mx-auto mb-3 rounded-circle d-flex align-items-center justify-content-center"
                                         style="width: 64px; height: 64px; background: linear-gradient(135deg, var(--primary), var(--secondary));">
                                        <i class="fas ${not empty cat.icon ? cat.icon : 'fa-folder'} fa-lg text-white"></i>
                                    </div>
                                    <h6 class="fw-bold mb-1">${cat.name}</h6>
                                    <p class="text-muted small mb-1">${cat.eventCount} sự kiện</p>
                                    <c:if test="${not empty cat.description}">
                                        <p class="text-muted small mb-3" style="font-size: 0.75rem;">${cat.description}</p>
                                    </c:if>
                                    <c:if test="${empty cat.description}">
                                        <p class="mb-3"></p>
                                    </c:if>
                                    <div class="d-flex gap-2 justify-content-center">
                                        <button class="btn btn-sm btn-light rounded-circle" title="Chỉnh sửa"
                                                onclick="openEditModal(${cat.categoryId}, '${cat.name}', '${cat.icon}', '${cat.description}')">
                                            <i class="fas fa-edit"></i>
                                        </button>
                                        <button class="btn btn-sm btn-light rounded-circle text-danger" title="Xóa"
                                                onclick="confirmDelete(${cat.categoryId}, '${cat.name}', ${cat.eventCount})">
                                            <i class="fas fa-trash"></i>
                                        </button>
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

<%-- Add/Edit Category Modal --%>
<div class="modal fade modal-glass" id="categoryModal" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content glass-strong border-0 rounded-4">
            <form id="categoryForm" method="POST">
                <input type="hidden" name="csrf_token" value="${sessionScope.csrf_token}"/>
                <input type="hidden" name="categoryId" id="editCategoryId"/>
                <div class="modal-header border-0 pb-0">
                    <h5 class="modal-title fw-bold" id="categoryModalTitle">Thêm danh mục mới</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <div class="mb-3">
                        <label class="form-label fw-medium">Tên danh mục <span class="text-danger">*</span></label>
                        <input type="text" class="form-control glass-input rounded-3" name="name" id="catName" placeholder="VD: Âm nhạc, Workshop..." required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-medium">Icon (Font Awesome class)</label>
                        <input type="text" class="form-control glass-input rounded-3" name="icon" id="catIcon" placeholder="VD: fa-music, fa-running">
                        <small class="text-muted">Tham khảo: <a href="https://fontawesome.com/icons" target="_blank">fontawesome.com/icons</a></small>
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-medium">Mô tả</label>
                        <textarea class="form-control glass-input rounded-3" name="description" id="catDesc" rows="2" placeholder="Mô tả ngắn về danh mục..."></textarea>
                    </div>
                </div>
                <div class="modal-footer border-0 pt-0">
                    <button type="button" class="btn btn-light rounded-pill px-4" data-bs-dismiss="modal">Hủy</button>
                    <button type="submit" class="btn btn-gradient rounded-pill px-4">
                        <i class="fas fa-save me-2"></i><span id="categorySubmitText">Tạo danh mục</span>
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<%-- Delete Confirmation Modal --%>
<div class="modal fade modal-glass" id="deleteModal" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered modal-sm">
        <div class="modal-content glass-strong border-0 rounded-4">
            <form method="POST" action="${pageContext.request.contextPath}/admin/categories/delete">
                <input type="hidden" name="csrf_token" value="${sessionScope.csrf_token}"/>
                <input type="hidden" name="categoryId" id="deleteCategoryId"/>
                <div class="modal-body text-center p-4">
                    <div class="mx-auto mb-3 rounded-circle d-flex align-items-center justify-content-center"
                         style="width: 64px; height: 64px; background: rgba(239,68,68,0.1);">
                        <i class="fas fa-trash fa-lg text-danger"></i>
                    </div>
                    <h6 class="fw-bold mb-2">Xóa danh mục?</h6>
                    <p class="text-muted small mb-0">Bạn có chắc muốn xóa <strong id="deleteCategoryName"></strong>?</p>
                    <p class="text-danger small mt-1 mb-0" id="deleteEventWarning" style="display:none;">
                        <i class="fas fa-exclamation-triangle me-1"></i>Danh mục này đang có sự kiện!
                    </p>
                </div>
                <div class="modal-footer border-0 pt-0 justify-content-center gap-2">
                    <button type="button" class="btn btn-light rounded-pill px-4" data-bs-dismiss="modal">Hủy</button>
                    <button type="submit" class="btn btn-danger rounded-pill px-4">
                        <i class="fas fa-trash me-1"></i>Xóa
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
var basePath = '${pageContext.request.contextPath}';
function openAddModal() {
    document.getElementById('categoryForm').action = basePath + '/admin/categories/create';
    document.getElementById('categoryModalTitle').textContent = 'Thêm danh mục mới';
    document.getElementById('categorySubmitText').textContent = 'Tạo danh mục';
    document.getElementById('editCategoryId').value = '';
    document.getElementById('catName').value = '';
    document.getElementById('catIcon').value = '';
    document.getElementById('catDesc').value = '';
}
function openEditModal(id, name, icon, desc) {
    document.getElementById('categoryForm').action = basePath + '/admin/categories/update';
    document.getElementById('categoryModalTitle').textContent = 'Chỉnh sửa danh mục';
    document.getElementById('categorySubmitText').textContent = 'Cập nhật';
    document.getElementById('editCategoryId').value = id;
    document.getElementById('catName').value = name;
    document.getElementById('catIcon').value = icon || '';
    document.getElementById('catDesc').value = desc || '';
    new bootstrap.Modal(document.getElementById('categoryModal')).show();
}
function confirmDelete(id, name, eventCount) {
    document.getElementById('deleteCategoryId').value = id;
    document.getElementById('deleteCategoryName').textContent = name;
    document.getElementById('deleteEventWarning').style.display = eventCount > 0 ? '' : 'none';
    new bootstrap.Modal(document.getElementById('deleteModal')).show();
}
</script>

<jsp:include page="../footer.jsp" />
