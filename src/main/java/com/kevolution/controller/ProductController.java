package com.kevolution.controller;

import com.kevolution.entity.Category;
import com.kevolution.entity.Product;
import com.kevolution.repository.CategoryRepository;
import com.kevolution.service.ProductService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@Controller
@RequiredArgsConstructor
public class ProductController {

    private final ProductService productService;
    private final CategoryRepository categoryRepository;

    @GetMapping("/")
    public String home() {
        return "redirect:/products";
    }

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
}
