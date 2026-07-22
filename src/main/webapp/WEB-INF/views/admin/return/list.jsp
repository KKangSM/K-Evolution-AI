<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>반품·교환 관리 · K-Evolution 관리자</title>
    <%@ include file="/WEB-INF/views/layout/meta.jsp" %>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin.css">
</head>
<body class="admin-body">

<%@ include file="/WEB-INF/views/layout/admin-topbar.jsp" %>

<div class="admin-layout">
    <%@ include file="/WEB-INF/views/layout/admin-sidebar.jsp" %>

    <main class="admin-main">

        <div class="d-flex justify-content-between align-items-center mb-3">
            <h4 class="page-title mb-1">반품·교환 관리</h4>
        </div>

        <%@ include file="/WEB-INF/views/layout/flash-toast.jsp" %>

        <div class="card shadow-sm">
            <div class="table-responsive">
                <table class="table table-hover align-middle mb-0">
                    <thead class="table-light">
                    <tr>
                        <th>신청일</th>
                        <th>회원</th>
                        <th>상품</th>
                        <th>유형</th>
                        <th>사유</th>
                        <th>상태</th>
                        <th class="text-end">처리</th>
                    </tr>
                    </thead>
                    <tbody>
                    <c:forEach var="r" items="${returns}">
                        <tr>
                            <td class="small text-muted">${r.createdAt}</td>
                            <td class="small">${r.member.name}<br><span class="text-muted">${r.member.userId}</span></td>
                            <td class="small">${r.orderItem.productName}</td>
                            <td>
                                <span class="badge ${r.type == 'RETURN' ? 'bg-dark' : 'bg-info text-dark'}">
                                    ${r.type == 'RETURN' ? '반품' : '교환'}
                                </span>
                            </td>
                            <td class="small" style="max-width:220px">${r.reason}</td>
                            <td>
                                <c:choose>
                                    <c:when test="${r.status == 'REQUESTED'}"><span class="badge bg-secondary">접수</span></c:when>
                                    <c:when test="${r.status == 'APPROVED'}"><span class="badge bg-primary">승인</span></c:when>
                                    <c:when test="${r.status == 'REJECTED'}"><span class="badge bg-danger">거절</span></c:when>
                                    <c:otherwise><span class="badge bg-success">완료</span></c:otherwise>
                                </c:choose>
                            </td>
                            <td class="text-end">
                                <div class="d-inline-flex gap-1">
                                    <c:if test="${r.status == 'REQUESTED'}">
                                        <form action="${pageContext.request.contextPath}/admin/returns/${r.returnId}/approve" method="post">
                                            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                                            <button class="btn btn-sm btn-outline-primary">승인</button>
                                        </form>
                                        <form action="${pageContext.request.contextPath}/admin/returns/${r.returnId}/reject" method="post">
                                            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                                            <button class="btn btn-sm btn-outline-danger">거절</button>
                                        </form>
                                    </c:if>
                                    <c:if test="${r.status == 'APPROVED'}">
                                        <form action="${pageContext.request.contextPath}/admin/returns/${r.returnId}/complete" method="post">
                                            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                                            <button class="btn btn-sm btn-outline-success">완료</button>
                                        </form>
                                    </c:if>
                                </div>
                            </td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty returns}">
                        <tr><td colspan="7" class="text-center text-muted py-4">반품·교환 신청이 없습니다.</td></tr>
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
