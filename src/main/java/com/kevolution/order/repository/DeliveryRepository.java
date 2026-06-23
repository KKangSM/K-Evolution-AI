package com.kevolution.order.repository;

import com.kevolution.order.entity.Delivery;
import com.kevolution.order.entity.Order;

import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface DeliveryRepository extends JpaRepository<Delivery, Long> {
    Optional<Delivery> findByOrder(Order order);
}
