<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>${product.name} — K-Evolution</title>
    <%@ include file="/WEB-INF/views/layout/meta.jsp" %>
    <style>
        .product-main-img {
            width: 100%;
            aspect-ratio: 3 / 4;
            object-fit: cover;
            border-radius: var(--kv-radius);
        }
        .img-placeholder {
            width: 100%;
            aspect-ratio: 3 / 4;
            background: #f1f3f5;
            border-radius: var(--kv-radius);
            display: flex;
            align-items: center;
            justify-content: center;
        }
        .product-sub-img {
            height: 90px;
            width: 90px;
            object-fit: cover;
            border-radius: 8px;
            border: 1px solid #e9ecef;
            cursor: pointer;
            transition: transform 0.15s;
        }
        .product-sub-img:hover { transform: scale(1.05); }
        .price-tag {
            font-size: 2rem;
            font-weight: 800;
            letter-spacing: -0.03em;
            color: var(--kv-primary);
        }
        .desc-box {
            white-space: pre-wrap;
            font-size: 0.88rem;
            line-height: 1.85;
            color: var(--kv-muted);
        }
    </style>
</head>
<body class="bg-light theme-popart">

<%@ include file="/WEB-INF/views/layout/header.jsp" %>

<div class="container py-4">

    <a href="${pageContext.request.contextPath}/products" class="back-link mb-4">
        <i class="bi bi-chevron-left"></i> 목록으로
    </a>

    <div class="row g-5 mt-1">

        <%-- ── 이미지 ── --%>
        <div class="col-md-6">
            <c:choose>
                <c:when test="${not empty product.imageUrl}">
                    <img src="${product.imageUrl}" alt="${product.name}" class="product-main-img" id="mainImg">
                </c:when>
                <c:otherwise>
                    <div class="img-placeholder">
                        <i class="bi bi-image text-muted" style="font-size: 4rem;"></i>
                    </div>
                </c:otherwise>
            </c:choose>

            <%-- ── 추가 이미지 갤러리 ── --%>
            <c:if test="${not empty images}">
                <div class="d-flex flex-wrap gap-2 mt-3">
                    <c:forEach var="img" items="${images}">
                        <img src="${img.imageUrl}" alt="${product.name}" class="product-sub-img">
                    </c:forEach>
                </div>
            </c:if>
        </div>

        <%-- ── 상품 정보 ── --%>
        <div class="col-md-6 d-flex flex-column">

            <c:if test="${not empty product.category}">
                <span class="badge bg-light text-dark border mb-2 align-self-start">
                    ${product.category.label}
                </span>
            </c:if>

            <h1 class="fs-3 fw-bold mb-3">${product.name}</h1>

            <div class="price-tag mb-2">
                <fmt:formatNumber value="${product.price}" type="number" groupingUsed="true"/>원
            </div>

            <%-- 별점 요약 (리뷰 영역으로 스크롤) --%>
            <c:if test="${reviewCount > 0}">
                <a href="#reviews" class="text-decoration-none text-dark mb-4 d-inline-flex align-items-center gap-1">
                    <span class="text-warning">
                        <c:forEach begin="1" end="5" var="i"><i class="bi ${i <= reviewAvg ? 'bi-star-fill' : 'bi-star'}"></i></c:forEach>
                    </span>
                    <span class="fw-semibold">${reviewAvg}</span>
                    <span class="text-muted small">리뷰 ${reviewCount}개</span>
                </a>
            </c:if>

            <%-- 재고 상태 (옵션 재고 합계) --%>
            <div class="mb-4">
                <c:choose>
                    <c:when test="${totalStock == 0}">
                        <span class="badge bg-secondary px-3 py-2 fs-6">품절</span>
                    </c:when>
                    <c:when test="${totalStock <= 5}">
                        <span class="text-danger small fw-semibold">
                            <i class="bi bi-exclamation-circle"></i> 재고 ${totalStock}개 남음
                        </span>
                    </c:when>
                    <c:otherwise>
                        <span class="text-success small fw-semibold">
                            <i class="bi bi-check-circle"></i> 재고 있음
                        </span>
                    </c:otherwise>
                </c:choose>
            </div>

            <%-- 장바구니 담기 결과 안내 (버튼 바로 위, 즉시 클릭 가능) --%>
            <c:if test="${not empty successMsg}">
                <div class="alert alert-dark d-flex align-items-center justify-content-between gap-2 py-2 mb-3">
                    <span class="d-flex align-items-center gap-2 fw-semibold">
                        <i class="bi bi-check-circle-fill"></i> ${successMsg}
                    </span>
                    <a href="${pageContext.request.contextPath}/cart" class="btn btn-light btn-sm fw-semibold flex-shrink-0">
                        장바구니로 이동 <i class="bi bi-arrow-right"></i>
                    </a>
                </div>
            </c:if>
            <c:if test="${not empty errorMsg}">
                <div class="alert alert-danger d-flex align-items-center gap-2 py-2 mb-3">
                    <i class="bi bi-exclamation-circle-fill"></i> ${errorMsg}
                </div>
            </c:if>

            <%-- 장바구니 버튼 --%>
            <div class="d-grid mb-5">
                <c:choose>
                    <c:when test="${totalStock == 0}">
                        <button class="btn btn-dark btn-lg" disabled>
                            <i class="bi bi-cart-x me-1"></i> 품절된 상품입니다
                        </button>
                    </c:when>
                    <c:otherwise>
                        <form action="${pageContext.request.contextPath}/cart/add" method="post">
                            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                            <input type="hidden" name="productId" value="${product.productId}"/>

                            <%-- ── 옵션 선택 (색상/사이즈 등) ── --%>
                            <c:if test="${not empty optionGroups}">
                                <div class="mb-3 text-start">
                                    <c:forEach var="group" items="${optionGroups}">
                                        <label class="form-label small fw-semibold mb-1">${group.key}</label>
                                        <select name="optionIds" class="form-select mb-2 option-select" required>
                                            <option value="" selected disabled>${group.key} 선택</option>
                                            <c:forEach var="opt" items="${group.value}">
                                                <option value="${opt.optionId}"
                                                    data-label="${opt.optionValue}" data-stock="${opt.stock}"
                                                    <c:if test="${opt.stock == 0}">disabled</c:if>>
                                                    ${opt.optionValue}<c:if test="${opt.stock == 0}"> — 품절</c:if>
                                                </option>
                                            </c:forEach>
                                        </select>
                                    </c:forEach>
                                </div>

                                <%-- ── 선택된 옵션 카드 (옵션 선택 후 표시): 이름 + 수량 + 금액 ── --%>
                                <div id="selectedOptionCard" class="border rounded-3 bg-white p-3 mb-2 d-none">
                                    <div class="d-flex justify-content-between align-items-start mb-2">
                                        <span class="fw-semibold small" id="selOptLabel"></span>
                                        <button type="button" class="btn-close btn-sm" id="selOptClear" aria-label="선택 해제"></button>
                                    </div>
                                    <div class="d-flex justify-content-between align-items-center">
                                        <div class="input-group" style="width: 130px;">
                                            <button class="btn btn-outline-secondary" type="button" id="qtyMinus" aria-label="수량 감소">−</button>
                                            <input type="number" name="quantity" id="qtyInput"
                                                   class="form-control text-center" value="1" min="1" inputmode="numeric">
                                            <button class="btn btn-outline-secondary" type="button" id="qtyPlus" aria-label="수량 증가">+</button>
                                        </div>
                                        <span class="fw-bold" id="linePrice"></span>
                                    </div>
                                    <div class="text-muted small mt-1" id="selOptStock"></div>
                                </div>

                                <%-- ── 합계 ── --%>
                                <div id="totalRow" class="d-flex justify-content-between align-items-center border-top pt-2 mb-3 d-none">
                                    <span class="text-muted small">총 <span id="totalQty">0</span>개</span>
                                    <span class="fs-5 fw-bold" id="totalPrice"></span>
                                </div>
                            </c:if>

                            <%-- ── 옵션이 없는 상품: 수량 바로 선택 ── --%>
                            <c:if test="${empty optionGroups}">
                                <div class="d-flex align-items-center gap-2 mb-3">
                                    <label class="form-label small fw-semibold mb-0" for="qtyInput">수량</label>
                                    <div class="input-group" style="width: 140px;">
                                        <button class="btn btn-outline-secondary" type="button" id="qtyMinus" aria-label="수량 감소">−</button>
                                        <input type="number" name="quantity" id="qtyInput"
                                               class="form-control text-center" value="1"
                                               min="1" max="${totalStock}" inputmode="numeric">
                                        <button class="btn btn-outline-secondary" type="button" id="qtyPlus" aria-label="수량 증가">+</button>
                                    </div>
                                    <span class="text-muted small">재고 ${totalStock}개</span>
                                </div>
                            </c:if>

                            <%-- 장바구니 / 구매하기 — 버튼 대신 아이콘+텍스트 클릭 링크로 --%>
                            <div class="d-flex gap-4 mt-1">
                                <button type="submit" class="btn btn-link text-decoration-none p-0 text-dark fw-semibold">
                                    <i class="bi bi-cart-plus me-1"></i> 장바구니
                                </button>
                                <button type="submit"
                                        formaction="${pageContext.request.contextPath}/order/direct"
                                        class="btn btn-link text-decoration-none p-0 text-dark fw-semibold">
                                    <i class="bi bi-bag-check me-1"></i> 구매하기
                                </button>
                            </div>
                        </form>
                    </c:otherwise>
                </c:choose>

                <%-- 찜(위시리스트) — 버튼 대신 하트+텍스트 클릭 링크로 깔끔하게 --%>
                <button type="button" id="wishBtn" data-wished="${wished}"
                        class="btn btn-link text-decoration-none p-0 mt-3 ${wished ? 'text-danger' : 'text-secondary'}">
                    <i id="wishIcon" class="bi ${wished ? 'bi-heart-fill' : 'bi-heart'} me-1"></i>
                    <span id="wishLabel">${wished ? '찜 완료' : '찜하기'}</span>
                    <span id="wishCount">${wishCount}</span>
                </button>
            </div>

            <hr>

            <%-- 상품 설명 --%>
            <c:if test="${not empty product.description}">
                <h6 class="fw-bold mb-2">상품 설명</h6>
                <div class="desc-box"><c:out value="${product.description}"/></div>
            </c:if>

        </div>
    </div>

    <%-- ── 상품 리뷰 ── --%>
    <div id="reviews" class="mt-5 pt-4 border-top">
        <div class="d-flex align-items-center gap-2 mb-4">
            <h5 class="fw-bold mb-0">상품 리뷰</h5>
            <span class="text-muted">${reviewCount}</span>
            <c:if test="${reviewCount > 0}">
                <span class="ms-2 text-warning">
                    <c:forEach begin="1" end="5" var="i"><i class="bi ${i <= reviewAvg ? 'bi-star-fill' : 'bi-star'}"></i></c:forEach>
                </span>
                <span class="fw-semibold">${reviewAvg}</span>
            </c:if>
        </div>

        <%-- AI 리뷰 요약: 후기가 충분히 쌓였고 요약이 생성된 경우에만 노출 --%>
        <c:if test="${not empty reviewSummary}">
            <div class="card border-0 shadow-sm mb-4" style="background:#f6f5ff;border-left:4px solid #5b5bd6 !important;">
                <div class="card-body">
                    <div class="d-flex align-items-center gap-2 mb-2">
                        <i class="bi bi-stars" style="color:#5b5bd6;font-size:1.1rem"></i>
                        <span class="fw-bold" style="color:#5b5bd6">AI 리뷰 요약</span>
                        <span class="badge rounded-pill text-bg-light text-muted">구매 후기 기반</span>
                    </div>
                    <div style="white-space:pre-wrap; font-size:.92rem; line-height:1.7;"><c:out value="${reviewSummary}"/></div>
                </div>
            </div>
        </c:if>

        <c:choose>
            <c:when test="${empty reviews}">
                <div class="text-center text-muted py-5">
                    <i class="bi bi-chat-square-heart" style="font-size:2rem"></i>
                    <div class="mt-2">아직 작성된 리뷰가 없습니다.</div>
                    <div class="small">이 상품을 구매하셨다면 첫 리뷰를 남겨보세요!</div>
                </div>
            </c:when>
            <c:otherwise>
                <c:forEach var="r" items="${reviews}">
                    <div class="card shadow-sm mb-3">
                        <div class="card-body">
                            <div class="d-flex justify-content-between align-items-center mb-2">
                                <span class="text-warning">
                                    <c:forEach begin="1" end="5" var="i"><i class="bi ${i <= r.rating ? 'bi-star-fill' : 'bi-star'}"></i></c:forEach>
                                </span>
                                <span class="text-muted small">
                                    <c:out value="${fn:substring(r.member.name, 0, 1)}"/>○○ · ${fn:substring(r.createdAt, 0, 10)}
                                </span>
                            </div>
                            <div class="mb-2" style="white-space:pre-wrap; font-size:.9rem;"><c:out value="${r.content}"/></div>
                            <c:if test="${not empty r.images}">
                                <div class="d-flex flex-wrap gap-2">
                                    <c:forEach var="img" items="${r.images}">
                                        <img src="${img.imageUrl}" alt="리뷰 이미지"
                                             style="width:90px;height:90px;object-fit:cover;border-radius:8px;border:1px solid #e9ecef;cursor:pointer"
                                             onclick="window.open(this.src)">
                                    </c:forEach>
                                </div>
                            </c:if>
                        </div>
                    </div>
                </c:forEach>
                <c:if test="${reviewCount > 20}">
                    <div class="text-center text-muted small mt-3">최근 20개의 리뷰만 표시됩니다.</div>
                </c:if>
            </c:otherwise>
        </c:choose>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    // 추가 이미지를 클릭하면 대표(메인) 이미지로 교체한다.
    document.querySelectorAll('.product-sub-img').forEach(function (thumb) {
        thumb.addEventListener('click', function () {
            const main = document.getElementById('mainImg');
            if (main) main.src = this.src;
        });
    });

    // 수량 스텝퍼 + 옵션 선택 카드
    (function () {
        const input = document.getElementById('qtyInput');
        if (!input) return;
        const minus = document.getElementById('qtyMinus');
        const plus  = document.getElementById('qtyPlus');
        const UNIT_PRICE = Number('${product.price}') || 0;
        const won = function (n) { return n.toLocaleString('ko-KR') + '원'; };

        // 옵션 관련 요소 (옵션 없는 상품이면 null)
        const selects = Array.prototype.slice.call(document.querySelectorAll('.option-select'));
        const hasOptions = selects.length > 0;
        const card       = document.getElementById('selectedOptionCard');
        const totalRow   = document.getElementById('totalRow');
        const selLabel   = document.getElementById('selOptLabel');
        const selStock   = document.getElementById('selOptStock');
        const linePrice  = document.getElementById('linePrice');
        const totalQty   = document.getElementById('totalQty');
        const totalPrice = document.getElementById('totalPrice');
        const clearBtn   = document.getElementById('selOptClear');

        // 현재 허용 최대 수량(재고). 옵션 상품은 선택된 옵션 재고의 최솟값.
        function currentMax() {
            if (!hasOptions) return parseInt(input.getAttribute('max') || '0', 10);
            let m = Infinity;
            selects.forEach(function (s) {
                const o = s.options[s.selectedIndex];
                if (o && o.value) m = Math.min(m, parseInt(o.getAttribute('data-stock') || '0', 10));
            });
            return m === Infinity ? 0 : m;
        }
        function allSelected() {
            return selects.every(function (s) { return s.value; });
        }
        function clamp() {
            const max = currentMax();
            let v = parseInt(input.value, 10);
            if (isNaN(v) || v < 1) v = 1;
            if (max > 0 && v > max) v = max;
            input.value = v;
        }
        function refresh() {
            clamp();
            const v = parseInt(input.value, 10) || 1;
            if (linePrice)  linePrice.textContent  = won(UNIT_PRICE * v);
            if (totalQty)   totalQty.textContent   = v;
            if (totalPrice) totalPrice.textContent = won(UNIT_PRICE * v);
        }

        // 옵션 상품: 선택 여부에 따라 카드 표시/숨김
        function syncCard() {
            if (!hasOptions) return;
            if (allSelected()) {
                const labels = selects.map(function (s) {
                    return s.options[s.selectedIndex].getAttribute('data-label');
                }).join(' / ');
                selLabel.textContent = labels;
                selStock.textContent = '재고 ' + currentMax() + '개';
                card.classList.remove('d-none');
                totalRow.classList.remove('d-none');
                input.value = 1;
                refresh();
            } else {
                card.classList.add('d-none');
                totalRow.classList.add('d-none');
            }
        }

        minus.addEventListener('click', function () { input.value = (parseInt(input.value, 10) || 1) - 1; refresh(); });
        plus.addEventListener('click',  function () { input.value = (parseInt(input.value, 10) || 0) + 1; refresh(); });
        input.addEventListener('change', refresh);
        selects.forEach(function (s) { s.addEventListener('change', syncCard); });
        if (clearBtn) clearBtn.addEventListener('click', function () {
            selects.forEach(function (s) { s.selectedIndex = 0; });
            syncCard();
        });

        if (hasOptions) syncCard(); else refresh();
    })();

    // 찜(위시리스트) 토글 — 로그인 안 했으면 로그인 페이지로 이동
    (function () {
        const btn = document.getElementById('wishBtn');
        if (!btn) return;
        const ctx = '${pageContext.request.contextPath}';
        const CSRF_TOKEN = '${_csrf.token}', CSRF_HEADER = '${_csrf.headerName}';
        btn.addEventListener('click', function () {
            fetch(ctx + '/wishlist/${product.productId}/toggle', {
                method: 'POST',
                headers: { [CSRF_HEADER]: CSRF_TOKEN, 'X-Requested-With': 'XMLHttpRequest' }
            }).then(function (res) {
                if (res.status === 401 || res.status === 403) {
                    alert('로그인이 필요한 기능입니다.');
                    location.href = ctx + '/auth/login';
                    return null;
                }
                return res.json();
            }).then(function (data) {
                if (!data) return;
                const icon = document.getElementById('wishIcon');
                const label = document.getElementById('wishLabel');
                const count = document.getElementById('wishCount');
                let n = parseInt(count.textContent || '0', 10);
                if (data.wished) {
                    btn.classList.remove('text-secondary'); btn.classList.add('text-danger');
                    icon.classList.remove('bi-heart'); icon.classList.add('bi-heart-fill');
                    label.textContent = '찜 완료'; count.textContent = n + 1;
                } else {
                    btn.classList.remove('text-danger'); btn.classList.add('text-secondary');
                    icon.classList.remove('bi-heart-fill'); icon.classList.add('bi-heart');
                    label.textContent = '찜하기'; count.textContent = Math.max(0, n - 1);
                }
            }).catch(function () { alert('잠시 후 다시 시도해주세요.'); });
        });
    })();
</script>
</body>
</html>
