package com.kevolution.event.controller;

import com.kevolution.event.entity.Event;
import com.kevolution.event.service.EventService;
import com.kevolution.storage.SupabaseStorageService;

import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.time.LocalDateTime;

/**
 * 이벤트/기획전 — 공개 조회(/events)와 관리자 CRUD(/admin/events)를 한 곳에서 담당한다.
 * 권한 구분은 SecurityConfig 의 URL 규칙(/admin/** = ROLE_ADMIN)만으로 처리한다.
 */
@Controller
@RequiredArgsConstructor
public class EventController {

    private final EventService eventService;
    private final SupabaseStorageService storageService;

    // ── 공개 조회 ─────────────────────────────────
    @GetMapping("/events")
    public String list(Model model) {
        model.addAttribute("events", eventService.getVisibleEvents());
        return "event/list";
    }

    @GetMapping("/events/{eventId}")
    public String detail(@PathVariable Long eventId, Model model) {
        eventService.increaseViewCount(eventId);
        model.addAttribute("event", eventService.getEvent(eventId));
        return "event/detail";
    }

    // ── 관리자 관리 (/admin/** = ROLE_ADMIN) ──────────
    @GetMapping("/admin/events")
    public String adminList(@RequestParam(defaultValue = "0") int page,
                            @RequestParam(required = false) String search,
                            Model model) {
        Page<Event> events = eventService.searchEvents(search, PageRequest.of(page, 20));
        model.addAttribute("activeMenu", "events");
        model.addAttribute("events", events);
        model.addAttribute("search", search);
        return "admin/event/list";
    }

    @PostMapping("/admin/events/write")
    public String write(@RequestParam String title,
                        @RequestParam String content,
                        @RequestParam(defaultValue = "false") boolean active,
                        @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime startAt,
                        @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime endAt,
                        @RequestParam(required = false) MultipartFile imageFile,
                        RedirectAttributes ra) {
        try {
            String imageUrl = (imageFile != null && !imageFile.isEmpty())
                ? storageService.upload(imageFile, "event") : null;
            eventService.create(title, content, imageUrl, active, startAt, endAt);
            ra.addFlashAttribute("successMsg", "이벤트가 등록되었습니다.");
        } catch (Exception e) {
            ra.addFlashAttribute("errorMsg", "등록 실패: " + e.getMessage());
        }
        return "redirect:/admin/events";
    }

    @PostMapping("/admin/events/{eventId}/edit")
    public String edit(@PathVariable Long eventId,
                       @RequestParam String title,
                       @RequestParam String content,
                       @RequestParam(defaultValue = "false") boolean active,
                       @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime startAt,
                       @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime endAt,
                       @RequestParam(required = false) MultipartFile imageFile,
                       RedirectAttributes ra) {
        try {
            String newImageUrl = (imageFile != null && !imageFile.isEmpty())
                ? storageService.upload(imageFile, "event") : null;
            String discardedUrl = eventService.update(eventId, title, content, newImageUrl, active, startAt, endAt);
            if (discardedUrl != null) storageService.deleteByPublicUrl(discardedUrl); // 교체된 옛 이미지 정리
            ra.addFlashAttribute("successMsg", "이벤트가 수정되었습니다.");
        } catch (IllegalArgumentException e) {
            ra.addFlashAttribute("errorMsg", e.getMessage());
        } catch (Exception e) {
            ra.addFlashAttribute("errorMsg", "수정 실패: " + e.getMessage());
        }
        return "redirect:/admin/events";
    }

    @PostMapping("/admin/events/{eventId}/delete")
    public String delete(@PathVariable Long eventId, RedirectAttributes ra) {
        try {
            String imageUrl = eventService.delete(eventId);
            if (imageUrl != null) storageService.deleteByPublicUrl(imageUrl); // Storage 파일도 정리
            ra.addFlashAttribute("successMsg", "이벤트가 삭제되었습니다.");
        } catch (IllegalArgumentException e) {
            ra.addFlashAttribute("errorMsg", e.getMessage());
        }
        return "redirect:/admin/events";
    }
}
