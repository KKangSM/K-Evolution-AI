package com.kevolution.banner.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

/** 메인 캐러셀/이벤트 배너 */
@Entity
@Table(name = "banner")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class Banner {

    /** PK — 등록 시각(yyyyMMddHHmmss)을 숫자로 변환해 부여. (auto-increment 미사용) */
    @Id
    private Long bannerId;

    @Column(nullable = false, length = 500)
    private String imageUrl;

    /** 클릭 시 이동 URL */
    @Column(length = 500)
    private String linkUrl;

    @Column(length = 100)
    private String title;

    @Column(nullable = false)
    private int sortOrder;

    /** 노출 여부 */
    @Column(name = "is_active", nullable = false)
    private boolean active;

    /** 노출 시작/종료 (null이면 상시) */
    private LocalDateTime startAt;
    private LocalDateTime endAt;

    @PrePersist
    protected void onCreate() {
        if (bannerId == null) {
            // 등록 시각으로 PK 생성: 2026-06-25 14:30:45 → 20260625143045
            bannerId = Long.parseLong(LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMddHHmmss")));
        }
    }

    @Builder
    public Banner(String imageUrl, String linkUrl, String title, int sortOrder,
                  boolean active, LocalDateTime startAt, LocalDateTime endAt) {
        this.imageUrl = imageUrl;
        this.linkUrl = linkUrl;
        this.title = title;
        this.sortOrder = sortOrder;
        this.active = active;
        this.startAt = startAt;
        this.endAt = endAt;
    }

    /** 이미지 외 메타 정보 수정 (이미지는 changeImageUrl 로 별도 교체) */
    public void update(String linkUrl, String title, int sortOrder, boolean active,
                       LocalDateTime startAt, LocalDateTime endAt) {
        this.linkUrl = linkUrl;
        this.title = title;
        this.sortOrder = sortOrder;
        this.active = active;
        this.startAt = startAt;
        this.endAt = endAt;
    }

    public void changeImageUrl(String imageUrl) {
        this.imageUrl = imageUrl;
    }
}
