<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>K-Evolution</title>
    <meta name="_csrf" content="${_csrf.token}">
    <meta name="_csrf_header" content="${_csrf.headerName}">
    <%@ include file="/WEB-INF/views/layout/meta.jsp" %>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/main.css">
</head>
<body class="bg-light">

<%@ include file="/WEB-INF/views/layout/header.jsp" %>

<%-- 로그아웃 직후 안내 토스트 --%>
<c:if test="${param.logout != null}">
    <c:set var="successMsg" value="로그아웃되었습니다." scope="request"/>
</c:if>
<%@ include file="/WEB-INF/views/layout/flash-toast.jsp" %>

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
                    <a role="button" tabindex="0" style="cursor:pointer"
                       data-bs-toggle="modal" data-bs-target="#noticeModal${n.noticeId}"
                       class="notice-marquee-item">
                        <span class="notice-marquee-title">${n.title}</span>
                        <span class="notice-marquee-dash">—</span>
                        <span class="notice-marquee-content">${n.content}</span>
                    </a>
                    <c:if test="${!s.last}"><span class="notice-marquee-sep">|</span></c:if>
                </c:forEach>
            </div>
        </div>
        <a class="notice-marquee-more" href="${pageContext.request.contextPath}/support/notices">
            더보기 <i class="bi bi-chevron-right"></i>
        </a>
    </div>
</c:if>

<!-- 카테고리 (공지 마퀴 아래, 가운데 정렬 + 아이콘) -->
<%-- 카테고리 세트는 Category enum 이 단일 소스. 칸 추가/수정은 enum 만 고치면 됩니다. --%>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<nav class="cat-grid">
    <a class="cat-item" href="${ctx}/products">
        <span class="cat-thumb"><img src="${ctx}/images/category/all.svg" alt="전체"></span>
        <span class="cat-label">전체</span>
    </a>
    <c:forEach var="cat" items="${globalCategories}">
        <a class="cat-item" href="${ctx}/products?category=${cat}">
            <span class="cat-thumb"><img src="${ctx}/images/category/${cat.icon}.svg" alt="${cat.label}"></span>
            <span class="cat-label">${cat.label}</span>
        </a>
    </c:forEach>
</nav>

<!-- 이벤트 캐러셀 (노출중인 배너) -->
<c:if test="${not empty banners}">
<div class="container mt-4">
    <div id="eventCarousel" class="carousel slide event-carousel shadow-sm" data-bs-ride="carousel">
        <c:if test="${banners.size() > 1}">
        <div class="carousel-indicators">
            <c:forEach var="b" items="${banners}" varStatus="st">
                <button type="button" data-bs-target="#eventCarousel" data-bs-slide-to="${st.index}"
                        class="${st.first ? 'active' : ''}"
                        <c:if test="${st.first}">aria-current="true"</c:if>
                        aria-label="슬라이드 ${st.count}"></button>
            </c:forEach>
        </div>
        </c:if>
        <div class="carousel-inner">
            <c:forEach var="b" items="${banners}" varStatus="st">
            <div class="carousel-item ${st.first ? 'active' : ''}">
                <c:choose>
                    <c:when test="${not empty b.linkUrl}">
                        <a href="${b.linkUrl}">
                            <div class="event-slide" style="background-image:url('${b.imageUrl}'); background-size:cover; background-position:center;"></div>
                        </a>
                    </c:when>
                    <c:otherwise>
                        <div class="event-slide" style="background-image:url('${b.imageUrl}'); background-size:cover; background-position:center;"></div>
                    </c:otherwise>
                </c:choose>
            </div>
            </c:forEach>
        </div>
        <c:if test="${banners.size() > 1}">
        <button class="carousel-control-prev" type="button" data-bs-target="#eventCarousel" data-bs-slide="prev">
            <span class="carousel-control-prev-icon" aria-hidden="true"></span>
            <span class="visually-hidden">이전</span>
        </button>
        <button class="carousel-control-next" type="button" data-bs-target="#eventCarousel" data-bs-slide="next">
            <span class="carousel-control-next-icon" aria-hidden="true"></span>
            <span class="visually-hidden">다음</span>
        </button>
        </c:if>
    </div>
</div>
</c:if>

<div class="container my-5">
    <div class="row g-4">

        <!-- 인기상품 -->
        <div class="col-lg-6">
            <div class="d-flex justify-content-between align-items-center mb-3">
                <h6 class="section-title mb-0">인기상품</h6>
                <a href="${pageContext.request.contextPath}/products" class="text-muted small">더보기 &rsaquo;</a>
            </div>
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
        </div>

        <!-- 신상품 -->
        <div class="col-lg-6">
            <div class="d-flex justify-content-between align-items-center mb-3">
                <h6 class="section-title mb-0">신상품</h6>
                <a href="${pageContext.request.contextPath}/products" class="text-muted small">더보기 &rsaquo;</a>
            </div>
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
    <div class="container text-center small text-light">
        <div class="opacity-75 mb-1">
            <i class="bi bi-telephone"></i> 고객센터 02-0000-0000
            <span class="opacity-50">· 평일 09:00~18:00 (주말/공휴일 휴무)</span>
        </div>
        <div class="opacity-50">© 2026 K-Evolution. All rights reserved.</div>
    </div>
</footer>

<%-- 마퀴 공지 모달 (메인에서 바로 표시) --%>
<c:forEach var="n" items="${marqueeNotices}">
    <div class="modal fade" id="noticeModal${n.noticeId}" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered modal-dialog-scrollable notice-view-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h6 class="modal-title fw-bold">
                        <c:out value="${n.title}"/>
                    </h6>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="닫기"></button>
                </div>
                <div class="modal-body notice-view-body">
                    <div class="text-muted small mb-3">
                        등록일: ${n.createdAt.toString().substring(0, 10)}
                        &nbsp;|&nbsp; 조회수: <span class="notice-view-count">${n.viewCount}</span>
                    </div>
                    <c:if test="${not empty n.imageUrl}">
                        <img src="${n.imageUrl}" alt="공지 이미지" class="notice-view-img mb-3">
                    </c:if>
                    <div style="white-space: pre-wrap;">${n.content}</div>
                </div>
            </div>
        </div>
    </div>
</c:forEach>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    // 마퀴 공지 모달을 처음 열 때 1회 조회수 증가 + 화면 숫자 즉시 +1
    (function () {
        var ctx = '${pageContext.request.contextPath}';
        var tokenMeta = document.querySelector('meta[name="_csrf"]');
        var headerMeta = document.querySelector('meta[name="_csrf_header"]');
        document.querySelectorAll('[id^="noticeModal"]').forEach(function (modal) {
            modal.addEventListener('show.bs.modal', function () {
                if (modal.dataset.viewed === 'true') return;
                modal.dataset.viewed = 'true';
                var id = modal.id.replace('noticeModal', '');
                var headers = {};
                if (tokenMeta && headerMeta) headers[headerMeta.content] = tokenMeta.content;
                fetch(ctx + '/support/notices/' + id + '/view', { method: 'POST', headers: headers });
                var countEl = modal.querySelector('.notice-view-count');
                if (countEl) {
                    var cur = parseInt(countEl.textContent, 10);
                    if (!isNaN(cur)) countEl.textContent = cur + 1;
                }
            });
        });
    })();
</script>
</body>
</html>
