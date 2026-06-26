package com.kevolution.product.service;

import com.kevolution.product.entity.Category;
import com.kevolution.product.entity.Product;
import com.kevolution.product.entity.ProductImage;
import com.kevolution.product.entity.ProductOption;
import com.kevolution.product.entity.ProductSize;
import com.kevolution.product.repository.CategoryRepository;
import com.kevolution.product.repository.ProductImageRepository;
import com.kevolution.product.repository.ProductOptionRepository;
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
    private final ProductOptionRepository productOptionRepository;

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

    /** 상품의 옵션(사이즈×색상 조합) 전체 */
    public List<ProductOption> getProductOptions(Long productId) {
        return productOptionRepository.findByProduct(getProduct(productId));
    }

    /** 사용된 사이즈 값 목록 (중복 제거) */
    public List<String> getProductSizes(Long productId) {
        return distinctNonBlank(getProductOptions(productId).stream().map(ProductOption::getSize));
    }

    /** 사용된 색상 값 목록 (중복 제거) */
    public List<String> getProductColors(Long productId) {
        return distinctNonBlank(getProductOptions(productId).stream().map(ProductOption::getColor));
    }

    private List<String> distinctNonBlank(java.util.stream.Stream<String> values) {
        return values.filter(v -> v != null && !v.isBlank()).distinct().toList();
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
                              String description, String imageUrl, List<String> detailImageUrls,
                              List<String> comboSizes, List<String> comboColors, List<Integer> comboStocks) {
        Category category = findCategoryOrNull(categoryId);
        Product product = Product.builder()
            .category(category)
            .name(name)
            .price(price)
            .stock(stock)
            .description(description)
            .imageUrl(emptyToNull(imageUrl))
            .build();
        productRepository.save(product);
        saveProductImages(product, detailImageUrls);
        replaceOptions(product, comboSizes, comboColors, comboStocks, isShoesCategory(category));
        return product.getProductId();
    }

    @Transactional
    public void updateProduct(Long productId, Long categoryId, String name, int price, int stock,
                              String description, String imageUrl, List<String> newDetailImageUrls,
                              List<String> comboSizes, List<String> comboColors, List<Integer> comboStocks) {
        Category category = findCategoryOrNull(categoryId);
        Product product = getProduct(productId);
        product.update(category, name, price, stock, description, emptyToNull(imageUrl));
        saveProductImages(product, newDetailImageUrls);  // 새로 올린 이미지는 기존 뒤에 추가된다.
        replaceOptions(product, comboSizes, comboColors, comboStocks, isShoesCategory(category)); // 옵션은 매번 새 입력으로 교체한다.
    }

    /** 신발 카테고리면 사이즈를 자유 입력으로 받는다. */
    private boolean isShoesCategory(Category category) {
        return category != null && "신발".equals(category.getName());
    }

    /** 상품과 그 이미지들을 삭제하고, Storage 에서 지워야 할 이미지 URL 목록(대표+추가)을 돌려준다. */
    @Transactional
    public List<String> deleteProduct(Long productId) {
        Product product = getProduct(productId);
        List<ProductImage> images = productImageRepository.findByProductOrderBySortOrderAsc(product);

        List<String> imageUrls = new ArrayList<>();
        if (product.getImageUrl() != null) imageUrls.add(product.getImageUrl());
        images.forEach(img -> imageUrls.add(img.getImageUrl()));

        // 자식(추가 이미지·옵션)을 먼저 정리해야 FK 제약에 걸리지 않는다.
        productImageRepository.deleteAll(images);
        productOptionRepository.deleteAll(productOptionRepository.findByProduct(product));
        productRepository.delete(product);
        return imageUrls;
    }

    /**
     * 사이즈×색상 조합 옵션을 기존 것 삭제 후 새로 저장한다.
     * 세 리스트는 같은 인덱스끼리 한 조합(size[i] / color[i] / stock[i])을 이룬다.
     */
    private void replaceOptions(Product product, List<String> sizes, List<String> colors,
                                List<Integer> stocks, boolean freeSize) {
        List<ProductOption> existing = productOptionRepository.findByProduct(product);
        if (!existing.isEmpty()) productOptionRepository.deleteAll(existing);
        if (sizes == null) return;

        for (int i = 0; i < sizes.size(); i++) {
            String size = normalizeSize(sizes.get(i), freeSize);
            String color = (colors != null && i < colors.size() && colors.get(i) != null)
                ? colors.get(i).trim() : "";
            int stock = (stocks != null && i < stocks.size() && stocks.get(i) != null)
                ? Math.max(stocks.get(i), 0) : 0;

            if (size.isEmpty() && color.isEmpty()) continue; // 빈 조합은 건너뛴다.
            productOptionRepository.save(ProductOption.builder()
                .product(product)
                .size(size)
                .color(color)
                .extraPrice(0)
                .stock(stock)
                .build());
        }
    }

    /**
     * 사이즈 값 표준화.
     * 신발(freeSize)이면 입력값을 그대로(trim) 쓰고,
     * 의류면 ProductSize(XS~XXL)에 정의된 값만 대문자로 남기고 나머지는 "".
     */
    private String normalizeSize(String size, boolean freeSize) {
        if (size == null || size.isBlank()) return "";
        if (freeSize) return size.trim();
        try {
            return ProductSize.valueOf(size.trim().toUpperCase()).name();
        } catch (IllegalArgumentException ignore) {
            return "";
        }
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
