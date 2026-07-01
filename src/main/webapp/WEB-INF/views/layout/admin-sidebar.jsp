<%@ page contentType="text/html; charset=UTF-8" %>
<%-- activeMenu 모델 속성으로 현재 메뉴 강조 (dashboard / products / terms / members / qna) --%>
<nav class="admin-sidebar">
    <div class="menu-title">메뉴</div>
    <a class="menu-link ${activeMenu == 'dashboard' ? 'active' : ''}"
       href="${pageContext.request.contextPath}/admin">
        <span><i class="bi bi-speedometer2"></i>대시보드</span>
    </a>
    <a class="menu-link ${activeMenu == 'products' ? 'active' : ''}"
       href="${pageContext.request.contextPath}/admin/products">
        <span><i class="bi bi-box-seam"></i>상품 관리</span>
    </a>
    <a class="menu-link ${activeMenu == 'terms' ? 'active' : ''}"
       href="${pageContext.request.contextPath}/admin/terms">
        <span><i class="bi bi-file-earmark-text"></i>약관 관리</span>
    </a>

    <div class="menu-title">준비 중</div>
    <a class="menu-link" href="#"><span><i class="bi bi-receipt"></i>주문 관리</span><span class="soon">준비중</span></a>
    <a class="menu-link ${activeMenu == 'members' ? 'active' : ''}"
       href="${pageContext.request.contextPath}/admin/members">
        <span><i class="bi bi-people"></i>회원 관리</span>
    </a>
    <a class="menu-link ${activeMenu == 'qna' ? 'active' : ''}"
       href="${pageContext.request.contextPath}/admin/qna">
        <span><i class="bi bi-chat-dots"></i>문의 관리</span>
    </a>
    <a class="menu-link ${activeMenu == 'notice' ? 'active' : ''}"
       href="${pageContext.request.contextPath}/admin/notice">
        <span><i class="bi bi-megaphone"></i>공지 관리</span>
    </a>
    <a class="menu-link ${activeMenu == 'banners' ? 'active' : ''}"
       href="${pageContext.request.contextPath}/admin/banners">
        <span><i class="bi bi-image"></i>배너 관리</span>
    </a>
    <a class="menu-link ${activeMenu == 'events' ? 'active' : ''}"
       href="${pageContext.request.contextPath}/admin/events">
        <span><i class="bi bi-calendar-event"></i>이벤트 관리</span>
    </a>
</nav>
