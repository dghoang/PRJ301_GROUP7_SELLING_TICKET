<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>

<jsp:include page="../header.jsp" />

<div class="container-fluid py-4">
    <div class="row">
        <div class="col-lg-2">
            <jsp:include page="sidebar.jsp">
                <jsp:param name="activePage" value="events"/>
            </jsp:include>
        </div>

        <div class="col-lg-10">
            <div class="d-flex justify-content-between align-items-center mb-4 animate-fadeInDown">
                <h2 class="fw-bold mb-0">📋 Quản lý sự kiện</h2>
            </div>

            <!-- Filter Tabs -->
            <div class="card glass-strong border-0 rounded-4 mb-4 animate-on-scroll">
                <div class="card-body d-flex gap-3 flex-wrap align-items-center p-3">
                    <div class="btn-group btn-group-sm">
                        <button class="btn btn-outline-primary rounded-start-pill active">Chờ duyệt <span class="badge bg-danger ms-1">5</span></button>
                        <button class="btn btn-outline-primary">Đã duyệt</button>
                        <button class="btn btn-outline-primary rounded-end-pill">Từ chối</button>
                    </div>
                    <div class="input-group ms-auto" style="max-width: 280px;">
                        <span class="input-group-text glass border-0"><i class="fas fa-search text-muted"></i></span>
                        <input type="text" class="form-control glass border-0" placeholder="Tìm kiếm sự kiện...">
                    </div>
                </div>
            </div>

            <!-- Events Grid -->
            <div class="row g-4">
                <c:forEach var="event" items="${pendingEvents}">
                    <div class="col-md-6 animate-on-scroll">
                        <div class="card glass-strong border-0 rounded-4 overflow-hidden hover-lift" style="transition: all 0.3s;">
                            <div class="row g-0">
                                <div class="col-4">
                                    <img src="${event.bannerUrl != null ? event.bannerUrl : 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=300'}" class="w-100 h-100" style="object-fit: cover;">
                                </div>
                                <div class="col-8">
                                    <div class="card-body p-3">
                                        <span class="badge bg-warning text-dark rounded-pill mb-2">Chờ duyệt</span>
                                        <h6 class="fw-bold mb-1">${event.title}</h6>
                                        <p class="text-muted small mb-2">
                                            <i class="far fa-calendar me-1"></i>${event.eventDate} •
                                            <i class="fas fa-map-marker-alt ms-2 me-1"></i>${event.location}
                                        </p>
                                        <p class="text-muted small mb-3">
                                            <strong>Organizer:</strong> ${event.organizerName}<br>
                                            <strong>Giá vé:</strong> ${event.priceRange}
                                        </p>
                                        <div class="d-flex gap-2">
                                            <button class="btn btn-sm rounded-pill px-3" style="background: linear-gradient(135deg, #10b981, #06b6d4); color: white;">
                                                <i class="fas fa-check me-1"></i>Duyệt
                                            </button>
                                            <button class="btn btn-sm btn-outline-danger rounded-pill px-3">
                                                <i class="fas fa-times me-1"></i>Từ chối
                                            </button>
                                            <button class="btn btn-sm glass rounded-pill"><i class="fas fa-eye text-primary"></i></button>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </c:forEach>
                <c:if test="${empty pendingEvents}">
                <div class="col-md-6 animate-on-scroll">
                    <div class="card glass-strong border-0 rounded-4 overflow-hidden hover-lift" style="transition: all 0.3s;">
                        <div class="row g-0">
                            <div class="col-4">
                                <img src="https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=300" class="w-100 h-100" style="object-fit: cover;">
                            </div>
                            <div class="col-8">
                                <div class="card-body p-3">
                                    <span class="badge bg-warning text-dark rounded-pill mb-2">Chờ duyệt</span>
                                    <h6 class="fw-bold mb-1">Đêm nhạc Rock Underground</h6>
                                    <p class="text-muted small mb-2">
                                        <i class="far fa-calendar me-1"></i>20/02/2026 •
                                        <i class="fas fa-map-marker-alt ms-2 me-1"></i>Quận 1, HCM
                                    </p>
                                    <p class="text-muted small mb-3">
                                        <strong>Organizer:</strong> Live Nation VN<br>
                                        <strong>Giá vé:</strong> 350.000đ - 1.500.000đ
                                    </p>
                                    <div class="d-flex gap-2">
                                        <button class="btn btn-sm rounded-pill px-3" style="background: linear-gradient(135deg, #10b981, #06b6d4); color: white;">
                                            <i class="fas fa-check me-1"></i>Duyệt
                                        </button>
                                        <button class="btn btn-sm btn-outline-danger rounded-pill px-3">
                                            <i class="fas fa-times me-1"></i>Từ chối
                                        </button>
                                        <button class="btn btn-sm glass rounded-pill"><i class="fas fa-eye text-primary"></i></button>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-md-6 animate-on-scroll stagger-1">
                    <div class="card glass-strong border-0 rounded-4 overflow-hidden hover-lift" style="transition: all 0.3s;">
                        <div class="row g-0">
                            <div class="col-4">
                                <img src="https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=300" class="w-100 h-100" style="object-fit: cover;">
                            </div>
                            <div class="col-8">
                                <div class="card-body p-3">
                                    <span class="badge bg-warning text-dark rounded-pill mb-2">Chờ duyệt</span>
                                    <h6 class="fw-bold mb-1">Tech Conference 2026</h6>
                                    <p class="text-muted small mb-2">
                                        <i class="far fa-calendar me-1"></i>25/02/2026 •
                                        <i class="fas fa-map-marker-alt ms-2 me-1"></i>Quận 7, HCM
                                    </p>
                                    <p class="text-muted small mb-3">
                                        <strong>Organizer:</strong> TechVN<br>
                                        <strong>Giá vé:</strong> 500.000đ - 2.000.000đ
                                    </p>
                                    <div class="d-flex gap-2">
                                        <button class="btn btn-sm rounded-pill px-3" style="background: linear-gradient(135deg, #10b981, #06b6d4); color: white;">
                                            <i class="fas fa-check me-1"></i>Duyệt
                                        </button>
                                        <button class="btn btn-sm btn-outline-danger rounded-pill px-3">
                                            <i class="fas fa-times me-1"></i>Từ chối
                                        </button>
                                        <button class="btn btn-sm glass rounded-pill"><i class="fas fa-eye text-primary"></i></button>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-md-6 animate-on-scroll stagger-2">
                    <div class="card glass-strong border-0 rounded-4 overflow-hidden hover-lift" style="transition: all 0.3s;">
                        <div class="row g-0">
                            <div class="col-4">
                                <img src="https://images.unsplash.com/photo-1501281668745-f7f57925c3b4?w=300" class="w-100 h-100" style="object-fit: cover;">
                            </div>
                            <div class="col-8">
                                <div class="card-body p-3">
                                    <span class="badge bg-warning text-dark rounded-pill mb-2">Chờ duyệt</span>
                                    <h6 class="fw-bold mb-1">EDM Night Festival</h6>
                                    <p class="text-muted small mb-2">
                                        <i class="far fa-calendar me-1"></i>10/03/2026 •
                                        <i class="fas fa-map-marker-alt ms-2 me-1"></i>Thủ Đức, HCM
                                    </p>
                                    <p class="text-muted small mb-3">
                                        <strong>Organizer:</strong> Ravolution<br>
                                        <strong>Giá vé:</strong> 600.000đ - 3.000.000đ
                                    </p>
                                    <div class="d-flex gap-2">
                                        <button class="btn btn-sm rounded-pill px-3" style="background: linear-gradient(135deg, #10b981, #06b6d4); color: white;">
                                            <i class="fas fa-check me-1"></i>Duyệt
                                        </button>
                                        <button class="btn btn-sm btn-outline-danger rounded-pill px-3">
                                            <i class="fas fa-times me-1"></i>Từ chối
                                        </button>
                                        <button class="btn btn-sm glass rounded-pill"><i class="fas fa-eye text-primary"></i></button>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                </c:if>
            </div>
        </div>
    </div>
</div>

<jsp:include page="../footer.jsp" />
