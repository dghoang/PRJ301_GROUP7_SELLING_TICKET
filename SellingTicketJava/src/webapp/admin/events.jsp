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
                <h2 class="fw-bold mb-0">Phê duyệt sự kiện</h2>
                <div class="btn-group">
                    <button class="btn btn-outline-primary active">Chờ duyệt (5)</button>
                    <button class="btn btn-outline-primary">Đã duyệt</button>
                    <button class="btn btn-outline-primary">Từ chối</button>
                </div>
            </div>

            <!-- Events List -->
            <div class="row g-4">
                <c:forEach var="i" begin="1" end="4">
                    <div class="col-md-6">
                        <div class="card glass-strong border-0 rounded-4 overflow-hidden">
                            <div class="row g-0">
                                <div class="col-4">
                                    <img src="https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=300" class="w-100 h-100" style="object-fit: cover;">
                                </div>
                                <div class="col-8">
                                    <div class="card-body">
                                        <span class="badge bg-warning text-dark rounded-pill mb-2">Chờ duyệt</span>
                                        <h5 class="fw-bold mb-1">Đêm nhạc Acoustic ${i}</h5>
                                        <p class="text-muted small mb-2">
                                            <i class="far fa-calendar me-1"></i>15/02/2026 •
                                            <i class="fas fa-map-marker-alt ms-2 me-1"></i>Quận 1, HCM
                                        </p>
                                        <p class="text-muted small mb-3">
                                            <strong>Organizer:</strong> Live Nation VN<br>
                                            <strong>Giá vé:</strong> 350.000đ - 1.500.000đ
                                        </p>
                                        <div class="d-flex gap-2">
                                            <button class="btn btn-success btn-sm rounded-pill px-3">
                                                <i class="fas fa-check me-1"></i>Duyệt
                                            </button>
                                            <button class="btn btn-danger btn-sm rounded-pill px-3">
                                                <i class="fas fa-times me-1"></i>Từ chối
                                            </button>
                                            <button class="btn btn-outline-secondary btn-sm rounded-pill">
                                                <i class="fas fa-eye"></i>
                                            </button>
                                        </div>
                                    </div>
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
