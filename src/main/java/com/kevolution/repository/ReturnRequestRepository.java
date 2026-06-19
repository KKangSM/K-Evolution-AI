package com.kevolution.repository;

import com.kevolution.entity.Member;
import com.kevolution.entity.ReturnRequest;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface ReturnRequestRepository extends JpaRepository<ReturnRequest, Long> {
    List<ReturnRequest> findByMemberOrderByCreatedAtDesc(Member member);
}
