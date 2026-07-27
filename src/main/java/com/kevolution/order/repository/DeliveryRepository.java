package com.kevolution.order.repository;

import com.kevolution.order.entity.Delivery;
import com.kevolution.order.entity.Order;

import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface DeliveryRepository extends JpaRepository<Delivery, Long> {
    Optional<Delivery> findByOrder(Order order);

    /** 관리자 목록: 여러 주문의 배송 정보를 한 번에 조회 (주문별 배송상태 표시용) */
    List<Delivery> findByOrderIn(List<Order> orders);
}
