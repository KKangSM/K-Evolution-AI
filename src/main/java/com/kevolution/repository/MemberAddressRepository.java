package com.kevolution.repository;

import com.kevolution.entity.Member;
import com.kevolution.entity.MemberAddress;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface MemberAddressRepository extends JpaRepository<MemberAddress, Long> {
    List<MemberAddress> findByMember(Member member);
    Optional<MemberAddress> findByMemberAndDefaultAddressTrue(Member member);
}
