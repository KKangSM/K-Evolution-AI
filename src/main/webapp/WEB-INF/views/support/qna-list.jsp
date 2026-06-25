<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>1:1 문의 - K-Evolution</title>
    <meta name="_csrf" content="${_csrf.token}">
    <meta name="_csrf_header" content="${_csrf.headerName}">
    <%@ include file="/WEB-INF/views/layout/meta.jsp" %>
    <style>
        .qna-acc .accordion-button { font-weight: 500; }
        .qna-acc .accordion-button:not(.collapsed) {
            background: #f8f9fa; color: var(--kv-text); box-shadow: none;
        }
        .qna-acc .accordion-button:focus { box-shadow: none; }
        .qna-status { width: 70px; flex-shrink: 0; }
        .qna-title { min-width: 0; }
    </style>
</head>
<body class="bg-light">
<%@ include file="/WEB-INF/views/layout/header.jsp" %>

<%@ include file="/WEB-INF/views/layout/flash-toast.jsp" %>

<div class="container py-5" style="max-width:760px">
    <a href="${pageContext.request.contextPath}/support" class="back-link"><i class="bi bi-chevron-left"></i>고객센터</a>
    <div class="d-flex justify-content-between align-items-center mt-2 mb-3">
        <div style="padding-left:.6rem">
            <h5 class="fw-bold mb-1">1:1 문의</h5>
        </div>
        <button type="button" class="btn btn-dark btn-sm px-3" data-bs-toggle="modal" data-bs-target="#writeModal">
            <i class="bi bi-pencil-square"></i> 문의 작성
        </button>
    </div>

    <c:choose>
        <c:when test="${empty qnaList.content}">
            <div class="card shadow-sm">
                <div class="card-body text-center text-muted py-5">
                    <i class="bi bi-chat-square-dots fs-2 d-block mb-2 opacity-50"></i>
                    아직 등록한 문의가 없습니다.
                </div>
            </div>
        </c:when>
        <c:otherwise>
            <div class="accordion qna-acc shadow-sm" id="qnaAcc">
                <c:forEach var="q" items="${qnaList.content}">
                    <div class="accordion-item">
                        <h2 class="accordion-header">
                            <button class="accordion-button collapsed" type="button"
                                    data-bs-toggle="collapse" data-bs-target="#qna${q.qnaId}">
                                <div class="d-flex align-items-center gap-3 flex-grow-1 pe-2" style="min-width:0">
                                    <span class="qna-status text-center">
                                        <c:choose>
                                            <c:when test="${q.answered}">
                                                <span class="badge rounded-pill bg-success-subtle text-success">답변완료</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge rounded-pill bg-warning-subtle text-warning-emphasis">미답변</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </span>
                                    <span class="qna-title flex-grow-1 text-truncate text-dark">${q.title}</span>
                                    <c:if test="${q.answered and !q.answerRead}">
                                        <span class="badge bg-danger new-badge-${q.qnaId}">새 답변</span>
                                    </c:if>
                                    <span class="text-muted small d-none d-sm-inline">${q.createdAt.toString().substring(0, 10)}</span>
                                </div>
                            </button>
                        </h2>
                        <div id="qna${q.qnaId}" class="accordion-collapse collapse qna-collapse"
                             data-bs-parent="#qnaAcc"
                             data-qna-id="${q.qnaId}"
                             data-answered="${q.answered}"
                             data-read="${q.answerRead}">
                            <div class="accordion-body">
                                <!-- 문의 내용 -->
                                <div class="text-muted small mb-1">문의 내용 · ${q.createdAt.toString().substring(0, 16).replace('T', ' ')}</div>
                                <p style="white-space: pre-wrap;" class="mb-0">${q.content}</p>

                                <!-- 답변 -->
                                <c:choose>
                                    <c:when test="${q.answered}">
                                        <div class="border-top mt-3 pt-3">
                                            <div class="fw-semibold text-success mb-1">
                                                <i class="bi bi-chat-left-text"></i> 답변
                                                <span class="text-muted small fw-normal ms-1">
                                                    ${q.answeredAt.toString().substring(0, 16).replace('T', ' ')}
                                                </span>
                                            </div>
                                            <p style="white-space: pre-wrap;" class="mb-0">${q.answer}</p>
                                        </div>
                                    </c:when>
                                    <c:otherwise>
                                        <div class="border-top mt-3 pt-3 d-flex justify-content-between align-items-center flex-wrap gap-2">
                                            <span class="text-muted small">
                                                아직 답변이 등록되지 않았습니다. 영업일 기준 1~2일 내에 답변드립니다.
                                            </span>
                                            <div class="d-flex gap-2">
                                                <button type="button" class="btn btn-outline-secondary btn-sm"
                                                        data-bs-toggle="modal" data-bs-target="#editModal"
                                                        data-qna-id="${q.qnaId}"
                                                        data-qna-title="<c:out value='${q.title}'/>"
                                                        data-qna-content="<c:out value='${q.content}'/>">수정</button>
                                                <form action="${pageContext.request.contextPath}/support/qna/${q.qnaId}/delete"
                                                      method="post" onsubmit="return confirm('문의를 삭제하시겠습니까?')">
                                                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                                                    <button class="btn btn-outline-danger btn-sm">삭제</button>
                                                </form>
                                            </div>
                                        </div>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                    </div>
                </c:forEach>
            </div>

            <c:if test="${qnaList.totalPages > 1}">
                <nav class="mt-3">
                    <ul class="pagination justify-content-center">
                        <c:forEach begin="0" end="${qnaList.totalPages - 1}" var="i">
                            <li class="page-item ${qnaList.number == i ? 'active' : ''}">
                                <a class="page-link" href="?page=${i}">${i + 1}</a>
                            </li>
                        </c:forEach>
                    </ul>
                </nav>
            </c:if>
        </c:otherwise>
    </c:choose>
