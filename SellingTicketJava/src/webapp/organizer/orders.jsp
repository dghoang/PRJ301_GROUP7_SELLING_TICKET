<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>

<jsp:include page="../header.jsp" />

<div class="container-fluid py-4">
    <div class="row">
        <!-- Sidebar -->
        <div class="col-lg-2">
            <jsp:include page="sidebar.jsp">
                <jsp:param name="activePage" value="orders"/>
            </jsp:include>
        </div>

        <!-- Main Content -->
        <div class="col-lg-10">
            <h2 class="fw-bold mb-4">Đơn hàng</h2>
            
            <!-- Filters -->
            <div class="card glass-strong border-0 rounded-4 mb-4">
                <div class="card-body d-flex gap-3 flex-wrap align-items-center">
                    <select class="form-select" style="width: 200px;">
                        <option>Tất cả sự kiện</option>
                        <option>Đêm nhạc Acoustic</option>
                        <option>Workshop Marketing</option>
                    </select>
                    <select class="form-select" style="width: 150px;">
                        <option>Tất cả trạng thái</option>
                        <option>Đã thanh toán</option>
                        <option>Chờ thanh toán</option>
                        <option>Đã hủy</option>
                    </select>
                    <div class="input-group" style="width: 250px;">
                        <span class="input-group-text"><i class="fas fa-search"></i></span>
                        <input type="text" class="form-control" placeholder="Tìm theo mã đơn...">
                    </div>
                    <button class="btn btn-outline-success ms-auto rounded-pill px-4">
                        <i class="fas fa-download me-2"></i>Xuất Excel
                    </button>
                </div>
            </div>

            <!-- Orders Table -->
            <div class="card glass-strong border-0 rounded-4">
                <div class="card-body">
                    <div class="table-responsive">
                        <table class="table table-hover align-middle">
                            <thead>
                                <tr>
                                    <th>Mã đơn</th>
                                    <th>Khách hàng</th>
                                    <th>Sự kiện</th>
                                    <th>Vé</th>
                                    <th>Tổng tiền</th>
                                    <th>Trạng thái</th>
                                    <th>Ngày</th>
                                </tr>
                            </thead>
                            <tbody>
                                <tr>
                                    <td class="fw-mono">#TB20260215001</td>
                                    <td>
                                        <div>Nguyễn Văn A</div>
                                        <small class="text-muted">nguyenvana@email.com</small>
                                    </td>
                                    <td>Đêm nhạc Acoustic</td>
                                    <td>VIP x 2</td>
                                    <td class="fw-bold">1.500.000đ</td>
                                    <td><span class="badge bg-success rounded-pill">Đã thanh toán</span></td>
                                    <td>04/02/2026</td>
                                </tr>
                                <tr>
                                    <td class="fw-mono">#TB20260215002</td>
                                    <td>
                                        <div>Trần Thị B</div>
                                        <small class="text-muted">tranthib@email.com</small>
                                    </td>
                                    <td>Đêm nhạc Acoustic</td>
                                    <td>Thường x 3</td>
                                    <td class="fw-bold">1.050.000đ</td>
                                    <td><span class="badge bg-success rounded-pill">Đã thanh toán</span></td>
                                    <td>04/02/2026</td>
                                </tr>
                                <tr>
                                    <td class="fw-mono">#TB20260214005</td>
                                    <td>
                                        <div>Lê Văn C</div>
                                        <small class="text-muted">levanc@email.com</small>
                                    </td>
                                    <td>Workshop Marketing</td>
                                    <td>Standard x 1</td>
                                    <td class="fw-bold">500.000đ</td>
                                    <td><span class="badge bg-warning text-dark rounded-pill">Chờ thanh toán</span></td>
                                    <td>03/02/2026</td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<jsp:include page="../footer.jsp" />
