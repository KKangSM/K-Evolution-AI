package com.kevolution.product.repository;

import com.kevolution.product.entity.Category;

import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface CategoryRepository extends JpaRepository<Category, Long> {

    /** 메인 네비용 최상위 카테고리(대분류, parent 없음) 목록 */
    List<Category> findByParentIsNullOrderByCategoryIdAsc();
}
