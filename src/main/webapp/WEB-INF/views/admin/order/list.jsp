<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="ui" tagdir="/WEB-INF/tags" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>주문 관리 · K-Evolution 관리자</title>
    <%@ include file="/WEB-INF/views/layout/meta.jsp" %>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin.css">
</head>
<body class="admin-body">

<%@ include file="/WEB-INF/views/layout/admin-topbar.jsp" %>

<div class="admin-layout">
    <%@ include file="/WEB-INF/views/layout/admin-sidebar.jsp" %>

    <main class="admin-main">

        <div class="d-flex justify-content-between align-items-center mb-3">
            <h4 class="page-title mb-1">주문 관리</h4>
        </div>

        <%@ include file="/WEB-INF/views/layout/flash-toast.jsp" %>

        <!-- 상태 필터 + 검색 -->
        <form method="get" action="${pageContext.request.contextPath}/admin/orders" class="row g-2 mb-3">
            <div class="col-auto">
                <select name="status" class="form-select form-select-sm">
                    <option value="" ${empty statusFilter ? 'selected' : ''}>전체 상태</option>
                    <option value="PAID" ${statusFilter == 'PAID' ? 'selected' : ''}>결제완료</option>
                    <option value="PENDING" ${statusFilter == 'PENDING' ? 'selected' : ''}>결제대기</option>
                    <option value="CANCELLED" ${statusFilter == 'CANCELLED' ? 'selected' : ''}>취소</option>
                </select>
            </div>
            <div class="col-auto flex-fill" style="max-width:280px">
                <input type="text" name="search" class="form-control form-control-sm"
                       value="<c:out value='${search}'/>" placeholder="주문자명 · 연락처 검색">
            </div>
            <div class="col-auto">
                <button type="submit" class="btn btn-dark btn-sm px-3"><i class="bi bi-search"></i> 검색</button>
                <a href="${pageContext.request.contextPath}/admin/orders" class="btn btn-outline-secondary btn-sm">초기화</a>
            </div>
        </form>

        <div class="card shadow-sm">
            <div class="card-body p-0">
                <table class="table table-hover mb-0 align-middle">
                    <thead class="table-light">
                    <tr>
                        <th class="ps-4" style="width:80px">주문번호</th>
                        <th style="width:100px">주문자</th>
                        <th>상품</th>
                        <th style="width:110px">결제금액</th>
                        <th style="width:130px">주문일</th>
                        <th style="width:90px">주문상태</th>
                        <th style="width:90px">배송상태</th>
                        <th style="width:70px" class="text-end pe-4">관리</th>
                    </tr>
                    </thead>
                    <tbody>
                    <c:forEach var="order" items="${orders.content}">
                        <c:set var="dv" value="${deliveryMap[order.orderId]}"/>
                        <tr>
                            <td class="ps-4 text-muted small">#${order.orderId}</td>
                            <td class="small fw-medium"><c:out value="${order.receiverName}"/></td>
                            <td class="small">
                                <c:out value="${order.orderItems[0].productName}"/>
                                <c:if test="${fn:length(order.orderItems) > 1}">
                                    <span class="text-muted">외 ${fn:length(order.orderItems) - 1}건</span>
                                </c:if>
                            </td>
                            <td class="small fw-semibold"><fmt:formatNumber value="${order.finalPrice}" type="number"/>원</td>
                            <td class="small text-muted">${order.createdAt.toString().substring(0, 16).replace('T', ' ')}</td>
                            <td>
                                <c:choose>
                                    <c:when test="${order.status == 'PAID'}"><span class="badge bg-success">결제완료</span></c:when>
                                    <c:when test="${order.status == 'PENDING'}"><span class="badge bg-secondary">결제대기</span></c:when>
                                    <c:otherwise><span class="badge bg-danger">취소</span></c:otherwise>
                                </c:choose>
                            </td>
                            <td>
                                <c:choose>
                                    <c:when test="${empty dv}"><span class="text-muted small">-</span></c:when>
                                    <c:when test="${dv.status == 'READY'}"><span class="badge bg-light text-dark border">배송준비</span></c:when>
                                    <c:when test="${dv.status == 'SHIPPED'}"><span class="badge bg-info text-dark">출고</span></c:when>
                                    <c:when test="${dv.status == 'IN_TRANSIT'}"><span class="badge bg-primary">배송중</span></c:when>
                                    <c:otherwise><span class="badge bg-dark">배송완료</span></c:otherwise>
                                </c:choose>
                            </td>
                            <td class="text-end pe-4">
                                <button type="button" class="btn btn-sm btn-outline-secondary"
                                        data-bs-toggle="modal" data-bs-target="#orderModal${order.orderId}">상세</button>
                            </td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty orders.content}">
                        <tr><td colspan="8" class="text-center text-muted py-4">주문이 없습니다.</td></tr>
                    </c:if>
                    </tbody>
                </table>
            </div>
        </div>

        <ui:pagination page="${orders}"/>

    </main>
</div>

