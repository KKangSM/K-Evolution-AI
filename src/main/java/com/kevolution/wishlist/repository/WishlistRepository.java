package com.kevolution.wishlist.repository;

import com.kevolution.member.entity.Member;
import com.kevolution.product.entity.Product;
import com.kevolution.wishlist.entity.Wishlist;

import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface WishlistRepository extends JpaRepository<Wishlist, Long> {
    List<Wishlist> findByMemberOrderByCreatedAtDesc(Member member);
    Optional<Wishlist> findByMemberAndProduct(Member member, Product product);
    boolean existsByMemberAndProduct(Member member, Product product);
    long countByProduct(Product product);
}
