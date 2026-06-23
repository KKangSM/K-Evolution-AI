package com.kevolution.qna.entity;

import com.kevolution.member.entity.Member;
import com.kevolution.product.entity.Product;

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

    /** 고객이 답변을 확인한 일시 (null이면 미확인) */
    private LocalDateTime answerReadAt;

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

    /** 답변 등록 전에 작성자가 제목·내용을 수정한다. */
    public void edit(String title, String content) {
        this.title = title;
        this.content = content;
    }

    public void answer(String answer) {
        this.answer = answer;
        this.answeredAt = LocalDateTime.now();
    }

    public boolean isAnswered() {
        return answer != null;
    }

    /** 작성자가 답변을 처음 열람한 시점을 1회 기록한다. */
    public void markAnswerRead() {
        if (answer != null && answerReadAt == null) {
            this.answerReadAt = LocalDateTime.now();
        }
    }

    public boolean isAnswerRead() {
        return answerReadAt != null;
    }
}
