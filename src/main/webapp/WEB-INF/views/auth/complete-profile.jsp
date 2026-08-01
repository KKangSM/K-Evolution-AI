<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>추가정보 입력 - K-Evolution</title>
    <%@ include file="/WEB-INF/views/layout/meta.jsp" %>
    <style>
        body { min-height: 100vh; display: flex; align-items: center; justify-content: center; }
        .wrap { width: 100%; max-width: 440px; }
    </style>
</head>
<body class="bg-light">

<div class="wrap px-3">
    <div class="text-center mb-4">
        <a href="${pageContext.request.contextPath}/" class="text-decoration-none fw-bold fs-3" style="color:#0f3460;">K-Evolution</a>
        <p class="text-muted small mt-1 mb-0">가입을 마치기 위해 아래 정보를 입력해주세요</p>
    </div>

    <div class="card shadow-sm">
        <div class="card-body p-4">
            <h5 class="fw-bold mb-1">환영합니다, <c:out value="${memberName}"/>님 👋</h5>
            <p class="text-muted small mb-4">서비스 이용을 위해 휴대폰 번호와 약관 동의가 필요합니다.</p>

            <c:if test="${not empty errorMsg}">
                <div class="alert alert-danger py-2 small">${errorMsg}</div>
            </c:if>

            <form action="${pageContext.request.contextPath}/auth/complete-profile" method="post" id="profileForm">
                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>

                <div class="mb-3">
                    <label class="form-label small text-muted">휴대폰 번호</label>
                    <input type="tel" name="phone" class="form-control"
                           placeholder="010-1234-5678" required maxlength="13" autofocus>
                </div>

                <c:if test="${not empty termsList}">
                    <div class="border rounded p-3 mb-3">
                        <div class="form-check mb-2 pb-2 border-bottom">
                            <input class="form-check-input" type="checkbox" id="agreeAll">
                            <label class="form-check-label small fw-semibold" for="agreeAll">전체 동의</label>
                        </div>
                        <c:forEach var="t" items="${termsList}">
                            <div class="form-check">
                                <input class="form-check-input term-check" type="checkbox"
                                       name="termIds" value="${t.termId}"
                                       id="term${t.termId}" ${t.required ? 'required' : ''}>
                                <label class="form-check-label small" for="term${t.termId}">
                                    <c:if test="${t.required}"><span class="text-danger">[필수]</span></c:if>
                                    <c:if test="${!t.required}"><span class="text-muted">[선택]</span></c:if>
                                    <c:out value="${t.title}"/>
                                </label>
                            </div>
                        </c:forEach>
                    </div>
                </c:if>

                <button type="submit" class="btn btn-dark w-100">가입 완료</button>
            </form>

            <p class="text-center mt-3 mb-0">
                <a href="${pageContext.request.contextPath}/auth/logout" class="text-muted small text-decoration-none">취소하고 로그아웃</a>
            </p>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    (function () {
        const agreeAll = document.getElementById('agreeAll');
        const checks = document.querySelectorAll('.term-check');
        if (agreeAll) {
            agreeAll.addEventListener('change', () => checks.forEach(c => c.checked = agreeAll.checked));
            checks.forEach(c => c.addEventListener('change',
                () => { agreeAll.checked = [...checks].every(x => x.checked); }));
        }
    })();
</script>
</body>
</html>
