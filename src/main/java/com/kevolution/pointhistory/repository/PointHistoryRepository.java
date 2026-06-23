package com.kevolution.pointhistory.repository;

import com.kevolution.member.entity.Member;
import com.kevolution.pointhistory.entity.PointHistory;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

public interface PointHistoryRepository extends JpaRepository<PointHistory, Long> {
    Page<PointHistory> findByMemberOrderByCreatedAtDesc(Member member, Pageable pageable);
    PointHistory findFirstByMemberOrderByCreatedAtDesc(Member member);
}
