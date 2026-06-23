package com.kevolution.order.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

/** 배송 정보 (주문당 1건). 송장/배송 상태 관리. */
@Entity
@Table(name = "delivery")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class Delivery {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long deliveryId;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "order_id", nullable = false, unique = true)
    private Order order;

    /** 택배사 */
    @Column(length = 50)
    private String courier;

    /** 송장번호 */
    @Column(length = 100)
    private String trackingNo;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private Status status;

    @Column(length = 50)
    private String recipient;

    @Column(length = 255)
    private String address;

    private LocalDateTime deliveredAt;

    /** 배송준비 → 출고 → 배송중 → 배송완료 */
    public enum Status { READY, SHIPPED, IN_TRANSIT, DELIVERED }

    @Builder
    public Delivery(Order order, String courier, String trackingNo, Status status,
                    String recipient, String address) {
        this.order = order;
        this.courier = courier;
        this.trackingNo = trackingNo;
        this.status = status != null ? status : Status.READY;
        this.recipient = recipient;
        this.address = address;
    }

    public void ship(String courier, String trackingNo) {
        this.courier = courier;
        this.trackingNo = trackingNo;
        this.status = Status.SHIPPED;
    }

    public void markInTransit() {
        this.status = Status.IN_TRANSIT;
    }

    public void complete() {
        this.status = Status.DELIVERED;
        this.deliveredAt = LocalDateTime.now();
    }
}
