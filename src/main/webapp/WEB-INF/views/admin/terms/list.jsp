<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
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
                <p class="text-muted small mb-0">회원가입 약관을 HTML 파일로 업로드하여 관리합니다.</p>
            </div>
            <a href="${pageContext.request.contextPath}/admin/terms/upload" class="btn btn-dark">+ 약관 등록</a>
        </div>

        <%@ include file="/WEB-INF/views/layout/flash-toast.jsp" %>

        <div class="card shadow-sm">
            <div class="card-body p-0">
                <table class="table table-hover mb-0">
                    <thead class="table-light">
                        <tr>
                            <th class="ps-4">ID</th>
                            <th>유형</th>
                            <th>제목</th>
                            <th>필수</th>
                            <th>활성</th>
                            <th>등록일</th>
                            <th></th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="t" items="${termsList}">
                        <tr>
                            <td class="ps-4 text-muted small">${t.termId}</td>
                            <td>
                                <c:choose>
                                    <c:when test="${t.type == 'SERVICE'}">
                                        <span class="badge bg-primary">이용약관</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="badge bg-secondary">개인정보처리방침</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td>${t.title}</td>
                            <td>
                                <c:choose>
                                    <c:when test="${t.required}"><span class="text-danger fw-bold">필수</span></c:when>
                                    <c:otherwise><span class="text-muted">선택</span></c:otherwise>
                                </c:choose>
                            </td>
                            <td>
                                <c:choose>
                                    <c:when test="${t.active}"><span class="badge bg-success">활성</span></c:when>
                                    <c:otherwise><span class="badge bg-light text-muted">비활성</span></c:otherwise>
                                </c:choose>
                            </td>
                            <td class="text-muted small">
                                ${t.createdAt.toString().substring(0, 10)}
                            </td>
                            <td class="text-end pe-4">
                                <a href="${pageContext.request.contextPath}/admin/terms/${t.termId}/edit"
                                   class="btn btn-sm btn-outline-secondary me-1">수정</a>
                                <form action="${pageContext.request.contextPath}/admin/terms/${t.termId}/delete"
                                      method="post" class="d-inline"
                                      onsubmit="return confirm('삭제하시겠습니까?')">
                                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                                    <button class="btn btn-sm btn-outline-danger">삭제</button>
                                </form>
                            </td>
                        </tr>
                        </c:forEach>
                        <c:if test="${empty termsList}">
                        <tr>
                            <td colspan="7" class="text-center text-muted py-4">등록된 약관이 없습니다.</td>
                        </tr>
                        </c:if>
                    </tbody>
                </table>
            </div>
        </div>

    </main>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
