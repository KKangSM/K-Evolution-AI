<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<nav class="navbar navbar-expand-lg site-navbar sticky-top">
    <div class="container">
        <a class="navbar-brand" href="${pageContext.request.contextPath}/">K-Evolution</a>

        <button class="navbar-toggler border-0" type="button" data-bs-toggle="collapse"
                data-bs-target="#kvNav" aria-controls="kvNav" aria-expanded="false" aria-label="메뉴 열기">
            <i class="bi bi-list fs-3"></i>
        </button>

        <div class="collapse navbar-collapse" id="kvNav">
            <%-- 모바일 카테고리 (PC 는 아래 카테고리 바로 노출) --%>
            <div class="d-lg-none py-2 border-bottom mb-2">
                <a class="header-cat-link d-block py-1" href="${pageContext.request.contextPath}/products">전체 상품</a>
                <c:forEach var="cat" items="${globalCategories}">
                    <a class="header-cat-link d-block py-1"
                       href="${pageContext.request.contextPath}/products?categoryId=${cat.categoryId}">
                        ${cat.name}
                    </a>
                </c:forEach>
            </div>
            <div class="navbar-nav ms-auto align-items-lg-center">
                <%-- 고객센터: ADMIN 만 숨김. 비로그인·일반회원·SYSTEM(마스터)에게 노출 --%>
                <sec:authorize access="!hasRole('ROLE_ADMIN') or hasRole('ROLE_SYSTEM')">
                    <a class="nav-link" href="${pageContext.request.contextPath}/support">
                        <i class="bi bi-headset"></i> 고객센터
                    </a>
                </sec:authorize>
                <%-- user 메뉴: ADMIN 만 숨김. 일반회원·SYSTEM(마스터)에게 노출 --%>
                <sec:authorize access="isAuthenticated() and (!hasRole('ROLE_ADMIN') or hasRole('ROLE_SYSTEM'))">
                    <a class="nav-link" href="${pageContext.request.contextPath}/cart">
                        <i class="bi bi-cart"></i> 장바구니
                    </a>
                    <a class="nav-link" href="${pageContext.request.contextPath}/mypage">
                        <i class="bi bi-person"></i> 마이페이지
                    </a>
                </sec:authorize>
                <%-- 관리자/시스템에게만 노출 --%>
                <sec:authorize access="hasAnyRole('ROLE_ADMIN','ROLE_SYSTEM')">
                    <a class="nav-link" href="${pageContext.request.contextPath}/admin">
                        <i class="bi bi-gear"></i> 관리자
                    </a>
                </sec:authorize>
                <sec:authorize access="isAnonymous()">
                    <a class="nav-link" href="${pageContext.request.contextPath}/auth/login">로그인</a>
                    <a class="btn btn-dark btn-sm ms-lg-2 px-3" href="${pageContext.request.contextPath}/auth/signup">회원가입</a>
                </sec:authorize>
                <sec:authorize access="isAuthenticated()">
                    <form action="${pageContext.request.contextPath}/auth/logout" method="post" class="d-inline ms-lg-2 mt-2 mt-lg-0">
                        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                        <button class="btn btn-outline-secondary btn-sm px-3" type="submit">로그아웃</button>
                    </form>
                </sec:authorize>
            </div>
        </div>
    </div>
</nav>
