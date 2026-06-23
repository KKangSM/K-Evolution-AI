package com.kevolution.notice.repository;

import com.kevolution.notice.entity.Notice;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface NoticeRepository extends JpaRepository<Notice, Long> {
    Page<Notice> findAllByOrderByPinnedDescCreatedAtDesc(Pageable pageable);
    List<Notice> findByMarqueeTrueOrderByCreatedAtDesc();
}
