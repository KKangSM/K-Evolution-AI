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
            <div class="kv-msg bot">안녕하세요! 무엇을 도와드릴까요? 😊<br>배송, 환불, 상품 정보 등을 물어보실 수 있어요.</div>
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

    form.addEventListener('submit', function (e) {
        e.preventDefault();
        var text = input.value.trim();
        if (!text) return;

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
            if (r.status === 401) throw new Error('로그인이 필요합니다.');
            if (!r.ok) throw new Error('일시적인 오류가 발생했어요.');
            return r.json();
        })
        .then(function (data) {
            typing.remove();
            addMsg(data.answer, 'bot', data.escalate);
        })
        .catch(function (err) {
            typing.remove();
            addMsg(err.message || '일시적인 오류가 발생했어요.', 'bot', false);
        })
        .finally(function () {
            sendBtn.disabled = false;
            input.focus();
        });
    });
})();
</script>
