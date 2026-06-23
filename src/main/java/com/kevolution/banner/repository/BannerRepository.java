package com.kevolution.banner.repository;

import com.kevolution.banner.entity.Banner;

import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface BannerRepository extends JpaRepository<Banner, Long> {
    List<Banner> findByActiveTrueOrderBySortOrderAsc();
}
