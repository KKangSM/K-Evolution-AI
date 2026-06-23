package com.kevolution.terms.controller;

import com.kevolution.config.SecurityConfig;
import com.kevolution.terms.entity.Terms;
import com.kevolution.terms.service.TermsService;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

/**
 * 약관 관리 — /admin/** 는 SecurityConfig 에서 ROLE_ADMIN 으로 제한된다.
 * 권한 구분은 URL 로만 처리하므로 클래스 이름에 권한 단계(Admin)를 박지 않는다.
 */
@Controller
@RequestMapping("/admin/terms")
@RequiredArgsConstructor
public class TermsController {

    private final TermsService termsService;

    @GetMapping
    public String list(Model model) {
        model.addAttribute("activeMenu", "terms");
        model.addAttribute("termsList", termsService.getAllTerms());
        return "admin/terms/list";
    }

    @GetMapping("/upload")
    public String uploadForm(Model model) {
        model.addAttribute("activeMenu", "terms");
        model.addAttribute("types", Terms.Type.values());
        return "admin/terms/upload";
    }

    @PostMapping("/upload")
    public String upload(
            @RequestParam Terms.Type type,
            @RequestParam String title,
            @RequestParam(defaultValue = "true") boolean required,
            @RequestParam(defaultValue = "true") boolean active,
            @RequestParam("file") MultipartFile file,
            RedirectAttributes ra
    ) {
        try {
            if (file.isEmpty()) {
                ra.addFlashAttribute("errorMsg", "HTML 파일을 선택해주세요.");
                return "redirect:/admin/terms/upload";
            }
            termsService.upload(type, title, required, active, file);
            ra.addFlashAttribute("successMsg", "약관이 등록되었습니다.");
        } catch (Exception e) {
            ra.addFlashAttribute("errorMsg", "업로드 실패: " + e.getMessage());
        }
        return "redirect:/admin/terms";
    }

    @GetMapping("/{termId}/edit")
    public String editForm(@PathVariable Long termId, Model model) {
        model.addAttribute("activeMenu", "terms");
        model.addAttribute("terms", termsService.getTerms(termId));
        model.addAttribute("types", Terms.Type.values());
        return "admin/terms/upload";
    }

    @PostMapping("/{termId}/edit")
    public String edit(
            @PathVariable Long termId,
            @RequestParam String title,
            @RequestParam(defaultValue = "false") boolean required,
            @RequestParam(defaultValue = "false") boolean active,
            @RequestParam(value = "file", required = false) MultipartFile file,
            RedirectAttributes ra
    ) {
        try {
            termsService.update(termId, title, required, active, file);
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
