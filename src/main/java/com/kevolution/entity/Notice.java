package com.kevolution.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

/** 공지사항 */
@Entity
@Table(name = "notice")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class Notice {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long noticeId;

    @Column(nullable = false, length = 200)
    private String title;

    @Column(nullable = false, columnDefinition = "TEXT")
    private String content;

    /** 상단 고정 여부 */
    @Column(name = "is_pinned", nullable = false)
    private boolean pinned;

    /** 메인 마퀴 표시 여부 */
    @Column(name = "is_marquee", nullable = false)
    private boolean marquee;

    @Column(nullable = false)
    private int viewCount;

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
    public Notice(String title, String content, boolean pinned, boolean marquee) {
        this.title = title;
        this.content = content;
        this.pinned = pinned;
        this.marquee = marquee;
    }

    public void update(String title, String content, boolean pinned, boolean marquee) {
        this.title = title;
        this.content = content;
        this.pinned = pinned;
        this.marquee = marquee;
    }

    public void increaseViewCount() {
        this.viewCount++;
    }
}
