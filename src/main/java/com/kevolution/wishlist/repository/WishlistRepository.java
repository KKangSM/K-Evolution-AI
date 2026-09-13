package com.kevolution.wishlist.repository;

import com.kevolution.member.entity.Member;
import com.kevolution.product.entity.Product;
import com.kevolution.wishlist.entity.Wishlist;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface WishlistRepository extends JpaRepository<Wishlist, Long> {
    List<Wishlist> findByMemberOrderByCreatedAtDesc(Member member);
    Optional<Wishlist> findByMemberAndProduct(Member member, Product product);
    boolean existsByMemberAndProduct(Member member, Product product);
    long countByProduct(Product product);

    /**
     * 회원이 찜한 상품들의 카테고리별 건수 — 개인화 추천의 카테고리 선호도 계산용.
     * 반환: Object[]{ Category, Long count }
     */
    @Query("SELECT w.product.category, COUNT(w) FROM Wishlist w " +
           "WHERE w.member = :member AND w.product.category IS NOT NULL " +
           "GROUP BY w.product.category")
    List<Object[]> countCategoriesByMember(@Param("member") Member member);
}
