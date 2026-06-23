package com.kevolution.review.repository;

import com.kevolution.review.entity.Review;
import com.kevolution.review.entity.ReviewImage;

import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface ReviewImageRepository extends JpaRepository<ReviewImage, Long> {
    List<ReviewImage> findByReviewOrderBySortOrderAsc(Review review);
}
