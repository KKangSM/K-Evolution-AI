package com.kevolution.terms.controller;

import com.kevolution.terms.entity.Terms;
import com.kevolution.terms.service.TermsService;
import com.kevolution.storage.SupabaseStorageService;

import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 약관 관리 — /admin/** 는 SecurityConfig 에서 ROLE_ADMIN 으로 제한된다.
 * 권한 구분은 URL 로만 처리하므로 클래스 이름에 권한 단계(Admin)를 박지 않는다.
 */
@Controller
@RequestMapping("/admin/terms")
@RequiredArgsConstructor
public class TermsController {

    private final TermsService termsService;
    private final SupabaseStorageService storageService;

    @GetMapping
    public String list(Model model, Authentication authentication) {
        boolean isSystem = authentication != null &&
            authentication.getAuthorities().stream()
                .anyMatch(auth -> auth.getAuthority().equals("ROLE_SYSTEM"));

        List<Terms> termsList = termsService.getAllTerms();
        Map<Long, String> plainTextMap = new HashMap<>();
        for (Terms term : termsList) {
            if ("TEXT".equals(term.getContentType())) {
                plainTextMap.put(term.getTermId(), termsService.htmlToPlainText(term.getContent()));
            }
        }

        model.addAttribute("activeMenu", "terms");
        model.addAttribute("termsList", termsList);
        model.addAttribute("plainTextMap", plainTextMap);
        model.addAttribute("types", Terms.Type.values());
        model.addAttribute("isSystem", isSystem);
        return "admin/terms/list";
    }

    @PostMapping("/upload")
    public String upload(
            @RequestParam Terms.Type type,
            @RequestParam String title,
            @RequestParam(defaultValue = "true") boolean required,
            @RequestParam(defaultValue = "true") boolean active,
            @RequestParam(value = "file", required = false) MultipartFile file,
            @RequestParam(value = "content", required = false) String content,
            RedirectAttributes ra
    ) {
        try {
            termsService.upload(type, title, required, active, file, content);
            ra.addFlashAttribute("successMsg", "약관이 등록되었습니다.");
        } catch (Exception e) {
            ra.addFlashAttribute("errorMsg", "등록 실패: " + e.getMessage());
        }
        return "redirect:/admin/terms";
    }

    @PostMapping("/{termId}/edit")
    public String edit(
            @PathVariable Long termId,
            @RequestParam String title,
            @RequestParam(defaultValue = "false") boolean required,
            @RequestParam(defaultValue = "false") boolean active,
            @RequestParam(value = "file", required = false) MultipartFile file,
            @RequestParam(value = "content", required = false) String content,
            RedirectAttributes ra
    ) {
        try {
            Terms oldTerms = termsService.getTerms(termId);
            String oldUrl = "FILE".equals(oldTerms.getContentType()) ? oldTerms.getContent() : null;

            termsService.update(termId, title, required, active, file, content);

            if (oldUrl != null && (file != null && !file.isEmpty())) {
                storageService.deleteByPublicUrl(oldUrl);
            }
            ra.addFlashAttribute("successMsg", "약관이 수정되었습니다.");
        } catch (Exception e) {
            ra.addFlashAttribute("errorMsg", "수정 실패: " + e.getMessage());
        }
        return "redirect:/admin/terms";
    }

    @PostMapping("/{termId}/delete")
    public String delete(@PathVariable Long termId, RedirectAttributes ra) {
        termsService.delete(termId);
        ra.addFlashAttribute("successMsg", "약관이 삭제되었습니다.");
        return "redirect:/admin/terms";
    }
}
