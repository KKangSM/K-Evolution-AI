package com.kevolution.ai.service;

import com.kevolution.ai.client.GeminiClient;
import com.kevolution.ai.dto.ChatMessage;
import com.kevolution.ai.dto.ChatResponse;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;

/**
 * AI 기능 공통 오케스트레이션. 지금은 상담 챗봇만 담당하지만,
 * 리뷰 요약·상품 설명 생성 등도 여기에 메서드로 추가해 GeminiClient 를 공유한다.
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class AiService {

    private static final String SYSTEM_TEMPLATE = """
        너는 K-Evolution 쇼핑몰의 친절한 상담원이야. 손님 질문에 우리말로 간결하게(3~4문장 이내) 답해.

        규칙:
        - 아래 [상점 정보]에 있는 내용을 우선 근거로 답하고, 없는 재고·가격·정책을 지어내지 마.
        - 확실하지 않거나 상점 정보로 답할 수 없으면 "정확한 확인을 위해 1:1 문의로 남겨주세요"라고 안내해.
        - 결제·주문변경·개인정보 처리는 직접 하지 말고 방법만 안내해.

        [기본 정보]
        - 상점명: K-Evolution (온라인 쇼핑몰)
        - 취급 카테고리: 의류, 신발, 가방, 액세서리, 뷰티, 디지털, 리빙, 식품
        - 배송비: 5만원 이상 구매 시 무료, 미만이면 3,000원
        - 결제수단: 토스페이먼츠(카드 등)
        - 1:1 문의: 고객센터 > 1:1 문의(/support/qna) 에서 남길 수 있음

        [상점 정보]
        %s
        """;

    private static final String FALLBACK =
        "죄송해요, 지금은 답변을 준비하기 어려워요. 고객센터의 1:1 문의로 남겨주시면 확인해 드릴게요.";

    private static final String REVIEW_SUMMARY_SYSTEM = """
        너는 쇼핑몰 리뷰 요약가야. 아래 구매 후기들을 바탕으로 상품 평가를 우리말로 간결하게 요약해.

        규칙:
        - 후기에 실제로 언급된 내용만 사용하고, 없는 내용을 지어내지 마.
        - 과장/광고 문구를 쓰지 말고 담백하게.
        - 아래 형식을 정확히 지켜(각 항목 1줄, 없으면 "언급 적음"):
        👍 장점: (핵심 3가지 이내, 쉼표로 구분)
        👎 아쉬운 점: (핵심 2가지 이내, 쉼표로 구분)
        한줄평: (전반적 반응 한 문장)
        """;

    /** 리뷰 요약 시 프롬프트에 넣을 후기 총 길이 상한(토큰/비용 관리) */
    private static final int MAX_REVIEW_CHARS = 4000;

    private static final String RECOMMEND_SYSTEM = """
        너는 K-Evolution 쇼핑몰의 개인화 추천 큐레이터야.
        아래 [고객 프로필]과 [추천 후보 상품]을 보고, 이 고객에게 가장 잘 맞는 상품을 골라 추천해.

        규칙:
        - 반드시 [추천 후보 상품] 목록 안에서만 골라. 목록에 없는 상품(id)을 지어내지 마.
        - 고객의 구매·찜 이력과 연결지어 왜 어울리는지 우리말 한 문장(30자 이내)으로 설명해.
        - 잘 맞는 순서대로 정렬해.
        - 반드시 아래 JSON 배열로만 답해(설명·코드블록·마크다운 없이):
        [{"id": 상품ID(숫자), "reason": "추천 이유"}, ...]
        """;

    private final GeminiClient geminiClient;
    private final ChatContextBuilder contextBuilder;
    private final ObjectMapper objectMapper;

    /**
     * 챗봇 답변 생성. 관련 컨텍스트 수집 → 프롬프트 조립 → 호출.
     * 키 미설정/호출 실패 시 폴백 안내 + escalate(문의 유도) 로 처리한다.
     *
     * @param history 이전 대화(오래된→최근 순). null 이면 빈 대화로 시작.
     */
    public ChatResponse chat(String question, List<ChatMessage> history) {
        if (!geminiClient.isConfigured()) {
            return new ChatResponse(FALLBACK, true);
        }
        try {
            String context = contextBuilder.build(question);
            String system = SYSTEM_TEMPLATE.formatted(
                    context.isBlank() ? "(질문과 직접 연결되는 상품/정책 정보 없음)" : context);

            List<ChatMessage> messages =
                    (history == null) ? new ArrayList<>() : new ArrayList<>(history);
            messages.add(new ChatMessage("user", question));

            String answer = geminiClient.complete(system, messages);
            if (answer.isBlank()) return new ChatResponse(FALLBACK, true);

            boolean escalate = answer.contains("1:1 문의");
            return new ChatResponse(answer, escalate);
        } catch (Exception e) {
            log.warn("AI 챗봇 응답 생성 실패", e);
            return new ChatResponse(FALLBACK, true);
        }
    }

    /**
     * 여러 리뷰 본문을 받아 장점/단점/한줄평으로 요약한다.
     * 키 미설정·후기 없음·호출 실패 시 null 을 반환한다(호출 측에서 "요약 없음"으로 처리).
     */
    public String summarizeReviews(List<String> reviewContents) {
        if (!geminiClient.isConfigured() || reviewContents == null || reviewContents.isEmpty()) {
            return null;
        }
        try {
            String joined = String.join("\n", reviewContents);
            if (joined.length() > MAX_REVIEW_CHARS) {
                joined = joined.substring(0, MAX_REVIEW_CHARS);
            }
            List<ChatMessage> messages = List.of(
                    new ChatMessage("user", "다음은 이 상품의 구매 후기들이야. 요약해줘:\n\n" + joined));
            String summary = geminiClient.complete(REVIEW_SUMMARY_SYSTEM, messages);
            return summary.isBlank() ? null : summary;
        } catch (Exception e) {
            log.warn("AI 리뷰 요약 생성 실패", e);
            return null;
        }
    }

    /**
     * 고객 프로필과 추천 후보 상품 목록을 LLM 에 주고, 잘 맞는 상품을 선별 + 추천 이유를 받아온다.
     * 반환은 상품ID→추천이유 (LLM 이 고른 순서 유지). 키 미설정·후보 없음·호출/파싱 실패 시 null
     * (호출 측에서 규칙 기반 추천으로 폴백).
     *
     * @param profile    고객 프로필 텍스트(선호 카테고리·최근 구매·찜 등)
     * @param candidates 후보 상품 텍스트("- id 123 / 상품명 / 카테고리 / 가격" 형식)
     * @param max        최대 추천 개수
     */
    public LinkedHashMap<Long, String> recommendPersonalized(String profile, String candidates, int max) {
        if (!geminiClient.isConfigured() || candidates == null || candidates.isBlank()) {
            return null;
        }
        try {
            String userMsg = "[고객 프로필]\n" + profile + "\n\n[추천 후보 상품]\n" + candidates
                    + "\n\n위 후보 중 이 고객에게 잘 맞는 순서로 최대 " + max + "개를 골라 JSON 으로만 답해.";
            List<ChatMessage> messages =
                    List.of(new ChatMessage("user", userMsg));
            String json = geminiClient.complete(RECOMMEND_SYSTEM, messages);
            return parseRecommendations(json);
        } catch (Exception e) {
            log.warn("AI 개인화 추천 생성 실패", e);
            return null;
        }
    }

    /** LLM 응답(JSON 배열)을 상품ID→이유 맵으로 파싱한다. 형식이 어긋나면 null. */
    private LinkedHashMap<Long, String> parseRecommendations(String raw) throws Exception {
        if (raw == null || raw.isBlank()) return null;
        String json = raw.trim();
        // 모델이 가끔 ```json ... ``` 코드블록으로 감싸는 경우를 벗겨낸다.
        if (json.startsWith("```")) {
            json = json.replaceAll("^```[a-zA-Z]*\\s*", "").replaceAll("```\\s*$", "").trim();
        }
        JsonNode arr = objectMapper.readTree(json);
        if (arr == null || !arr.isArray()) return null;

        LinkedHashMap<Long, String> out = new LinkedHashMap<>();
        for (JsonNode node : arr) {
            if (!node.hasNonNull("id")) continue;
            out.put(node.get("id").asLong(), node.path("reason").asText("").trim());
        }
        return out.isEmpty() ? null : out;
    }
}
