package com.kevolution.order.service;

import com.kevolution.cart.service.CartService;
import com.kevolution.coupon.entity.Coupon;
import com.kevolution.member.entity.IssuedCoupon;
import com.kevolution.member.entity.Member;
import com.kevolution.member.repository.IssuedCouponRepository;
import com.kevolution.order.client.TossPaymentClient;
import com.kevolution.order.entity.Order;
import com.kevolution.order.repository.DeliveryRepository;
import com.kevolution.order.repository.OrderRepository;
import com.kevolution.order.repository.PaymentRepository;
import com.kevolution.pointhistory.service.PointService;
import com.kevolution.product.service.ProductService;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.Mockito.when;

/**
 * 주문 결제 직전 금액 계산(OrderService) 단위 테스트.
 * 배송비(5만원 이상 무료, 미만 3천원), 쿠폰 할인, 적립금 사용이 최종금액에 어떻게 반영되는지 검증한다.
 */
@ExtendWith(MockitoExtension.class)
class OrderServiceTest {

    private static final String USER_ID = "user1";
    private static final long ORDER_ID = 100L;

    @Mock OrderRepository orderRepository;
    @Mock PaymentRepository paymentRepository;
    @Mock DeliveryRepository deliveryRepository;
    @Mock IssuedCouponRepository issuedCouponRepository;
    @Mock CartService cartService;
    @Mock ProductService productService;
    @Mock TossPaymentClient tossPaymentClient;
    @Mock PointService pointService;

    @InjectMocks
    OrderService orderService;

    Member member;

    @BeforeEach
    void setUp() {
        member = Member.builder().userId(USER_ID).password("pw").name("홍길동").build();
    }

    /** totalPrice/discountAmount 로 결제대기 주문을 만들어 조회되도록 스텁한다. */
    private Order pendingOrder(int totalPrice, int discountAmount) {
        Order order = Order.builder()
                .member(member)
                .tossOrderId("KEV_test")
                .receiverName("홍길동").receiverPhone("010").address("서울")
                .totalPrice(totalPrice)
                .discountAmount(discountAmount)
                .finalPrice(totalPrice + discountAmount) // 임의 초기값 — 계산 로직이 덮어쓴다
                .fromCart(true)
                .build();
        when(orderRepository.findById(ORDER_ID)).thenReturn(Optional.of(order));
        return order;
    }

    private Coupon fixedCoupon(int value, Integer minOrder) {
        return Coupon.builder()
                .name("쿠폰").discountType(Coupon.DiscountType.FIXED)
                .discountValue(value).minOrderAmount(minOrder).build();
    }

    private IssuedCoupon issued(Coupon coupon) {
        return IssuedCoupon.builder().member(member).coupon(coupon).build();
    }

    @Nested
    @DisplayName("쿠폰 적용")
    class ApplyCoupon {

        @DisplayName("쿠폰 해제(null) 시 배송비만 더한 금액이 최종금액이 된다 (5만원 미만 → 배송비 3천원)")
        @Test
        void clearCouponAddsShippingFee() {
            pendingOrder(20_000, 0);

            Order result = orderService.applyCoupon(USER_ID, ORDER_ID, null);

            assertThat(result.getDiscountAmount()).isZero();
            assertThat(result.getFinalPrice()).isEqualTo(23_000); // 20000 + 3000
        }

        @DisplayName("정액 쿠폰 적용 시 상품금액에서 할인하고 배송비를 더한다")
        @Test
        void applyFixedCoupon() {
            pendingOrder(20_000, 0);
            IssuedCoupon issued = issued(fixedCoupon(5_000, null));
            when(issuedCouponRepository.findById(1L)).thenReturn(Optional.of(issued));

            Order result = orderService.applyCoupon(USER_ID, ORDER_ID, 1L);

            assertThat(result.getDiscountAmount()).isEqualTo(5_000);
            assertThat(result.getFinalPrice()).isEqualTo(18_000); // 20000 - 5000 + 3000
        }

        @DisplayName("5만원 이상이면 배송비가 무료다")
        @Test
        void freeShippingOverThreshold() {
            pendingOrder(60_000, 0);
            IssuedCoupon issued = issued(fixedCoupon(5_000, null));
            when(issuedCouponRepository.findById(1L)).thenReturn(Optional.of(issued));

            Order result = orderService.applyCoupon(USER_ID, ORDER_ID, 1L);

            assertThat(result.getFinalPrice()).isEqualTo(55_000); // 60000 - 5000 + 0
        }

        @DisplayName("최소 주문금액을 충족하지 않는 쿠폰은 적용할 수 없다")
        @Test
        void rejectBelowMinOrder() {
            pendingOrder(20_000, 0);
            IssuedCoupon issued = issued(fixedCoupon(5_000, 30_000));
            when(issuedCouponRepository.findById(1L)).thenReturn(Optional.of(issued));

            assertThatThrownBy(() -> orderService.applyCoupon(USER_ID, ORDER_ID, 1L))
                    .isInstanceOf(IllegalStateException.class)
                    .hasMessageContaining("최소 주문금액");
        }
    }

    @Nested
    @DisplayName("적립금 사용")
    class ApplyPoint {

        @DisplayName("적립금 사용액만큼 상품금액에서 차감하고 배송비를 더한다")
        @Test
        void applyPointSubtracts() {
            pendingOrder(20_000, 0);
            when(pointService.getBalance(member)).thenReturn(10_000);

            Order result = orderService.applyPoint(USER_ID, ORDER_ID, 5_000);

            assertThat(result.getPointUsed()).isEqualTo(5_000);
            assertThat(result.getFinalPrice()).isEqualTo(18_000); // 20000 - 5000 + 3000
        }

        @DisplayName("잔액보다 많은 적립금은 사용할 수 없다")
        @Test
        void rejectOverBalance() {
            pendingOrder(20_000, 0);
            when(pointService.getBalance(member)).thenReturn(1_000);

            assertThatThrownBy(() -> orderService.applyPoint(USER_ID, ORDER_ID, 5_000))
                    .isInstanceOf(IllegalStateException.class)
                    .hasMessageContaining("잔액이 부족");
        }

        @DisplayName("상품금액(할인 적용 후)을 초과하는 적립금은 사용할 수 없다 (배송비는 적립금 결제 불가)")
        @Test
        void rejectOverProductAmount() {
            pendingOrder(20_000, 0);
            when(pointService.getBalance(member)).thenReturn(30_000);

            assertThatThrownBy(() -> orderService.applyPoint(USER_ID, ORDER_ID, 25_000))
                    .isInstanceOf(IllegalStateException.class)
                    .hasMessageContaining("초과");
        }
    }
}
