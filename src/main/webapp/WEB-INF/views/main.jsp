<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>K-Evolution</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/main.css">
</head>
<body class="bg-light">

<%@ include file="/WEB-INF/views/fragments/header.jsp" %>

<!-- 히어로 배너 -->
<section class="hero text-center">
    <div class="container">
        <h1 class="mb-3">K-Evolution</h1>
        <p class="lead mb-0 text-light opacity-75">당신의 일상을 진화시키는 셀렉트 쇼핑</p>
    </div>
</section>

<!-- 이벤트 캐러셀 (슬라이드 내용은 추후 채움) -->
<div class="container mt-4">
    <div id="eventCarousel" class="carousel slide event-carousel shadow-sm" data-bs-ride="carousel">
        <div class="carousel-indicators">
            <button type="button" data-bs-target="#eventCarousel" data-bs-slide-to="0" class="active" aria-current="true" aria-label="슬라이드 1"></button>
            <button type="button" data-bs-target="#eventCarousel" data-bs-slide-to="1" aria-label="슬라이드 2"></button>
            <button type="button" data-bs-target="#eventCarousel" data-bs-slide-to="2" aria-label="슬라이드 3"></button>
        </div>
        <div class="carousel-inner">
            <div class="carousel-item active">
                <div class="event-slide"></div>
            </div>
            <div class="carousel-item">
                <div class="event-slide"></div>
            </div>
            <div class="carousel-item">
                <div class="event-slide"></div>
            </div>
        </div>
        <button class="carousel-control-prev" type="button" data-bs-target="#eventCarousel" data-bs-slide="prev">
            <span class="carousel-control-prev-icon" aria-hidden="true"></span>
            <span class="visually-hidden">이전</span>
        </button>
        <button class="carousel-control-next" type="button" data-bs-target="#eventCarousel" data-bs-slide="next">
            <span class="carousel-control-next-icon" aria-hidden="true"></span>
            <span class="visually-hidden">다음</span>
        </button>
    </div>
</div>

<div class="container my-5">

    <!-- 카테고리 바로가기 -->
    <c:if test="${not empty categories}">
        <div class="d-flex flex-wrap gap-3 justify-content-center mb-5">
            <c:forEach var="cat" items="${categories}">
                <a class="category-chip"
                   href="${pageContext.request.contextPath}/products?categoryId=${cat.categoryId}">
                    <span class="emoji">🛍️</span>
                    <span>${cat.name}</span>
                </a>
            </c:forEach>
        </div>
    </c:if>

    <!-- 신상품 -->
    <div class="d-flex justify-content-between align-items-center mb-3">
        <h4 class="section-title mb-0">신상품</h4>
        <a href="${pageContext.request.contextPath}/products" class="text-decoration-none text-muted small">더보기 →</a>
    </div>
    <div class="row g-4 mb-5">
        <c:if test="${empty newProducts}">
            <div class="col-12 text-center py-4 text-muted">등록된 상품이 없습니다.</div>
        </c:if>
        <c:forEach var="product" items="${newProducts}">
            <div class="col-6 col-md-3">
                <div class="card product-card h-100"
                     onclick="location.href='${pageContext.request.contextPath}/products/${product.productId}'">
                    <img src="${empty product.imageUrl ? 'https://placehold.co/300x200?text=No+Image' : product.imageUrl}"
                         class="card-img-top product-img" alt="상품 이미지">
                    <div class="card-body d-flex flex-column">
                        <p class="card-text text-muted small mb-1">${product.category.name}</p>
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

    <!-- 인기상품 -->
    <div class="d-flex justify-content-between align-items-center mb-3">
        <h4 class="section-title mb-0">인기상품</h4>
        <a href="${pageContext.request.contextPath}/products" class="text-decoration-none text-muted small">더보기 →</a>
    </div>
    <div class="row g-4">
        <c:if test="${empty popularProducts}">
            <div class="col-12 text-center py-4 text-muted">등록된 상품이 없습니다.</div>
        </c:if>
        <c:forEach var="product" items="${popularProducts}" varStatus="status">
            <div class="col-6 col-md-3">
                <div class="card product-card h-100 position-relative"
                     onclick="location.href='${pageContext.request.contextPath}/products/${product.productId}'">
                    <span class="rank-badge">${status.index + 1}</span>
                    <img src="${empty product.imageUrl ? 'https://placehold.co/300x200?text=No+Image' : product.imageUrl}"
                         class="card-img-top product-img" alt="상품 이미지">
                    <div class="card-body d-flex flex-column">
                        <p class="card-text text-muted small mb-1">${product.category.name}</p>
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

    <!-- 전체 상품 보러가기 -->
    <div class="text-center mt-5">
        <a href="${pageContext.request.contextPath}/products" class="btn btn-dark btn-lg px-4 fw-semibold">
            전체 상품 보러가기
        </a>
    </div>

</div>

<footer class="bg-dark text-light py-4 site-footer">
    <div class="container text-center small text-light opacity-50">
        © 2026 K-Evolution. All rights reserved.
    </div>
</footer>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
