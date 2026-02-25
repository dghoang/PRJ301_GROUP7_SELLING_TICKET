<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>

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
            <h2 class="fw-bold mb-4 animate-fadeInDown">🎫 Check-in khách</h2>

            <div class="row g-4">
                <!-- QR Scanner -->
                <div class="col-lg-6 animate-on-scroll">
                    <div class="card glass-strong border-0 rounded-4">
                        <div class="card-body p-4 text-center">
                            <h5 class="fw-bold mb-4"><i class="fas fa-qrcode text-primary me-2"></i>Quét mã QR</h5>
                            <div class="bg-dark rounded-4 p-5 mb-4" style="min-height: 300px;">
                                <div class="d-flex align-items-center justify-content-center h-100">
                                    <div class="text-white">
                                        <i class="fas fa-camera fa-4x mb-3 opacity-50"></i>
                                        <p>Camera sẽ hiển thị ở đây</p>
                                        <button class="btn btn-gradient rounded-pill px-4 mt-2">
                                            <i class="fas fa-video me-2"></i>Bật Camera
                                        </button>
                                    </div>
                                </div>
                            </div>
                            <p class="text-muted small">Hướng camera vào mã QR trên vé của khách</p>
                        </div>
                    </div>
                </div>

                <!-- Manual Input + Stats -->
                <div class="col-lg-6 animate-on-scroll stagger-1">
                    <!-- Manual Input -->
                    <div class="card glass-strong border-0 rounded-4 mb-4">
                        <div class="card-body p-4">
                            <h5 class="fw-bold mb-3"><i class="fas fa-keyboard text-primary me-2"></i>Nhập mã thủ công</h5>
                            <form class="d-flex gap-2">
                                <input type="text" class="form-control form-control-lg" placeholder="Nhập mã vé (VD: TB20260215001)">
                                <button type="submit" class="btn btn-gradient px-4">Check-in</button>
                            </form>
                        </div>
                    </div>

                    <!-- Today Stats -->
                    <div class="card glass-strong border-0 rounded-4 mb-4">
                        <div class="card-body p-4">
                            <h5 class="fw-bold mb-3">Thống kê hôm nay</h5>
                            <div class="row g-3 text-center">
                                <div class="col-4">
                                    <div class="bg-success bg-opacity-10 rounded-3 p-3">
                                        <h3 class="fw-bold text-success mb-0">245</h3>
                                        <small class="text-muted">Đã check-in</small>
                                    </div>
                                </div>
                                <div class="col-4">
                                    <div class="bg-warning bg-opacity-10 rounded-3 p-3">
                                        <h3 class="fw-bold text-warning mb-0">155</h3>
                                        <small class="text-muted">Chưa đến</small>
                                    </div>
                                </div>
                                <div class="col-4">
                                    <div class="bg-primary bg-opacity-10 rounded-3 p-3">
                                        <h3 class="fw-bold text-primary mb-0">61%</h3>
                                        <small class="text-muted">Tỷ lệ</small>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Recent Check-ins -->
                    <div class="card glass-strong border-0 rounded-4">
                        <div class="card-body p-4">
                            <h5 class="fw-bold mb-3">Check-in gần đây</h5>
                            <div class="list-group list-group-flush">
                                <div class="list-group-item bg-transparent d-flex justify-content-between align-items-center px-0">
                                    <div>
                                        <p class="mb-0 fw-medium">Nguyễn Văn A</p>
                                        <small class="text-muted">Vé VIP • #TB001</small>
                                    </div>
                                    <small class="text-success"><i class="fas fa-check-circle me-1"></i>10:30</small>
                                </div>
                                <div class="list-group-item bg-transparent d-flex justify-content-between align-items-center px-0">
                                    <div>
                                        <p class="mb-0 fw-medium">Trần Thị B</p>
                                        <small class="text-muted">Vé thường • #TB002</small>
                                    </div>
                                    <small class="text-success"><i class="fas fa-check-circle me-1"></i>10:28</small>
                                </div>
                                <div class="list-group-item bg-transparent d-flex justify-content-between align-items-center px-0">
                                    <div>
                                        <p class="mb-0 fw-medium">Lê Văn C</p>
                                        <small class="text-muted">Vé VIP • #TB003</small>
                                    </div>
                                    <small class="text-success"><i class="fas fa-check-circle me-1"></i>10:25</small>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<jsp:include page="../footer.jsp" />
