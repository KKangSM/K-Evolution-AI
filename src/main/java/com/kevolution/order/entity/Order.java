package com.kevolution.order.entity;

import com.kevolution.member.entity.IssuedCoupon;
import com.kevolution.member.entity.Member;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "orders")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class Order {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long orderId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "member_id", nullable = false)
    private Member member;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "member_coupon_id")
    private IssuedCoupon issuedCoupon;

    /** 토스페이먼츠에 넘기는 주문번호(문자열). 결제 승인 콜백에서 이 값으로 주문을 되찾는다. */
    @Column(name = "toss_order_id", unique = true, length = 64)
    private String tossOrderId;

    @Column(nullable = false, length = 50)
    private String receiverName;

    @Column(nullable = false, length = 20)
    private String receiverPhone;

    @Column(nullable = false, length = 255)
    private String address;

    @Column(nullable = false)
    private int totalPrice;

    @Column(nullable = false)
    private int discountAmount;

    /** 사용한 적립금 (결제 시 상품금액에서 차감) */
    @Column(nullable = false)
    private int pointUsed;

    @Column(nullable = false)
    private int finalPrice;

    /** 장바구니 주문이면 true, "바로구매" 주문이면 false. 결제 승인 후 장바구니 비우기 여부를 가른다. */
    @Column(nullable = false)
    private boolean fromCart;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private Status status;

    @Column(nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @OneToMany(mappedBy = "order", cascade = CascadeType.ALL)
    private List<OrderItem> orderItems = new ArrayList<>();

    @OneToOne(mappedBy = "order", cascade = CascadeType.ALL)
    private Payment payment;

    public enum Status { PENDING, PAID, CANCELLED }

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
    }

    @Builder
    public Order(Member member, IssuedCoupon issuedCoupon, String tossOrderId, String receiverName,
                 String receiverPhone, String address, int totalPrice, int discountAmount, int finalPrice,
                 boolean fromCart) {
        this.member = member;
        this.issuedCoupon = issuedCoupon;
        this.tossOrderId = tossOrderId;
        this.receiverName = receiverName;
        this.receiverPhone = receiverPhone;
        this.address = address;
        this.totalPrice = totalPrice;
        this.discountAmount = discountAmount;
        this.finalPrice = finalPrice;
        this.fromCart = fromCart;
        this.status = Status.PENDING;
    }

    /** 주문 항목 추가 (연관관계 편의 메서드) */
    public void addOrderItem(OrderItem item) {
        this.orderItems.add(item);
    }

    /** 결제 직전 쿠폰 적용/해제. 할인액과 최종 결제금액을 함께 갱신한다. (쿠폰 해제 시 null 전달) */
    public void applyCoupon(IssuedCoupon issuedCoupon, int discountAmount, int finalPrice) {
        this.issuedCoupon = issuedCoupon;
        this.discountAmount = discountAmount;
        this.finalPrice = finalPrice;
    }

    /** 결제 직전 적립금 사용/해제. 사용액과 최종 결제금액을 함께 갱신한다. */
    public void applyPoint(int pointUsed, int finalPrice) {
        this.pointUsed = pointUsed;
        this.finalPrice = finalPrice;
    }

    /** 결제 직전 배송지 정보 변경 */
    public void updateShipping(String receiverName, String receiverPhone, String address) {
        this.receiverName = receiverName;
        this.receiverPhone = receiverPhone;
        this.address = address;
    }

    public void markAsPaid() {
        this.status = Status.PAID;
    }

    public void cancel() {
        this.status = Status.CANCELLED;
    }
}
