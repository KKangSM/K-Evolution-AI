package com.kevolution.banner.repository;

import com.kevolution.banner.entity.Banner;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDateTime;
import java.util.List;

public interface BannerRepository extends JpaRepository<Banner, Long> {

    /**
     * 공개 노출용: active=true 이고 현재 시각이 노출 기간 안에 있는 배너만.
     * startAt/endAt 이 null 이면 각각 "시작 제한 없음 / 종료 제한 없음"으로 상시 취급.
     */
    @Query("SELECT b FROM Banner b WHERE b.active = true " +
           "AND (b.startAt IS NULL OR b.startAt <= :now) " +
           "AND (b.endAt IS NULL OR b.endAt >= :now) " +
           "ORDER BY b.sortOrder ASC, b.bannerId ASC")
    List<Banner> findVisible(@Param("now") LocalDateTime now);

    /** 관리자 목록: 노출순서 → ID 순 정렬 (비활성 포함 전체) */
    List<Banner> findAllByOrderBySortOrderAscBannerIdAsc();

    /** 관리자 목록: 제목 검색 (keyword 가 null 이면 전체) */
    @Query("SELECT b FROM Banner b WHERE " +
           "(:keyword IS NULL OR b.title LIKE %:keyword%) " +
           "ORDER BY b.sortOrder ASC, b.bannerId ASC")
    List<Banner> searchByTitle(@Param("keyword") String keyword);
}
