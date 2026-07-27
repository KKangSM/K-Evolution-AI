package com.kevolution.coupon.service;

import com.kevolution.coupon.entity.Coupon;
import com.kevolution.coupon.repository.CouponRepository;
import com.kevolution.member.entity.IssuedCoupon;
import com.kevolution.member.entity.Member;
import com.kevolution.member.repository.IssuedCouponRepository;
import com.kevolution.member.repository.MemberRepository;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 쿠폰 관리 — 관리자용 쿠폰 생성·삭제와 회원 발급(개별/일괄)을 담당한다.
 * 결제 시 쿠폰 적용/사용 처리는 OrderService 가 담당한다.
 */
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class CouponService {

    private final CouponRepository couponRepository;
    private final IssuedCouponRepository issuedCouponRepository;
    private final MemberRepository memberRepository;

    public List<Coupon> getAllCoupons() {
        return couponRepository.findAllByOrderByCouponIdDesc();
    }

    /** 쿠폰별 발급 건수 (couponId → 발급 수). 관리자 목록 표시용. */
    public Map<Long, Long> getIssuedCounts(List<Coupon> coupons) {
        Map<Long, Long> counts = new HashMap<>();
        for (Coupon c : coupons) {
            counts.put(c.getCouponId(), issuedCouponRepository.countByCoupon(c));
        }
        return counts;
    }

    @Transactional
    public void createCoupon(String name, String discountType, int discountValue,
                             Integer minOrderAmount, LocalDateTime expiredAt) {
        Coupon.DiscountType type = parseType(discountType);
        validateValue(type, discountValue);

        couponRepository.save(Coupon.builder()
                .name(name)
                .discountType(type)
                .discountValue(discountValue)
                .minOrderAmount(minOrderAmount)
                .expiredAt(expiredAt)
                .build());
    }

    @Transactional
    public void deleteCoupon(Long couponId) {
        Coupon coupon = getCoupon(couponId);
        if (issuedCouponRepository.countByCoupon(coupon) > 0) {
            throw new IllegalArgumentException("이미 회원에게 발급된 쿠폰은 삭제할 수 없습니다.");
        }
        couponRepository.delete(coupon);
    }

    /** 특정 회원(아이디)에게 쿠폰을 1장 발급한다. 이미 보유 중이면 예외. */
    @Transactional
    public void issueToMember(Long couponId, String userId) {
        Coupon coupon = getCoupon(couponId);
        Member member = memberRepository.findByUserId(userId)
                .orElseThrow(() -> new IllegalArgumentException("회원 아이디 '" + userId + "' 를 찾을 수 없습니다."));
        if (issuedCouponRepository.existsByMemberAndCoupon(member, coupon)) {
            throw new IllegalArgumentException("이미 해당 회원이 보유한 쿠폰입니다.");
        }
        issuedCouponRepository.save(IssuedCoupon.builder().member(member).coupon(coupon).build());
    }

    /** 활성 상태의 일반회원 전체에게 발급한다. 이미 보유한 회원은 건너뛰고, 실제 발급된 인원 수를 반환. */
    @Transactional
    public int issueToAllActiveMembers(Long couponId) {
        Coupon coupon = getCoupon(couponId);
        List<Member> members = memberRepository.findByStatusAndRole(Member.Status.ACTIVE, Member.Role.USER);
        int issued = 0;
        for (Member m : members) {
            if (issuedCouponRepository.existsByMemberAndCoupon(m, coupon)) continue;
            issuedCouponRepository.save(IssuedCoupon.builder().member(m).coupon(coupon).build());
            issued++;
        }
        return issued;
    }

    private Coupon getCoupon(Long couponId) {
        return couponRepository.findById(couponId)
                .orElseThrow(() -> new IllegalArgumentException("쿠폰을 찾을 수 없습니다."));
    }

    private Coupon.DiscountType parseType(String discountType) {
        try {
            return Coupon.DiscountType.valueOf(discountType);
        } catch (IllegalArgumentException | NullPointerException e) {
            throw new IllegalArgumentException("할인 유형이 올바르지 않습니다.");
        }
    }

    private void validateValue(Coupon.DiscountType type, int value) {
        if (value <= 0) {
            throw new IllegalArgumentException("할인 값은 1 이상이어야 합니다.");
        }
        if (type == Coupon.DiscountType.PERCENT && value > 100) {
            throw new IllegalArgumentException("퍼센트 할인은 100 이하여야 합니다.");
        }
    }
}
