package com.kevolution.wishlist.controller;

import com.kevolution.wishlist.service.WishlistService;

import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.Map;

/**
 * 찜(위시리스트) — 상품 상세의 하트 토글(AJAX)과 마이페이지 찜 목록을 담당한다.
 * 권한 구분은 SecurityConfig 의 URL 규칙(/wishlist/**, /mypage/**)으로만 처리한다.
 */
@Controller
@RequiredArgsConstructor
public class WishlistController {

    private final WishlistService wishlistService;

    // ── 하트 토글 (상품 상세에서 AJAX 호출) ───────────
    @PostMapping("/wishlist/{productId}/toggle")
    @ResponseBody
    public Map<String, Object> toggle(@AuthenticationPrincipal UserDetails user,
                                      @PathVariable Long productId) {
        boolean wished = wishlistService.toggle(user.getUsername(), productId);
        return Map.of("wished", wished);
    }

    // ── 마이페이지 찜 목록 ─────────────────────────
    @GetMapping("/mypage/wishlist")
    public String list(@AuthenticationPrincipal UserDetails user, Model model) {
        model.addAttribute("wishlist", wishlistService.getMyWishlist(user.getUsername()));
        return "mypage/wishlist";
    }

    @PostMapping("/mypage/wishlist/{productId}/remove")
    public String remove(@AuthenticationPrincipal UserDetails user,
                         @PathVariable Long productId,
                         RedirectAttributes ra) {
        wishlistService.remove(user.getUsername(), productId);
        ra.addFlashAttribute("successMsg", "찜을 해제했습니다.");
        return "redirect:/mypage/wishlist";
    }
}
