package com.kevolution.cart.repository;

import com.kevolution.cart.entity.Cart;
import com.kevolution.member.entity.Member;

import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;

public interface CartRepository extends JpaRepository<Cart, Long> {
    Optional<Cart> findByMember(Member member);
}
