<%@ page contentType="text/html; charset=UTF-8" %>
<%-- activeMenu 모델 속성으로 현재 메뉴 강조 (dashboard / products) --%>
<nav class="admin-sidebar">
    <div class="menu-title">메뉴</div>
    <a class="menu-link ${activeMenu == 'dashboard' ? 'active' : ''}"
       href="${pageContext.request.contextPath}/admin">
        <span>📊 대시보드</span>
    </a>
    <a class="menu-link ${activeMenu == 'products' ? 'active' : ''}"
       href="${pageContext.request.contextPath}/admin/products">
        <span>📦 상품 관리</span>
    </a>
    <a class="menu-link ${activeMenu == 'terms' ? 'active' : ''}"
       href="${pageContext.request.contextPath}/admin/terms">
        <span>📋 약관 관리</span>
    </a>

    <div class="menu-title">준비 중</div>
    <a class="menu-link" href="#"><span>🧾 주문 관리</span><span class="soon">준비중</span></a>
    <a class="menu-link ${activeMenu == 'members' ? 'active' : ''}"
       href="${pageContext.request.contextPath}/admin/members">
        <span>👥 회원 관리</span>
    </a>
    <a class="menu-link" href="#"><span>💬 문의 관리</span><span class="soon">준비중</span></a>
    <a class="menu-link" href="#"><span>📢 공지 관리</span><span class="soon">준비중</span></a>
    <a class="menu-link" href="#"><span>🖼️ 배너 관리</span><span class="soon">준비중</span></a>
</nav>
