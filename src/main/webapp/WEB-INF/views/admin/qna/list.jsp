<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>문의 관리 · K-Evolution 관리자</title>
    <%@ include file="/WEB-INF/views/layout/meta.jsp" %>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin.css">
</head>
<body class="admin-body">

<%@ include file="/WEB-INF/views/layout/admin-topbar.jsp" %>

<div class="admin-layout">
    <%@ include file="/WEB-INF/views/layout/admin-sidebar.jsp" %>

    <main class="admin-main">

        <div class="mb-4">
            <h4 class="page-title mb-1">문의 관리</h4>
            <p class="text-muted small mb-0">행을 클릭하면 상세 내용과 답변 창이 열립니다.</p>
        </div>

        <%@ include file="/WEB-INF/views/layout/flash-toast.jsp" %>

        <div class="card shadow-sm">
            <div class="card-body p-0">
                <table class="table table-hover mb-0 align-middle">
                    <thead class="table-light">
                    <tr>
                        <th class="ps-4" style="width:60px">No</th>
                        <th>제목</th>
                        <th style="width:100px">작성자</th>
                        <th style="width:80px">비밀글</th>
                        <th style="width:90px">상태</th>
                        <th style="width:90px">고객확인</th>
                        <th style="width:110px">작성일</th>
                    </tr>
                    </thead>
                    <tbody>
                    <c:forEach var="q" items="${qnaList.content}">
                        <tr style="cursor:pointer" data-bs-toggle="modal" data-bs-target="#qnaModal${q.qnaId}">
                            <td class="ps-4 text-muted small">${q.qnaId}</td>
                            <td class="fw-medium text-dark">${q.title}</td>
                            <td class="small">${q.member.userId}</td>
                            <td>
                                <c:if test="${q.secret}">
                                    <span class="badge bg-secondary">비밀</span>
                                </c:if>
                            </td>
                            <td>
                                <c:choose>
                                    <c:when test="${q.answered}">
                                        <span class="badge bg-success">답변완료</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="badge bg-warning text-dark">미답변</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td>
                                <c:if test="${q.answered}">
                                    <c:choose>
                                        <c:when test="${q.answerRead}">
                                            <span class="badge bg-light text-success border border-success">확인함</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="badge bg-light text-warning border border-warning">미확인</span>
                                        </c:otherwise>
                                    </c:choose>
                                </c:if>
                            </td>
                            <td class="pe-4 text-muted small">${q.createdAt.toString().substring(0, 10)}</td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty qnaList.content}">
                        <tr>
                            <td colspan="7" class="text-center text-muted py-4">등록된 문의가 없습니다.</td>
                        </tr>
                    </c:if>
                    </tbody>
                </table>
            </div>
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

    </main>
</div>

<%-- 문의별 상세/답변 모달 --%>
<c:forEach var="q" items="${qnaList.content}">
    <div class="modal fade" id="qnaModal${q.qnaId}" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-lg modal-dialog-centered modal-dialog-scrollable">
            <div class="modal-content">
                <div class="modal-header">
                    <h6 class="modal-title fw-bold">
                        ${q.title}
                        <c:if test="${q.secret}"><span class="badge bg-secondary ms-1">비밀글</span></c:if>
                    </h6>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="닫기"></button>
                </div>
                <div class="modal-body">
                    <!-- 문의 정보 -->
                    <div class="text-muted small mb-3">
                        작성자: ${q.member.userId}
                        &nbsp;|&nbsp; 작성일: ${q.createdAt.toString().substring(0, 16).replace('T', ' ')}
                        <c:if test="${q.product != null}">&nbsp;|&nbsp; 상품: ${q.product.name}</c:if>
                    </div>
                    <p style="white-space: pre-wrap;">${q.content}</p>

                    <!-- 답변 영역 -->
                    <div class="border-top pt-3 mt-3">
                        <div class="fw-bold mb-2">
                            답변
                            <c:if test="${q.answered}"><span class="badge bg-success ms-1">완료</span></c:if>
                        </div>
                        <c:if test="${q.answered}">
                            <p class="text-muted small mb-2">
                                답변일: ${q.answeredAt.toString().substring(0, 16).replace('T', ' ')}
                                &nbsp;|&nbsp; 고객 확인:
                                <c:choose>
                                    <c:when test="${q.answerRead}">
                                        <span class="text-success">확인함 (${q.answerReadAt.toString().substring(0, 16).replace('T', ' ')})</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="text-warning">미확인</span>
                                    </c:otherwise>
                                </c:choose>
                            </p>
                        </c:if>
                        <form action="${pageContext.request.contextPath}/admin/qna/${q.qnaId}/answer" method="post">
                            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                            <textarea name="answer" class="form-control mb-3" rows="5"
                                      placeholder="답변을 입력하세요" required>${q.answer}</textarea>
                            <div class="text-end">
                                <button type="button" class="btn btn-outline-secondary btn-sm" data-bs-dismiss="modal">닫기</button>
                                <button type="submit" class="btn btn-dark btn-sm">${q.answered ? '답변 수정' : '답변 등록'}</button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>
</c:forEach>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
