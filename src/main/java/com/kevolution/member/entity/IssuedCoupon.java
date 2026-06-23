package com.kevolution.member.entity;

import com.kevolution.coupon.entity.Coupon;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

/** 회원이 발급받아 보유한 쿠폰(사용여부 포함). Member ↔ Coupon 연결. */
@Entity
@Table(name = "member_coupon")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class IssuedCoupon {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "member_coupon_id")
    private Long issuedCouponId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "member_id", nullable = false)
    private Member member;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "coupon_id", nullable = false)
    private Coupon coupon;

    @Column(name = "is_used", nullable = false)
    private boolean used;

    private LocalDateTime usedAt;

    @Builder
    public IssuedCoupon(Member member, Coupon coupon) {
        this.member = member;
        this.coupon = coupon;
        this.used = false;
    }

    public void use() {
        this.used = true;
        this.usedAt = LocalDateTime.now();
    }
}
