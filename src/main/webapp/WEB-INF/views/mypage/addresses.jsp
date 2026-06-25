<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>배송지 관리 - K-Evolution</title>
    <%@ include file="/WEB-INF/views/layout/meta.jsp" %>
</head>
<body class="bg-light">
<%@ include file="/WEB-INF/views/layout/header.jsp" %>

<div class="container py-5" style="max-width:640px">
    <a href="${pageContext.request.contextPath}/mypage" class="back-link"><i class="bi bi-chevron-left"></i>마이페이지</a>
    <h5 class="fw-bold mt-2 mb-4">배송지 관리</h5>

    <%@ include file="/WEB-INF/views/layout/flash-toast.jsp" %>

    <!-- 배송지 목록 -->
    <c:forEach var="a" items="${addresses}">
        <div class="card shadow-sm mb-3">
            <div class="card-body">
                <div class="d-flex justify-content-between align-items-start">
                    <div>
                        <span class="fw-bold">${a.recipient}</span>
                        <c:if test="${a.defaultAddress}">
                            <span class="badge bg-dark ms-2">기본</span>
                        </c:if>
                        <div class="text-muted small mt-1">${a.phone}</div>
                        <div class="small">[${a.zipcode}] ${a.address} ${a.addressDetail}</div>
                    </div>
                    <div class="d-flex gap-2">
                        <c:if test="${!a.defaultAddress}">
                            <form action="${pageContext.request.contextPath}/mypage/addresses/${a.addressId}/default"
                                  method="post">
                                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                                <button class="btn btn-sm btn-outline-secondary">기본 설정</button>
                            </form>
                        </c:if>
                        <form action="${pageContext.request.contextPath}/mypage/addresses/${a.addressId}/delete"
                              method="post" onsubmit="return confirm('삭제하시겠습니까?')">
                            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                            <button class="btn btn-sm btn-outline-danger">삭제</button>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </c:forEach>

    <c:if test="${empty addresses}">
        <div class="text-center text-muted py-4">등록된 배송지가 없습니다.</div>
    </c:if>

    <!-- 배송지 추가 폼 -->
    <div class="card shadow-sm mt-4">
        <div class="card-header fw-bold">배송지 추가</div>
        <div class="card-body">
            <form action="${pageContext.request.contextPath}/mypage/addresses/add" method="post">
                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                <div class="row g-2 mb-2">
                    <div class="col-6">
                        <input type="text" name="recipient" class="form-control form-control-sm"
                               placeholder="받는 사람" required>
                    </div>
                    <div class="col-6">
                        <input type="text" name="phone" class="form-control form-control-sm"
                               placeholder="연락처">
                    </div>
                </div>
                <div class="input-group input-group-sm mb-2">
                    <input type="text" id="zipcode" name="zipcode" class="form-control form-control-sm"
                           placeholder="우편번호">
                    <button type="button" class="btn btn-outline-secondary" id="zipSearchBtn">우편번호 검색</button>
                </div>
                <div class="mb-2">
                    <input type="text" id="address" name="address" class="form-control form-control-sm"
                           placeholder="주소" required>
                </div>
                <div class="mb-3">
                    <input type="text" id="addressDetail" name="addressDetail" class="form-control form-control-sm"
                           placeholder="상세주소">
                </div>
                <div class="form-check mb-3">
                    <input class="form-check-input" type="checkbox" name="defaultAddress"
                           id="chkDefault" value="true">
                    <label class="form-check-label small" for="chkDefault">기본 배송지로 설정</label>
                </div>
                <button type="submit" class="btn btn-dark btn-sm">추가</button>
            </form>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script src="//t1.kakaocdn.net/mapjsapi/bundle/postcode/prod/postcode.v2.js"></script>
<script>
    const PostcodeService = (window.daum && window.daum.Postcode)
                         || (window.kakao && window.kakao.Postcode);
    document.getElementById('zipSearchBtn').addEventListener('click', () => {
        if (!PostcodeService) { alert('우편번호 서비스를 불러오지 못했습니다. 직접 입력해주세요.'); return; }
        new PostcodeService({
            oncomplete: function (data) {
                document.getElementById('zipcode').value = data.zonecode;
                document.getElementById('address').value = data.roadAddress || data.jibunAddress;
                document.getElementById('addressDetail').focus();
            }
        }).open();
    });
</script>
</body>
</html>
