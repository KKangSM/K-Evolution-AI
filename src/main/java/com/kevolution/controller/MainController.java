package com.kevolution.controller;

import com.kevolution.banner.service.BannerService;
import com.kevolution.notice.repository.NoticeRepository;
import com.kevolution.product.repository.CategoryRepository;
import com.kevolution.product.service.ProductService;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
@RequiredArgsConstructor
public class MainController {

    private static final int SECTION_SIZE = 3;

    private final ProductService productService;
    private final CategoryRepository categoryRepository;
    private final NoticeRepository noticeRepository;
    private final BannerService bannerService;

    @GetMapping("/")
    public String main(Model model) {
        model.addAttribute("categories", categoryRepository.findAll());
        model.addAttribute("newProducts", productService.getNewProducts(SECTION_SIZE));
        model.addAttribute("popularProducts", productService.getPopularProducts(SECTION_SIZE));
        model.addAttribute("marqueeNotices", noticeRepository.findTop5ByOrderByCreatedAtDesc());
        model.addAttribute("banners", bannerService.getVisibleBanners());
        return "main";
    }
}
