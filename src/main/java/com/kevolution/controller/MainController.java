package com.kevolution.controller;

import com.kevolution.repository.CategoryRepository;
import com.kevolution.service.ProductService;
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

    @GetMapping("/")
    public String main(Model model) {
        model.addAttribute("categories", categoryRepository.findAll());
        model.addAttribute("newProducts", productService.getNewProducts(SECTION_SIZE));
        model.addAttribute("popularProducts", productService.getPopularProducts(SECTION_SIZE));
        return "main";
    }
}
