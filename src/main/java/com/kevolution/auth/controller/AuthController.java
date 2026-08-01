package com.kevolution.auth.controller;

import com.kevolution.member.service.MemberService;
import com.kevolution.terms.service.TermsService;

import com.kevolution.member.entity.Member;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;
import java.util.List;
import java.util.Map;

@Controller
@RequiredArgsConstructor
public class AuthController {

    private final MemberService memberService;
    private final TermsService termsService;

    @GetMapping("/auth/login")
    public String loginForm() {
        return "auth/login";
    }

    @GetMapping("/auth/signup")
    public String signupForm(Model model) {
        model.addAttribute("termsList", termsService.getActiveTerms());
        return "auth/signup";
    }

    @PostMapping("/auth/signup")
    public String signup(
        @RequestParam String userId,
        @RequestParam String password,
        @RequestParam String name,
        @RequestParam String phone,
        @RequestParam(required = false) String zipcode,
        @RequestParam String address,
        @RequestParam(required = false) String addressDetail,
        @RequestParam(name = "termIds", required = false) List<Long> termIds,
        RedirectAttributes ra
    ) {
        try {
            memberService.signup(userId, password, name, phone, zipcode, address, addressDetail, termIds);
            ra.addFlashAttribute("signupSuccess", true);
            return "redirect:/auth/login";
        } catch (IllegalArgumentException e) {
            ra.addFlashAttribute("errorMsg", e.getMessage());
            return "redirect:/auth/signup";
        }
    }

    // ── 소셜 로그인 추가정보 입력 (첫 구글 로그인 시 휴대폰·약관동의 수집) ──
    @GetMapping("/auth/complete-profile")
    public String completeProfileForm(@AuthenticationPrincipal UserDetails user, Model model) {
        if (user == null) return "redirect:/auth/login";
        Member member = memberService.findByUserId(user.getUsername());
        // 이미 추가정보를 입력했거나(휴대폰 있음) 일반 폼 회원이면 완성 페이지가 불필요 → 홈으로
        if (member.getProvider() == null || member.getPhone() != null) {
            return "redirect:/";
        }
        model.addAttribute("memberName", member.getName());
        model.addAttribute("termsList", termsService.getActiveTerms());
        return "auth/complete-profile";
    }

    @PostMapping("/auth/complete-profile")
    public String completeProfile(
        @AuthenticationPrincipal UserDetails user,
        @RequestParam String phone,
        @RequestParam(name = "termIds", required = false) List<Long> termIds,
        RedirectAttributes ra
    ) {
        if (user == null) return "redirect:/auth/login";
        try {
            memberService.completeOAuthProfile(user.getUsername(), phone, termIds);
            return "redirect:/";
        } catch (IllegalArgumentException e) {
            ra.addFlashAttribute("errorMsg", e.getMessage());
            return "redirect:/auth/complete-profile";
        }
    }

    @GetMapping("/auth/logoutAfterWithdraw")
    public String logoutAfterWithdraw(jakarta.servlet.http.HttpSession session) {
        session.invalidate();
        return "redirect:/auth/login?withdraw=true";
    }

    // 아이디 중복 확인 (AJAX)
    @GetMapping("/auth/checkId")
    @ResponseBody
    public ResponseEntity<Map<String, Boolean>> checkId(@RequestParam String userId) {
        boolean duplicated = memberService.isUserIdDuplicated(userId);
        return ResponseEntity.ok(Map.of("duplicated", duplicated));
    }
}
