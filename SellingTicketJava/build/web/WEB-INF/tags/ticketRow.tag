<%-- 
    Custom Tag: Ticket Type Row
    Renders a ticket type with quantity controls, availability info, and sale period checks.
    Usage: <tags:ticketRow ticketType="${tt}" maxPerOrder="10" preOrderEnabled="false" />
--%>
<%@tag description="Ticket Type Row with Controls" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@attribute name="ticketType" required="true" type="com.sellingticket.model.TicketType" %>
<%@attribute name="maxPerOrder" required="false" type="java.lang.Integer" %>
<%@attribute name="preOrderEnabled" required="false" type="java.lang.Boolean" %>
<%@attribute name="eventEnded" required="false" type="java.lang.Boolean" %>

<jsp:useBean id="now" class="java.util.Date" />

<c:set var="maxQty" value="${empty maxPerOrder || maxPerOrder == 0 ? 10 : maxPerOrder}" />
<c:set var="available" value="${ticketType.availableQuantity}" />
<c:set var="actualMax" value="${available < maxQty ? available : maxQty}" />
<c:set var="isSoldOut" value="${available <= 0}" />
<c:set var="saleNotStarted" value="${ticketType.saleStart != null && ticketType.saleStart.time > now.time}" />
<c:set var="saleEnded" value="${ticketType.saleEnd != null && ticketType.saleEnd.time < now.time}" />
<c:set var="canBuy" value="${!isSoldOut && !saleEnded && (!saleNotStarted || preOrderEnabled) && !eventEnded}" />
<c:set var="isPreOrder" value="${saleNotStarted && preOrderEnabled && !isSoldOut && !eventEnded}" />
<c:set var="ttId" value="tt-${ticketType.ticketTypeId}" />

<div class="ticket-row p-4 rounded-4 glass animate-on-scroll hover-lift ${isSoldOut || eventEnded ? 'opacity-50' : ''}" 
     data-id="${ticketType.ticketTypeId}" 
     data-name="${ticketType.name}" 
     data-price="${ticketType.price}" 
     data-max="${actualMax}"
     style="cursor: ${canBuy ? 'pointer' : 'default'}; transition: all 0.3s ease; border-left: 4px solid ${isSoldOut || eventEnded ? '#9ca3af' : isPreOrder ? '#f59e0b' : '#3b82f6'};">
    <div class="row align-items-center">
        <div class="col">
            <div class="d-flex align-items-center gap-2 mb-2">
                <h6 class="fw-bold mb-0"><c:out value="${ticketType.name}" /></h6>
                <c:if test="${isSoldOut}">
                    <span class="badge rounded-pill bg-danger px-2 py-1 small">Hết vé</span>
                </c:if>
                <c:if test="${isPreOrder}">
                    <span class="badge rounded-pill px-2 py-1 small" style="background: rgba(245,158,11,0.15); color: #d97706;">
                        <i class="fas fa-clock me-1"></i>Đặt trước
                    </span>
                </c:if>
                <c:if test="${saleEnded && !isSoldOut}">
                    <span class="badge rounded-pill bg-secondary px-2 py-1 small">Hết hạn bán</span>
                </c:if>
                <c:if test="${saleNotStarted && !preOrderEnabled}">
                    <span class="badge rounded-pill px-2 py-1 small" style="background: rgba(107,114,128,0.15); color: #6b7280;">
                        <i class="fas fa-lock me-1"></i>Chưa mở bán
                    </span>
                </c:if>
                <c:if test="${eventEnded}">
                    <span class="badge rounded-pill bg-secondary px-2 py-1 small">Sự kiện đã kết thúc</span>
                </c:if>
            </div>
            <c:if test="${not empty ticketType.description}">
                <p class="text-muted small mb-2"><c:out value="${ticketType.description}" /></p>
            </c:if>
            <p class="fs-5 fw-bold text-primary mb-0">
                <fmt:formatNumber value="${ticketType.price}" pattern="#,###" /> đ
            </p>
            <p class="text-muted small mb-0">
                Còn ${available} vé
                <c:if test="${maxQty > 0}"> &bull; Tối đa ${maxQty} vé/đơn</c:if>
            </p>
            <c:if test="${isPreOrder && ticketType.saleStart != null}">
                <p class="small mb-0" style="color: #d97706;">
                    <i class="fas fa-info-circle me-1"></i>Mở bán chính thức: <fmt:formatDate value="${ticketType.saleStart}" pattern="dd/MM/yyyy HH:mm" />
                </p>
            </c:if>
        </div>
        <c:if test="${canBuy}">
            <div class="col-auto">
                <div class="d-flex align-items-center gap-3">
                    <button type="button" onclick="updateQty('${ticketType.ticketTypeId}', -1)" 
                            class="btn glass rounded-3 d-flex align-items-center justify-content-center hover-scale" 
                            style="width: 44px; height: 44px;">
                        <i class="fas fa-minus"></i>
                    </button>
                    <span id="qty-${ticketType.ticketTypeId}" class="fs-5 fw-bold" style="min-width: 40px; text-align: center;">0</span>
                    <button type="button" onclick="updateQty('${ticketType.ticketTypeId}', 1)" 
                            class="btn glass rounded-3 d-flex align-items-center justify-content-center hover-scale" 
                            style="width: 44px; height: 44px;">
                        <i class="fas fa-plus"></i>
                    </button>
                </div>
            </div>
        </c:if>
    </div>
</div>
