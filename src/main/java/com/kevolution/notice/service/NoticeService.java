package com.kevolution.notice.service;

import com.kevolution.notice.entity.Notice;
import com.kevolution.notice.repository.NoticeRepository;

import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * 공지사항 단일 서비스 — 조회(공개)와 관리(CRUD)를 모두 담당한다.
 * 권한 구분은 호출 측 URL(SecurityConfig)에서만 다루므로, 서비스 이름에 권한 단계를 박지 않는다.
 */
@Service
@RequiredArgsConstructor
public class NoticeService {

    private final NoticeRepository noticeRepository;

    public Page<Notice> getNotices(Pageable pageable) {
        return noticeRepository.findAllByOrderByCreatedAtDesc(pageable);
    }

    public Notice getNotice(Long noticeId) {
        Notice notice = noticeRepository.findById(noticeId)
                .orElseThrow(() -> new IllegalArgumentException("공지사항을 찾을 수 없습니다."));
        notice.increaseViewCount();
        return notice;
    }

    /** 모달 조회 시 조회수만 1 증가 (없는 ID는 조용히 무시) */
    @Transactional
    public void increaseViewCount(Long noticeId) {
        noticeRepository.findById(noticeId).ifPresent(Notice::increaseViewCount);
    }

    @Transactional
    public void create(String title, String content, String imageUrl) {
        noticeRepository.save(Notice.builder()
                .title(title)
                .content(content)
                .imageUrl(imageUrl)
                .build());
    }

    /**
     * 공지 수정. newImageUrl 이 null 이 아니면 이미지를 교체한다.
     * @return 교체로 버려진 이전 이미지 URL (교체 없으면 null) — 호출 측 Storage 정리용
     */
    @Transactional
    public String update(Long noticeId, String title, String content, String newImageUrl) {
        Notice notice = noticeRepository.findById(noticeId)
                .orElseThrow(() -> new IllegalArgumentException("공지사항을 찾을 수 없습니다."));
        String discardedImageUrl = null;
        if (newImageUrl != null) {
            discardedImageUrl = notice.getImageUrl();
            notice.changeImageUrl(newImageUrl);
        }
        notice.update(title, content);
        return discardedImageUrl;
    }

    /** @return 삭제된 공지의 이미지 URL (Storage 정리용) */
    @Transactional
    public String delete(Long noticeId) {
        Notice notice = noticeRepository.findById(noticeId)
                .orElseThrow(() -> new IllegalArgumentException("공지사항을 찾을 수 없습니다."));
        String imageUrl = notice.getImageUrl();
        noticeRepository.delete(notice);
        return imageUrl;
    }
}
