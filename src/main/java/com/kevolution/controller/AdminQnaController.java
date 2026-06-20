package com.kevolution.controller;

import com.kevolution.service.AdminQnaService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

@Controller
@RequestMapping("/admin/qna")
@RequiredArgsConstructor
public class AdminQnaController {

    private final AdminQnaService adminQnaService;

    @GetMapping
    public String list(
            @RequestParam(defaultValue = "0") int page,
            Model model
    ) {
        model.addAttribute("activeMenu", "qna");
        model.addAttribute("qnaList", adminQnaService.getQnaList(
                PageRequest.of(page, 20, Sort.by("createdAt").descending())));
        return "admin/qna/list";
    }

    @GetMapping("/{qnaId}")
    public String detail(@PathVariable Long qnaId, Model model) {
        model.addAttribute("activeMenu", "qna");
        model.addAttribute("qna", adminQnaService.getQna(qnaId));
        return "admin/qna/detail";
    }

    @PostMapping("/{qnaId}/answer")
    public String answer(
            @PathVariable Long qnaId,
            @RequestParam String answer,
            RedirectAttributes ra
    ) {
        adminQnaService.answer(qnaId, answer);
        ra.addFlashAttribute("successMsg", "답변이 등록되었습니다.");
        return "redirect:/admin/qna/" + qnaId;
    }

    @PostMapping("/{qnaId}/delete")
    public String delete(@PathVariable Long qnaId, RedirectAttributes ra) {
        adminQnaService.delete(qnaId);
        ra.addFlashAttribute("successMsg", "문의가 삭제되었습니다.");
        return "redirect:/admin/qna";
    }
}
