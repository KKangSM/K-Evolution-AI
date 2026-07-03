<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="ui" tagdir="/WEB-INF/tags" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>재고 관리 · K-Evolution 관리자</title>
    <%@ include file="/WEB-INF/views/layout/meta.jsp" %>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin.css">
    <style>
        .stock-input { width: 90px; }
        .product-row { cursor: pointer; }
        .product-row .toggle-icon { transition: transform .15s ease; color: #999; }
        .product-row.open .toggle-icon { transform: rotate(90deg); }
        .option-row { display: none; }
        .option-row.show { display: table-row; }
        .option-row td { background: #fafafa; }
        /* 옵션이 상품 하위임을 시각적으로: 크게 들여쓰기 */
        .option-row .nest { padding-left: 3.25rem; }
        .option-label { color: #555; }
    </style>
</head>
<body class="admin-body">

<%@ include file="/WEB-INF/views/layout/admin-topbar.jsp" %>

<div class="admin-layout">
    <%@ include file="/WEB-INF/views/layout/admin-sidebar.jsp" %>

    <main class="admin-main">
        <c:set var="ctx" value="${pageContext.request.contextPath}"/>

        <div class="d-flex justify-content-between align-items-center mb-3">
            <div>
                <h4 class="page-title mb-1">재고 관리</h4>
                <p class="text-muted small mb-0">
                    총 <strong>${products.totalElements}</strong>개 상품 ·
                    옵션 있는 상품의 재고는 옵션별로 수정하면 상품 재고(합계)가 자동 반영됩니다.
                </p>
            </div>
        </div>

        <%@ include file="/WEB-INF/views/layout/flash-toast.jsp" %>

        <!-- 검색 폼 (상품명) -->
        <ui:searchForm placeholder="상품명 검색" resetUrl="${ctx}/admin/stock">
            <%-- 페이지 크기 유지 --%>
            <input type="hidden" name="pageSize" value="${empty param.pageSize ? '20' : param.pageSize}">
        </ui:searchForm>

        <!-- 페이지당 표시 -->
        <div class="d-flex justify-content-end mb-2">
            <ui:pageSize/>
        </div>

        <div class="card shadow-sm">
            <div class="card-body p-0">
                <table class="table table-hover mb-0 align-middle">
                    <thead class="table-light text-center">
                    <tr>
                        <th style="width:60px">No.</th>
                        <th>상품 / 옵션</th>
                        <th style="width:110px">구분</th>
                        <th style="width:110px">현재 재고</th>
                        <th style="width:220px">재고 수정</th>
                    </tr>
                    </thead>
                    <tbody>
                    <c:if test="${empty products.content}">
                        <tr><td colspan="5" class="text-center text-muted py-5">등록된 상품이 없습니다.</td></tr>
                    </c:if>
                    <c:forEach var="p" items="${products.content}" varStatus="status">
                        <c:set var="options" value="${optionMap[p.productId]}"/>
                        <%-- 방금 재고를 수정한 상품이면 펼친 상태로 렌더 --%>
                        <c:set var="isOpen" value="${param.expand == p.productId}"/>

                        <%-- 상품 행 (총재고 = 옵션 재고 합계, 표시 전용 / 클릭 시 옵션 펼침) --%>
                        <tr class="product-row ${isOpen ? 'open' : ''}" data-group="opt-${p.productId}">
                            <td class="text-center text-muted small">${products.number * products.size + status.index + 1}</td>
                            <td>
                                <i class="bi bi-chevron-right toggle-icon me-1 small"></i>
                                <span class="fw-semibold"><c:out value="${p.name}"/></span>
                                <c:if test="${not empty p.category}">
                                    <span class="text-muted small ms-1">${p.category.label}</span>
                                </c:if>
                            </td>
                            <td class="text-center">
                                <span class="badge bg-primary-subtle text-primary border">옵션 ${options.size()}개</span>
                            </td>
                            <td class="text-center">
                                <c:set var="pstock" value="${stockMap[p.productId]}"/>
                                <c:choose>
                                    <c:when test="${pstock == 0}"><span class="badge bg-secondary">품절</span></c:when>
                                    <c:otherwise><span class="fw-semibold">${pstock}</span></c:otherwise>
                                </c:choose>
                            </td>
                            <td class="text-center">
                                <span class="text-muted small toggle-hint">${isOpen ? '접기' : '클릭하여 옵션 보기'}</span>
                            </td>
                        </tr>

                        <%-- 옵션 행 (재고 입력 — 저장은 상품별 폼 하나로 일괄 처리) --%>
                        <c:forEach var="opt" items="${options}">
                            <tr class="option-row ${isOpen ? 'show' : ''}" data-group="opt-${p.productId}">
                                <td></td>
                                <td class="option-label nest" colspan="2">
                                    └ ${opt.optionName}: ${opt.optionValue}
                                </td>
                                <td class="text-center">
                                    <c:choose>
                                        <c:when test="${opt.stock == 0}"><span class="badge bg-secondary">품절</span></c:when>
                                        <c:otherwise>${opt.stock}</c:otherwise>
                                    </c:choose>
                                </td>
                                <td class="text-center">
                                    <div class="d-flex justify-content-center">
                                        <input type="hidden" name="optionId" value="${opt.optionId}"
                                               form="stockForm-${p.productId}"/>
                                        <input type="number" name="stock" min="0" required value="${opt.stock}"
                                               form="stockForm-${p.productId}"
                                               class="form-control form-control-sm text-center stock-input">
                                    </div>
                                </td>
                            </tr>
                        </c:forEach>

                        <%-- 저장 행 (해당 상품의 모든 옵션 재고를 한 번에 저장) --%>
                        <c:if test="${not empty options}">
                            <tr class="option-row ${isOpen ? 'show' : ''}" data-group="opt-${p.productId}">
                                <td></td>
                                <td colspan="3" class="text-muted small nest">사이즈별 재고를 입력한 뒤 저장을 누르면 한 번에 반영됩니다.</td>
                                <td class="text-center">
                                    <form id="stockForm-${p.productId}"
                                          action="${ctx}/admin/stock/products/${p.productId}" method="post" class="d-inline">
                                        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                                        <input type="hidden" name="search" value="${param.search}"/>
                                        <input type="hidden" name="page" value="${products.number}"/>
                                        <input type="hidden" name="pageSize" value="${empty param.pageSize ? '20' : param.pageSize}"/>
                                        <button type="submit" class="btn btn-sm btn-dark px-3">저장</button>
                                    </form>
                                </td>
                            </tr>
                        </c:if>
                    </c:forEach>
                    </tbody>
                </table>
            </div>
        </div>

        <ui:pagination page="${products}"/>

    </main>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    // 상품 행 클릭 시 해당 옵션 행 펼치기/접기 (기본은 접힘)
    document.querySelectorAll('.product-row').forEach(function (row) {
        row.addEventListener('click', function () {
            var group = row.getAttribute('data-group');
            var open = row.classList.toggle('open');
            document.querySelectorAll('.option-row[data-group="' + group + '"]').forEach(function (opt) {
                opt.classList.toggle('show', open);
            });
            var hint = row.querySelector('.toggle-hint');
            if (hint) hint.textContent = open ? '접기' : '클릭하여 옵션 보기';
        });
    });

    // 저장 후 펼친 채로 복귀한 상품을 화면에 보이도록 스크롤
    var opened = document.querySelector('.product-row.open');
    if (opened) opened.scrollIntoView({ block: 'center' });
</script>
</body>
</html>
