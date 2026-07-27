package com.kevolution.member.repository;

import com.kevolution.coupon.entity.Coupon;
import com.kevolution.member.entity.IssuedCoupon;
import com.kevolution.member.entity.Member;

import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface IssuedCouponRepository extends JpaRepository<IssuedCoupon, Long> {
    List<IssuedCoupon> findByMemberAndUsedFalse(Member member);

    /** 쿠폰별 발급 건수 (관리자 목록 표시용) */
    long countByCoupon(Coupon coupon);

    /** 같은 회원에게 같은 쿠폰이 중복 발급되지 않도록 확인 */
    boolean existsByMemberAndCoupon(Member member, Coupon coupon);
}
