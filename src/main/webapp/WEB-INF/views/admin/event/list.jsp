<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="ui" tagdir="/WEB-INF/tags" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>이벤트 관리 · K-Evolution 관리자</title>
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
                <h4 class="page-title mb-1">이벤트 관리</h4>
            </div>
            <button type="button" class="btn btn-dark btn-sm px-3"
                    data-bs-toggle="modal" data-bs-target="#writeModal">
                <i class="bi bi-megaphone"></i> 이벤트 등록
            </button>
        </div>

        <%@ include file="/WEB-INF/views/layout/flash-toast.jsp" %>

        <!-- 검색 폼 (제목) -->
        <ui:searchForm placeholder="제목 검색"
                       resetUrl="${pageContext.request.contextPath}/admin/events">
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
                        <th style="width:80px">노출</th>
                        <th style="width:230px">노출 기간</th>
                        <th style="width:80px">조회수</th>
                        <th style="width:110px">등록일</th>
                    </tr>
                    </thead>
                    <tbody>
                    <c:forEach var="e" items="${events.content}" varStatus="status">
                        <tr style="cursor:pointer"
                            data-bs-toggle="modal" data-bs-target="#eventModal${e.eventId}">
                            <td class="ps-4 text-muted small">${events.totalElements - (events.number * events.size + status.index)}</td>
                            <td class="fw-medium text-dark"><c:out value="${e.title}"/></td>
                            <td>
                                <c:choose>
                                    <c:when test="${e.exposureStatus == 'LIVE'}"><span class="badge bg-success">노출중</span></c:when>
                                    <c:when test="${e.exposureStatus == 'SCHEDULED'}"><span class="badge bg-info text-dark">예정</span></c:when>
                                    <c:when test="${e.exposureStatus == 'ENDED'}"><span class="badge bg-secondary">종료</span></c:when>
                                    <c:otherwise><span class="badge bg-dark">숨김</span></c:otherwise>
                                </c:choose>
                            </td>
                            <td class="small text-muted">
                                <c:choose>
                                    <c:when test="${empty e.startAt and empty e.endAt}">상시</c:when>
                                    <c:otherwise>
                                        ${empty e.startAt ? '~' : e.startAt.toString().substring(0,16).replace('T',' ')}
                                        &nbsp;~&nbsp;
                                        ${empty e.endAt ? '∞' : e.endAt.toString().substring(0,16).replace('T',' ')}
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td class="small text-muted">${e.viewCount}</td>
                            <td class="pe-4 small text-muted">${e.createdAt.toString().substring(0, 10)}</td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty events.content}">
                        <tr>
                            <td colspan="6" class="text-center text-muted py-4">등록된 이벤트가 없습니다.</td>
                        </tr>
                    </c:if>
                    </tbody>
                </table>
            </div>
        </div>

        <ui:pagination page="${events}"/>

    </main>
</div>

<%-- 이벤트 등록 모달 --%>
<div class="modal fade" id="writeModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-centered modal-dialog-scrollable">
        <div class="modal-content">
            <form action="${pageContext.request.contextPath}/admin/events/write"
                  method="post" enctype="multipart/form-data">
                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                <div class="modal-header">
                    <h6 class="modal-title fw-bold">이벤트 등록</h6>
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
                        <textarea name="content" class="form-control" rows="8" required
                                  placeholder="이벤트 상세 내용을 입력하세요"></textarea>
                    </div>
                    <div class="mb-3">
                        <label class="form-label small text-muted d-block">대표 이미지 (선택)</label>
                        <label class="upload-box" for="eventWriteImage">
                            <span class="upload-placeholder"><i class="bi bi-camera"></i><span>사진 등록</span></span>
                            <img class="upload-preview" src="" alt="">
                            <span class="upload-hint"><i class="bi bi-arrow-repeat"></i> 사진 변경</span>
                        </label>
                        <input type="file" id="eventWriteImage" name="imageFile" class="upload-input" accept="image/*">
                        <div class="form-text">이벤트 상세 페이지 상단에 표시됩니다.</div>
                    </div>
                    <div class="row g-3">
                        <div class="col-md-4">
                            <label class="form-label small text-muted">노출 시작 (선택)</label>
                            <input type="datetime-local" name="startAt" class="form-control">
                        </div>
                        <div class="col-md-4">
                            <label class="form-label small text-muted">노출 종료 (선택)</label>
                            <input type="datetime-local" name="endAt" class="form-control">
                        </div>
                        <div class="col-md-4 d-flex align-items-end">
                            <div class="form-check">
                                <input class="form-check-input" type="checkbox" name="active" value="true" id="writeActive" checked>
                                <label class="form-check-label small" for="writeActive">바로 노출(활성화)</label>
                            </div>
                        </div>
                    </div>
                    <div class="form-text mt-2">기간을 비우면 상시 노출됩니다. 활성 상태이고 현재가 노출 기간 안일 때만 메인/이벤트 목록에 나타납니다.</div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-outline-secondary btn-sm" data-bs-dismiss="modal">취소</button>
                    <button type="submit" class="btn btn-dark btn-sm px-3">등록</button>
                </div>
            </form>
        </div>
    </div>
