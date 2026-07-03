<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>결제 — K-Evolution</title>
    <%@ include file="/WEB-INF/views/layout/meta.jsp" %>
    <c:set var="ctx" value="${pageContext.request.contextPath}" />
    <c:set var="shipping" value="${order.finalPrice - order.totalPrice + order.discountAmount}" />
</head>
<body class="bg-light">

<%@ include file="/WEB-INF/views/layout/header.jsp" %>
<%@ include file="/WEB-INF/views/layout/flash-toast.jsp" %>

<div class="container py-4" style="max-width: 720px;">

    <a href="${ctx}/cart" class="back-link mb-4">
        <i class="bi bi-chevron-left"></i> 장바구니로
    </a>

    <h4 class="fw-bold mt-3 mb-4">주문/결제</h4>

    <%-- 주문 상품 --%>
    <div class="card shadow-sm mb-3">
        <div class="card-body">
            <h6 class="fw-bold mb-3">주문 상품</h6>
            <c:forEach var="item" items="${order.orderItems}" varStatus="vs">
                <div class="d-flex justify-content-between ${vs.last ? '' : 'mb-2'}">
                    <span class="text-truncate me-2">${item.productName}
                        <span class="text-muted small">x${item.quantity}</span>
                    </span>
                    <span class="text-nowrap">
                        <fmt:formatNumber value="${item.totalPrice}" type="number" groupingUsed="true"/>원
                    </span>
                </div>
            </c:forEach>
        </div>
    </div>

    <%-- 배송지 --%>
    <div class="card shadow-sm mb-3">
        <div class="card-body">
            <h6 class="fw-bold mb-3">배송지</h6>
            <form id="shippingForm">
                <div class="mb-2">
                    <label class="form-label small text-muted mb-1">받는 사람</label>
                    <input type="text" class="form-control" name="receiverName"
                           value="<c:out value='${order.receiverName}'/>" required>
                </div>
                <div class="mb-2">
                    <label class="form-label small text-muted mb-1">연락처</label>
                    <input type="text" class="form-control" name="receiverPhone"
                           value="<c:out value='${order.receiverPhone}'/>" placeholder="010-0000-0000" required>
                </div>
                <div class="mb-0">
                    <label class="form-label small text-muted mb-1">주소</label>
                    <input type="text" class="form-control" name="address"
                           value="<c:out value='${order.address}'/>" required>
                </div>
            </form>
        </div>
    </div>

    <%-- 금액 --%>
    <div class="card shadow-sm mb-3">
        <div class="card-body">
            <div class="d-flex justify-content-between mb-2">
                <span class="text-muted">상품 합계</span>
                <span><fmt:formatNumber value="${order.totalPrice}" type="number" groupingUsed="true"/>원</span>
            </div>
            <div class="d-flex justify-content-between mb-2">
                <span class="text-muted">배송비</span>
                <span>
                    <c:choose>
                        <c:when test="${shipping == 0}">무료</c:when>
                        <c:otherwise><fmt:formatNumber value="${shipping}" type="number" groupingUsed="true"/>원</c:otherwise>
                    </c:choose>
                </span>
            </div>
            <hr>
            <div class="d-flex justify-content-between align-items-center">
                <span class="fw-bold fs-5">최종 결제금액</span>
                <span class="fw-bold fs-5">
                    <fmt:formatNumber value="${order.finalPrice}" type="number" groupingUsed="true"/>원
                </span>
            </div>
        </div>
    </div>

    <%-- 토스 결제위젯 --%>
    <div class="card shadow-sm mb-3">
        <div class="card-body">
            <div id="payment-method"></div>
            <div id="agreement"></div>
        </div>
    </div>

    <div class="d-grid">
        <button id="payButton" class="btn btn-dark btn-lg" disabled>결제하기</button>
    </div>

    <input type="hidden" id="orderName" value="<c:out value='${orderName}'/>">
</div>

<script src="https://js.tosspayments.com/v2/standard"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    const ctx = "${ctx}";
    const clientKey = "${clientKey}";
    const customerKey = "${customerKey}";
    const tossOrderId = "${order.tossOrderId}";
    const amount = { currency: "KRW", value: ${order.finalPrice} };
    const csrfHeader = "${_csrf.headerName}";
    const csrfToken = "${_csrf.token}";

    const payButton = document.getElementById("payButton");
    const tossPayments = TossPayments(clientKey);
    const widgets = tossPayments.widgets({ customerKey });

    async function init() {
        await widgets.setAmount(amount);
        await Promise.all([
            widgets.renderPaymentMethods({ selector: "#payment-method", variantKey: "DEFAULT" }),
            widgets.renderAgreement({ selector: "#agreement", variantKey: "DEFAULT" }),
        ]);
        payButton.disabled = false;
    }
    init();

    payButton.addEventListener("click", async () => {
        const form = document.getElementById("shippingForm");
        if (!form.reportValidity()) return;

        payButton.disabled = true;
        try {
            // 결제 직전 배송지 저장
            const body = new URLSearchParams(new FormData(form)).toString();
            const resp = await fetch(ctx + "/order/${order.orderId}/shipping", {
                method: "POST",
                headers: {
                    "Content-Type": "application/x-www-form-urlencoded;charset=UTF-8",
                    [csrfHeader]: csrfToken,
                },
                body: body,
            });
            if (!resp.ok) {
                alert("배송지 저장에 실패했습니다.");
                payButton.disabled = false;
                return;
            }

            await widgets.requestPayment({
                orderId: tossOrderId,
                orderName: document.getElementById("orderName").value,
                successUrl: window.location.origin + ctx + "/order/success",
                failUrl: window.location.origin + ctx + "/order/fail",
                customerName: form.receiverName.value,
                customerMobilePhone: form.receiverPhone.value.replace(/[^0-9]/g, ""),
            });
        } catch (e) {
            // 사용자가 결제창을 닫는 등 취소 시
            payButton.disabled = false;
        }
    });
</script>
</body>
</html>
