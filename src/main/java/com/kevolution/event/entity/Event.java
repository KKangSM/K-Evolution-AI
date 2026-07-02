package com.kevolution.event.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

/** 이벤트/기획전 — 메인 배너가 링크하는 상세 대상. */
@Entity
@Table(name = "event")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class Event {

    /** PK — 등록 시각(yyyyMMddHHmmss)을 숫자로 변환해 부여한다. (auto-increment 미사용) */
    @Id
    private Long eventId;

    @Column(nullable = false, length = 200)
    private String title;

    @Column(nullable = false, columnDefinition = "TEXT")
    private String content;

    /** 상세 페이지 대표 이미지 (Supabase Storage 공개 URL) */
    @Column(length = 500)
    private String imageUrl;

    /** 노출 여부 (관리자 수동 스위치) */
    @Column(name = "is_active", nullable = false)
    private boolean active;

    /** 노출 시작/종료 (null이면 상시) */
    private LocalDateTime startAt;
    private LocalDateTime endAt;

    @Column(nullable = false)
    private int viewCount;

    @Column(nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @Column(nullable = false)
    private LocalDateTime updatedAt;

    @PrePersist
    protected void onCreate() {
        LocalDateTime now = LocalDateTime.now();
        createdAt = now;
        updatedAt = now;
        if (eventId == null) {
            // 등록 시각으로 PK 생성: 2026-06-25 14:30:45 → 20260625143045
            eventId = Long.parseLong(now.format(DateTimeFormatter.ofPattern("yyyyMMddHHmmss")));
        }
    }

    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }

    @Builder
    public Event(String title, String content, String imageUrl,
                 boolean active, LocalDateTime startAt, LocalDateTime endAt) {
        this.title = title;
        this.content = content;
        this.imageUrl = imageUrl;
        this.active = active;
        this.startAt = startAt;
        this.endAt = endAt;
    }

    public void update(String title, String content, boolean active,
                       LocalDateTime startAt, LocalDateTime endAt) {
        this.title = title;
        this.content = content;
        this.active = active;
        this.startAt = startAt;
        this.endAt = endAt;
    }

    public void changeImageUrl(String imageUrl) {
        this.imageUrl = imageUrl;
    }

    public void increaseViewCount() {
        this.viewCount++;
    }

    /**
     * 관리자 화면 표시용 실제 노출 상태 (active + 기간 종합).
     * HIDDEN(숨김) / SCHEDULED(예정) / LIVE(노출중) / ENDED(종료)
     */
    @Transient
    public String getExposureStatus() {
        if (!active) return "HIDDEN";
        LocalDateTime now = LocalDateTime.now();
        if (startAt != null && now.isBefore(startAt)) return "SCHEDULED";
        if (endAt != null && now.isAfter(endAt)) return "ENDED";
        return "LIVE";
    }
}
