<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>로그인 - K-Evolution</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
    <style>
        body { min-height: 100vh; display: flex; align-items: center; justify-content: center; }
        .login-wrap { width: 100%; max-width: 400px; }
        .login-logo {
            display: inline-block;
            font-weight: 800; letter-spacing: -1px; font-size: 4rem;
            color: #0f3460; text-decoration: none;
        }
        .login-logo:hover { color: #16213e; }
    </style>
</head>
<body class="bg-light">

<div class="login-wrap px-3">

    <!-- 로고 -->
    <div class="text-center mb-4">
        <a href="${pageContext.request.contextPath}/" class="login-logo">K-Evolution</a>
        <p class="text-muted small mt-1 mb-0">당신의 일상을 진화시키는 셀렉트 쇼핑</p>
    </div>

    <!-- 로그인 카드 -->
    <div class="card shadow-sm">
        <div class="card-body p-4">
            <h5 class="text-center fw-bold mb-4">로그인</h5>

            <c:if test="${param.error != null}">
                <div class="alert alert-danger py-2 small">아이디 또는 비밀번호가 올바르지 않습니다.</div>
            </c:if>
            <c:if test="${param.logout != null}">
                <div class="alert alert-success py-2 small">로그아웃되었습니다.</div>
            </c:if>

            <form action="${pageContext.request.contextPath}/auth/login" method="post">
                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>

                <div class="mb-3">
                    <label class="form-label small text-muted">아이디</label>
                    <input type="text" name="id" class="form-control" required autofocus>
                </div>
                <div class="mb-3">
                    <label class="form-label small text-muted">비밀번호</label>
                    <input type="password" name="password" class="form-control" required>
                </div>

                <button type="submit" class="btn btn-dark w-100">로그인</button>
            </form>

            <p class="text-center text-muted small mt-3 mb-0">
                계정이 없으신가요?
                <a href="${pageContext.request.contextPath}/auth/signup" class="text-decoration-none">회원가입</a>
            </p>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
