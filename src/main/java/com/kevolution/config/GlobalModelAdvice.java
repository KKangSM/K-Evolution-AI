package com.kevolution.config;

import com.kevolution.product.repository.CategoryRepository;
import lombok.Getter;
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

    /** 메인 화면 카테고리 네비 — 최상위 카테고리를 DB 기준으로 동적 생성(아이콘 포함). */
    @ModelAttribute("mainCategories")
    public List<CategoryNav> mainCategories() {
        return categoryRepository.findByParentIsNullOrderByCategoryIdAsc().stream()
            .map(c -> new CategoryNav(c.getCategoryId(), c.getName(), iconFor(c.getName())))
            .toList();
    }

    /** 카테고리 이름으로 static/images/category/*.svg 아이콘을 고른다. (없으면 default) */
    private String iconFor(String name) {
        if (name == null) return "default";
        if (name.contains("신발")) return "shoes";
        if (name.contains("의류") || name.contains("패션") || name.contains("옷")) return "clothing";
        if (name.contains("뷰티") || name.contains("화장")) return "beauty";
        if (name.contains("가방")) return "bag";
        if (name.contains("액세서리") || name.contains("악세")) return "accessory";
        if (name.contains("리빙") || name.contains("생활")) return "living";
        if (name.contains("노트북") || name.contains("스마트폰") || name.contains("폰")
            || name.contains("디지털") || name.contains("전자")) return "digital";
        if (name.contains("식품") || name.contains("식") || name.contains("푸드")) return "food";
        return "default";
    }

    /** 메인 네비 한 칸 (카테고리 id/이름/아이콘). JSP EL 게터 규약을 위해 클래스로 둔다. */
    @Getter
    @RequiredArgsConstructor
    public static class CategoryNav {
        private final Long id;
        private final String name;
        private final String icon;
    }
}
