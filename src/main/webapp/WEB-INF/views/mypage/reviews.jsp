<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>내 리뷰 - K-Evolution</title>
    <%@ include file="/WEB-INF/views/layout/meta.jsp" %>
</head>
<body class="bg-light">
<%@ include file="/WEB-INF/views/layout/header.jsp" %>

<div class="container py-5" style="max-width:720px">
    <a href="${pageContext.request.contextPath}/mypage" class="back-link"><i class="bi bi-chevron-left"></i>마이페이지</a>
    <h5 class="fw-bold mt-2 mb-4">내 리뷰</h5>

    <%@ include file="/WEB-INF/views/layout/flash-toast.jsp" %>

    <c:forEach var="r" items="${reviews}">
        <div class="card shadow-sm mb-3">
            <div class="card-body">
                <div class="d-flex align-items-center gap-3 mb-2">
                    <a href="${pageContext.request.contextPath}/products/${r.product.productId}">
                        <c:choose>
                            <c:when test="${not empty r.product.imageUrl}">
                                <img src="${r.product.imageUrl}" alt="${r.product.name}"
                                     style="width:48px;height:60px;object-fit:cover;border-radius:6px;">
                            </c:when>
                            <c:otherwise>
                                <div style="width:48px;height:60px;background:#f1f3f5;border-radius:6px;"></div>
                            </c:otherwise>
                        </c:choose>
                    </a>
                    <div class="flex-fill">
                        <a href="${pageContext.request.contextPath}/products/${r.product.productId}"
                           class="fw-semibold small text-decoration-none text-dark">${r.product.name}</a>
                        <div class="text-warning small">
                            <c:forEach begin="1" end="5" var="i"><i class="bi ${i <= r.rating ? 'bi-star-fill' : 'bi-star'}"></i></c:forEach>
                            <span class="text-muted ms-1">${fn:substring(r.createdAt, 0, 10)}</span>
                        </div>
                    </div>
                </div>
                <div class="mb-2" style="white-space:pre-wrap; font-size:.9rem;"><c:out value="${r.content}"/></div>
                <c:if test="${not empty r.images}">
                    <div class="d-flex flex-wrap gap-2 mb-2">
                        <c:forEach var="img" items="${r.images}">
                            <img src="${img.imageUrl}" alt="리뷰 이미지"
                                 style="width:72px;height:72px;object-fit:cover;border-radius:6px;border:1px solid #e9ecef;cursor:pointer"
                                 onclick="window.open(this.src)">
                        </c:forEach>
                    </div>
                </c:if>
                <div class="d-flex justify-content-end gap-2">
                    <button type="button" class="btn btn-sm btn-outline-secondary edit-btn"
                            data-id="${r.reviewId}" data-rating="${r.rating}"
                            data-content="<c:out value='${r.content}'/>">수정</button>
                    <form action="${pageContext.request.contextPath}/mypage/reviews/${r.reviewId}/delete"
                          method="post" onsubmit="return confirm('리뷰를 삭제하시겠습니까?')">
                        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                        <button class="btn btn-sm btn-outline-danger">삭제</button>
                    </form>
                </div>
            </div>
        </div>
    </c:forEach>

    <c:if test="${empty reviews}">
        <div class="text-center text-muted py-5">
            <i class="bi bi-chat-square-heart" style="font-size:2rem"></i>
            <div class="mt-2">작성한 리뷰가 없습니다.</div>
            <a href="${pageContext.request.contextPath}/orders" class="btn btn-dark btn-sm mt-3">주문 내역에서 리뷰 쓰기</a>
        </div>
    </c:if>
</div>

<!-- 리뷰 수정 모달 -->
<div class="modal fade" id="editModal" tabindex="-1">
    <div class="modal-dialog">
        <form class="modal-content" id="editForm" method="post">
            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
            <div class="modal-header">
                <h6 class="modal-title fw-bold">리뷰 수정</h6>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <div class="mb-3">
                    <label class="form-label small fw-semibold">별점</label>
                    <select name="rating" id="editRating" class="form-select form-select-sm">
                        <option value="5">★★★★★ (5점)</option>
                        <option value="4">★★★★ (4점)</option>
                        <option value="3">★★★ (3점)</option>
                        <option value="2">★★ (2점)</option>
                        <option value="1">★ (1점)</option>
                    </select>
                </div>
                <div class="mb-2">
                    <label class="form-label small fw-semibold">리뷰 내용</label>
                    <textarea name="content" id="editContent" rows="4" class="form-control form-control-sm" required></textarea>
                </div>
                <p class="text-muted small mb-0">※ 사진 수정이 필요하면 삭제 후 다시 작성해주세요.</p>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-sm btn-outline-secondary" data-bs-dismiss="modal">취소</button>
                <button type="submit" class="btn btn-sm btn-dark">수정 완료</button>
            </div>
        </form>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    const ctx = '${pageContext.request.contextPath}';
    const editModal = new bootstrap.Modal(document.getElementById('editModal'));
    document.querySelectorAll('.edit-btn').forEach(function (btn) {
        btn.addEventListener('click', function () {
            document.getElementById('editForm').action = ctx + '/mypage/reviews/' + this.dataset.id + '/edit';
            document.getElementById('editRating').value = this.dataset.rating;
            document.getElementById('editContent').value = this.dataset.content;
            editModal.show();
        });
    });
</script>
</body>
</html>
