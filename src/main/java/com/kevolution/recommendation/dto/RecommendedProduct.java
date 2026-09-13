package com.kevolution.recommendation.dto;

import com.kevolution.product.entity.Product;

/**
 * 개인화 추천 결과 한 건. LLM 추천이면 reason 에 "왜 이 고객에게 맞는지" 한 줄 설명이 들어가고,
 * 규칙 기반 폴백이면 reason 은 null 이다(뷰에서 이유 표시를 생략).
 */
public record RecommendedProduct(Product product, String reason) {

    public boolean hasReason() {
        return reason != null && !reason.isBlank();
    }
}
