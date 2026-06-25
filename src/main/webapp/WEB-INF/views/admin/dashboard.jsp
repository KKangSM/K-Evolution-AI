<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>대시보드 · K-Evolution 관리자</title>
    <%@ include file="/WEB-INF/views/layout/meta.jsp" %>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin.css">
    <style>
        .stat-link { cursor: pointer; transition: transform .12s ease, box-shadow .12s ease, border-color .12s ease; }
        .stat-link:hover { transform: translateY(-2px); box-shadow: 0 6px 18px rgba(17, 24, 39, .08); border-color: #dfe3e7; }
        .stat-link:hover .stat-value { color: var(--kv-primary); }
    </style>
</head>
<body class="admin-body">

<%@ include file="/WEB-INF/views/layout/admin-topbar.jsp" %>

<div class="admin-layout">
    <%@ include file="/WEB-INF/views/layout/admin-sidebar.jsp" %>

    <main class="admin-main">

        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h4 class="page-title mb-1">대시보드</h4>
                <p class="text-muted small mb-0">쇼핑몰 운영 현황 요약</p>
            </div>
            <a href="${pageContext.request.contextPath}/admin/products/register" class="btn btn-dark">+ 상품 등록</a>
        </div>

        <!-- 핵심 지표 -->
        <div class="row g-3 mb-4">
            <div class="col-6 col-lg-3">
                <a href="${pageContext.request.contextPath}/admin/members"
                   class="card stat-card h-100 stat-link text-decoration-none text-reset">
                    <div class="card-body d-flex align-items-center gap-3">
                        <div class="stat-icon bg-soft-blue"><i class="bi bi-people text-primary"></i></div>
                        <div>
                            <div class="stat-label">전체 회원</div>
                            <div class="stat-value"><fmt:formatNumber value="${memberCount}"/></div>
                        </div>
                    </div>
                </a>
            </div>
            <div class="col-6 col-lg-3">
                <a href="${pageContext.request.contextPath}/admin/products"
                   class="card stat-card h-100 stat-link text-decoration-none text-reset">
                    <div class="card-body d-flex align-items-center gap-3">
                        <div class="stat-icon bg-soft-purple"><i class="bi bi-box-seam" style="color:#7c4dff"></i></div>
                        <div>
                            <div class="stat-label">등록 상품</div>
                            <div class="stat-value"><fmt:formatNumber value="${productCount}"/></div>
                        </div>
                    </div>
                </a>
            </div>
            <div class="col-6 col-lg-3">
                <div class="card stat-card h-100">
                    <div class="card-body d-flex align-items-center gap-3">
                        <div class="stat-icon bg-soft-green"><i class="bi bi-receipt text-success"></i></div>
                        <div>
                            <div class="stat-label">전체 주문</div>
                            <div class="stat-value"><fmt:formatNumber value="${orderCount}"/></div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-6 col-lg-3">
                <div class="card stat-card h-100">
                    <div class="card-body d-flex align-items-center gap-3">
                        <div class="stat-icon bg-soft-amber"><i class="bi bi-cash-coin" style="color:#d98e00"></i></div>
                        <div>
                            <div class="stat-label">누적 매출 (결제완료)</div>
                            <div class="stat-value"><fmt:formatNumber value="${paidSales}"/><span class="fs-6 fw-normal">원</span></div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- 처리 필요 항목 -->
        <h6 class="text-muted mb-2">처리 필요</h6>
        <div class="row g-3 mb-4">
            <div class="col-6 col-lg-4">
                <div class="card stat-card h-100">
                    <div class="card-body d-flex align-items-center justify-content-between">
                        <span class="stat-label">결제 대기 주문</span>
                        <span class="badge ${pendingOrderCount > 0 ? 'bg-warning text-dark' : 'bg-light text-muted'} fs-6">
                            <fmt:formatNumber value="${pendingOrderCount}"/>건
                        </span>
                    </div>
                </div>
            </div>
            <div class="col-6 col-lg-4">
                <a href="${pageContext.request.contextPath}/admin/products"
                   class="card stat-card h-100 stat-link text-decoration-none text-reset">
                    <div class="card-body d-flex align-items-center justify-content-between">
                        <span class="stat-label">재고 부족 상품 (5개 미만)</span>
                        <span class="badge ${lowStockCount > 0 ? 'bg-danger' : 'bg-light text-muted'} fs-6">
                            <fmt:formatNumber value="${lowStockCount}"/>개
                        </span>
                    </div>
                </a>
            </div>
            <div class="col-6 col-lg-4">
                <a href="${pageContext.request.contextPath}/admin/qna"
                   class="card stat-card h-100 stat-link text-decoration-none text-reset">
                    <div class="card-body d-flex align-items-center justify-content-between">
                        <span class="stat-label">미답변 문의</span>
                        <span class="badge ${unansweredQna > 0 ? 'bg-primary' : 'bg-light text-muted'} fs-6">
                            <fmt:formatNumber value="${unansweredQna}"/>건
                        </span>
                    </div>
                </a>
            </div>
        </div>

        <!-- 최근 주문 -->
        <div class="card stat-card">
            <div class="card-body">
                <div class="d-flex justify-content-between align-items-center mb-3">
                    <h6 class="mb-0 fw-bold">최근 주문</h6>
                </div>
                <div class="table-responsive">
                    <table class="table table-hover align-middle mb-0">
                        <thead class="table-light">
                        <tr>
                            <th style="width:70px">번호</th>
                            <th>주문자</th>
                            <th class="text-end">결제금액</th>
                            <th style="width:110px" class="text-center">상태</th>
                            <th style="width:180px">주문일시</th>
                        </tr>
                        </thead>
                        <tbody>
                        <c:if test="${empty recentOrders}">
                            <tr><td colspan="5" class="text-center text-muted py-4">주문 내역이 없습니다.</td></tr>
                        </c:if>
                        <c:forEach var="order" items="${recentOrders}">
                            <tr>
                                <td class="text-muted">#${order.orderId}</td>
                                <td class="fw-semibold">${order.receiverName}</td>
                                <td class="text-end">
                                    <fmt:formatNumber value="${order.finalPrice}" type="number" groupingUsed="true"/>원
                                </td>
                                <td class="text-center">
                                    <c:choose>
                                        <c:when test="${order.status == 'PAID'}"><span class="badge bg-success">결제완료</span></c:when>
                                        <c:when test="${order.status == 'PENDING'}"><span class="badge bg-warning text-dark">결제대기</span></c:when>
                                        <c:otherwise><span class="badge bg-secondary">취소</span></c:otherwise>
                                    </c:choose>
                                </td>
                                <td class="text-muted small">${order.createdAt}</td>
                            </tr>
                        </c:forEach>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

    </main>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
