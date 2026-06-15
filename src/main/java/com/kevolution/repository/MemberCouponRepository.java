package com.kevolution.repository;

import com.kevolution.entity.Member;
import com.kevolution.entity.MemberCoupon;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface MemberCouponRepository extends JpaRepository<MemberCoupon, Long> {
    List<MemberCoupon> findByMemberAndUsedFalse(Member member);
}
