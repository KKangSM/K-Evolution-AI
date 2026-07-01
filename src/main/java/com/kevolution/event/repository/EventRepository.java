package com.kevolution.event.repository;

import com.kevolution.event.entity.Event;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDateTime;
import java.util.List;

public interface EventRepository extends JpaRepository<Event, Long> {

    /** 관리자 목록: 최신순 + 제목 검색 (keyword 가 null 이면 전체) */
    @Query("SELECT e FROM Event e WHERE " +
           "(:keyword IS NULL OR e.title LIKE %:keyword%) " +
           "ORDER BY e.createdAt DESC")
    Page<Event> searchByTitle(@Param("keyword") String keyword, Pageable pageable);

    /**
     * 공개 노출용: active=true 이고 현재 시각이 노출 기간 안에 있는 이벤트만.
     * startAt/endAt 이 null 이면 각각 상시로 취급. 최신 등록순.
     */
    @Query("SELECT e FROM Event e WHERE e.active = true " +
           "AND (e.startAt IS NULL OR e.startAt <= :now) " +
           "AND (e.endAt IS NULL OR e.endAt >= :now) " +
           "ORDER BY e.createdAt DESC")
    List<Event> findVisible(@Param("now") LocalDateTime now);
}
