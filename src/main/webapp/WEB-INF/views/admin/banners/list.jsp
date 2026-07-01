<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="ui" tagdir="/WEB-INF/tags" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>배너 관리 · K-Evolution 관리자</title>
    <%@ include file="/WEB-INF/views/layout/meta.jsp" %>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin.css">
    <style>
        .banner-thumb { width: 120px; height: 48px; object-fit: cover; border-radius: 6px; border: 1px solid #dee2e6; background: #f8f9fa; }
        .banner-preview { width: 100%; max-height: 200px; object-fit: contain; border-radius: 8px; border: 1px solid #dee2e6; background: #f8f9fa; }
    </style>
</head>
<body class="admin-body">

<%@ include file="/WEB-INF/views/layout/admin-topbar.jsp" %>

<div class="admin-layout">
    <%@ include file="/WEB-INF/views/layout/admin-sidebar.jsp" %>

    <main class="admin-main">

        <div class="d-flex justify-content-between align-items-center mb-3">
            <div>
                <h4 class="page-title mb-1">배너 관리</h4>
                <p class="text-muted small mb-0">행을 클릭하면 상세·수정 창이 열립니다. 노출순서 오름차순으로 정렬됩니다.</p>
            </div>
            <button type="button" class="btn btn-dark btn-sm px-3"
                    data-bs-toggle="modal" data-bs-target="#writeModal">
                <i class="bi bi-image"></i> 배너 등록
            </button>
        </div>

        <%@ include file="/WEB-INF/views/layout/flash-toast.jsp" %>

        <!-- 검색 폼 (제목) -->
        <ui:searchForm placeholder="제목 검색"
                       resetUrl="${pageContext.request.contextPath}/admin/banners"/>

        <div class="card shadow-sm">
            <div class="card-body p-0">
                <table class="table table-hover mb-0 align-middle">
                    <thead class="table-light">
                    <tr>
                        <th class="ps-4" style="width:70px">순서</th>
                        <th style="width:150px">이미지</th>
                        <th>제목 / 링크</th>
                        <th style="width:80px">노출</th>
                        <th style="width:230px">노출 기간</th>
                    </tr>
                    </thead>
                    <tbody>
                    <c:forEach var="b" items="${banners}">
                        <tr style="cursor:pointer"
                            data-bs-toggle="modal" data-bs-target="#bannerModal${b.bannerId}">
                            <td class="ps-4 text-muted">${b.sortOrder}</td>
                            <td><img src="${b.imageUrl}" class="banner-thumb" alt="배너 이미지"></td>
                            <td>
                                <div class="fw-medium text-dark">
                                    <c:choose>
                                        <c:when test="${not empty b.title}"><c:out value="${b.title}"/></c:when>
                                        <c:otherwise><span class="text-muted">(제목 없음)</span></c:otherwise>
                                    </c:choose>
                                </div>
                                <c:if test="${not empty b.linkUrl}">
                                    <div class="small text-muted text-truncate" style="max-width:380px">
                                        <i class="bi bi-link-45deg"></i> <c:out value="${b.linkUrl}"/>
                                    </div>
                                </c:if>
                            </td>
                            <td>
                                <c:choose>
                                    <c:when test="${b.active}"><span class="badge bg-success">노출중</span></c:when>
                                    <c:otherwise><span class="badge bg-secondary">숨김</span></c:otherwise>
                                </c:choose>
                            </td>
                            <td class="small text-muted">
                                <c:choose>
                                    <c:when test="${empty b.startAt and empty b.endAt}">상시</c:when>
                                    <c:otherwise>
                                        ${empty b.startAt ? '~' : b.startAt.toString().substring(0,16).replace('T',' ')}
                                        &nbsp;~&nbsp;
                                        ${empty b.endAt ? '∞' : b.endAt.toString().substring(0,16).replace('T',' ')}
                                    </c:otherwise>
                                </c:choose>
                            </td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty banners}">
                        <tr><td colspan="5" class="text-center text-muted py-5">등록된 배너가 없습니다.</td></tr>
                    </c:if>
                    </tbody>
                </table>
            </div>
        </div>

    </main>
</div>

<%-- ── 배너 등록 모달 ───────────────────────────── --%>
<div class="modal fade" id="writeModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-centered modal-dialog-scrollable">
        <div class="modal-content">
            <form action="${pageContext.request.contextPath}/admin/banners/register"
                  method="post" enctype="multipart/form-data">
                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                <div class="modal-header">
                    <h6 class="modal-title fw-bold">배너 등록</h6>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="닫기"></button>
                </div>
                <div class="modal-body">
                    <div class="mb-3">
                        <label class="form-label small text-muted d-block">배너 이미지</label>
                        <label class="upload-box" for="bannerWriteImage">
                            <span class="upload-placeholder"><i class="bi bi-camera"></i><span>사진 등록</span></span>
                            <img class="upload-preview" src="" alt="">
                            <span class="upload-hint"><i class="bi bi-arrow-repeat"></i> 사진 변경</span>
                        </label>
                        <input type="file" id="bannerWriteImage" name="imageFile" class="upload-input" accept="image/*" required>
                        <div class="form-text">JPG, PNG, WEBP 등 (최대 10MB) · Supabase Storage 에 업로드됩니다.</div>
                    </div>
                    <div class="mb-3">
                        <label class="form-label small text-muted">제목</label>
                        <input type="text" name="title" class="form-control" maxlength="100" required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label small text-muted">연결 이벤트 (선택)</label>
                        <select class="form-select event-select" data-target="writeLinkUrl">
                            <option value="">선택 안 함 (직접 URL 입력)</option>
                            <c:forEach var="ev" items="${events}">
                                <option value="${ev.eventId}"><c:out value="${ev.title}"/></option>
                            </c:forEach>
                        </select>
                        <div class="form-text">이벤트를 고르면 아래 링크가 자동으로 채워집니다.</div>
                    </div>
                    <div class="mb-3">
                        <label class="form-label small text-muted">클릭 시 이동 URL (선택)</label>
                        <input type="text" name="linkUrl" id="writeLinkUrl" class="form-control" maxlength="500"
                               placeholder="https://... 또는 /events/123">
                    </div>
                    <div class="row g-3">
                        <div class="col-md-4">
                            <label class="form-label small text-muted">노출순서</label>
                            <input type="number" name="sortOrder" class="form-control" value="0" min="0">
                        </div>
                        <div class="col-md-4">
                            <label class="form-label small text-muted">노출 시작 (선택)</label>
                            <input type="datetime-local" name="startAt" class="form-control">
                        </div>
                        <div class="col-md-4">
                            <label class="form-label small text-muted">노출 종료 (선택)</label>
                            <input type="datetime-local" name="endAt" class="form-control">
                        </div>
                    </div>
                    <div class="form-check mt-3">
                        <input class="form-check-input" type="checkbox" name="active" value="true" id="writeActive" checked>
                        <label class="form-check-label small" for="writeActive">바로 노출(활성화)</label>
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

<%-- ── 배너별 상세/수정 모달 ─────────────────────── --%>
<c:forEach var="b" items="${banners}">
    <div class="modal fade" id="bannerModal${b.bannerId}" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-lg modal-dialog-centered modal-dialog-scrollable">
            <div class="modal-content">
                <div class="modal-header">
                    <h6 class="modal-title fw-bold">
                        배너 #${b.bannerId}
                        <c:choose>
                            <c:when test="${b.active}"><span class="badge bg-success ms-1">노출중</span></c:when>
                            <c:otherwise><span class="badge bg-secondary ms-1">숨김</span></c:otherwise>
                        </c:choose>
                    </h6>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="닫기"></button>
                </div>
                <div class="modal-body">
                    <form action="${pageContext.request.contextPath}/admin/banners/${b.bannerId}/edit"
                          method="post" enctype="multipart/form-data">
                        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>

                        <div class="mb-3">
                            <label class="form-label small text-muted d-block">배너 이미지</label>
                            <label class="upload-box ${not empty b.imageUrl ? 'has-image' : ''}" for="bannerEditImage${b.bannerId}">
                                <span class="upload-placeholder"><i class="bi bi-camera"></i><span>사진 등록</span></span>
                                <img class="upload-preview" src="${b.imageUrl}" alt="">
                                <span class="upload-hint"><i class="bi bi-arrow-repeat"></i> 사진 변경</span>
                            </label>
                            <input type="file" id="bannerEditImage${b.bannerId}" name="imageFile" class="upload-input"
                                   accept="image/*">
                            <div class="form-text">새 파일을 선택하면 교체됩니다. (비워두면 기존 이미지 유지)</div>
                        </div>
                        <div class="mb-3">
                            <label class="form-label small text-muted">제목</label>
                            <input type="text" name="title" class="form-control" maxlength="100" required
                                   value="<c:out value='${b.title}'/>">
                        </div>
                        <div class="mb-3">
                            <label class="form-label small text-muted">연결 이벤트 (선택)</label>
                            <select class="form-select event-select" data-target="editLinkUrl${b.bannerId}">
                                <option value="">선택 안 함 (직접 URL 입력)</option>
                                <c:forEach var="ev" items="${events}">
                                    <option value="${ev.eventId}"><c:out value="${ev.title}"/></option>
                                </c:forEach>
                            </select>
                            <div class="form-text">이벤트를 고르면 아래 링크가 자동으로 채워집니다.</div>
                        </div>
                        <div class="mb-3">
                            <label class="form-label small text-muted">클릭 시 이동 URL</label>
                            <input type="text" name="linkUrl" id="editLinkUrl${b.bannerId}" class="form-control" maxlength="500"
                                   value="<c:out value='${b.linkUrl}'/>">
                        </div>
                        <div class="row g-3">
                            <div class="col-md-4">
                                <label class="form-label small text-muted">노출순서</label>
                                <input type="number" name="sortOrder" class="form-control" min="0"
                                       value="${b.sortOrder}">
                            </div>
                            <div class="col-md-4">
                                <label class="form-label small text-muted">노출 시작</label>
                                <input type="datetime-local" name="startAt" class="form-control"
                                       value="${empty b.startAt ? '' : b.startAt.toString().substring(0,16)}">
                            </div>
                            <div class="col-md-4">
                                <label class="form-label small text-muted">노출 종료</label>
                                <input type="datetime-local" name="endAt" class="form-control"
                                       value="${empty b.endAt ? '' : b.endAt.toString().substring(0,16)}">
                            </div>
                        </div>
                        <div class="form-check mt-3 mb-3">
                            <input class="form-check-input" type="checkbox" name="active" value="true"
                                   id="active${b.bannerId}" ${b.active ? 'checked' : ''}>
                            <label class="form-check-label small" for="active${b.bannerId}">노출(활성화)</label>
                        </div>

                        <div class="d-flex justify-content-between">
                            <button type="button" class="btn btn-outline-danger btn-sm"
                                    onclick="submitBannerDelete(${b.bannerId})">삭제</button>
                            <div class="d-flex gap-2">
                                <button type="button" class="btn btn-outline-secondary btn-sm"
                                        data-bs-dismiss="modal">닫기</button>
                                <button type="submit" class="btn btn-dark btn-sm px-3">수정 완료</button>
                            </div>
                        </div>
                    </form>
                    <%-- 삭제 폼 (form 중첩 방지용 분리) --%>
                    <form id="bannerDeleteForm${b.bannerId}"
                          action="${pageContext.request.contextPath}/admin/banners/${b.bannerId}/delete"
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

    function submitBannerDelete(bannerId) {
        if (confirm('배너를 삭제하시겠습니까? Storage 이미지도 함께 삭제됩니다.')) {
            document.getElementById('bannerDeleteForm' + bannerId).submit();
        }
    }

    // 이벤트 선택 시 링크 URL 을 /events/{id} 로 자동 채움
    document.querySelectorAll('.event-select').forEach(function (sel) {
        sel.addEventListener('change', function () {
            var target = document.getElementById(sel.dataset.target);
            if (target && sel.value) {
                target.value = '${pageContext.request.contextPath}/events/' + sel.value;
            }
        });
    });
</script>
</body>
</html>
