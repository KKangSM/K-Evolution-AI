<%@ tag pageEncoding="UTF-8" body-content="empty" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%--
  관리자 목록 공통 "페이지당 표시 개수" 셀렉트 (20 / 50 / 100).
  - 현재 pageSize 파라미터를 선택 상태로 반영 (기본 20).
  - 변경 시 pageSize 적용 + page=0 으로 이동하며, 그 외 쿼리 파라미터(검색어·필터·탭)는 유지.
  - 배치: 테이블 상단 우측. 탭이 있는 화면은 감싸는 flex 컨테이너에서 함께 정렬한다.
  - 검색 폼 제출 시 값 유지가 필요하면 검색 폼 안에 hidden(name="pageSize")을 함께 둔다.
--%>
<select name="pageSize" class="form-select form-select-sm" style="width:90px" onchange="kevChangePageSize(this)">
    <option value="20" ${empty param.pageSize || param.pageSize == '20' ? 'selected' : ''}>20개</option>
    <option value="50" ${param.pageSize == '50' ? 'selected' : ''}>50개</option>
    <option value="100" ${param.pageSize == '100' ? 'selected' : ''}>100개</option>
</select>
<script>
    if (typeof window.kevChangePageSize !== 'function') {
        window.kevChangePageSize = function (select) {
            const url = new URL(window.location);
            url.searchParams.set('pageSize', select.value);
            url.searchParams.set('page', '0');
            window.location = url.toString();
        };
    }
</script>
