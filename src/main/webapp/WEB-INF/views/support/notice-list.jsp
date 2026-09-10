<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>공지사항 - K-Evolution</title>
    <meta name="_csrf" content="${_csrf.token}">
    <meta name="_csrf_header" content="${_csrf.headerName}">
    <%@ include file="/WEB-INF/views/layout/meta.jsp" %>
</head>
<body class="bg-light theme-popart">
<%@ include file="/WEB-INF/views/layout/header.jsp" %>

<div class="container py-5" style="max-width:720px">
    <a href="${pageContext.request.contextPath}/support" class="back-link"><i class="bi bi-chevron-left"></i>고객센터</a>
    <h5 class="fw-bold mt-2 mb-4">공지사항</h5>

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
                <div class="list-group-item text-center text-muted py-4">공지사항이 없습니다.</div>
            </c:if>
        </div>
    </div>

    <c:if test="${notices.totalPages > 1}">
        <nav class="mt-3">
            <ul class="pagination justify-content-center">
                <c:forEach begin="0" end="${notices.totalPages - 1}" var="i">
                    <li class="page-item ${notices.number == i ? 'active' : ''}">
                        <a class="page-link" href="?page=${i}">${i + 1}</a>
                    </li>
                </c:forEach>
            </ul>
        </nav>
    </c:if>
</div>

<%-- 공지별 상세 모달 (상세 페이지 대체) --%>
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
    // 공지 모달을 처음 열 때 1회 조회수 증가 + 화면 숫자 즉시 +1
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