</div>

<!-- 문의 작성 모달 -->
<div class="modal fade" id="writeModal" tabindex="-1" aria-labelledby="writeModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <form action="${pageContext.request.contextPath}/support/qna/write" method="post">
                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                <div class="modal-header">
                    <h6 class="modal-title fw-bold" id="writeModalLabel">1:1 문의 작성</h6>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="닫기"></button>
                </div>
                <div class="modal-body">
                    <div class="mb-3">
                        <label class="form-label small text-muted">제목</label>
                        <input type="text" name="title" class="form-control" required maxlength="200"
                               placeholder="제목을 입력하세요">
                    </div>
                    <div class="mb-1">
                        <label class="form-label small text-muted">내용</label>
                        <textarea name="content" class="form-control" rows="7" required
                                  placeholder="문의 내용을 입력하세요"></textarea>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-outline-secondary btn-sm" data-bs-dismiss="modal">취소</button>
                    <button type="submit" class="btn btn-dark btn-sm px-3">등록</button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- 문의 수정 모달 (공유 — 수정 버튼 클릭 시 값 채움) -->
<div class="modal fade" id="editModal" tabindex="-1" aria-labelledby="editModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <form id="editForm" method="post">
                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                <div class="modal-header">
                    <h6 class="modal-title fw-bold" id="editModalLabel">문의 수정</h6>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="닫기"></button>
                </div>
                <div class="modal-body">
                    <div class="mb-3">
                        <label class="form-label small text-muted">제목</label>
                        <input type="text" name="title" id="editTitle" class="form-control" required maxlength="200">
                    </div>
                    <div class="mb-1">
                        <label class="form-label small text-muted">내용</label>
                        <textarea name="content" id="editContent" class="form-control" rows="7" required></textarea>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-outline-secondary btn-sm" data-bs-dismiss="modal">취소</button>
                    <button type="submit" class="btn btn-dark btn-sm px-3">수정 완료</button>
                </div>
            </form>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    // 수정 모달: 열릴 때 클릭한 문의의 제목·내용·전송 대상(action)을 채운다.
    (function () {
        var ctx = '${pageContext.request.contextPath}';
        var modal = document.getElementById('editModal');
        if (modal) {
            modal.addEventListener('show.bs.modal', function (e) {
                var btn = e.relatedTarget;
                document.getElementById('editForm').action = ctx + '/support/qna/' + btn.getAttribute('data-qna-id') + '/edit';
                document.getElementById('editTitle').value = btn.getAttribute('data-qna-title');
                document.getElementById('editContent').value = btn.getAttribute('data-qna-content');
            });
        }
    })();

    // 답변이 달린 문의를 펼치면 1회 '확인' 처리 (고객확인 추적)
    (function () {
        var ctx = '${pageContext.request.contextPath}';
        var token = document.querySelector('meta[name="_csrf"]').content;
        var header = document.querySelector('meta[name="_csrf_header"]').content;
        document.querySelectorAll('.qna-collapse').forEach(function (el) {
            el.addEventListener('shown.bs.collapse', function () {
                if (el.dataset.answered !== 'true' || el.dataset.read === 'true') return;
                el.dataset.read = 'true';
                var headers = {};
                headers[header] = token;
                fetch(ctx + '/support/qna/' + el.dataset.qnaId + '/read', { method: 'POST', headers: headers });
                var badge = document.querySelector('.new-badge-' + el.dataset.qnaId);
                if (badge) badge.remove();
            });
        });
    })();
</script>
</body>
</html>
