package com.kevolution.repository;

import com.kevolution.entity.Member;
import com.kevolution.entity.Product;
import com.kevolution.entity.Review;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface ReviewRepository extends JpaRepository<Review, Long> {
    Page<Review> findByProductOrderByCreatedAtDesc(Product product, Pageable pageable);
    List<Review> findByMemberOrderByCreatedAtDesc(Member member);
    long countByProduct(Product product);
}
