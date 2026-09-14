package com.kevolution.coupon.service;

import com.kevolution.coupon.entity.Coupon;
import com.kevolution.coupon.repository.CouponRepository;
import com.kevolution.member.entity.IssuedCoupon;
import com.kevolution.member.entity.Member;
import com.kevolution.member.repository.IssuedCouponRepository;
import com.kevolution.member.repository.MemberRepository;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

/**
 * 쿠폰 관리(CouponService) 단위 테스트 — 생성 검증, 발급 규칙, 삭제 제약.
 */
@ExtendWith(MockitoExtension.class)
class CouponServiceTest {

    @Mock
    CouponRepository couponRepository;
    @Mock
    IssuedCouponRepository issuedCouponRepository;
    @Mock
    MemberRepository memberRepository;

    @InjectMocks
    CouponService couponService;

    private Member member(String userId) {
        return Member.builder().userId(userId).password("pw").name(userId).build();
    }

    private Coupon coupon() {
        return Coupon.builder()
                .name("쿠폰").discountType(Coupon.DiscountType.FIXED).discountValue(1_000).build();
    }

    @DisplayName("정상적인 정액 쿠폰은 입력값 그대로 저장된다")
    @Test
    void createFixedCoupon() {
        couponService.createCoupon("5천원 할인", "FIXED", 5_000, 30_000, null);

        ArgumentCaptor<Coupon> captor = ArgumentCaptor.forClass(Coupon.class);
        verify(couponRepository).save(captor.capture());
        Coupon saved = captor.getValue();
        assertThat(saved.getDiscountType()).isEqualTo(Coupon.DiscountType.FIXED);
        assertThat(saved.getDiscountValue()).isEqualTo(5_000);
        assertThat(saved.getMinOrderAmount()).isEqualTo(30_000);
    }

    @DisplayName("할인 유형 문자열이 올바르지 않으면 예외가 발생한다")
    @Test
    void createRejectsInvalidType() {
        assertThatThrownBy(() -> couponService.createCoupon("잘못된유형", "HALF", 10, null, null))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("할인 유형");
        verify(couponRepository, never()).save(any());
    }

    @DisplayName("할인 값이 0 이하이면 예외가 발생한다")
    @Test
    void createRejectsNonPositiveValue() {
        assertThatThrownBy(() -> couponService.createCoupon("영원할인", "FIXED", 0, null, null))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("1 이상");
        verify(couponRepository, never()).save(any());
    }

    @DisplayName("정률 할인이 100을 초과하면 예외가 발생한다")
    @Test
    void createRejectsPercentOver100() {
        assertThatThrownBy(() -> couponService.createCoupon("과도한정률", "PERCENT", 150, null, null))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("100 이하");
        verify(couponRepository, never()).save(any());
    }

    @DisplayName("발급 이력이 있는 쿠폰은 삭제할 수 없다")
    @Test
    void deleteBlockedWhenIssued() {
        Coupon coupon = coupon();
        when(couponRepository.findById(1L)).thenReturn(Optional.of(coupon));
        when(issuedCouponRepository.countByCoupon(coupon)).thenReturn(3L);

        assertThatThrownBy(() -> couponService.deleteCoupon(1L))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("삭제할 수 없");
        verify(couponRepository, never()).delete(any());
    }

    @DisplayName("발급 이력이 없는 쿠폰은 삭제된다")
    @Test
    void deleteWhenNotIssued() {
        Coupon coupon = coupon();
        when(couponRepository.findById(1L)).thenReturn(Optional.of(coupon));
        when(issuedCouponRepository.countByCoupon(coupon)).thenReturn(0L);

        couponService.deleteCoupon(1L);

        verify(couponRepository).delete(coupon);
    }

    @DisplayName("이미 보유한 회원에게 같은 쿠폰을 중복 발급하면 예외가 발생한다")
    @Test
    void issueRejectsDuplicate() {
        Coupon coupon = coupon();
        Member member = member("user1");
        when(couponRepository.findById(1L)).thenReturn(Optional.of(coupon));
        when(memberRepository.findByUserId("user1")).thenReturn(Optional.of(member));
        when(issuedCouponRepository.existsByMemberAndCoupon(member, coupon)).thenReturn(true);

        assertThatThrownBy(() -> couponService.issueToMember(1L, "user1"))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("이미");
        verify(issuedCouponRepository, never()).save(any());
    }

    @DisplayName("존재하지 않는 회원에게 발급하면 예외가 발생한다")
    @Test
    void issueRejectsUnknownMember() {
        when(couponRepository.findById(1L)).thenReturn(Optional.of(coupon()));
        when(memberRepository.findByUserId("ghost")).thenReturn(Optional.empty());

        assertThatThrownBy(() -> couponService.issueToMember(1L, "ghost"))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("찾을 수 없");
    }

    @DisplayName("일괄 발급 시 이미 보유한 회원은 건너뛰고 실제 발급 인원만 센다")
    @Test
    void issueToAllSkipsExisting() {
        Coupon coupon = coupon();
        Member a = member("a");
        Member b = member("b");
        Member c = member("c");
        when(couponRepository.findById(1L)).thenReturn(Optional.of(coupon));
        when(memberRepository.findByStatusAndRole(Member.Status.ACTIVE, Member.Role.USER))
                .thenReturn(List.of(a, b, c));
        // b 만 이미 보유
        when(issuedCouponRepository.existsByMemberAndCoupon(a, coupon)).thenReturn(false);
        when(issuedCouponRepository.existsByMemberAndCoupon(b, coupon)).thenReturn(true);
        when(issuedCouponRepository.existsByMemberAndCoupon(c, coupon)).thenReturn(false);

        int issued = couponService.issueToAllActiveMembers(1L);

        assertThat(issued).isEqualTo(2);
        verify(issuedCouponRepository, never()).save(argThatBelongsTo(b));
        verify(issuedCouponRepository, org.mockito.Mockito.times(2)).save(any(IssuedCoupon.class));
    }

    /** 특정 회원에게 발급된 IssuedCoupon 인지 매칭하는 헬퍼 (b 에게는 저장되지 않아야 함) */
    private static IssuedCoupon argThatBelongsTo(Member member) {
        return org.mockito.ArgumentMatchers.argThat(ic -> ic != null && ic.getMember() == member);
    }
}
