package com.kevolution.service;

import com.kevolution.entity.Category;
import com.kevolution.entity.Product;
import com.kevolution.repository.CategoryRepository;
import com.kevolution.repository.ProductRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

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

    /** 메인 페이지 신상품 목록 (등록일 최신순) */
    public List<Product> getNewProducts(int size) {
        return productRepository.findAllByOrderByCreatedAtDesc(PageRequest.of(0, size));
    }

    /** 메인 페이지 인기상품 목록 (판매량 순) */
    public List<Product> getPopularProducts(int size) {
        return productRepository.findPopularProducts(PageRequest.of(0, size));
    }

    // ---------------------------------------------------------------
    // 관리자 상품 관리 (등록/수정/삭제)
    // ---------------------------------------------------------------

    @Transactional
    public Long createProduct(Long categoryId, String name, int price, int stock,
                              String description, String imageUrl) {
        Product product = Product.builder()
            .category(findCategoryOrNull(categoryId))
            .name(name)
            .price(price)
            .stock(stock)
            .description(description)
            .imageUrl(emptyToNull(imageUrl))
            .build();
        return productRepository.save(product).getProductId();
    }

    @Transactional
    public void updateProduct(Long productId, Long categoryId, String name, int price, int stock,
                              String description, String imageUrl) {
        Product product = getProduct(productId);
        product.update(findCategoryOrNull(categoryId), name, price, stock,
                       description, emptyToNull(imageUrl));
    }

    @Transactional
    public void deleteProduct(Long productId) {
        if (!productRepository.existsById(productId)) {
            throw new IllegalArgumentException("상품을 찾을 수 없습니다.");
        }
        productRepository.deleteById(productId);
    }

    private Category findCategoryOrNull(Long categoryId) {
        if (categoryId == null) return null;
        return categoryRepository.findById(categoryId).orElse(null);
    }

    private String emptyToNull(String value) {
        return (value == null || value.isBlank()) ? null : value;
    }
}
