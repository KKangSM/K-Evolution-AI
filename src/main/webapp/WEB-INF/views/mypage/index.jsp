<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
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

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
