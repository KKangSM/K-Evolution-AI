<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%-- 공통 플래시 토스트: successMsg / errorMsg 가 있으면 상단 중앙에 잠시 떠서 사라진다.
     레이아웃을 밀지 않도록 position-fixed. Bootstrap JS 로드 이후 동작하도록 DOMContentLoaded 로 지연. --%>
<c:if test="${not empty successMsg or not empty errorMsg}">
    <div class="toast-container position-fixed start-50 translate-middle-x p-3" style="top:84px; z-index:1090">
        <div id="flashToast" class="toast align-items-center border-0 shadow ${not empty errorMsg ? 'text-bg-danger' : 'text-bg-dark'}"
             role="alert" aria-live="assertive" aria-atomic="true">
            <div class="d-flex">
                <div class="toast-body d-flex align-items-center gap-2">
                    <i class="bi ${not empty errorMsg ? 'bi-exclamation-circle' : 'bi-check-circle'}"></i>
                    <span>${not empty errorMsg ? errorMsg : successMsg}</span>
                </div>
                <button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast" aria-label="닫기"></button>
            </div>
        </div>
    </div>
    <script>
        document.addEventListener('DOMContentLoaded', function () {
            var t = document.getElementById('flashToast');
            if (t && window.bootstrap) new bootstrap.Toast(t, { delay: 2500 }).show();
        });
    </script>
</c:if>
