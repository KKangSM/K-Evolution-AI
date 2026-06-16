package com.kevolution.repository;

import com.kevolution.entity.Category;
import com.kevolution.entity.Product;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;

public interface ProductRepository extends JpaRepository<Product, Long> {
    Page<Product> findByNameContainingIgnoreCase(String keyword, Pageable pageable);
    Page<Product> findByCategory(Category category, Pageable pageable);
    Page<Product> findByCategoryAndNameContainingIgnoreCase(Category category, String keyword, Pageable pageable);

    // 신상품: 등록일 내림차순
    List<Product> findAllByOrderByCreatedAtDesc(Pageable pageable);

    // 인기상품: 실제 주문 판매량(OrderItem 수량 합계) 내림차순.
    // LEFT JOIN이라 판매 이력이 없는 상품도 항상 포함되어 섹션이 비지 않는다.
    @Query("SELECT p FROM Product p LEFT JOIN OrderItem oi ON oi.product = p " +
           "GROUP BY p ORDER BY COALESCE(SUM(oi.quantity), 0) DESC, p.createdAt DESC")
    List<Product> findPopularProducts(Pageable pageable);
}
