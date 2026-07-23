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

    /** 결제를 처리한 PG사. 기존(토스) 결제 데이터 호환을 위해 컬럼은 nullable 로 두고, 저장 시 항상 채운다. */
    @Enumerated(EnumType.STRING)
    @Column(name = "pg_provider", length = 10)
    private PgProvider pgProvider;

    /** 토스는 paymentKey, 이니시스는 승인 tid 를 담는다. */
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

    /** 결제 대행사 구분 */
    public enum PgProvider { TOSS, INICIS }

    @Builder
    public Payment(Order order, PgProvider pgProvider, String paymentKey, String method,
                   int amount, Status status, LocalDateTime approvedAt) {
        this.order = order;
        this.pgProvider = pgProvider;
        this.paymentKey = paymentKey;
        this.method = method;
        this.amount = amount;
        this.status = status;
        this.approvedAt = approvedAt;
    }
}
