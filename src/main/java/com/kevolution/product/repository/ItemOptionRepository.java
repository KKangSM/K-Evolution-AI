package com.kevolution.product.repository;

import com.kevolution.product.entity.ItemOption;
import com.kevolution.product.entity.Product;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface ItemOptionRepository extends JpaRepository<ItemOption, Long> {

    /** 상품의 옵션 목록 (노출 순서순) */
    List<ItemOption> findByProductOrderBySortOrderAsc(Product product);

    /** 여러 상품의 옵션을 한 번에 조회 (노출 순서순). 재고 목록 N+1 방지용. */
    List<ItemOption> findByProductInOrderBySortOrderAsc(List<Product> products);

    List<ItemOption> findByProduct(Product product);

    /** 상품 하나의 총재고 (옵션 재고 합계). 옵션이 없으면 0. */
    @Query("SELECT COALESCE(SUM(o.stock), 0) FROM ItemOption o WHERE o.product = :product")
    int sumStockByProduct(@Param("product") Product product);

    /** 여러 상품의 총재고를 [상품ID, 합계] 로 반환 (목록 화면 품절 판단용) */
    @Query("SELECT o.product.productId, COALESCE(SUM(o.stock), 0) FROM ItemOption o " +
           "WHERE o.product IN :products GROUP BY o.product.productId")
    List<Object[]> sumStockGrouped(@Param("products") List<Product> products);
}
