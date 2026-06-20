<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>내 정보 수정 - K-Evolution</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
</head>
<body class="bg-light">
<%@ include file="/WEB-INF/views/fragments/header.jsp" %>

<div class="container py-5" style="max-width:560px">
    <a href="${pageContext.request.contextPath}/mypage" class="text-muted small text-decoration-none">← 마이페이지</a>
    <h5 class="fw-bold mt-2 mb-4">내 정보 수정</h5>

    <!-- 기본 정보 수정 -->
    <div class="card shadow-sm mb-4">
        <div class="card-header fw-bold">기본 정보</div>
        <div class="card-body">
            <c:if test="${not empty successMsg}">
                <div class="alert alert-success py-2 small">${successMsg}</div>
            </c:if>
            <form action="${pageContext.request.contextPath}/mypage/edit" method="post">
                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                <div class="mb-3">
                    <label class="form-label small text-muted">아이디</label>
                    <input type="text" class="form-control" value="${member.userId}" disabled>
                </div>
                <div class="mb-3">
                    <label class="form-label small text-muted">이름</label>
                    <input type="text" name="name" class="form-control" value="${member.name}" required>
                </div>
                <div class="mb-3">
                    <label class="form-label small text-muted">전화번호</label>
                    <input type="text" name="phone" class="form-control"
                           value="${member.phone}" placeholder="010-0000-0000">
                </div>
                <button type="submit" class="btn btn-dark btn-sm">수정 완료</button>
            </form>
        </div>
    </div>

    <!-- 비밀번호 변경 -->
    <div class="card shadow-sm">
        <div class="card-header fw-bold">비밀번호 변경</div>
        <div class="card-body">
            <c:if test="${not empty pwSuccessMsg}">
                <div class="alert alert-success py-2 small">${pwSuccessMsg}</div>
            </c:if>
            <c:if test="${not empty pwErrorMsg}">
                <div class="alert alert-danger py-2 small">${pwErrorMsg}</div>
            </c:if>
            <form action="${pageContext.request.contextPath}/mypage/change-password" method="post">
                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                <div class="mb-3">
                    <label class="form-label small text-muted">현재 비밀번호</label>
                    <input type="password" name="currentPassword" class="form-control" required>
                </div>
                <div class="mb-3">
                    <label class="form-label small text-muted">새 비밀번호</label>
                    <input type="password" name="newPassword" class="form-control" minlength="8" required>
                </div>
                <button type="submit" class="btn btn-dark btn-sm">비밀번호 변경</button>
            </form>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
