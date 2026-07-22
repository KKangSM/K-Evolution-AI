package com.kevolution.returnrequest.repository;

import com.kevolution.member.entity.Member;
import com.kevolution.order.entity.OrderItem;
import com.kevolution.returnrequest.entity.ReturnRequest;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface ReturnRequestRepository extends JpaRepository<ReturnRequest, Long> {

    /** 같은 주문상품에 대한 중복 신청 방지 */
    boolean existsByOrderItem(OrderItem orderItem);

    /** 회원 본인 신청 목록 (주문상품까지 로딩, 최신순) */
    @Query("SELECT r FROM ReturnRequest r JOIN FETCH r.orderItem "
         + "WHERE r.member.userId = :userId ORDER BY r.createdAt DESC")
    List<ReturnRequest> findMyWithItem(@Param("userId") String userId);

    /** 관리자 전체 목록 (주문상품·회원까지 로딩, 최신순) */
    @Query("SELECT r FROM ReturnRequest r JOIN FETCH r.orderItem JOIN FETCH r.member "
         + "ORDER BY r.createdAt DESC")
    List<ReturnRequest> findAllWithDetails();

    /** 주문 내역에서 '이미 신청됨' 표시용 — 회원이 신청한 주문상품 ID 목록 */
    @Query("SELECT r.orderItem.orderItemId FROM ReturnRequest r WHERE r.member.userId = :userId")
    List<Long> findRequestedOrderItemIds(@Param("userId") String userId);
}
