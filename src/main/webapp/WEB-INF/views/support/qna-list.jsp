<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>1:1 문의 - K-Evolution</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
</head>
<body class="bg-light">
<%@ include file="/WEB-INF/views/fragments/header.jsp" %>

<div class="container py-5" style="max-width:720px">
    <a href="${pageContext.request.contextPath}/support" class="text-muted small text-decoration-none">← 고객센터</a>
    <div class="d-flex justify-content-between align-items-center mt-2 mb-4">
        <h5 class="fw-bold mb-0">1:1 문의</h5>
        <a href="${pageContext.request.contextPath}/support/qna/write" class="btn btn-dark btn-sm">문의 작성</a>
    </div>

    <c:if test="${not empty successMsg}">
        <div class="alert alert-success py-2 small">${successMsg}</div>
    </c:if>

    <div class="card shadow-sm">
        <div class="list-group list-group-flush">
            <c:forEach var="q" items="${qnaList.content}">
                <a href="${pageContext.request.contextPath}/support/qna/${q.qnaId}"
                   class="list-group-item list-group-item-action d-flex justify-content-between align-items-center">
                    <span>
                        <c:if test="${q.secret}">
                            <span class="badge bg-secondary me-1">비밀</span>
                        </c:if>
                        ${q.title}
                    </span>
                    <div class="d-flex align-items-center gap-2">
                        <c:choose>
                            <c:when test="${q.answered}">
                                <span class="badge bg-success">답변완료</span>
                            </c:when>
                            <c:otherwise>
                                <span class="badge bg-warning text-dark">미답변</span>
                            </c:otherwise>
                        </c:choose>
                        <span class="text-muted small">${q.createdAt.toString().substring(0, 10)}</span>
                    </div>
                </a>
            </c:forEach>
            <c:if test="${empty qnaList.content}">
                <div class="list-group-item text-center text-muted py-4">문의 내역이 없습니다.</div>
            </c:if>
        </div>
    </div>

    <c:if test="${qnaList.totalPages > 1}">
        <nav class="mt-3">
            <ul class="pagination justify-content-center">
                <c:forEach begin="0" end="${qnaList.totalPages - 1}" var="i">
                    <li class="page-item ${qnaList.number == i ? 'active' : ''}">
                        <a class="page-link" href="?page=${i}">${i + 1}</a>
                    </li>
                </c:forEach>
            </ul>
        </nav>
    </c:if>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
