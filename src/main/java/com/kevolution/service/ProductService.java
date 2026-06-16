package com.kevolution.service;

import com.kevolution.entity.Category;
import com.kevolution.entity.Product;
import com.kevolution.repository.CategoryRepository;
import com.kevolution.repository.ProductRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class ProductService {

    private final ProductRepository productRepository;
    private final CategoryRepository categoryRepository;

    public Page<Product> getProducts(String keyword, Long categoryId, Pageable pageable) {
        if (categoryId != null) {
            Category category = categoryRepository.findById(categoryId).orElse(null);
            if (category != null) {
                if (keyword != null && !keyword.isBlank()) {
                    return productRepository.findByCategoryAndNameContainingIgnoreCase(category, keyword, pageable);
                }
                return productRepository.findByCategory(category, pageable);
            }
        }
        if (keyword != null && !keyword.isBlank()) {
            return productRepository.findByNameContainingIgnoreCase(keyword, pageable);
        }
        return productRepository.findAll(pageable);
    }

    public Product getProduct(Long productId) {
        return productRepository.findById(productId)
            .orElseThrow(() -> new IllegalArgumentException("상품을 찾을 수 없습니다."));
    }
}
