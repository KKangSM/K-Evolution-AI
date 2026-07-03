<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="ui" tagdir="/WEB-INF/tags" %>
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

        <div class="d-flex justify-content-between align-items-center mb-3">
            <div>
                <h4 class="page-title mb-1">약관 관리</h4>
            </div>
            <button type="button" class="btn btn-dark btn-sm px-3"
                    data-bs-toggle="modal" data-bs-target="#writeModal">
                <i class="bi bi-file-earmark-plus"></i> 약관 등록
            </button>
        </div>

        <%@ include file="/WEB-INF/views/layout/flash-toast.jsp" %>

        <!-- 검색 폼 -->
        <ui:searchForm placeholder="제목 검색"
                       resetUrl="${pageContext.request.contextPath}/admin/terms?type=${filterType}">
            <%-- 현재 탭(유형)·페이지 크기 유지 --%>
            <input type="hidden" name="type" value="${filterType}">
            <input type="hidden" name="pageSize" value="${empty param.pageSize ? '20' : param.pageSize}">
            <div class="col-md-2">
                <select name="contentType" class="form-select form-select-sm">
                    <option value="">저장방식 전체</option>
                    <option value="FILE" ${filterContentType == 'FILE' ? 'selected' : ''}>파일</option>
                    <option value="TEXT" ${filterContentType == 'TEXT' ? 'selected' : ''}>텍스트</option>
                </select>
            </div>
            <div class="col-md-2">
                <select name="required" class="form-select form-select-sm">
                    <option value="">동의구분 전체</option>
                    <option value="true" ${filterRequired == 'true' ? 'selected' : ''}>필수</option>
                    <option value="false" ${filterRequired == 'false' ? 'selected' : ''}>선택</option>
                </select>
            </div>
            <div class="col-md-2">
                <select name="active" class="form-select form-select-sm">
                    <option value="">활성상태 전체</option>
                    <option value="true" ${filterActive == 'true' ? 'selected' : ''}>활성</option>
                    <option value="false" ${filterActive == 'false' ? 'selected' : ''}>비활성</option>
                </select>
            </div>
        </ui:searchForm>

        <!-- 유형 탭 + 페이지당 표시 -->
        <div class="d-flex justify-content-between align-items-end mb-2">
            <ul class="nav nav-tabs mb-0" role="tablist" style="border-bottom:0">
                <li class="nav-item">
                    <a class="nav-link ${filterType == 'SERVICE' ? 'active' : ''}"
                       href="?type=SERVICE">이용약관</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link ${filterType == 'PRIVACY' ? 'active' : ''}"
                       href="?type=PRIVACY">개인정보처리방침</a>
                </li>
            </ul>
            <ui:pageSize/>
        </div>

        <div class="card shadow-sm">
            <div class="card-body p-0">
                <table class="table table-hover mb-0 align-middle">
                    <thead class="table-light">
                        <tr>
                            <th class="ps-4" style="width:60px">No.</th>
                            <th style="width:150px">유형</th>
                            <th>제목</th>
                            <th style="width:80px" class="text-center">저장 방식</th>
                            <th style="width:90px" class="text-center">동의 구분</th>
                            <th style="width:90px" class="text-center">활성 상태</th>
                            <th style="width:110px" class="text-center">등록일</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="t" items="${termsList.content}" varStatus="status">
                        <tr style="cursor:pointer" data-bs-toggle="modal" data-bs-target="#termsModal${t.termId}">
                            <td class="ps-4 text-muted small">${termsList.totalElements - (termsList.number * termsList.size + status.index)}</td>
                            <td>
                                <c:choose>
                                    <c:when test="${t.type == 'SERVICE'}"><span class="badge bg-primary">이용약관</span></c:when>
                                    <c:otherwise><span class="badge bg-secondary">개인정보처리방침</span></c:otherwise>
                                </c:choose>
                            </td>
                            <td class="fw-medium text-dark">${t.title}</td>
                            <td class="text-center">
                                <c:choose>
                                    <c:when test="${t.contentType == 'FILE'}"><span class="badge bg-info">📁 파일</span></c:when>
                                    <c:otherwise><span class="badge bg-warning">✏️ 텍스트</span></c:otherwise>
                                </c:choose>
                            </td>
                            <td class="text-center">
                                <c:choose>
                                    <c:when test="${t.required}"><span class="text-danger fw-bold small">필수</span></c:when>
                                    <c:otherwise><span class="text-muted small">선택</span></c:otherwise>
                                </c:choose>
                            </td>
                            <td class="text-center">
                                <c:choose>
                                    <c:when test="${t.active}"><span class="badge bg-success">활성</span></c:when>
                                    <c:otherwise><span class="badge bg-light text-muted">비활성</span></c:otherwise>
                                </c:choose>
                            </td>
                            <td class="text-muted small text-center">${t.createdAt.toString().substring(0, 10)}</td>
                        </tr>
                        </c:forEach>
                        <c:if test="${empty termsList.content}">
                        <tr><td colspan="7" class="text-center text-muted py-4">등록된 약관이 없습니다.</td></tr>
                        </c:if>
                    </tbody>
                </table>
            </div>
        </div>

        <!-- 페이지네이션 -->
        <ui:pagination page="${termsList}"/>

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
                        <input type="text" name="title" class="form-control" required maxlength="100">
                    </div>
                    <div class="mb-3">
                        <label class="form-label small text-muted">약관 내용</label>
                        <c:if test="${isSystem}">
                            <ul class="nav nav-tabs nav-fill mb-2" role="tablist">
                                <li class="nav-item">
                                    <a class="nav-link active" data-bs-toggle="tab" href="#writeFile" role="tab">📁 파일로 업로드</a>
                                </li>
                                <li class="nav-item">
                                    <a class="nav-link" data-bs-toggle="tab" href="#writeText" role="tab">✏️ 직접 입력</a>
                                </li>
                            </ul>
                            <div class="tab-content">
                                <div class="tab-pane fade show active" id="writeFile" role="tabpanel">
                                    <input type="file" name="file" class="form-control" accept=".html,.htm">
                                    <div class="form-text">.html / .htm 파일을 선택하세요.</div>
                                </div>
                                <div class="tab-pane fade" id="writeText" role="tabpanel">
                                    <textarea name="content" class="form-control" rows="10" placeholder="일반 텍스트로 입력하세요. 줄바꿈은 자동으로 변환됩니다."></textarea>
                                    <div class="form-text">평문 텍스트로 입력하세요. 줄바꿈(엔터)은 자동으로 HTML로 변환됩니다.</div>
                                </div>
                            </div>
                        </c:if>
                        <c:if test="${!isSystem}">
                            <textarea name="content" class="form-control" rows="10" placeholder="약관 내용을 입력하세요"></textarea>
                        </c:if>
                    </div>
                    <div class="d-flex gap-4">
                        <div style="width:50%;">
                            <label class="form-label small text-muted">동의 구분</label>
                            <div class="d-flex gap-3">
                                <div class="form-check">
                                    <input class="form-check-input" type="radio" name="required" value="true" id="writeRequired" checked>
                                    <label class="form-check-label small" for="writeRequired">필수 동의</label>
                                </div>
                                <div class="form-check">
                                    <input class="form-check-input" type="radio" name="required" value="false" id="writeOptional">
                                    <label class="form-check-label small" for="writeOptional">선택 동의</label>
                                </div>
                            </div>
                        </div>
                        <div style="width:50%;">
                            <label class="form-label small text-muted">활성 상태</label>
                            <div class="d-flex gap-3">
                                <div class="form-check">
                                    <input class="form-check-input" type="radio" name="active" value="true" id="writeActive" checked>
                                    <label class="form-check-label small" for="writeActive">활성화</label>
                                </div>
                                <div class="form-check">
                                    <input class="form-check-input" type="radio" name="active" value="false" id="writeInactive">
                                    <label class="form-check-label small" for="writeInactive">비활성화</label>
                                </div>
                            </div>
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
<c:forEach var="t" items="${termsList.content}">
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
                            <label class="form-label small text-muted">약관 내용</label>
                            <c:if test="${isSystem}">
                                <ul class="nav nav-tabs nav-fill mb-2" role="tablist">
                                    <li class="nav-item">
                                        <a class="nav-link <c:if test="${t.contentType == 'FILE'}">active</c:if>" data-bs-toggle="tab" href="#editFile${t.termId}" role="tab">📁 파일로 변경</a>
                                    </li>
                                    <li class="nav-item">
                                        <a class="nav-link <c:if test="${t.contentType == 'TEXT'}">active</c:if>" data-bs-toggle="tab" href="#editText${t.termId}" role="tab">✏️ 직접 수정</a>
                                    </li>
                                </ul>
                                <div class="tab-content">
                                    <div class="tab-pane fade <c:if test="${t.contentType == 'FILE'}">show active</c:if>" id="editFile${t.termId}" role="tabpanel">
                                        <input type="file" name="file" class="form-control" accept=".html,.htm">
                                        <div class="form-text">새 파일을 선택하면 내용을 변경합니다. (선택 사항)</div>
                                    </div>
                                    <div class="tab-pane fade <c:if test="${t.contentType == 'TEXT'}">show active</c:if>" id="editText${t.termId}" role="tabpanel">
                                        <textarea name="content" class="form-control" rows="10"><c:if test="${t.contentType == 'TEXT'}"><c:out value="${plainTextMap[t.termId]}"/></c:if></textarea>
                                    </div>
                                </div>
                            </c:if>
                            <c:if test="${!isSystem}">
                                <textarea name="content" class="form-control" rows="10"><c:out value="${plainTextMap[t.termId]}"/></textarea>
                            </c:if>
                        </div>
                        <div class="d-flex gap-4 mb-3">
                            <div style="width:50%;">
                                <label class="form-label small text-muted">동의 구분</label>
                                <div class="d-flex gap-3">
                                    <div class="form-check">
                                        <input class="form-check-input" type="radio" name="required" value="true"
                                               id="required${t.termId}" ${t.required ? 'checked' : ''}>
                                        <label class="form-check-label small" for="required${t.termId}">필수 동의</label>
                                    </div>
                                    <div class="form-check">
                                        <input class="form-check-input" type="radio" name="required" value="false"
                                               id="optional${t.termId}" ${!t.required ? 'checked' : ''}>
                                        <label class="form-check-label small" for="optional${t.termId}">선택 동의</label>
                                    </div>
                                </div>
                            </div>
                            <div style="width:50%;">
                                <label class="form-label small text-muted">활성 상태</label>
                                <div class="d-flex gap-3">
                                    <div class="form-check">
                                        <input class="form-check-input" type="radio" name="active" value="true"
                                               id="active${t.termId}" ${t.active ? 'checked' : ''}>
                                        <label class="form-check-label small" for="active${t.termId}">활성화</label>
                                    </div>
                                    <div class="form-check">
                                        <input class="form-check-input" type="radio" name="active" value="false"
                                               id="inactive${t.termId}" ${!t.active ? 'checked' : ''}>
                                        <label class="form-check-label small" for="inactive${t.termId}">비활성화</label>
                                    </div>
                                </div>
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
