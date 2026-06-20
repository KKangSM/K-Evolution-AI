<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>회원 탈퇴 - K-Evolution</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
</head>
<body class="bg-light">
<%@ include file="/WEB-INF/views/fragments/header.jsp" %>

<div class="container py-5" style="max-width:480px">
    <a href="${pageContext.request.contextPath}/mypage" class="text-muted small text-decoration-none">← 마이페이지</a>
    <h5 class="fw-bold mt-2 mb-4">회원 탈퇴</h5>

    <div class="alert alert-warning small">
        탈퇴 시 계정 정보 및 개인정보는 즉시 비활성화되며 복구할 수 없습니다.
    </div>

    <c:if test="${not empty errorMsg}">
        <div class="alert alert-danger py-2 small">${errorMsg}</div>
    </c:if>

    <div class="card shadow-sm">
        <div class="card-body">
            <form action="${pageContext.request.contextPath}/mypage/withdraw" method="post"
                  onsubmit="return confirm('정말 탈퇴하시겠습니까? 이 작업은 되돌릴 수 없습니다.')">
                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                <div class="mb-3">
                    <label class="form-label small text-muted">비밀번호 확인</label>
                    <input type="password" name="password" class="form-control"
                           placeholder="현재 비밀번호 입력" required>
                </div>
                <button type="submit" class="btn btn-danger w-100">탈퇴하기</button>
            </form>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
