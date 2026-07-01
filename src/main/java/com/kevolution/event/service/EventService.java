package com.kevolution.event.service;

import com.kevolution.event.entity.Event;
import com.kevolution.event.repository.EventRepository;

import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 이벤트 단일 서비스 — 공개 조회와 관리(CRUD)를 모두 담당한다.
 * 권한 구분은 호출 측 URL(SecurityConfig)에서만 다루므로 서비스 이름에 권한 단계를 박지 않는다.
 */
@Service
@RequiredArgsConstructor
public class EventService {

    private final EventRepository eventRepository;

    // ── 관리자 목록/검색 ──────────────────────────
    public Page<Event> searchEvents(String keyword, Pageable pageable) {
        return eventRepository.searchByTitle(
                (keyword != null && !keyword.isEmpty()) ? keyword : null, pageable);
    }

    /** 배너 연결용 선택 목록 (활성/기간 무관 전체, 최신순) */
    public List<Event> getAllEvents() {
        return eventRepository.findAll(Sort.by("createdAt").descending());
    }

    // ── 공개 조회 ─────────────────────────────────
    /** 현재 시각 기준 노출중인 이벤트 목록 */
    public List<Event> getVisibleEvents() {
        return eventRepository.findVisible(LocalDateTime.now());
    }

    public Event getEvent(Long eventId) {
        return eventRepository.findById(eventId)
                .orElseThrow(() -> new IllegalArgumentException("이벤트를 찾을 수 없습니다."));
    }

    /** 상세 조회 시 조회수 1 증가 (없는 ID는 조용히 무시) */
    @Transactional
    public void increaseViewCount(Long eventId) {
        eventRepository.findById(eventId).ifPresent(Event::increaseViewCount);
    }

    // ── 관리 (CRUD) ───────────────────────────────
    @Transactional
    public void create(String title, String content, String imageUrl,
                       boolean active, LocalDateTime startAt, LocalDateTime endAt) {
        eventRepository.save(Event.builder()
                .title(title)
                .content(content)
                .imageUrl(imageUrl)
                .active(active)
                .startAt(startAt)
                .endAt(endAt)
                .build());
    }

    /**
     * 이벤트 수정. newImageUrl 이 null 이 아니면 이미지를 교체한다.
     * @return 교체로 버려진 이전 이미지 URL (교체 없으면 null) — 호출 측 Storage 정리용
     */
    @Transactional
    public String update(Long eventId, String title, String content, String newImageUrl,
                         boolean active, LocalDateTime startAt, LocalDateTime endAt) {
        Event event = getEvent(eventId);
        String discardedImageUrl = null;
        if (newImageUrl != null) {
            discardedImageUrl = event.getImageUrl();
            event.changeImageUrl(newImageUrl);
        }
        event.update(title, content, active, startAt, endAt);
        return discardedImageUrl;
    }

    /** @return 삭제된 이벤트의 이미지 URL (Storage 정리용) */
    @Transactional
    public String delete(Long eventId) {
        Event event = getEvent(eventId);
        String imageUrl = event.getImageUrl();
        eventRepository.delete(event);
        return imageUrl;
    }
}
