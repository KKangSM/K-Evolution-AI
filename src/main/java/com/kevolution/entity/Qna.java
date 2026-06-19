package com.kevolution.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

/** 상품 문의 / 1:1 문의. product가 null이면 일반 문의. */
@Entity
@Table(name = "qna")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class Qna {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long qnaId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "member_id", nullable = false)
    private Member member;

    /** 상품 문의면 해당 상품, 일반 1:1 문의면 null */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "product_id")
    private Product product;

    @Column(nullable = false, length = 200)
    private String title;

    @Column(nullable = false, columnDefinition = "TEXT")
    private String content;

    @Column(columnDefinition = "TEXT")
    private String answer;

    private LocalDateTime answeredAt;

    /** 비밀글 여부 */
    @Column(name = "is_secret", nullable = false)
    private boolean secret;

    @Column(nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
    }

    @Builder
    public Qna(Member member, Product product, String title, String content, boolean secret) {
        this.member = member;
        this.product = product;
        this.title = title;
        this.content = content;
        this.secret = secret;
    }

    public void answer(String answer) {
        this.answer = answer;
        this.answeredAt = LocalDateTime.now();
    }

    public boolean isAnswered() {
        return answer != null;
    }
}
