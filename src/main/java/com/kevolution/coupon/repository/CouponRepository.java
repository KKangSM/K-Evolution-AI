package com.kevolution.coupon.repository;

import com.kevolution.coupon.entity.Coupon;

import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface CouponRepository extends JpaRepository<Coupon, Long> {
    List<Coupon> findAllByOrderByCouponIdDesc();
}
