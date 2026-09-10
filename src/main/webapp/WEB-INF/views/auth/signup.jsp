<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>회원가입 - K-Evolution</title>
    <%@ include file="/WEB-INF/views/layout/meta.jsp" %>
    <style>
        body { min-height: 100vh; display: flex; align-items: center; justify-content: center; }
        .signup-wrap { width: 100%; max-width: 420px; }
        .signup-logo {
            display: inline-block;
            font-weight: 800; letter-spacing: -1px; font-size: 4rem;
            color: #0f3460; text-decoration: none;
        }
        .signup-logo:hover { color: #16213e; }
        /* 메시지 영역: 텍스트가 있든 없든 높이를 '완전히 고정'해 단 1px도 움직이지 않게.
           height = line-height 로 맞추고 overflow:hidden(한 줄 고정). className 변경과 무관하게
           ID 로 고정하므로 JS 가 class 를 덮어써도 유지된다. */
        #idMsg, #pwMsg, #pwConfirmMsg {
            height: 1.5rem;
            line-height: 1.5rem;
            overflow: hidden;
        }
    </style>
</head>
<body class="bg-light theme-popart">

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
                               required minlength="4" maxlength="20" autocomplete="off"
                               pattern="[a-z][a-z0-9]{3,19}"
                               title="영문 소문자로 시작하고 영문 소문자·숫자 4~20자여야 합니다.">
                        <button type="button" class="btn btn-outline-secondary" id="checkIdBtn">중복확인</button>
                    </div>
                    <div class="form-text">영문 소문자로 시작, 영문 소문자·숫자 4~20자</div>
                    <div id="idMsg" class="form-text mt-1 field-msg"></div>
                </div>

                <!-- 비밀번호 -->
                <div class="mb-3">
                    <label class="form-label small text-muted">비밀번호</label>
                    <input type="password" id="password" name="password" class="form-control"
                           required minlength="8" maxlength="64"
                           pattern="(?=.*[A-Za-z])(?=.*\d)(?=.*[^A-Za-z0-9\s])\S{8,64}"
                           title="영문·숫자·특수문자를 모두 포함해 8자 이상(공백 불가)이어야 합니다.">
                    <div class="form-text">영문·숫자·특수문자 포함 8자 이상 (공백 불가)</div>
                    <div id="pwMsg" class="form-text mt-1 field-msg"></div>
                </div>

                <!-- 비밀번호 확인 -->
                <div class="mb-3">
                    <label class="form-label small text-muted">비밀번호 확인</label>
                    <input type="password" id="passwordConfirm" name="passwordConfirm" class="form-control"
                           required minlength="8">
                    <div id="pwConfirmMsg" class="form-text mt-1 field-msg"></div>
                </div>

                <!-- 이름 -->
                <div class="mb-3">
                    <label class="form-label small text-muted">이름</label>
                    <input type="text" name="name" class="form-control"
                           required maxlength="50">
                </div>

                <!-- 휴대폰 -->
                <div class="mb-3">
                    <label class="form-label small text-muted">휴대폰</label>
                    <input type="tel" name="phone" class="form-control" data-phone-format
                           placeholder="010-1234-5678" required maxlength="13"
                           pattern="01[0-9]-\d{3,4}-\d{4}"
                           title="숫자를 입력하면 하이픈(-)이 자동으로 들어갑니다.">
                </div>

                <!-- 기본 배송지 -->
                <div class="mb-3">
                    <label class="form-label small text-muted">기본 배송지</label>
                    <div class="input-group mb-2">
                        <input type="text" id="zipcode" name="zipcode" class="form-control"
                               placeholder="우편번호" maxlength="20">
                        <button type="button" class="btn btn-outline-secondary" id="zipSearchBtn">우편번호 검색</button>
                    </div>
                    <input type="text" id="address" name="address" class="form-control mb-2"
                           placeholder="주소" required maxlength="200">
                    <input type="text" id="addressDetail" name="addressDetail" class="form-control"
                           placeholder="상세주소 (선택)" maxlength="200">
                </div>

                <!-- 약관 동의 -->
                <c:if test="${not empty termsList}">
                <div class="mb-4">
                    <div class="border rounded p-3 bg-white">
                        <div class="form-check mb-2">
                            <input class="form-check-input" type="checkbox" id="agreeAll">
                            <label class="form-check-label fw-bold small" for="agreeAll">전체 동의</label>
                        </div>
                        <hr class="my-2">
                        <div class="form-check mb-1">
                            <input class="form-check-input term-check" type="checkbox"
                                   id="termKsm" required>
                            <label class="form-check-label small" for="termKsm">
                                <span class="text-danger">[필수]</span> 강선모를 찬양경배해
                            </label>
                        </div>
                        <c:forEach var="t" items="${termsList}" varStatus="vs">
                        <div class="form-check mb-1 d-flex align-items-center justify-content-between">
                            <div>
                                <input class="form-check-input term-check" type="checkbox"
                                       name="termIds" value="${t.termId}"
                                       id="term${t.termId}" ${t.required ? 'required' : ''}>
                                <label class="form-check-label small" for="term${t.termId}">
                                    <c:if test="${t.required}"><span class="text-danger">[필수]</span></c:if>
                                    <c:if test="${!t.required}"><span class="text-muted">[선택]</span></c:if>
                                    ${t.title}
                                </label>
                            </div>
                            <button type="button" class="btn btn-link btn-sm p-0 text-muted text-decoration-none"
                                    data-bs-toggle="modal" data-bs-target="#termModal${t.termId}">보기</button>
                        </div>

                        <!-- 약관 내용 모달 -->
                        <div class="modal fade" id="termModal${t.termId}" tabindex="-1">
                            <div class="modal-dialog modal-lg modal-dialog-scrollable">
                                <div class="modal-content">
                                    <div class="modal-header">
                                        <h6 class="modal-title">${t.title}</h6>
                                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                                    </div>
                                    <div class="modal-body" style="font-size: 0.85rem;">
                                        ${t.content}
                                    </div>
                                    <div class="modal-footer">
                                        <button type="button" class="btn btn-dark btn-sm"
                                                onclick="agreeAndClose('term${t.termId}', 'termModal${t.termId}')">
                                            동의하고 닫기
                                        </button>
                                        <button type="button" class="btn btn-outline-secondary btn-sm"
                                                data-bs-dismiss="modal">닫기</button>
                                    </div>
                                </div>
                            </div>
                        </div>
                        </c:forEach>
                    </div>
                </div>
                </c:if>

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
<script src="//t1.kakaocdn.net/mapjsapi/bundle/postcode/prod/postcode.v2.js"></script>
<script src="${pageContext.request.contextPath}/js/phone-format.js"></script>
<script>
    // 카카오(다음) 우편번호 검색 — 스크립트가 노출하는 전역(daum/kakao) 어느 쪽이든 사용
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

    const userIdInput     = document.getElementById('userId');
    const checkIdBtn      = document.getElementById('checkIdBtn');
    const idMsg           = document.getElementById('idMsg');
    const submitBtn       = document.getElementById('submitBtn');
    const passwordInput   = document.getElementById('password');
    const pwConfirmInput  = document.getElementById('passwordConfirm');
    const pwConfirmMsg    = document.getElementById('pwConfirmMsg');
    const pwMsg           = document.getElementById('pwMsg');
    const ctx             = '${pageContext.request.contextPath}';

    // 서버 PasswordPolicy 와 동일한 규칙 (영문·숫자·특수문자 포함, 공백 없이 8~64자)
    const PW_PATTERN = /^(?=.*[A-Za-z])(?=.*\d)(?=.*[^A-Za-z0-9\s])\S{8,64}$/;

    function validatePassword() {
        const v = passwordInput.value;
        if (v === '') {                       // 비었을 때: 공간은 유지하되 메시지 숨김
            pwMsg.textContent = '';
            pwMsg.className = 'form-text mt-1 field-msg';
            return false;
        }
        if (PW_PATTERN.test(v)) {
            pwMsg.textContent = '사용 가능한 비밀번호입니다.';
            pwMsg.className = 'form-text mt-1 field-msg text-success';
            return true;
        }
        pwMsg.textContent = '비밀번호 형식이 올바르지 않습니다.';
        pwMsg.className = 'form-text mt-1 field-msg text-danger';
        return false;
    }

    function validatePasswordConfirm() {
        if (pwConfirmInput.value === '') {
            pwConfirmMsg.textContent = '';
            pwConfirmMsg.className = 'form-text mt-1';
            return false;
        }
        if (passwordInput.value === pwConfirmInput.value) {
            pwConfirmMsg.textContent = '비밀번호가 일치합니다.';
            pwConfirmMsg.className = 'form-text mt-1 text-success';
            return true;
        } else {
            pwConfirmMsg.textContent = '비밀번호가 일치하지 않습니다.';
            pwConfirmMsg.className = 'form-text mt-1 text-danger';
            return false;
        }
    }

    passwordInput.addEventListener('input', () => { validatePassword(); validatePasswordConfirm(); });
    pwConfirmInput.addEventListener('input', validatePasswordConfirm);

    // 서버 UserIdPolicy 와 동일한 규칙 (영문 소문자 시작, 영문 소문자·숫자 4~20자)
    const ID_PATTERN = /^[a-z][a-z0-9]{3,19}$/;

    // 실시간 형식 검증(서버 규칙과 동일). 형식이 틀리면 아래에 표시, 맞으면 비워서
    // 중복확인 결과("사용 가능/중복")가 들어갈 자리를 남긴다.
    function validateUserId() {
        const v = userIdInput.value;
        if (v === '' || ID_PATTERN.test(v)) {
            idMsg.textContent = '';
            idMsg.className = 'form-text mt-1';
            return v !== '';
        }
        idMsg.textContent = '아이디 형식이 올바르지 않습니다.';
        idMsg.className = 'form-text mt-1 text-danger';
        return false;
    }
    userIdInput.addEventListener('input', validateUserId);

    checkIdBtn.addEventListener('click', async () => {
        const val = userIdInput.value.trim();
        // 형식부터 검사 — 형식이 틀리면 "사용 가능" 으로 통과시키지 않는다.
        if (!ID_PATTERN.test(val)) {
            idMsg.textContent = '아이디 형식을 확인해주세요.';
            idMsg.className = 'form-text mt-1 text-danger';
            return;
        }
        checkIdBtn.disabled = true;
        checkIdBtn.textContent = '확인 중...';

        try {
            const res = await fetch(ctx + '/auth/checkId?userId=' + encodeURIComponent(val));
            const data = await res.json();
            if (data.duplicated) {
                idMsg.textContent = '이미 사용 중인 아이디입니다.';
                idMsg.className = 'form-text mt-1 text-danger';
            } else {
                idMsg.textContent = '사용 가능한 아이디입니다.';
                idMsg.className = 'form-text mt-1 text-success';
            }
        } catch (e) {
            idMsg.textContent = '확인 중 오류가 발생했습니다.';
            idMsg.className = 'form-text mt-1 text-danger';
        } finally {
            checkIdBtn.disabled = false;
            checkIdBtn.textContent = '중복확인';
        }
    });

    // 전체 동의 체크박스
    const agreeAll = document.getElementById('agreeAll');
    const termChecks = document.querySelectorAll('.term-check');

    if (agreeAll) {
        agreeAll.addEventListener('change', () => {
            termChecks.forEach(c => c.checked = agreeAll.checked);
        });
        termChecks.forEach(c => c.addEventListener('change', () => {
            agreeAll.checked = [...termChecks].every(c => c.checked);
        }));
    }

    function agreeAndClose(checkId, modalId) {
        document.getElementById(checkId).checked = true;
        if (agreeAll) agreeAll.checked = [...termChecks].every(c => c.checked);
        bootstrap.Modal.getInstance(document.getElementById(modalId)).hide();
    }

    document.getElementById('signupForm').addEventListener('submit', (e) => {
        if (!validatePasswordConfirm()) {
            e.preventDefault();
            pwConfirmInput.focus();
            return;
        }
        const requiredTerms = document.querySelectorAll('.term-check[required]');
        for (const t of requiredTerms) {
            if (!t.checked) {
                e.preventDefault();
                alert('필수 약관에 동의해주세요.');
                t.focus();
                return;
            }
        }
    });
</script>
</body>
</html>
