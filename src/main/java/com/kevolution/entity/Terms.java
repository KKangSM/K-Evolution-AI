package com.kevolution.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "terms")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class Terms {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
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

    @Column(name = "is_required", nullable = false)
    private boolean required;

    @Column(name = "is_active", nullable = false)
    private boolean active;

    @Column(nullable = false, updatable = false)
    private LocalDateTime createdAt;

    public enum Type { SERVICE, PRIVACY }

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
    }

    @Builder
    public Terms(Type type, String title, String content, boolean required, boolean active) {
        this.type = type;
        this.title = title;
        this.content = content;
        this.required = required;
        this.active = active;
    }

    public void update(String title, String content, boolean required, boolean active) {
        this.title = title;
        this.content = content;
        this.required = required;
        this.active = active;
    }
}
