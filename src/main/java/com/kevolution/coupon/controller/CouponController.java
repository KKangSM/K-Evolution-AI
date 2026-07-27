package com.kevolution.coupon.controller;

import com.kevolution.coupon.entity.Coupon;
import com.kevolution.coupon.service.CouponService;

import static com.kevolution.config.ValidationUtils.isBlank;

import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 쿠폰 관리 (관리자 · /admin/** = ROLE_ADMIN).
 * 쿠폰 생성/삭제와 회원 발급(개별·전체)을 담당한다.
 */
@Controller
@RequiredArgsConstructor
@RequestMapping("/admin/coupons")
public class CouponController {

    private final CouponService couponService;

    @GetMapping
    public String list(Model model) {
        List<Coupon> coupons = couponService.getAllCoupons();
        model.addAttribute("activeMenu", "coupons");
        model.addAttribute("coupons", coupons);
        model.addAttribute("issuedCounts", couponService.getIssuedCounts(coupons));
        return "admin/coupon/list";
    }

    @PostMapping("/create")
    public String create(@RequestParam String name,
                         @RequestParam String discountType,
                         @RequestParam(defaultValue = "0") int discountValue,
                         @RequestParam(required = false) Integer minOrderAmount,
                         @RequestParam(required = false)
                         @DateTimeFormat(pattern = "yyyy-MM-dd'T'HH:mm") LocalDateTime expiredAt,
                         RedirectAttributes ra) {
        if (isBlank(name)) {
            ra.addFlashAttribute("errorMsg", "쿠폰 이름을 입력해주세요.");
            return "redirect:/admin/coupons";
        }
        try {
            couponService.createCoupon(name, discountType, discountValue, minOrderAmount, expiredAt);
            ra.addFlashAttribute("successMsg", "쿠폰이 생성되었습니다.");
        } catch (IllegalArgumentException e) {
            ra.addFlashAttribute("errorMsg", e.getMessage());
        }
        return "redirect:/admin/coupons";
    }

    @PostMapping("/{couponId}/issue")
    public String issue(@PathVariable Long couponId,
                        @RequestParam String target,
                        @RequestParam(required = false) String userId,
                        RedirectAttributes ra) {
        try {
            if ("all".equals(target)) {
                int n = couponService.issueToAllActiveMembers(couponId);
                ra.addFlashAttribute("successMsg", n + "명의 회원에게 쿠폰을 발급했습니다.");
            } else {
                if (isBlank(userId)) {
                    ra.addFlashAttribute("errorMsg", "발급할 회원 아이디를 입력해주세요.");
                    return "redirect:/admin/coupons";
                }
                couponService.issueToMember(couponId, userId.trim());
                ra.addFlashAttribute("successMsg", "'" + userId.trim() + "' 회원에게 쿠폰을 발급했습니다.");
            }
        } catch (IllegalArgumentException e) {
            ra.addFlashAttribute("errorMsg", e.getMessage());
        }
        return "redirect:/admin/coupons";
    }

    @PostMapping("/{couponId}/delete")
    public String delete(@PathVariable Long couponId, RedirectAttributes ra) {
        try {
            couponService.deleteCoupon(couponId);
            ra.addFlashAttribute("successMsg", "쿠폰이 삭제되었습니다.");
        } catch (IllegalArgumentException e) {
            ra.addFlashAttribute("errorMsg", e.getMessage());
        }
        return "redirect:/admin/coupons";
    }
}
