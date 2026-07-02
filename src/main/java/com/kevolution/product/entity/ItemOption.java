package com.kevolution.product.entity;

import jakarta.persistence.*;
import lombok.*;

/**
 * 상품 옵션 — (옵션명, 옵션값) + 옵션별 재고. 상품 하나에 여러 행이 붙는다.
 * 예: (사이즈, 250, 5), (사이즈, 260, 3), (색상, 블랙, 10)
 */
@Entity
@Table(name = "item_option")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class ItemOption {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long optionId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "product_id", nullable = false)
    private Product product;

    /** 옵션명 (자유 입력, 예: 사이즈) */
    @Column(name = "option_name", nullable = false, length = 50)
    private String optionName;

    /** 옵션값 (자유 입력, 예: 250) */
    @Column(name = "option_value", nullable = false, length = 50)
    private String optionValue;

    /** 옵션별 재고. 판매 시 이 값만 차감한다. */
    @Column(nullable = false)
    private int stock;

    /** 노출 순서 (작을수록 먼저) */
    @Column(name = "sort_order", nullable = false)
    private int sortOrder;

    @Builder
    public ItemOption(Product product, String optionName, String optionValue, int stock, int sortOrder) {
        this.product = product;
        this.optionName = optionName;
        this.optionValue = optionValue;
        this.stock = stock;
        this.sortOrder = sortOrder;
    }

    /** 재고 직접 지정 (음수는 0으로 보정) */
    public void changeStock(int stock) {
        this.stock = Math.max(0, stock);
    }

    /** 판매 시 재고 차감 */
    public void decreaseStock(int quantity) {
        if (this.stock < quantity) throw new IllegalStateException("옵션 재고가 부족합니다.");
        this.stock -= quantity;
    }
}
