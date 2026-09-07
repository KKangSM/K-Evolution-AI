package com.kevolution.ai.dto;

/**
 * 서버 → 챗봇 위젯 응답.
 * escalate 가 true 면 화면에서 "1:1 문의 남기기" 안내를 함께 노출한다.
 */
public record ChatResponse(String answer, boolean escalate) {}
