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
                    <div class="input-group mb-2">
                        <input type="text" id="zipcode" class="form-control" placeholder="우편번호" maxlength="20">
                        <button type="button" class="btn btn-outline-secondary" id="zipSearchBtn">우편번호 검색</button>
                    </div>
                    <input type="text" id="roadAddress" class="form-control mb-2"
                           value="<c:out value='${order.address}'/>" placeholder="주소" required maxlength="200">
                    <input type="text" id="addressDetail" class="form-control"
                           placeholder="상세주소 (선택)" maxlength="200">
                    <input type="hidden" name="address" id="addressCombined">
                </div>
            </form>
        </div>
    </div>

    <%-- 쿠폰 --%>
    <div class="card shadow-sm mb-3">
        <div class="card-body">
            <h6 class="fw-bold mb-3">쿠폰</h6>
            <c:choose>
                <c:when test="${empty coupons}">
                    <p class="text-muted small mb-0">사용 가능한 쿠폰이 없습니다.</p>
                </c:when>
                <c:otherwise>
                    <select id="couponSelect" class="form-select">
                        <option value="">쿠폰 선택 안 함</option>
                        <c:forEach var="ic" items="${coupons}">
                            <option value="${ic.issuedCouponId}">
                                <c:out value="${ic.coupon.name}"/>
                                (<c:choose>
                                    <c:when test="${ic.coupon.discountType == 'PERCENT'}">${ic.coupon.discountValue}% 할인</c:when>
                                    <c:otherwise><fmt:formatNumber value="${ic.coupon.discountValue}" type="number" groupingUsed="true"/>원 할인</c:otherwise>
                                </c:choose>)
                            </option>
                        </c:forEach>
                    </select>
                </c:otherwise>
            </c:choose>
        </div>
    </div>

    <%-- 금액 --%>
    <div class="card shadow-sm mb-3">
        <div class="card-body">
            <div class="d-flex justify-content-between mb-2">
                <span class="text-muted">상품 합계</span>
                <span><fmt:formatNumber value="${order.totalPrice}" type="number" groupingUsed="true"/>원</span>
            </div>
            <div id="discountRow" class="d-flex justify-content-between mb-2 text-danger ${order.discountAmount > 0 ? '' : 'd-none'}">
                <span>쿠폰 할인</span>
                <span>-<span id="discountValue"><fmt:formatNumber value="${order.discountAmount}" type="number" groupingUsed="true"/></span>원</span>
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
                    <span id="finalPrice"><fmt:formatNumber value="${order.finalPrice}" type="number" groupingUsed="true"/></span>원
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
<script src="//t1.kakaocdn.net/mapjsapi/bundle/postcode/prod/postcode.v2.js"></script>
<script>
    const ctx = "${ctx}";
    const clientKey = "${clientKey}";
    const customerKey = "${customerKey}";
    const tossOrderId = "${order.tossOrderId}";
    const orderId = "${order.orderId}";
    const amount = { currency: "KRW", value: ${order.finalPrice} };
    const csrfHeader = "${_csrf.headerName}";
    const csrfToken = "${_csrf.token}";

    const payButton = document.getElementById("payButton");
    const tossPayments = TossPayments(clientKey);
    const widgets = tossPayments.widgets({ customerKey });

    const nf = new Intl.NumberFormat("ko-KR");

    // 우편번호 검색 (카카오/다음 우편번호 서비스 — 별도 키 불필요)
    const PostcodeService = (window.daum && window.daum.Postcode)
                         || (window.kakao && window.kakao.Postcode);
    document.getElementById("zipSearchBtn").addEventListener("click", () => {
        if (!PostcodeService) { alert("우편번호 서비스를 불러오지 못했습니다. 직접 입력해주세요."); return; }
        new PostcodeService({
            oncomplete: function (data) {
                document.getElementById("zipcode").value = data.zonecode;
                document.getElementById("roadAddress").value = data.roadAddress || data.jibunAddress;
                document.getElementById("addressDetail").focus();
            }
        }).open();
    });

    async function init() {
        await widgets.setAmount(amount);
        await Promise.all([
            widgets.renderPaymentMethods({ selector: "#payment-method", variantKey: "DEFAULT" }),
            widgets.renderAgreement({ selector: "#agreement", variantKey: "DEFAULT" }),
        ]);
        payButton.disabled = false;
    }
    init();

    // 쿠폰 선택 → 서버에서 할인·최종금액 재계산 후 위젯 금액 갱신
    const couponSelect = document.getElementById("couponSelect");
    if (couponSelect) {
        couponSelect.addEventListener("change", async () => {
            const issuedCouponId = couponSelect.value;
            const body = new URLSearchParams();
            if (issuedCouponId) body.append("issuedCouponId", issuedCouponId);

            const resp = await fetch(ctx + "/order/" + orderId + "/coupon", {
                method: "POST",
                headers: {
                    "Content-Type": "application/x-www-form-urlencoded;charset=UTF-8",
                    [csrfHeader]: csrfToken,
                },
                body: body.toString(),
            });
            const data = await resp.json();
            if (!resp.ok) {
                alert(data.message || "쿠폰 적용에 실패했습니다.");
                couponSelect.value = "";
                return;
            }

            // 화면 금액 갱신
            const discount = ${order.totalPrice} + (${shipping}) - data.finalPrice;
            const discountRow = document.getElementById("discountRow");
            if (discount > 0) {
                document.getElementById("discountValue").textContent = nf.format(discount);
                discountRow.classList.remove("d-none");
            } else {
                discountRow.classList.add("d-none");
            }
            document.getElementById("finalPrice").textContent = nf.format(data.finalPrice);

            // 토스 위젯 결제금액 갱신
            amount.value = data.finalPrice;
            await widgets.setAmount(amount);
        });
    }

    payButton.addEventListener("click", async () => {
        const form = document.getElementById("shippingForm");
        if (!form.reportValidity()) return;

        // 우편번호 + 도로명 + 상세주소를 하나의 주소 문자열로 합쳐 저장
        const zip = document.getElementById("zipcode").value.trim();
        const road = document.getElementById("roadAddress").value.trim();
        const detail = document.getElementById("addressDetail").value.trim();
        document.getElementById("addressCombined").value =
            (zip ? "[" + zip + "] " : "") + road + (detail ? " " + detail : "");

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
