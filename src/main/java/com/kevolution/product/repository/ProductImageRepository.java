package com.kevolution.product.repository;

import com.kevolution.product.entity.Product;
import com.kevolution.product.entity.ProductImage;

import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface ProductImageRepository extends JpaRepository<ProductImage, Long> {
    List<ProductImage> findByProductOrderBySortOrderAsc(Product product);
}
