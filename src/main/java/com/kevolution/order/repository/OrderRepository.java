package com.kevolution.order.repository;

import com.kevolution.member.entity.Member;
import com.kevolution.order.entity.Order;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import java.util.List;

public interface OrderRepository extends JpaRepository<Order, Long> {
    List<Order> findByMemberOrderByCreatedAtDesc(Member member);

    // 대시보드 집계
    List<Order> findTop5ByOrderByCreatedAtDesc();
    long countByStatus(Order.Status status);

    /** 특정 상태 주문의 결제금액 합계 (매출 등) */
    @Query("SELECT COALESCE(SUM(o.finalPrice), 0) FROM Order o WHERE o.status = :status")
    long sumFinalPriceByStatus(@Param("status") Order.Status status);
}
