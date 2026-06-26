<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="isEdit" value="${not empty product}"/>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title><c:choose><c:when test="${isEdit}">상품 수정</c:when><c:otherwise>상품 등록</c:otherwise></c:choose> · K-Evolution 관리자</title>
    <%@ include file="/WEB-INF/views/layout/meta.jsp" %>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin.css">
</head>
<body class="admin-body">

<%@ include file="/WEB-INF/views/layout/admin-topbar.jsp" %>

<div class="admin-layout">
    <%@ include file="/WEB-INF/views/layout/admin-sidebar.jsp" %>

    <main class="admin-main">

        <h4 class="page-title mb-4">
            <c:choose>
                <c:when test="${isEdit}">상품 수정 <span class="text-muted fs-6">#${product.productId}</span></c:when>
                <c:otherwise>상품 등록</c:otherwise>
            </c:choose>
        </h4>

        <c:choose>
            <c:when test="${isEdit}">
                <c:url var="formAction" value="/admin/products/${product.productId}/edit"/>
            </c:when>
            <c:otherwise>
                <c:url var="formAction" value="/admin/products/register"/>
            </c:otherwise>
        </c:choose>

        <form action="${formAction}" method="post" enctype="multipart/form-data"
              class="card stat-card p-4" style="max-width:720px">
            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
            <c:if test="${isEdit}">
                <input type="hidden" name="existingImageUrl" value="${product.imageUrl}"/>
            </c:if>

            <div class="mb-3">
                <label class="form-label">상품명</label>
                <input type="text" name="name" class="form-control" required
                       value="${product.name}" placeholder="상품명을 입력하세요">
            </div>

            <div class="mb-3">
                <label class="form-label">카테고리</label>
                <select name="categoryId" id="categorySelect" class="form-select">
                    <option value="" data-name="">카테고리 없음</option>
                    <c:forEach var="cat" items="${categories}">
                        <option value="${cat.categoryId}" data-name="${cat.name}"
                            <c:if test="${isEdit and not empty product.category and product.category.categoryId == cat.categoryId}">selected</c:if>>
                            ${cat.name}
                        </option>
                    </c:forEach>
                </select>
                <div class="form-text">"신발" 카테고리를 선택하면 사이즈를 직접 입력합니다. (그 외 의류는 XS~XXL 선택)</div>
            </div>

            <div class="row">
                <div class="col-md-6 mb-3">
                    <label class="form-label">판매가 (원)</label>
                    <input type="number" name="price" class="form-control" required min="0"
                           value="${product.price}" placeholder="0">
                </div>
                <div class="col-md-6 mb-3">
                    <label class="form-label">재고 수량</label>
                    <input type="number" name="stock" class="form-control" required min="0"
                           value="${product.stock}" placeholder="0">
                </div>
            </div>

            <!-- 사이즈: 의류=체크박스 / 신발=자유 입력 (유형에 따라 토글) -->
            <div class="mb-3">
                <label class="form-label">사이즈</label>

                <!-- 의류용: XS~XXL 체크박스 -->
                <div id="sizeClothing">
                    <div class="d-flex flex-wrap gap-3">
                        <c:forEach var="size" items="${allSizes}">
                            <div class="form-check">
                                <input class="form-check-input size-check" type="checkbox"
                                       id="size_${size}" value="${size}"
                                       <c:if test="${not empty selectedSizes and selectedSizes.contains(size.name())}">checked</c:if>>
                                <label class="form-check-label" for="size_${size}">${size}</label>
                            </div>
                        </c:forEach>
                    </div>
                    <div class="form-text">판매할 사이즈를 모두 선택하세요.</div>
                </div>

                <!-- 신발용: 사이즈 자유 입력 (콤마로 구분) -->
                <div id="sizeShoes" style="display:none;">
                    <input type="text" id="shoeSizesInput" class="form-control"
                           value="${sizesValue}" placeholder="예: 250, 260, 270, 280">
                    <div class="form-text">신발 사이즈를 콤마(,)로 구분해 입력하세요. (mm 등)</div>
                </div>
            </div>

            <!-- 색상 (자유 입력, 콤마로 구분) -->
            <div class="mb-3">
                <label class="form-label">색상</label>
                <input type="text" id="colorsInput" class="form-control"
                       value="${colorsValue}" placeholder="예: 블랙, 화이트, 네이비">
                <div class="form-text">여러 색상은 콤마(,)로 구분해 입력하세요.</div>
            </div>

            <!-- 사이즈×색상 조합별 재고 (사이즈/색상 선택 시 자동 생성) -->
            <div class="mb-3">
                <label class="form-label">옵션별 재고</label>
                <table class="table table-sm align-middle mb-1" id="optionStockTable" style="display:none;">
                    <thead>
                        <tr><th>사이즈</th><th>색상</th><th style="width:160px;">재고</th></tr>
                    </thead>
                    <tbody id="optionStockBody"></tbody>
                </table>
                <div class="form-text" id="optionStockHint">사이즈나 색상을 선택하면 조합별 재고 입력칸이 생성됩니다.</div>
            </div>

            <!-- 이미지 업로드 -->
            <div class="mb-3">
                <label class="form-label">상품 이미지</label>
                <c:if test="${isEdit and not empty product.imageUrl}">
                    <div class="mb-2">
                        <img src="${pageContext.request.contextPath}${product.imageUrl}"
                             alt="현재 이미지" id="imagePreview"
                             style="max-height:160px; border-radius:6px; border:1px solid #dee2e6;">
                        <p class="form-text">새 파일을 선택하면 교체됩니다.</p>
                    </div>
                </c:if>
                <c:if test="${not isEdit or empty product.imageUrl}">
                    <img id="imagePreview" src="#" alt="미리보기"
                         style="display:none; max-height:160px; border-radius:6px; border:1px solid #dee2e6; margin-bottom:8px;">
                </c:if>
                <input type="file" name="imageFile" id="imageFile" class="form-control"
                       accept="image/*">
                <div class="form-text">JPG, PNG, WEBP 등 이미지 파일 (최대 10MB)</div>
            </div>

            <!-- 추가 이미지 (여러 장) -->
            <div class="mb-3">
                <label class="form-label">추가 이미지</label>
                <c:if test="${isEdit and not empty images}">
                    <div class="d-flex flex-wrap gap-2 mb-2">
                        <c:forEach var="img" items="${images}">
                            <img src="${pageContext.request.contextPath}${img.imageUrl}" alt="추가 이미지"
                                 style="height:80px; border-radius:6px; border:1px solid #dee2e6;">
                        </c:forEach>
                    </div>
                    <p class="form-text">새로 선택한 파일은 기존 이미지 뒤에 추가됩니다.</p>
                </c:if>
                <input type="file" name="detailImages" class="form-control"
                       accept="image/*" multiple>
                <div class="form-text">상세 페이지에 표시될 추가 이미지 (여러 장 선택 가능)</div>
            </div>

            <div class="mb-4">
                <label class="form-label">상품 설명</label>
                <textarea name="description" class="form-control" rows="5"
                          placeholder="상품 설명을 입력하세요">${product.description}</textarea>
            </div>

            <div class="d-flex justify-content-end gap-2">
                <a href="${pageContext.request.contextPath}/admin/products" class="btn btn-outline-secondary">취소</a>
                <button type="submit" class="btn btn-dark px-4">
                    <c:choose><c:when test="${isEdit}">수정 완료</c:when><c:otherwise>등록</c:otherwise></c:choose>
                </button>
            </div>
        </form>

    </main>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    document.getElementById('imageFile').addEventListener('change', function () {
        const file = this.files[0];
        if (!file) return;
        const preview = document.getElementById('imagePreview');
        preview.src = URL.createObjectURL(file);
        preview.style.display = 'block';
    });