<%-- 주문별 상세/처리 모달 --%>
<c:forEach var="order" items="${orders.content}">
    <c:set var="dv" value="${deliveryMap[order.orderId]}"/>
    <div class="modal fade" id="orderModal${order.orderId}" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-lg modal-dialog-centered modal-dialog-scrollable">
            <div class="modal-content">
                <div class="modal-header">
                    <h6 class="modal-title fw-bold">주문 #${order.orderId}</h6>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="닫기"></button>
                </div>
                <div class="modal-body">

                    <%-- 주문 상품 --%>
                    <h6 class="fw-bold small text-muted mb-2">주문 상품</h6>
                    <c:forEach var="item" items="${order.orderItems}">
                        <div class="d-flex justify-content-between small py-1 border-bottom">
                            <span><c:out value="${item.productName}"/> <span class="text-muted">x${item.quantity}</span></span>
                            <span><fmt:formatNumber value="${item.totalPrice}" type="number"/>원</span>
                        </div>
                    </c:forEach>
                    <div class="d-flex justify-content-between fw-bold mt-2 mb-3">
                        <span>결제금액</span>
                        <span class="text-danger"><fmt:formatNumber value="${order.finalPrice}" type="number"/>원</span>
                    </div>

                    <%-- 배송지 / 결제 --%>
                    <div class="row g-3 mb-3">
                        <div class="col-md-6">
                            <h6 class="fw-bold small text-muted mb-2">배송지</h6>
                            <div class="small"><c:out value="${order.receiverName}"/> · <c:out value="${order.receiverPhone}"/></div>
                            <div class="small text-muted"><c:out value="${order.address}"/></div>
                        </div>
                        <div class="col-md-6">
                            <h6 class="fw-bold small text-muted mb-2">결제 정보</h6>
                            <c:choose>
                                <c:when test="${not empty order.payment}">
                                    <div class="small">수단: <c:out value="${order.payment.method}"/></div>
                                    <div class="small text-muted">
                                        승인: ${order.payment.approvedAt != null ? order.payment.approvedAt.toString().substring(0,16).replace('T',' ') : '-'}
                                    </div>
                                </c:when>
                                <c:otherwise><div class="small text-muted">결제 정보 없음</div></c:otherwise>
                            </c:choose>
                        </div>
                    </div>

                    <%-- 배송 처리 --%>
                    <c:if test="${order.status == 'PAID'}">
                        <div class="border rounded-3 p-3 bg-light">
                            <h6 class="fw-bold small mb-3">배송 처리</h6>
                            <c:choose>
                                <%-- 아직 송장 미등록(배송정보 없음 또는 배송준비) → 송장 등록 --%>
                                <c:when test="${empty dv or dv.status == 'READY'}">
                                    <form action="${pageContext.request.contextPath}/admin/orders/${order.orderId}/ship"
                                          method="post" class="row g-2">
                                        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                                        <div class="col-4">
                                            <input type="text" name="courier" class="form-control form-control-sm"
                                                   placeholder="택배사" required>
                                        </div>
                                        <div class="col-5">
                                            <input type="text" name="trackingNo" class="form-control form-control-sm"
                                                   placeholder="송장번호" required>
                                        </div>
                                        <div class="col-3 d-grid">
                                            <button type="submit" class="btn btn-dark btn-sm">배송 시작</button>
                                        </div>
                                    </form>
                                </c:when>
                                <%-- 송장 등록 이후 → 현재 배송정보 + 다음 단계 버튼 --%>
                                <c:otherwise>
                                    <div class="small mb-2">
                                        <c:out value="${dv.courier}"/> · <c:out value="${dv.trackingNo}"/>
                                    </div>
                                    <c:choose>
                                        <c:when test="${dv.status == 'SHIPPED'}">
                                            <form action="${pageContext.request.contextPath}/admin/orders/${order.orderId}/delivery" method="post">
                                                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                                                <input type="hidden" name="action" value="transit"/>
                                                <button type="submit" class="btn btn-primary btn-sm">배송중으로 변경</button>
                                            </form>
                                        </c:when>
                                        <c:when test="${dv.status == 'IN_TRANSIT'}">
                                            <form action="${pageContext.request.contextPath}/admin/orders/${order.orderId}/delivery" method="post">
                                                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                                                <input type="hidden" name="action" value="complete"/>
                                                <button type="submit" class="btn btn-dark btn-sm">배송완료로 변경</button>
                                            </form>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="badge bg-dark">배송완료</span>
                                        </c:otherwise>
                                    </c:choose>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </c:if>
                </div>
                <div class="modal-footer justify-content-between">
                    <c:if test="${order.status != 'CANCELLED'}">
                        <form action="${pageContext.request.contextPath}/admin/orders/${order.orderId}/cancel"
                              method="post" onsubmit="return confirm('주문을 취소하시겠습니까?')">
                            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                            <button type="submit" class="btn btn-outline-danger btn-sm">주문 취소</button>
                        </form>
                    </c:if>
                    <button type="button" class="btn btn-outline-secondary btn-sm ms-auto" data-bs-dismiss="modal">닫기</button>
                </div>
            </div>
        </div>
    </div>
</c:forEach>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
