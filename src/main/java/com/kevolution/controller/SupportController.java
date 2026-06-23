package com.kevolution.controller;

import com.kevolution.service.NoticeService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

/** 고객센터 메인. 공지 조회는 NoticeController, 1:1 문의는 QnaController 가 담당한다. */
@Controller
@RequestMapping("/support")
@RequiredArgsConstructor
public class SupportController {

    private final NoticeService noticeService;

    @GetMapping
    public String index(Model model) {
        model.addAttribute("notices", noticeService.getNotices(PageRequest.of(0, 5)));
        return "support/index";
    }
}
