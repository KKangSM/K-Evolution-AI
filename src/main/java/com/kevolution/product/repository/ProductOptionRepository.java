package com.kevolution.product.repository;

import com.kevolution.product.entity.Product;
import com.kevolution.product.entity.ProductOption;

import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface ProductOptionRepository extends JpaRepository<ProductOption, Long> {
    List<ProductOption> findByProduct(Product product);
    List<ProductOption> findByProductOrderBySortOrderAsc(Product product);
}
