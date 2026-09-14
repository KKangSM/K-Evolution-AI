package com.kevolution.ai.service;

import com.kevolution.ai.client.GeminiClient;
import com.kevolution.ai.dto.ChatMessage;
import com.kevolution.ai.dto.ChatResponse;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.LinkedHashMap;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.anyList;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

/**
 * AiService 의 결정적 로직 단위 테스트 — 실제 Gemini 호출은 모킹하고,
 * 응답 파싱/폴백/escalate 판정만 검증한다. (ObjectMapper 는 실제 구현 사용)
 */
@ExtendWith(MockitoExtension.class)
class AiServiceTest {

    @Mock
    GeminiClient geminiClient;
    @Mock
    ChatContextBuilder contextBuilder;

    AiService aiService;

    @BeforeEach
    void setUp() {
        aiService = new AiService(geminiClient, contextBuilder, new ObjectMapper());
    }

    @Nested
    @DisplayName("개인화 추천 응답 파싱")
    class RecommendParsing {

        @Test
        @DisplayName("정상 JSON 배열은 id→이유 맵으로, LLM이 준 순서를 유지해 파싱된다")
        void parsesValidJson() {
            when(geminiClient.isConfigured()).thenReturn(true);
            when(geminiClient.complete(anyString(), anyList())).thenReturn(
                    "[{\"id\": 30, \"reason\": \"이유A\"}, {\"id\": 10, \"reason\": \"이유B\"}]");

            LinkedHashMap<Long, String> result =
                    aiService.recommendPersonalized("프로필", "후보목록", 5);

            assertThat(result).isNotNull();
            assertThat(result).containsExactly(
                    org.assertj.core.api.Assertions.entry(30L, "이유A"),
                    org.assertj.core.api.Assertions.entry(10L, "이유B"));
        }

        @Test
        @DisplayName("```json 코드블록으로 감싼 응답도 벗겨내 파싱한다")
        void stripsCodeFence() {
            when(geminiClient.isConfigured()).thenReturn(true);
            when(geminiClient.complete(anyString(), anyList())).thenReturn(
                    "```json\n[{\"id\": 7, \"reason\": \"코드블록\"}]\n```");

            LinkedHashMap<Long, String> result =
                    aiService.recommendPersonalized("프로필", "후보목록", 5);

            assertThat(result).containsExactly(
                    org.assertj.core.api.Assertions.entry(7L, "코드블록"));
        }

        @Test
        @DisplayName("id 없는 항목은 건너뛴다")
        void skipsEntriesWithoutId() {
            when(geminiClient.isConfigured()).thenReturn(true);
            when(geminiClient.complete(anyString(), anyList())).thenReturn(
                    "[{\"reason\": \"id없음\"}, {\"id\": 5, \"reason\": \"정상\"}]");

            LinkedHashMap<Long, String> result =
                    aiService.recommendPersonalized("프로필", "후보목록", 5);

            assertThat(result).containsExactly(
                    org.assertj.core.api.Assertions.entry(5L, "정상"));
        }

        @Test
        @DisplayName("빈 배열이면 null 을 반환한다(폴백 유도)")
        void emptyArrayReturnsNull() {
            when(geminiClient.isConfigured()).thenReturn(true);
            when(geminiClient.complete(anyString(), anyList())).thenReturn("[]");

            assertThat(aiService.recommendPersonalized("프로필", "후보목록", 5)).isNull();
        }

        @Test
        @DisplayName("JSON 배열이 아닌 응답(사과문 등)이면 null 을 반환한다")
        void nonArrayReturnsNull() {
            when(geminiClient.isConfigured()).thenReturn(true);
            when(geminiClient.complete(anyString(), anyList()))
                    .thenReturn("죄송해요, 추천할 상품이 없어요.");

            assertThat(aiService.recommendPersonalized("프로필", "후보목록", 5)).isNull();
        }

        @Test
        @DisplayName("AI 미설정이면 호출 없이 null 을 반환한다")
        void notConfiguredReturnsNull() {
            when(geminiClient.isConfigured()).thenReturn(false);

            assertThat(aiService.recommendPersonalized("프로필", "후보목록", 5)).isNull();
            verify(geminiClient, never()).complete(anyString(), anyList());
        }

        @Test
        @DisplayName("후보 목록이 비면 호출 없이 null 을 반환한다")
        void blankCandidatesReturnsNull() {
            when(geminiClient.isConfigured()).thenReturn(true);

            assertThat(aiService.recommendPersonalized("프로필", "   ", 5)).isNull();
            verify(geminiClient, never()).complete(anyString(), anyList());
        }
    }

    @Nested
    @DisplayName("챗봇 응답 · escalate 판정")
    class Chat {

        @Test
        @DisplayName("AI 미설정이면 폴백 안내 + escalate=true")
        void notConfiguredFallback() {
            when(geminiClient.isConfigured()).thenReturn(false);

            ChatResponse res = aiService.chat("배송 얼마나 걸려요?", List.of());

            assertThat(res.escalate()).isTrue();
            assertThat(res.answer()).contains("1:1 문의");
            verify(geminiClient, never()).complete(anyString(), anyList());
        }

