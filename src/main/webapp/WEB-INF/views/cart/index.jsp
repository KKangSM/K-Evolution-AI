<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>장바구니 — K-Evolution</title>
    <%@ include file="/WEB-INF/views/layout/meta.jsp" %>
    <style>
        .cart-img { width: 72px; height: 72px; object-fit: cover; border-radius: 8px; background: #f1f3f5; }
        .qty-input { width: 56px; text-align: center; }
    </style>
</head>
<body class="bg-light">

<%@ include file="/WEB-INF/views/layout/header.jsp" %>
<%@ include file="/WEB-INF/views/layout/flash-toast.jsp" %>

<div class="container py-4" style="max-width: 860px;">

    <a href="${pageContext.request.contextPath}/products" class="back-link mb-4">
        <i class="bi bi-chevron-left"></i> 쇼핑 계속하기
    </a>

    <h4 class="fw-bold mt-3 mb-4">장바구니</h4>

    <c:choose>
        <c:when test="${empty cart.cartItems}">
            <div class="card shadow-sm text-center py-5">
                <div class="mb-3"><i class="bi bi-cart-x" style="font-size: 3rem; color: var(--kv-muted);"></i></div>
                <p class="text-muted mb-3">장바구니가 비어 있습니다.</p>
                <a href="${pageContext.request.contextPath}/products" class="btn btn-dark px-4 mx-auto" style="width:fit-content;">
                    상품 보러가기
                </a>
            </div>
        </c:when>
        <c:otherwise>
            <div class="card shadow-sm mb-4">
                <div class="card-body p-0">
                    <c:forEach var="item" items="${cart.cartItems}" varStatus="vs">
                        <div class="d-flex align-items-center gap-3 p-3 ${vs.last ? '' : 'border-bottom'}">

                            <%-- 이미지 --%>
                            <img src="${empty item.product.imageUrl
                                ? 'https://placehold.co/72x72?text=No+Image'
                                : item.product.imageUrl}"
                                 class="cart-img flex-shrink-0" alt="${item.product.name}">

                            <%-- 상품 정보 --%>
                            <div class="flex-grow-1">
                                <p class="text-muted small mb-0">${not empty item.product.category ? item.product.category.label : ''}</p>
                                <a href="${pageContext.request.contextPath}/products/${item.product.productId}"
                                   class="fw-semibold text-dark text-decoration-none">${item.product.name}</a>
                                <p class="text-muted small mb-0">
                                    <fmt:formatNumber value="${item.product.price}" type="number" groupingUsed="true"/>원
                                </p>
                            </div>

                            <%-- 수량 변경 --%>
                            <form action="${pageContext.request.contextPath}/cart/update" method="post"
                                  class="d-flex align-items-center gap-1">
                                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                                <input type="hidden" name="cartItemId" value="${item.cartItemId}"/>
                                <button type="submit" name="quantity" value="${item.quantity - 1}"
                                        class="btn btn-outline-secondary btn-sm px-2">
                                    <i class="bi bi-dash"></i>
                                </button>
                                <input type="text" class="form-control form-control-sm qty-input"
                                       value="${item.quantity}" readonly>
                                <button type="submit" name="quantity" value="${item.quantity + 1}"
                                        class="btn btn-outline-secondary btn-sm px-2">
                                    <i class="bi bi-plus"></i>
                                </button>
                            </form>

                            <%-- 소계 --%>
                            <div class="text-end fw-bold" style="min-width:80px;">
                                <fmt:formatNumber value="${item.totalPrice}" type="number" groupingUsed="true"/>원
                            </div>

                            <%-- 삭제 --%>
                            <form action="${pageContext.request.contextPath}/cart/remove/${item.cartItemId}" method="post">
                                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                                <button type="submit" class="btn btn-link text-muted p-0"
                                        title="삭제" onclick="return confirm('삭제하시겠습니까?')">
                                    <i class="bi bi-x-lg"></i>
                                </button>
                            </form>

                        </div>
                    </c:forEach>
                </div>
            </div>

            <%-- 합계 & 주문 버튼 --%>
            <div class="card shadow-sm">
                <div class="card-body">
                    <div class="d-flex justify-content-between align-items-center mb-2">
                        <span class="text-muted">상품 합계</span>
                        <span><fmt:formatNumber value="${totalPrice}" type="number" groupingUsed="true"/>원</span>
                    </div>
                    <div class="d-flex justify-content-between align-items-center mb-3">
                        <span class="text-muted">배송비</span>
                        <span class="text-muted small">
                            <c:choose>
                                <c:when test="${totalPrice >= 50000}">무료</c:when>
                                <c:otherwise>3,000원</c:otherwise>
                            </c:choose>
                        </span>
                    </div>
                    <hr>
                    <div class="d-flex justify-content-between align-items-center mb-4">
                        <span class="fw-bold fs-5">결제 예정금액</span>
                        <span class="fw-bold fs-5">
                            <fmt:formatNumber
                                value="${totalPrice >= 50000 ? totalPrice : totalPrice + 3000}"
                                type="number" groupingUsed="true"/>원
                        </span>
                    </div>
                    <div class="d-grid">
                        <button class="btn btn-dark btn-lg" disabled>
                            주문하기 (준비 중)
                        </button>
                    </div>
                    <p class="text-muted small text-center mt-2 mb-0">5만원 이상 구매 시 무료배송</p>
                </div>
            </div>

        </c:otherwise>
    </c:choose>

</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
