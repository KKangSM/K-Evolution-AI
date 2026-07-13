package com.kevolution.order.controller;

import com.kevolution.order.entity.Order;
import com.kevolution.order.service.OrderService;

import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

@Controller
@RequiredArgsConstructor
@RequestMapping("/order")
public class OrderController {

    private final OrderService orderService;

    /** 결제위젯 클라이언트 키 (프론트로 내려보냄) */
    @Value("${toss.client-key}")
    private String tossClientKey;

    // ── 주문서/결제 ────────────────────────────────────────────

    /** 장바구니 "주문하기" → 결제 대기 주문 생성 후 결제 페이지로 이동 (PRG) */
    @PostMapping("/checkout")
    public String checkout(@AuthenticationPrincipal UserDetails user, RedirectAttributes ra) {
        try {
            Order order = orderService.createFromCart(user.getUsername());
            return "redirect:/order/pay/" + order.getOrderId();
        } catch (IllegalStateException e) {
            ra.addFlashAttribute("errorMsg", e.getMessage());
            return "redirect:/cart";
        }
    }

    /** 상품 상세 "바로구매" → 장바구니를 거치지 않고 결제 대기 주문 생성 후 결제 페이지로 이동 (PRG) */
    @PostMapping("/direct")
    public String direct(@RequestParam Long productId,
                         @RequestParam(defaultValue = "1") int quantity,
                         @AuthenticationPrincipal UserDetails user, RedirectAttributes ra) {
        try {
            Order order = orderService.createDirect(user.getUsername(), productId, quantity);
            return "redirect:/order/pay/" + order.getOrderId();
        } catch (RuntimeException e) {
            ra.addFlashAttribute("errorMsg", e.getMessage());
            return "redirect:/products/" + productId;
        }
    }

    /** 결제위젯 페이지 */
    @GetMapping("/pay/{orderId}")
    public String pay(@PathVariable Long orderId,
                      @AuthenticationPrincipal UserDetails user,
                      Model model, RedirectAttributes ra) {
        try {
            Order order = orderService.getPayableOrder(user.getUsername(), orderId);
            model.addAttribute("order", order);
            model.addAttribute("orderName", buildOrderName(order));
            model.addAttribute("clientKey", tossClientKey);
            model.addAttribute("customerKey", order.getMember().getMemberId());
            model.addAttribute("coupons", orderService.getSelectableCoupons(user.getUsername(), orderId));
            return "order/pay";
        } catch (RuntimeException e) {
            ra.addFlashAttribute("errorMsg", e.getMessage());
            return "redirect:/cart";
        }
    }

    /** 결제 직전 배송지 저장 (결제 페이지에서 fetch 로 호출) */
    @PostMapping("/{orderId}/shipping")
    @ResponseBody
    public ResponseEntity<Void> updateShipping(@PathVariable Long orderId,
                                               @RequestParam String receiverName,
                                               @RequestParam String receiverPhone,
                                               @RequestParam String address,
                                               @AuthenticationPrincipal UserDetails user) {
        orderService.updateShipping(user.getUsername(), orderId, receiverName, receiverPhone, address);
        return ResponseEntity.ok().build();
    }

    /** 결제 직전 쿠폰 적용/해제 (결제 페이지에서 fetch 로 호출). 갱신된 최종 결제금액을 돌려준다. */
    @PostMapping("/{orderId}/coupon")
    @ResponseBody
    public ResponseEntity<?> applyCoupon(@PathVariable Long orderId,
                                         @RequestParam(required = false) Long issuedCouponId,
                                         @AuthenticationPrincipal UserDetails user) {
        try {
            int finalPrice = orderService.applyCoupon(user.getUsername(), orderId, issuedCouponId);
            return ResponseEntity.ok(java.util.Map.of("finalPrice", finalPrice));
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(java.util.Map.of("message", e.getMessage()));
        }
    }

    // ── 결제 결과 콜백 ─────────────────────────────────────────

    /** 토스 successUrl — 서버에서 결제 승인 후 완료 페이지 렌더 */
    @GetMapping("/success")
    public String success(@RequestParam String paymentKey,
                          @RequestParam String orderId,
                          @RequestParam int amount,
                          @AuthenticationPrincipal UserDetails user,
                          Model model) {
        try {
            Order order = orderService.confirm(user.getUsername(), paymentKey, orderId, amount);
            model.addAttribute("order", order);
            return "order/success";
        } catch (RuntimeException e) {
            model.addAttribute("message", e.getMessage());
            return "order/fail";
        }
    }

    /** 토스 failUrl */
    @GetMapping("/fail")
    public String fail(@RequestParam(required = false) String code,
                       @RequestParam(required = false) String message,
                       Model model) {
        model.addAttribute("code", code);
        model.addAttribute("message", message != null ? message : "결제가 취소되었거나 실패했습니다.");
        return "order/fail";
    }

    // ── 내부 유틸 ──────────────────────────────────────────────

    /** 주문명: "상품A" 또는 "상품A 외 2건" */
    private String buildOrderName(Order order) {
        String first = order.getOrderItems().get(0).getProductName();
        int rest = order.getOrderItems().size() - 1;
        return rest > 0 ? first + " 외 " + rest + "건" : first;
    }
}
