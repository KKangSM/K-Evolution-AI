package com.kevolution.ai.client;

import com.kevolution.ai.dto.ChatMessage;
import com.kevolution.ai.dto.GeminiRequest;
import com.kevolution.ai.dto.GeminiResponse;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClient;

import java.util.List;

/**
 * Google Gemini(generativelanguage) API 호출 담당. 결제의 TossPaymentClient 과 동일한 방식으로,
 * 생성자에서 키를 주입받아 RestClient 를 만들어 두고 재사용한다.
 * API 키가 비어 있으면(미설정) isConfigured() 가 false 를 반환해 상위에서 폴백 처리한다.
 */
@Component
public class GeminiClient {

    private static final String BASE_URL = "https://generativelanguage.googleapis.com";

    private final RestClient restClient;
    private final String apiKey;
    private final String model;
    private final int maxTokens;

    public GeminiClient(
            @Value("${gemini.api-key:}") String apiKey,
            @Value("${gemini.model:gemini-3.6-flash}") String model,
            @Value("${gemini.max-tokens:2048}") int maxTokens) {
        this.apiKey = apiKey;
        this.model = model;
        this.maxTokens = maxTokens;
        this.restClient = RestClient.builder()
            .baseUrl(BASE_URL)
            .defaultHeader("x-goog-api-key", apiKey)
            .build();
    }

    /** API 키가 설정되어 있어야 실제 호출이 가능하다. */
    public boolean isConfigured() {
        return apiKey != null && !apiKey.isBlank();
    }

    /**
     * 시스템 프롬프트 + 대화 메시지로 Gemini 응답 텍스트를 받아온다.
     * 실패(비2xx)하면 예외를 던져 상위(AiService)에서 폴백 메시지로 처리하게 한다.
     */
    public String complete(String systemPrompt, List<ChatMessage> messages) {
        List<GeminiRequest.Content> contents = messages.stream()
                .map(m -> new GeminiRequest.Content(mapRole(m.role()),
                        List.of(new GeminiRequest.Part(m.content()))))
                .toList();
        GeminiRequest body = GeminiRequest.of(maxTokens, systemPrompt, contents);

        return restClient.post()
            .uri("/v1beta/models/{model}:generateContent", model)
            .contentType(MediaType.APPLICATION_JSON)
            .body(body)
            .exchange((request, response) -> {
                if (response.getStatusCode().is2xxSuccessful()) {
                    return response.bodyTo(GeminiResponse.class).firstText();
                }
                throw new IllegalStateException("AI 응답 생성에 실패했습니다. (status="
                        + response.getStatusCode() + ")");
            });
    }

    /** 우리 내부 role("assistant") 을 Gemini 규격("model") 으로 변환한다. */
    private String mapRole(String role) {
        return "assistant".equals(role) ? "model" : "user";
    }
}
