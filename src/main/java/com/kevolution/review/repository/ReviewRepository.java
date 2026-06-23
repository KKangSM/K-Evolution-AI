package com.kevolution.review.repository;

import com.kevolution.member.entity.Member;
import com.kevolution.product.entity.Product;
import com.kevolution.review.entity.Review;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface ReviewRepository extends JpaRepository<Review, Long> {
    Page<Review> findByProductOrderByCreatedAtDesc(Product product, Pageable pageable);
    List<Review> findByMemberOrderByCreatedAtDesc(Member member);
    long countByProduct(Product product);
}
