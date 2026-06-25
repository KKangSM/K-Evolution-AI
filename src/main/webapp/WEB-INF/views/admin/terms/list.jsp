<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>약관 관리 · K-Evolution 관리자</title>
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
                <h4 class="page-title mb-1">약관 관리</h4>
                <p class="text-muted small mb-0">행을 클릭하면 상세·수정 창이 열립니다. HTML 파일로 등록·관리합니다.</p>
            </div>
            <button type="button" class="btn btn-dark btn-sm px-3"
                    data-bs-toggle="modal" data-bs-target="#writeModal">
                <i class="bi bi-file-earmark-plus"></i> 약관 등록
            </button>
        </div>

        <%@ include file="/WEB-INF/views/layout/flash-toast.jsp" %>

        <div class="card shadow-sm">
            <div class="card-body p-0">
                <table class="table table-hover mb-0 align-middle">
                    <thead class="table-light">
                        <tr>
                            <th class="ps-4" style="width:60px">No.</th>
                            <th style="width:150px">유형</th>
                            <th>제목</th>
                            <th style="width:90px">동의 구분</th>
                            <th style="width:90px">활성 구분</th>
                            <th style="width:110px">등록일</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="t" items="${termsList}" varStatus="status">
                        <tr style="cursor:pointer" data-bs-toggle="modal" data-bs-target="#termsModal${t.termId}">
                            <td class="ps-4 text-muted small">${status.count}</td>
                            <td>
                                <c:choose>
                                    <c:when test="${t.type == 'SERVICE'}"><span class="badge bg-primary">이용약관</span></c:when>
                                    <c:otherwise><span class="badge bg-secondary">개인정보처리방침</span></c:otherwise>
                                </c:choose>
                            </td>
                            <td class="fw-medium text-dark">${t.title}</td>
                            <td>
                                <c:choose>
                                    <c:when test="${t.required}"><span class="text-danger fw-bold small">필수</span></c:when>
                                    <c:otherwise><span class="text-muted small">선택</span></c:otherwise>
                                </c:choose>
                            </td>
                            <td>
                                <c:choose>
                                    <c:when test="${t.active}"><span class="badge bg-success">활성</span></c:when>
                                    <c:otherwise><span class="badge bg-light text-muted">비활성</span></c:otherwise>
                                </c:choose>
                            </td>
                            <td class="text-muted small">${t.createdAt.toString().substring(0, 10)}</td>
                        </tr>
                        </c:forEach>
                        <c:if test="${empty termsList}">
                        <tr><td colspan="6" class="text-center text-muted py-4">등록된 약관이 없습니다.</td></tr>
                        </c:if>
                    </tbody>
                </table>
            </div>
        </div>

    </main>
</div>

<%-- 약관 등록 모달 --%>
<div class="modal fade" id="writeModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-centered modal-dialog-scrollable">
        <div class="modal-content">
            <form action="${pageContext.request.contextPath}/admin/terms/upload"
                  method="post" enctype="multipart/form-data">
                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                <div class="modal-header">
                    <h6 class="modal-title fw-bold">약관 등록</h6>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="닫기"></button>
                </div>
                <div class="modal-body">
                    <div class="mb-3">
                        <label class="form-label small text-muted">유형</label>
                        <select name="type" class="form-select" required>
                            <c:forEach var="t" items="${types}">
                                <option value="${t}">
                                    <c:choose>
                                        <c:when test="${t == 'SERVICE'}">이용약관</c:when>
                                        <c:otherwise>개인정보처리방침</c:otherwise>
                                    </c:choose>
                                </option>
                            </c:forEach>
                        </select>
                    </div>
                    <div class="mb-3">
                        <label class="form-label small text-muted">제목</label>
                        <input type="text" name="title" class="form-control" required maxlength="100"
                               placeholder="예) K-Evolution 이용약관 (2026.06)">
                    </div>
                    <div class="mb-3">
                        <label class="form-label small text-muted">HTML 파일</label>
                        <input type="file" name="file" class="form-control" accept=".html,.htm" required>
                        <div class="form-text">.html / .htm 파일만 업로드 가능합니다.</div>
                    </div>
                    <div class="d-flex gap-4">
                        <div class="form-check">
                            <input class="form-check-input" type="checkbox" name="required" value="true" id="writeRequired" checked>
                            <label class="form-check-label small" for="writeRequired">필수 동의</label>
                        </div>
                        <div class="form-check">
                            <input class="form-check-input" type="checkbox" name="active" value="true" id="writeActive" checked>
                            <label class="form-check-label small" for="writeActive">활성화</label>
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

