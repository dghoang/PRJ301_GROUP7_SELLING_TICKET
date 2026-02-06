<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>

<jsp:include page="../header.jsp" />

<div class="container-fluid py-4">
    <div class="row">
        <!-- Sidebar -->
        <div class="col-lg-2">
            <jsp:include page="sidebar.jsp">
                <jsp:param name="activePage" value="statistics"/>
            </jsp:include>
        </div>

        <!-- Main Content -->
        <div class="col-lg-10">
            <h2 class="fw-bold mb-4">Thống kê</h2>

            <!-- Stats Overview -->
            <div class="row g-4 mb-4">
                <div class="col-md-3">
                    <div class="card glass-strong border-0 rounded-4 text-center p-4">
                        <h2 class="fw-bold text-primary mb-1">850M đ</h2>
                        <p class="text-muted small mb-0">Tổng doanh thu</p>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="card glass-strong border-0 rounded-4 text-center p-4">
                        <h2 class="fw-bold text-success mb-1">2,458</h2>
                        <p class="text-muted small mb-0">Vé đã bán</p>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="card glass-strong border-0 rounded-4 text-center p-4">
                        <h2 class="fw-bold text-warning mb-1">12</h2>
                        <p class="text-muted small mb-0">Sự kiện</p>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="card glass-strong border-0 rounded-4 text-center p-4">
                        <h2 class="fw-bold text-info mb-1">4.8</h2>
                        <p class="text-muted small mb-0">Đánh giá TB</p>
                    </div>
                </div>
            </div>

            <div class="row g-4">
                <!-- Revenue by Event -->
                <div class="col-lg-8">
                    <div class="card glass-strong border-0 rounded-4">
                        <div class="card-header bg-transparent border-0">
                            <h5 class="fw-bold mb-0">Doanh thu theo sự kiện</h5>
                        </div>
                        <div class="card-body">
                            <div class="table-responsive">
                                <table class="table align-middle">
                                    <thead>
                                        <tr>
                                            <th>Sự kiện</th>
                                            <th>Vé bán</th>
                                            <th>Doanh thu</th>
                                            <th>Tỷ lệ</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <tr>
                                            <td>Đêm nhạc Acoustic</td>
                                            <td>450</td>
                                            <td class="fw-bold">450M đ</td>
                                            <td>
                                                <div class="progress" style="height: 8px; width: 100px;">
                                                    <div class="progress-bar bg-primary" style="width: 53%;"></div>
                                                </div>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>Rock Festival</td>
                                            <td>320</td>
                                            <td class="fw-bold">280M đ</td>
                                            <td>
                                                <div class="progress" style="height: 8px; width: 100px;">
                                                    <div class="progress-bar bg-success" style="width: 33%;"></div>
                                                </div>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>Workshop Marketing</td>
                                            <td>80</td>
                                            <td class="fw-bold">80M đ</td>
                                            <td>
                                                <div class="progress" style="height: 8px; width: 100px;">
                                                    <div class="progress-bar bg-warning" style="width: 9%;"></div>
                                                </div>
                                            </td>
                                        </tr>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Ticket Types -->
                <div class="col-lg-4">
                    <div class="card glass-strong border-0 rounded-4">
                        <div class="card-header bg-transparent border-0">
                            <h5 class="fw-bold mb-0">Loại vé bán chạy</h5>
                        </div>
                        <div class="card-body">
                            <div class="mb-3">
                                <div class="d-flex justify-content-between mb-1">
                                    <span>Vé VIP</span>
                                    <span class="fw-bold">45%</span>
                                </div>
                                <div class="progress" style="height: 8px;">
                                    <div class="progress-bar bg-primary" style="width: 45%;"></div>
                                </div>
                            </div>
                            <div class="mb-3">
                                <div class="d-flex justify-content-between mb-1">
                                    <span>Vé thường</span>
                                    <span class="fw-bold">35%</span>
                                </div>
                                <div class="progress" style="height: 8px;">
                                    <div class="progress-bar bg-success" style="width: 35%;"></div>
                                </div>
                            </div>
                            <div>
                                <div class="d-flex justify-content-between mb-1">
                                    <span>Vé Early Bird</span>
                                    <span class="fw-bold">20%</span>
                                </div>
                                <div class="progress" style="height: 8px;">
                                    <div class="progress-bar bg-warning" style="width: 20%;"></div>
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
