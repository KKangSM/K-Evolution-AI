package com.kevolution.controller;

import com.kevolution.entity.Product;
import com.kevolution.repository.CategoryRepository;
import com.kevolution.service.ProductService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

/** 관리자 상품 관리. /admin/** 는 SecurityConfig에서 ROLE_ADMIN으로 제한됨. */
@Controller
@RequestMapping("/admin/products")
@RequiredArgsConstructor
public class AdminProductController {

    private static final int PAGE_SIZE = 20;

    private final ProductService productService;
    private final CategoryRepository categoryRepository;

    /** 상품 목록 */
    @GetMapping
    public String list(
        @RequestParam(required = false) String keyword,
        @RequestParam(defaultValue = "0") int page,
        Model model
    ) {
        Page<Product> products = productService.getProducts(keyword, null, PageRequest.of(page, PAGE_SIZE));
        model.addAttribute("activeMenu", "products");
        model.addAttribute("products", products);
        model.addAttribute("keyword", keyword);
        model.addAttribute("currentPage", page);
        return "admin/products/list";
    }

    /** 상품 등록 폼 */
    @GetMapping("/register")
    public String registerForm(Model model) {
        model.addAttribute("activeMenu", "products");
        model.addAttribute("categories", categoryRepository.findAll());
        return "admin/products/form";
    }

    /** 상품 등록 처리 */
    @PostMapping("/register")
    public String register(
        @RequestParam(required = false) Long categoryId,
        @RequestParam String name,
        @RequestParam int price,
        @RequestParam int stock,
        @RequestParam(required = false) String description,
        @RequestParam(required = false) String imageUrl
    ) {
        productService.createProduct(categoryId, name, price, stock, description, imageUrl);
        return "redirect:/admin/products";
    }

    /** 상품 수정 폼 */
    @GetMapping("/{productId}/edit")
    public String editForm(@PathVariable Long productId, Model model) {
        model.addAttribute("activeMenu", "products");
        model.addAttribute("product", productService.getProduct(productId));
        model.addAttribute("categories", categoryRepository.findAll());
        return "admin/products/form";
    }

    /** 상품 수정 처리 */
    @PostMapping("/{productId}/edit")
    public String edit(
        @PathVariable Long productId,
        @RequestParam(required = false) Long categoryId,
        @RequestParam String name,
        @RequestParam int price,
        @RequestParam int stock,
        @RequestParam(required = false) String description,
        @RequestParam(required = false) String imageUrl
    ) {
        productService.updateProduct(productId, categoryId, name, price, stock, description, imageUrl);
        return "redirect:/admin/products";
    }

    /** 상품 삭제 처리 */
    @PostMapping("/{productId}/delete")
    public String delete(@PathVariable Long productId) {
        productService.deleteProduct(productId);
        return "redirect:/admin/products";
    }
}
