package com.kevolution.ai.dto;

/**
 * 공급자(Gemini 등)에 독립적인 대화 메시지 한 턴.
 * role 은 "user" 또는 "assistant" 를 쓰고, 각 클라이언트가 자기 API 형식으로 변환한다.
 */
public record ChatMessage(String role, String content) {}
