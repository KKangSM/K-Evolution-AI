<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>문의 관리 · K-Evolution 관리자</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin.css">
</head>
<body class="admin-body">

<%@ include file="/WEB-INF/views/fragments/admin-topbar.jsp" %>

<div class="admin-layout">
    <%@ include file="/WEB-INF/views/fragments/admin-sidebar.jsp" %>

    <main class="admin-main">

        <div class="mb-4">
            <h4 class="page-title mb-1">문의 관리</h4>
            <p class="text-muted small mb-0">전체 문의 목록을 조회하고 답변을 처리합니다.</p>
        </div>

        <c:if test="${not empty successMsg}">
            <div class="alert alert-success py-2 small">${successMsg}</div>
        </c:if>

        <div class="card shadow-sm">
            <div class="card-body p-0">
                <table class="table table-hover mb-0 align-middle">
                    <thead class="table-light">
                    <tr>
                        <th class="ps-4" style="width:60px">No</th>
                        <th>제목</th>
                        <th style="width:100px">작성자</th>
                        <th style="width:80px">비밀글</th>
                        <th style="width:90px">상태</th>
                        <th style="width:110px">작성일</th>
                        <th style="width:80px"></th>
                    </tr>
                    </thead>
                    <tbody>
                    <c:forEach var="q" items="${qnaList.content}">
                        <tr>
                            <td class="ps-4 text-muted small">${q.qnaId}</td>
                            <td>
                                <a href="${pageContext.request.contextPath}/admin/qna/${q.qnaId}"
                                   class="text-decoration-none text-dark">${q.title}</a>
                            </td>
                            <td class="small">${q.member.userId}</td>
                            <td>
                                <c:if test="${q.secret}">
                                    <span class="badge bg-secondary">비밀</span>
                                </c:if>
                            </td>
                            <td>
                                <c:choose>
                                    <c:when test="${q.answered}">
                                        <span class="badge bg-success">답변완료</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="badge bg-warning text-dark">미답변</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td class="text-muted small">${q.createdAt.toString().substring(0, 10)}</td>
                            <td class="pe-4">
                                <form action="${pageContext.request.contextPath}/admin/qna/${q.qnaId}/delete"
                                      method="post"
                                      onsubmit="return confirm('삭제하시겠습니까?')">
                                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                                    <button class="btn btn-sm btn-outline-danger">삭제</button>
                                </form>
                            </td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty qnaList.content}">
                        <tr>
                            <td colspan="7" class="text-center text-muted py-4">등록된 문의가 없습니다.</td>
                        </tr>
                    </c:if>
                    </tbody>
                </table>
            </div>
        </div>

        <nav class="mt-3">
            <ul class="pagination justify-content-center">
                <c:forEach begin="0" end="${qnaList.totalPages - 1}" var="i">
                    <li class="page-item ${qnaList.number == i ? 'active' : ''}">
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
