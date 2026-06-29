package com.kevolution.member.repository;

import com.kevolution.member.entity.Member;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;

public interface MemberRepository extends JpaRepository<Member, String> {
    Optional<Member> findByUserId(String userId);
    boolean existsByUserId(String userId);
    Page<Member> findByRoleNot(Member.Role role, Pageable pageable);
}
