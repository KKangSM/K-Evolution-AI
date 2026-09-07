<%@ page contentType="text/html; charset=UTF-8" %>
<%--
  AI 상담 챗봇 위젯 — 고객 화면 공통(header.jsp)에서 include 한다.
  자체 완결형(마크업+스타일+스크립트). CSRF 토큰과 contextPath 는 JSP EL 로 주입한다.
--%>
<div id="kvChat" class="kv-chat">
    <button type="button" class="kv-chat-fab" id="kvChatFab" aria-label="AI 상담 열기">
        <i class="bi bi-chat-dots-fill"></i>
    </button>

    <div class="kv-chat-panel" id="kvChatPanel" hidden>
        <div class="kv-chat-head">
            <div>
                <strong>K-Evolution AI 상담</strong>
                <div class="kv-chat-sub">배송·환불·상품 무엇이든 물어보세요</div>
            </div>
            <button type="button" class="kv-chat-close" id="kvChatClose" aria-label="닫기">
                <i class="bi bi-x-lg"></i>
            </button>
        </div>

        <div class="kv-chat-body" id="kvChatBody">
            <div class="kv-msg bot">안녕하세요! K-Evolution AI 상담원이에요 😊<br>아래에서 골라 물어보시거나 직접 입력해 주세요.</div>
            <div class="kv-chat-suggest" id="kvChatSuggest">
                <div class="kv-suggest-title">이런 걸 물어보실 수 있어요</div>
                <button type="button" class="kv-chip">배송비는 얼마인가요?</button>
                <button type="button" class="kv-chip">반품·교환은 어떻게 하나요?</button>
                <button type="button" class="kv-chip">포인트 적립은 어떻게 되나요?</button>
                <button type="button" class="kv-chip">인기 상품 추천해 주세요</button>
            </div>
        </div>

        <form class="kv-chat-input" id="kvChatForm" autocomplete="off">
            <input type="text" id="kvChatText" placeholder="메시지를 입력하세요…" maxlength="500" required>
            <button type="submit" aria-label="보내기"><i class="bi bi-send-fill"></i></button>
        </form>
    </div>
</div>

