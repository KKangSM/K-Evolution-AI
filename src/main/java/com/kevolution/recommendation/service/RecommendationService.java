package com.kevolution.recommendation.service;

import com.kevolution.ai.service.AiService;
import com.kevolution.member.entity.Member;
import com.kevolution.member.repository.MemberRepository;
import com.kevolution.order.entity.Order;
import com.kevolution.order.repository.OrderItemRepository;
import com.kevolution.product.entity.Category;
import com.kevolution.product.entity.Product;
import com.kevolution.product.repository.ProductRepository;
import com.kevolution.product.service.ProductService;
import com.kevolution.recommendation.dto.RecommendedProduct;
import com.kevolution.recommendation.entity.RecommendationCache;
import com.kevolution.recommendation.repository.RecommendationCacheRepository;
import com.kevolution.wishlist.repository.WishlistRepository;

import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.EnumMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * 개인화 추천 — 회원의 구매/찜 이력에서 "카테고리 선호도"를 계산해
 * 선호 카테고리의 인기상품을 추천한다. 이력이 없거나 비로그인이면 인기상품으로 폴백한다.
 * (새 테이블 없이 기존 주문/찜 데이터만 사용)
 */
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
@Slf4j
public class RecommendationService {

    // 카테고리 선호도 가중치: 실제 구매가 찜보다 강한 신호다.
    private static final int WEIGHT_PURCHASE = 3;
    private static final int WEIGHT_WISHLIST = 1;
    // 선호 상위 몇 개 카테고리까지 추천에 사용할지
    private static final int TOP_CATEGORIES = 3;

    // LLM 이 그 안에서 고를 후보 상품 수(추천 노출 수보다 넉넉히 뽑아 선택지를 준다)
    private static final int CANDIDATE_POOL = 16;
    // LLM 추천 캐시 유효 시간(시간). 이 안에는 재호출 없이 캐시 사용(비용 관리).
    private static final int CACHE_TTL_HOURS = 12;
    // 프로필에 넣을 최근 구매/찜 상품 수
    private static final int PROFILE_ITEMS = 5;

    private final MemberRepository memberRepository;
    private final OrderItemRepository orderItemRepository;
    private final WishlistRepository wishlistRepository;
    private final ProductRepository productRepository;
    private final ProductService productService;
    private final RecommendationCacheRepository recommendationCacheRepository;
    private final AiService aiService;
    private final ObjectMapper objectMapper;

    /**
     * 메인·마이페이지용 개인화 추천 목록.
     * 로그인 회원의 선호 카테고리 인기상품(이미 산 상품 제외)을 채우고,
     * 개수가 모자라면 전체 인기상품으로 보충한다. 신호가 전혀 없으면 인기상품만 반환한다.
     */
    public List<Product> getPersonalized(String userId, int size) {
        Member member = (userId == null) ? null : memberRepository.findByUserId(userId).orElse(null);
        return ruleBasedPool(member, size);
    }

    /**
     * LLM 기반 개인화 추천(마이페이지). 흐름:
     *   ① 캐시가 최신이면 그대로 사용(LLM 재호출 없음)
     *   ② 규칙 기반으로 후보 상품 풀을 뽑고(= LLM 이 이 안에서만 고르게 해 환각 방지)
     *   ③ 고객 프로필 + 후보를 LLM 에 주고 선별 + 추천 이유를 받아
     *   ④ LLM 이 고른 순서대로 상품을 매핑해 캐시에 저장 후 반환
     * 키 미설정·호출/파싱 실패 시엔 규칙 기반 결과로 폴백한다(이유 없이).
     */
    @Transactional
    public List<RecommendedProduct> getPersonalizedWithReasons(String userId, int size) {
        Member member = (userId == null) ? null : memberRepository.findByUserId(userId).orElse(null);

        // ① 캐시 사용 (회원 + 유효기간 내)
        if (member != null) {
            RecommendationCache cache = recommendationCacheRepository.findById(userId).orElse(null);
            if (cache != null && cache.isFresh(CACHE_TTL_HOURS)) {
                List<RecommendedProduct> cached = fromCache(cache.getPayload(), size);
                if (!cached.isEmpty()) return cached;
            }
        }

        // ② 규칙 기반 후보 풀
        List<Product> candidates = ruleBasedPool(member, CANDIDATE_POOL);

        // ③ LLM 선별 + 이유 (회원·후보 있을 때만 시도)
        LinkedHashMap<Long, String> picked = (member == null || candidates.isEmpty()) ? null
                : aiService.recommendPersonalized(buildProfile(member), buildCandidateList(candidates), size);

        // ④ 실패/미설정 → 규칙 기반 폴백(이유 없음)
        if (picked == null) {
            return withoutReasons(candidates, size);
        }

        Map<Long, Product> byId = candidates.stream()
                .collect(Collectors.toMap(Product::getProductId, p -> p, (a, b) -> a));
        List<RecommendedProduct> result = new ArrayList<>();
        for (Map.Entry<Long, String> e : picked.entrySet()) {
            Product p = byId.get(e.getKey());
            if (p != null && result.size() < size) {
                result.add(new RecommendedProduct(p, e.getValue()));
            }
        }
        if (result.isEmpty()) {
            return withoutReasons(candidates, size);
        }
        saveCache(userId, result);
        return result;
    }

