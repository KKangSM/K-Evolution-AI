package com.kevolution.pointhistory.service;

import com.kevolution.member.entity.Member;
import com.kevolution.member.repository.MemberRepository;
import com.kevolution.pointhistory.entity.PointHistory;
import com.kevolution.pointhistory.repository.PointHistoryRepository;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

/**
 * 적립금 엔진(PointService) 단위 테스트.
 * 잔액은 "가장 최근 내역의 balance 스냅샷"으로 관리된다는 계약을 검증한다.
 */
@ExtendWith(MockitoExtension.class)
class PointServiceTest {

    @Mock
    PointHistoryRepository pointHistoryRepository;
    @Mock
    MemberRepository memberRepository;

    @InjectMocks
    PointService pointService;

    Member member;

    @BeforeEach
    void setUp() {
        member = Member.builder().userId("user1").password("pw").name("홍길동").build();
    }

    private PointHistory snapshot(int balance) {
        return PointHistory.builder()
                .member(member).amount(balance).balance(balance)
                .type(PointHistory.Type.EARN).description("테스트").build();
    }

    @DisplayName("적립 내역이 없으면 잔액은 0이다")
    @Test
    void balanceIsZeroWhenNoHistory() {
        when(pointHistoryRepository.findFirstByMemberOrderByCreatedAtDesc(member)).thenReturn(null);
        assertThat(pointService.getBalance(member)).isZero();
    }

    @DisplayName("잔액은 가장 최근 내역의 balance 스냅샷을 따른다")
    @Test
    void balanceFollowsLatestSnapshot() {
        when(pointHistoryRepository.findFirstByMemberOrderByCreatedAtDesc(member)).thenReturn(snapshot(1_500));
        assertThat(pointService.getBalance(member)).isEqualTo(1_500);
    }

    @DisplayName("적립 포인트는 결제금액의 1%이며 원 단위는 버림한다")
    @Test
    void calculateEarnPoints() {
        assertThat(pointService.calculateEarnPoints(10_000)).isEqualTo(100);
        assertThat(pointService.calculateEarnPoints(99)).isZero(); // 0.99 → 0
    }

    @DisplayName("적립하면 (기존잔액+적립액)을 새 잔액 스냅샷으로 EARN 내역을 저장한다")
    @Test
    void earnAddsToBalance() {
        when(pointHistoryRepository.findFirstByMemberOrderByCreatedAtDesc(member)).thenReturn(snapshot(1_000));

        pointService.earn(member, 500, "구매 적립");

        ArgumentCaptor<PointHistory> captor = ArgumentCaptor.forClass(PointHistory.class);
        verify(pointHistoryRepository).save(captor.capture());
        PointHistory saved = captor.getValue();
        assertThat(saved.getAmount()).isEqualTo(500);
        assertThat(saved.getBalance()).isEqualTo(1_500);
        assertThat(saved.getType()).isEqualTo(PointHistory.Type.EARN);
    }

    @DisplayName("적립액이 0 이하이면 아무것도 저장하지 않는다")
    @Test
    void earnIgnoresNonPositive() {
        pointService.earn(member, 0, "무효");
        pointService.earn(member, -100, "무효");
        verify(pointHistoryRepository, never()).save(org.mockito.ArgumentMatchers.any());
    }

    @DisplayName("사용하면 음수 amount와 (잔액-사용액) 스냅샷으로 USE 내역을 저장한다")
    @Test
    void useSubtractsFromBalance() {
        when(pointHistoryRepository.findFirstByMemberOrderByCreatedAtDesc(member)).thenReturn(snapshot(1_000));

        pointService.use(member, 300, "주문 결제 사용");

        ArgumentCaptor<PointHistory> captor = ArgumentCaptor.forClass(PointHistory.class);
        verify(pointHistoryRepository).save(captor.capture());
        PointHistory saved = captor.getValue();
        assertThat(saved.getAmount()).isEqualTo(-300);
        assertThat(saved.getBalance()).isEqualTo(700);
        assertThat(saved.getType()).isEqualTo(PointHistory.Type.USE);
    }

    @DisplayName("잔액보다 많이 사용하려 하면 예외가 발생하고 저장하지 않는다")
    @Test
    void useRejectsInsufficientBalance() {
        when(pointHistoryRepository.findFirstByMemberOrderByCreatedAtDesc(member)).thenReturn(snapshot(200));

        assertThatThrownBy(() -> pointService.use(member, 500, "초과 사용"))
                .isInstanceOf(IllegalStateException.class)
                .hasMessageContaining("잔액이 부족");
        verify(pointHistoryRepository, never()).save(org.mockito.ArgumentMatchers.any());
    }

    @DisplayName("사용액이 0 이하이면 아무것도 저장하지 않는다")
    @Test
    void useIgnoresNonPositive() {
        pointService.use(member, 0, "무효");
        verify(pointHistoryRepository, never()).save(org.mockito.ArgumentMatchers.any());
    }
}
