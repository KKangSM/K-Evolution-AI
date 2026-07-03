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

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * 재고 관리 — 옵션별 재고를 목록에서 바로 수정한다.
 * 상품 정보 전체를 열지 않고 재고만 빠르게 만지는 운영용 화면. (재고는 옵션에만 존재)
 */
@Controller
@RequestMapping("/admin/stock")
@RequiredArgsConstructor
public class StockController {

    private final ProductService productService;

    @GetMapping
    public String list(
        @RequestParam(required = false) String search,
        @RequestParam(defaultValue = "0") int page,
        @RequestParam(defaultValue = "20") int pageSize,
        Model model
    ) {
        Page<Product> products = productService.getProducts(search, null, PageRequest.of(page, pageSize));
        model.addAttribute("activeMenu", "stock");
        model.addAttribute("products", products);
        model.addAttribute("optionMap", productService.getOptionsByProduct(products.getContent()));
        model.addAttribute("stockMap", productService.getStockMap(products.getContent()));
        return "admin/stock/list";
    }

    /** 옵션 재고 일괄 수정 — 한 상품의 모든 옵션 재고를 한 번에 저장 */
    @PostMapping("/products/{productId}")
    public String updateProductStock(
        @PathVariable Long productId,
        @RequestParam("optionId") List<Long> optionIds,
        @RequestParam("stock") List<Integer> stocks,
        @RequestParam(required = false) String search,
        @RequestParam(defaultValue = "0") int page,
        @RequestParam(defaultValue = "20") int pageSize,
        RedirectAttributes ra
    ) {
        try {
            if (optionIds.size() != stocks.size()) {
                throw new IllegalArgumentException("옵션과 재고 값의 개수가 맞지 않습니다.");
            }
            Map<Long, Integer> stockByOption = new LinkedHashMap<>();
            for (int i = 0; i < optionIds.size(); i++) {
                stockByOption.put(optionIds.get(i), stocks.get(i));
            }
            productService.updateOptionStocks(stockByOption);
            ra.addFlashAttribute("successMsg", "재고가 저장되었습니다.");
        } catch (IllegalArgumentException e) {
            ra.addFlashAttribute("errorMsg", e.getMessage());
        }
        // 방금 저장한 상품은 목록에서 펼친 채로 복귀
        ra.addAttribute("expand", productId);
        return redirectBack(search, page, pageSize, ra);
    }

    /** 보고 있던 검색어·페이지·표시 개수를 유지한 채 목록으로 복귀 (addAttribute 가 인코딩 처리) */
    private String redirectBack(String search, int page, int pageSize, RedirectAttributes ra) {
        if (search != null && !search.isBlank()) ra.addAttribute("search", search);
        if (page > 0) ra.addAttribute("page", page);
        if (pageSize != 20) ra.addAttribute("pageSize", pageSize);
        return "redirect:/admin/stock";
    }
}
