package com.kevolution.order.service;

import com.kevolution.cart.entity.Cart;
import com.kevolution.cart.entity.CartItem;
import com.kevolution.cart.service.CartService;
import com.kevolution.member.entity.Member;
import com.kevolution.order.client.TossPaymentClient;
import com.kevolution.order.dto.TossConfirmResponse;
import com.kevolution.order.entity.Order;
import com.kevolution.order.entity.OrderItem;
import com.kevolution.order.entity.Payment;
import com.kevolution.order.repository.OrderRepository;
import com.kevolution.order.repository.PaymentRepository;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.OffsetDateTime;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class OrderService {

    /** 무료배송 기준 금액 */
    private static final int FREE_SHIPPING_THRESHOLD = 50_000;
    /** 기본 배송비 */
    private static final int SHIPPING_FEE = 3_000;

    private final OrderRepository orderRepository;
    private final PaymentRepository paymentRepository;
    private final CartService cartService;
    private final TossPaymentClient tossPaymentClient;

    // ── 주문 생성 ──────────────────────────────────────────────

    /** 장바구니 내용으로 결제 대기(PENDING) 주문을 만든다. 배송지는 회원 정보로 초기화. */
    @Transactional
    public Order createFromCart(String userId) {
        Member member = cartService.getMember(userId);
        Cart cart = cartService.getCart(member);

        if (cart.getCartItems().isEmpty()) {
            throw new IllegalStateException("장바구니가 비어 있습니다.");
        }

        int totalPrice = cart.getCartItems().stream()
            .mapToInt(CartItem::getTotalPrice)
            .sum();
        int shippingFee = totalPrice >= FREE_SHIPPING_THRESHOLD ? 0 : SHIPPING_FEE;
        int discountAmount = 0; // 쿠폰 적용은 이번 범위 밖
        int finalPrice = totalPrice - discountAmount + shippingFee;

        Order order = Order.builder()
            .member(member)
            .tossOrderId(generateTossOrderId())
            .receiverName(nvl(member.getName()))
            .receiverPhone(nvl(member.getPhone()))
            .address(nvl(member.getAddress()))
            .totalPrice(totalPrice)
            .discountAmount(discountAmount)
            .finalPrice(finalPrice)
            .build();

        for (CartItem item : cart.getCartItems()) {
            order.addOrderItem(OrderItem.builder()
                .order(order)
                .product(item.getProduct())
                .productName(item.getProduct().getName())
                .price(item.getProduct().getPrice())
                .quantity(item.getQuantity())
                .build());
        }

        return orderRepository.save(order);
    }

    /** 결제 페이지에서 쓸, 본인 소유의 결제 대기 주문 조회 */
    public Order getPayableOrder(String userId, Long orderId) {
        Order order = orderRepository.findById(orderId)
            .orElseThrow(() -> new IllegalArgumentException("주문을 찾을 수 없습니다."));
        verifyOwner(order, userId);
        if (order.getStatus() != Order.Status.PENDING) {
            throw new IllegalStateException("이미 처리된 주문입니다.");
        }
        return order;
    }

    /** 결제 직전 배송지 변경 */
    @Transactional
    public void updateShipping(String userId, Long orderId, String receiverName,
                               String receiverPhone, String address) {
        Order order = getPayableOrder(userId, orderId);
        order.updateShipping(receiverName, receiverPhone, address);
    }

    // ── 결제 승인 ──────────────────────────────────────────────

    /**
     * 토스 successUrl 콜백 처리. 금액 위·변조를 막기 위해 서버가 보관한 finalPrice 와
     * 콜백으로 넘어온 amount 를 대조한 뒤 승인 API 를 호출한다.
     */
    @Transactional
    public Order confirm(String userId, String paymentKey, String tossOrderId, int amount) {
        Order order = orderRepository.findByTossOrderId(tossOrderId)
            .orElseThrow(() -> new IllegalArgumentException("주문을 찾을 수 없습니다."));
        verifyOwner(order, userId);

        if (order.getStatus() != Order.Status.PENDING) {
            throw new IllegalStateException("이미 처리된 주문입니다.");
        }
        if (order.getFinalPrice() != amount) {
            throw new IllegalStateException("결제 금액이 주문 금액과 일치하지 않습니다.");
        }

        TossConfirmResponse res = tossPaymentClient.confirm(paymentKey, tossOrderId, amount);

        order.markAsPaid();
        paymentRepository.save(Payment.builder()
            .order(order)
            .paymentKey(res.paymentKey())
            .method(res.method())
            .amount(res.totalAmount())
            .status(Payment.Status.SUCCESS)
            .approvedAt(res.approvedAt() != null
                ? OffsetDateTime.parse(res.approvedAt()).toLocalDateTime() : null)
            .build());

        cartService.clearCart(userId);
        return order;
    }

    // ── 내부 유틸 ──────────────────────────────────────────────

    private void verifyOwner(Order order, String userId) {
        if (!order.getMember().getUserId().equals(userId)) {
            throw new IllegalStateException("권한이 없습니다.");
        }
    }

    /** 토스 주문번호: 6~64자, 영문/숫자/-_ 만 허용 → UUID 기반으로 생성 */
    private String generateTossOrderId() {
        return "KEV_" + UUID.randomUUID().toString().replace("-", "");
    }

    private String nvl(String value) {
        return value == null ? "" : value;
    }
}
