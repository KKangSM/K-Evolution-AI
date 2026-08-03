<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="ui" tagdir="/WEB-INF/tags" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>적립금 - K-Evolution</title>
    <%@ include file="/WEB-INF/views/layout/meta.jsp" %>
</head>
<body class="bg-light">
<%@ include file="/WEB-INF/views/layout/header.jsp" %>

<div class="container py-5" style="max-width:720px">
    <a href="${pageContext.request.contextPath}/mypage" class="back-link"><i class="bi bi-chevron-left"></i>마이페이지</a>
    <h5 class="fw-bold mt-2 mb-4">적립금</h5>

    <%-- 잔액 카드 --%>
    <div class="card shadow-sm mb-4">
        <div class="card-body text-center py-4">
            <div class="text-muted small mb-1">사용 가능 적립금</div>
            <div class="fw-bold" style="font-size:2rem">
                <fmt:formatNumber value="${balance}" type="number" groupingUsed="true"/><span class="fs-5 ms-1">P</span>
            </div>
        </div>
    </div>

    <%-- 적립/사용 내역 --%>
    <c:forEach var="h" items="${histories.content}">
        <div class="card shadow-sm mb-2">
            <div class="card-body py-3">
                <div class="d-flex justify-content-between align-items-start">
                    <div>
                        <c:choose>
                            <c:when test="${h.type == 'EARN'}"><span class="badge bg-dark">적립</span></c:when>
                            <c:when test="${h.type == 'USE'}"><span class="badge bg-secondary">사용</span></c:when>
                            <c:when test="${h.type == 'CANCEL'}"><span class="badge bg-info text-dark">취소복원</span></c:when>
                            <c:otherwise><span class="badge bg-light text-muted border">만료</span></c:otherwise>
                        </c:choose>
                        <span class="fw-semibold ms-1">${h.description}</span>
                        <div class="text-muted small mt-1">
                            ${fn:substring(h.createdAt, 0, 10)} ${fn:substring(h.createdAt, 11, 16)}
                        </div>
                    </div>
                    <div class="text-end">
                        <div class="fw-bold ${h.amount > 0 ? 'text-danger' : 'text-primary'}">
                            <c:if test="${h.amount > 0}">+</c:if><fmt:formatNumber value="${h.amount}" type="number" groupingUsed="true"/>P
                        </div>
                        <div class="text-muted small">잔액 <fmt:formatNumber value="${h.balance}" type="number" groupingUsed="true"/>P</div>
                    </div>
                </div>
            </div>
        </div>
    </c:forEach>

    <ui:pagination page="${histories}"/>

    <c:if test="${empty histories.content}">
        <div class="text-center text-muted py-5">
            <i class="bi bi-coin" style="font-size:2rem"></i>
            <div class="mt-2">적립금 내역이 없습니다.</div>
            <a href="${pageContext.request.contextPath}/products" class="btn btn-dark btn-sm mt-3">쇼핑하러 가기</a>
        </div>
    </c:if>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
