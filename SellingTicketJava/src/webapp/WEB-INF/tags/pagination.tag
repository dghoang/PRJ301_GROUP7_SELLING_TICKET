<%@tag description="Pagination component with page size selection" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@attribute name="currentPage" required="true" type="java.lang.Integer" %>
<%@attribute name="totalPages" required="true" type="java.lang.Integer" %>
<%@attribute name="pageSize" required="true" type="java.lang.Integer" %>
<%@attribute name="totalRecords" required="true" type="java.lang.Integer" %>
<%@attribute name="formId" required="false" type="java.lang.String" description="Optional: ID of a form to submit when changing page/size. If not provided, it adds query params to current URL." %>

<c:if test="${totalPages > 0}">
<div class="d-flex flex-column flex-md-row justify-content-between align-items-center mt-4 animate-on-scroll">
    <!-- Page Size Selector -->
    <div class="d-flex align-items-center gap-2 mb-3 mb-md-0">
        <span class="text-muted small">Hiển thị:</span>
        <select class="form-select form-select-sm glass border-0 rounded-3 text-center" style="width: 75px; font-weight: 500;" 
                onchange="changePageSize(this.value)">
            <option value="10" ${pageSize == 10 ? 'selected' : ''}>10</option>
            <option value="20" ${pageSize == 20 ? 'selected' : ''}>20</option>
            <option value="50" ${pageSize == 50 ? 'selected' : ''}>50</option>
            <option value="100" ${pageSize == 100 ? 'selected' : ''}>100</option>
            <option value="200" ${pageSize == 200 ? 'selected' : ''}>200</option>
        </select>
        <span class="text-muted small">dòng / trang</span>
    </div>

    <!-- Pagination Controls -->
    <nav aria-label="Page navigation">
        <ul class="pagination mb-0">
            <!-- First and Prev -->
            <li class="page-item ${currentPage == 1 ? 'disabled' : ''}">
                <a class="page-link glass rounded-start-3 px-3" href="javascript:void(0)" onclick="goToPage(1)" title="Trang đầu">
                    <i class="fas fa-angle-double-left"></i>
                </a>
            </li>
            <li class="page-item ${currentPage == 1 ? 'disabled' : ''}">
                <a class="page-link glass px-3" href="javascript:void(0)" onclick="goToPage(${currentPage - 1})" title="Trang trước">
                    <i class="fas fa-chevron-left"></i>
                </a>
            </li>

            <!-- Page Numbers -->
            <c:set var="startPage" value="${currentPage > 2 ? currentPage - 2 : 1}" />
            <c:set var="endPage" value="${startPage + 4 > totalPages ? totalPages : startPage + 4}" />
            <c:if test="${endPage - startPage < 4 && endPage > 4}">
                <c:set var="startPage" value="${endPage - 4}" />
            </c:if>

            <c:forEach begin="${startPage}" end="${endPage}" var="i">
                <li class="page-item ${i == currentPage ? 'active' : ''}">
                    <c:choose>
                        <c:when test="${i == currentPage}">
                            <a class="page-link fw-bold shadow-sm" href="javascript:void(0)" 
                               style="background: linear-gradient(135deg, var(--primary), var(--secondary)); border: none; color: white; min-width: 40px; text-align: center;">${i}</a>
                        </c:when>
                        <c:otherwise>
                            <a class="page-link glass" href="javascript:void(0)" onclick="goToPage(${i})" style="min-width: 40px; text-align: center;">${i}</a>
                        </c:otherwise>
                    </c:choose>
                </li>
            </c:forEach>

            <!-- Next and Last -->
            <li class="page-item ${currentPage == totalPages ? 'disabled' : ''}">
                <a class="page-link glass px-3" href="javascript:void(0)" onclick="goToPage(${currentPage + 1})" title="Trang sau">
                    <i class="fas fa-chevron-right"></i>
                </a>
            </li>
            <li class="page-item ${currentPage == totalPages ? 'disabled' : ''}">
                <a class="page-link glass rounded-end-3 px-3" href="javascript:void(0)" onclick="goToPage(${totalPages})" title="Trang cuối">
                    <i class="fas fa-angle-double-right"></i>
                </a>
            </li>
        </ul>
    </nav>
    
    <!-- Item Info -->
    <div class="ms-md-3 mt-3 mt-md-0 text-muted small">
        <c:set var="startRow" value="${(currentPage - 1) * pageSize + 1}" />
        <c:set var="endRow" value="${currentPage * pageSize > totalRecords ? totalRecords : currentPage * pageSize}" />
        Hiển thị <b>${startRow}-${endRow}</b> / <b>${totalRecords}</b>
    </div>
</div>

<script>
function changePageSize(size) {
    if ('${formId}') {
        const form = document.getElementById('${formId}');
        if (form) {
            let sizeInput = form.querySelector('input[name="size"]');
            if (!sizeInput) {
                sizeInput = document.createElement('input');
                sizeInput.type = 'hidden';
                sizeInput.name = 'size';
                form.appendChild(sizeInput);
            }
            sizeInput.value = size;
            
            let pageInput = form.querySelector('input[name="page"]');
            if (!pageInput) {
                pageInput = document.createElement('input');
                pageInput.type = 'hidden';
                pageInput.name = 'page';
                form.appendChild(pageInput);
            }
            pageInput.value = 1; // Reset to page 1
            
            form.submit();
            return;
        }
    }
    
    const url = new URL(window.location.href);
    url.searchParams.set('size', size);
    url.searchParams.set('page', '1');
    window.location.href = url.toString();
}

function goToPage(page) {
    if (page === ${currentPage} || page < 1 || page > ${totalPages}) return;
    
    if ('${formId}') {
        const form = document.getElementById('${formId}');
        if (form) {
            let pageInput = form.querySelector('input[name="page"]');
            if (!pageInput) {
                pageInput = document.createElement('input');
                pageInput.type = 'hidden';
                pageInput.name = 'page';
                form.appendChild(pageInput);
            }
            pageInput.value = page;
            
            // Keep existing size
            let sizeInput = form.querySelector('input[name="size"]');
            if (!sizeInput) {
                sizeInput = document.createElement('input');
                sizeInput.type = 'hidden';
                sizeInput.name = 'size';
                sizeInput.value = '${pageSize}';
                form.appendChild(sizeInput);
            }
            
            form.submit();
            return;
        }
    }
    
    const url = new URL(window.location.href);
    url.searchParams.set('page', page);
    if (!url.searchParams.has('size')) {
        url.searchParams.set('size', '${pageSize}');
    }
    window.location.href = url.toString();
}
</script>
</c:if>
