<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>회원 관리 · K-Evolution 관리자</title>
    <%@ include file="/WEB-INF/views/layout/meta.jsp" %>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin.css">
</head>
<body class="admin-body">

<%@ include file="/WEB-INF/views/layout/admin-topbar.jsp" %>

<div class="admin-layout">
    <%@ include file="/WEB-INF/views/layout/admin-sidebar.jsp" %>

    <main class="admin-main">

        <div class="mb-4">
            <h4 class="page-title mb-1">회원 관리</h4>
            <p class="text-muted small mb-0">회원 정보를 조회하고 상태를 관리합니다.</p>
        </div>

        <%@ include file="/WEB-INF/views/layout/flash-toast.jsp" %>

        <!-- 탭 -->
        <ul class="nav nav-tabs mb-3" role="tablist">
            <li class="nav-item">
                <a class="nav-link active" data-bs-toggle="tab" href="#userTab" role="tab">USER</a>
            </li>
            <li class="nav-item">
                <a class="nav-link" data-bs-toggle="tab" href="#adminTab" role="tab">ADMIN</a>
            </li>
        </ul>

        <!-- TAB 1: USER -->
        <div class="tab-content">
            <div class="tab-pane fade show active" id="userTab" role="tabpanel">
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
                            </tr>
                            </thead>
                            <tbody>
                            <c:forEach var="m" items="${members.content}">
                                <c:if test="${m.role == 'USER'}">
                                <tr style="cursor:pointer" data-bs-toggle="modal" data-bs-target="#memberModal${m.memberId}">
                                    <td class="ps-4">${m.userId}</td>
                                    <td>${m.name}</td>
                                    <td><span class="badge bg-secondary">USER</span></td>
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
                                </tr>
                                </c:if>
                            </c:forEach>
                            <c:set var="userCount" value="0"/>
                            <c:forEach var="m" items="${members.content}">
                                <c:if test="${m.role == 'USER'}">
                                    <c:set var="userCount" value="${userCount + 1}"/>
                                </c:if>
                            </c:forEach>
                            <c:if test="${userCount == 0}">
                            <tr>
                                <td colspan="5" class="text-center text-muted py-4">USER 회원이 없습니다.</td>
                            </tr>
                            </c:if>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>

            <!-- TAB 2: ADMIN -->
            <div class="tab-pane fade" id="adminTab" role="tabpanel">
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
                            </tr>
                            </thead>
                            <tbody>
                            <c:forEach var="m" items="${members.content}">
                                <c:if test="${m.role == 'ADMIN'}">
                                <tr style="cursor:pointer" data-bs-toggle="modal" data-bs-target="#memberModal${m.memberId}">
                                    <td class="ps-4">${m.userId}</td>
                                    <td>${m.name}</td>
                                    <td><span class="badge bg-danger">ADMIN</span></td>
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
                                </tr>
                                </c:if>
                            </c:forEach>
                            <c:set var="adminCount" value="0"/>
                            <c:forEach var="m" items="${members.content}">
                                <c:if test="${m.role == 'ADMIN'}">
                                    <c:set var="adminCount" value="${adminCount + 1}"/>
                                </c:if>
                            </c:forEach>
                            <c:if test="${adminCount == 0}">
                            <tr>
                                <td colspan="5" class="text-center text-muted py-4">ADMIN 회원이 없습니다.</td>
                            </tr>
                            </c:if>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>

        <%-- 페이지네이션 --%>
        <c:if test="${members.totalPages > 1}">
        <nav class="mt-3">
            <ul class="pagination justify-content-center">
                <c:forEach begin="0" end="${members.totalPages - 1}" var="i">
                    <li class="page-item ${members.number == i ? 'active' : ''}">
                        <a class="page-link" href="?page=${i}">${i + 1}</a>
                    </li>
                </c:forEach>
            </ul>
        </nav>
        </c:if>
        </nav>

    </main>
</div>

