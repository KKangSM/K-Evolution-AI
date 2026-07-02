package com.kevolution.product.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "product")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class Product {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long productId;

    /** 고정 enum — DB 에는 이름 문자열로 저장 (예: CLOTHING). 없으면 NULL */
    @Enumerated(EnumType.STRING)
    @Column(name = "category", length = 30)
    private Category category;

    @Column(nullable = false, length = 200)
    private String name;

    @Column(nullable = false)
    private int price;

    @Column(nullable = false)
    private int stock;

    @Column(columnDefinition = "TEXT")
    private String description;

    @Column(length = 500)
    private String imageUrl;

    @Column(nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @Column(nullable = false)
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
    public Product(Category category, String name, int price, int stock, String description, String imageUrl) {
        this.category = category;
        this.name = name;
        this.price = price;
        this.stock = stock;
        this.description = description;
        this.imageUrl = imageUrl;
    }

    public void update(Category category, String name, int price, int stock, String description, String imageUrl) {
        this.category = category;
        this.name = name;
        this.price = price;
        this.stock = stock;
        this.description = description;
        this.imageUrl = imageUrl;
    }

    /** 재고 수량 직접 지정 (재고 관리 화면 / 옵션 합계 동기화용) */
    public void changeStock(int stock) {
        this.stock = Math.max(0, stock);
    }

    public void decreaseStock(int quantity) {
        if (this.stock < quantity) throw new IllegalStateException("재고가 부족합니다.");
        this.stock -= quantity;
    }

    public void increaseStock(int quantity) {
        this.stock += quantity;
    }
}
