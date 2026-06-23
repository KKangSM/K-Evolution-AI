package com.kevolution.member.repository;

import com.kevolution.member.entity.IssuedCoupon;
import com.kevolution.member.entity.Member;

import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface IssuedCouponRepository extends JpaRepository<IssuedCoupon, Long> {
    List<IssuedCoupon> findByMemberAndUsedFalse(Member member);
}
