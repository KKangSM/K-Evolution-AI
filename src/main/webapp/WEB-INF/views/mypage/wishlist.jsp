<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>찜 목록 - K-Evolution</title>
    <%@ include file="/WEB-INF/views/layout/meta.jsp" %>
</head>
<body class="bg-light theme-popart">
<%@ include file="/WEB-INF/views/layout/header.jsp" %>

<div class="container py-5" style="max-width:720px">
    <a href="${pageContext.request.contextPath}/mypage" class="back-link"><i class="bi bi-chevron-left"></i>마이페이지</a>
    <h5 class="fw-bold mt-2 mb-4">찜 목록</h5>

    <%@ include file="/WEB-INF/views/layout/flash-toast.jsp" %>

    <c:forEach var="w" items="${wishlist}">
        <div class="card shadow-sm mb-3">
            <div class="card-body d-flex align-items-center gap-3">
                <a href="${pageContext.request.contextPath}/products/${w.product.productId}">
                    <c:choose>
                        <c:when test="${not empty w.product.imageUrl}">
                            <img src="${w.product.imageUrl}" alt="${w.product.name}"
                                 style="width:72px;height:96px;object-fit:cover;border-radius:8px;">
                        </c:when>
                        <c:otherwise>
                            <div style="width:72px;height:96px;background:#f1f3f5;border-radius:8px;"></div>
                        </c:otherwise>
                    </c:choose>
                </a>
                <div class="flex-fill">
                    <a href="${pageContext.request.contextPath}/products/${w.product.productId}"
                       class="fw-bold text-decoration-none text-dark">${w.product.name}</a>
                    <div class="text-danger fw-bold mt-1">
                        <fmt:formatNumber value="${w.product.price}" type="number"/>원
                    </div>
                </div>
                <form action="${pageContext.request.contextPath}/mypage/wishlist/${w.product.productId}/remove"
                      method="post" onsubmit="return confirm('찜을 해제하시겠습니까?')">
                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                    <button class="btn btn-sm btn-outline-danger"><i class="bi bi-heart-fill"></i></button>
                </form>
            </div>
        </div>
    </c:forEach>

    <c:if test="${empty wishlist}">
        <div class="text-center text-muted py-5">
            <i class="bi bi-heart" style="font-size:2rem"></i>
            <div class="mt-2">찜한 상품이 없습니다.</div>
            <a href="${pageContext.request.contextPath}/products" class="btn btn-dark btn-sm mt-3">상품 보러가기</a>
        </div>
    </c:if>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
