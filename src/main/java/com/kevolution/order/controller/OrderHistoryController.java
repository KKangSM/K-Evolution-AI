package com.kevolution.order.controller;

import com.kevolution.order.service.OrderService;
import com.kevolution.returnrequest.service.ReturnRequestService;
import com.kevolution.review.service.ReviewService;

import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

/**
 * 주문 내역(/orders) — 마이페이지에서 진입하는 회원 본인의 주문 목록.
 * 결제완료(PAID) 주문 상품에는 반품/교환 신청 버튼이 노출된다.
 */
@Controller
@RequiredArgsConstructor
public class OrderHistoryController {

    private final OrderService orderService;
    private final ReturnRequestService returnRequestService;
    private final ReviewService reviewService;

    @GetMapping("/orders")
    public String list(@AuthenticationPrincipal UserDetails user, Model model) {
        model.addAttribute("orders", orderService.getMyOrders(user.getUsername()));
        model.addAttribute("returnedItemIds", returnRequestService.getRequestedOrderItemIds(user.getUsername()));
        model.addAttribute("reviewedItemIds", reviewService.getReviewedOrderItemIds(user.getUsername()));
        return "order/history";
    }
}
