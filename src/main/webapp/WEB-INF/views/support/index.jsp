<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>고객센터 - K-Evolution</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
</head>
<body class="bg-light">
<%@ include file="/WEB-INF/views/fragments/header.jsp" %>

<div class="container py-5" style="max-width:720px">
    <h4 class="fw-bold mb-1">고객센터</h4>
    <p class="text-muted small mb-4">운영시간: 평일 09:00 ~ 18:00 (주말/공휴일 휴무)</p>

    <div class="row g-3 mb-5">
        <div class="col-4">
            <a href="${pageContext.request.contextPath}/support/notices" class="text-decoration-none">
                <div class="card shadow-sm text-center py-4 h-100">
                    <div class="fs-2 mb-2">📢</div>
                    <div class="fw-bold">공지사항</div>
                </div>
            </a>
        </div>
        <div class="col-4">
            <sec:authorize access="isAuthenticated()">
                <a href="${pageContext.request.contextPath}/support/qna" class="text-decoration-none">
            </sec:authorize>
            <sec:authorize access="isAnonymous()">
                <a href="${pageContext.request.contextPath}/auth/login" class="text-decoration-none">
            </sec:authorize>
                <div class="card shadow-sm text-center py-4 h-100">
                    <div class="fs-2 mb-2">💬</div>
                    <div class="fw-bold">1:1 문의</div>
                </div>
            </a>
        </div>
        <div class="col-4">
            <div class="card shadow-sm text-center py-4 h-100">
                <div class="fs-2 mb-2">📞</div>
                <div class="fw-bold">전화 문의</div>
                <div class="text-muted small mt-1">02-0000-0000</div>
            </div>
        </div>
    </div>

    <!-- 최근 공지사항 -->
    <h6 class="fw-bold mb-3">최근 공지사항</h6>
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
                <div class="list-group-item text-center text-muted py-3">공지사항이 없습니다.</div>
            </c:if>
        </div>
    </div>
    <div class="text-end mt-2">
        <a href="${pageContext.request.contextPath}/support/notices" class="text-muted small">전체 보기 →</a>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
