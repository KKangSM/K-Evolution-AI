<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>${notice.title} - K-Evolution</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
</head>
<body class="bg-light">
<%@ include file="/WEB-INF/views/fragments/header.jsp" %>

<div class="container py-5" style="max-width:720px">
    <a href="${pageContext.request.contextPath}/support/notices" class="text-muted small text-decoration-none">← 공지사항 목록</a>

    <div class="card shadow-sm mt-3">
        <div class="card-header">
            <c:if test="${notice.pinned}">
                <span class="badge bg-danger me-1">공지</span>
            </c:if>
            <span class="fw-bold">${notice.title}</span>
        </div>
        <div class="card-body">
            <div class="text-muted small mb-3">
                등록일: ${notice.createdAt.toString().substring(0, 10)} &nbsp;|&nbsp; 조회수: ${notice.viewCount}
            </div>
            <div style="white-space: pre-wrap;">${notice.content}</div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
