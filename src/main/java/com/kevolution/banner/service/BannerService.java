package com.kevolution.banner.service;

import com.kevolution.banner.entity.Banner;
import com.kevolution.banner.repository.BannerRepository;

import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 배너(광고/이벤트 노출용) 단일 서비스 — 조회와 관리(CRUD)를 모두 담당한다.
 * 이미지 파일 업로드는 컨트롤러에서 Supabase Storage 로 처리하고,
 * 여기서는 결과 URL 만 다룬다. (상품 관리와 동일한 책임 분리)
 */
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class BannerService {

    private final BannerRepository bannerRepository;

    public List<Banner> getBanners() {
        return bannerRepository.findAllByOrderBySortOrderAscBannerIdAsc();
    }

    /** 공개 노출용: 현재 시각 기준으로 활성·노출기간을 만족하는 배너만 */
    public List<Banner> getVisibleBanners() {
        return bannerRepository.findVisible(LocalDateTime.now());
    }

    public Page<Banner> searchBanners(String keyword, Pageable pageable) {
        return bannerRepository.searchByTitle(
                (keyword != null && !keyword.isEmpty()) ? keyword : null, pageable);
    }

    public Banner getBanner(Long bannerId) {
        return bannerRepository.findById(bannerId)
            .orElseThrow(() -> new IllegalArgumentException("배너를 찾을 수 없습니다."));
    }

    @Transactional
    public Long create(String imageUrl, String linkUrl, String title, int sortOrder,
                       boolean active, LocalDateTime startAt, LocalDateTime endAt) {
        Banner banner = Banner.builder()
            .imageUrl(imageUrl)
            .linkUrl(emptyToNull(linkUrl))
            .title(emptyToNull(title))
            .sortOrder(sortOrder)
            .active(active)
            .startAt(startAt)
            .endAt(endAt)
            .build();
        return bannerRepository.save(banner).getBannerId();
    }

    /**
     * 배너 수정. newImageUrl 이 null 이 아니면 이미지를 교체한다.
     * @return 교체로 버려진 이전 이미지 URL (교체가 없었으면 null). 호출 측이 Storage 정리에 사용한다.
     */
    @Transactional
    public String update(Long bannerId, String newImageUrl, String linkUrl, String title,
                         int sortOrder, boolean active, LocalDateTime startAt, LocalDateTime endAt) {
        Banner banner = getBanner(bannerId);
        String discardedImageUrl = null;
        if (newImageUrl != null) {
            discardedImageUrl = banner.getImageUrl();
            banner.changeImageUrl(newImageUrl);
        }
        banner.update(emptyToNull(linkUrl), emptyToNull(title), sortOrder, active, startAt, endAt);
        return discardedImageUrl;
    }

    /**
     * 배너 삭제.
     * @return 삭제된 배너의 이미지 URL (호출 측이 Storage 파일 정리에 사용한다).
     */
    @Transactional
    public String delete(Long bannerId) {
        Banner banner = getBanner(bannerId);
        String imageUrl = banner.getImageUrl();
        bannerRepository.delete(banner);
        return imageUrl;
    }

    private String emptyToNull(String value) {
        return (value == null || value.isBlank()) ? null : value;
    }
}
