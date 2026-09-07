package com.kevolution.review.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

/**
 * 상품별 AI 리뷰 요약 캐시. 상품 상세를 열 때마다 AI 를 부르면 비용이 커지므로,
 * 생성한 요약을 저장해 두고 리뷰가 일정 수 이상 늘었을 때만 다시 생성한다.
 * PK 는 상품 ID(1:1) 를 그대로 쓴다.
 */
@Entity
@Table(name = "review_summary")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class ReviewSummary {

    @Id
    private Long productId;

    @Column(columnDefinition = "TEXT")
    private String summary;

    /** 이 요약을 만들 때 기준이 된 리뷰 수 — 이후 증가분을 보고 재생성 여부를 판단한다. */
    @Column(nullable = false)
    private int reviewCount;

    @Column(nullable = false)
    private LocalDateTime updatedAt;

    @Builder
    public ReviewSummary(Long productId, String summary, int reviewCount) {
        this.productId = productId;
        this.summary = summary;
        this.reviewCount = reviewCount;
        this.updatedAt = LocalDateTime.now();
    }

    public void update(String summary, int reviewCount) {
        this.summary = summary;
        this.reviewCount = reviewCount;
        this.updatedAt = LocalDateTime.now();
    }
}