<%-- 약관별 상세/수정 모달 --%>
<c:forEach var="t" items="${termsList}">
    <div class="modal fade" id="termsModal${t.termId}" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-lg modal-dialog-centered modal-dialog-scrollable">
            <div class="modal-content">
                <div class="modal-header">
                    <h6 class="modal-title fw-bold">
                        <c:choose>
                            <c:when test="${t.type == 'SERVICE'}"><span class="badge bg-primary me-1">이용약관</span></c:when>
                            <c:otherwise><span class="badge bg-secondary me-1">개인정보처리방침</span></c:otherwise>
                        </c:choose>
                        <c:out value="${t.title}"/>
                    </h6>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="닫기"></button>
                </div>
                <div class="modal-body">
                    <div class="text-muted small mb-3">
                        ID: ${t.termId} &nbsp;|&nbsp; 등록일: ${t.createdAt.toString().substring(0, 10)}
                        &nbsp;|&nbsp; <span class="text-muted">유형은 등록 후 변경 불가</span>
                    </div>

                    <%-- 수정 폼 --%>
                    <form action="${pageContext.request.contextPath}/admin/terms/${t.termId}/edit"
                          method="post" enctype="multipart/form-data">
                        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                        <div class="mb-3">
                            <label class="form-label small text-muted">제목</label>
                            <input type="text" name="title" class="form-control" required maxlength="100"
                                   value="<c:out value='${t.title}'/>">
                        </div>
                        <div class="mb-3">
                            <label class="form-label small text-muted">HTML 파일 (변경 시에만 업로드)</label>
                            <input type="file" name="file" class="form-control" accept=".html,.htm">
                            <div class="form-text">비워두면 기존 내용을 유지합니다.</div>
                        </div>
                        <div class="d-flex gap-4 mb-3">
                            <div class="form-check">
                                <input class="form-check-input" type="checkbox" name="required" value="true"
                                       id="required${t.termId}" ${t.required ? 'checked' : ''}>
                                <label class="form-check-label small" for="required${t.termId}">필수 동의</label>
                            </div>
                            <div class="form-check">
                                <input class="form-check-input" type="checkbox" name="active" value="true"
                                       id="active${t.termId}" ${t.active ? 'checked' : ''}>
                                <label class="form-check-label small" for="active${t.termId}">활성화</label>
                            </div>
                        </div>
                        <div class="d-flex justify-content-between">
                            <button type="button" class="btn btn-outline-danger btn-sm"
                                    onclick="submitDelete(${t.termId})">삭제</button>
                            <div class="d-flex gap-2">
                                <button type="button" class="btn btn-outline-secondary btn-sm" data-bs-dismiss="modal">닫기</button>
                                <button type="submit" class="btn btn-dark btn-sm px-3">수정 완료</button>
                            </div>
                        </div>
                    </form>
                    <%-- 삭제 폼 (form 중첩 방지용 분리) --%>
                    <form id="deleteForm${t.termId}"
                          action="${pageContext.request.contextPath}/admin/terms/${t.termId}/delete"
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
    function submitDelete(termId) {
        if (confirm('약관을 삭제하시겠습니까?')) {
            document.getElementById('deleteForm' + termId).submit();
        }
    }
</script>
</body>
</html>
