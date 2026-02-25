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
                <h2 class="fw-bold mb-0">🎤 Sự kiện của tôi</h2>
                <a href="${pageContext.request.contextPath}/organizer/create-event" class="btn btn-gradient rounded-pill px-4 hover-glow">
                    <i class="fas fa-plus me-2"></i>Tạo sự kiện
                </a>
            </div>

            <!-- Filter -->
            <div class="card glass-strong border-0 rounded-4 mb-4 animate-on-scroll">
                <div class="card-body d-flex gap-3 flex-wrap align-items-center p-3">
                    <div class="btn-group btn-group-sm">
                        <button class="btn btn-outline-primary rounded-start-pill active">Tất cả <span class="badge bg-primary ms-1">12</span></button>
                        <button class="btn btn-outline-primary">Đang bán <span class="badge bg-success ms-1">5</span></button>
                        <button class="btn btn-outline-primary">Chờ duyệt <span class="badge bg-warning text-dark ms-1">2</span></button>
                        <button class="btn btn-outline-primary">Nháp <span class="badge bg-secondary ms-1">3</span></button>
                        <button class="btn btn-outline-primary rounded-end-pill">Đã kết thúc <span class="badge bg-dark ms-1">2</span></button>
                    </div>
                    <div class="input-group ms-auto" style="max-width: 250px;">
                        <span class="input-group-text glass border-0"><i class="fas fa-search text-muted"></i></span>
                        <input type="text" class="form-control glass border-0" placeholder="Tìm sự kiện...">
                    </div>
                </div>
            </div>

            <!-- Events Grid -->
            <div class="row g-4">
                <c:forEach var="event" items="${events}">
                    <div class="col-md-6 col-lg-4 animate-on-scroll">
                        <div class="card glass-strong border-0 rounded-4 overflow-hidden hover-lift h-100" style="transition: all 0.3s;">
                            <div class="position-relative">
                                <img src="${event.bannerUrl != null ? event.bannerUrl : 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=400'}" class="card-img-top" style="height: 160px; object-fit: cover;">
                                <span class="badge position-absolute top-0 end-0 m-2 rounded-pill px-3 py-2"
                                      style="background: ${event.status == 'ACTIVE' ? 'linear-gradient(135deg,#10b981,#06b6d4)' : event.status == 'PENDING' ? '#f59e0b' : '#94a3b8'}; color: white;">
                                    ${event.status == 'ACTIVE' ? 'Đang bán' : event.status == 'PENDING' ? 'Chờ duyệt' : 'Nháp'}
                                </span>
                            </div>
                            <div class="card-body p-3">
                                <h6 class="fw-bold mb-2">${event.title}</h6>
                                <p class="text-muted small mb-2">
                                    <i class="far fa-calendar me-1"></i>${event.eventDate} •
                                    <i class="fas fa-map-marker-alt ms-2 me-1"></i>${event.location}
                                </p>
                                <div class="d-flex justify-content-between align-items-center mb-3">
                                    <span class="small"><strong>${event.soldTickets}</strong>/${event.totalTickets} vé</span>
                                    <span class="text-success fw-bold">${event.revenue}</span>
                                </div>
                                <div class="d-flex gap-2">
                                    <a href="${pageContext.request.contextPath}/organizer/events?action=edit&id=${event.eventId}" class="btn btn-sm btn-outline-primary flex-grow-1 rounded-pill">
                                        <i class="fas fa-edit me-1"></i>Sửa
                                    </a>
                                    <button class="btn btn-sm glass rounded-pill"><i class="fas fa-chart-bar text-primary"></i></button>
                                    <button class="btn btn-sm glass rounded-pill"><i class="fas fa-trash text-danger"></i></button>
                                </div>
                            </div>
                        </div>
                    </div>
                </c:forEach>
                <c:if test="${empty events}">
                <div class="col-md-6 col-lg-4 animate-on-scroll">
                    <div class="card glass-strong border-0 rounded-4 overflow-hidden hover-lift h-100" style="transition: all 0.3s;">
                        <div class="position-relative">
                            <img src="https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=400" class="card-img-top" style="height: 160px; object-fit: cover;">
                            <span class="badge position-absolute top-0 end-0 m-2 rounded-pill px-3 py-2" style="background: linear-gradient(135deg,#10b981,#06b6d4); color: white;">Đang bán</span>
                        </div>
                        <div class="card-body p-3">
                            <h6 class="fw-bold mb-2">Đêm nhạc Acoustic</h6>
                            <p class="text-muted small mb-2"><i class="far fa-calendar me-1"></i>15/02/2026 • <i class="fas fa-map-marker-alt ms-2 me-1"></i>Quận 1</p>
                            <div class="d-flex justify-content-between align-items-center mb-3">
                                <span class="small"><strong>450</strong>/500 vé</span>
                                <span class="text-success fw-bold">180M đ</span>
                            </div>
                            <div class="d-flex gap-2">
                                <a href="#" class="btn btn-sm btn-outline-primary flex-grow-1 rounded-pill"><i class="fas fa-edit me-1"></i>Sửa</a>
                                <button class="btn btn-sm glass rounded-pill"><i class="fas fa-chart-bar text-primary"></i></button>
                                <button class="btn btn-sm glass rounded-pill"><i class="fas fa-trash text-danger"></i></button>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-md-6 col-lg-4 animate-on-scroll stagger-1">
                    <div class="card glass-strong border-0 rounded-4 overflow-hidden hover-lift h-100" style="transition: all 0.3s;">
                        <div class="position-relative">
                            <img src="https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=400" class="card-img-top" style="height: 160px; object-fit: cover;">
                            <span class="badge position-absolute top-0 end-0 m-2 rounded-pill px-3 py-2" style="background: linear-gradient(135deg,#10b981,#06b6d4); color: white;">Đang bán</span>
                        </div>
                        <div class="card-body p-3">
                            <h6 class="fw-bold mb-2">Workshop Marketing</h6>
                            <p class="text-muted small mb-2"><i class="far fa-calendar me-1"></i>20/02/2026 • <i class="fas fa-map-marker-alt ms-2 me-1"></i>Quận 3</p>
                            <div class="d-flex justify-content-between align-items-center mb-3">
                                <span class="small"><strong>80</strong>/100 vé</span>
                                <span class="text-success fw-bold">40M đ</span>
                            </div>
                            <div class="d-flex gap-2">
                                <a href="#" class="btn btn-sm btn-outline-primary flex-grow-1 rounded-pill"><i class="fas fa-edit me-1"></i>Sửa</a>
                                <button class="btn btn-sm glass rounded-pill"><i class="fas fa-chart-bar text-primary"></i></button>
                                <button class="btn btn-sm glass rounded-pill"><i class="fas fa-trash text-danger"></i></button>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-md-6 col-lg-4 animate-on-scroll stagger-2">
                    <div class="card glass-strong border-0 rounded-4 overflow-hidden hover-lift h-100" style="transition: all 0.3s;">
                        <div class="position-relative">
                            <img src="https://images.unsplash.com/photo-1501281668745-f7f57925c3b4?w=400" class="card-img-top" style="height: 160px; object-fit: cover;">
                            <span class="badge bg-warning text-dark position-absolute top-0 end-0 m-2 rounded-pill px-3 py-2">Chờ duyệt</span>
                        </div>
                        <div class="card-body p-3">
                            <h6 class="fw-bold mb-2">EDM Night Festival</h6>
                            <p class="text-muted small mb-2"><i class="far fa-calendar me-1"></i>28/02/2026 • <i class="fas fa-map-marker-alt ms-2 me-1"></i>Thủ Đức</p>
                            <div class="d-flex justify-content-between align-items-center mb-3">
                                <span class="small"><strong>1,200</strong>/2,000 vé</span>
                                <span class="text-success fw-bold">600M đ</span>
                            </div>
                            <div class="d-flex gap-2">
                                <a href="#" class="btn btn-sm btn-outline-primary flex-grow-1 rounded-pill"><i class="fas fa-edit me-1"></i>Sửa</a>
                                <button class="btn btn-sm glass rounded-pill"><i class="fas fa-chart-bar text-primary"></i></button>
                                <button class="btn btn-sm glass rounded-pill"><i class="fas fa-trash text-danger"></i></button>
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
