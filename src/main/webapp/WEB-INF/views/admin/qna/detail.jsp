<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>문의 상세 · K-Evolution 관리자</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin.css">
</head>
<body class="admin-body">

<%@ include file="/WEB-INF/views/fragments/admin-topbar.jsp" %>

<div class="admin-layout">
    <%@ include file="/WEB-INF/views/fragments/admin-sidebar.jsp" %>

    <main class="admin-main">

        <div class="d-flex justify-content-between align-items-center mb-4">
            <h4 class="page-title mb-0">문의 상세</h4>
            <a href="${pageContext.request.contextPath}/admin/qna" class="btn btn-outline-secondary btn-sm">목록으로</a>
        </div>

        <c:if test="${not empty successMsg}">
            <div class="alert alert-success py-2 small">${successMsg}</div>
        </c:if>

        <!-- 문의 내용 -->
        <div class="card shadow-sm mb-4">
            <div class="card-header d-flex justify-content-between align-items-center">
                <span class="fw-bold">${qna.title}</span>
                <c:if test="${qna.secret}">
                    <span class="badge bg-secondary">비밀글</span>
                </c:if>
            </div>
            <div class="card-body">
                <div class="text-muted small mb-3">
                    작성자: ${qna.member.userId} &nbsp;|&nbsp;
                    작성일: ${qna.createdAt.toString().substring(0, 16).replace('T', ' ')}
                    <c:if test="${qna.product != null}">
                        &nbsp;|&nbsp; 상품: ${qna.product.name}
                    </c:if>
                </div>
                <p style="white-space: pre-wrap;">${qna.content}</p>
            </div>
        </div>

        <!-- 답변 영역 -->
        <div class="card shadow-sm mb-4">
            <div class="card-header fw-bold">
                답변
                <c:if test="${qna.answered}">
                    <span class="badge bg-success ms-2">완료</span>
                </c:if>
            </div>
            <div class="card-body">
                <c:if test="${qna.answered}">
                    <p class="text-muted small mb-2">
                        답변일: ${qna.answeredAt.toString().substring(0, 16).replace('T', ' ')}
                    </p>
                    <p style="white-space: pre-wrap;">${qna.answer}</p>
                    <hr>
                    <p class="text-muted small mb-2">답변 수정</p>
                </c:if>
                <form action="${pageContext.request.contextPath}/admin/qna/${qna.qnaId}/answer" method="post">
                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                    <textarea name="answer" class="form-control mb-3" rows="5"
                              placeholder="답변을 입력하세요" required>${qna.answer}</textarea>
                    <button type="submit" class="btn btn-dark btn-sm">
                        ${qna.answered ? '답변 수정' : '답변 등록'}
                    </button>
                </form>
            </div>
        </div>

        <!-- 삭제 -->
        <form action="${pageContext.request.contextPath}/admin/qna/${qna.qnaId}/delete"
              method="post" onsubmit="return confirm('문의를 삭제하시겠습니까?')">
            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
            <button class="btn btn-outline-danger btn-sm">문의 삭제</button>
        </form>

    </main>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