<style>
    .kv-chat-fab{position:fixed;right:22px;bottom:22px;width:58px;height:58px;border:none;border-radius:50%;
        background:#1a1a2e;color:#fff;font-size:24px;box-shadow:0 6px 20px rgba(20,20,50,.28);cursor:pointer;z-index:1080;
        display:flex;align-items:center;justify-content:center;transition:transform .15s;}
    .kv-chat-fab:hover{transform:scale(1.06);}
    .kv-chat-panel{position:fixed;right:22px;bottom:92px;width:360px;max-width:calc(100vw - 32px);height:520px;
        max-height:calc(100vh - 130px);background:#fff;border-radius:18px;box-shadow:0 12px 40px rgba(20,20,50,.28);
        display:flex;flex-direction:column;overflow:hidden;z-index:1080;}
    .kv-chat-head{background:#1a1a2e;color:#fff;padding:14px 16px;display:flex;align-items:center;justify-content:space-between;}
    .kv-chat-sub{font-size:12px;opacity:.7;margin-top:2px;}
    .kv-chat-close{background:none;border:none;color:#fff;font-size:16px;cursor:pointer;opacity:.8;}
    .kv-chat-close:hover{opacity:1;}
    .kv-chat-body{flex:1;overflow-y:auto;padding:16px;background:#fafafc;display:flex;flex-direction:column;gap:10px;}
    .kv-msg{max-width:82%;padding:10px 13px;border-radius:14px;font-size:14px;line-height:1.55;word-break:break-word;}
    .kv-msg.bot{background:#fff;border:1px solid #ececf3;align-self:flex-start;border-bottom-left-radius:4px;}
    .kv-msg.user{background:#5b5bd6;color:#fff;align-self:flex-end;border-bottom-right-radius:4px;}
    .kv-msg.typing{color:#9a9ab0;font-style:italic;}
    .kv-msg .kv-escalate{display:inline-block;margin-top:8px;font-size:13px;font-weight:600;color:#5b5bd6;text-decoration:none;}
    .kv-chat-suggest{display:flex;flex-direction:column;gap:6px;align-self:flex-start;max-width:100%;}
    .kv-suggest-title{font-size:12px;color:#9a9ab0;margin:2px 2px 0;}
    .kv-chip{background:#fff;border:1px solid #d7d7ea;color:#3a3a55;border-radius:16px;padding:7px 12px;
        font-size:13px;text-align:left;cursor:pointer;transition:all .12s;}
    .kv-chip:hover{border-color:#5b5bd6;color:#5b5bd6;background:#f6f5ff;}
    .kv-chat-input{display:flex;gap:8px;padding:12px;border-top:1px solid #ececf3;background:#fff;}
    .kv-chat-input input{flex:1;border:1px solid #dcdce6;border-radius:22px;padding:9px 15px;font-size:14px;outline:none;}
    .kv-chat-input input:focus{border-color:#5b5bd6;}
    .kv-chat-input button{border:none;background:#1a1a2e;color:#fff;width:40px;height:40px;border-radius:50%;cursor:pointer;flex:0 0 auto;}
    .kv-chat-input button:disabled{opacity:.5;cursor:default;}
</style>

<script>
(function () {
    var ctx = '${pageContext.request.contextPath}';
    var csrfHeader = '${_csrf.headerName}';
    var csrfToken = '${_csrf.token}';

    var fab = document.getElementById('kvChatFab');
    var panel = document.getElementById('kvChatPanel');
    var closeBtn = document.getElementById('kvChatClose');
    var body = document.getElementById('kvChatBody');
    var form = document.getElementById('kvChatForm');
    var input = document.getElementById('kvChatText');
    var sendBtn = form.querySelector('button[type="submit"]');

    function toggle(open) {
        panel.hidden = !open;
        if (open) { input.focus(); scrollDown(); }
    }
    fab.addEventListener('click', function () { toggle(panel.hidden); });
    closeBtn.addEventListener('click', function () { toggle(false); });

    function scrollDown() { body.scrollTop = body.scrollHeight; }

    function escapeHtml(s) {
        return s.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
    }

    function addMsg(text, who, escalate) {
        var el = document.createElement('div');
        el.className = 'kv-msg ' + who;
        el.innerHTML = escapeHtml(text).replace(/\n/g, '<br>');
        if (escalate) {
            el.innerHTML += '<br><a class="kv-escalate" href="' + ctx + '/support/qna">'
                + '<i class="bi bi-headset"></i> 1:1 문의 남기기</a>';
        }
        body.appendChild(el);
        scrollDown();
        return el;
    }

    // 질문 예시 칩: 클릭하면 그대로 전송하고 목록은 숨긴다
    var suggest = document.getElementById('kvChatSuggest');
    function hideSuggest() { if (suggest) suggest.style.display = 'none'; }
    if (suggest) {
        suggest.querySelectorAll('.kv-chip').forEach(function (chip) {
            chip.addEventListener('click', function () { sendMessage(chip.textContent); });
        });
    }

    function sendMessage(text) {
        text = (text || '').trim();
        if (!text) return;

        hideSuggest();
        addMsg(text, 'user', false);
        input.value = '';
        sendBtn.disabled = true;

        var typing = addMsg('입력 중…', 'bot typing', false);

        var headers = { 'Content-Type': 'application/json', 'X-Requested-With': 'XMLHttpRequest' };
        if (csrfHeader) headers[csrfHeader] = csrfToken;

        fetch(ctx + '/api/ai/chat', {
            method: 'POST',
            headers: headers,
            body: JSON.stringify({ message: text })
        })
        .then(function (r) {
            if (!r.ok) {
                // 실패(세션 만료·CSRF·서버 오류 등)해도 막다른 오류 대신 1:1 문의로 유도한다
                var e = new Error(r.status === 401
                    ? '로그인이 필요해요. 로그인 후 다시 시도하시거나, 아래 1:1 문의로 남겨주세요.'
                    : '지금은 바로 답변드리기 어려워요. 아래 1:1 문의로 남겨주시면 확인해 드릴게요.');
                e.escalate = true;
                throw e;
            }
            return r.json();
        })
        .then(function (data) {
            typing.remove();
            addMsg(data.answer, 'bot', data.escalate);
        })
        .catch(function (err) {
            typing.remove();
            // 네트워크 오류 등도 1:1 문의 링크를 함께 보여준다
            addMsg(err.message || '지금은 답변이 어려워요. 아래 1:1 문의로 남겨주시면 확인해 드릴게요.',
                   'bot', err.escalate !== false);
        })
        .finally(function () {
            sendBtn.disabled = false;
            input.focus();
        });
    }

    form.addEventListener('submit', function (e) {
        e.preventDefault();
        sendMessage(input.value);
    });
})();
</script>
