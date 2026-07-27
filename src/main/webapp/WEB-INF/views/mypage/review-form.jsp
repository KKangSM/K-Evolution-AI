<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>리뷰 작성 - K-Evolution</title>
    <%@ include file="/WEB-INF/views/layout/meta.jsp" %>
    <style>
        .star-input { display:inline-flex; flex-direction: row-reverse; justify-content: center; }
        .star-input input { display:none; }
        .star-input label { font-size:2.2rem; color:#dee2e6; cursor:pointer; padding:0 3px; transition:color .1s; }
        .star-input label:hover,
        .star-input label:hover ~ label,
        .star-input input:checked ~ label { color:#ffc107; }
    </style>
</head>
<body class="bg-light">
<%@ include file="/WEB-INF/views/layout/header.jsp" %>

<div class="container py-5" style="max-width:640px">
    <a href="${pageContext.request.contextPath}/orders" class="back-link"><i class="bi bi-chevron-left"></i>주문 내역</a>
    <h5 class="fw-bold mt-2 mb-4">리뷰 작성</h5>

    <%@ include file="/WEB-INF/views/layout/flash-toast.jsp" %>

    <div class="card shadow-sm">
        <div class="card-body">
            <%-- 대상 상품 --%>
            <div class="d-flex align-items-center gap-3 pb-3 mb-3 border-bottom">
                <c:choose>
                    <c:when test="${not empty item.product.imageUrl}">
                        <img src="${item.product.imageUrl}" alt="${item.productName}"
                             style="width:56px;height:72px;object-fit:cover;border-radius:6px;">
                    </c:when>
                    <c:otherwise>
                        <div style="width:56px;height:72px;background:#f1f3f5;border-radius:6px;"></div>
                    </c:otherwise>
                </c:choose>
                <div class="fw-semibold">${item.productName}</div>
            </div>

            <form action="${pageContext.request.contextPath}/mypage/reviews/write" method="post"
                  enctype="multipart/form-data">
                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                <input type="hidden" name="orderItemId" value="${item.orderItemId}"/>

                <div class="mb-3 text-center">
                    <label class="form-label small fw-semibold d-block mb-1">별점</label>
                    <div class="star-input">
                        <input type="radio" id="s5" name="rating" value="5" required><label for="s5">★</label>
                        <input type="radio" id="s4" name="rating" value="4"><label for="s4">★</label>
                        <input type="radio" id="s3" name="rating" value="3"><label for="s3">★</label>
                        <input type="radio" id="s2" name="rating" value="2"><label for="s2">★</label>
                        <input type="radio" id="s1" name="rating" value="1"><label for="s1">★</label>
                    </div>
                </div>

                <div class="mb-3">
                    <label class="form-label small fw-semibold">리뷰 내용</label>
                    <textarea name="content" rows="5" class="form-control"
                              placeholder="상품은 어떠셨나요? 다른 고객에게 도움이 되는 솔직한 후기를 남겨주세요." required></textarea>
                </div>

                <div class="mb-4">
                    <label class="form-label small fw-semibold">사진 첨부
                        <span class="text-muted fw-normal">(선택, 최대 5장)</span></label>
                    <input type="file" name="images" class="form-control" accept="image/*" multiple>
                </div>

                <div class="d-grid">
                    <button type="submit" class="btn btn-dark">리뷰 등록</button>
                </div>
            </form>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
