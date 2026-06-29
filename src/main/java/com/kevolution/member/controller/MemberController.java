package com.kevolution.member.controller;

import com.kevolution.config.SecurityConfig;
import com.kevolution.member.entity.Member;
import com.kevolution.member.service.MemberService;

import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

/**
 * 회원 관리 — /admin/** 는 SecurityConfig 에서 ROLE_ADMIN 으로 제한된다.
 * 권한 구분은 URL 로만 처리하므로 클래스 이름에 권한 단계(Admin)를 박지 않는다.
 */
@Controller
@RequestMapping("/admin/members")
@RequiredArgsConstructor
public class MemberController {

    private final MemberService memberService;

    @GetMapping
    public String list(
            @RequestParam(defaultValue = "0") int page,
            @AuthenticationPrincipal UserDetails userDetails,
            Model model
    ) {
        PageRequest pageable = PageRequest.of(page, 20, Sort.by("createdAt").descending());

        // 요청자의 Member 정보 조회
        Member requester = memberService.findByUserId(userDetails.getUsername());

        Page<Member> members = memberService.getMembers(pageable, requester.getRole());
        model.addAttribute("activeMenu", "members");
        model.addAttribute("members", members);
        model.addAttribute("requesterRole", requester.getRole());
        return "admin/members";
    }

    @PostMapping("/{memberId}/delete")
    public String deleteMember(
            @PathVariable String memberId,
            @AuthenticationPrincipal UserDetails userDetails,
            RedirectAttributes ra
    ) {
        try {
            memberService.deleteMember(memberId, userDetails.getUsername());
            ra.addFlashAttribute("successMsg", "회원이 삭제(탈퇴 처리)되었습니다.");
        } catch (IllegalArgumentException e) {
            ra.addFlashAttribute("errorMsg", e.getMessage());
        }
        return "redirect:/admin/members";
    }

    @PostMapping("/{memberId}/role")
    public String changeRole(
            @PathVariable String memberId,
            @RequestParam String role,
            @AuthenticationPrincipal UserDetails userDetails,
            RedirectAttributes ra
    ) {
        try {
            String requesterId = userDetails.getUsername();
            memberService.changeRole(memberId, requesterId, Member.Role.valueOf(role));
            ra.addFlashAttribute("successMsg", "권한이 변경되었습니다.");
        } catch (IllegalArgumentException | UsernameNotFoundException e) {
            ra.addFlashAttribute("errorMsg", e.getMessage());
        }
        return "redirect:/admin/members";
    }
}
