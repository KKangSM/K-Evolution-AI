package com.kevolution.product.entity;

import jakarta.persistence.*;
import lombok.*;

/**
 * 상품 옵션 = 사이즈×색상 조합 1건 + 조합별 재고.
 * 기존 option_name / option_value 컬럼을 각각 size / color 로 재사용한다(스키마 변경 없음).
 * 사이즈만/색상만 있는 경우 반대쪽 값은 빈 문자열("")로 저장한다.
 */
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

    /** 사이즈 (XS~XXL). 색상만 있는 조합이면 "" */
    @Column(name = "option_name", nullable = false, length = 50)
    private String size;

    /** 색상 (자유 입력). 사이즈만 있는 조합이면 "" */
    @Column(name = "option_value", nullable = false, length = 50)
    private String color;

    /** 옵션 추가금 */
    @Column(nullable = false)
    private int extraPrice;

    /** 조합별 재고 */
    @Column(nullable = false)
    private int stock;

    @Builder
    public ProductOption(Product product, String size, String color, int extraPrice, int stock) {
        this.product = product;
        this.size = (size == null) ? "" : size;
        this.color = (color == null) ? "" : color;
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
