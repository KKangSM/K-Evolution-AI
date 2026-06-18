<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>회원 관리 - K-Evolution</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
</head>
<body>
<%@ include file="../fragments/header.jsp" %>

<div class="container mt-4">
    <h4 class="mb-4">회원 관리</h4>

    <c:if test="${not empty successMsg}">
        <div class="alert alert-success">${successMsg}</div>
    </c:if>
    <c:if test="${not empty errorMsg}">
        <div class="alert alert-danger">${errorMsg}</div>
    </c:if>

    <table class="table table-bordered table-hover align-middle">
        <thead class="table-dark">
        <tr>
            <th>아이디</th>
            <th>이름</th>
            <th>권한</th>
            <th>상태</th>
            <th>가입일</th>
            <th>권한 변경</th>
        </tr>
        </thead>
        <tbody>
        <c:forEach var="m" items="${members.content}">
            <tr>
                <td>${m.userId}</td>
                <td>${m.name}</td>
                <td>
                    <span class="badge ${m.role == 'ADMIN' ? 'bg-danger' : 'bg-secondary'}">
                        ${m.role}
                    </span>
                </td>
                <td>
                    <span class="badge ${m.status == 'ACTIVE' ? 'bg-success' : 'bg-dark'}">
                        ${m.status}
                    </span>
                </td>
                <td>${m.createdAt.toString().substring(0, 10)}</td>
                <td>
                    <form action="${pageContext.request.contextPath}/admin/members/${m.memberId}/role"
                          method="post" class="d-flex gap-2">
                        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                        <select name="role" class="form-select form-select-sm" style="width:120px">
                            <option value="USER"  ${m.role == 'USER'  ? 'selected' : ''}>USER</option>
                            <option value="ADMIN" ${m.role == 'ADMIN' ? 'selected' : ''}>ADMIN</option>
                        </select>
                        <button class="btn btn-sm btn-primary">변경</button>
                    </form>
                </td>
            </tr>
        </c:forEach>
        </tbody>
    </table>

    <%-- 페이지네이션 --%>
    <nav>
        <ul class="pagination justify-content-center">
            <c:forEach begin="0" end="${members.totalPages - 1}" var="i">
                <li class="page-item ${members.number == i ? 'active' : ''}">
                    <a class="page-link" href="?page=${i}">${i + 1}</a>
                </li>
            </c:forEach>
        </ul>
    </nav>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
