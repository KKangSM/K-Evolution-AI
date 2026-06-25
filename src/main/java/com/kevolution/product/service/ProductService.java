package com.kevolution.product.service;

import com.kevolution.product.entity.Category;
import com.kevolution.product.entity.Product;
import com.kevolution.product.entity.ProductImage;
import com.kevolution.product.repository.CategoryRepository;
import com.kevolution.product.repository.ProductImageRepository;
import com.kevolution.product.repository.ProductRepository;

import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class ProductService {

    private final ProductRepository productRepository;
    private final CategoryRepository categoryRepository;
    private final ProductImageRepository productImageRepository;

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

    /** 상품의 추가 이미지 목록 (정렬순) */
    public List<ProductImage> getProductImages(Long productId) {
        return productImageRepository.findByProductOrderBySortOrderAsc(getProduct(productId));
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
                              String description, String imageUrl, List<String> detailImageUrls) {
        Product product = Product.builder()
            .category(findCategoryOrNull(categoryId))
            .name(name)
            .price(price)
            .stock(stock)
            .description(description)
            .imageUrl(emptyToNull(imageUrl))
            .build();
        productRepository.save(product);
        saveProductImages(product, detailImageUrls);
        return product.getProductId();
    }

    @Transactional
    public void updateProduct(Long productId, Long categoryId, String name, int price, int stock,
                              String description, String imageUrl, List<String> newDetailImageUrls) {
        Product product = getProduct(productId);
        product.update(findCategoryOrNull(categoryId), name, price, stock,
                       description, emptyToNull(imageUrl));
        saveProductImages(product, newDetailImageUrls); // 새로 올린 이미지는 기존 뒤에 추가된다.
    }

    /** 상품과 그 이미지들을 삭제하고, Storage 에서 지워야 할 이미지 URL 목록(대표+추가)을 돌려준다. */
    @Transactional
    public List<String> deleteProduct(Long productId) {
        Product product = getProduct(productId);
        List<ProductImage> images = productImageRepository.findByProductOrderBySortOrderAsc(product);

        List<String> imageUrls = new ArrayList<>();
        if (product.getImageUrl() != null) imageUrls.add(product.getImageUrl());
        images.forEach(img -> imageUrls.add(img.getImageUrl()));

        // 자식(추가 이미지)을 먼저 정리해야 FK 제약에 걸리지 않는다.
        productImageRepository.deleteAll(images);
        productRepository.delete(product);
        return imageUrls;
    }

    /** 추가 이미지 URL 들을 ProductImage 로 저장한다. (기존 이미지 뒤 순서로 이어 붙임) */
    private void saveProductImages(Product product, List<String> imageUrls) {
        if (imageUrls == null || imageUrls.isEmpty()) return;
        int sortOrder = productImageRepository.findByProductOrderBySortOrderAsc(product).size();
        for (String url : imageUrls) {
            if (url == null || url.isBlank()) continue;
            productImageRepository.save(ProductImage.builder()
                .product(product)
                .imageUrl(url)
                .sortOrder(sortOrder++)
                .thumbnail(false)
                .build());
        }
    }

    private Category findCategoryOrNull(Long categoryId) {
        if (categoryId == null) return null;
        return categoryRepository.findById(categoryId).orElse(null);
    }

    private String emptyToNull(String value) {
        return (value == null || value.isBlank()) ? null : value;
    }
}