    /** 규칙 기반 추천 풀: 선호 카테고리 인기상품(구매분 제외) → 부족분은 전체 인기상품으로 보충. */
    private List<Product> ruleBasedPool(Member member, int size) {
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

    // ── LLM 추천 도우미 ─────────────────────────────

    /** 후보를 이유 없이 RecommendedProduct 로 감싼다(폴백용). */
    private List<RecommendedProduct> withoutReasons(List<Product> candidates, int size) {
        return candidates.stream().limit(size)
                .map(p -> new RecommendedProduct(p, null))
                .toList();
    }

    /** LLM 에 줄 고객 프로필 텍스트: 선호 카테고리 + 최근 구매/찜 상품명. */
    private String buildProfile(Member member) {
        StringBuilder sb = new StringBuilder();

        List<Category> preferred = preferredCategories(member);
        if (!preferred.isEmpty()) {
            sb.append("- 선호 카테고리: ")
              .append(preferred.stream().map(Category::getLabel).collect(Collectors.joining(", ")))
              .append("\n");
        }

        List<Long> purchasedIds = orderItemRepository.findPurchasedProductIds(member, Order.Status.PAID);
        if (!purchasedIds.isEmpty()) {
            String names = productRepository.findAllById(purchasedIds).stream()
                    .limit(PROFILE_ITEMS).map(Product::getName).collect(Collectors.joining(", "));
            if (!names.isBlank()) sb.append("- 최근 구매: ").append(names).append("\n");
        }

        String wished = wishlistRepository.findByMemberOrderByCreatedAtDesc(member).stream()
                .limit(PROFILE_ITEMS).map(w -> w.getProduct().getName()).collect(Collectors.joining(", "));
        if (!wished.isBlank()) sb.append("- 찜한 상품: ").append(wished).append("\n");

        return sb.length() == 0 ? "(이력 정보 없음)" : sb.toString();
    }

    /** LLM 에 줄 후보 상품 목록 텍스트("- id 123 / 상품명 / 카테고리 / 가격원"). */
    private String buildCandidateList(List<Product> candidates) {
        StringBuilder sb = new StringBuilder();
        for (Product p : candidates) {
            sb.append(String.format("- id %d / %s / %s / %,d원%n",
                    p.getProductId(), p.getName(),
                    p.getCategory() == null ? "미지정" : p.getCategory().getLabel(),
                    p.getPrice()));
        }
        return sb.toString();
    }

    /** 캐시 JSON([{id,reason}])을 상품과 매핑해 복원한다. 상품이 지워졌으면 건너뛴다. */
    private List<RecommendedProduct> fromCache(String payload, int size) {
        List<RecommendedProduct> result = new ArrayList<>();
        try {
            List<CacheItem> items = objectMapper.readValue(payload,
                    objectMapper.getTypeFactory().constructCollectionType(List.class, CacheItem.class));
            Map<Long, Product> byId = productRepository.findAllById(
                    items.stream().map(CacheItem::id).toList()).stream()
                    .collect(Collectors.toMap(Product::getProductId, p -> p, (a, b) -> a));
            for (CacheItem item : items) {
                Product p = byId.get(item.id());
                if (p != null && result.size() < size) {
                    result.add(new RecommendedProduct(p, item.reason()));
                }
            }
        } catch (Exception e) {
            log.warn("추천 캐시 복원 실패 - 재생성으로 진행", e);
            return List.of();
        }
        return result;
    }

    /** 추천 결과를 JSON 으로 직렬화해 캐시에 저장(있으면 갱신). */
    private void saveCache(String userId, List<RecommendedProduct> result) {
        try {
            List<CacheItem> items = result.stream()
                    .map(r -> new CacheItem(r.product().getProductId(), r.reason()))
                    .toList();
            String payload = objectMapper.writeValueAsString(items);
            recommendationCacheRepository.findById(userId)
                    .ifPresentOrElse(
                            c -> c.update(payload),
                            () -> recommendationCacheRepository.save(
                                    RecommendationCache.builder().userId(userId).payload(payload).build()));
        } catch (Exception e) {
            log.warn("추천 캐시 저장 실패 - 결과는 그대로 반환", e);
        }
    }

    /** 캐시 JSON 직렬화용 항목. */
    private record CacheItem(Long id, String reason) {}
}
