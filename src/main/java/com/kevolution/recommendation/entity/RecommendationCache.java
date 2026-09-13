package com.kevolution.recommendation.entity;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

/**
 * 회원별 LLM 개인화 추천 결과 캐시. 마이페이지를 열 때마다 LLM 을 부르면 비용·지연이 크므로,
 * 생성한 추천(상품ID+이유 JSON)을 저장해 두고 일정 시간 안에는 그대로 재사용한다.
 * (리뷰 요약의 ReviewSummary 캐시와 같은 취지) PK 는 회원 userId.
 */
@Entity
@Table(name = "recommendation_cache")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class RecommendationCache {

    @Id
    private String userId;

    /** 추천 결과 JSON — [{"id":상품ID,"reason":"추천 이유"}, ...] (LLM 이 고른 순서 유지) */
    @Column(columnDefinition = "TEXT")
    private String payload;

    @Column(nullable = false)
    private LocalDateTime updatedAt;

    @Builder
    public RecommendationCache(String userId, String payload) {
        this.userId = userId;
        this.payload = payload;
        this.updatedAt = LocalDateTime.now();
    }

    public void update(String payload) {
        this.payload = payload;
        this.updatedAt = LocalDateTime.now();
    }

    /** 마지막 생성 후 ttlHours 시간 안이면 최신으로 본다(=LLM 재호출 생략). */
    public boolean isFresh(int ttlHours) {
        return updatedAt.isAfter(LocalDateTime.now().minusHours(ttlHours));
    }
}
