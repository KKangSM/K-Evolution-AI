<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>회원 관리 · K-Evolution 관리자</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin.css">
</head>
<body class="admin-body">

<%@ include file="/WEB-INF/views/fragments/admin-topbar.jsp" %>

<div class="admin-layout">
    <%@ include file="/WEB-INF/views/fragments/admin-sidebar.jsp" %>

    <main class="admin-main">

        <div class="mb-4">
            <h4 class="page-title mb-1">회원 관리</h4>
            <p class="text-muted small mb-0">전체 회원 목록을 조회하고 권한 변경 및 삭제를 처리합니다.</p>
        </div>

        <c:if test="${not empty successMsg}">
            <div class="alert alert-success py-2 small">${successMsg}</div>
        </c:if>
        <c:if test="${not empty errorMsg}">
            <div class="alert alert-danger py-2 small">${errorMsg}</div>
        </c:if>

        <div class="card shadow-sm">
            <div class="card-body p-0">
                <table class="table table-hover mb-0 align-middle">
                    <thead class="table-light">
                    <tr>
                        <th class="ps-4">아이디</th>
                        <th>이름</th>
                        <th>권한</th>
                        <th>상태</th>
                        <th>가입일</th>
                        <th>권한 변경</th>
                        <th></th>
                    </tr>
                    </thead>
                    <tbody>
                    <c:forEach var="m" items="${members.content}">
                        <tr>
                            <td class="ps-4">${m.userId}</td>
                            <td>${m.name}</td>
                            <td>
                                <c:choose>
                                    <c:when test="${m.role == 'SYSTEM'}">
                                        <span class="badge bg-dark">SYSTEM</span>
                                    </c:when>
                                    <c:when test="${m.role == 'ADMIN'}">
                                        <span class="badge bg-danger">ADMIN</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="badge bg-secondary">USER</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td>
                                <c:choose>
                                    <c:when test="${m.status == 'ACTIVE'}">
                                        <span class="badge bg-success">활성</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="badge bg-dark">탈퇴</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td class="text-muted small">${m.createdAt.toString().substring(0, 10)}</td>
                            <td>
                                <form action="${pageContext.request.contextPath}/admin/members/${m.memberId}/role"
                                      method="post" class="d-flex gap-2">
                                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                                    <select name="role" class="form-select form-select-sm" style="width:110px">
                                        <option value="USER"   ${m.role == 'USER'   ? 'selected' : ''}>USER</option>
                                        <option value="ADMIN"  ${m.role == 'ADMIN'  ? 'selected' : ''}>ADMIN</option>
                                        <option value="SYSTEM" ${m.role == 'SYSTEM' ? 'selected' : ''}>SYSTEM</option>
                                    </select>
                                    <button class="btn btn-sm btn-outline-primary">변경</button>
                                </form>
                            </td>
                            <td class="pe-4">
                                <form action="${pageContext.request.contextPath}/admin/members/${m.memberId}/delete"
                                      method="post"
                                      onsubmit="return confirm('${m.userId} 회원을 삭제하시겠습니까?')">
                                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                                    <button class="btn btn-sm btn-outline-danger">삭제</button>
                                </form>
                            </td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty members.content}">
                        <tr>
                            <td colspan="7" class="text-center text-muted py-4">회원이 없습니다.</td>
                        </tr>
                    </c:if>
                    </tbody>
                </table>
            </div>
        </div>

        <%-- 페이지네이션 --%>
        <nav class="mt-3">
            <ul class="pagination justify-content-center">
                <c:forEach begin="0" end="${members.totalPages - 1}" var="i">
                    <li class="page-item ${members.number == i ? 'active' : ''}">
                        <a class="page-link" href="?page=${i}">${i + 1}</a>
                    </li>
                </c:forEach>
            </ul>
        </nav>

    </main>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
