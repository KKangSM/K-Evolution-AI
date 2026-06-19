package com.kevolution.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

/** 반품/교환 요청. 주문 상품(order_item) 단위로 신청. */
@Entity
@Table(name = "return_request")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class ReturnRequest {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long returnId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "order_item_id", nullable = false)
    private OrderItem orderItem;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "member_id", nullable = false)
    private Member member;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private Type type;

    @Column(columnDefinition = "TEXT")
    private String reason;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private Status status;

    @Column(nullable = false, updatable = false)
    private LocalDateTime createdAt;

    private LocalDateTime processedAt;

    public enum Type { RETURN, EXCHANGE }
    public enum Status { REQUESTED, APPROVED, REJECTED, COMPLETED }

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        if (status == null) status = Status.REQUESTED;
    }

    @Builder
    public ReturnRequest(OrderItem orderItem, Member member, Type type, String reason) {
        this.orderItem = orderItem;
        this.member = member;
        this.type = type;
        this.reason = reason;
        this.status = Status.REQUESTED;
    }

    public void approve() {
        this.status = Status.APPROVED;
        this.processedAt = LocalDateTime.now();
    }

    public void reject() {
        this.status = Status.REJECTED;
        this.processedAt = LocalDateTime.now();
    }

    public void complete() {
        this.status = Status.COMPLETED;
        this.processedAt = LocalDateTime.now();
    }
}
