<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="ui" tagdir="/WEB-INF/tags" %>
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

        <div class="mb-3">
            <h4 class="page-title mb-1">회원 관리</h4>
        </div>

        <%@ include file="/WEB-INF/views/layout/flash-toast.jsp" %>

        <!-- 검색 폼 (필터 → 검색창 → 검색 → 초기화) -->
        <ui:searchForm placeholder="아이디, 이름 검색"
                       resetUrl="${pageContext.request.contextPath}/admin/members?role=${filterRole}">
            <%-- 현재 탭(권한)·페이지 크기 유지 --%>
            <input type="hidden" name="role" value="${filterRole}">
            <input type="hidden" name="pageSize" value="${empty param.pageSize ? '20' : param.pageSize}">
            <div class="col-md-2">
                <select name="status" class="form-select form-select-sm">
                    <option value="">상태 전체</option>
                    <option value="ACTIVE" ${filterStatus == 'ACTIVE' ? 'selected' : ''}>활성</option>
                    <option value="WITHDRAWN" ${filterStatus == 'WITHDRAWN' ? 'selected' : ''}>탈퇴</option>
                </select>
            </div>
        </ui:searchForm>

        <!-- 권한 탭 + 페이지당 표시 -->
        <div class="d-flex justify-content-between align-items-end mb-2">
            <ul class="nav nav-tabs mb-0" role="tablist" style="border-bottom:0">
                <li class="nav-item">
                    <a class="nav-link ${filterRole == 'USER' ? 'active' : ''}" href="?role=USER">USER</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link ${filterRole == 'ADMIN' ? 'active' : ''}" href="?role=ADMIN">ADMIN</a>
                </li>
                <c:if test="${requesterRole == 'SYSTEM'}">
                <li class="nav-item">
                    <a class="nav-link ${filterRole == 'SYSTEM' ? 'active' : ''}" href="?role=SYSTEM">SYSTEM</a>
                </li>
                </c:if>
            </ul>
            <select name="pageSize" class="form-select form-select-sm" style="width:90px" onchange="changePageSize(this)">
                <option value="20" ${empty param.pageSize || param.pageSize == '20' ? 'selected' : ''}>20개</option>
                <option value="50" ${param.pageSize == '50' ? 'selected' : ''}>50개</option>
                <option value="100" ${param.pageSize == '100' ? 'selected' : ''}>100개</option>
            </select>
        </div>

        <!-- 테이블 -->
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
                        <tr style="cursor:pointer" data-bs-toggle="modal" data-bs-target="#memberModal${m.memberId}">
                            <td class="ps-4">${m.userId}</td>
                            <td>${m.name}</td>
                            <td>
                                <c:choose>
                                    <c:when test="${m.role == 'SYSTEM'}"><span class="badge bg-dark">SYSTEM</span></c:when>
                                    <c:when test="${m.role == 'ADMIN'}"><span class="badge bg-danger">ADMIN</span></c:when>
                                    <c:otherwise><span class="badge bg-secondary">USER</span></c:otherwise>
                                </c:choose>
                            </td>
                            <td>
                                <c:choose>
                                    <c:when test="${m.status == 'ACTIVE'}"><span class="badge bg-success">활성</span></c:when>
                                    <c:otherwise><span class="badge bg-dark">탈퇴</span></c:otherwise>
                                </c:choose>
                            </td>
                            <td class="text-muted small">${m.createdAt.toString().substring(0, 10)}</td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty members.content}">
                    <tr>
                        <td colspan="5" class="text-center text-muted py-4">해당 회원이 없습니다.</td>
                    </tr>
                    </c:if>
                    </tbody>
                </table>
            </div>
        </div>

        <!-- 페이지네이션 -->
        <ui:pagination page="${members}"/>

    </main>
</div>

