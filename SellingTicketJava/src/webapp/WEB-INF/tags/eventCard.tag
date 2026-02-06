<%-- 
    Custom Tag: Event Card
    Usage: <tags:eventCard event="${event}" />
--%>
<%@tag description="Reusable Event Card Component" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@attribute name="event" required="true" type="com.sellingticket.model.Event" %>
<%@attribute name="showAttendees" required="false" type="java.lang.Boolean" %>

<a href="${pageContext.request.contextPath}/event?id=${event.id}" 
   class="card event-card h-100 text-decoration-none border-0 shadow-sm overflow-hidden">
    <div class="position-relative" style="aspect-ratio: 4/3;">
        <img src="${event.image}" alt="${event.title}" 
             class="card-img-top w-100 h-100 object-fit-cover">
        <span class="badge bg-primary position-absolute top-0 end-0 m-2">
            <c:choose>
                <c:when test="${event.price == 0}">Miễn phí</c:when>
                <c:otherwise>${event.price} đ</c:otherwise>
            </c:choose>
        </span>
    </div>
    <div class="card-body">
        <small class="text-uppercase text-primary fw-semibold">${event.category}</small>
        <h5 class="card-title mt-2 mb-3 text-dark line-clamp-2" style="min-height: 3rem;">
            ${event.title}
        </h5>
        <div class="d-flex flex-column gap-2 text-muted small mb-3">
            <div class="d-flex align-items-center gap-2">
                <i class="far fa-calendar text-primary"></i>
                <span>${event.date}</span>
            </div>
            <div class="d-flex align-items-center gap-2">
                <i class="fas fa-map-marker-alt text-primary"></i>
                <span class="text-truncate">${event.location}</span>
            </div>
        </div>
        <c:if test="${showAttendees && event.attendees > 0}">
            <div class="border-top pt-3 d-flex justify-content-between align-items-center">
                <small class="text-muted">
                    <i class="fas fa-users me-1"></i>${event.attendees} tham gia
                </small>
                <span class="btn btn-sm btn-outline-primary rounded-circle">
                    <i class="fas fa-arrow-right"></i>
                </span>
            </div>
        </c:if>
    </div>
</a>

<style>
.event-card {
    transition: transform 0.3s, box-shadow 0.3s;
    border-radius: 1rem !important;
}
.event-card:hover {
    transform: translateY(-5px);
    box-shadow: 0 10px 30px rgba(0,0,0,0.15) !important;
}
.line-clamp-2 {
    display: -webkit-box;
    -webkit-line-clamp: 2;
    -webkit-box-orient: vertical;
    overflow: hidden;
}
</style>
