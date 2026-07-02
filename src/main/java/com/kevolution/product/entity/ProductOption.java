package com.kevolution.product.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

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
    @Column(name = "option_name", nullable = false, length = 50)
    private String optionName;

    /** 옵션 값 (예: 블랙) */
    @Column(name = "option_value", nullable = false, length = 50)
    private String optionValue;

    /** 옵션 추가금 */
    @Column(name = "extra_price", nullable = false, columnDefinition = "INT DEFAULT 0")
    private int extraPrice;

    /** 옵션별 재고 */
    @Column(nullable = false, columnDefinition = "INT DEFAULT 0")
    private int stock;

    /** 재고관리 코드(SKU). 없으면 NULL */
    @Column(name = "sku_code", length = 50)
    private String skuCode;

    /** 노출 순서 (작을수록 먼저) */
    @Column(name = "sort_order", nullable = false, columnDefinition = "INT DEFAULT 0")
    private int sortOrder;

    /** 판매 여부 (품절/숨김 처리용) */
    @Column(name = "is_active", nullable = false, columnDefinition = "TINYINT(1) DEFAULT 1")
    private boolean active;

    @Column(name = "created_at", nullable = false, updatable = false, columnDefinition = "DATETIME DEFAULT CURRENT_TIMESTAMP")
    private LocalDateTime createdAt;

    @Column(name = "updated_at", nullable = false, columnDefinition = "DATETIME DEFAULT CURRENT_TIMESTAMP")
    private LocalDateTime updatedAt;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
    }

    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }

    @Builder
    public ProductOption(Product product, String optionName, String optionValue,
                         int extraPrice, int stock, String skuCode, int sortOrder) {
        this.product = product;
        this.optionName = optionName;
        this.optionValue = optionValue;
        this.extraPrice = extraPrice;
        this.stock = stock;
        this.skuCode = skuCode;
        this.sortOrder = sortOrder;
        this.active = true;
    }

    public void update(String optionName, String optionValue, int extraPrice,
                       int stock, String skuCode, int sortOrder) {
        this.optionName = optionName;
        this.optionValue = optionValue;
        this.extraPrice = extraPrice;
        this.stock = stock;
        this.skuCode = skuCode;
        this.sortOrder = sortOrder;
    }

    /** 재고 수량 직접 지정 (재고 관리 화면용) */
    public void changeStock(int stock) {
        this.stock = Math.max(0, stock);
    }

    public void decreaseStock(int quantity) {
        if (this.stock < quantity) throw new IllegalStateException("옵션 재고가 부족합니다.");
        this.stock -= quantity;
    }

    public void increaseStock(int quantity) {
        this.stock += quantity;
    }

    public void activate() {
        this.active = true;
    }

    public void deactivate() {
        this.active = false;
    }
}
