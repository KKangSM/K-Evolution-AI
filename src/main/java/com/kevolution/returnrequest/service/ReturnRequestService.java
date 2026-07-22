package com.kevolution.returnrequest.service;

import com.kevolution.member.entity.Member;
import com.kevolution.member.repository.MemberRepository;
import com.kevolution.order.entity.Order;
import com.kevolution.order.entity.OrderItem;
import com.kevolution.order.repository.OrderItemRepository;
import com.kevolution.returnrequest.entity.ReturnRequest;
import com.kevolution.returnrequest.repository.ReturnRequestRepository;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

/**
 * 반품/교환 신청 서비스 — 회원용 신청·조회와 관리자용 전체 조회·승인/거절/완료를 담당한다.
 * 권한 구분은 호출 측 URL(SecurityConfig)에서만 다룬다.
 */
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class ReturnRequestService {

    private final ReturnRequestRepository returnRequestRepository;
    private final OrderItemRepository orderItemRepository;
    private final MemberRepository memberRepository;

    // ── 회원용 ────────────────────────────────────

    /** 결제완료(PAID)된 본인 주문상품에 대해서만 반품/교환을 신청할 수 있다. 상품당 1건만. */
    @Transactional
    public void request(String userId, Long orderItemId, ReturnRequest.Type type, String reason) {
        Member member = member(userId);
        OrderItem orderItem = orderItemRepository.findById(orderItemId)
                .orElseThrow(() -> new IllegalArgumentException("주문 상품을 찾을 수 없습니다."));

        Order order = orderItem.getOrder();
        if (!order.getMember().getUserId().equals(userId)) {
            throw new IllegalArgumentException("본인의 주문만 신청할 수 있습니다.");
        }
        if (order.getStatus() != Order.Status.PAID) {
            throw new IllegalArgumentException("결제 완료된 주문만 반품/교환을 신청할 수 있습니다.");
        }
        if (returnRequestRepository.existsByOrderItem(orderItem)) {
            throw new IllegalArgumentException("이미 신청된 상품입니다.");
        }

        returnRequestRepository.save(ReturnRequest.builder()
                .orderItem(orderItem)
                .member(member)
                .type(type)
                .reason(reason)
                .build());
    }

    public List<ReturnRequest> getMyReturns(String userId) {
        return returnRequestRepository.findMyWithItem(userId);
    }

    /** 주문 내역에서 '신청됨' 배지를 그리기 위한 주문상품 ID 목록 */
    public List<Long> getRequestedOrderItemIds(String userId) {
        return returnRequestRepository.findRequestedOrderItemIds(userId);
    }

    // ── 관리자용 (/admin/returns) ──────────────────

    public List<ReturnRequest> getAll() {
        return returnRequestRepository.findAllWithDetails();
    }

    @Transactional
    public void approve(Long returnId) {
        load(returnId).approve();
    }

    @Transactional
    public void reject(Long returnId) {
        load(returnId).reject();
    }

    @Transactional
    public void complete(Long returnId) {
        load(returnId).complete();
    }

    private ReturnRequest load(Long returnId) {
        return returnRequestRepository.findById(returnId)
                .orElseThrow(() -> new IllegalArgumentException("반품/교환 신청을 찾을 수 없습니다."));
    }

    private Member member(String userId) {
        return memberRepository.findByUserId(userId)
                .orElseThrow(() -> new IllegalArgumentException("회원을 찾을 수 없습니다."));
    }
}
