package com.kevolution.member.entity;

import com.kevolution.terms.entity.Terms;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

/** 회원 약관 동의 이력 (회원 ↔ 약관). 가입 시 동의한 약관을 시점과 함께 기록한다. */
@Entity
@Table(name = "member_terms_agreement")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class TermsAgreement {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "agreement_id")
    private Long agreementId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "member_id", nullable = false)
    private Member member;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "term_id", nullable = false)
    private Terms terms;

    @Column(nullable = false, updatable = false)
    private LocalDateTime agreedAt;

    @PrePersist
    protected void onCreate() {
        agreedAt = LocalDateTime.now();
    }

    @Builder
    public TermsAgreement(Member member, Terms terms) {
        this.member = member;
        this.terms = terms;
    }
}
