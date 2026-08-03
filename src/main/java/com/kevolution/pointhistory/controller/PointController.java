package com.kevolution.pointhistory.controller;

import com.kevolution.pointhistory.service.PointService;

import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

/**
 * 적립금 — 회원용(/mypage/points) 잔액·내역 조회를 담당한다.
 * 권한 구분은 SecurityConfig 의 /mypage/** 규칙으로 처리한다.
 */
@Controller
@RequiredArgsConstructor
public class PointController {

    /** 한 페이지에 보여줄 내역 수 */
    private static final int PAGE_SIZE = 10;

    private final PointService pointService;

    @GetMapping("/mypage/points")
    public String myPoints(@AuthenticationPrincipal UserDetails user,
                           @RequestParam(defaultValue = "0") int page,
                           Model model) {
        Pageable pageable = PageRequest.of(Math.max(page, 0), PAGE_SIZE);
        model.addAttribute("balance", pointService.getBalance(user.getUsername()));
        model.addAttribute("histories", pointService.getHistory(user.getUsername(), pageable));
        return "mypage/points";
    }
}
