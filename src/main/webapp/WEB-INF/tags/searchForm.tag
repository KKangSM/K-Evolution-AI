<%@ tag pageEncoding="UTF-8" body-content="scriptless" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%--
  관리자 목록 공통 검색폼 골격.
  - placeholder : 검색창 안내 문구
  - resetUrl    : 초기화 버튼 이동 경로 (현재 탭 유지가 필요하면 호출 측에서 쿼리 포함)
  - 본문(doBody): 필터 select, 탭/페이지크기 유지용 hidden input 등 화면별 가변 영역
--%>
<%@ attribute name="placeholder" required="true" %>
<%@ attribute name="resetUrl" required="true" %>
<form method="get" class="card shadow-sm mb-3">
    <div class="card-body p-3">
        <div class="row gx-2 align-items-center">
            <jsp:doBody/>
            <div class="col">
                <input type="text" name="search" class="form-control form-control-sm"
                       placeholder="${placeholder}" value="${param.search}">
            </div>
            <div class="col-auto">
                <button type="submit" class="btn btn-primary btn-sm">검색</button>
                <a href="${resetUrl}" class="btn btn-outline-secondary btn-sm">초기화</a>
            </div>
        </div>
    </div>
</form>
