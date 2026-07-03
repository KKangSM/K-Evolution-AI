<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="ui" tagdir="/WEB-INF/tags" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>상품 관리 · K-Evolution 관리자</title>
    <%@ include file="/WEB-INF/views/layout/meta.jsp" %>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin.css">
    <style>
        .admin-thumb { width: 56px; height: 56px; object-fit: cover; border-radius: 6px; }
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
                <h4 class="page-title mb-1">상품 관리</h4>
                <p class="text-muted small mb-0">총 <strong>${products.totalElements}</strong>개 상품</p>
            </div>
            <a href="${ctx}/admin/products/register" class="btn btn-dark btn-sm px-3">+ 상품 등록</a>
        </div>

        <%@ include file="/WEB-INF/views/layout/flash-toast.jsp" %>

        <!-- 검색 폼 (상품명) -->
        <ui:searchForm placeholder="상품명 검색" resetUrl="${ctx}/admin/products">
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
                    <thead class="table-light">
                    <tr>
                        <th class="ps-4" style="width:70px">이미지</th>
                        <th style="width:60px">ID</th>
                        <th>상품명</th>
                        <th style="width:120px">카테고리</th>
                        <th style="width:120px" class="text-end">가격</th>
                        <th style="width:80px" class="text-end">재고</th>
                        <th style="width:160px" class="text-center pe-4">관리</th>
                    </tr>
                    </thead>
                    <tbody>
                    <c:forEach var="product" items="${products.content}">
                        <tr>
                            <td class="ps-4">
                                <img src="${empty product.imageUrl ? 'https://placehold.co/56x56?text=No' : product.imageUrl}"
                                     class="admin-thumb" alt="상품 이미지">
                            </td>
                            <td class="text-muted">${product.productId}</td>
                            <td class="fw-semibold">${product.name}</td>
                            <td>
                                <c:choose>
                                    <c:when test="${not empty product.category}">${product.category.label}</c:when>
                                    <c:otherwise><span class="text-muted">-</span></c:otherwise>
                                </c:choose>
                            </td>
                            <td class="text-end">
                                <fmt:formatNumber value="${product.price}" type="number" groupingUsed="true"/>원
                            </td>
                            <td class="text-end">
                                <c:set var="pstock" value="${stockMap[product.productId]}"/>
                                <c:choose>
                                    <c:when test="${pstock == 0}"><span class="badge bg-secondary">품절</span></c:when>
                                    <c:otherwise>${pstock}</c:otherwise>
                                </c:choose>
                            </td>
                            <td class="text-center pe-4">
                                <a href="${ctx}/admin/products/${product.productId}/edit"
                                   class="btn btn-sm btn-outline-primary">수정</a>
                                <form action="${ctx}/admin/products/${product.productId}/delete"
                                      method="post" class="d-inline"
                                      onsubmit="return confirm('정말 삭제하시겠습니까?');">
                                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                                    <button type="submit" class="btn btn-sm btn-outline-danger">삭제</button>
                                </form>
                            </td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty products.content}">
                        <tr><td colspan="7" class="text-center text-muted py-4">등록된 상품이 없습니다.</td></tr>
                    </c:if>
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
