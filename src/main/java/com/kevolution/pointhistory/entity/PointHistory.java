package com.kevolution.pointhistory.entity;

import com.kevolution.member.entity.Member;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

/** 적립금 내역. amount는 적립(+)/사용(-), balance는 변동 후 잔액 스냅샷. */
@Entity
@Table(name = "point_history")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class PointHistory {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long pointHistoryId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "member_id", nullable = false)
    private Member member;

    /** 변동 금액 (적립 +, 사용/만료 -) */
    @Column(nullable = false)
    private int amount;

    /** 변동 후 잔액 */
    @Column(nullable = false)
    private int balance;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private Type type;

    @Column(length = 200)
    private String description;

    @Column(nullable = false, updatable = false)
    private LocalDateTime createdAt;

    public enum Type { EARN, USE, EXPIRE, CANCEL }

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
    }

    @Builder
    public PointHistory(Member member, int amount, int balance, Type type, String description) {
        this.member = member;
        this.amount = amount;
        this.balance = balance;
        this.type = type;
        this.description = description;
    }
}
