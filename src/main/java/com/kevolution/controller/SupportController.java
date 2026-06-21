package com.kevolution.controller;

import com.kevolution.service.SupportService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

@Controller
@RequestMapping("/support")
@RequiredArgsConstructor
public class SupportController {

    private final SupportService supportService;

    @GetMapping
    public String index(Model model) {
        model.addAttribute("notices", supportService.getNotices(PageRequest.of(0, 5)));
        return "support/index";
    }

    // 공지사항
    @GetMapping("/notices")
    public String noticeList(@RequestParam(defaultValue = "0") int page, Model model) {
        model.addAttribute("notices", supportService.getNotices(
                PageRequest.of(page, 10, Sort.by("pinned").descending().and(Sort.by("createdAt").descending()))));
        return "support/notice-list";
    }

    @GetMapping("/notices/{noticeId}")
    public String noticeDetail(@PathVariable Long noticeId, Model model) {
        model.addAttribute("notice", supportService.getNotice(noticeId));
        return "support/notice-detail";
    }

    // 1:1 문의
    @GetMapping("/qna")
    public String qnaList(@AuthenticationPrincipal UserDetails user,
                          @RequestParam(defaultValue = "0") int page,
                          Model model) {
        model.addAttribute("qnaList", supportService.getMyQnaList(
                user.getUsername(), PageRequest.of(page, 10)));
        return "support/qna-list";
    }

    @PostMapping("/qna/write")
    public String qnaWrite(@AuthenticationPrincipal UserDetails user,
                           @RequestParam String title,
                           @RequestParam String content,
                           @RequestParam(defaultValue = "false") boolean secret,
                           RedirectAttributes ra) {
        supportService.writeQna(user.getUsername(), title, content, secret);
        ra.addFlashAttribute("successMsg", "문의가 등록되었습니다.");
        return "redirect:/support/qna";
    }

    // 답변 확인 처리 — 목록 아코디언을 펼칠 때 AJAX로 호출된다.
    @PostMapping("/qna/{qnaId}/read")
    @ResponseBody
    public ResponseEntity<Void> qnaMarkRead(@PathVariable Long qnaId,
                                            @AuthenticationPrincipal UserDetails user) {
        supportService.markAnswerRead(qnaId, user.getUsername());
        return ResponseEntity.ok().build();
    }

    @PostMapping("/qna/{qnaId}/edit")
    public String qnaEdit(@PathVariable Long qnaId,
                          @AuthenticationPrincipal UserDetails user,
                          @RequestParam String title,
                          @RequestParam String content,
                          RedirectAttributes ra) {
        try {
            supportService.updateQna(qnaId, user.getUsername(), title, content);
            ra.addFlashAttribute("successMsg", "문의가 수정되었습니다.");
        } catch (IllegalArgumentException e) {
            ra.addFlashAttribute("errorMsg", e.getMessage());
        }
        return "redirect:/support/qna";
    }

    @PostMapping("/qna/{qnaId}/delete")
    public String qnaDelete(@PathVariable Long qnaId,
                            @AuthenticationPrincipal UserDetails user,
                            RedirectAttributes ra) {
        try {
            supportService.deleteQna(qnaId, user.getUsername());
            ra.addFlashAttribute("successMsg", "문의가 삭제되었습니다.");
        } catch (IllegalArgumentException e) {
            ra.addFlashAttribute("errorMsg", e.getMessage());
        }
        return "redirect:/support/qna";
    }
}
