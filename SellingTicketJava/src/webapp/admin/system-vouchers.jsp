<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<jsp:include page="../header.jsp" />

<div class="container-fluid py-4">
    <div class="row">
        <div class="col-lg-2">
            <jsp:include page="sidebar.jsp">
                <jsp:param name="activePage" value="system-vouchers"/>
            </jsp:include>
        </div>

        <div class="col-lg-10">
            <div class="d-flex justify-content-between align-items-center mb-4">
                <div>
                    <h2 class="fw-bold mb-1"><i class="fas fa-gift text-primary me-2"></i>Voucher Hệ thống</h2>
                    <p class="text-muted mb-0">Module riêng cho admin: trợ giá từ quỹ hệ thống, không trừ doanh thu BTC.</p>
                </div>
                <a href="${pageContext.request.contextPath}/admin/system-vouchers/create" class="btn btn-gradient rounded-pill px-4">
                    <i class="fas fa-plus me-2"></i>Tạo voucher hệ thống
                </a>
            </div>

            <div class="card glass-strong border-0 rounded-4">
                <div class="card-body p-0">
                    <div class="table-responsive">
                        <table class="table table-glass align-middle mb-0">
                            <thead>
                                <tr>
                                    <th>Mã voucher</th>
                                    <th>Loại</th>
                                    <th>Giá trị</th>
                                    <th>Phạm vi</th>
                                    <th>Nguồn trừ tiền</th>
                                    <th>Sử dụng</th>
                                    <th>Thời gian</th>
                                    <th class="text-center">Thao tác</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:choose>
                                    <c:when test="${empty vouchers}">
                                        <tr>
                                            <td colspan="8" class="text-center py-5 text-muted">
                                                Chưa có voucher hệ thống nào.
                                            </td>
                                        </tr>
                                    </c:when>
                                    <c:otherwise>
                                        <c:forEach var="v" items="${vouchers}">
                                            <tr>
                                                <td><span class="fw-bold font-monospace">${v.code}</span></td>
                                                <td>${v.discountType == 'percentage' ? 'Phần trăm' : 'Số tiền cố định'}</td>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${v.discountType == 'percentage'}">${v.discountValue}%</c:when>
                                                        <c:otherwise><fmt:formatNumber value="${v.discountValue}" type="number" groupingUsed="true"/>đ</c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td><span class="badge rounded-pill" style="background:linear-gradient(135deg,#6366f1,#8b5cf6);color:white;">SYSTEM</span></td>
                                                <td><span class="badge rounded-pill" style="background:linear-gradient(135deg,#10b981,#06b6d4);color:white;">SYSTEM FUND</span></td>
                                                <td>${v.usedCount}/${v.usageLimit}</td>
                                                <td>
                                                    <small class="text-muted">
                                                        <fmt:formatDate value="${v.startDate}" pattern="dd/MM/yyyy"/>
                                                        -
                                                        <fmt:formatDate value="${v.endDate}" pattern="dd/MM/yyyy"/>
                                                    </small>
                                                </td>
                                                <td class="text-center">
                                                    <a href="${pageContext.request.contextPath}/admin/system-vouchers/edit/${v.voucherId}" class="btn btn-sm btn-outline-primary rounded-pill px-2" title="Sửa">
                                                        <i class="fas fa-edit"></i>
                                                    </a>
                                                    <form method="POST" action="${pageContext.request.contextPath}/admin/system-vouchers" class="d-inline">
                                                        <input type="hidden" name="csrf_token" value="${sessionScope.csrf_token}"/>
                                                        <input type="hidden" name="action" value="delete"/>
                                                        <input type="hidden" name="voucherId" value="${v.voucherId}"/>
                                                        <button type="submit" class="btn btn-sm btn-outline-danger rounded-pill px-2" onclick="return confirm('Xóa voucher hệ thống ${v.code}?')" title="Xóa">
                                                            <i class="fas fa-trash"></i>
                                                        </button>
                                                    </form>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </c:otherwise>
                                </c:choose>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<jsp:include page="../footer.jsp" />
