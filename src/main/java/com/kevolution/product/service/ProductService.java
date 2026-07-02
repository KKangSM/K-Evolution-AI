package com.kevolution.product.service;

import com.kevolution.product.dto.ProductOptionForm;
import com.kevolution.product.entity.Category;
import com.kevolution.product.entity.Product;
import com.kevolution.product.entity.ProductImage;
import com.kevolution.product.entity.ProductOption;
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
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class ProductService {

    private final ProductRepository productRepository;
    private final ProductImageRepository productImageRepository;
    private final ProductOptionRepository productOptionRepository;

    public Page<Product> getProducts(String keyword, Category category, Pageable pageable) {
        if (category != null) {
            if (keyword != null && !keyword.isBlank()) {
                return productRepository.findByCategoryAndNameContainingIgnoreCase(category, keyword, pageable);
            }
            return productRepository.findByCategory(category, pageable);
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

    /** 상품의 옵션 목록 (노출 순서순) */
    public List<ProductOption> getProductOptions(Long productId) {
        return productOptionRepository.findByProductOrderBySortOrderAsc(getProduct(productId));
    }

    /** 판매 중인 옵션을 옵션명(색상/사이즈 등)별로 묶어 노출 순서대로 반환한다. (상세 페이지 옵션 선택용) */
    public Map<String, List<ProductOption>> getProductOptionsGrouped(Long productId) {
        Map<String, List<ProductOption>> grouped = new LinkedHashMap<>();
        for (ProductOption option : getProductOptions(productId)) {
            if (!option.isActive()) continue;
            grouped.computeIfAbsent(option.getOptionName(), key -> new ArrayList<>()).add(option);
        }
        return grouped;
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
    public Long createProduct(Category category, String name, int price, int stock,
                              String description, String imageUrl, List<String> detailImageUrls,
                              List<ProductOptionForm> options) {
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
        saveProductOptions(product, options);
        syncStockFromOptions(product);
        return product.getProductId();
    }

    @Transactional
    public void updateProduct(Long productId, Category category, String name, int price, int stock,
                              String description, String imageUrl, List<String> newDetailImageUrls,
                              List<ProductOptionForm> options) {
        Product product = getProduct(productId);
        product.update(category, name, price, stock,
                       description, emptyToNull(imageUrl));
        saveProductImages(product, newDetailImageUrls); // 새로 올린 이미지는 기존 뒤에 추가된다.
        replaceProductOptions(product, options);        // 옵션은 폼 내용으로 전체 교체된다.
        syncStockFromOptions(product);
    }

    // ---------------------------------------------------------------
    // 재고 관리 (/admin/stock)
    // 규칙: 옵션 있는 상품의 재고 원본은 옵션별 재고이고, product.stock 은 판매중
    //       옵션 재고의 합계로 자동 동기화된다. (품절 배지·장바구니 차단·대시보드
    //       집계가 지금처럼 product.stock 만 읽어도 항상 정확하도록)
    //       옵션 없는 상품은 product.stock 을 직접 관리한다.
    // ---------------------------------------------------------------

    /** 재고 관리 화면용: 상품 목록의 옵션들을 상품 ID 별로 묶어 반환 (옵션 없는 상품은 미포함) */
    public Map<Long, List<ProductOption>> getOptionsByProduct(List<Product> products) {
        Map<Long, List<ProductOption>> grouped = new LinkedHashMap<>();
        for (Product product : products) {
            List<ProductOption> options = productOptionRepository.findByProductOrderBySortOrderAsc(product);
            if (!options.isEmpty()) grouped.put(product.getProductId(), options);
        }
        return grouped;
    }

    /** 옵션 없는 상품의 재고 수정. 옵션 있는 상품은 옵션별 재고로만 관리한다. */
    @Transactional
    public void updateProductStock(Long productId, int stock) {
        Product product = getProduct(productId);
        if (!productOptionRepository.findByProduct(product).isEmpty()) {
            throw new IllegalArgumentException("옵션이 있는 상품은 옵션별 재고로 관리됩니다.");
        }
        product.changeStock(stock);
    }

    /** 옵션 재고 수정 후 상품 재고(합계)를 동기화한다. */
    @Transactional
    public void updateOptionStock(Long optionId, int stock) {
        ProductOption option = productOptionRepository.findById(optionId)
            .orElseThrow(() -> new IllegalArgumentException("옵션을 찾을 수 없습니다."));
        option.changeStock(stock);
        syncStockFromOptions(option.getProduct());
    }

    /** 옵션 있는 상품이면 product.stock 을 판매중 옵션 재고 합계로 맞춘다. (옵션 없으면 그대로) */
    private void syncStockFromOptions(Product product) {
        List<ProductOption> options = productOptionRepository.findByProduct(product);
        if (options.isEmpty()) return;
        int total = options.stream()
            .filter(ProductOption::isActive)
            .mapToInt(ProductOption::getStock)
            .sum();
        product.changeStock(total);
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

    /** 유효한(옵션명·옵션값이 있는) 옵션 행만 입력 순서대로 저장한다. */
    private void saveProductOptions(Product product, List<ProductOptionForm> options) {
        if (options == null || options.isEmpty()) return;
        int sortOrder = 0;
        for (ProductOptionForm form : options) {
            if (!form.isValid()) continue;
            productOptionRepository.save(ProductOption.builder()
                .product(product)
                .optionName(form.optionName().trim())
                .optionValue(form.optionValue().trim())
                .extraPrice(form.extraPrice())
                .stock(form.stock())
                .skuCode(emptyToNull(form.skuCode()))
                .sortOrder(sortOrder++)
                .build());
        }
    }

    /** 기존 옵션을 모두 지우고 폼 내용으로 다시 저장한다. (옵션은 아직 주문/장바구니에서 참조되지 않아 교체 안전) */
    private void replaceProductOptions(Product product, List<ProductOptionForm> options) {
        productOptionRepository.deleteAll(productOptionRepository.findByProduct(product));
        saveProductOptions(product, options);
    }

    private String emptyToNull(String value) {
        return (value == null || value.isBlank()) ? null : value;
    }
}
