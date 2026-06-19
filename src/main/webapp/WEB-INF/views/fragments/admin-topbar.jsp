<%@ page contentType="text/html; charset=UTF-8" %>
<div class="admin-topbar">
    <a class="brand" href="${pageContext.request.contextPath}/admin">
        K-Evolution<span class="tag">ADMIN</span>
    </a>
    <div class="topbar-right">
        <a class="btn btn-sm btn-outline-light" href="${pageContext.request.contextPath}/" target="_blank">사이트 보기</a>
        <form action="${pageContext.request.contextPath}/auth/logout" method="post" class="d-inline">
            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
            <button class="btn btn-sm btn-light" type="submit">로그아웃</button>
        </form>
    </div>
</div>
