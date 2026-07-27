<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>쿠폰 관리 · K-Evolution 관리자</title>
    <%@ include file="/WEB-INF/views/layout/meta.jsp" %>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin.css">
</head>
<body class="admin-body">

<%@ include file="/WEB-INF/views/layout/admin-topbar.jsp" %>

<div class="admin-layout">
    <%@ include file="/WEB-INF/views/layout/admin-sidebar.jsp" %>

    <main class="admin-main">

        <div class="d-flex justify-content-between align-items-center mb-3">
            <h4 class="page-title mb-1">쿠폰 관리</h4>
            <button type="button" class="btn btn-dark btn-sm px-3"
                    data-bs-toggle="modal" data-bs-target="#createModal">
                <i class="bi bi-ticket-perforated"></i> 쿠폰 만들기
            </button>
        </div>

        <%@ include file="/WEB-INF/views/layout/flash-toast.jsp" %>

        <div class="card shadow-sm">
            <div class="card-body p-0">
                <table class="table table-hover mb-0 align-middle">
                    <thead class="table-light">
                    <tr>
                        <th class="ps-4">쿠폰 이름</th>
                        <th style="width:120px">할인</th>
                        <th style="width:130px">최소 주문금액</th>
                        <th style="width:150px">만료일</th>
                        <th style="width:90px">발급 수</th>
                        <th style="width:170px" class="text-end pe-4">관리</th>
                    </tr>
                    </thead>
                    <tbody>
                    <c:forEach var="cp" items="${coupons}">
                        <tr>
                            <td class="ps-4 fw-medium text-dark"><c:out value="${cp.name}"/></td>
                            <td>
                                <c:choose>
                                    <c:when test="${cp.discountType == 'PERCENT'}">
                                        <span class="badge bg-primary">${cp.discountValue}% 할인</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="badge bg-success">
                                            <fmt:formatNumber value="${cp.discountValue}" type="number"/>원 할인
                                        </span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td class="small text-muted">
                                <c:choose>
                                    <c:when test="${empty cp.minOrderAmount}">-</c:when>
                                    <c:otherwise><fmt:formatNumber value="${cp.minOrderAmount}" type="number"/>원 이상</c:otherwise>
                                </c:choose>
                            </td>
                            <td class="small text-muted">
                                <c:choose>
                                    <c:when test="${empty cp.expiredAt}"><span class="text-secondary">무제한</span></c:when>
                                    <c:otherwise>${cp.expiredAt.toString().substring(0, 16).replace('T', ' ')}</c:otherwise>
                                </c:choose>
                            </td>
                            <td class="small">
                                <span class="fw-semibold">${issuedCounts[cp.couponId]}</span>명
                            </td>
                            <td class="text-end pe-4">
                                <button type="button" class="btn btn-sm btn-outline-primary"
                                        data-bs-toggle="modal" data-bs-target="#issueModal${cp.couponId}">
                                    발급
                                </button>
                                <button type="button" class="btn btn-sm btn-outline-danger"
                                        onclick="submitDelete(${cp.couponId})">삭제</button>
                                <form id="deleteForm${cp.couponId}"
                                      action="${pageContext.request.contextPath}/admin/coupons/${cp.couponId}/delete"
                                      method="post" style="display:none">
                                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                                </form>
                            </td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty coupons}">
                        <tr>
                            <td colspan="6" class="text-center text-muted py-4">등록된 쿠폰이 없습니다.</td>
                        </tr>
                    </c:if>
                    </tbody>
                </table>
            </div>
        </div>

    </main>
</div>

