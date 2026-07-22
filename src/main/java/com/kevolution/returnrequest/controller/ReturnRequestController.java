package com.kevolution.returnrequest.controller;

import com.kevolution.returnrequest.entity.ReturnRequest;
import com.kevolution.returnrequest.service.ReturnRequestService;

import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

/**
 * 반품/교환 — 회원용(/mypage/returns) 신청·조회와 관리자용(/admin/returns) 처리를 한 곳에서 담당한다.
 * 권한 구분은 SecurityConfig 의 URL 규칙만으로 처리한다.
 */
@Controller
@RequiredArgsConstructor
public class ReturnRequestController {

    private final ReturnRequestService returnRequestService;

    // ── 회원용 (/mypage/returns) ───────────────────
    @PostMapping("/mypage/returns/request")
    public String request(@AuthenticationPrincipal UserDetails user,
                          @RequestParam Long orderItemId,
                          @RequestParam String type,
                          @RequestParam(required = false) String reason,
                          RedirectAttributes ra) {
        try {
            returnRequestService.request(user.getUsername(), orderItemId,
                    ReturnRequest.Type.valueOf(type), reason);
            ra.addFlashAttribute("successMsg", "반품/교환 신청이 접수되었습니다.");
        } catch (IllegalArgumentException e) {
            ra.addFlashAttribute("errorMsg", e.getMessage());
        }
        return "redirect:/orders";
    }

    @GetMapping("/mypage/returns")
    public String myList(@AuthenticationPrincipal UserDetails user, Model model) {
        model.addAttribute("returns", returnRequestService.getMyReturns(user.getUsername()));
        return "mypage/returns";
    }

    // ── 관리자용 (/admin/returns = ROLE_ADMIN) ──────
    @GetMapping("/admin/returns")
    public String adminList(Model model) {
        model.addAttribute("activeMenu", "returns");
        model.addAttribute("returns", returnRequestService.getAll());
        return "admin/return/list";
    }

    @PostMapping("/admin/returns/{returnId}/approve")
    public String approve(@PathVariable Long returnId, RedirectAttributes ra) {
        returnRequestService.approve(returnId);
        ra.addFlashAttribute("successMsg", "승인 처리되었습니다.");
        return "redirect:/admin/returns";
    }

    @PostMapping("/admin/returns/{returnId}/reject")
    public String reject(@PathVariable Long returnId, RedirectAttributes ra) {
        returnRequestService.reject(returnId);
        ra.addFlashAttribute("successMsg", "거절 처리되었습니다.");
        return "redirect:/admin/returns";
    }

    @PostMapping("/admin/returns/{returnId}/complete")
    public String complete(@PathVariable Long returnId, RedirectAttributes ra) {
        returnRequestService.complete(returnId);
        ra.addFlashAttribute("successMsg", "완료 처리되었습니다.");
        return "redirect:/admin/returns";
    }
}
