<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>반품·교환 내역 - K-Evolution</title>
    <%@ include file="/WEB-INF/views/layout/meta.jsp" %>
</head>
<body class="bg-light theme-popart">
<%@ include file="/WEB-INF/views/layout/header.jsp" %>

<div class="container py-5" style="max-width:720px">
    <a href="${pageContext.request.contextPath}/mypage" class="back-link"><i class="bi bi-chevron-left"></i>마이페이지</a>
    <h5 class="fw-bold mt-2 mb-4">반품·교환 내역</h5>

    <%@ include file="/WEB-INF/views/layout/flash-toast.jsp" %>

    <c:forEach var="r" items="${returns}">
        <div class="card shadow-sm mb-3">
            <div class="card-body">
                <div class="d-flex justify-content-between align-items-start">
                    <div>
                        <span class="badge ${r.type == 'RETURN' ? 'bg-dark' : 'bg-info text-dark'}">
                            ${r.type == 'RETURN' ? '반품' : '교환'}
                        </span>
                        <span class="fw-semibold ms-1">${r.orderItem.productName}</span>
                        <div class="text-muted small mt-1">${r.reason}</div>
                        <div class="text-muted small">신청일 ${r.createdAt}</div>
                    </div>
                    <c:choose>
                        <c:when test="${r.status == 'REQUESTED'}"><span class="badge bg-secondary">접수</span></c:when>
                        <c:when test="${r.status == 'APPROVED'}"><span class="badge bg-primary">승인</span></c:when>
                        <c:when test="${r.status == 'REJECTED'}"><span class="badge bg-danger">거절</span></c:when>
                        <c:otherwise><span class="badge bg-success">완료</span></c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>
    </c:forEach>

    <c:if test="${empty returns}">
        <div class="text-center text-muted py-5">
            <i class="bi bi-arrow-return-left" style="font-size:2rem"></i>
            <div class="mt-2">반품·교환 신청 내역이 없습니다.</div>
            <a href="${pageContext.request.contextPath}/orders" class="btn btn-dark btn-sm mt-3">주문 내역 보기</a>
        </div>
    </c:if>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
