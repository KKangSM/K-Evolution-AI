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
                <select name="categoryId" class="form-select">
                    <option value="">카테고리 없음</option>
                    <c:forEach var="cat" items="${categories}">
                        <option value="${cat.categoryId}"
                            <c:if test="${isEdit and not empty product.category and product.category.categoryId == cat.categoryId}">selected</c:if>>
                            ${cat.name}
                        </option>
                    </c:forEach>
                </select>
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

            <!-- 이미지 업로드 -->
            <div class="mb-3">
                <label class="form-label d-block">상품 이미지</label>
                <label class="upload-box ${isEdit and not empty product.imageUrl ? 'has-image' : ''}" for="imageFile">
                    <span class="upload-placeholder"><i class="bi bi-camera"></i><span>사진 등록</span></span>
                    <img class="upload-preview" src="${pageContext.request.contextPath}${product.imageUrl}" alt="">
                    <span class="upload-hint"><i class="bi bi-arrow-repeat"></i> 사진 변경</span>
                </label>
                <input type="file" name="imageFile" id="imageFile" class="upload-input" accept="image/*">
                <div class="form-text">JPG, PNG, WEBP 등 이미지 파일 (최대 10MB)</div>
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
    // 파일 선택 시 업로드 박스에 미리보기 표시(이미지로 전환)
    document.querySelectorAll('.upload-input').forEach(function (inp) {
        inp.addEventListener('change', function () {
            if (!inp.files || !inp.files.length) return;
            var box = inp.parentElement.querySelector('.upload-box');
            if (!box) return;
            box.querySelector('.upload-preview').src = URL.createObjectURL(inp.files[0]);
            box.classList.add('has-image');
        });
    });
</script>
</body>
</html>
