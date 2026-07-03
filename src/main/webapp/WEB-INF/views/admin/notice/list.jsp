<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="ui" tagdir="/WEB-INF/tags" %>
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

        <div class="d-flex justify-content-between align-items-center mb-3">
            <div>
                <h4 class="page-title mb-1">공지 관리</h4>
            </div>
            <button type="button" class="btn btn-dark btn-sm px-3"
                    data-bs-toggle="modal" data-bs-target="#writeModal">
                <i class="bi bi-pencil-square"></i> 공지 작성
            </button>
        </div>

        <%@ include file="/WEB-INF/views/layout/flash-toast.jsp" %>

        <!-- 검색 폼 (제목) -->
        <ui:searchForm placeholder="제목 검색"
                       resetUrl="${pageContext.request.contextPath}/admin/notice">
            <%-- 페이지 크기 유지 --%>
            <input type="hidden" name="pageSize" value="${empty param.pageSize ? '20' : param.pageSize}">
        </ui:searchForm>

        <!-- 페이지당 표시 -->
        <div class="d-flex justify-content-end mb-2">
            <ui:pageSize/>
        </div>

        <div class="card shadow-sm">
            <div class="card-body p-0">
                <table class="table table-hover mb-0 align-middle">
                    <thead class="table-light">
                    <tr>
                        <th class="ps-4" style="width:70px">No.</th>
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

        <ui:pagination page="${notices}"/>

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
                        <label class="form-label small text-muted d-block">이미지 (선택)</label>
                        <label class="upload-box" for="noticeWriteImage">
                            <span class="upload-placeholder"><i class="bi bi-camera"></i><span>사진 등록</span></span>
                            <img class="upload-preview" src="" alt="">
                            <span class="upload-hint"><i class="bi bi-arrow-repeat"></i> 사진 변경</span>
                        </label>
                        <input type="file" id="noticeWriteImage" name="imageFile" class="upload-input" accept="image/*">
                        <div class="form-text">공지 본문 상단에 표시됩니다.</div>
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
                            <label class="form-label small text-muted d-block">이미지 (선택)</label>
                            <label class="upload-box ${not empty n.imageUrl ? 'has-image' : ''}" for="noticeEditImage${n.noticeId}">
                                <span class="upload-placeholder"><i class="bi bi-camera"></i><span>사진 등록</span></span>
                                <img class="upload-preview" src="${n.imageUrl}" alt="">
                                <span class="upload-hint"><i class="bi bi-arrow-repeat"></i> 사진 변경</span>
                            </label>
                            <input type="file" id="noticeEditImage${n.noticeId}" name="imageFile" class="upload-input" accept="image/*">
                            <div class="form-text">사진을 클릭하면 다른 이미지로 교체됩니다. (비워두면 기존 이미지 유지)</div>
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

    // 파일 선택 시 업로드 박스에 미리보기 표시(이미지로 전환)
    document.querySelectorAll('.upload-input').forEach(function (inp) {
        inp.addEventListener('change', function () {
            if (!inp.files || !inp.files.length) return;
            var box = inp.parentElement.querySelector('.upload-box');
            if (!box) return;
            box.querySelector('.upload-preview').src = URL.createObjectURL(inp.files[0]);
            box.classList.add('has-image');
        });
    });
</script>
</body>
</html>
