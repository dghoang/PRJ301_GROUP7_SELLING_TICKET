<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>

<jsp:include page="../header.jsp" />

<div class="container-fluid py-4">
    <div class="row">
        <!-- Sidebar -->
        <div class="col-lg-2">
            <jsp:include page="sidebar.jsp">
                <jsp:param name="activePage" value="create-event"/>
            </jsp:include>
        </div>

        <!-- Main Content -->
        <div class="col-lg-10">
            <h2 class="fw-bold mb-4">Tạo sự kiện mới</h2>
            
            <form action="${pageContext.request.contextPath}/organizer/create-event" method="POST" enctype="multipart/form-data">
                <div class="row g-4">
                    <!-- Left Column -->
                    <div class="col-lg-8">
                        <!-- Basic Info -->
                        <div class="card glass-strong border-0 rounded-4 mb-4">
                            <div class="card-body p-4">
                                <h5 class="fw-bold mb-4"><i class="fas fa-info-circle text-primary me-2"></i>Thông tin cơ bản</h5>
                                <div class="mb-3">
                                    <label class="form-label">Tên sự kiện *</label>
                                    <input type="text" class="form-control form-control-lg" name="title" placeholder="VD: Đêm nhạc Acoustic" required>
                                </div>
                                <div class="mb-3">
                                    <label class="form-label">Mô tả *</label>
                                    <textarea class="form-control" name="description" rows="5" placeholder="Mô tả chi tiết về sự kiện..." required></textarea>
                                </div>
                                <div class="row g-3">
                                    <div class="col-md-6">
                                        <label class="form-label">Danh mục *</label>
                                        <select class="form-select" name="category" required>
                                            <option value="">Chọn danh mục</option>
                                            <option value="music">Âm nhạc</option>
                                            <option value="sports">Thể thao</option>
                                            <option value="workshop">Workshop</option>
                                            <option value="food">Ẩm thực</option>
                                            <option value="art">Nghệ thuật</option>
                                        </select>
                                    </div>
                                    <div class="col-md-6">
                                        <label class="form-label">Ảnh bìa *</label>
                                        <input type="file" class="form-control" name="banner" accept="image/*" required>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Date & Location -->
                        <div class="card glass-strong border-0 rounded-4 mb-4">
                            <div class="card-body p-4">
                                <h5 class="fw-bold mb-4"><i class="fas fa-calendar-alt text-primary me-2"></i>Thời gian & Địa điểm</h5>
                                <div class="row g-3">
                                    <div class="col-md-6">
                                        <label class="form-label">Ngày bắt đầu *</label>
                                        <input type="datetime-local" class="form-control" name="startDate" required>
                                    </div>
                                    <div class="col-md-6">
                                        <label class="form-label">Ngày kết thúc</label>
                                        <input type="datetime-local" class="form-control" name="endDate">
                                    </div>
                                    <div class="col-md-6">
                                        <label class="form-label">Địa điểm *</label>
                                        <input type="text" class="form-control" name="location" placeholder="VD: Nhà hát Thành phố" required>
                                    </div>
                                    <div class="col-md-6">
                                        <label class="form-label">Địa chỉ chi tiết</label>
                                        <input type="text" class="form-control" name="address" placeholder="Số nhà, đường, quận...">
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Tickets -->
                        <div class="card glass-strong border-0 rounded-4">
                            <div class="card-body p-4">
                                <h5 class="fw-bold mb-4"><i class="fas fa-ticket-alt text-primary me-2"></i>Loại vé</h5>
                                <div id="ticketTypes">
                                    <div class="glass p-3 rounded-3 mb-3">
                                        <div class="row g-3">
                                            <div class="col-md-4">
                                                <label class="form-label">Tên loại vé</label>
                                                <input type="text" class="form-control" name="ticketName[]" placeholder="VD: Vé VIP">
                                            </div>
                                            <div class="col-md-3">
                                                <label class="form-label">Giá (VNĐ)</label>
                                                <input type="number" class="form-control" name="ticketPrice[]" placeholder="500000">
                                            </div>
                                            <div class="col-md-3">
                                                <label class="form-label">Số lượng</label>
                                                <input type="number" class="form-control" name="ticketQuantity[]" placeholder="100">
                                            </div>
                                            <div class="col-md-2 d-flex align-items-end">
                                                <button type="button" class="btn btn-outline-danger w-100"><i class="fas fa-trash"></i></button>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <button type="button" class="btn btn-outline-primary rounded-pill" onclick="addTicketType()">
                                    <i class="fas fa-plus me-2"></i>Thêm loại vé
                                </button>
                            </div>
                        </div>
                    </div>

                    <!-- Right Column -->
                    <div class="col-lg-4">
                        <div class="card glass-strong border-0 rounded-4 sticky-top" style="top: 80px;">
                            <div class="card-body p-4">
                                <h5 class="fw-bold mb-4">Xuất bản</h5>
                                <div class="mb-3">
                                    <label class="form-label">Trạng thái</label>
                                    <select class="form-select" name="status">
                                        <option value="draft">Bản nháp</option>
                                        <option value="pending">Gửi duyệt</option>
                                    </select>
                                </div>
                                <div class="mb-3">
                                    <div class="form-check">
                                        <input class="form-check-input" type="checkbox" name="isPrivate" id="isPrivate">
                                        <label class="form-check-label" for="isPrivate">Sự kiện riêng tư</label>
                                    </div>
                                </div>
                                <hr>
                                <div class="d-grid gap-2">
                                    <button type="submit" class="btn btn-gradient btn-lg rounded-pill">
                                        <i class="fas fa-save me-2"></i>Lưu sự kiện
                                    </button>
                                    <button type="button" class="btn btn-outline-secondary rounded-pill">Xem trước</button>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
function addTicketType() {
    const container = document.getElementById('ticketTypes');
    const ticketHtml = `
        <div class="glass p-3 rounded-3 mb-3">
            <div class="row g-3">
                <div class="col-md-4">
                    <label class="form-label">Tên loại vé</label>
                    <input type="text" class="form-control" name="ticketName[]" placeholder="VD: Vé thường">
                </div>
                <div class="col-md-3">
                    <label class="form-label">Giá (VNĐ)</label>
                    <input type="number" class="form-control" name="ticketPrice[]" placeholder="300000">
                </div>
                <div class="col-md-3">
                    <label class="form-label">Số lượng</label>
                    <input type="number" class="form-control" name="ticketQuantity[]" placeholder="200">
                </div>
                <div class="col-md-2 d-flex align-items-end">
                    <button type="button" class="btn btn-outline-danger w-100" onclick="this.closest('.glass').remove()"><i class="fas fa-trash"></i></button>
                </div>
            </div>
        </div>
    `;
    container.insertAdjacentHTML('beforeend', ticketHtml);
}
</script>

<jsp:include page="../footer.jsp" />
