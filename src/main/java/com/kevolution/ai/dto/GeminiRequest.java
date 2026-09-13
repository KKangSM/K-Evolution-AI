package com.kevolution.ai.dto;

import java.util.List;

/**
 * Google Gemini generateContent 요청 바디. 필드명이 그대로 JSON 키가 된다.
 * (Gemini 는 camelCase·snake_case 를 모두 받으므로 camelCase 로 통일)
 * system_instruction 으로 시스템 프롬프트를, contents 로 대화 메시지를 보낸다.
 */
public record GeminiRequest(
        SystemInstruction systemInstruction,
        List<Content> contents,
        GenerationConfig generationConfig) {

    public record SystemInstruction(List<Part> parts) {}

    /** 대화 한 턴. role 은 Gemini 규격상 "user" 또는 "model". */
    public record Content(String role, List<Part> parts) {}

    public record Part(String text) {}

    public record GenerationConfig(int maxOutputTokens) {}

    public static GeminiRequest of(int maxTokens, String systemPrompt, List<Content> contents) {
        SystemInstruction system = (systemPrompt == null || systemPrompt.isBlank())
                ? null
                : new SystemInstruction(List.of(new Part(systemPrompt)));
        return new GeminiRequest(system, contents, new GenerationConfig(maxTokens));
    }
}
