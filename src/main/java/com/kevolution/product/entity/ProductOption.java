package com.kevolution.product.entity;

import jakarta.persistence.*;
import lombok.*;

/** 상품 옵션 (색상/사이즈 등) + 옵션별 재고 */
@Entity
@Table(name = "product_option")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class ProductOption {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long optionId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "product_id", nullable = false)
    private Product product;

    /** 옵션 종류명 (예: 색상) */
    @Column(nullable = false, length = 50)
    private String optionName;

    /** 옵션 값 (예: 블랙) */
    @Column(nullable = false, length = 50)
    private String optionValue;

    /** 옵션 추가금 */
    @Column(nullable = false)
    private int extraPrice;

    /** 옵션별 재고 */
    @Column(nullable = false)
    private int stock;

    @Builder
    public ProductOption(Product product, String optionName, String optionValue, int extraPrice, int stock) {
        this.product = product;
        this.optionName = optionName;
        this.optionValue = optionValue;
        this.extraPrice = extraPrice;
        this.stock = stock;
    }

    public void decreaseStock(int quantity) {
        if (this.stock < quantity) throw new IllegalStateException("옵션 재고가 부족합니다.");
        this.stock -= quantity;
    }

    public void increaseStock(int quantity) {
        this.stock += quantity;
    }
}
