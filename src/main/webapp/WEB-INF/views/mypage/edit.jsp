<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>내 정보 수정 - K-Evolution</title>
    <%@ include file="/WEB-INF/views/layout/meta.jsp" %>
</head>
<body class="bg-light theme-popart">
<%@ include file="/WEB-INF/views/layout/header.jsp" %>

<%@ include file="/WEB-INF/views/layout/flash-toast.jsp" %>

<div class="container py-5" style="max-width:560px">
    <a href="${pageContext.request.contextPath}/mypage" class="back-link"><i class="bi bi-chevron-left"></i>마이페이지</a>
    <h5 class="fw-bold mt-2 mb-4">내 정보 수정</h5>

    <!-- 기본 정보 수정 -->
    <div class="card shadow-sm mb-4">
        <div class="card-header fw-bold">기본 정보</div>
        <div class="card-body">
            <form action="${pageContext.request.contextPath}/mypage/edit" method="post">
                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                <div class="mb-3">
                    <label class="form-label small text-muted">아이디</label>
                    <input type="text" class="form-control" value="${member.userId}" disabled>
                </div>
                <div class="mb-3">
                    <label class="form-label small text-muted">이름</label>
                    <input type="text" name="name" class="form-control" value="${member.name}" required>
                </div>
                <div class="mb-3">
                    <label class="form-label small text-muted">전화번호</label>
                    <input type="tel" name="phone" class="form-control" data-phone-format
                           value="${member.phone}" placeholder="010-1234-5678"
                           maxlength="13" pattern="01[0-9]-\d{3,4}-\d{4}"
                           title="숫자를 입력하면 하이픈(-)이 자동으로 들어갑니다.">
                </div>
                <button type="submit" class="btn btn-dark btn-sm">수정 완료</button>
            </form>
        </div>
    </div>

    <!-- 비밀번호 변경 -->
    <div class="card shadow-sm">
        <div class="card-header fw-bold">비밀번호 변경</div>
        <div class="card-body">
            <c:if test="${not empty pwSuccessMsg}">
                <div class="alert alert-success py-2 small">${pwSuccessMsg}</div>
            </c:if>
            <c:if test="${not empty pwErrorMsg}">
                <div class="alert alert-danger py-2 small">${pwErrorMsg}</div>
            </c:if>
            <form action="${pageContext.request.contextPath}/mypage/changePassword" method="post">
                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                <div class="mb-3">
                    <label class="form-label small text-muted">현재 비밀번호</label>
                    <input type="password" name="currentPassword" class="form-control" required>
                </div>
                <div class="mb-3">
                    <label class="form-label small text-muted">새 비밀번호</label>
                    <input type="password" name="newPassword" class="form-control"
                           minlength="8" maxlength="64" required
                           pattern="(?=.*[A-Za-z])(?=.*\d)(?=.*[^A-Za-z0-9\s])\S{8,64}"
                           title="영문·숫자·특수문자를 모두 포함해 8자 이상(공백 불가)이어야 합니다.">
                </div>
                <button type="submit" class="btn btn-dark btn-sm">비밀번호 변경</button>
            </form>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script src="${pageContext.request.contextPath}/js/phone-format.js"></script>
</body>
</html>
