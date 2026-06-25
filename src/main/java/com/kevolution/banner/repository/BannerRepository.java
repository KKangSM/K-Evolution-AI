package com.kevolution.banner.repository;

import com.kevolution.banner.entity.Banner;

import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface BannerRepository extends JpaRepository<Banner, Long> {
    List<Banner> findByActiveTrueOrderBySortOrderAsc();

    /** 관리자 목록: 노출순서 → ID 순 정렬 (비활성 포함 전체) */
    List<Banner> findAllByOrderBySortOrderAscBannerIdAsc();
}
