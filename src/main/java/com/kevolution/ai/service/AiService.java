package com.kevolution.ai.service;

import com.kevolution.ai.client.AnthropicClient;
import com.kevolution.ai.dto.AnthropicRequest;
import com.kevolution.ai.dto.ChatResponse;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;

/**
 * AI 기능 공통 오케스트레이션. 지금은 상담 챗봇만 담당하지만,
 * 리뷰 요약·상품 설명 생성 등도 여기에 메서드로 추가해 AnthropicClient 를 공유한다.
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

    private final AnthropicClient anthropicClient;
    private final ChatContextBuilder contextBuilder;

    /**
     * 챗봇 답변 생성. 관련 컨텍스트 수집 → 프롬프트 조립 → 호출.
     * 키 미설정/호출 실패 시 폴백 안내 + escalate(문의 유도) 로 처리한다.
     *
     * @param history 이전 대화(오래된→최근 순). null 이면 빈 대화로 시작.
     */
    public ChatResponse chat(String question, List<AnthropicRequest.Message> history) {
        if (!anthropicClient.isConfigured()) {
            return new ChatResponse(FALLBACK, true);
        }
        try {
            String context = contextBuilder.build(question);
            String system = SYSTEM_TEMPLATE.formatted(
                    context.isBlank() ? "(질문과 직접 연결되는 상품/정책 정보 없음)" : context);

            List<AnthropicRequest.Message> messages =
                    (history == null) ? new ArrayList<>() : new ArrayList<>(history);
            messages.add(new AnthropicRequest.Message("user", question));

            String answer = anthropicClient.complete(system, messages);
            if (answer.isBlank()) return new ChatResponse(FALLBACK, true);

            boolean escalate = answer.contains("1:1 문의");
            return new ChatResponse(answer, escalate);
        } catch (Exception e) {
            log.warn("AI 챗봇 응답 생성 실패", e);
            return new ChatResponse(FALLBACK, true);
        }
    }
}
