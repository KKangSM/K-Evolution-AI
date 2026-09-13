<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>마이페이지 - K-Evolution</title>
    <%@ include file="/WEB-INF/views/layout/meta.jsp" %>
</head>
<body class="bg-light theme-popart">
<%@ include file="/WEB-INF/views/layout/header.jsp" %>

<div class="container py-5" style="max-width:720px">
    <h4 class="fw-bold mb-1">마이페이지</h4>
    <p class="text-muted small mb-4">안녕하세요, <strong>${member.name}</strong>님</p>

    <div class="row g-3">
        <div class="col-6">
            <a href="${pageContext.request.contextPath}/mypage/edit" class="text-decoration-none">
                <div class="card h-100 shadow-sm text-center py-4">
                    <div class="fs-2 mb-2">👤</div>
                    <div class="fw-bold">내 정보 수정</div>
                    <div class="text-muted small">이름, 전화번호, 비밀번호</div>
                </div>
            </a>
        </div>
        <div class="col-6">
            <a href="${pageContext.request.contextPath}/mypage/addresses" class="text-decoration-none">
                <div class="card h-100 shadow-sm text-center py-4">
                    <div class="fs-2 mb-2">📦</div>
                    <div class="fw-bold">배송지 관리</div>
                    <div class="text-muted small">배송지 추가/삭제/기본 설정</div>
                </div>
            </a>
        </div>
        <div class="col-6">
            <a href="${pageContext.request.contextPath}/cart" class="text-decoration-none">
                <div class="card h-100 shadow-sm text-center py-4">
                    <div class="fs-2 mb-2">🛒</div>
                    <div class="fw-bold">장바구니</div>
                    <div class="text-muted small">담아둔 상품 확인</div>
                </div>
            </a>
        </div>
        <div class="col-6">
            <a href="${pageContext.request.contextPath}/orders" class="text-decoration-none">
                <div class="card h-100 shadow-sm text-center py-4">
                    <div class="fs-2 mb-2">🧾</div>
                    <div class="fw-bold">주문 내역</div>
                    <div class="text-muted small">주문 및 배송 현황</div>
                </div>
            </a>
        </div>
        <div class="col-6">
            <a href="${pageContext.request.contextPath}/mypage/points" class="text-decoration-none">
                <div class="card h-100 shadow-sm text-center py-4">
                    <div class="fs-2 mb-2">💰</div>
                    <div class="fw-bold">적립금</div>
                    <div class="text-muted small">잔액 및 적립·사용 내역</div>
                </div>
            </a>
        </div>
        <div class="col-6">
            <a href="${pageContext.request.contextPath}/mypage/reviews" class="text-decoration-none">
                <div class="card h-100 shadow-sm text-center py-4">
                    <div class="fs-2 mb-2">⭐</div>
                    <div class="fw-bold">내 리뷰</div>
                    <div class="text-muted small">작성한 상품 리뷰</div>
                </div>
            </a>
        </div>
        <div class="col-6">
            <a href="${pageContext.request.contextPath}/mypage/wishlist" class="text-decoration-none">
                <div class="card h-100 shadow-sm text-center py-4">
                    <div class="fs-2 mb-2">❤️</div>
                    <div class="fw-bold">찜 목록</div>
                    <div class="text-muted small">찜한 상품 보기</div>
                </div>
            </a>
        </div>
        <div class="col-6">
            <a href="${pageContext.request.contextPath}/mypage/returns" class="text-decoration-none">
                <div class="card h-100 shadow-sm text-center py-4">
                    <div class="fs-2 mb-2">↩️</div>
                    <div class="fw-bold">반품·교환 내역</div>
                    <div class="text-muted small">신청 및 처리 현황</div>
                </div>
            </a>
        </div>
        <div class="col-6">
            <a href="${pageContext.request.contextPath}/support" class="text-decoration-none">
                <div class="card h-100 shadow-sm text-center py-4">
                    <div class="fs-2 mb-2">💬</div>
                    <div class="fw-bold">고객센터</div>
                    <div class="text-muted small">공지사항, 1:1 문의</div>
                </div>
            </a>
        </div>
        <div class="col-6">
            <a href="${pageContext.request.contextPath}/mypage/withdraw" class="text-decoration-none">
                <div class="card h-100 shadow-sm text-center py-4">
                    <div class="fs-2 mb-2">🚪</div>
                    <div class="fw-bold text-danger">회원 탈퇴</div>
                    <div class="text-muted small">탈퇴 신청</div>
                </div>
            </a>
        </div>
    </div>
</div>

<%-- 취향 저격 추천 (개인화) --%>
<c:if test="${not empty recommendedProducts}">
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<div class="container pb-5" style="max-width:960px">
    <div class="rail-head">
        <h5 class="rail-title fw-bold mb-0">${member.name}님 취향 저격 <span class="rail-sub">구매·찜 이력 기반 추천</span></h5>
        <a href="${ctx}/products" class="rail-more">더보기 <i class="bi bi-chevron-right"></i></a>
    </div>
    <div class="product-rail">
        <c:forEach var="product" items="${recommendedProducts}">
            <div class="rail-card">
                <div class="card product-card h-100"
                     onclick="location.href='${ctx}/products/${product.productId}'">
                    <img src="${empty product.imageUrl ? 'https://placehold.co/300x360?text=No+Image' : product.imageUrl}"
                         class="card-img-top product-img" alt="상품 이미지">
                    <div class="card-body d-flex flex-column">
                        <p class="card-text text-muted small mb-1">${not empty product.category ? product.category.label : ''}</p>
                        <h6 class="card-title flex-grow-1">${product.name}</h6>
                        <div class="d-flex justify-content-between align-items-center mt-2">
                            <span class="fw-bold">
                                <fmt:formatNumber value="${product.price}" type="number" groupingUsed="true"/>원
                            </span>
                            <c:if test="${stockMap[product.productId] == 0}">
                                <span class="badge bg-secondary">품절</span>
                            </c:if>
                        </div>
                    </div>
                </div>
            </div>
        </c:forEach>
    </div>
</div>
</c:if>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
