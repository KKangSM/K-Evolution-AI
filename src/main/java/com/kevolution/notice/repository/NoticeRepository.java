package com.kevolution.notice.repository;

import com.kevolution.notice.entity.Notice;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface NoticeRepository extends JpaRepository<Notice, Long> {
    /** 목록: 최신순 */
    Page<Notice> findAllByOrderByCreatedAtDesc(Pageable pageable);
    /** 메인 마퀴: 최신 5건 */
    List<Notice> findTop5ByOrderByCreatedAtDesc();
}
