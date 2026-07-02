package com.kevolution.product.dto;

/** 상품 등록/수정 폼에서 넘어오는 옵션 한 행. (옵션명, 옵션값, 재고) */
public record ProductOptionForm(
    String optionName,
    String optionValue,
    int stock
) {
    /** 옵션명·옵션값이 모두 있어야 저장 대상. */
    public boolean isValid() {
        return optionName != null && !optionName.isBlank()
            && optionValue != null && !optionValue.isBlank();
    }
}
