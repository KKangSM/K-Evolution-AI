package com.kevolution.product.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

@Entity
@Table(name = "product")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class Product {

    /** PK — 등록 시각(yyyyMMddHHmmss)을 숫자로 변환해 부여한다. (auto-increment 미사용) */
    @Id
    private Long productId;

    /** 고정 enum — DB 에는 이름 문자열로 저장 (예: CLOTHING). 없으면 NULL */
    @Enumerated(EnumType.STRING)
    @Column(name = "category", length = 30)
    private Category category;

    @Column(nullable = false, length = 200)
    private String name;

    @Column(nullable = false)
    private int price;

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
        LocalDateTime now = LocalDateTime.now();
        createdAt = now;
        updatedAt = now;
        if (productId == null) {
            // 등록 시각으로 PK 생성: 2026-06-25 14:30:45 → 20260625143045
            productId = Long.parseLong(now.format(DateTimeFormatter.ofPattern("yyyyMMddHHmmss")));
        }
    }

    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }

    @Builder
    public Product(Category category, String name, int price, String description, String imageUrl) {
        this.category = category;
        this.name = name;
        this.price = price;
        this.description = description;
        this.imageUrl = imageUrl;
    }

    public void update(Category category, String name, int price, String description, String imageUrl) {
        this.category = category;
        this.name = name;
        this.price = price;
        this.description = description;
        this.imageUrl = imageUrl;
    }
}
