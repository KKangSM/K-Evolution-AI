package com.kevolution.review.entity;

import jakarta.persistence.*;
import lombok.*;

/** 리뷰 첨부 이미지 */
@Entity
@Table(name = "review_image")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class ReviewImage {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long imageId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "review_id", nullable = false)
    private Review review;

    @Column(nullable = false, length = 500)
    private String imageUrl;

    @Column(nullable = false)
    private int sortOrder;

    @Builder
    public ReviewImage(Review review, String imageUrl, int sortOrder) {
        this.review = review;
        this.imageUrl = imageUrl;
        this.sortOrder = sortOrder;
    }
}
