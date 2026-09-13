package com.kevolution.recommendation.repository;

import com.kevolution.recommendation.entity.RecommendationCache;
import org.springframework.data.jpa.repository.JpaRepository;

public interface RecommendationCacheRepository extends JpaRepository<RecommendationCache, String> {
}