</script>

<%-- ── 사이즈×색상 조합별 재고 입력 ── --%>
<script>
    // 수정 화면일 때 기존 옵션(조합별 재고) 시드 데이터
    const existingCombos = [
        <c:forEach var="opt" items="${optionCombos}" varStatus="st">
        { size: "<c:out value='${opt.size}'/>", color: "<c:out value='${opt.color}'/>", stock: ${opt.stock} }<c:if test="${!st.last}">,</c:if>
        </c:forEach>
    ];

    const categorySelect = document.getElementById('categorySelect');
    const sizeClothing = document.getElementById('sizeClothing');
    const sizeShoes = document.getElementById('sizeShoes');
    const sizeChecks = Array.from(document.querySelectorAll('.size-check'));
    const shoeSizesInput = document.getElementById('shoeSizesInput');
    const colorsInput = document.getElementById('colorsInput');
    const table = document.getElementById('optionStockTable');
    const tbody = document.getElementById('optionStockBody');
    const hint = document.getElementById('optionStockHint');

    // 이전 입력값 보존용 맵 ("size||color" -> stock)
    const stockMap = {};
    existingCombos.forEach(c => { stockMap[c.size + '||' + c.color] = c.stock; });

    function isShoes() {
        const opt = categorySelect.options[categorySelect.selectedIndex];
        return opt && opt.dataset.name === '신발';
    }
    function selectedSizes() {
        if (isShoes()) {
            return shoeSizesInput.value.split(',').map(s => s.trim()).filter(s => s.length > 0);
        }
        return sizeChecks.filter(c => c.checked).map(c => c.value);
    }
    function selectedColors() {
        return colorsInput.value.split(',').map(s => s.trim()).filter(s => s.length > 0);
    }

    // 유형에 따라 사이즈 입력 UI 전환
    function applyType() {
        const shoes = isShoes();
        sizeClothing.style.display = shoes ? 'none' : '';
        sizeShoes.style.display = shoes ? '' : 'none';
    }

    // 현재 화면에 입력된 재고값을 맵에 저장(재구성 시 보존)
    function captureStocks() {
        tbody.querySelectorAll('tr').forEach(tr => {
            const key = tr.dataset.size + '||' + tr.dataset.color;
            const input = tr.querySelector('input[name="comboStock"]');
            if (input) stockMap[key] = input.value;
        });
    }

    function buildCombos() {
        const sizes = selectedSizes();
        const colors = selectedColors();
        const combos = [];
        if (sizes.length && colors.length) {
            colors.forEach(co => sizes.forEach(sz => combos.push({ size: sz, color: co })));
        } else if (sizes.length) {
            sizes.forEach(sz => combos.push({ size: sz, color: '' }));
        } else if (colors.length) {
            colors.forEach(co => combos.push({ size: '', color: co }));
        }
        return combos;
    }

    function render() {
        captureStocks();
        const combos = buildCombos();
        tbody.innerHTML = '';
        if (combos.length === 0) {
            table.style.display = 'none';
            hint.style.display = '';
            return;
        }
        table.style.display = '';
        hint.style.display = 'none';
        combos.forEach(c => {
            const key = c.size + '||' + c.color;
            const stock = (stockMap[key] !== undefined) ? stockMap[key] : 0;
            const tr = document.createElement('tr');
            tr.dataset.size = c.size;
            tr.dataset.color = c.color;
            tr.innerHTML =
                '<td>' + (c.size || '-') + '<input type="hidden" name="comboSize" value="' + c.size + '"></td>' +
                '<td>' + (c.color || '-') + '<input type="hidden" name="comboColor" value="' + c.color + '"></td>' +
                '<td><input type="number" name="comboStock" class="form-control form-control-sm" min="0" value="' + stock + '"></td>';
            tbody.appendChild(tr);
        });
    }

    sizeChecks.forEach(c => c.addEventListener('change', render));
    shoeSizesInput.addEventListener('input', render);
    colorsInput.addEventListener('input', render);
    categorySelect.addEventListener('change', function () { applyType(); render(); });

    applyType();  // 카테고리에 맞는 사이즈 입력 UI 표시
    render();     // 최초 렌더 (수정 화면이면 기존 조합 표시)
</script>
</body>
</html>