<%-- 정보 수정 모달 --%>
<c:forEach var="m" items="${members.content}">
    <div class="modal fade" id="memberModal${m.memberId}" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-lg modal-dialog-centered modal-dialog-scrollable">
            <div class="modal-content">
                <form action="${pageContext.request.contextPath}/admin/members/${m.memberId}/update-info"
                      method="post">
                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                    <div class="modal-header">
                        <h6 class="modal-title fw-bold">${m.userId} · ${m.name}</h6>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="닫기"></button>
                    </div>
                    <div class="modal-body">
                        <div class="mb-3">
                            <label class="form-label small text-muted">이름</label>
                            <input type="text" name="name" class="form-control" required maxlength="50"
                                   value="${m.name}">
                        </div>
                        <div class="mb-3">
                            <label class="form-label small text-muted">휴대폰</label>
                            <input type="tel" name="phone" class="form-control" maxlength="50"
                                   value="${m.phone}">
                        </div>
                        <div class="d-flex gap-4 mb-3">
                            <c:if test="${requesterRole == 'SYSTEM'}">
                            <div style="width:50%;">
                                <label class="form-label small text-muted">권한</label>
                                <div class="d-flex gap-3">
                                    <div class="form-check">
                                        <input class="form-check-input" type="radio" name="role" value="USER"
                                               id="role_user_${m.memberId}" ${m.role == 'USER' ? 'checked' : ''}>
                                        <label class="form-check-label small" for="role_user_${m.memberId}">USER</label>
                                    </div>
                                    <div class="form-check">
                                        <input class="form-check-input" type="radio" name="role" value="ADMIN"
                                               id="role_admin_${m.memberId}" ${m.role == 'ADMIN' ? 'checked' : ''}>
                                        <label class="form-check-label small" for="role_admin_${m.memberId}">ADMIN</label>
                                    </div>
                                    <div class="form-check">
                                        <input class="form-check-input" type="radio" name="role" value="SYSTEM"
                                               id="role_system_${m.memberId}" ${m.role == 'SYSTEM' ? 'checked' : ''}>
                                        <label class="form-check-label small" for="role_system_${m.memberId}">SYSTEM</label>
                                    </div>
                                </div>
                            </div>
                            </c:if>
                            <c:if test="${requesterRole == 'ADMIN'}">
                            <div style="width:50%;">
                                <label class="form-label small text-muted">권한</label>
                                <div class="text-muted small">
                                    <c:choose>
                                        <c:when test="${m.role == 'SYSTEM'}"><span class="badge bg-dark">SYSTEM</span></c:when>
                                        <c:when test="${m.role == 'ADMIN'}"><span class="badge bg-danger">ADMIN</span></c:when>
                                        <c:otherwise><span class="badge bg-secondary">USER</span></c:otherwise>
                                    </c:choose>
                                    <input type="hidden" name="role" value="${m.role}">
                                </div>
                            </div>
                            </c:if>
                            <div style="width:50%;">
                                <label class="form-label small text-muted">상태</label>
                                <div class="d-flex gap-3">
                                    <div class="form-check">
                                        <input class="form-check-input" type="radio" name="status" value="ACTIVE"
                                               id="status_active_${m.memberId}" ${m.status == 'ACTIVE' ? 'checked' : ''}>
                                        <label class="form-check-label small" for="status_active_${m.memberId}">활성</label>
                                    </div>
                                    <div class="form-check">
                                        <input class="form-check-input" type="radio" name="status" value="WITHDRAWN"
                                               id="status_withdrawn_${m.memberId}" ${m.status == 'WITHDRAWN' ? 'checked' : ''}>
                                        <label class="form-check-label small" for="status_withdrawn_${m.memberId}">탈퇴</label>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <c:if test="${requesterRole == 'SYSTEM'}">
                            <form action="${pageContext.request.contextPath}/admin/members/${m.memberId}/delete"
                                  method="post" style="display:inline"
                                  onsubmit="return confirm('${m.userId} 회원을 삭제하시겠습니까?')">
                                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                                <button type="submit" class="btn btn-outline-danger btn-sm">삭제</button>
                            </form>
                        </c:if>
                        <div class="d-flex gap-2">
                            <button type="button" class="btn btn-outline-secondary btn-sm" data-bs-dismiss="modal">취소</button>
                            <button type="submit" class="btn btn-dark btn-sm px-3">수정 완료</button>
                        </div>
                    </div>
                </form>
            </div>
        </div>
    </div>
</c:forEach>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
