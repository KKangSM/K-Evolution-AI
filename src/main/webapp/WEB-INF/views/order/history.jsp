<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>주문 내역 - K-Evolution</title>
    <%@ include file="/WEB-INF/views/layout/meta.jsp" %>
</head>
<body class="bg-light">
<%@ include file="/WEB-INF/views/layout/header.jsp" %>

<div class="container py-5" style="max-width:800px">
    <a href="${pageContext.request.contextPath}/mypage" class="back-link"><i class="bi bi-chevron-left"></i>마이페이지</a>
    <h5 class="fw-bold mt-2 mb-4">주문 내역</h5>

    <%@ include file="/WEB-INF/views/layout/flash-toast.jsp" %>

    <c:forEach var="order" items="${orders}">
        <div class="card shadow-sm mb-3">
            <div class="card-header bg-white d-flex justify-content-between align-items-center">
                <div>
                    <span class="text-muted small">주문번호 #${order.orderId}</span>
                    <span class="text-muted small ms-2">${order.createdAt}</span>
                </div>
                <c:choose>
                    <c:when test="${order.status == 'PAID'}"><span class="badge bg-success">결제완료</span></c:when>
                    <c:when test="${order.status == 'PENDING'}"><span class="badge bg-secondary">결제대기</span></c:when>
                    <c:otherwise><span class="badge bg-danger">취소</span></c:otherwise>
                </c:choose>
            </div>
            <div class="card-body">
                <c:forEach var="item" items="${order.orderItems}">
                    <div class="d-flex align-items-center gap-3 py-2 border-bottom">
                        <a href="${pageContext.request.contextPath}/products/${item.product.productId}">
                            <c:choose>
                                <c:when test="${not empty item.product.imageUrl}">
                                    <img src="${item.product.imageUrl}" alt="${item.productName}"
                                         style="width:56px;height:72px;object-fit:cover;border-radius:6px;">
                                </c:when>
                                <c:otherwise>
                                    <div style="width:56px;height:72px;background:#f1f3f5;border-radius:6px;"></div>
                                </c:otherwise>
                            </c:choose>
                        </a>
                        <div class="flex-fill">
                            <div class="fw-semibold small">${item.productName}</div>
                            <div class="text-muted small">
                                <fmt:formatNumber value="${item.price}" type="number"/>원 · ${item.quantity}개
                            </div>
                        </div>
                        <c:if test="${order.status == 'PAID'}">
                            <c:choose>
                                <c:when test="${returnedItemIds.contains(item.orderItemId)}">
                                    <span class="badge bg-light text-secondary border">신청됨</span>
                                </c:when>
                                <c:otherwise>
                                    <button type="button" class="btn btn-sm btn-outline-secondary return-btn"
                                            data-item-id="${item.orderItemId}" data-item-name="${item.productName}">
                                        반품·교환
                                    </button>
                                </c:otherwise>
                            </c:choose>
                        </c:if>
                    </div>
                </c:forEach>
                <div class="text-end fw-bold mt-3">
                    결제금액 <span class="text-danger"><fmt:formatNumber value="${order.finalPrice}" type="number"/>원</span>
                </div>
            </div>
        </div>
    </c:forEach>

    <c:if test="${empty orders}">
        <div class="text-center text-muted py-5">
            <i class="bi bi-receipt" style="font-size:2rem"></i>
            <div class="mt-2">주문 내역이 없습니다.</div>
            <a href="${pageContext.request.contextPath}/products" class="btn btn-dark btn-sm mt-3">쇼핑하러 가기</a>
        </div>
    </c:if>
</div>

<!-- 반품/교환 신청 모달 -->
<div class="modal fade" id="returnModal" tabindex="-1">
    <div class="modal-dialog">
        <form class="modal-content" action="${pageContext.request.contextPath}/mypage/returns/request" method="post">
            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
            <input type="hidden" name="orderItemId" id="returnItemId"/>
            <div class="modal-header">
                <h6 class="modal-title fw-bold">반품·교환 신청</h6>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <p class="small mb-3">상품: <span id="returnItemName" class="fw-semibold"></span></p>
                <div class="mb-3">
                    <label class="form-label small fw-semibold">유형</label>
                    <select name="type" class="form-select form-select-sm">
                        <option value="RETURN">반품</option>
                        <option value="EXCHANGE">교환</option>
                    </select>
                </div>
                <div class="mb-2">
                    <label class="form-label small fw-semibold">사유</label>
                    <textarea name="reason" rows="3" class="form-control form-control-sm"
                              placeholder="사유를 입력해주세요." required></textarea>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-sm btn-outline-secondary" data-bs-dismiss="modal">취소</button>
                <button type="submit" class="btn btn-sm btn-dark">신청하기</button>
            </div>
        </form>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    const returnModal = new bootstrap.Modal(document.getElementById('returnModal'));
    document.querySelectorAll('.return-btn').forEach(function (btn) {
        btn.addEventListener('click', function () {
            document.getElementById('returnItemId').value = this.dataset.itemId;
            document.getElementById('returnItemName').textContent = this.dataset.itemName;
            returnModal.show();
        });
    });
</script>
</body>
</html>
