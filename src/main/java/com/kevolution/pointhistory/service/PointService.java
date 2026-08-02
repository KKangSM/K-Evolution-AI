package com.kevolution.pointhistory.service;

import com.kevolution.member.entity.Member;
import com.kevolution.pointhistory.entity.PointHistory;
import com.kevolution.pointhistory.repository.PointHistoryRepository;

import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * 적립금(포인트) 엔진.
 * 잔액은 PointHistory 의 마지막 balance 스냅샷으로 관리하고, 적립/사용은 모두 이 서비스를 거친다.
 *
 * ── 정책(TODO): 아래 상수/규칙은 기획 수치로 채워 넣을 것 ──
 *  - EARN_RATE: 결제금액 대비 적립률
 *  - (선택) 최소 사용 단위, 사용 상한, 유효기간/만료(EXPIRE), 주문취소 복원(CANCEL) 등
 */
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class PointService {

    /** TODO(정책): 적립률. 예) 0.01 = 결제금액의 1% 적립 */
    private static final double EARN_RATE = 0.01;

    private final PointHistoryRepository pointHistoryRepository;

    /** 현재 적립금 잔액 (가장 최근 내역의 잔액 스냅샷, 없으면 0) */
    public int getBalance(Member member) {
        PointHistory latest = pointHistoryRepository.findFirstByMemberOrderByCreatedAtDesc(member);
        return latest != null ? latest.getBalance() : 0;
    }

    /** 적립금 내역 (마이페이지 조회용) */
    public Page<PointHistory> getHistory(Member member, Pageable pageable) {
        return pointHistoryRepository.findByMemberOrderByCreatedAtDesc(member, pageable);
    }

    /** 결제금액 기준 적립 포인트 계산 (원 단위 버림) */
    public int calculateEarnPoints(int paidAmount) {
        return (int) (paidAmount * EARN_RATE);
    }

    /** 적립 (+). amount 가 0 이하면 아무 것도 하지 않는다. */
    @Transactional
    public void earn(Member member, int amount, String description) {
        if (amount <= 0) return;
        int balance = getBalance(member) + amount;
        pointHistoryRepository.save(PointHistory.builder()
                .member(member).amount(amount).balance(balance)
                .type(PointHistory.Type.EARN).description(description).build());
    }

    /** 사용 (-). 잔액이 부족하면 예외. */
    @Transactional
    public void use(Member member, int amount, String description) {
        if (amount <= 0) return;
        int current = getBalance(member);
        if (amount > current) {
            throw new IllegalStateException("적립금 잔액이 부족합니다.");
        }
        int balance = current - amount;
        pointHistoryRepository.save(PointHistory.builder()
                .member(member).amount(-amount).balance(balance)
                .type(PointHistory.Type.USE).description(description).build());
    }
}
