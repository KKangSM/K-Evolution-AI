<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>문의 작성 - K-Evolution</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
</head>
<body class="bg-light">
<%@ include file="/WEB-INF/views/fragments/header.jsp" %>

<div class="container py-5" style="max-width:640px">
    <a href="${pageContext.request.contextPath}/support/qna" class="text-muted small text-decoration-none">← 1:1 문의 목록</a>
    <h5 class="fw-bold mt-2 mb-4">문의 작성</h5>

    <div class="card shadow-sm">
        <div class="card-body">
            <form action="${pageContext.request.contextPath}/support/qna/write" method="post">
                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                <div class="mb-3">
                    <label class="form-label small text-muted">제목</label>
                    <input type="text" name="title" class="form-control" required maxlength="200">
                </div>
                <div class="mb-3">
                    <label class="form-label small text-muted">내용</label>
                    <textarea name="content" class="form-control" rows="8" required></textarea>
                </div>
                <div class="form-check mb-3">
                    <input class="form-check-input" type="checkbox" name="secret"
                           id="chkSecret" value="true">
                    <label class="form-check-label small" for="chkSecret">비밀글로 등록</label>
                </div>
                <div class="d-flex gap-2">
                    <button type="submit" class="btn btn-dark btn-sm">등록</button>
                    <a href="${pageContext.request.contextPath}/support/qna"
                       class="btn btn-outline-secondary btn-sm">취소</a>
                </div>
            </form>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
