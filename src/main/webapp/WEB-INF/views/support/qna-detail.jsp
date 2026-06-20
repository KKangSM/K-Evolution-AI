<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>문의 상세 - K-Evolution</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
</head>
<body class="bg-light">
<%@ include file="/WEB-INF/views/fragments/header.jsp" %>

<div class="container py-5" style="max-width:720px">
    <a href="${pageContext.request.contextPath}/support/qna" class="text-muted small text-decoration-none">← 1:1 문의 목록</a>

    <c:if test="${not empty errorMsg}">
        <div class="alert alert-danger mt-3">${errorMsg}</div>
    </c:if>

    <c:if test="${not empty qna}">
        <!-- 문의 내용 -->
        <div class="card shadow-sm mt-3 mb-3">
            <div class="card-header d-flex justify-content-between">
                <span class="fw-bold">${qna.title}</span>
                <c:choose>
                    <c:when test="${qna.answered}">
                        <span class="badge bg-success">답변완료</span>
                    </c:when>
                    <c:otherwise>
                        <span class="badge bg-warning text-dark">미답변</span>
                    </c:otherwise>
                </c:choose>
            </div>
            <div class="card-body">
                <div class="text-muted small mb-3">
                    작성일: ${qna.createdAt.toString().substring(0, 16).replace('T', ' ')}
                </div>
                <p style="white-space: pre-wrap;">${qna.content}</p>
            </div>
        </div>

        <!-- 답변 -->
        <c:if test="${qna.answered}">
            <div class="card shadow-sm border-success">
                <div class="card-header bg-success bg-opacity-10 fw-bold text-success">
                    답변
                </div>
                <div class="card-body">
                    <div class="text-muted small mb-2">
                        답변일: ${qna.answeredAt.toString().substring(0, 16).replace('T', ' ')}
                    </div>
                    <p style="white-space: pre-wrap;">${qna.answer}</p>
                </div>
            </div>
        </c:if>

        <c:if test="${!qna.answered}">
            <div class="card shadow-sm border-secondary mt-3">
                <div class="card-body text-muted text-center py-4">
                    아직 답변이 등록되지 않았습니다. 영업일 기준 1~2일 내에 답변드립니다.
                </div>
            </div>
        </c:if>
    </c:if>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
