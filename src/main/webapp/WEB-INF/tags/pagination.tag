<%@ tag pageEncoding="UTF-8" body-content="empty" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%--
  관리자 목록 공통 페이지네이션.
  - page : Spring Data Page 객체 (totalPages/number 사용)
  현재 요청의 모든 쿼리 파라미터를 page 만 제외하고 그대로 유지한다
  (검색어·필터·탭·페이지크기 등 화면별 파라미터를 자동 보존).
--%>
<%@ attribute name="page" required="true" type="org.springframework.data.domain.Page" %>
<c:if test="${page.totalPages > 1}">
    <%-- page 를 제외한 현재 쿼리스트링 재구성 --%>
    <c:set var="qs" value=""/>
    <c:forEach var="e" items="${paramValues}">
        <c:if test="${e.key ne 'page'}">
            <c:forEach var="v" items="${e.value}">
                <c:set var="qs" value="${qs}&${e.key}=${v}"/>
            </c:forEach>
        </c:if>
    </c:forEach>
    <nav class="mt-3">
        <ul class="pagination justify-content-center mb-0">
            <c:forEach begin="0" end="${page.totalPages - 1}" var="i">
                <li class="page-item ${page.number == i ? 'active' : ''}">
                    <a class="page-link" href="?page=${i}${qs}">${i + 1}</a>
                </li>
            </c:forEach>
        </ul>
    </nav>
</c:if>
