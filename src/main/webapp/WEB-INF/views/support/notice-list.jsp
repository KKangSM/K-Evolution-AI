<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>공지사항 - K-Evolution</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
</head>
<body class="bg-light">
<%@ include file="/WEB-INF/views/fragments/header.jsp" %>

<div class="container py-5" style="max-width:720px">
    <a href="${pageContext.request.contextPath}/support" class="text-muted small text-decoration-none">← 고객센터</a>
    <h5 class="fw-bold mt-2 mb-4">공지사항</h5>

    <div class="card shadow-sm">
        <div class="list-group list-group-flush">
            <c:forEach var="n" items="${notices.content}">
                <a href="${pageContext.request.contextPath}/support/notices/${n.noticeId}"
                   class="list-group-item list-group-item-action d-flex justify-content-between align-items-center">
                    <span>
                        <c:if test="${n.pinned}">
                            <span class="badge bg-danger me-1">공지</span>
                        </c:if>
                        ${n.title}
                    </span>
                    <span class="text-muted small">${n.createdAt.toString().substring(0, 10)}</span>
                </a>
            </c:forEach>
            <c:if test="${empty notices.content}">
                <div class="list-group-item text-center text-muted py-4">공지사항이 없습니다.</div>
            </c:if>
        </div>
    </div>

    <nav class="mt-3">
        <ul class="pagination justify-content-center">
            <c:forEach begin="0" end="${notices.totalPages - 1}" var="i">
                <li class="page-item ${notices.number == i ? 'active' : ''}">
                    <a class="page-link" href="?page=${i}">${i + 1}</a>
                </li>
            </c:forEach>
        </ul>
    </nav>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
