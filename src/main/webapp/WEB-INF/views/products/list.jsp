<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>K-Evolution</title>
    <%@ include file="/WEB-INF/views/layout/meta.jsp" %>
    <style>
        .product-card { cursor: pointer; transition: transform 0.2s; }
        .product-card:hover { transform: translateY(-4px); box-shadow: 0 4px 12px rgba(0,0,0,0.15); }
        .product-img { height: 200px; object-fit: cover; }
    </style>
</head>
<body class="bg-light">

<%@ include file="/WEB-INF/views/layout/header.jsp" %>

<div class="container mt-4">

    <!-- 검색 -->
    <form action="${pageContext.request.contextPath}/products" method="get" class="mb-4">
        <div class="row g-2">
            <div class="col-md-6">
                <input type="text" name="keyword" class="form-control"
                       placeholder="상품명 검색" value="${keyword}">
            </div>
            <div class="col-md-4">
                <select name="category" class="form-select">
                    <option value="">전체 카테고리</option>
                    <c:forEach var="cat" items="${globalCategories}">
                        <option value="${cat}"
                            <c:if test="${cat == category}">selected</c:if>>
                            ${cat.label}
                        </option>
                    </c:forEach>
                </select>
            </div>
            <div class="col-md-2">
                <button type="submit" class="btn btn-dark w-100">검색</button>
            </div>
        </div>
    </form>

    <!-- 결과 수 -->
    <p class="text-muted small mb-3">
        총 <strong>${products.totalElements}</strong>개 상품
    </p>

    <!-- 상품 목록 -->
    <div class="row g-4">
        <c:if test="${products.isEmpty()}">
            <div class="col-12 text-center py-5 text-muted">검색 결과가 없습니다.</div>
        </c:if>
        <c:forEach var="product" items="${products.content}">
            <div class="col-6 col-md-3">
                <div class="card product-card h-100"
                     onclick="location.href='${pageContext.request.contextPath}/products/${product.productId}'">
                    <img src="${empty product.imageUrl ? 'https://placehold.co/300x200?text=No+Image' : product.imageUrl}"
                         class="card-img-top product-img" alt="상품 이미지">
                    <div class="card-body d-flex flex-column">
                        <p class="card-text text-muted small mb-1">${not empty product.category ? product.category.label : ''}</p>
                        <h6 class="card-title flex-grow-1">${product.name}</h6>
                        <div class="d-flex justify-content-between align-items-center mt-2">
                            <span class="fw-bold">
                                <fmt:formatNumber value="${product.price}" type="number" groupingUsed="true"/>원
                            </span>
                            <c:if test="${product.stock == 0}">
                                <span class="badge bg-secondary">품절</span>
                            </c:if>
                        </div>
                    </div>
                </div>
            </div>
        </c:forEach>
    </div>

    <!-- 페이지네이션 -->
    <c:if test="${products.totalPages > 1}">
        <nav class="mt-5 d-flex justify-content-center">
            <ul class="pagination">
                <li class="page-item <c:if test="${currentPage == 0}">disabled</c:if>">
                    <c:url value="/products" var="prevUrl">
                        <c:param name="keyword" value="${keyword}"/>
                        <c:param name="category" value="${category}"/>
                        <c:param name="page" value="${currentPage - 1}"/>
                    </c:url>
                    <a class="page-link" href="${prevUrl}">이전</a>
                </li>
                <c:forEach begin="0" end="${products.totalPages - 1}" var="i">
                    <li class="page-item <c:if test="${i == currentPage}">active</c:if>">
                        <c:url value="/products" var="pageUrl">
                            <c:param name="keyword" value="${keyword}"/>
                            <c:param name="category" value="${category}"/>
                            <c:param name="page" value="${i}"/>
                        </c:url>
                        <a class="page-link" href="${pageUrl}">${i + 1}</a>
                    </li>
                </c:forEach>
                <li class="page-item <c:if test="${currentPage == products.totalPages - 1}">disabled</c:if>">
                    <c:url value="/products" var="nextUrl">
                        <c:param name="keyword" value="${keyword}"/>
                        <c:param name="category" value="${category}"/>
                        <c:param name="page" value="${currentPage + 1}"/>
                    </c:url>
                    <a class="page-link" href="${nextUrl}">다음</a>
                </li>
            </ul>
        </nav>
    </c:if>

</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
