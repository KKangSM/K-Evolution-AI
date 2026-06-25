<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>공지 관리 · K-Evolution 관리자</title>
    <%@ include file="/WEB-INF/views/layout/meta.jsp" %>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin.css">
</head>
<body class="admin-body">

<%@ include file="/WEB-INF/views/layout/admin-topbar.jsp" %>

<div class="admin-layout">
    <%@ include file="/WEB-INF/views/layout/admin-sidebar.jsp" %>

    <main class="admin-main">

        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h4 class="page-title mb-1">공지 관리</h4>
            </div>
            <button type="button" class="btn btn-dark btn-sm px-3"
                    data-bs-toggle="modal" data-bs-target="#writeModal">
                <i class="bi bi-pencil-square"></i> 공지 작성
            </button>
        </div>

        <%@ include file="/WEB-INF/views/layout/flash-toast.jsp" %>

        <div class="card shadow-sm">
            <div class="card-body p-0">
                <table class="table table-hover mb-0 align-middle">
                    <thead class="table-light">
                    <tr>
                        <th class="ps-4" style="width:70px">번호</th>
                        <th>제목</th>
                        <th style="width:80px">조회수</th>
                        <th style="width:110px">작성일</th>
                        <th style="width:110px">수정일</th>
                    </tr>
                    </thead>
                    <tbody>
                    <c:forEach var="n" items="${notices.content}" varStatus="status">
                        <tr style="cursor:pointer"
                            data-bs-toggle="modal" data-bs-target="#noticeModal${n.noticeId}">
                            <td class="ps-4 text-muted small">${notices.totalElements - (notices.number * notices.size + status.index)}</td>
                            <td class="fw-medium text-dark">
                                <c:out value="${n.title}"/>
                            </td>
                            <td class="small text-muted">${n.viewCount}</td>
                            <td class="small text-muted">${n.createdAt.toString().substring(0, 10)}</td>
                            <td class="pe-4 small text-muted">${n.updatedAt.toString().substring(0, 10)}</td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty notices.content}">
                        <tr>
                            <td colspan="5" class="text-center text-muted py-4">등록된 공지사항이 없습니다.</td>
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
            <form action="${pageContext.request.contextPath}/admin/notice/write"
                  method="post" enctype="multipart/form-data">
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
                    <div class="mb-3">
                        <label class="form-label small text-muted">이미지 (선택)</label>
                        <input type="file" name="imageFile" class="form-control" accept="image/*">
                        <div class="form-text">공지 본문 상단에 표시됩니다. (최대 10MB)</div>
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
                    <form action="${pageContext.request.contextPath}/admin/notice/${n.noticeId}/edit"
                          method="post" enctype="multipart/form-data">
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
                        <div class="mb-3">
                            <label class="form-label small text-muted">이미지 (선택)</label>
                            <c:if test="${not empty n.imageUrl}">
                                <div class="mb-2">
                                    <img src="${n.imageUrl}" alt="현재 이미지"
                                         style="max-height:120px; border-radius:6px; border:1px solid #dee2e6;">
                                </div>
                            </c:if>
                            <input type="file" name="imageFile" class="form-control" accept="image/*">
                            <div class="form-text">새 파일을 선택하면 교체됩니다. (비워두면 기존 이미지 유지)</div>
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
