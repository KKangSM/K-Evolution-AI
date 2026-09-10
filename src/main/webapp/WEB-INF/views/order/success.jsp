<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>결제 완료 — K-Evolution</title>
    <%@ include file="/WEB-INF/views/layout/meta.jsp" %>
    <c:set var="ctx" value="${pageContext.request.contextPath}" />
</head>
<body class="bg-light theme-popart">

<%@ include file="/WEB-INF/views/layout/header.jsp" %>

<div class="container py-5" style="max-width: 560px;">
    <div class="card shadow-sm text-center">
        <div class="card-body p-5">
            <div class="mb-3">
                <i class="bi bi-check-circle-fill text-success" style="font-size: 3.5rem;"></i>
            </div>
            <h4 class="fw-bold mb-2">결제가 완료되었습니다</h4>
            <p class="text-muted mb-4">주문해 주셔서 감사합니다.</p>

            <div class="text-start border rounded p-3 mb-4">
                <div class="d-flex justify-content-between mb-2">
                    <span class="text-muted">주문번호</span>
                    <span class="fw-semibold">${order.orderId}</span>
                </div>
                <div class="d-flex justify-content-between mb-2">
                    <span class="text-muted">받는 사람</span>
                    <span>${order.receiverName}</span>
                </div>
                <div class="d-flex justify-content-between mb-2">
                    <span class="text-muted">배송지</span>
                    <span class="text-end">${order.address}</span>
                </div>
                <hr class="my-2">
                <div class="d-flex justify-content-between">
                    <span class="fw-bold">결제금액</span>
                    <span class="fw-bold">
                        <fmt:formatNumber value="${order.finalPrice}" type="number" groupingUsed="true"/>원
                    </span>
                </div>
            </div>

            <div class="d-grid gap-2">
                <a href="${ctx}/products" class="btn btn-dark">쇼핑 계속하기</a>
                <a href="${ctx}/" class="btn btn-outline-secondary">홈으로</a>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
