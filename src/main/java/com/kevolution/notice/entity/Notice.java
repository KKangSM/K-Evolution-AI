package com.kevolution.notice.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

/** 공지사항 */
@Entity
@Table(name = "notice")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class Notice {

    /** PK — 등록 시각(yyyyMMddHHmmss)을 숫자로 변환해 부여한다. (auto-increment 미사용) */
    @Id
    private Long noticeId;

    @Column(nullable = false, length = 200)
    private String title;

    @Column(nullable = false, columnDefinition = "TEXT")
    private String content;

    @Column(nullable = false)
    private int viewCount;

    /** 본문 상단에 표시할 이미지 (선택, Supabase Storage 공개 URL) */
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
        if (noticeId == null) {
            // 등록 시각으로 PK 생성: 2026-06-25 14:30:45 → 20260625143045
            noticeId = Long.parseLong(now.format(DateTimeFormatter.ofPattern("yyyyMMddHHmmss")));
        }
    }

    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }

    @Builder
    public Notice(String title, String content, String imageUrl) {
        this.title = title;
        this.content = content;
        this.imageUrl = imageUrl;
    }

    public void update(String title, String content) {
        this.title = title;
        this.content = content;
    }

    public void changeImageUrl(String imageUrl) {
        this.imageUrl = imageUrl;
    }

    public void increaseViewCount() {
        this.viewCount++;
    }
}
