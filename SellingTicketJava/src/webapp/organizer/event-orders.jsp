<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@taglib prefix="fn" uri="jakarta.tags.functions" %>

<jsp:include page="../header.jsp" />

<div class="container-fluid py-4">
    <div class="row">
        <div class="col-lg-2">
            <jsp:include page="sidebar.jsp">
                <jsp:param name="activePage" value="orders"/>
            </jsp:include>
        </div>

        <div class="col-lg-10">
            <div class="d-flex justify-content-between align-items-center mb-4 animate-fadeInDown">
                <div>
                    <h2 class="fw-bold mb-1"><i class="fas fa-receipt text-primary me-2"></i>Đơn hàng theo sự kiện</h2>
                    <p class="text-muted mb-0">${event.title}</p>
                </div>
                <a href="${pageContext.request.contextPath}/organizer/orders?eventId=${event.eventId}" class="btn glass rounded-pill px-4">
                    <i class="fas fa-arrow-left me-2"></i>Quay lại danh sách
                </a>
            </div>

            <div class="card glass-strong border-0 rounded-4 mb-4 animate-on-scroll">
                <div class="card-body p-3 d-flex flex-wrap gap-4">
                    <div>
                        <div class="small text-muted">Sự kiện</div>
                        <div class="fw-bold">${event.title}</div>
                    </div>
                    <div>
                        <div class="small text-muted">Thời gian</div>
                        <div class="fw-medium">
                            <fmt:formatDate value="${event.startDate}" pattern="dd/MM/yyyy HH:mm"/>
                        </div>
                    </div>
                    <div>
                        <div class="small text-muted">Địa điểm</div>
                        <div class="fw-medium">${event.location}</div>
                    </div>
                </div>
            </div>

            <div class="card glass-strong border-0 rounded-4 animate-on-scroll">
                <div class="card-body p-0">
                    <div class="table-responsive">
                        <table class="table table-glass align-middle mb-0">
                            <thead>
                                <tr>
                                    <th>Mã đơn</th>
                                    <th>Khách hàng</th>
                                    <th>Chi tiết vé</th>
                                    <th>Tổng tiền</th>
                                    <th>Trạng thái</th>
                                    <th>Ngày tạo</th>
                                    <th class="text-center">Thao tác</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="order" items="${orders}">
                                    <c:set var="status" value="${fn:toLowerCase(order.status)}"/>
                                    <tr>
                                        <td><code class="text-primary fw-bold">#${order.orderId}</code></td>
                                        <td>
                                            <div class="fw-medium">${order.buyerName}</div>
                                            <small class="text-muted">${order.buyerEmail}</small>
                                        </td>
                                        <td>
                                            <c:forEach var="item" items="${order.items}">
                                                <div>${item.ticketTypeName} x ${item.quantity}</div>
                                            </c:forEach>
                                            <c:if test="${empty order.items}">
                                                <span class="text-muted">Không có dữ liệu item</span>
                                            </c:if>
                                        </td>
                                        <td class="fw-bold text-primary"><fmt:formatNumber value="${order.finalAmount}" type="number"/>đ</td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${status == 'paid'}">
                                                    <span class="badge rounded-pill px-3 py-2" style="background:linear-gradient(135deg,#10b981,#06b6d4);color:white;">Đã thanh toán</span>
                                                </c:when>
                                                <c:when test="${status == 'pending'}">
                                                    <span class="badge bg-warning text-dark rounded-pill px-3 py-2">Chờ thanh toán</span>
                                                </c:when>
                                                <c:when test="${status == 'checked_in'}">
                                                    <span class="badge bg-info rounded-pill px-3 py-2">Đã check-in</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge bg-danger rounded-pill px-3 py-2">Đã hủy</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td><fmt:formatDate value="${order.createdAt}" pattern="dd/MM/yyyy HH:mm"/></td>
                                        <td class="text-center">
                                            <div class="d-flex justify-content-center gap-2">
                                                <c:if test="${status == 'pending'}">
                                                    <form action="${pageContext.request.contextPath}/organizer/orders/confirm-payment" method="POST" class="d-inline">
                                                        <input type="hidden" name="csrf_token" value="${sessionScope.csrf_token}">
                                                        <input type="hidden" name="orderId" value="${order.orderId}">
                                                        <input type="hidden" name="eventId" value="${event.eventId}">
                                                        <button type="submit" class="btn btn-sm btn-outline-success rounded-pill" title="Xác nhận thanh toán"
                                                                onclick="return confirm('Xác nhận đơn này đã thanh toán?');">
                                                            <i class="fas fa-check"></i>
                                                        </button>
                                                    </form>
                                                    <form action="${pageContext.request.contextPath}/organizer/orders/cancel" method="POST" class="d-inline">
                                                        <input type="hidden" name="csrf_token" value="${sessionScope.csrf_token}">
                                                        <input type="hidden" name="orderId" value="${order.orderId}">
                                                        <input type="hidden" name="eventId" value="${event.eventId}">
                                                        <button type="submit" class="btn btn-sm btn-outline-danger rounded-pill" title="Hủy đơn"
                                                                onclick="return confirm('Hủy đơn này?');">
                                                            <i class="fas fa-times"></i>
                                                        </button>
                                                    </form>
                                                </c:if>
                                                <c:if test="${status != 'pending'}">
                                                    <span class="text-muted small">Không có thao tác</span>
                                                </c:if>
                                            </div>
                                        </td>
                                    </tr>
                                </c:forEach>

                                <c:if test="${empty orders}">
                                    <tr>
                                        <td colspan="7" class="text-center py-5">
                                            <i class="fas fa-inbox fa-2x text-muted mb-3"></i>
                                            <div class="text-muted">Sự kiện này chưa có đơn hàng.</div>
                                        </td>
                                    </tr>
                                </c:if>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<jsp:include page="../footer.jsp" />
