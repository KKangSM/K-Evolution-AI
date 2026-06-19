package com.kevolution.repository;

import com.kevolution.entity.Product;
import com.kevolution.entity.ProductImage;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface ProductImageRepository extends JpaRepository<ProductImage, Long> {
    List<ProductImage> findByProductOrderBySortOrderAsc(Product product);
}
