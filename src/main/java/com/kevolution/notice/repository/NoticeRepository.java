package com.kevolution.notice.repository;

import com.kevolution.notice.entity.Notice;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface NoticeRepository extends JpaRepository<Notice, Long> {
    /** 목록: 최신순 */
    Page<Notice> findAllByOrderByCreatedAtDesc(Pageable pageable);
    /** 메인 마퀴: 최신 5건 */
    List<Notice> findTop5ByOrderByCreatedAtDesc();

    /** 관리자 목록: 제목 검색 (keyword 가 null 이면 전체) */
    @Query("SELECT n FROM Notice n WHERE " +
           "(:keyword IS NULL OR n.title LIKE %:keyword%) " +
           "ORDER BY n.createdAt DESC")
    Page<Notice> searchByTitle(@Param("keyword") String keyword, Pageable pageable);
}
