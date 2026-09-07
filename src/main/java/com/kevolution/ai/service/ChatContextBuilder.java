package com.kevolution.ai.service;

import com.kevolution.notice.entity.Notice;
import com.kevolution.notice.service.NoticeService;
import com.kevolution.product.entity.Product;
import com.kevolution.product.repository.ProductRepository;
import com.kevolution.terms.entity.Terms;
import com.kevolution.terms.service.TermsService;

import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.LinkedHashSet;
import java.util.Set;

/**
 * RAG — 사용자 질문에서 상품/정책 관련 데이터를 우리 DB 에서 찾아 [상점 정보] 텍스트로 만든다.
 * Claude 는 우리 DB 를 모르므로, 이 컨텍스트가 "지어내기(환각)" 를 막는 핵심 근거가 된다.
 * 초기 버전은 키워드 매칭으로 단순하게 구성한다. (추후 임베딩 검색으로 고도화 가능)
 */
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class ChatContextBuilder {

    /** 상품 컨텍스트에 포함할 최대 상품 수 */
    private static final int MAX_PRODUCTS = 5;
    /** 정책 컨텍스트에 포함할 최대 공지 수 */
    private static final int MAX_NOTICES = 3;
    /** 본문 길이 상한(토큰/비용 관리) */
    private static final int SNIPPET_LEN = 300;

    /** 정책성 질문으로 판단할 키워드 */
    private static final String[] POLICY_KEYWORDS = {
        "배송", "택배", "반품", "환불", "교환", "취소", "결제", "쿠폰",
        "적립", "포인트", "회원", "탈퇴", "개인정보", "약관", "주문"
    };

    private final ProductRepository productRepository;
    private final NoticeService noticeService;
    private final TermsService termsService;

    /**
     * 질문 관련 상품·정책을 모아 [상점 정보] 블록을 만든다.
     * 매칭이 없으면 빈 문자열을 반환한다(상위에서 기본 안내만 사용).
     */
    public String build(String question) {
        StringBuilder ctx = new StringBuilder();
        appendMatchedProducts(ctx, question);
        appendPolicies(ctx, question);
        return ctx.toString();
    }

    /** 질문의 각 단어로 상품명을 검색해 관련 상품을 모은다. */
    private void appendMatchedProducts(StringBuilder ctx, String question) {
        Set<Product> matched = new LinkedHashSet<>();
        for (String token : question.split("[^\\p{L}\\p{N}]+")) {
            if (token.length() < 2 || matched.size() >= MAX_PRODUCTS) continue;
            matched.addAll(productRepository
                    .findByNameContainingIgnoreCase(token, PageRequest.of(0, MAX_PRODUCTS))
                    .getContent());
        }
        if (matched.isEmpty()) return;

        ctx.append("[관련 상품]\n");
        matched.stream().limit(MAX_PRODUCTS).forEach(p -> ctx.append(String.format(
                "- %s / 가격 %,d원 / 카테고리 %s%s%n",
                p.getName(), p.getPrice(),
                p.getCategory() == null ? "미지정" : p.getCategory().getLabel(),
                snippet(p.getDescription()))));
        ctx.append("\n");
    }

    /** 정책성 키워드가 있으면 공지·약관을 근거로 붙인다. */
    private void appendPolicies(StringBuilder ctx, String question) {
        boolean policyRelated = false;
        for (String kw : POLICY_KEYWORDS) {
            if (question.contains(kw)) { policyRelated = true; break; }
        }
        if (!policyRelated) return;

        var notices = noticeService.getNotices(PageRequest.of(0, MAX_NOTICES)).getContent();
        if (!notices.isEmpty()) {
            ctx.append("[공지사항]\n");
            for (Notice n : notices) {
                ctx.append("- ").append(n.getTitle()).append(snippet(n.getContent())).append("\n");
            }
            ctx.append("\n");
        }

        var terms = termsService.getActiveTerms();
        if (!terms.isEmpty()) {
            ctx.append("[약관/정책]\n");
            for (Terms t : terms) {
                ctx.append("- ").append(t.getTitle());
                // TEXT 약관만 본문을 붙인다(FILE 은 URL 이라 제외)
                if ("TEXT".equals(t.getContentType())) {
                    ctx.append(snippet(termsService.htmlToPlainText(t.getContent())));
                }
                ctx.append("\n");
            }
            ctx.append("\n");
        }
    }

    /** 본문을 한 줄로 정리하고 상한 길이로 자른다. 비면 빈 문자열. */
    private String snippet(String text) {
        if (text == null || text.isBlank()) return "";
        String flat = text.replaceAll("<[^>]+>", " ").replaceAll("\\s+", " ").trim();
        if (flat.isEmpty()) return "";
        if (flat.length() > SNIPPET_LEN) flat = flat.substring(0, SNIPPET_LEN) + "…";
        return " : " + flat;
    }
}
