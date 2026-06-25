package com.kevolution.cart.controller;

import com.kevolution.cart.entity.Cart;
import com.kevolution.cart.service.CartService;
import com.kevolution.member.entity.Member;

import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

@Controller
@RequiredArgsConstructor
public class CartController {

    private final CartService cartService;

    @GetMapping("/cart")
    public String cart(@AuthenticationPrincipal UserDetails user, Model model) {
        Member member = cartService.getMember(user.getUsername());
        Cart cart = cartService.getCart(member);
        int totalPrice = cart.getCartItems().stream()
            .mapToInt(item -> item.getTotalPrice())
            .sum();
        model.addAttribute("cart", cart);
        model.addAttribute("totalPrice", totalPrice);
        return "cart/index";
    }

    @PostMapping("/cart/add")
    public String add(
        @RequestParam Long productId,
        @RequestParam(defaultValue = "1") int quantity,
        @AuthenticationPrincipal UserDetails user,
        RedirectAttributes ra
    ) {
        try {
            cartService.addItem(user.getUsername(), productId, quantity);
            ra.addFlashAttribute("successMsg", "장바구니에 담겼습니다.");
        } catch (IllegalStateException e) {
            ra.addFlashAttribute("errorMsg", e.getMessage());
        }
        return "redirect:/products/" + productId;
    }

    @PostMapping("/cart/update")
    public String update(
        @RequestParam Long cartItemId,
        @RequestParam int quantity,
        @AuthenticationPrincipal UserDetails user,
        RedirectAttributes ra
    ) {
        try {
            cartService.updateQuantity(user.getUsername(), cartItemId, quantity);
        } catch (IllegalStateException e) {
            ra.addFlashAttribute("errorMsg", e.getMessage());
        }
        return "redirect:/cart";
    }

    @PostMapping("/cart/remove/{cartItemId}")
    public String remove(
        @PathVariable Long cartItemId,
        @AuthenticationPrincipal UserDetails user,
        RedirectAttributes ra
    ) {
        try {
            cartService.removeItem(user.getUsername(), cartItemId);
            ra.addFlashAttribute("successMsg", "상품을 장바구니에서 제거했습니다.");
        } catch (IllegalStateException e) {
            ra.addFlashAttribute("errorMsg", e.getMessage());
        }
        return "redirect:/cart";
    }
}
