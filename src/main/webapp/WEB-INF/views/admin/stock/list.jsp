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
        .option-row td { background: #fafafa; }
        .option-label { padding-left: 1.5rem; color: #555; }
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
        <ui:searchForm placeholder="상품명 검색" resetUrl="${ctx}/admin/stock"/>

        <div class="card shadow-sm">
            <div class="card-body p-0">
                <table class="table table-hover mb-0 align-middle">
                    <thead class="table-light">
                    <tr>
                        <th class="ps-4" style="width:60px">No.</th>
                        <th>상품 / 옵션</th>
                        <th style="width:110px">구분</th>
                        <th style="width:110px" class="text-end">현재 재고</th>
                        <th style="width:220px" class="text-end pe-4">재고 수정</th>
                    </tr>
                    </thead>
                    <tbody>
                    <c:if test="${empty products.content}">
                        <tr><td colspan="5" class="text-center text-muted py-5">등록된 상품이 없습니다.</td></tr>
                    </c:if>
                    <c:forEach var="p" items="${products.content}" varStatus="status">
                        <c:set var="options" value="${optionMap[p.productId]}"/>

                        <%-- 상품 행 (총재고 = 옵션 재고 합계, 표시 전용) --%>
                        <tr>
                            <td class="ps-4 text-muted small">${products.number * products.size + status.index + 1}</td>
                            <td>
                                <span class="fw-semibold"><c:out value="${p.name}"/></span>
                                <c:if test="${not empty p.category}">
                                    <span class="text-muted small ms-1">${p.category.label}</span>
                                </c:if>
                            </td>
                            <td>
                                <span class="badge bg-primary-subtle text-primary border">옵션 ${options.size()}개</span>
                            </td>
                            <td class="text-end">
                                <c:set var="pstock" value="${stockMap[p.productId]}"/>
                                <c:choose>
                                    <c:when test="${pstock == 0}"><span class="badge bg-secondary">품절</span></c:when>
                                    <c:otherwise><span class="fw-semibold">${pstock}</span></c:otherwise>
                                </c:choose>
                            </td>
                            <td class="text-end pe-4">
                                <span class="text-muted small">옵션별 관리 ↓</span>
                            </td>
                        </tr>

                        <%-- 옵션 행 (재고 수정) --%>
                        <c:forEach var="opt" items="${options}">
                            <tr class="option-row">
                                <td></td>
                                <td class="option-label" colspan="2">
                                    └ ${opt.optionName}: ${opt.optionValue}
                                </td>
                                <td class="text-end">
                                    <c:choose>
                                        <c:when test="${opt.stock == 0}"><span class="badge bg-secondary">품절</span></c:when>
                                        <c:otherwise>${opt.stock}</c:otherwise>
                                    </c:choose>
                                </td>
                                <td class="text-end pe-4">
                                    <form action="${ctx}/admin/stock/options/${opt.optionId}" method="post"
                                          class="d-inline-flex gap-1 justify-content-end">
                                        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                                        <input type="hidden" name="search" value="${param.search}"/>
                                        <input type="hidden" name="page" value="${products.number}"/>
                                        <input type="number" name="stock" min="0" required
                                               class="form-control form-control-sm text-end stock-input" value="${opt.stock}">
                                        <button type="submit" class="btn btn-sm btn-outline-dark">저장</button>
                                    </form>
                                </td>
                            </tr>
                        </c:forEach>
                    </c:forEach>
                    </tbody>
                </table>
            </div>
        </div>

        <ui:pagination page="${products}"/>

    </main>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
