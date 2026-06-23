package com.kevolution.coupon.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "coupon")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@AllArgsConstructor
@Builder
public class Coupon {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long couponId;

    @Column(nullable = false, length = 100)
    private String name;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private DiscountType discountType;

    @Column(nullable = false)
    private int discountValue;

    private Integer minOrderAmount;

    private LocalDateTime expiredAt;

    public enum DiscountType { FIXED, PERCENT }

    public boolean isExpired() {
        return expiredAt != null && LocalDateTime.now().isAfter(expiredAt);
    }

    public int calculateDiscount(int totalPrice) {
        if (discountType == DiscountType.FIXED) {
            return Math.min(discountValue, totalPrice);
        }
        return (int) (totalPrice * discountValue / 100.0);
    }
}