        @Test
        @DisplayName("답변에 '1:1 문의'가 포함되면 escalate=true 로 표시한다")
        void escalateWhenAnswerMentionsInquiry() {
            when(geminiClient.isConfigured()).thenReturn(true);
            when(contextBuilder.build(anyString())).thenReturn("");
            when(geminiClient.complete(anyString(), anyList()))
                    .thenReturn("정확한 확인을 위해 1:1 문의로 남겨주세요.");

            ChatResponse res = aiService.chat("재고 있나요?", null);

            assertThat(res.escalate()).isTrue();
        }

        @Test
        @DisplayName("일반 답변은 escalate=false")
        void noEscalateForNormalAnswer() {
            when(geminiClient.isConfigured()).thenReturn(true);
            when(contextBuilder.build(anyString())).thenReturn("");
            when(geminiClient.complete(anyString(), anyList()))
                    .thenReturn("5만원 이상 구매하시면 배송비가 무료입니다.");

            ChatResponse res = aiService.chat("배송비 얼마예요?", null);

            assertThat(res.escalate()).isFalse();
            assertThat(res.answer()).contains("무료");
        }

        @Test
        @DisplayName("빈 답변이면 폴백 + escalate=true")
        void blankAnswerFallback() {
            when(geminiClient.isConfigured()).thenReturn(true);
            when(contextBuilder.build(anyString())).thenReturn("");
            when(geminiClient.complete(anyString(), anyList())).thenReturn("   ");

            ChatResponse res = aiService.chat("질문", null);

            assertThat(res.escalate()).isTrue();
            assertThat(res.answer()).contains("1:1 문의");
        }

        @Test
        @DisplayName("호출 중 예외가 나도 폴백 + escalate=true 로 안전하게 처리한다")
        void exceptionFallback() {
            when(geminiClient.isConfigured()).thenReturn(true);
            when(contextBuilder.build(anyString())).thenReturn("");
            when(geminiClient.complete(anyString(), anyList()))
                    .thenThrow(new RuntimeException("네트워크 오류"));

            ChatResponse res = aiService.chat("질문", null);

            assertThat(res.escalate()).isTrue();
            assertThat(res.answer()).contains("1:1 문의");
        }

        @Test
        @DisplayName("직전 대화 history와 이번 질문이 함께 모델에 전달된다")
        void passesHistoryPlusQuestion() {
            when(geminiClient.isConfigured()).thenReturn(true);
            when(contextBuilder.build(anyString())).thenReturn("");
            when(geminiClient.complete(anyString(), anyList())).thenReturn("답변");

            List<ChatMessage> history = List.of(
                    new ChatMessage("user", "이전질문"),
                    new ChatMessage("assistant", "이전답변"));

            aiService.chat("새질문", history);

            @SuppressWarnings("unchecked")
            org.mockito.ArgumentCaptor<List<ChatMessage>> captor =
                    org.mockito.ArgumentCaptor.forClass(List.class);
            verify(geminiClient).complete(anyString(), captor.capture());
            List<ChatMessage> sent = captor.getValue();
            assertThat(sent).hasSize(3);
            assertThat(sent.get(2).content()).isEqualTo("새질문");
        }
    }

    @Nested
    @DisplayName("리뷰 요약")
    class ReviewSummary {

        @Test
        @DisplayName("정상 요약 텍스트는 그대로 반환한다")
        void returnsSummary() {
            when(geminiClient.isConfigured()).thenReturn(true);
            when(geminiClient.complete(anyString(), anyList()))
                    .thenReturn("👍 장점: 좋음\n👎 아쉬운 점: 없음\n한줄평: 만족");

            String summary = aiService.summarizeReviews(List.of("정말 좋아요"));

            assertThat(summary).contains("장점");
        }

        @Test
        @DisplayName("AI 미설정이면 null")
        void notConfiguredReturnsNull() {
            when(geminiClient.isConfigured()).thenReturn(false);
            assertThat(aiService.summarizeReviews(List.of("리뷰"))).isNull();
        }

        @Test
        @DisplayName("리뷰가 없으면 호출 없이 null")
        void emptyReviewsReturnsNull() {
            when(geminiClient.isConfigured()).thenReturn(true);
            assertThat(aiService.summarizeReviews(List.of())).isNull();
            verify(geminiClient, never()).complete(anyString(), anyList());
        }

        @Test
        @DisplayName("빈 응답이면 null")
        void blankSummaryReturnsNull() {
            when(geminiClient.isConfigured()).thenReturn(true);
            when(geminiClient.complete(anyString(), anyList())).thenReturn("  ");
            assertThat(aiService.summarizeReviews(List.of("리뷰"))).isNull();
        }

        @Test
        @DisplayName("호출 중 예외가 나면 null 로 안전하게 처리한다")
        void exceptionReturnsNull() {
            when(geminiClient.isConfigured()).thenReturn(true);
            when(geminiClient.complete(anyString(), anyList()))
                    .thenThrow(new RuntimeException("오류"));
            assertThat(aiService.summarizeReviews(List.of("리뷰"))).isNull();
        }
    }
}
