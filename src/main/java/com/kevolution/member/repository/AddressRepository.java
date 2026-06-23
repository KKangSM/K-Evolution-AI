package com.kevolution.member.repository;

import com.kevolution.member.entity.Address;
import com.kevolution.member.entity.Member;

import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface AddressRepository extends JpaRepository<Address, Long> {
    List<Address> findByMember(Member member);
    Optional<Address> findByMemberAndDefaultAddressTrue(Member member);
}
