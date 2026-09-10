<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title><c:out value="${event.title}"/> - K-Evolution</title>
    <%@ include file="/WEB-INF/views/layout/meta.jsp" %>
</head>
<body class="bg-light theme-popart">
<%@ include file="/WEB-INF/views/layout/header.jsp" %>

<div class="container py-5" style="max-width:860px">
    <a href="${pageContext.request.contextPath}/events" class="back-link"><i class="bi bi-chevron-left"></i>이벤트</a>

    <div class="mt-2 mb-3">
        <h4 class="fw-bold mb-1"><c:out value="${event.title}"/></h4>
        <p class="text-muted small mb-0">
            <c:choose>
                <c:when test="${empty event.startAt and empty event.endAt}">상시 진행</c:when>
                <c:otherwise>
                    ${empty event.startAt ? '' : event.startAt.toString().substring(0,16).replace('T',' ')}
                    ~
                    ${empty event.endAt ? '' : event.endAt.toString().substring(0,16).replace('T',' ')}
                </c:otherwise>
            </c:choose>
            &nbsp;|&nbsp; 조회 ${event.viewCount}
        </p>
    </div>

    <div class="card shadow-sm">
        <c:if test="${not empty event.imageUrl}">
            <img src="${event.imageUrl}" class="card-img-top" alt="이벤트 이미지">
        </c:if>
        <div class="card-body">
            <p style="white-space: pre-wrap;" class="mb-0"><c:out value="${event.content}"/></p>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
