package com.kevolution.mypage.controller;

import com.kevolution.mypage.service.MypageService;

import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

@Controller
@RequestMapping("/mypage")
@RequiredArgsConstructor
public class MypageController {

    private final MypageService mypageService;

    @GetMapping
    public String index(@AuthenticationPrincipal UserDetails user, Model model) {
        model.addAttribute("member", mypageService.getMember(user.getUsername()));
        return "mypage/index";
    }

    @GetMapping("/edit")
    public String editForm(@AuthenticationPrincipal UserDetails user, Model model) {
        model.addAttribute("member", mypageService.getMember(user.getUsername()));
        return "mypage/edit";
    }

    @PostMapping("/edit")
    public String edit(@AuthenticationPrincipal UserDetails user,
                       @RequestParam String name,
                       @RequestParam(required = false) String phone,
                       RedirectAttributes ra) {
        mypageService.updateInfo(user.getUsername(), name, phone);
        ra.addFlashAttribute("successMsg", "정보가 수정되었습니다.");
        return "redirect:/mypage/edit";
    }

    @PostMapping("/changePassword")
    public String changePassword(@AuthenticationPrincipal UserDetails user,
                                 @RequestParam String currentPassword,
                                 @RequestParam String newPassword,
                                 RedirectAttributes ra) {
        try {
            mypageService.changePassword(user.getUsername(), currentPassword, newPassword);
            ra.addFlashAttribute("pwSuccessMsg", "비밀번호가 변경되었습니다.");
        } catch (IllegalArgumentException e) {
            ra.addFlashAttribute("pwErrorMsg", e.getMessage());
        }
        return "redirect:/mypage/edit";
    }

    // 배송지
    @GetMapping("/addresses")
    public String addresses(@AuthenticationPrincipal UserDetails user, Model model) {
        model.addAttribute("addresses", mypageService.getAddresses(user.getUsername()));
        return "mypage/addresses";
    }

    @PostMapping("/addresses/add")
    public String addAddress(@AuthenticationPrincipal UserDetails user,
                             @RequestParam String recipient,
                             @RequestParam(required = false) String phone,
                             @RequestParam(required = false) String zipcode,
                             @RequestParam(required = false) String address,
                             @RequestParam(required = false) String addressDetail,
                             @RequestParam(defaultValue = "false") boolean defaultAddress,
                             RedirectAttributes ra) {
        mypageService.addAddress(user.getUsername(), recipient, phone, zipcode, address, addressDetail, defaultAddress);
        ra.addFlashAttribute("successMsg", "배송지가 추가되었습니다.");
        return "redirect:/mypage/addresses";
    }

    @PostMapping("/addresses/{addressId}/delete")
    public String deleteAddress(@AuthenticationPrincipal UserDetails user,
                                @PathVariable Long addressId,
                                RedirectAttributes ra) {
        try {
            mypageService.deleteAddress(user.getUsername(), addressId);
            ra.addFlashAttribute("successMsg", "배송지가 삭제되었습니다.");
        } catch (IllegalArgumentException e) {
            ra.addFlashAttribute("errorMsg", e.getMessage());
        }
        return "redirect:/mypage/addresses";
    }

    @PostMapping("/addresses/{addressId}/default")
    public String setDefault(@AuthenticationPrincipal UserDetails user,
                             @PathVariable Long addressId,
                             RedirectAttributes ra) {
        mypageService.setDefaultAddress(user.getUsername(), addressId);
        ra.addFlashAttribute("successMsg", "기본 배송지가 변경되었습니다.");
        return "redirect:/mypage/addresses";
    }

    // 회원탈퇴
    @GetMapping("/withdraw")
    public String withdrawForm() {
        return "mypage/withdraw";
    }

    @PostMapping("/withdraw")
    public String withdraw(@AuthenticationPrincipal UserDetails user,
                           @RequestParam String password,
                           RedirectAttributes ra) {
        try {
            mypageService.withdraw(user.getUsername(), password);
            return "redirect:/auth/logoutAfterWithdraw";
        } catch (IllegalArgumentException e) {
            ra.addFlashAttribute("errorMsg", e.getMessage());
            return "redirect:/mypage/withdraw";
        }
    }
}
