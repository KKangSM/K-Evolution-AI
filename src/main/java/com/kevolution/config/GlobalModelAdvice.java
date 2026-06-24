package com.kevolution.config;

import com.kevolution.product.repository.CategoryRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ModelAttribute;

import java.util.List;

@ControllerAdvice
@RequiredArgsConstructor
public class GlobalModelAdvice {

    private final CategoryRepository categoryRepository;

    @ModelAttribute("globalCategories")
    public List<?> globalCategories() {
        return categoryRepository.findAll();
    }
}
