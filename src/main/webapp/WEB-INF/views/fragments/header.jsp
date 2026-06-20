<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<nav class="navbar navbar-expand-lg navbar-dark bg-dark">
    <div class="container">
        <a class="navbar-brand fw-bold" href="${pageContext.request.contextPath}/">K-Evolution</a>
        <div class="navbar-nav ms-auto align-items-center">
            <a class="nav-link" href="${pageContext.request.contextPath}/support">고객센터</a>
            <sec:authorize access="isAuthenticated()">
                <a class="nav-link" href="${pageContext.request.contextPath}/cart">장바구니</a>
                <a class="nav-link" href="${pageContext.request.contextPath}/mypage">마이페이지</a>
            </sec:authorize>
            <sec:authorize access="hasAnyRole('ROLE_ADMIN','ROLE_SYSTEM')">
                <a class="nav-link" href="${pageContext.request.contextPath}/admin">관리자</a>
            </sec:authorize>
            <sec:authorize access="isAnonymous()">
                <a class="nav-link" href="${pageContext.request.contextPath}/auth/login">로그인</a>
                <a class="nav-link" href="${pageContext.request.contextPath}/auth/signup">회원가입</a>
            </sec:authorize>
            <sec:authorize access="isAuthenticated()">
                <form action="${pageContext.request.contextPath}/auth/logout" method="post" class="d-inline ms-2">
                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                    <button class="btn btn-sm btn-outline-light" type="submit">로그아웃</button>
                </form>
            </sec:authorize>
        </div>
    </div>
</nav>
