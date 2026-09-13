package com.kevolution.recommendation.service;

import com.kevolution.member.entity.Member;
import com.kevolution.member.repository.MemberRepository;
import com.kevolution.order.entity.Order;
import com.kevolution.order.repository.OrderItemRepository;
import com.kevolution.product.entity.Category;
import com.kevolution.product.entity.Product;
import com.kevolution.product.repository.ProductRepository;
import com.kevolution.product.service.ProductService;
import com.kevolution.wishlist.repository.WishlistRepository;

import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.EnumMap;
import java.util.List;
import java.util.Map;

/**
 * 개인화 추천 — 회원의 구매/찜 이력에서 "카테고리 선호도"를 계산해
 * 선호 카테고리의 인기상품을 추천한다. 이력이 없거나 비로그인이면 인기상품으로 폴백한다.
 * (새 테이블 없이 기존 주문/찜 데이터만 사용)
 */
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class RecommendationService {

    // 카테고리 선호도 가중치: 실제 구매가 찜보다 강한 신호다.
    private static final int WEIGHT_PURCHASE = 3;
    private static final int WEIGHT_WISHLIST = 1;
    // 선호 상위 몇 개 카테고리까지 추천에 사용할지
    private static final int TOP_CATEGORIES = 3;

    private final MemberRepository memberRepository;
    private final OrderItemRepository orderItemRepository;
    private final WishlistRepository wishlistRepository;
    private final ProductRepository productRepository;
    private final ProductService productService;

    /**
     * 메인·마이페이지용 개인화 추천 목록.
     * 로그인 회원의 선호 카테고리 인기상품(이미 산 상품 제외)을 채우고,
     * 개수가 모자라면 전체 인기상품으로 보충한다. 신호가 전혀 없으면 인기상품만 반환한다.
     */
    public List<Product> getPersonalized(String userId, int size) {
        Member member = (userId == null) ? null : memberRepository.findByUserId(userId).orElse(null);
        if (member == null) {
            return productService.getPopularProducts(size);
        }

        List<Category> preferred = preferredCategories(member);
        List<Long> purchasedIds = orderItemRepository.findPurchasedProductIds(member, Order.Status.PAID);

        List<Product> result = new ArrayList<>();
        if (!preferred.isEmpty()) {
            result.addAll(productRepository.findPopularInCategories(
                    preferred, safeExclude(purchasedIds), PageRequest.of(0, size)));
        }
        // 선호 카테고리 상품이 부족하면 전체 인기상품으로 보충한다. (이미 담긴 상품·구매 상품은 제외)
        if (result.size() < size) {
            fillUp(result, productService.getPopularProducts(size * 2), size, purchasedIds);
        }
        return result.size() > size ? result.subList(0, size) : result;
    }

    /** 상품 상세 "연관 상품" — 같은 카테고리 인기상품(현재 상품 제외). 카테고리가 없으면 인기상품으로 폴백. */
    public List<Product> getRelated(Product product, int size) {
        List<Product> related = new ArrayList<>();
        if (product.getCategory() != null) {
            related.addAll(productRepository.findRelatedInCategory(
                    product.getCategory(), product.getProductId(), PageRequest.of(0, size)));
        }
        // 같은 카테고리 상품이 부족하면(또는 카테고리가 없으면) 전체 인기상품으로 보충한다.
        if (related.size() < size) {
            fillUp(related, productService.getPopularProducts(size * 2), size, List.of(product.getProductId()));
        }
        return related.size() > size ? related.subList(0, size) : related;
    }

    // ── 내부 도우미 ─────────────────────────────

    /** 구매(가중치 3) + 찜(가중치 1) 카테고리 점수를 합산해 상위 카테고리를 뽑는다. */
    private List<Category> preferredCategories(Member member) {
        Map<Category, Integer> score = new EnumMap<>(Category.class);
        for (Object[] row : orderItemRepository.countCategoriesByMember(member, Order.Status.PAID)) {
            addScore(score, (Category) row[0], ((Number) row[1]).intValue() * WEIGHT_PURCHASE);
        }
        for (Object[] row : wishlistRepository.countCategoriesByMember(member)) {
            addScore(score, (Category) row[0], ((Number) row[1]).intValue() * WEIGHT_WISHLIST);
        }
        return score.entrySet().stream()
                .sorted(Map.Entry.<Category, Integer>comparingByValue().reversed())
                .limit(TOP_CATEGORIES)
                .map(Map.Entry::getKey)
                .toList();
    }

    private void addScore(Map<Category, Integer> score, Category category, int delta) {
        if (category == null) return;
        score.merge(category, delta, Integer::sum);
    }

    /** target 이 size 에 찰 때까지 candidates 에서 채운다. (중복·제외 상품은 건너뜀) */
    private void fillUp(List<Product> target, List<Product> candidates, int size, List<Long> excludeIds) {
        for (Product p : candidates) {
            if (target.size() >= size) break;
            Long id = p.getProductId();
            if (excludeIds.contains(id)) continue;
            if (target.stream().anyMatch(r -> r.getProductId().equals(id))) continue;
            target.add(p);
        }
    }

    /** JPQL "NOT IN" 은 빈 목록이면 오류가 나므로 최소 1개(존재할 수 없는 ID)를 넣어 안전하게 만든다. */
    private List<Long> safeExclude(List<Long> ids) {
        return (ids == null || ids.isEmpty()) ? List.of(-1L) : ids;
    }
}
