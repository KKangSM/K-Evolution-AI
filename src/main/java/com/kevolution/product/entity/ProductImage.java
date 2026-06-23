package com.kevolution.product.entity;

import jakarta.persistence.*;
import lombok.*;

/** 상품 이미지 (상품당 여러 장) */
@Entity
@Table(name = "product_image")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class ProductImage {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long imageId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "product_id", nullable = false)
    private Product product;

    @Column(nullable = false, length = 500)
    private String imageUrl;

    /** 노출 순서 (0이 대표 다음) */
    @Column(nullable = false)
    private int sortOrder;

    /** 대표(썸네일) 여부 */
    @Column(name = "is_thumbnail", nullable = false)
    private boolean thumbnail;

    @Builder
    public ProductImage(Product product, String imageUrl, int sortOrder, boolean thumbnail) {
        this.product = product;
        this.imageUrl = imageUrl;
        this.sortOrder = sortOrder;
        this.thumbnail = thumbnail;
    }
}
