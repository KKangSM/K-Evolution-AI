package com.kevolution.order.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "payment")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class Payment {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long paymentId;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "order_id", unique = true)
    private Order order;

    @Column(length = 200)
    private String paymentKey;

    @Column(length = 50)
    private String method;

    @Column(nullable = false)
    private int amount;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 10)
    private Status status;

    private LocalDateTime approvedAt;

    public enum Status { SUCCESS, FAIL }

    @Builder
    public Payment(Order order, String paymentKey, String method, int amount, Status status, LocalDateTime approvedAt) {
        this.order = order;
        this.paymentKey = paymentKey;
        this.method = method;
        this.amount = amount;
        this.status = status;
        this.approvedAt = approvedAt;
    }
}
