package com.kevolution.review.repository;

import com.kevolution.member.entity.Member;
import com.kevolution.order.entity.OrderItem;
import com.kevolution.product.entity.Product;
import com.kevolution.review.entity.Review;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface ReviewRepository extends JpaRepository<Review, Long> {
    Page<Review> findByProductOrderByCreatedAtDesc(Product product, Pageable pageable);
    List<Review> findByMemberOrderByCreatedAtDesc(Member member);
    long countByProduct(Product product);

    /** 한 주문 상품(order_item)당 리뷰는 1개 — 중복 작성 방지용 */
    boolean existsByOrderItem(OrderItem orderItem);

    /** 상품 평균 별점 (리뷰가 없으면 null) */
    @Query("SELECT AVG(r.rating) FROM Review r WHERE r.product = :product")
    Double averageRatingByProduct(@Param("product") Product product);

    /** 특정 회원이 이미 리뷰를 작성한 주문상품 ID 목록 (주문내역에서 '작성완료' 표시용) */
    @Query("SELECT r.orderItem.orderItemId FROM Review r "
         + "WHERE r.member.userId = :userId AND r.orderItem IS NOT NULL")
    List<Long> findReviewedOrderItemIds(@Param("userId") String userId);
}
