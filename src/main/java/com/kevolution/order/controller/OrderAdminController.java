package com.kevolution.order.controller;

import com.kevolution.order.entity.Order;
import com.kevolution.order.service.OrderService;

import static com.kevolution.config.ValidationUtils.isAnyBlank;

import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

/**
 * 관리자 주문 관리 (/admin/** = ROLE_ADMIN).
 * 주문 조회·검색, 송장 등록/배송 상태 변경, 주문 취소를 담당한다.
 */
@Controller
@RequiredArgsConstructor
@RequestMapping("/admin/orders")
public class OrderAdminController {

    private final OrderService orderService;

    @GetMapping
    public String list(@RequestParam(required = false) String status,
                       @RequestParam(required = false) String search,
                       @RequestParam(defaultValue = "0") int page,
                       @RequestParam(defaultValue = "20") int pageSize,
                       Model model) {
        Page<Order> orders = orderService.searchOrders(parseStatus(status), search,
                PageRequest.of(page, pageSize));
        model.addAttribute("activeMenu", "orders");
        model.addAttribute("orders", orders);
        model.addAttribute("deliveryMap", orderService.getDeliveryMap(orders.getContent()));
        model.addAttribute("search", search);
        model.addAttribute("statusFilter", status);
        return "admin/order/list";
    }

    @PostMapping("/{orderId}/ship")
    public String ship(@PathVariable Long orderId,
                       @RequestParam String courier,
                       @RequestParam String trackingNo,
                       RedirectAttributes ra) {
        if (isAnyBlank(courier, trackingNo)) {
            ra.addFlashAttribute("errorMsg", "택배사와 송장번호를 모두 입력해주세요.");
            return "redirect:/admin/orders";
        }
        try {
            orderService.registerShipping(orderId, courier.trim(), trackingNo.trim());
            ra.addFlashAttribute("successMsg", "송장이 등록되어 배송이 시작되었습니다.");
        } catch (IllegalArgumentException | IllegalStateException e) {
            ra.addFlashAttribute("errorMsg", e.getMessage());
        }
        return "redirect:/admin/orders";
    }

    @PostMapping("/{orderId}/delivery")
    public String delivery(@PathVariable Long orderId,
                           @RequestParam String action,
                           RedirectAttributes ra) {
        try {
            orderService.updateDeliveryStatus(orderId, action);
            ra.addFlashAttribute("successMsg", "배송 상태가 변경되었습니다.");
        } catch (IllegalArgumentException | IllegalStateException e) {
            ra.addFlashAttribute("errorMsg", e.getMessage());
        }
        return "redirect:/admin/orders";
    }

    @PostMapping("/{orderId}/cancel")
    public String cancel(@PathVariable Long orderId, RedirectAttributes ra) {
        try {
            orderService.cancelOrder(orderId);
            ra.addFlashAttribute("successMsg", "주문이 취소되었습니다.");
        } catch (IllegalArgumentException | IllegalStateException e) {
            ra.addFlashAttribute("errorMsg", e.getMessage());
        }
        return "redirect:/admin/orders";
    }

    /** 상태 문자열 → enum. 비었거나 잘못된 값이면 null(전체). */
    private Order.Status parseStatus(String status) {
        if (status == null || status.isBlank()) return null;
        try {
            return Order.Status.valueOf(status);
        } catch (IllegalArgumentException e) {
            return null;
        }
    }
}
