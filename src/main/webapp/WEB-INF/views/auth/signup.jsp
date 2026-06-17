<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>회원가입 - K-Evolution</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
    <style>
        body { min-height: 100vh; display: flex; align-items: center; justify-content: center; }
        .signup-wrap { width: 100%; max-width: 420px; }
        .signup-logo {
            display: inline-block;
            font-weight: 800; letter-spacing: -1px; font-size: 4rem;
            color: #0f3460; text-decoration: none;
        }
        .signup-logo:hover { color: #16213e; }
    </style>
</head>
<body class="bg-light">

<div class="signup-wrap px-3">

    <div class="text-center mb-4">
        <a href="${pageContext.request.contextPath}/" class="signup-logo">K-Evolution</a>
        <p class="text-muted small mt-1 mb-0">당신의 일상을 진화시키는 셀렉트 쇼핑</p>
    </div>

    <div class="card shadow-sm">
        <div class="card-body p-4">
            <h5 class="text-center fw-bold mb-4">회원가입</h5>

            <c:if test="${not empty errorMsg}">
                <div class="alert alert-danger py-2 small">${errorMsg}</div>
            </c:if>

            <form action="${pageContext.request.contextPath}/auth/signup" method="post" id="signupForm">
                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>

                <!-- 아이디 -->
                <div class="mb-3">
                    <label class="form-label small text-muted">아이디</label>
                    <div class="input-group">
                        <input type="text" id="userId" name="userId" class="form-control"
                               placeholder="4~20자 영문, 숫자" required minlength="4" maxlength="20"
                               autocomplete="off">
                        <button type="button" class="btn btn-outline-secondary" id="checkIdBtn">중복확인</button>
                    </div>
                    <div id="idMsg" class="form-text mt-1"></div>
                </div>

                <!-- 비밀번호 -->
                <div class="mb-3">
                    <label class="form-label small text-muted">비밀번호</label>
                    <input type="password" name="password" class="form-control"
                           placeholder="8자 이상" required minlength="8">
                </div>

                <!-- 이름 -->
                <div class="mb-4">
                    <label class="form-label small text-muted">이름</label>
                    <input type="text" name="name" class="form-control"
                           placeholder="실명 입력" required maxlength="50">
                </div>

                <button type="submit" class="btn btn-dark w-100" id="submitBtn">가입하기</button>
            </form>

            <p class="text-center text-muted small mt-3 mb-0">
                이미 계정이 있으신가요?
                <a href="${pageContext.request.contextPath}/auth/login" class="text-decoration-none">로그인</a>
            </p>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    const userIdInput = document.getElementById('userId');
    const checkIdBtn  = document.getElementById('checkIdBtn');
    const idMsg       = document.getElementById('idMsg');
    const submitBtn   = document.getElementById('submitBtn');
    const ctx         = '${pageContext.request.contextPath}';

    let idChecked = false;

    userIdInput.addEventListener('input', () => {
        idChecked = false;
        idMsg.textContent = '';
        idMsg.className = 'form-text mt-1';
    });

    checkIdBtn.addEventListener('click', async () => {
        const val = userIdInput.value.trim();
        if (val.length < 4) {
            idMsg.textContent = '아이디는 4자 이상이어야 합니다.';
            idMsg.className = 'form-text mt-1 text-danger';
            return;
        }
        checkIdBtn.disabled = true;
        checkIdBtn.textContent = '확인 중...';

        try {
            const res = await fetch(ctx + '/auth/check-id?userId=' + encodeURIComponent(val));
            const data = await res.json();
            if (data.duplicated) {
                idMsg.textContent = '이미 사용 중인 아이디입니다.';
                idMsg.className = 'form-text mt-1 text-danger';
                idChecked = false;
            } else {
                idMsg.textContent = '사용 가능한 아이디입니다.';
                idMsg.className = 'form-text mt-1 text-success';
                idChecked = true;
            }
        } catch (e) {
            idMsg.textContent = '확인 중 오류가 발생했습니다.';
            idMsg.className = 'form-text mt-1 text-danger';
        } finally {
            checkIdBtn.disabled = false;
            checkIdBtn.textContent = '중복확인';
        }
    });

    document.getElementById('signupForm').addEventListener('submit', (e) => {
        if (!idChecked) {
            e.preventDefault();
            idMsg.textContent = '아이디 중복 확인을 해주세요.';
            idMsg.className = 'form-text mt-1 text-danger';
            userIdInput.focus();
        }
    });
</script>
</body>
</html>
