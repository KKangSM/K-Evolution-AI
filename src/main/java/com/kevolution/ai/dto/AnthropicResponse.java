package com.kevolution.ai.dto;

import java.util.List;

/**
 * Anthropic Messages API 응답 중 우리가 쓰는 부분만 매핑한다.
 * (Spring Boot 기본 Jackson 설정은 모르는 필드를 무시하므로 나머지는 생략)
 */
public record AnthropicResponse(List<Content> content) {

    public record Content(String type, String text) {}

    /** 첫 텍스트 블록을 뽑아 반환한다. 비어 있으면 빈 문자열. */
    public String firstText() {
        if (content == null || content.isEmpty()) return "";
        String text = content.get(0).text();
        return text == null ? "" : text.trim();
    }
}
