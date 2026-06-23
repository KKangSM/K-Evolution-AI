package com.kevolution.returnrequest.repository;

import com.kevolution.member.entity.Member;
import com.kevolution.returnrequest.entity.ReturnRequest;

import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface ReturnRequestRepository extends JpaRepository<ReturnRequest, Long> {
    List<ReturnRequest> findByMemberOrderByCreatedAtDesc(Member member);
}
