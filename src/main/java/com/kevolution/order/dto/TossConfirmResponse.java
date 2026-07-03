package com.kevolution.order.dto;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

/**
 * 토스페이먼츠 결제 승인(confirm) API 응답 중 필요한 필드만 매핑.
 * 승인 성공 시 반환되는 JSON은 필드가 많아 나머지는 무시한다.
 */
@JsonIgnoreProperties(ignoreUnknown = true)
public record TossConfirmResponse(
    String paymentKey,
    String orderId,
    String status,
    String method,      // 결제수단 (예: 카드, 간편결제, 가상계좌)
    int totalAmount,
    String approvedAt   // ISO-8601 (예: 2026-07-03T12:00:00+09:00)
) {}
