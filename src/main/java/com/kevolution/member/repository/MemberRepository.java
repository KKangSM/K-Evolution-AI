package com.kevolution.member.repository;

import com.kevolution.member.entity.Member;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import java.util.List;
import java.util.Optional;

public interface MemberRepository extends JpaRepository<Member, String> {
    Optional<Member> findByUserId(String userId);
    boolean existsByUserId(String userId);
    Page<Member> findByRoleNot(Member.Role role, Pageable pageable);

    /** 특정 상태·권한의 회원 전체 (쿠폰 일괄 발급 대상 조회용) */
    List<Member> findByStatusAndRole(Member.Status status, Member.Role role);

    // 검색: 아이디/이름 + 필터. excludeRole 이 있으면 해당 권한(Admin 요청 시 SYSTEM)을 쿼리에서 제외한다.
    @Query("SELECT m FROM Member m WHERE " +
           "(:keyword IS NULL OR m.userId LIKE %:keyword% OR m.name LIKE %:keyword%) AND " +
           "(:role IS NULL OR m.role = :role) AND " +
           "(:status IS NULL OR m.status = :status) AND " +
           "(:excludeRole IS NULL OR m.role <> :excludeRole) " +
           "ORDER BY m.createdAt DESC")
    Page<Member> searchMembers(
        @Param("keyword") String keyword,
        @Param("role") Member.Role role,
        @Param("status") Member.Status status,
        @Param("excludeRole") Member.Role excludeRole,
        Pageable pageable
    );
}