</div>

<%-- 이벤트별 상세/수정 모달 --%>
<c:forEach var="e" items="${events.content}">
    <div class="modal fade" id="eventModal${e.eventId}" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-lg modal-dialog-centered modal-dialog-scrollable">
            <div class="modal-content">
                <div class="modal-header">
                    <h6 class="modal-title fw-bold">
                        <c:out value="${e.title}"/>
                        <c:choose>
                            <c:when test="${e.exposureStatus == 'LIVE'}"><span class="badge bg-success ms-1">노출중</span></c:when>
                            <c:when test="${e.exposureStatus == 'SCHEDULED'}"><span class="badge bg-info text-dark ms-1">예정</span></c:when>
                            <c:when test="${e.exposureStatus == 'ENDED'}"><span class="badge bg-secondary ms-1">종료</span></c:when>
                            <c:otherwise><span class="badge bg-dark ms-1">숨김</span></c:otherwise>
                        </c:choose>
                    </h6>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="닫기"></button>
                </div>
                <div class="modal-body">
                    <div class="text-muted small mb-3">
                        작성일: ${e.createdAt.toString().substring(0, 16).replace('T', ' ')}
                        &nbsp;|&nbsp; 수정일: ${e.updatedAt.toString().substring(0, 16).replace('T', ' ')}
                        &nbsp;|&nbsp; 조회수: ${e.viewCount}
                        &nbsp;|&nbsp; 링크: <code>/events/${e.eventId}</code>
                    </div>

                    <%-- 수정 폼 --%>
                    <form action="${pageContext.request.contextPath}/admin/events/${e.eventId}/edit"
                          method="post" enctype="multipart/form-data">
                        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                        <div class="mb-3">
                            <label class="form-label small text-muted">제목</label>
                            <input type="text" name="title" class="form-control" required maxlength="200"
                                   value="<c:out value='${e.title}'/>">
                        </div>
                        <div class="mb-3">
                            <label class="form-label small text-muted">내용</label>
                            <textarea name="content" class="form-control" rows="8" required><c:out value="${e.content}"/></textarea>
                        </div>
                        <div class="mb-3">
                            <label class="form-label small text-muted d-block">대표 이미지 (선택)</label>
                            <label class="upload-box ${not empty e.imageUrl ? 'has-image' : ''}" for="eventEditImage${e.eventId}">
                                <span class="upload-placeholder"><i class="bi bi-camera"></i><span>사진 등록</span></span>
                                <img class="upload-preview" src="${e.imageUrl}" alt="">
                                <span class="upload-hint"><i class="bi bi-arrow-repeat"></i> 사진 변경</span>
                            </label>
                            <input type="file" id="eventEditImage${e.eventId}" name="imageFile" class="upload-input" accept="image/*">
                            <div class="form-text">사진을 클릭하면 다른 이미지로 교체됩니다. (비워두면 기존 이미지 유지)</div>
                        </div>
                        <div class="row g-3 mb-3">
                            <div class="col-md-4">
                                <label class="form-label small text-muted">노출 시작</label>
                                <input type="datetime-local" name="startAt" class="form-control"
                                       value="${empty e.startAt ? '' : e.startAt.toString().substring(0,16)}">
                            </div>
                            <div class="col-md-4">
                                <label class="form-label small text-muted">노출 종료</label>
                                <input type="datetime-local" name="endAt" class="form-control"
                                       value="${empty e.endAt ? '' : e.endAt.toString().substring(0,16)}">
                            </div>
                            <div class="col-md-4 d-flex align-items-end">
                                <div class="form-check">
                                    <input class="form-check-input" type="checkbox" name="active" value="true"
                                           id="active${e.eventId}" ${e.active ? 'checked' : ''}>
                                    <label class="form-check-label small" for="active${e.eventId}">노출(활성화)</label>
                                </div>
                            </div>
                        </div>
                        <div class="d-flex justify-content-between">
                            <button type="button" class="btn btn-outline-danger btn-sm"
                                    onclick="submitDelete(${e.eventId})">삭제</button>
                            <div class="d-flex gap-2">
                                <button type="button" class="btn btn-outline-secondary btn-sm" data-bs-dismiss="modal">닫기</button>
                                <button type="submit" class="btn btn-dark btn-sm px-3">수정 완료</button>
                            </div>
                        </div>
                    </form>
                    <%-- 삭제 폼 (form 중첩 방지용 분리) --%>
                    <form id="deleteForm${e.eventId}"
                          action="${pageContext.request.contextPath}/admin/events/${e.eventId}/delete"
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
    function submitDelete(eventId) {
        if (confirm('이벤트를 삭제하시겠습니까?')) {
            document.getElementById('deleteForm' + eventId).submit();
        }
    }

    // 파일 선택 시 업로드 박스 미리보기
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
