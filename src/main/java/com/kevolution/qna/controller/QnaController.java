package com.kevolution.qna.controller;

import com.kevolution.qna.entity.Qna;
import com.kevolution.qna.service.QnaService;

import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

/**
 * 1:1 문의 — 작성자(회원)용 /support/qna 와 관리자용 /admin/qna 를 한 곳에서 담당한다.
 * 권한 구분은 SecurityConfig 의 URL 규칙만으로 처리하고, 클래스 이름에 권한 단계(Admin)를 박지 않는다.
 */
@Controller
@RequiredArgsConstructor
public class QnaController {

    private final QnaService qnaService;

    // ── 작성자(회원)용 (/support/qna) ──────────────
    @GetMapping("/support/qna")
    public String list(@AuthenticationPrincipal UserDetails user,
                       @RequestParam(defaultValue = "0") int page,
                       Model model) {
        model.addAttribute("qnaList", qnaService.getMyQnaList(
                user.getUsername(), PageRequest.of(page, 10)));
        return "support/qna-list";
    }

    @PostMapping("/support/qna/write")
    public String write(@AuthenticationPrincipal UserDetails user,
                        @RequestParam String title,
                        @RequestParam String content,
                        RedirectAttributes ra) {
        qnaService.writeQna(user.getUsername(), title, content);
        ra.addFlashAttribute("successMsg", "문의가 등록되었습니다.");
        return "redirect:/support/qna";
    }

    // 답변 확인 처리 — 목록 아코디언을 펼칠 때 AJAX로 호출된다.
    @PostMapping("/support/qna/{qnaId}/read")
    @ResponseBody
    public ResponseEntity<Void> markRead(@PathVariable Long qnaId,
                                         @AuthenticationPrincipal UserDetails user) {
        qnaService.markAnswerRead(qnaId, user.getUsername());
        return ResponseEntity.ok().build();
    }

    @PostMapping("/support/qna/{qnaId}/edit")
    public String edit(@PathVariable Long qnaId,
                       @AuthenticationPrincipal UserDetails user,
                       @RequestParam String title,
                       @RequestParam String content,
                       RedirectAttributes ra) {
        try {
            qnaService.updateQna(qnaId, user.getUsername(), title, content);
            ra.addFlashAttribute("successMsg", "문의가 수정되었습니다.");
        } catch (IllegalArgumentException e) {
            ra.addFlashAttribute("errorMsg", e.getMessage());
        }
        return "redirect:/support/qna";
    }

    @PostMapping("/support/qna/{qnaId}/delete")
    public String delete(@PathVariable Long qnaId,
                         @AuthenticationPrincipal UserDetails user,
                         RedirectAttributes ra) {
        try {
            qnaService.deleteQna(qnaId, user.getUsername());
            ra.addFlashAttribute("successMsg", "문의가 삭제되었습니다.");
        } catch (IllegalArgumentException e) {
            ra.addFlashAttribute("errorMsg", e.getMessage());
        }
        return "redirect:/support/qna";
    }

    // ── 관리자용 (/admin/qna = ROLE_ADMIN) ─────────
    @GetMapping("/admin/qna")
    public String adminList(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int pageSize,
            @RequestParam(required = false) String search,
            @RequestParam(required = false) String answered,
            @RequestParam(required = false) String answerRead,
            @RequestParam(defaultValue = "product") String type,
            Model model) {

        // type 은 탭(기본 상품문의)으로 항상 지정됨 → searchQna 단일 경로
        Page<Qna> qnaList = qnaService.searchQna(search, answered, answerRead, type,
                PageRequest.of(page, pageSize, Sort.by("createdAt").descending()));

        model.addAttribute("activeMenu", "qna");
        model.addAttribute("qnaList", qnaList);
        model.addAttribute("search", search);
        model.addAttribute("filterAnswered", answered);
        model.addAttribute("filterAnswerRead", answerRead);
        model.addAttribute("filterType", type);
        return "admin/qna/list";
    }

    @PostMapping("/admin/qna/{qnaId}/answer")
    public String answer(@PathVariable Long qnaId,
                         @RequestParam String answer,
                         RedirectAttributes ra) {
        qnaService.answer(qnaId, answer);
        ra.addFlashAttribute("successMsg", "답변이 등록되었습니다.");
        return "redirect:/admin/qna";
    }
}
