package com.kevolution.controller;

import com.kevolution.entity.Member;
import com.kevolution.service.AdminMemberService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

@Controller
@RequestMapping("/admin/members")
@RequiredArgsConstructor
public class AdminMemberController {

    private final AdminMemberService adminMemberService;

    @GetMapping
    public String list(
            @RequestParam(defaultValue = "0") int page,
            Model model
    ) {
        PageRequest pageable = PageRequest.of(page, 20, Sort.by("createdAt").descending());
        Page<Member> members = adminMemberService.getMembers(pageable);
        model.addAttribute("activeMenu", "members");
        model.addAttribute("members", members);
        return "admin/members";
    }

    @PostMapping("/{memberId}/delete")
    public String deleteMember(
            @PathVariable String memberId,
            @AuthenticationPrincipal UserDetails userDetails,
            RedirectAttributes ra
    ) {
        try {
            adminMemberService.deleteMember(memberId, userDetails.getUsername());
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
            // 현재 로그인한 관리자의 memberId 조회
            String requesterId = userDetails.getUsername(); // userId
            adminMemberService.changeRole(memberId, requesterId, Member.Role.valueOf(role));
            ra.addFlashAttribute("successMsg", "권한이 변경되었습니다.");
        } catch (IllegalArgumentException e) {
            ra.addFlashAttribute("errorMsg", e.getMessage());
        }
        return "redirect:/admin/members";
    }
}
