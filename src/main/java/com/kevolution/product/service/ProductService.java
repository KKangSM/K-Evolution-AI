package com.kevolution.product.service;

import com.kevolution.product.dto.ProductOptionForm;
import com.kevolution.product.entity.Category;
import com.kevolution.product.entity.ItemOption;
import com.kevolution.product.entity.Product;
import com.kevolution.product.entity.ProductImage;
import com.kevolution.product.repository.ItemOptionRepository;
import com.kevolution.product.repository.ProductImageRepository;
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
    private final ItemOptionRepository itemOptionRepository;

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
    public List<ItemOption> getProductOptions(Long productId) {
        return itemOptionRepository.findByProductOrderBySortOrderAsc(getProduct(productId));
    }

    /** 옵션을 옵션명(색상/사이즈 등)별로 묶어 노출 순서대로 반환한다. (상세 페이지 옵션 선택용) */
    public Map<String, List<ItemOption>> getProductOptionsGrouped(Long productId) {
        Map<String, List<ItemOption>> grouped = new LinkedHashMap<>();
        for (ItemOption option : getProductOptions(productId)) {
            grouped.computeIfAbsent(option.getOptionName(), key -> new ArrayList<>()).add(option);
        }
        return grouped;
    }

    /** 상품 하나의 총재고 (옵션 재고 합계) */
    public int getTotalStock(Product product) {
        return itemOptionRepository.sumStockByProduct(product);
    }

    /** 목록 화면용: 상품별 총재고 맵 (productId → 합계). 품절 판단에 사용. */
    public Map<Long, Integer> getStockMap(List<Product> products) {
        Map<Long, Integer> map = new LinkedHashMap<>();
        if (products == null || products.isEmpty()) return map;
        for (Object[] row : itemOptionRepository.sumStockGrouped(products)) {
            map.put((Long) row[0], ((Number) row[1]).intValue());
        }
        // 옵션이 하나도 없어 쿼리에 안 잡힌 상품은 0으로 채운다.
        for (Product p : products) map.putIfAbsent(p.getProductId(), 0);
        return map;
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
    // 재고는 옵션(item_option)에만 존재한다. 모든 상품은 옵션을 최소 1개 가진다.
    // ---------------------------------------------------------------

    @Transactional
    public Long createProduct(Category category, String name, int price,
                              String description, String imageUrl, List<String> detailImageUrls,
                              List<ProductOptionForm> options) {
        requireAtLeastOneOption(options);
        Product product = Product.builder()
            .category(category)
            .name(name)
            .price(price)
            .description(description)
            .imageUrl(emptyToNull(imageUrl))
            .build();
        productRepository.save(product);
        saveProductImages(product, detailImageUrls);
        saveProductOptions(product, options);
        return product.getProductId();
    }

    @Transactional
    public void updateProduct(Long productId, Category category, String name, int price,
                              String description, String imageUrl, List<String> newDetailImageUrls,
                              List<ProductOptionForm> options) {
        requireAtLeastOneOption(options);
        Product product = getProduct(productId);
        product.update(category, name, price, description, emptyToNull(imageUrl));
        saveProductImages(product, newDetailImageUrls); // 새로 올린 이미지는 기존 뒤에 추가된다.
        replaceProductOptions(product, options);        // 옵션은 폼 내용으로 전체 교체된다.
    }

    // ---------------------------------------------------------------
    // 재고 관리 (/admin/stock) — 재고는 옵션 단위로만 수정한다.
    // ---------------------------------------------------------------

    /** 재고 관리 화면용: 상품 목록의 옵션들을 상품 ID 별로 묶어 반환 (단일 쿼리로 조회 후 메모리에서 그룹핑) */
    public Map<Long, List<ItemOption>> getOptionsByProduct(List<Product> products) {
        Map<Long, List<ItemOption>> grouped = new LinkedHashMap<>();
        if (products == null || products.isEmpty()) return grouped;
        // 상품 순서를 유지하기 위해 빈 리스트로 먼저 채워 둔다.
        for (Product product : products) grouped.put(product.getProductId(), new ArrayList<>());
        // 옵션을 한 번에 가져와 상품별로 분배 (기존: 상품 수만큼 쿼리 → 현재: 1회)
        for (ItemOption option : itemOptionRepository.findByProductInOrderBySortOrderAsc(products)) {
            grouped.get(option.getProduct().getProductId()).add(option);
        }
        return grouped;
    }

    /** 옵션 재고 일괄 수정 — 한 상품의 여러 옵션 재고를 한 트랜잭션에서 저장한다(하나라도 실패하면 전체 롤백). */
    @Transactional
    public void updateOptionStocks(Map<Long, Integer> stockByOptionId) {
        stockByOptionId.forEach((optionId, stock) -> {
            ItemOption option = itemOptionRepository.findById(optionId)
                .orElseThrow(() -> new IllegalArgumentException("옵션을 찾을 수 없습니다."));
            option.changeStock(stock);
        });
    }

    /** 상품과 그 이미지·옵션을 삭제하고, Storage 에서 지워야 할 이미지 URL 목록(대표+추가)을 돌려준다. */
    @Transactional
    public List<String> deleteProduct(Long productId) {
        Product product = getProduct(productId);
        List<ProductImage> images = productImageRepository.findByProductOrderBySortOrderAsc(product);

        List<String> imageUrls = new ArrayList<>();
        if (product.getImageUrl() != null) imageUrls.add(product.getImageUrl());
        images.forEach(img -> imageUrls.add(img.getImageUrl()));

        // 상품을 참조하는 자식(추가 이미지·옵션)을 먼저 정리해야 FK 제약에 걸리지 않는다.
        productImageRepository.deleteAll(images);
        itemOptionRepository.deleteAll(itemOptionRepository.findByProduct(product));
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
        int sortOrder = 0;
        for (ProductOptionForm form : options) {
            if (!form.isValid()) continue;
            itemOptionRepository.save(ItemOption.builder()
                .product(product)
                .optionName(form.optionName().trim())
                .optionValue(form.optionValue().trim())
                .stock(form.stock())
                .sortOrder(sortOrder++)
                .build());
        }
    }

    /** 기존 옵션을 모두 지우고 폼 내용으로 다시 저장한다. */
    private void replaceProductOptions(Product product, List<ProductOptionForm> options) {
        itemOptionRepository.deleteAll(itemOptionRepository.findByProduct(product));
        saveProductOptions(product, options);
    }

    /** 재고는 옵션에만 있으므로, 상품은 유효한 옵션을 최소 1개 가져야 한다. */
    private void requireAtLeastOneOption(List<ProductOptionForm> options) {
        boolean hasValid = options != null && options.stream().anyMatch(ProductOptionForm::isValid);
        if (!hasValid) {
            throw new IllegalArgumentException(
                "재고 관리를 위해 옵션을 최소 1개 입력해주세요. (옵션이 없는 상품은 예: 기본/단일)");
        }
    }

    private String emptyToNull(String value) {
        return (value == null || value.isBlank()) ? null : value;
    }
}
