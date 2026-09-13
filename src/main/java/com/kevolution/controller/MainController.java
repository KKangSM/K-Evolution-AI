package com.kevolution.controller;

import com.kevolution.banner.service.BannerService;
import com.kevolution.notice.repository.NoticeRepository;
import com.kevolution.product.entity.Product;
import com.kevolution.product.service.ProductService;
import com.kevolution.recommendation.service.RecommendationService;

import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

import java.util.ArrayList;
import java.util.List;

@Controller
@RequiredArgsConstructor
public class MainController {

    // 메인 상품 레일(가로 스크롤)을 채우기 위한 섹션당 노출 개수
    private static final int SECTION_SIZE = 8;

    private final ProductService productService;
    private final NoticeRepository noticeRepository;
    private final BannerService bannerService;
    private final RecommendationService recommendationService;

    @GetMapping("/")
    public String main(@AuthenticationPrincipal UserDetails user, Model model) {
        List<Product> newProducts = productService.getNewProducts(SECTION_SIZE);
        List<Product> popularProducts = productService.getPopularProducts(SECTION_SIZE);

        // 로그인 회원에게만 개인화 추천 레일을 노출한다. (비로그인은 MD's PICK 과 중복되므로 생략)
        List<Product> recommendedProducts = (user == null)
                ? List.of()
                : recommendationService.getPersonalized(user.getUsername(), SECTION_SIZE);

        // 세 섹션 상품을 합쳐 품절 판단용 재고 맵을 한 번에 만든다.
        List<Product> shown = new ArrayList<>(newProducts);
        shown.addAll(popularProducts);
        shown.addAll(recommendedProducts);

        model.addAttribute("newProducts", newProducts);
        model.addAttribute("popularProducts", popularProducts);
        model.addAttribute("recommendedProducts", recommendedProducts);
        model.addAttribute("stockMap", productService.getStockMap(shown));
        model.addAttribute("marqueeNotices", noticeRepository.findTop5ByOrderByCreatedAtDesc());
        model.addAttribute("banners", bannerService.getVisibleBanners());
        return "main";
    }
}
