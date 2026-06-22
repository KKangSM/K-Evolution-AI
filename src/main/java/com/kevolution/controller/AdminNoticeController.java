package com.kevolution.controller;

import com.kevolution.service.AdminNoticeService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

@Controller
@RequestMapping("/admin/notice")
@RequiredArgsConstructor
public class AdminNoticeController {

    private final AdminNoticeService adminNoticeService;

    @GetMapping
    public String list(@RequestParam(defaultValue = "0") int page, Model model) {
        model.addAttribute("activeMenu", "notice");
        model.addAttribute("notices", adminNoticeService.getNotices(
                PageRequest.of(page, 20, Sort.by("pinned").descending().and(Sort.by("createdAt").descending()))));
        return "admin/notice/list";
    }

    @PostMapping("/write")
    public String write(@RequestParam String title,
                        @RequestParam String content,
                        @RequestParam(defaultValue = "false") boolean pinned,
                        RedirectAttributes ra) {
        adminNoticeService.create(title, content, pinned);
        ra.addFlashAttribute("successMsg", "공지사항이 등록되었습니다.");
        return "redirect:/admin/notice";
    }

    @PostMapping("/{noticeId}/edit")
    public String edit(@PathVariable Long noticeId,
                       @RequestParam String title,
                       @RequestParam String content,
                       @RequestParam(defaultValue = "false") boolean pinned,
                       RedirectAttributes ra) {
        try {
            adminNoticeService.update(noticeId, title, content, pinned);
            ra.addFlashAttribute("successMsg", "공지사항이 수정되었습니다.");
        } catch (IllegalArgumentException e) {
            ra.addFlashAttribute("errorMsg", e.getMessage());
        }
        return "redirect:/admin/notice";
    }

    @PostMapping("/{noticeId}/delete")
    public String delete(@PathVariable Long noticeId, RedirectAttributes ra) {
        try {
            adminNoticeService.delete(noticeId);
            ra.addFlashAttribute("successMsg", "공지사항이 삭제되었습니다.");
        } catch (IllegalArgumentException e) {
            ra.addFlashAttribute("errorMsg", e.getMessage());
        }
        return "redirect:/admin/notice";
    }
}
