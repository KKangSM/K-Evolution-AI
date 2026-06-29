package com.kevolution.terms.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

@Entity
@Table(name = "terms")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class Terms {

    /** PK — 등록 시각(yyyyMMddHHmmss)을 숫자로 변환해 부여. (auto-increment 미사용) */
    @Id
    @Column(name = "term_id")
    private Long termId;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private Type type;

    @Column(nullable = false, length = 100)
    private String title;

    @Lob
    @Column(nullable = false, columnDefinition = "LONGTEXT")
    private String content;

    @Column(nullable = false, length = 10)
    private String contentType;

    @Column(name = "is_required", nullable = false)
    private boolean required;

    @Column(name = "is_active", nullable = false)
    private boolean active;

    @Column(nullable = false, updatable = false)
    private LocalDateTime createdAt;

    public enum Type { SERVICE, PRIVACY }

    @PrePersist
    protected void onCreate() {
        LocalDateTime now = LocalDateTime.now();
        createdAt = now;
        if (termId == null) {
            // 등록 시각으로 PK 생성: 2026-06-25 14:30:45 → 20260625143045
            termId = Long.parseLong(now.format(DateTimeFormatter.ofPattern("yyyyMMddHHmmss")));
        }
    }

    @Builder
    public Terms(Type type, String title, String content, String contentType, boolean required, boolean active) {
        this.type = type;
        this.title = title;
        this.content = content;
        this.contentType = contentType != null ? contentType : "TEXT";
        this.required = required;
        this.active = active;
    }

    public void update(String title, String content, String contentType, boolean required, boolean active) {
        this.title = title;
        this.content = content;
        this.contentType = contentType != null ? contentType : "TEXT";
        this.required = required;
        this.active = active;
    }
}
