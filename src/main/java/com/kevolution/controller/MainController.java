package com.kevolution.controller;

import com.kevolution.banner.service.BannerService;
import com.kevolution.notice.repository.NoticeRepository;
import com.kevolution.product.entity.Product;
import com.kevolution.product.service.ProductService;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

import java.util.ArrayList;
import java.util.List;

@Controller
@RequiredArgsConstructor
public class MainController {

    private static final int SECTION_SIZE = 3;

    private final ProductService productService;
    private final NoticeRepository noticeRepository;
    private final BannerService bannerService;

    @GetMapping("/")
    public String main(Model model) {
        List<Product> newProducts = productService.getNewProducts(SECTION_SIZE);
        List<Product> popularProducts = productService.getPopularProducts(SECTION_SIZE);

        // 두 섹션 상품을 합쳐 품절 판단용 재고 맵을 한 번에 만든다.
        List<Product> shown = new ArrayList<>(newProducts);
        shown.addAll(popularProducts);

        model.addAttribute("newProducts", newProducts);
        model.addAttribute("popularProducts", popularProducts);
        model.addAttribute("stockMap", productService.getStockMap(shown));
        model.addAttribute("marqueeNotices", noticeRepository.findTop5ByOrderByCreatedAtDesc());
        model.addAttribute("banners", bannerService.getVisibleBanners());
        return "main";
    }
}
