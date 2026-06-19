package com.kevolution.controller;

import com.kevolution.service.MemberService;
import com.kevolution.service.TermsService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;
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
        RedirectAttributes ra
    ) {
        try {
            memberService.signup(userId, password, name);
            ra.addFlashAttribute("signupSuccess", true);
            return "redirect:/auth/login";
        } catch (IllegalArgumentException e) {
            ra.addFlashAttribute("errorMsg", e.getMessage());
            return "redirect:/auth/signup";
        }
    }

    // 아이디 중복 확인 (AJAX)
    @GetMapping("/auth/check-id")
    @ResponseBody
    public ResponseEntity<Map<String, Boolean>> checkId(@RequestParam String userId) {
        boolean duplicated = memberService.isUserIdDuplicated(userId);
        return ResponseEntity.ok(Map.of("duplicated", duplicated));
    }
}
