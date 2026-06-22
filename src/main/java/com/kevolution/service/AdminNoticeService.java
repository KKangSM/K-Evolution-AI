package com.kevolution.service;

import com.kevolution.entity.Notice;
import com.kevolution.repository.NoticeRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class AdminNoticeService {

    private final NoticeRepository noticeRepository;

    public Page<Notice> getNotices(Pageable pageable) {
        return noticeRepository.findAllByOrderByPinnedDescCreatedAtDesc(pageable);
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
