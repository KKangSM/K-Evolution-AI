<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>결제 실패 — K-Evolution</title>
    <%@ include file="/WEB-INF/views/layout/meta.jsp" %>
    <c:set var="ctx" value="${pageContext.request.contextPath}" />
</head>
<body class="bg-light theme-popart">

<%@ include file="/WEB-INF/views/layout/header.jsp" %>

<div class="container py-5" style="max-width: 560px;">
    <div class="card shadow-sm text-center">
        <div class="card-body p-5">
            <div class="mb-3">
                <i class="bi bi-x-circle-fill text-danger" style="font-size: 3.5rem;"></i>
            </div>
            <h4 class="fw-bold mb-2">결제에 실패했습니다</h4>
            <p class="text-muted mb-1"><c:out value="${message}"/></p>
            <c:if test="${not empty code}">
                <p class="text-muted small mb-4">오류코드: <c:out value="${code}"/></p>
            </c:if>

            <div class="d-grid gap-2 mt-4">
                <a href="${ctx}/cart" class="btn btn-dark">장바구니로 돌아가기</a>
                <a href="${ctx}/products" class="btn btn-outline-secondary">쇼핑 계속하기</a>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
