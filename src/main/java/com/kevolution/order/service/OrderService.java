package com.kevolution.order.service;

import com.kevolution.cart.entity.Cart;
import com.kevolution.cart.entity.CartItem;
import com.kevolution.cart.service.CartService;
import com.kevolution.coupon.entity.Coupon;
import com.kevolution.member.entity.IssuedCoupon;
import com.kevolution.member.entity.Member;
import com.kevolution.member.repository.IssuedCouponRepository;
import com.kevolution.order.client.TossPaymentClient;
import com.kevolution.order.dto.TossConfirmResponse;
import com.kevolution.order.entity.Order;
import com.kevolution.order.entity.OrderItem;
import com.kevolution.order.entity.Payment;
import com.kevolution.order.repository.OrderRepository;
import com.kevolution.order.repository.PaymentRepository;
import com.kevolution.product.entity.Product;
import com.kevolution.product.service.ProductService;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.OffsetDateTime;
import java.util.List;
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
    private final IssuedCouponRepository issuedCouponRepository;
    private final CartService cartService;
    private final ProductService productService;
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
        int shippingFee = shippingFeeFor(totalPrice);
        int discountAmount = 0; // 쿠폰은 결제 페이지에서 선택 → applyCoupon 으로 반영
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
            .fromCart(true)
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

    /** "바로구매": 장바구니를 거치지 않고 단일 상품으로 결제 대기(PENDING) 주문을 만든다. */
    @Transactional
    public Order createDirect(String userId, Long productId, int quantity) {
        Member member = cartService.getMember(userId);
        Product product = productService.getProduct(productId);

        if (quantity < 1) {
            throw new IllegalStateException("수량은 1개 이상이어야 합니다.");
        }
        if (productService.getTotalStock(product) < quantity) {
            throw new IllegalStateException("재고가 부족합니다.");
        }

        int totalPrice = product.getPrice() * quantity;
        int shippingFee = shippingFeeFor(totalPrice);
        int finalPrice = totalPrice + shippingFee;

        Order order = Order.builder()
            .member(member)
            .tossOrderId(generateTossOrderId())
            .receiverName(nvl(member.getName()))
            .receiverPhone(nvl(member.getPhone()))
            .address(nvl(member.getAddress()))
            .totalPrice(totalPrice)
            .discountAmount(0) // 쿠폰은 결제 페이지에서 선택 → applyCoupon 으로 반영
            .finalPrice(finalPrice)
            .fromCart(false)
            .build();

        order.addOrderItem(OrderItem.builder()
            .order(order)
            .product(product)
            .productName(product.getName())
            .price(product.getPrice())
            .quantity(quantity)
            .build());

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

    // ── 쿠폰 ───────────────────────────────────────────────────

    /** 결제 페이지에서 선택 가능한 쿠폰: 본인 보유 + 미사용 + 미만료 + 최소주문액 충족 */
    public List<IssuedCoupon> getSelectableCoupons(String userId, Long orderId) {
        Order order = getPayableOrder(userId, orderId);
        return issuedCouponRepository.findByMemberAndUsedFalse(order.getMember()).stream()
            .filter(ic -> !ic.getCoupon().isExpired())
            .filter(ic -> meetsMinOrder(ic.getCoupon(), order.getTotalPrice()))
            .toList();
    }

    /**
     * 결제 직전 쿠폰 적용/해제. issuedCouponId 가 null 이면 해제한다.
     * 할인은 상품 합계(totalPrice)에만 적용하고, 배송비는 그대로 더한다.
     * 실제 쿠폰 사용 처리(use)는 결제 승인 성공 시점에 한다. 갱신된 최종 결제금액을 돌려준다.
     */
    @Transactional
    public int applyCoupon(String userId, Long orderId, Long issuedCouponId) {
        Order order = getPayableOrder(userId, orderId);
        int shippingFee = shippingFeeFor(order.getTotalPrice());

        if (issuedCouponId == null) {
            order.applyCoupon(null, 0, order.getTotalPrice() + shippingFee);
            return order.getFinalPrice();
        }

        IssuedCoupon issued = issuedCouponRepository.findById(issuedCouponId)
            .orElseThrow(() -> new IllegalArgumentException("쿠폰을 찾을 수 없습니다."));
        if (!issued.getMember().getUserId().equals(userId)) {
            throw new IllegalStateException("본인의 쿠폰이 아닙니다.");
        }
        if (issued.isUsed()) {
            throw new IllegalStateException("이미 사용한 쿠폰입니다.");
        }
        Coupon coupon = issued.getCoupon();
        if (coupon.isExpired()) {
            throw new IllegalStateException("만료된 쿠폰입니다.");
        }
        if (!meetsMinOrder(coupon, order.getTotalPrice())) {
            throw new IllegalStateException("최소 주문금액을 충족하지 않습니다.");
        }

        int discount = coupon.calculateDiscount(order.getTotalPrice());
        order.applyCoupon(issued, discount, order.getTotalPrice() - discount + shippingFee);
        return order.getFinalPrice();
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

        // 승인 전 재고 확인 — 부족하면 결제 승인 자체를 막는다.
        verifyStock(order);

        TossConfirmResponse res = tossPaymentClient.confirm(paymentKey, tossOrderId, amount);

        // 승인 성공 → 재고 차감 + 쿠폰 사용 처리
        for (OrderItem item : order.getOrderItems()) {
            productService.decreaseStock(item.getProduct(), item.getQuantity());
        }
        if (order.getIssuedCoupon() != null) {
            order.getIssuedCoupon().use();
        }

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

        // 바로구매 주문은 장바구니를 거치지 않았으므로 비우지 않는다.
        if (order.isFromCart()) {
            cartService.clearCart(userId);
        }
        return order;
    }

    // ── 내부 유틸 ──────────────────────────────────────────────

    private void verifyOwner(Order order, String userId) {
        if (!order.getMember().getUserId().equals(userId)) {
            throw new IllegalStateException("권한이 없습니다.");
        }
    }

    /** 주문 항목별로 상품 총재고가 주문 수량 이상인지 확인한다. */
    private void verifyStock(Order order) {
        for (OrderItem item : order.getOrderItems()) {
            if (productService.getTotalStock(item.getProduct()) < item.getQuantity()) {
                throw new IllegalStateException(item.getProductName() + "의 재고가 부족합니다.");
            }
        }
    }

    /** 무료배송 기준 이상이면 0, 아니면 기본 배송비 */
    private int shippingFeeFor(int totalPrice) {
        return totalPrice >= FREE_SHIPPING_THRESHOLD ? 0 : SHIPPING_FEE;
    }

    /** 쿠폰의 최소 주문금액 조건 충족 여부 (조건 없으면 항상 true) */
    private boolean meetsMinOrder(Coupon coupon, int totalPrice) {
        return coupon.getMinOrderAmount() == null || totalPrice >= coupon.getMinOrderAmount();
    }

    /** 토스 주문번호: 6~64자, 영문/숫자/-_ 만 허용 → UUID 기반으로 생성 */
    private String generateTossOrderId() {
        return "KEV_" + UUID.randomUUID().toString().replace("-", "");
    }

    private String nvl(String value) {
        return value == null ? "" : value;
    }
}
