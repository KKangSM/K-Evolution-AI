package com.kevolution.banner.controller;

import com.kevolution.banner.service.BannerService;
import com.kevolution.event.service.EventService;
import com.kevolution.storage.SupabaseStorageService;

import static com.kevolution.config.ValidationUtils.isBlank;

import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.time.LocalDateTime;

/**
 * 배너(광고/이벤트 노출용) — 관리자 CRUD 를 담당한다.
 * 이미지는 Supabase Storage 에 업로드하고, 그 공개 URL 을 배너에 저장한다.
 * 권한 구분은 SecurityConfig 의 URL 규칙(/admin/** = ROLE_ADMIN)으로만 처리한다.
 */
@Controller
@RequiredArgsConstructor
public class BannerController {

    private final BannerService bannerService;
    private final EventService eventService;
    private final SupabaseStorageService storageService;

    // ── 관리자 목록 ─────────────────────────────────
    @GetMapping("/admin/banners")
    public String adminList(@RequestParam(required = false) String search,
                            @RequestParam(defaultValue = "0") int page,
                            @RequestParam(defaultValue = "20") int pageSize,
                            Model model) {
        model.addAttribute("activeMenu", "banners");
        model.addAttribute("banners", bannerService.searchBanners(search, PageRequest.of(page, pageSize)));
        model.addAttribute("events", eventService.getAllEvents()); // 배너-이벤트 연결 드롭다운용
        model.addAttribute("search", search);
        return "admin/banners/list";
    }

    // ── 등록 (리스트의 등록 모달에서 multipart 전송) ──
    @PostMapping("/admin/banners/register")
    public String register(
        @RequestParam MultipartFile imageFile,
        @RequestParam(required = false) String linkUrl,
        @RequestParam(required = false) String title,
        @RequestParam(defaultValue = "0") int sortOrder,
        @RequestParam(defaultValue = "false") boolean active,
        @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime startAt,
        @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime endAt,
        RedirectAttributes ra
    ) {
        if (isBlank(title)) {
            ra.addFlashAttribute("errorMsg", "제목을 입력해주세요.");
            return "redirect:/admin/banners";
        }
        try {
            String imageUrl = storageService.upload(imageFile, "banner");
            bannerService.create(imageUrl, linkUrl, title, sortOrder, active, startAt, endAt);
            ra.addFlashAttribute("successMsg",
                "배너가 등록되었습니다. (Supabase 업로드 성공 — 키/연결 정상)");
        } catch (Exception e) {
            ra.addFlashAttribute("errorMsg", "등록 실패: " + e.getMessage());
        }
        return "redirect:/admin/banners";
    }

    // ── 수정 ───────────────────────────────────────
    @PostMapping("/admin/banners/{bannerId}/edit")
    public String edit(
        @PathVariable Long bannerId,
        @RequestParam(required = false) MultipartFile imageFile,
        @RequestParam(required = false) String linkUrl,
        @RequestParam(required = false) String title,
        @RequestParam(defaultValue = "0") int sortOrder,
        @RequestParam(defaultValue = "false") boolean active,
        @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime startAt,
        @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime endAt,
        RedirectAttributes ra
    ) {
        if (isBlank(title)) {
            ra.addFlashAttribute("errorMsg", "제목을 입력해주세요.");
            return "redirect:/admin/banners";
        }
        try {
            String newImageUrl = (imageFile != null && !imageFile.isEmpty())
                ? storageService.upload(imageFile, "banner") : null;
            String discardedUrl = bannerService.update(
                bannerId, newImageUrl, linkUrl, title, sortOrder, active, startAt, endAt);
            if (discardedUrl != null) storageService.deleteByPublicUrl(discardedUrl); // 교체된 옛 파일 정리
            ra.addFlashAttribute("successMsg", "배너가 수정되었습니다.");
        } catch (Exception e) {
            ra.addFlashAttribute("errorMsg", "수정 실패: " + e.getMessage());
        }
        return "redirect:/admin/banners";
    }

    // ── 삭제 ───────────────────────────────────────
    @PostMapping("/admin/banners/{bannerId}/delete")
    public String delete(@PathVariable Long bannerId, RedirectAttributes ra) {
        try {
            String imageUrl = bannerService.delete(bannerId);
            storageService.deleteByPublicUrl(imageUrl); // Storage 파일도 정리
            ra.addFlashAttribute("successMsg", "배너가 삭제되었습니다.");
        } catch (Exception e) {
            ra.addFlashAttribute("errorMsg", "삭제 실패: " + e.getMessage());
        }
        return "redirect:/admin/banners";
    }
}
