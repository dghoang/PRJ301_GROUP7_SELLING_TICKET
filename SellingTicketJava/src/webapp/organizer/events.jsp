<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>

<jsp:include page="../header.jsp" />

<div class="container-fluid py-4">
    <div class="row">
        <!-- Sidebar -->
        <div class="col-lg-2">
            <jsp:include page="sidebar.jsp">
                <jsp:param name="activePage" value="events"/>
            </jsp:include>
        </div>

        <!-- Main Content -->
        <div class="col-lg-10">
            <div class="d-flex justify-content-between align-items-center mb-4">
                <h2 class="fw-bold mb-0">Sự kiện của tôi</h2>
                <a href="${pageContext.request.contextPath}/organizer/create-event" class="btn btn-gradient rounded-pill px-4">
                    <i class="fas fa-plus me-2"></i>Tạo sự kiện
                </a>
            </div>

            <!-- Filter -->
            <div class="btn-group mb-4">
                <button class="btn btn-outline-primary active">Tất cả (12)</button>
                <button class="btn btn-outline-primary">Đang bán (5)</button>
                <button class="btn btn-outline-primary">Chờ duyệt (2)</button>
                <button class="btn btn-outline-primary">Nháp (3)</button>
                <button class="btn btn-outline-primary">Đã kết thúc (2)</button>
            </div>

            <!-- Events Grid -->
            <div class="row g-4">
                <c:forEach var="i" begin="1" end="6">
                    <div class="col-md-6 col-lg-4">
                        <div class="card glass-strong border-0 rounded-4 overflow-hidden card-hover">
                            <div class="position-relative">
                                <img src="https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=400" class="card-img-top" style="height: 160px; object-fit: cover;">
                                <span class="badge bg-success position-absolute top-0 end-0 m-2">Đang bán</span>
                            </div>
                            <div class="card-body">
                                <h6 class="fw-bold mb-2">Đêm nhạc Acoustic ${i}</h6>
                                <p class="text-muted small mb-2">
                                    <i class="far fa-calendar me-1"></i>15/02/2026 •
                                    <i class="fas fa-map-marker-alt ms-2 me-1"></i>Quận 1
                                </p>
                                <div class="d-flex justify-content-between align-items-center mb-3">
                                    <span class="small"><strong>450</strong>/500 vé</span>
                                    <span class="text-success fw-bold">180M đ</span>
                                </div>
                                <div class="d-flex gap-2">
                                    <a href="#" class="btn btn-sm btn-outline-primary flex-grow-1 rounded-pill">
                                        <i class="fas fa-edit me-1"></i>Sửa
                                    </a>
                                    <button class="btn btn-sm btn-outline-secondary rounded-pill">
                                        <i class="fas fa-chart-bar"></i>
                                    </button>
                                    <button class="btn btn-sm btn-outline-danger rounded-pill">
                                        <i class="fas fa-trash"></i>
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>
                </c:forEach>
            </div>
        </div>
    </div>
</div>

<jsp:include page="../footer.jsp" />
