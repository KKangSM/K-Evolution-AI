package com.kevolution.repository;

import com.kevolution.entity.Review;
import com.kevolution.entity.ReviewImage;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface ReviewImageRepository extends JpaRepository<ReviewImage, Long> {
    List<ReviewImage> findByReviewOrderBySortOrderAsc(Review review);
}
