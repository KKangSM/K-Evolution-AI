package com.kevolution.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

/** 메인 캐러셀/이벤트 배너 */
@Entity
@Table(name = "banner")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class Banner {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
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
}
