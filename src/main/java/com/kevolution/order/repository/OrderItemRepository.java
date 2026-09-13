package com.kevolution.order.repository;

import com.kevolution.member.entity.Member;
import com.kevolution.order.entity.Order;
import com.kevolution.order.entity.OrderItem;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface OrderItemRepository extends JpaRepository<OrderItem, Long> {

    /**
     * 회원이 특정 상태(결제완료) 주문에서 산 상품들의 카테고리별 건수.
     * 개인화 추천의 카테고리 선호도 계산에 사용한다. (카테고리 없는 상품은 제외)
     * 반환: Object[]{ Category, Long count }
     */
    @Query("SELECT oi.product.category, COUNT(oi) FROM OrderItem oi " +
           "WHERE oi.order.member = :member AND oi.order.status = :status " +
           "AND oi.product.category IS NOT NULL " +
           "GROUP BY oi.product.category")
    List<Object[]> countCategoriesByMember(@Param("member") Member member,
                                           @Param("status") Order.Status status);

    /** 회원이 특정 상태(결제완료) 주문으로 산 상품 ID 목록 — 추천에서 이미 산 상품을 빼기 위함 */
    @Query("SELECT DISTINCT oi.product.productId FROM OrderItem oi " +
           "WHERE oi.order.member = :member AND oi.order.status = :status")
    List<Long> findPurchasedProductIds(@Param("member") Member member,
                                       @Param("status") Order.Status status);
}
