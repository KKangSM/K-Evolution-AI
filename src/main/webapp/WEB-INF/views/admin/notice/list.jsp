<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>공지 관리 · K-Evolution 관리자</title>
    <%@ include file="/WEB-INF/views/fragments/head.jsp" %>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin.css">
</head>
<body class="admin-body">

<%@ include file="/WEB-INF/views/fragments/admin-topbar.jsp" %>

<div class="admin-layout">
    <%@ include file="/WEB-INF/views/fragments/admin-sidebar.jsp" %>

    <main class="admin-main">

        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h4 class="page-title mb-1">공지 관리</h4>
                <p class="text-muted small mb-0">행을 클릭하면 상세 내용과 수정 창이 열립니다.</p>
            </div>
            <button type="button" class="btn btn-dark btn-sm px-3"
                    data-bs-toggle="modal" data-bs-target="#writeModal">
                <i class="bi bi-pencil-square"></i> 공지 작성
            </button>
        </div>

        <%@ include file="/WEB-INF/views/fragments/flash-toast.jsp" %>

        <div class="card shadow-sm">
            <div class="card-body p-0">
                <table class="table table-hover mb-0 align-middle">
                    <thead class="table-light">
                    <tr>
                        <th class="ps-4" style="width:60px">No</th>
                        <th>제목</th>
                        <th style="width:70px">고정</th>
                        <th style="width:70px">마퀴</th>
                        <th style="width:80px">조회수</th>
                        <th style="width:110px">작성일</th>
                        <th style="width:110px">수정일</th>
                    </tr>
                    </thead>
                    <tbody>
                    <c:forEach var="n" items="${notices.content}">
                        <tr style="cursor:pointer"
                            data-bs-toggle="modal" data-bs-target="#noticeModal${n.noticeId}">
                            <td class="ps-4 text-muted small">${n.noticeId}</td>
                            <td class="fw-medium text-dark">
                                <c:if test="${n.pinned}">
                                    <span class="badge bg-danger me-1">고정</span>
                                </c:if>
                                <c:out value="${n.title}"/>
                            </td>
                            <td>
                                <c:choose>
                                    <c:when test="${n.pinned}">
                                        <span class="badge bg-danger">고정</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="text-muted small">—</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td>
                                <c:choose>
                                    <c:when test="${n.marquee}">
                                        <span class="badge bg-primary">마퀴</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="text-muted small">—</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td class="small text-muted">${n.viewCount}</td>
                            <td class="small text-muted">${n.createdAt.toString().substring(0, 10)}</td>
                            <td class="pe-4 small text-muted">${n.updatedAt.toString().substring(0, 10)}</td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty notices.content}">
                        <tr>
                            <td colspan="6" class="text-center text-muted py-4">등록된 공지사항이 없습니다.</td>
                        </tr>
                    </c:if>
                    </tbody>
                </table>
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

    </main>
</div>

<%-- 공지 작성 모달 --%>
<div class="modal fade" id="writeModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-centered modal-dialog-scrollable">
        <div class="modal-content">
            <form action="${pageContext.request.contextPath}/admin/notice/write" method="post">
                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                <div class="modal-header">
                    <h6 class="modal-title fw-bold">공지사항 작성</h6>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="닫기"></button>
                </div>
                <div class="modal-body">
                    <div class="mb-3">
                        <label class="form-label small text-muted">제목</label>
                        <input type="text" name="title" class="form-control" required maxlength="200"
                               placeholder="제목을 입력하세요">
                    </div>
                    <div class="mb-3">
                        <label class="form-label small text-muted">내용</label>
                        <textarea name="content" class="form-control" rows="10" required
                                  placeholder="내용을 입력하세요"></textarea>
                    </div>
                    <div class="d-flex gap-4">
                        <div class="form-check">
                            <input class="form-check-input" type="checkbox" name="pinned" value="true" id="writePinned">
                            <label class="form-check-label small" for="writePinned">상단 고정</label>
                        </div>
                        <div class="form-check">
                            <input class="form-check-input" type="checkbox" name="marquee" value="true" id="writeMarquee">
                            <label class="form-check-label small" for="writeMarquee">메인 마퀴 표시</label>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-outline-secondary btn-sm" data-bs-dismiss="modal">취소</button>
                    <button type="submit" class="btn btn-dark btn-sm px-3">등록</button>
                </div>
            </form>
        </div>
    </div>
</div>

<%-- 공지별 상세/수정 모달 --%>
<c:forEach var="n" items="${notices.content}">
    <div class="modal fade" id="noticeModal${n.noticeId}" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-lg modal-dialog-centered modal-dialog-scrollable">
            <div class="modal-content">
                <div class="modal-header">
                    <h6 class="modal-title fw-bold">
                        <c:if test="${n.pinned}"><span class="badge bg-danger me-1">고정</span></c:if>
                        <c:out value="${n.title}"/>
                    </h6>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="닫기"></button>
                </div>
                <div class="modal-body">
                    <div class="text-muted small mb-3">
                        작성일: ${n.createdAt.toString().substring(0, 16).replace('T', ' ')}
                        &nbsp;|&nbsp; 수정일: ${n.updatedAt.toString().substring(0, 16).replace('T', ' ')}
                        &nbsp;|&nbsp; 조회수: ${n.viewCount}
                    </div>

                    <%-- 수정 폼 --%>
                    <form action="${pageContext.request.contextPath}/admin/notice/${n.noticeId}/edit" method="post">
                        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                        <div class="mb-3">
                            <label class="form-label small text-muted">제목</label>
                            <input type="text" name="title" class="form-control" required maxlength="200"
                                   value="<c:out value='${n.title}'/>">
                        </div>
                        <div class="mb-3">
                            <label class="form-label small text-muted">내용</label>
                            <textarea name="content" class="form-control" rows="10" required><c:out value="${n.content}"/></textarea>
                        </div>
                        <div class="d-flex gap-4 mb-3">
                            <div class="form-check">
                                <input class="form-check-input" type="checkbox" name="pinned" value="true"
                                       id="pinned${n.noticeId}" ${n.pinned ? 'checked' : ''}>
                                <label class="form-check-label small" for="pinned${n.noticeId}">상단 고정</label>
                            </div>
                            <div class="form-check">
                                <input class="form-check-input" type="checkbox" name="marquee" value="true"
                                       id="marquee${n.noticeId}" ${n.marquee ? 'checked' : ''}>
                                <label class="form-check-label small" for="marquee${n.noticeId}">메인 마퀴 표시</label>
                            </div>
                        </div>
                        <div class="d-flex justify-content-between">
                            <button type="button" class="btn btn-outline-danger btn-sm"
                                    onclick="submitDelete(${n.noticeId})">삭제</button>
                            <div class="d-flex gap-2">
                                <button type="button" class="btn btn-outline-secondary btn-sm"
                                        data-bs-dismiss="modal">닫기</button>
                                <button type="submit" class="btn btn-dark btn-sm px-3">수정 완료</button>
                            </div>
                        </div>
                    </form>
                    <%-- 삭제 폼 (form 중첩 방지용 분리) --%>
                    <form id="deleteForm${n.noticeId}"
                          action="${pageContext.request.contextPath}/admin/notice/${n.noticeId}/delete"
                          method="post" style="display:none">
                        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                    </form>
                </div>
            </div>
        </div>
    </div>
</c:forEach>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    function submitDelete(noticeId) {
        if (confirm('공지사항을 삭제하시겠습니까?')) {
            document.getElementById('deleteForm' + noticeId).submit();
        }
    }
</script>
</body>
</html>
