package com.kevolution.notice.controller;

import com.kevolution.notice.service.NoticeService;
import com.kevolution.storage.SupabaseStorageService;

import static com.kevolution.config.ValidationUtils.isAnyBlank;

import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
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
    private final SupabaseStorageService storageService;

    // ── 공개 조회 ─────────────────────────────────
    @GetMapping("/support/notices")
    public String list(@RequestParam(defaultValue = "0") int page, Model model) {
        model.addAttribute("notices", noticeService.getNotices(PageRequest.of(page, 10)));
        return "support/notice-list";
    }

    /** 모달로 공지를 열 때 비동기로 호출되어 조회수만 올린다. */
    @PostMapping("/support/notices/{noticeId}/view")
    @ResponseBody
    public void increaseView(@PathVariable Long noticeId) {
        noticeService.increaseViewCount(noticeId);
    }

    // ── 관리자 관리 (/admin/** = ROLE_ADMIN) ──────────
    @GetMapping("/admin/notice")
    public String adminList(@RequestParam(defaultValue = "0") int page,
                            @RequestParam(defaultValue = "20") int pageSize,
                            @RequestParam(required = false) String search,
                            Model model) {
        model.addAttribute("activeMenu", "notice");
        model.addAttribute("notices", noticeService.searchNotices(search, PageRequest.of(page, pageSize)));
        model.addAttribute("search", search);
        return "admin/notice/list";
    }

    @PostMapping("/admin/notice/write")
    public String write(@RequestParam String title,
                        @RequestParam String content,
                        @RequestParam(required = false) MultipartFile imageFile,
                        RedirectAttributes ra) {
        if (isAnyBlank(title, content)) {
            ra.addFlashAttribute("errorMsg", "제목과 내용을 모두 입력해주세요.");
            return "redirect:/admin/notice";
        }
        try {
            String imageUrl = (imageFile != null && !imageFile.isEmpty())
                ? storageService.upload(imageFile, "notice") : null;
            noticeService.create(title, content, imageUrl);
            ra.addFlashAttribute("successMsg", "공지사항이 등록되었습니다.");
        } catch (Exception e) {
            ra.addFlashAttribute("errorMsg", "등록 실패: " + e.getMessage());
        }
        return "redirect:/admin/notice";
    }

    @PostMapping("/admin/notice/{noticeId}/edit")
    public String edit(@PathVariable Long noticeId,
                       @RequestParam String title,
                       @RequestParam String content,
                       @RequestParam(required = false) MultipartFile imageFile,
                       RedirectAttributes ra) {
        if (isAnyBlank(title, content)) {
            ra.addFlashAttribute("errorMsg", "제목과 내용을 모두 입력해주세요.");
            return "redirect:/admin/notice";
        }
        try {
            String newImageUrl = (imageFile != null && !imageFile.isEmpty())
                ? storageService.upload(imageFile, "notice") : null;
            String discardedUrl = noticeService.update(noticeId, title, content, newImageUrl);
            if (discardedUrl != null) storageService.deleteByPublicUrl(discardedUrl); // 교체된 옛 이미지 정리
            ra.addFlashAttribute("successMsg", "공지사항이 수정되었습니다.");
        } catch (IllegalArgumentException e) {
            ra.addFlashAttribute("errorMsg", e.getMessage());
        } catch (Exception e) {
            ra.addFlashAttribute("errorMsg", "수정 실패: " + e.getMessage());
        }
        return "redirect:/admin/notice";
    }

    @PostMapping("/admin/notice/{noticeId}/delete")
    public String delete(@PathVariable Long noticeId, RedirectAttributes ra) {
        try {
            String imageUrl = noticeService.delete(noticeId);
            if (imageUrl != null) storageService.deleteByPublicUrl(imageUrl); // Storage 파일도 정리
            ra.addFlashAttribute("successMsg", "공지사항이 삭제되었습니다.");
        } catch (IllegalArgumentException e) {
            ra.addFlashAttribute("errorMsg", e.getMessage());
        }
        return "redirect:/admin/notice";
    }
}
