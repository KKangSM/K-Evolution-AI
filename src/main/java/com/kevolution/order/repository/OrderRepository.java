package com.kevolution.order.repository;

import com.kevolution.member.entity.Member;
import com.kevolution.order.entity.Order;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import java.util.List;
import java.util.Optional;

public interface OrderRepository extends JpaRepository<Order, Long> {
    List<Order> findByMemberOrderByCreatedAtDesc(Member member);

    /** 관리자 주문 관리: 상태 필터 + 주문자명/연락처 검색 (둘 다 null 이면 전체) 최신순 */
    @Query("SELECT o FROM Order o WHERE "
         + "(:status IS NULL OR o.status = :status) AND "
         + "(:keyword IS NULL OR o.receiverName LIKE %:keyword% OR o.receiverPhone LIKE %:keyword%) "
         + "ORDER BY o.createdAt DESC")
    Page<Order> searchOrders(@Param("status") Order.Status status,
                             @Param("keyword") String keyword,
                             Pageable pageable);

    /** 주문 내역 화면용 — 주문 상품/상품정보까지 한 번에 로딩(LazyInitialization 방지) */
    @Query("SELECT DISTINCT o FROM Order o "
         + "JOIN FETCH o.orderItems oi JOIN FETCH oi.product "
         + "WHERE o.member.userId = :userId ORDER BY o.createdAt DESC")
    List<Order> findWithItemsByUserId(@Param("userId") String userId);

    /** 토스 결제 승인 콜백에서 주문번호(문자열)로 주문 조회 */
    Optional<Order> findByTossOrderId(String tossOrderId);

    // 대시보드 집계
    List<Order> findTop5ByOrderByCreatedAtDesc();
    long countByStatus(Order.Status status);

    /** 특정 상태 주문의 결제금액 합계 (매출 등) */
    @Query("SELECT COALESCE(SUM(o.finalPrice), 0) FROM Order o WHERE o.status = :status")
    long sumFinalPriceByStatus(@Param("status") Order.Status status);
}
