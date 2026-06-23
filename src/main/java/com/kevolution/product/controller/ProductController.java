package com.kevolution.product.controller;

import com.kevolution.config.SecurityConfig;
import com.kevolution.product.entity.Category;
import com.kevolution.product.entity.Product;
import com.kevolution.product.repository.CategoryRepository;
import com.kevolution.product.service.ProductService;

import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import java.util.List;

/**
 * 상품 — 공개 조회(/products)와 관리자 관리(/admin/products)를 한 곳에서 담당한다.
 * 권한 구분은 SecurityConfig 의 URL 규칙(/admin/** = ROLE_ADMIN)만으로 처리한다.
 */
@Controller
@RequiredArgsConstructor
public class ProductController {

    private static final int ADMIN_PAGE_SIZE = 20;

    private final ProductService productService;
    private final CategoryRepository categoryRepository;

    // ── 공개 조회 ─────────────────────────────────
    @GetMapping("/products")
    public String list(
        @RequestParam(required = false) String keyword,
        @RequestParam(required = false) Long categoryId,
        @RequestParam(defaultValue = "0") int page,
        Model model
    ) {
        Page<Product> products = productService.getProducts(keyword, categoryId, PageRequest.of(page, 12));
        List<Category> categories = categoryRepository.findAll();

        model.addAttribute("products", products);
        model.addAttribute("categories", categories);
        model.addAttribute("keyword", keyword);
        model.addAttribute("categoryId", categoryId);
        model.addAttribute("currentPage", page);
        return "products/list";
    }

    @GetMapping("/products/{productId}")
    public String detail(@PathVariable Long productId, Model model) {
        model.addAttribute("product", productService.getProduct(productId));
        return "products/detail";
    }

    // ── 관리자 관리 (/admin/** = ROLE_ADMIN) ──────────
    @GetMapping("/admin/products")
    public String adminList(
        @RequestParam(required = false) String keyword,
        @RequestParam(defaultValue = "0") int page,
        Model model
    ) {
        Page<Product> products = productService.getProducts(keyword, null, PageRequest.of(page, ADMIN_PAGE_SIZE));
        model.addAttribute("activeMenu", "products");
        model.addAttribute("products", products);
        model.addAttribute("keyword", keyword);
        model.addAttribute("currentPage", page);
        return "admin/products/list";
    }

    @GetMapping("/admin/products/register")
    public String registerForm(Model model) {
        model.addAttribute("activeMenu", "products");
        model.addAttribute("categories", categoryRepository.findAll());
        return "admin/products/form";
    }

    @PostMapping("/admin/products/register")
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

    @GetMapping("/admin/products/{productId}/edit")
    public String editForm(@PathVariable Long productId, Model model) {
        model.addAttribute("activeMenu", "products");
        model.addAttribute("product", productService.getProduct(productId));
        model.addAttribute("categories", categoryRepository.findAll());
        return "admin/products/form";
    }

    @PostMapping("/admin/products/{productId}/edit")
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

    @PostMapping("/admin/products/{productId}/delete")
    public String delete(@PathVariable Long productId) {
        productService.deleteProduct(productId);
        return "redirect:/admin/products";
    }
}