<%-- 쿠폰 생성 모달 --%>
<div class="modal fade" id="createModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <form action="${pageContext.request.contextPath}/admin/coupons/create" method="post">
                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                <div class="modal-header">
                    <h6 class="modal-title fw-bold">쿠폰 만들기</h6>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="닫기"></button>
                </div>
                <div class="modal-body">
                    <div class="mb-3">
                        <label class="form-label small text-muted">쿠폰 이름</label>
                        <input type="text" name="name" class="form-control" required maxlength="100"
                               placeholder="예) 신규가입 5,000원 할인">
                    </div>
                    <div class="row g-2 mb-3">
                        <div class="col-5">
                            <label class="form-label small text-muted">할인 유형</label>
                            <select name="discountType" id="discountType" class="form-select">
                                <option value="FIXED">정액(원)</option>
                                <option value="PERCENT">정률(%)</option>
                            </select>
                        </div>
                        <div class="col-7">
                            <label class="form-label small text-muted">할인 값</label>
                            <div class="input-group">
                                <input type="number" name="discountValue" class="form-control" required min="1"
                                       placeholder="예) 5000">
                                <span class="input-group-text" id="valueUnit">원</span>
                            </div>
                        </div>
                    </div>
                    <div class="mb-3">
                        <label class="form-label small text-muted">최소 주문금액 <span class="text-muted">(선택)</span></label>
                        <div class="input-group">
                            <input type="number" name="minOrderAmount" class="form-control" min="0"
                                   placeholder="비워두면 제한 없음">
                            <span class="input-group-text">원 이상</span>
                        </div>
                    </div>
                    <div class="mb-2">
                        <label class="form-label small text-muted">만료일 <span class="text-muted">(선택)</span></label>
                        <input type="datetime-local" name="expiredAt" class="form-control">
                        <div class="form-text">비워두면 무제한 유효합니다.</div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-outline-secondary btn-sm" data-bs-dismiss="modal">취소</button>
                    <button type="submit" class="btn btn-dark btn-sm px-3">생성</button>
                </div>
            </form>
        </div>
    </div>
</div>

<%-- 쿠폰별 발급 모달 --%>
<c:forEach var="cp" items="${coupons}">
    <div class="modal fade" id="issueModal${cp.couponId}" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content">
                <form action="${pageContext.request.contextPath}/admin/coupons/${cp.couponId}/issue" method="post">
                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                    <div class="modal-header">
                        <h6 class="modal-title fw-bold">쿠폰 발급 — <c:out value="${cp.name}"/></h6>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="닫기"></button>
                    </div>
                    <div class="modal-body">
                        <div class="form-check mb-2">
                            <input class="form-check-input issue-target" type="radio" name="target" value="member"
                                   id="targetMember${cp.couponId}" data-coupon="${cp.couponId}" checked>
                            <label class="form-check-label" for="targetMember${cp.couponId}">특정 회원에게 발급</label>
                        </div>
                        <div class="mb-3 ps-4" id="userIdBox${cp.couponId}">
                            <input type="text" name="userId" class="form-control form-control-sm"
                                   placeholder="회원 아이디 입력">
                        </div>
                        <div class="form-check">
                            <input class="form-check-input issue-target" type="radio" name="target" value="all"
                                   id="targetAll${cp.couponId}" data-coupon="${cp.couponId}">
                            <label class="form-check-label" for="targetAll${cp.couponId}">
                                전체 회원에게 발급 <span class="text-muted small">(활성 상태의 일반회원)</span>
                            </label>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-outline-secondary btn-sm" data-bs-dismiss="modal">취소</button>
                        <button type="submit" class="btn btn-dark btn-sm px-3">발급하기</button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</c:forEach>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    function submitDelete(couponId) {
        if (confirm('쿠폰을 삭제하시겠습니까?')) {
            document.getElementById('deleteForm' + couponId).submit();
        }
    }

    // 생성 모달: 할인 유형에 따라 단위(원/%) 표시 전환
    (function () {
        var type = document.getElementById('discountType');
        var unit = document.getElementById('valueUnit');
        if (type && unit) {
            type.addEventListener('change', function () {
                unit.textContent = type.value === 'PERCENT' ? '%' : '원';
            });
        }
    })();

    // 발급 모달: 대상 선택에 따라 아이디 입력칸 표시/숨김
    document.querySelectorAll('.issue-target').forEach(function (radio) {
        radio.addEventListener('change', function () {
            var box = document.getElementById('userIdBox' + this.dataset.coupon);
            if (box) box.style.display = (this.value === 'member') ? '' : 'none';
        });
    });
</script>
</body>
</html>
