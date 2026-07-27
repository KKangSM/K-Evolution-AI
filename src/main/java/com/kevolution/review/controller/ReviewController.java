package com.kevolution.review.controller;

import com.kevolution.order.entity.OrderItem;
import com.kevolution.review.service.ReviewService;

import static com.kevolution.config.ValidationUtils.isBlank;

import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.List;

/**
 * 상품 리뷰 — 회원 본인의 리뷰 작성/수정/삭제 및 내 리뷰 목록.
 * 상품 상세 화면의 리뷰 노출은 ProductController 가 담당한다.
 * 모든 경로가 /mypage/** 아래라 SecurityConfig 의 회원 전용 규칙을 그대로 적용받는다.
 */
@Controller
@RequiredArgsConstructor
@RequestMapping("/mypage/reviews")
public class ReviewController {

    private final ReviewService reviewService;

    @GetMapping
    public String myReviews(@AuthenticationPrincipal UserDetails user, Model model) {
        model.addAttribute("reviews", reviewService.getMyReviews(user.getUsername()));
        return "mypage/reviews";
    }

    @GetMapping("/write")
    public String writeForm(@AuthenticationPrincipal UserDetails user,
                            @RequestParam Long orderItemId,
                            Model model, RedirectAttributes ra) {
        try {
            OrderItem item = reviewService.getWritableOrderItem(user.getUsername(), orderItemId);
            model.addAttribute("item", item);
            return "mypage/review-form";
        } catch (IllegalArgumentException e) {
            ra.addFlashAttribute("errorMsg", e.getMessage());
            return "redirect:/orders";
        }
    }

    @PostMapping("/write")
    public String write(@AuthenticationPrincipal UserDetails user,
                        @RequestParam Long orderItemId,
                        @RequestParam(defaultValue = "0") int rating,
                        @RequestParam(required = false) String content,
                        @RequestParam(required = false) List<MultipartFile> images,
                        RedirectAttributes ra) {
        if (isBlank(content)) {
            ra.addFlashAttribute("errorMsg", "리뷰 내용을 입력해주세요.");
            return "redirect:/mypage/reviews/write?orderItemId=" + orderItemId;
        }
        try {
            reviewService.writeReview(user.getUsername(), orderItemId, rating, content, images);
            ra.addFlashAttribute("successMsg", "리뷰가 등록되었습니다. 감사합니다!");
            return "redirect:/mypage/reviews";
        } catch (IllegalArgumentException e) {
            ra.addFlashAttribute("errorMsg", e.getMessage());
            return "redirect:/orders";
        }
    }

    @PostMapping("/{reviewId}/edit")
    public String edit(@PathVariable Long reviewId,
                       @AuthenticationPrincipal UserDetails user,
                       @RequestParam(defaultValue = "0") int rating,
                       @RequestParam(required = false) String content,
                       RedirectAttributes ra) {
        if (isBlank(content)) {
            ra.addFlashAttribute("errorMsg", "리뷰 내용을 입력해주세요.");
            return "redirect:/mypage/reviews";
        }
        try {
            reviewService.updateReview(reviewId, user.getUsername(), rating, content);
            ra.addFlashAttribute("successMsg", "리뷰가 수정되었습니다.");
        } catch (IllegalArgumentException e) {
            ra.addFlashAttribute("errorMsg", e.getMessage());
        }
        return "redirect:/mypage/reviews";
    }

    @PostMapping("/{reviewId}/delete")
    public String delete(@PathVariable Long reviewId,
                         @AuthenticationPrincipal UserDetails user,
                         RedirectAttributes ra) {
        try {
            reviewService.deleteReview(reviewId, user.getUsername());
            ra.addFlashAttribute("successMsg", "리뷰가 삭제되었습니다.");
        } catch (IllegalArgumentException e) {
            ra.addFlashAttribute("errorMsg", e.getMessage());
        }
        return "redirect:/mypage/reviews";
    }
}
