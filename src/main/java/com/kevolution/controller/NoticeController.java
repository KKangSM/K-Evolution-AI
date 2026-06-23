package com.kevolution.controller;

import com.kevolution.service.NoticeService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

/**
 * 공지사항 — 공개 조회와 관리자 CRUD 를 한 곳에서 담당한다.
 * 권한 구분은 SecurityConfig 의 URL 규칙(/admin/** = ROLE_ADMIN)만으로 처리하고,
 * 클래스 이름에 권한 단계(Admin)를 박지 않는다.
 */
@Controller
@RequiredArgsConstructor
public class NoticeController {

    private final NoticeService noticeService;

    private static Sort defaultSort() {
        return Sort.by("pinned").descending().and(Sort.by("createdAt").descending());
    }

    // ── 공개 조회 ─────────────────────────────────
    @GetMapping("/support/notices")
    public String list(@RequestParam(defaultValue = "0") int page, Model model) {
        model.addAttribute("notices", noticeService.getNotices(PageRequest.of(page, 10, defaultSort())));
        return "support/notice-list";
    }

    @GetMapping("/support/notices/{noticeId}")
    public String detail(@PathVariable Long noticeId, Model model) {
        model.addAttribute("notice", noticeService.getNotice(noticeId));
        return "support/notice-detail";
    }

    // ── 관리자 관리 (/admin/** = ROLE_ADMIN) ──────────
    @GetMapping("/admin/notice")
    public String adminList(@RequestParam(defaultValue = "0") int page, Model model) {
        model.addAttribute("activeMenu", "notice");
        model.addAttribute("notices", noticeService.getNotices(PageRequest.of(page, 20, defaultSort())));
        return "admin/notice/list";
    }

    @PostMapping("/admin/notice/write")
    public String write(@RequestParam String title,
                        @RequestParam String content,
                        @RequestParam(defaultValue = "false") boolean pinned,
                        RedirectAttributes ra) {
        noticeService.create(title, content, pinned);
        ra.addFlashAttribute("successMsg", "공지사항이 등록되었습니다.");
        return "redirect:/admin/notice";
    }

    @PostMapping("/admin/notice/{noticeId}/edit")
    public String edit(@PathVariable Long noticeId,
                       @RequestParam String title,
                       @RequestParam String content,
                       @RequestParam(defaultValue = "false") boolean pinned,
                       RedirectAttributes ra) {
        try {
            noticeService.update(noticeId, title, content, pinned);
            ra.addFlashAttribute("successMsg", "공지사항이 수정되었습니다.");
        } catch (IllegalArgumentException e) {
            ra.addFlashAttribute("errorMsg", e.getMessage());
        }
        return "redirect:/admin/notice";
    }

    @PostMapping("/admin/notice/{noticeId}/delete")
    public String delete(@PathVariable Long noticeId, RedirectAttributes ra) {
        try {
            noticeService.delete(noticeId);
            ra.addFlashAttribute("successMsg", "공지사항이 삭제되었습니다.");
        } catch (IllegalArgumentException e) {
            ra.addFlashAttribute("errorMsg", e.getMessage());
        }
        return "redirect:/admin/notice";
    }
}
