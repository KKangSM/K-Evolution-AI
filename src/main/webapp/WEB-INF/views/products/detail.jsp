<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>${product.name} — K-Evolution</title>
    <%@ include file="/WEB-INF/views/layout/meta.jsp" %>
    <style>
        .product-main-img {
            width: 100%;
            aspect-ratio: 3 / 4;
            object-fit: cover;
            border-radius: var(--kv-radius);
        }
        .img-placeholder {
            width: 100%;
            aspect-ratio: 3 / 4;
            background: #f1f3f5;
            border-radius: var(--kv-radius);
            display: flex;
            align-items: center;
            justify-content: center;
        }
        .product-sub-img {
            height: 90px;
            width: 90px;
            object-fit: cover;
            border-radius: 8px;
            border: 1px solid #e9ecef;
            cursor: pointer;
            transition: transform 0.15s;
        }
        .product-sub-img:hover { transform: scale(1.05); }
        .price-tag {
            font-size: 2rem;
            font-weight: 800;
            letter-spacing: -0.03em;
            color: var(--kv-primary);
        }
        .desc-box {
            white-space: pre-wrap;
            font-size: 0.88rem;
            line-height: 1.85;
            color: var(--kv-muted);
        }
    </style>
</head>
<body class="bg-light">

<%@ include file="/WEB-INF/views/layout/header.jsp" %>

<div class="container py-4">

    <a href="${pageContext.request.contextPath}/products" class="back-link mb-4">
        <i class="bi bi-chevron-left"></i> 목록으로
    </a>

    <div class="row g-5 mt-1">

        <%-- ── 이미지 ── --%>
        <div class="col-md-6">
            <c:choose>
                <c:when test="${not empty product.imageUrl}">
                    <img src="${product.imageUrl}" alt="${product.name}" class="product-main-img" id="mainImg">
                </c:when>
                <c:otherwise>
                    <div class="img-placeholder">
                        <i class="bi bi-image text-muted" style="font-size: 4rem;"></i>
                    </div>
                </c:otherwise>
            </c:choose>

            <%-- ── 추가 이미지 갤러리 ── --%>
            <c:if test="${not empty images}">
                <div class="d-flex flex-wrap gap-2 mt-3">
                    <c:forEach var="img" items="${images}">
                        <img src="${img.imageUrl}" alt="${product.name}" class="product-sub-img">
                    </c:forEach>
                </div>
            </c:if>
        </div>

        <%-- ── 상품 정보 ── --%>
        <div class="col-md-6 d-flex flex-column">

            <c:if test="${not empty product.category}">
                <span class="badge bg-light text-dark border mb-2 align-self-start">
                    ${product.category.name}
                </span>
            </c:if>

            <h1 class="fs-3 fw-bold mb-3">${product.name}</h1>

            <div class="price-tag mb-4">
                <fmt:formatNumber value="${product.price}" type="number" groupingUsed="true"/>원
            </div>

            <%-- 재고 상태 --%>
            <div class="mb-4">
                <c:choose>
                    <c:when test="${product.stock == 0}">
                        <span class="badge bg-secondary px-3 py-2 fs-6">품절</span>
                    </c:when>
                    <c:when test="${product.stock <= 5}">
                        <span class="text-danger small fw-semibold">
                            <i class="bi bi-exclamation-circle"></i> 재고 ${product.stock}개 남음
                        </span>
                    </c:when>
                    <c:otherwise>
                        <span class="text-success small fw-semibold">
                            <i class="bi bi-check-circle"></i> 재고 있음
                        </span>
                    </c:otherwise>
                </c:choose>
            </div>

            <%-- 사이즈 / 색상 옵션 --%>
            <c:if test="${not empty sizes}">
                <div class="mb-3">
                    <h6 class="fw-bold mb-2">사이즈</h6>
                    <div class="d-flex flex-wrap gap-2">
                        <c:forEach var="size" items="${sizes}">
                            <span class="badge bg-light text-dark border px-3 py-2">${size}</span>
                        </c:forEach>
                    </div>
                </div>
            </c:if>
            <c:if test="${not empty colors}">
                <div class="mb-4">
                    <h6 class="fw-bold mb-2">색상</h6>
                    <div class="d-flex flex-wrap gap-2">
                        <c:forEach var="color" items="${colors}">
                            <span class="badge bg-light text-dark border px-3 py-2"><c:out value="${color}"/></span>
                        </c:forEach>
                    </div>
                </div>
            </c:if>

            <%-- 장바구니 버튼 --%>
            <div class="d-grid mb-5">
                <c:choose>
                    <c:when test="${product.stock == 0}">
                        <button class="btn btn-dark btn-lg" disabled>
                            <i class="bi bi-cart-x me-1"></i> 품절된 상품입니다
                        </button>
                    </c:when>
                    <c:otherwise>
                        <form action="${pageContext.request.contextPath}/cart/add" method="post">
                            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                            <input type="hidden" name="productId" value="${product.productId}"/>
                            <input type="hidden" name="quantity" value="1"/>
                            <button type="submit" class="btn btn-dark btn-lg w-100">
                                <i class="bi bi-cart-plus me-1"></i> 장바구니 담기
                            </button>
                        </form>
                    </c:otherwise>
                </c:choose>
            </div>

            <hr>

            <%-- 상품 설명 --%>
            <c:if test="${not empty product.description}">
                <h6 class="fw-bold mb-2">상품 설명</h6>
                <div class="desc-box"><c:out value="${product.description}"/></div>
            </c:if>

        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    // 추가 이미지를 클릭하면 대표(메인) 이미지로 교체한다.
    document.querySelectorAll('.product-sub-img').forEach(function (thumb) {
        thumb.addEventListener('click', function () {
            const main = document.getElementById('mainImg');
            if (main) main.src = this.src;
        });
    });
</script>
</body>
</html>
