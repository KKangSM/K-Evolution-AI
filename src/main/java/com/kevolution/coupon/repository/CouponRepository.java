package com.kevolution.coupon.repository;

import com.kevolution.coupon.entity.Coupon;

import org.springframework.data.jpa.repository.JpaRepository;

public interface CouponRepository extends JpaRepository<Coupon, Long> {
}
