<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>K-Evolution</title>
    <%@ include file="/WEB-INF/views/fragments/head.jsp" %>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/main.css">
</head>
<body class="bg-light">

<%@ include file="/WEB-INF/views/fragments/header.jsp" %>

<!-- 히어로 배너 -->
<section class="hero text-center">
    <div class="container">
        <h1 class="mb-3">K-Evolution</h1>
        <p class="lead mb-4 text-light opacity-75">당신의 일상을 진화시키는 셀렉트 쇼핑</p>

        <!-- 상품 검색 -->
        <form action="${pageContext.request.contextPath}/products" method="get" class="hero-search mx-auto">
            <div class="input-group input-group-lg shadow">
                <input type="text" name="keyword" class="form-control border-0"
                       placeholder="어떤 상품을 찾으세요?" aria-label="상품 검색">
                <button class="btn bg-white text-dark px-4 d-flex align-items-center" type="submit" aria-label="검색">
                    <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" fill="currentColor" viewBox="0 0 16 16">
                        <path d="M11.742 10.344a6.5 6.5 0 1 0-1.397 1.398h-.001q.044.06.098.115l3.85 3.85a1 1 0 0 0 1.415-1.414l-3.85-3.85a1 1 0 0 0-.115-.1zM12 6.5a5.5 5.5 0 1 1-11 0 5.5 5.5 0 0 1 11 0"/>
                    </svg>
                </button>
            </div>
        </form>
    </div>
</section>

<!-- 공지 마퀴 배너 -->
<c:if test="${not empty marqueeNotices}">
    <div class="notice-marquee-bar">
        <span class="notice-marquee-label">공지</span>
        <div class="notice-marquee-wrap">
            <div class="notice-marquee-track">
                <c:forEach var="n" items="${marqueeNotices}" varStatus="s">
                    <a href="${pageContext.request.contextPath}/support/notices/${n.noticeId}"
                       class="notice-marquee-item">${n.title}</a>
                    <c:if test="${!s.last}"><span class="notice-marquee-sep">|</span></c:if>
                </c:forEach>
                <%-- 짧을 때 루프가 끊겨 보이지 않도록 한 번 더 복제 --%>
                <c:forEach var="n" items="${marqueeNotices}" varStatus="s">
                    <a href="${pageContext.request.contextPath}/support/notices/${n.noticeId}"
                       class="notice-marquee-item">${n.title}</a>
                    <c:if test="${!s.last}"><span class="notice-marquee-sep">|</span></c:if>
                </c:forEach>
            </div>
        </div>
    </div>
</c:if>

<!-- 카테고리 분류 -->
<c:if test="${not empty categories}">
    <div class="container mt-4">
        <div class="d-flex flex-wrap gap-3 justify-content-center">
            <c:forEach var="cat" items="${categories}">
                <a class="category-chip"
                   href="${pageContext.request.contextPath}/products?categoryId=${cat.categoryId}">
                    <span class="emoji">🛍️</span>
                    <span>${cat.name}</span>
                </a>
            </c:forEach>
        </div>
    </div>
</c:if>

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

    <div class="row g-4">

        <!-- 인기상품 (왼쪽) -->
        <div class="col-lg-6">
            <div class="d-flex justify-content-between align-items-center mb-3">
                <h6 class="section-title mb-0">인기상품</h6>            </div>
            <div class="row g-3">
                <c:if test="${empty popularProducts}">
                    <c:forEach begin="1" end="3">
                        <div class="col-4">
                            <div class="card product-card h-100">
                                <div class="product-img bg-light"></div>
                                <div class="card-body">
                                    <p class="placeholder-glow mb-1"><span class="placeholder col-7"></span></p>
                                    <p class="placeholder-glow mb-0"><span class="placeholder col-5"></span></p>
                                </div>
                            </div>
                        </div>
                    </c:forEach>
                </c:if>
                <c:forEach var="product" items="${popularProducts}" varStatus="status">
                    <div class="col-4">
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
        </div>

        <!-- 신상품 (오른쪽) -->
        <div class="col-lg-6">
            <div class="d-flex justify-content-between align-items-center mb-3">
                <h6 class="section-title mb-0">신상품</h6>            </div>
            <div class="row g-3">
                <c:if test="${empty newProducts}">
                    <c:forEach begin="1" end="3">
                        <div class="col-4">
                            <div class="card product-card h-100">
                                <div class="product-img bg-light"></div>
                                <div class="card-body">
                                    <p class="placeholder-glow mb-1"><span class="placeholder col-7"></span></p>
                                    <p class="placeholder-glow mb-0"><span class="placeholder col-5"></span></p>
                                </div>
                            </div>
                        </div>
                    </c:forEach>
                </c:if>
                <c:forEach var="product" items="${newProducts}">
                    <div class="col-4">
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
        </div>

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
