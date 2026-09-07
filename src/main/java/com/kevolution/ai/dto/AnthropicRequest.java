package com.kevolution.ai.dto;

import java.util.List;

/**
 * Anthropic Messages API 요청 바디. 필드명이 그대로 JSON 키가 되므로 API 스펙(snake_case)에 맞춘다.
 * system 을 배열(블록)로 보내 각 블록에 cache_control 을 지정할 수 있게 한다(프롬프트 캐싱).
 */
public record AnthropicRequest(
        String model,
        int max_tokens,
        List<System> system,
        List<Message> messages) {

    /** 대화 메시지 한 턴. role 은 "user" 또는 "assistant". */
    public record Message(String role, String content) {}

    /** 시스템 프롬프트 블록. cache_control 을 걸면 반복 호출 시 해당 토큰 비용을 절감한다. */
    public record System(String type, String text, CacheControl cache_control) {
        public static System cached(String text) {
            return new System("text", text, new CacheControl("ephemeral"));
        }
    }

    public record CacheControl(String type) {}

    public static AnthropicRequest of(String model, int maxTokens,
                                      String systemPrompt, List<Message> messages) {
        return new AnthropicRequest(model, maxTokens,
                List.of(System.cached(systemPrompt)), messages);
    }
}
