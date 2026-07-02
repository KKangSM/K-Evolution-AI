package com.kevolution.product.controller;

import com.kevolution.product.entity.Product;
import com.kevolution.product.service.ProductService;

import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

/**
 * 재고 관리 — 옵션별 재고를 목록에서 바로 수정한다.
 * 상품 정보 전체를 열지 않고 재고만 빠르게 만지는 운영용 화면. (재고는 옵션에만 존재)
 */
@Controller
@RequestMapping("/admin/stock")
@RequiredArgsConstructor
public class StockController {

    private static final int PAGE_SIZE = 20;

    private final ProductService productService;

    @GetMapping
    public String list(
        @RequestParam(required = false) String search,
        @RequestParam(defaultValue = "0") int page,
        Model model
    ) {
        Page<Product> products = productService.getProducts(search, null, PageRequest.of(page, PAGE_SIZE));
        model.addAttribute("activeMenu", "stock");
        model.addAttribute("products", products);
        model.addAttribute("optionMap", productService.getOptionsByProduct(products.getContent()));
        model.addAttribute("stockMap", productService.getStockMap(products.getContent()));
        return "admin/stock/list";
    }

    /** 옵션 재고 수정 */
    @PostMapping("/options/{optionId}")
    public String updateOptionStock(
        @PathVariable Long optionId,
        @RequestParam int stock,
        @RequestParam(required = false) String search,
        @RequestParam(defaultValue = "0") int page,
        RedirectAttributes ra
    ) {
        try {
            productService.updateOptionStock(optionId, stock);
            ra.addFlashAttribute("successMsg", "옵션 재고가 수정되었습니다.");
        } catch (IllegalArgumentException e) {
            ra.addFlashAttribute("errorMsg", e.getMessage());
        }
        return redirectBack(search, page, ra);
    }

    /** 보고 있던 검색어·페이지를 유지한 채 목록으로 복귀 (addAttribute 가 인코딩 처리) */
    private String redirectBack(String search, int page, RedirectAttributes ra) {
        if (search != null && !search.isBlank()) ra.addAttribute("search", search);
        if (page > 0) ra.addAttribute("page", page);
        return "redirect:/admin/stock";
    }
}
