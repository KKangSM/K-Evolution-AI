<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>이벤트 - K-Evolution</title>
    <%@ include file="/WEB-INF/views/layout/meta.jsp" %>
</head>
<body class="bg-light">
<%@ include file="/WEB-INF/views/layout/header.jsp" %>

<div class="container py-5">
    <h4 class="fw-bold mb-4">이벤트</h4>

    <c:choose>
        <c:when test="${empty events}">
            <div class="card shadow-sm">
                <div class="card-body text-center text-muted py-5">
                    <i class="bi bi-megaphone fs-2 d-block mb-2 opacity-50"></i>
                    진행 중인 이벤트가 없습니다.
                </div>
            </div>
        </c:when>
        <c:otherwise>
            <div class="row g-4">
                <c:forEach var="e" items="${events}">
                    <div class="col-md-6 col-lg-4">
                        <a href="${pageContext.request.contextPath}/events/${e.eventId}" class="text-decoration-none">
                            <div class="card shadow-sm h-100">
                                <c:if test="${not empty e.imageUrl}">
                                    <img src="${e.imageUrl}" class="card-img-top"
                                         style="height:180px; object-fit:cover;" alt="이벤트 이미지">
                                </c:if>
                                <div class="card-body">
                                    <h6 class="fw-bold text-dark mb-1"><c:out value="${e.title}"/></h6>
                                    <p class="small text-muted mb-0">
                                        <c:choose>
                                            <c:when test="${empty e.startAt and empty e.endAt}">상시 진행</c:when>
                                            <c:otherwise>
                                                ${empty e.startAt ? '' : e.startAt.toString().substring(0,10)}
                                                ~
                                                ${empty e.endAt ? '' : e.endAt.toString().substring(0,10)}
                                            </c:otherwise>
                                        </c:choose>
                                    </p>
                                </div>
                            </div>
                        </a>
                    </div>
                </c:forEach>
            </div>
        </c:otherwise>
    </c:choose>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
