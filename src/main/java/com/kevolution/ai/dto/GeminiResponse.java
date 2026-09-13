package com.kevolution.ai.dto;

import java.util.List;

/**
 * Gemini generateContent 응답 중 우리가 쓰는 부분만 매핑한다.
 * (Spring Boot 기본 Jackson 은 모르는 필드를 무시하므로 나머지는 생략)
 * gemini-3.x 는 생각(thinking) 모델이라 thought=true 인 파트가 섞일 수 있어 그것은 제외한다.
 */
public record GeminiResponse(List<Candidate> candidates) {

    public record Candidate(Content content) {}

    public record Content(List<Part> parts) {}

    public record Part(String text, Boolean thought) {}

    /** 첫 후보의 텍스트 파트들을 이어붙여 반환한다(생각 파트 제외). 없으면 빈 문자열. */
    public String firstText() {
        if (candidates == null || candidates.isEmpty()) return "";
        Content content = candidates.get(0).content();
        if (content == null || content.parts() == null) return "";

        StringBuilder sb = new StringBuilder();
        for (Part part : content.parts()) {
            if (Boolean.TRUE.equals(part.thought())) continue;
            if (part.text() != null && !part.text().isBlank()) sb.append(part.text());
        }
        return sb.toString().trim();
    }
}
