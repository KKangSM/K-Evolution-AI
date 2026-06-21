<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>약관 ${empty terms ? '등록' : '수정'} · K-Evolution 관리자</title>
    <%@ include file="/WEB-INF/views/fragments/head.jsp" %>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin.css">
</head>
<body class="admin-body">

<%@ include file="/WEB-INF/views/fragments/admin-topbar.jsp" %>

<div class="admin-layout">
    <%@ include file="/WEB-INF/views/fragments/admin-sidebar.jsp" %>

    <main class="admin-main">

        <div class="mb-4">
            <h4 class="page-title mb-1">약관 ${empty terms ? '등록' : '수정'}</h4>
            <p class="text-muted small mb-0">HTML 파일을 업로드하면 내용이 저장됩니다.</p>
        </div>

        <%@ include file="/WEB-INF/views/fragments/flash-toast.jsp" %>

        <div class="card shadow-sm" style="max-width: 560px;">
            <div class="card-body p-4">
                <c:choose>
                    <c:when test="${empty terms}">
                        <c:set var="formAction" value="${pageContext.request.contextPath}/admin/terms/upload"/>
                    </c:when>
                    <c:otherwise>
                        <c:set var="formAction" value="${pageContext.request.contextPath}/admin/terms/${terms.termId}/edit"/>
                    </c:otherwise>
                </c:choose>
                <form action="${formAction}" method="post" enctype="multipart/form-data">
                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>

                    <div class="mb-3">
                        <label class="form-label small text-muted">유형</label>
                        <select name="type" class="form-select" ${not empty terms ? 'disabled' : ''} required>
                            <c:forEach var="t" items="${types}">
                                <option value="${t}" ${terms.type == t ? 'selected' : ''}>
                                    <c:choose>
                                        <c:when test="${t == 'SERVICE'}">이용약관</c:when>
                                        <c:otherwise>개인정보처리방침</c:otherwise>
                                    </c:choose>
                                </option>
                            </c:forEach>
                        </select>
                        <c:if test="${not empty terms}">
                            <input type="hidden" name="type" value="${terms.type}"/>
                        </c:if>
                    </div>

                    <div class="mb-3">
                        <label class="form-label small text-muted">제목</label>
                        <input type="text" name="title" class="form-control"
                               value="${terms.title}" placeholder="예) K-Evolution 이용약관 (2026.06)" required maxlength="100">
                    </div>

                    <div class="mb-3">
                        <label class="form-label small text-muted">HTML 파일 ${not empty terms ? '(변경 시에만 업로드)' : ''}</label>
                        <input type="file" name="file" class="form-control" accept=".html,.htm"
                               ${empty terms ? 'required' : ''}>
                        <div class="form-text">.html / .htm 파일만 업로드 가능합니다.</div>
                    </div>

                    <div class="mb-3 d-flex gap-4">
                        <div class="form-check">
                            <input class="form-check-input" type="checkbox" name="required" id="chkRequired"
                                   value="true" ${(empty terms || terms.required) ? 'checked' : ''}>
                            <label class="form-check-label small" for="chkRequired">필수 동의</label>
                        </div>
                        <div class="form-check">
                            <input class="form-check-input" type="checkbox" name="active" id="chkActive"
                                   value="true" ${(empty terms || terms.active) ? 'checked' : ''}>
                            <label class="form-check-label small" for="chkActive">활성화</label>
                        </div>
                    </div>

                    <div class="d-flex gap-2">
                        <button type="submit" class="btn btn-dark">${empty terms ? '등록' : '수정'}</button>
                        <a href="${pageContext.request.contextPath}/admin/terms" class="btn btn-outline-secondary">취소</a>
                    </div>
                </form>
            </div>
        </div>

    </main>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
