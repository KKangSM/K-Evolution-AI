package com.kevolution.repository;

import com.kevolution.entity.Member;
import com.kevolution.entity.PointHistory;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

public interface PointHistoryRepository extends JpaRepository<PointHistory, Long> {
    Page<PointHistory> findByMemberOrderByCreatedAtDesc(Member member, Pageable pageable);
    PointHistory findFirstByMemberOrderByCreatedAtDesc(Member member);
}