<%-- 정보 수정 모달 --%>
<c:forEach var="m" items="${members.content}">
    <div class="modal fade" id="memberModal${m.memberId}" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content">
                <form action="${pageContext.request.contextPath}/admin/members/${m.memberId}/update-info"
                      method="post">
                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                    <div class="modal-header">
                        <h6 class="modal-title fw-bold">${m.userId}</h6>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="닫기"></button>
                    </div>
                    <div class="modal-body">
                        <div class="mb-2">
                            <label class="form-label small text-muted">이름</label>
                            <input type="text" name="name" class="form-control form-control-sm" required maxlength="50"
                                   value="${m.name}">
                        </div>
                        <div class="mb-2">
                            <label class="form-label small text-muted">휴대폰</label>
                            <input type="tel" name="phone" class="form-control form-control-sm" maxlength="50"
                                   value="${m.phone}">
                        </div>
                        <div class="row gx-2 mb-2">
                            <c:if test="${requesterRole == 'SYSTEM'}">
                            <div class="col">
                                <label class="form-label small text-muted">권한</label>
                                <div class="d-flex gap-2">
                                    <div class="form-check form-check-sm">
                                        <input class="form-check-input" type="radio" name="role" value="USER"
                                               id="role_user_${m.memberId}" ${m.role == 'USER' ? 'checked' : ''}>
                                        <label class="form-check-label small" for="role_user_${m.memberId}">USER</label>
                                    </div>
                                    <div class="form-check form-check-sm">
                                        <input class="form-check-input" type="radio" name="role" value="ADMIN"
                                               id="role_admin_${m.memberId}" ${m.role == 'ADMIN' ? 'checked' : ''}>
                                        <label class="form-check-label small" for="role_admin_${m.memberId}">ADMIN</label>
                                    </div>
                                    <div class="form-check form-check-sm">
                                        <input class="form-check-input" type="radio" name="role" value="SYSTEM"
                                               id="role_system_${m.memberId}" ${m.role == 'SYSTEM' ? 'checked' : ''}>
                                        <label class="form-check-label small" for="role_system_${m.memberId}">SYSTEM</label>
                                    </div>
                                </div>
                            </div>
                            </c:if>
                            <c:if test="${requesterRole == 'ADMIN'}">
                            <div class="col">
                                <label class="form-label small text-muted">권한</label>
                                <div class="small text-muted">
                                    <c:choose>
                                        <c:when test="${m.role == 'SYSTEM'}"><span class="badge bg-dark">SYSTEM</span></c:when>
                                        <c:when test="${m.role == 'ADMIN'}"><span class="badge bg-danger">ADMIN</span></c:when>
                                        <c:otherwise><span class="badge bg-secondary">USER</span></c:otherwise>
                                    </c:choose>
                                    <input type="hidden" name="role" value="${m.role}">
                                </div>
                            </div>
                            </c:if>
                            <div class="col">
                                <label class="form-label small text-muted">상태</label>
                                <div class="d-flex gap-2">
                                    <div class="form-check form-check-sm">
                                        <input class="form-check-input" type="radio" name="status" value="ACTIVE"
                                               id="status_active_${m.memberId}" ${m.status == 'ACTIVE' ? 'checked' : ''}>
                                        <label class="form-check-label small" for="status_active_${m.memberId}">활성</label>
                                    </div>
                                    <div class="form-check form-check-sm">
                                        <input class="form-check-input" type="radio" name="status" value="WITHDRAWN"
                                               id="status_withdrawn_${m.memberId}" ${m.status == 'WITHDRAWN' ? 'checked' : ''}>
                                        <label class="form-check-label small" for="status_withdrawn_${m.memberId}">탈퇴</label>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="modal-footer gap-2">
                        <c:if test="${requesterRole == 'SYSTEM'}">
                            <form action="${pageContext.request.contextPath}/admin/members/${m.memberId}/delete"
                                  method="post" style="display:inline"
                                  onsubmit="return confirm('${m.userId} 회원을 삭제하시겠습니까?')">
                                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                                <button type="submit" class="btn btn-outline-danger btn-sm">삭제</button>
                            </form>
                        </c:if>
                        <button type="button" class="btn btn-outline-secondary btn-sm" data-bs-dismiss="modal">취소</button>
                        <button type="submit" class="btn btn-dark btn-sm">수정</button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</c:forEach>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
function changePageSize(select) {
    const pageSize = select.value;
    const url = new URL(window.location);
    url.searchParams.set('pageSize', pageSize);
    url.searchParams.set('page', '0');
    window.location = url.toString();
}
</script>
</body>
</html>
