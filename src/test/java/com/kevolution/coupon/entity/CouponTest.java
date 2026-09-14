package com.kevolution.coupon.entity;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;

import java.time.LocalDateTime;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * 쿠폰 할인 계산·만료 판단 단위 테스트.
 * 순수 로직(의존성 없음)이라 스프링 컨텍스트/DB 없이 검증한다.
 */
class CouponTest {

    private Coupon fixed(int value) {
        return Coupon.builder()
                .name("정액쿠폰")
                .discountType(Coupon.DiscountType.FIXED)
                .discountValue(value)
                .build();
    }

    private Coupon percent(int value) {
        return Coupon.builder()
                .name("정률쿠폰")
                .discountType(Coupon.DiscountType.PERCENT)
                .discountValue(value)
                .build();
    }

    @Nested
    @DisplayName("정액(FIXED) 할인")
    class Fixed {

        @Test
        @DisplayName("주문금액이 할인액보다 크면 할인액 그대로 적용된다")
        void discountBelowTotal() {
            assertThat(fixed(5_000).calculateDiscount(20_000)).isEqualTo(5_000);
        }

        @Test
        @DisplayName("할인액이 주문금액보다 크면 주문금액을 넘지 않도록 상한이 걸린다")
        void discountCappedAtTotal() {
            assertThat(fixed(30_000).calculateDiscount(20_000)).isEqualTo(20_000);
        }

        @Test
        @DisplayName("주문금액과 할인액이 같으면 전액 할인된다")
        void discountEqualsTotal() {
            assertThat(fixed(20_000).calculateDiscount(20_000)).isEqualTo(20_000);
        }
    }

    @Nested
    @DisplayName("정률(PERCENT) 할인")
    class Percent {

        @Test
        @DisplayName("퍼센트 비율만큼 할인된다")
        void discountByRate() {
            assertThat(percent(10).calculateDiscount(25_000)).isEqualTo(2_500);
        }

        @Test
        @DisplayName("소수점 이하는 버림(원 단위 절사)된다")
        void discountTruncatesFraction() {
            // 25 * 10 / 100.0 = 2.5 → 2
            assertThat(percent(10).calculateDiscount(25)).isEqualTo(2);
        }

        @Test
        @DisplayName("100% 할인이면 전액 할인된다")
        void discountFullRate() {
            assertThat(percent(100).calculateDiscount(33_000)).isEqualTo(33_000);
        }
    }

    @Nested
    @DisplayName("만료 판단")
    class Expiry {

        @Test
        @DisplayName("만료일이 없으면 만료되지 않은 것으로 본다")
        void notExpiredWhenNull() {
            Coupon coupon = Coupon.builder()
                    .name("무기한")
                    .discountType(Coupon.DiscountType.FIXED)
                    .discountValue(1_000)
                    .expiredAt(null)
                    .build();
            assertThat(coupon.isExpired()).isFalse();
        }

        @Test
        @DisplayName("만료일이 과거면 만료된 것으로 본다")
        void expiredWhenPast() {
            Coupon coupon = Coupon.builder()
                    .name("어제만료")
                    .discountType(Coupon.DiscountType.FIXED)
                    .discountValue(1_000)
                    .expiredAt(LocalDateTime.now().minusDays(1))
                    .build();
            assertThat(coupon.isExpired()).isTrue();
        }

        @Test
        @DisplayName("만료일이 미래면 만료되지 않은 것으로 본다")
        void notExpiredWhenFuture() {
            Coupon coupon = Coupon.builder()
                    .name("내일만료")
                    .discountType(Coupon.DiscountType.FIXED)
                    .discountValue(1_000)
                    .expiredAt(LocalDateTime.now().plusDays(1))
                    .build();
            assertThat(coupon.isExpired()).isFalse();
        }
    }
}
