package com.kevolution.banner.repository;

import com.kevolution.banner.entity.Banner;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface BannerRepository extends JpaRepository<Banner, Long> {
    List<Banner> findByActiveTrueOrderBySortOrderAsc();

    /** 관리자 목록: 노출순서 → ID 순 정렬 (비활성 포함 전체) */
    List<Banner> findAllByOrderBySortOrderAscBannerIdAsc();

    /** 관리자 목록: 제목 검색 (keyword 가 null 이면 전체) */
    @Query("SELECT b FROM Banner b WHERE " +
           "(:keyword IS NULL OR b.title LIKE %:keyword%) " +
           "ORDER BY b.sortOrder ASC, b.bannerId ASC")
    List<Banner> searchByTitle(@Param("keyword") String keyword);
}
