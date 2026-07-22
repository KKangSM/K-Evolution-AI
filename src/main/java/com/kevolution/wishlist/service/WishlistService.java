package com.kevolution.wishlist.service;

import com.kevolution.member.entity.Member;
import com.kevolution.member.repository.MemberRepository;
import com.kevolution.product.entity.Product;
import com.kevolution.product.service.ProductService;
import com.kevolution.wishlist.entity.Wishlist;
import com.kevolution.wishlist.repository.WishlistRepository;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

/**
 * 찜(위시리스트) 서비스. 회원+상품 조합은 유일하므로 toggle 로 담기/해제를 한 번에 처리한다.
 * 권한 구분은 호출 측 URL(SecurityConfig)에서만 다룬다.
 */
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class WishlistService {

    private final WishlistRepository wishlistRepository;
    private final MemberRepository memberRepository;
    private final ProductService productService;

    // ── 회원용 ────────────────────────────────────

    /** 찜 담기/해제 토글. 반환값 = 처리 후 찜 상태(true=담김). */
    @Transactional
    public boolean toggle(String userId, Long productId) {
        Member member = member(userId);
        Product product = productService.getProduct(productId);
        return wishlistRepository.findByMemberAndProduct(member, product)
                .map(w -> { wishlistRepository.delete(w); return false; })
                .orElseGet(() -> {
                    wishlistRepository.save(Wishlist.builder().member(member).product(product).build());
                    return true;
                });
    }

    public List<Wishlist> getMyWishlist(String userId) {
        return wishlistRepository.findByMemberOrderByCreatedAtDesc(member(userId));
    }

    @Transactional
    public void remove(String userId, Long productId) {
        Member member = member(userId);
        Product product = productService.getProduct(productId);
        wishlistRepository.findByMemberAndProduct(member, product)
                .ifPresent(wishlistRepository::delete);
    }

    // ── 조회 도우미 (상품 상세에서 사용) ──────────────

    /** 로그인하지 않았거나 회원을 못 찾으면 false. */
    public boolean isWished(String userId, Product product) {
        if (userId == null) return false;
        return memberRepository.findByUserId(userId)
                .map(m -> wishlistRepository.existsByMemberAndProduct(m, product))
                .orElse(false);
    }

    public long count(Product product) {
        return wishlistRepository.countByProduct(product);
    }

    private Member member(String userId) {
        return memberRepository.findByUserId(userId)
                .orElseThrow(() -> new IllegalArgumentException("회원을 찾을 수 없습니다."));
    }
}
