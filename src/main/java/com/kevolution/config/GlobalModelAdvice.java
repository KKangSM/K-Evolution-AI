package com.kevolution.config;

import com.kevolution.product.entity.Category;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ModelAttribute;

import java.util.List;

/** 모든 뷰에 공통으로 내려주는 모델. 카테고리는 여기 한 곳에서만 공급한다. */
@ControllerAdvice
public class GlobalModelAdvice {

    @ModelAttribute("globalCategories")
    public List<Category> globalCategories() {
        return List.of(Category.values());
    }
}
