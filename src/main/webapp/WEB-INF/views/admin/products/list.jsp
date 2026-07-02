<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
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

        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h4 class="page-title mb-1">상품 관리</h4>
                <p class="text-muted small mb-0">총 <strong>${products.totalElements}</strong>개 상품</p>
            </div>
            <a href="${pageContext.request.contextPath}/admin/products/register" class="btn btn-dark">+ 상품 등록</a>
        </div>

        <!-- 검색 -->
        <form action="${pageContext.request.contextPath}/admin/products" method="get" class="mb-3">
            <div class="row g-2">
                <div class="col-md-6">
                    <input type="text" name="keyword" class="form-control"
                           placeholder="상품명 검색" value="${keyword}">
                </div>
                <div class="col-md-2">
                    <button type="submit" class="btn btn-outline-dark w-100">검색</button>
                </div>
            </div>
        </form>

        <div class="card stat-card">
            <div class="table-responsive">
                <table class="table table-hover align-middle mb-0">
                    <thead class="table-light">
                    <tr>
                        <th style="width:70px">이미지</th>
                        <th style="width:60px">ID</th>
                        <th>상품명</th>
                        <th style="width:120px">카테고리</th>
                        <th style="width:120px" class="text-end">가격</th>
                        <th style="width:80px" class="text-end">재고</th>
                        <th style="width:160px" class="text-center">관리</th>
                    </tr>
                    </thead>
                    <tbody>
                    <c:if test="${products.isEmpty()}">
                        <tr><td colspan="7" class="text-center text-muted py-5">등록된 상품이 없습니다.</td></tr>
                    </c:if>
                    <c:forEach var="product" items="${products.content}">
                        <tr>
                            <td>
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
                                <c:choose>
                                    <c:when test="${product.stock == 0}"><span class="badge bg-secondary">품절</span></c:when>
                                    <c:otherwise>${product.stock}</c:otherwise>
                                </c:choose>
                            </td>
                            <td class="text-center">
                                <a href="${pageContext.request.contextPath}/admin/products/${product.productId}/edit"
                                   class="btn btn-sm btn-outline-primary">수정</a>
                                <form action="${pageContext.request.contextPath}/admin/products/${product.productId}/delete"
                                      method="post" class="d-inline"
                                      onsubmit="return confirm('정말 삭제하시겠습니까?');">
                                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                                    <button type="submit" class="btn btn-sm btn-outline-danger">삭제</button>
                                </form>
                            </td>
                        </tr>
                    </c:forEach>
                    </tbody>
                </table>
            </div>
        </div>

        <!-- 페이지네이션 -->
        <c:if test="${products.totalPages > 1}">
            <nav class="mt-4 d-flex justify-content-center">
                <ul class="pagination">
                    <li class="page-item <c:if test="${currentPage == 0}">disabled</c:if>">
                        <c:url value="/admin/products" var="prevUrl">
                            <c:param name="keyword" value="${keyword}"/>
                            <c:param name="page" value="${currentPage - 1}"/>
                        </c:url>
                        <a class="page-link" href="${prevUrl}">이전</a>
                    </li>
                    <c:forEach begin="0" end="${products.totalPages - 1}" var="i">
                        <li class="page-item <c:if test="${i == currentPage}">active</c:if>">
                            <c:url value="/admin/products" var="pageUrl">
                                <c:param name="keyword" value="${keyword}"/>
                                <c:param name="page" value="${i}"/>
                            </c:url>
                            <a class="page-link" href="${pageUrl}">${i + 1}</a>
                        </li>
                    </c:forEach>
                    <li class="page-item <c:if test="${currentPage == products.totalPages - 1}">disabled</c:if>">
                        <c:url value="/admin/products" var="nextUrl">
                            <c:param name="keyword" value="${keyword}"/>
                            <c:param name="page" value="${currentPage + 1}"/>
                        </c:url>
                        <a class="page-link" href="${nextUrl}">다음</a>
                    </li>
                </ul>
            </nav>
        </c:if>

    </main>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
