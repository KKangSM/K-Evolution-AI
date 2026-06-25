<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>고객센터 - K-Evolution</title>
    <meta name="_csrf" content="${_csrf.token}">
    <meta name="_csrf_header" content="${_csrf.headerName}">
    <%@ include file="/WEB-INF/views/layout/meta.jsp" %>
</head>
<body class="bg-light">
<%@ include file="/WEB-INF/views/layout/header.jsp" %>

<div class="container py-5" style="max-width:720px">
    <h4 class="fw-bold mb-1">고객센터</h4>
    <p class="text-muted small mb-4">운영시간: 평일 09:00 ~ 18:00 (주말/공휴일 휴무)</p>

    <div class="row g-3 mb-5">
        <div class="col-6">
            <a href="${pageContext.request.contextPath}/support/notices" class="text-decoration-none">
                <div class="card shadow-sm text-center py-4 h-100">
                    <div class="fs-2 mb-2">📢</div>
                    <div class="fw-bold">공지사항</div>
                </div>
            </a>
        </div>
        <div class="col-6">
            <sec:authorize access="isAuthenticated()">
                <c:set var="qnaUrl" value="${pageContext.request.contextPath}/support/qna"/>
            </sec:authorize>
            <sec:authorize access="isAnonymous()">
                <c:set var="qnaUrl" value="${pageContext.request.contextPath}/auth/login"/>
            </sec:authorize>
            <a href="${qnaUrl}" class="text-decoration-none">
                <div class="card shadow-sm text-center py-4 h-100">
                    <div class="fs-2 mb-2">💬</div>
                    <div class="fw-bold">1:1 문의</div>
                </div>
            </a>
        </div>
    </div>

    <!-- 최근 공지사항 -->
    <div class="d-flex justify-content-between align-items-center mb-3">
        <h6 class="fw-bold mb-0">최근 공지사항</h6>
        <a href="${pageContext.request.contextPath}/support/notices" class="back-link">더보기 <i class="bi bi-chevron-right"></i></a>
    </div>
    <div class="card shadow-sm">
        <div class="list-group list-group-flush">
            <c:forEach var="n" items="${notices.content}">
                <button type="button"
                        data-bs-toggle="modal" data-bs-target="#noticeModal${n.noticeId}"
                        class="list-group-item list-group-item-action d-flex justify-content-between align-items-center text-start">
                    <span><c:out value="${n.title}"/></span>
                    <span class="text-muted small">${n.createdAt.toString().substring(0, 10)}</span>
                </button>
            </c:forEach>
            <c:if test="${empty notices.content}">
                <div class="list-group-item text-center text-muted py-3">공지사항이 없습니다.</div>
            </c:if>
        </div>
    </div>
</div>

<%-- 공지별 상세 모달 --%>
<c:forEach var="n" items="${notices.content}">
    <div class="modal fade" id="noticeModal${n.noticeId}" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered modal-dialog-scrollable notice-view-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h6 class="modal-title fw-bold">
                        <c:out value="${n.title}"/>
                    </h6>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="닫기"></button>
                </div>
                <div class="modal-body notice-view-body">
                    <div class="text-muted small mb-3">
                        등록일: ${n.createdAt.toString().substring(0, 10)}
                        &nbsp;|&nbsp; 조회수: <span class="notice-view-count">${n.viewCount}</span>
                    </div>
                    <c:if test="${not empty n.imageUrl}">
                        <img src="${n.imageUrl}" alt="공지 이미지" class="notice-view-img mb-3">
                    </c:if>
                    <div style="white-space: pre-wrap;">${n.content}</div>
                </div>
            </div>
        </div>
    </div>
</c:forEach>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    // 공지 모달을 처음 열 때 1회 조회수 증가
    (function () {
        var ctx = '${pageContext.request.contextPath}';
        var tokenMeta = document.querySelector('meta[name="_csrf"]');
        var headerMeta = document.querySelector('meta[name="_csrf_header"]');
        document.querySelectorAll('[id^="noticeModal"]').forEach(function (modal) {
            modal.addEventListener('show.bs.modal', function () {
                if (modal.dataset.viewed === 'true') return;
                modal.dataset.viewed = 'true';
                var id = modal.id.replace('noticeModal', '');
                var headers = {};
                if (tokenMeta && headerMeta) headers[headerMeta.content] = tokenMeta.content;
                fetch(ctx + '/support/notices/' + id + '/view', { method: 'POST', headers: headers });
                var countEl = modal.querySelector('.notice-view-count');
                if (countEl) {
                    var cur = parseInt(countEl.textContent, 10);
                    if (!isNaN(cur)) countEl.textContent = cur + 1;
                }
            });
        });
    })();
</script>
</body>
</html>
