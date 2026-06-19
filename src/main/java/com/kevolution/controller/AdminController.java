package com.kevolution.controller;

import com.kevolution.entity.Order;
import com.kevolution.repository.MemberRepository;
import com.kevolution.repository.OrderRepository;
import com.kevolution.repository.ProductRepository;
import com.kevolution.repository.QnaRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

/** 관리자 대시보드. /admin/** 는 SecurityConfig에서 ROLE_ADMIN으로 제한됨. */
@Controller
@RequestMapping("/admin")
@RequiredArgsConstructor
public class AdminController {

    /** 재고 부족 기준 수량 */
    private static final int LOW_STOCK_THRESHOLD = 5;

    private final MemberRepository memberRepository;
    private final ProductRepository productRepository;
    private final OrderRepository orderRepository;
    private final QnaRepository qnaRepository;

    @GetMapping
    public String dashboard(Model model) {
        model.addAttribute("activeMenu", "dashboard");

        // 핵심 지표
        model.addAttribute("memberCount", memberRepository.count());
        model.addAttribute("productCount", productRepository.count());
        model.addAttribute("orderCount", orderRepository.count());
        model.addAttribute("paidSales", orderRepository.sumFinalPriceByStatus(Order.Status.PAID));

        // 처리 필요 항목
        model.addAttribute("pendingOrderCount", orderRepository.countByStatus(Order.Status.PENDING));
        model.addAttribute("lowStockCount", productRepository.countByStockLessThan(LOW_STOCK_THRESHOLD));
        model.addAttribute("unansweredQna", qnaRepository.countByAnswerIsNull());

        // 최근 주문
        model.addAttribute("recentOrders", orderRepository.findTop5ByOrderByCreatedAtDesc());

        return "admin/dashboard";
    }
}
