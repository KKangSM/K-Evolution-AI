package com.kevolution.notice.service;

import com.kevolution.config.SecurityConfig;
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
        return noticeRepository.findAllByOrderByPinnedDescCreatedAtDesc(pageable);
    }

    public Notice getNotice(Long noticeId) {
        Notice notice = noticeRepository.findById(noticeId)
                .orElseThrow(() -> new IllegalArgumentException("공지사항을 찾을 수 없습니다."));
        notice.increaseViewCount();
        return notice;
    }

    @Transactional
    public void create(String title, String content, boolean pinned, boolean marquee) {
        noticeRepository.save(Notice.builder()
                .title(title)
                .content(content)
                .pinned(pinned)
                .marquee(marquee)
                .build());
    }

    @Transactional
    public void update(Long noticeId, String title, String content, boolean pinned, boolean marquee) {
        Notice notice = noticeRepository.findById(noticeId)
                .orElseThrow(() -> new IllegalArgumentException("공지사항을 찾을 수 없습니다."));
        notice.update(title, content, pinned, marquee);
    }

    @Transactional
    public void delete(Long noticeId) {
        noticeRepository.findById(noticeId)
                .orElseThrow(() -> new IllegalArgumentException("공지사항을 찾을 수 없습니다."));
        noticeRepository.deleteById(noticeId);
    }
}
