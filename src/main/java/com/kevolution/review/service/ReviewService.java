package com.kevolution.review.service;

import com.kevolution.ai.service.AiService;
import com.kevolution.member.entity.Member;
import com.kevolution.member.repository.MemberRepository;
import com.kevolution.order.entity.Order;
import com.kevolution.order.entity.OrderItem;
import com.kevolution.order.repository.OrderItemRepository;
import com.kevolution.product.entity.Product;
import com.kevolution.review.entity.Review;
import com.kevolution.review.entity.ReviewImage;
import com.kevolution.review.entity.ReviewSummary;
import com.kevolution.review.repository.ReviewImageRepository;
import com.kevolution.review.repository.ReviewRepository;
import com.kevolution.review.repository.ReviewSummaryRepository;
import com.kevolution.storage.SupabaseStorageService;

import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.util.HashSet;
import java.util.List;
import java.util.Set;

/**
 * 상품 리뷰 서비스 — 상품 상세 노출용 조회와 회원 본인의 작성·수정·삭제를 담당한다.
 * 리뷰는 구매(결제완료)한 주문상품(order_item) 기준으로 작성하며, 주문상품당 1건으로 제한한다.
 */
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class ReviewService {

    /** 리뷰당 첨부 이미지 최대 장수 */
    private static final int MAX_IMAGES = 5;

    /** 요약을 생성하기 위한 최소 리뷰 수 (너무 적으면 요약 의미가 없음) */
    private static final int MIN_REVIEWS_FOR_SUMMARY = 3;
    /** 마지막 요약 이후 리뷰가 이만큼 늘면 다시 요약한다 */
    private static final int REGENERATE_EVERY = 5;
    /** 요약에 반영할 최근 리뷰 수 */
    private static final int SUMMARY_SAMPLE_SIZE = 30;

    private final ReviewRepository reviewRepository;
    private final ReviewImageRepository reviewImageRepository;
    private final OrderItemRepository orderItemRepository;
    private final MemberRepository memberRepository;
    private final SupabaseStorageService storageService;
    private final ReviewSummaryRepository reviewSummaryRepository;
    private final AiService aiService;

    // ── 상품 상세 노출용 ──────────────────────────────
    public Page<Review> getProductReviews(Product product, Pageable pageable) {
        return reviewRepository.findByProductOrderByCreatedAtDesc(product, pageable);
    }

    public long countByProduct(Product product) {
        return reviewRepository.countByProduct(product);
    }

    /** 평균 별점 (소수 첫째자리 반올림). 리뷰가 없으면 0 */
    public double averageRating(Product product) {
        Double avg = reviewRepository.averageRatingByProduct(product);
        return avg == null ? 0 : Math.round(avg * 10) / 10.0;
    }

    /**
     * 상품 상세용 AI 리뷰 요약. 저장된 요약을 재사용하고, 리뷰가 충분히 늘었을 때만 다시 생성한다.
     * 리뷰가 적거나(임계치 미만) AI 미설정/실패면 null 을 반환한다(화면에서 요약 영역 숨김).
     * (쓰기가 있어 클래스 기본 readOnly 를 이 메서드에서 해제한다. AI 호출은 캐시 미스 때만 발생)
     */
    @Transactional
    public String getReviewSummary(Product product) {
        long count = reviewRepository.countByProduct(product);
        if (count < MIN_REVIEWS_FOR_SUMMARY) return null;

        ReviewSummary cached = reviewSummaryRepository.findById(product.getProductId()).orElse(null);
        if (cached != null && count - cached.getReviewCount() < REGENERATE_EVERY) {
            return cached.getSummary(); // 최신이면 캐시 그대로 사용 (API 호출 없음)
        }

        List<String> contents = reviewRepository
                .findByProductOrderByCreatedAtDesc(product, PageRequest.of(0, SUMMARY_SAMPLE_SIZE))
                .getContent().stream()
                .map(r -> "[" + r.getRating() + "점] " + (r.getContent() == null ? "" : r.getContent().trim()))
                .filter(s -> s.length() > 4)
                .toList();

        String summary = aiService.summarizeReviews(contents);
        if (summary == null || summary.isBlank()) {
            return cached == null ? null : cached.getSummary(); // 실패 시 있으면 옛 요약 유지
        }

        if (cached == null) {
            reviewSummaryRepository.save(ReviewSummary.builder()
                    .productId(product.getProductId())
                    .summary(summary)
                    .reviewCount((int) count)
                    .build());
        } else {
            cached.update(summary, (int) count);
        }
        return summary;
    }

    // ── 주문내역 표시용 ────────────────────────────────
    /** 회원이 이미 리뷰를 작성한 주문상품 ID 집합 (주문내역에서 버튼 상태 분기용) */
    public Set<Long> getReviewedOrderItemIds(String userId) {
        return new HashSet<>(reviewRepository.findReviewedOrderItemIds(userId));
    }

    // ── 작성 ──────────────────────────────────────────
    /** 리뷰 작성 화면에서 쓸, 본인이 구매(결제완료)했고 아직 리뷰가 없는 주문상품을 검증해 반환한다. */
    public OrderItem getWritableOrderItem(String userId, Long orderItemId) {
        OrderItem item = orderItemRepository.findById(orderItemId)
                .orElseThrow(() -> new IllegalArgumentException("주문 상품을 찾을 수 없습니다."));
        Order order = item.getOrder();
        if (!order.getMember().getUserId().equals(userId)) {
            throw new IllegalArgumentException("본인이 구매한 상품만 리뷰를 작성할 수 있습니다.");
        }
        if (order.getStatus() != Order.Status.PAID) {
            throw new IllegalArgumentException("결제 완료된 상품만 리뷰를 작성할 수 있습니다.");
        }
        if (reviewRepository.existsByOrderItem(item)) {
            throw new IllegalArgumentException("이미 리뷰를 작성한 상품입니다.");
        }
        return item;
    }

    @Transactional
    public void writeReview(String userId, Long orderItemId, int rating, String content, List<MultipartFile> images) {
        OrderItem item = getWritableOrderItem(userId, orderItemId);
        Member member = memberRepository.findByUserId(userId)
                .orElseThrow(() -> new IllegalArgumentException("회원을 찾을 수 없습니다."));
        validateRating(rating);

        Review review = Review.builder()
                .product(item.getProduct())
                .member(member)
                .orderItem(item)
                .rating(rating)
                .content(content)
                .build();

        addImages(review, images);
        reviewRepository.save(review); // cascade 로 첨부 이미지도 함께 저장
    }

    // ── 내 리뷰 관리 ──────────────────────────────────
    public List<Review> getMyReviews(String userId) {
        Member member = memberRepository.findByUserId(userId)
                .orElseThrow(() -> new IllegalArgumentException("회원을 찾을 수 없습니다."));
        return reviewRepository.findByMemberOrderByCreatedAtDesc(member);
    }

    @Transactional
    public void updateReview(Long reviewId, String userId, int rating, String content) {
        Review review = loadOwnedReview(reviewId, userId);
        validateRating(rating);
        review.update(rating, content);
    }

    @Transactional
    public void deleteReview(Long reviewId, String userId) {
        Review review = loadOwnedReview(reviewId, userId);
        List<String> urls = review.getImages().stream().map(ReviewImage::getImageUrl).toList();
        reviewRepository.delete(review); // cascade + orphanRemoval 로 이미지 row 도 삭제
        urls.forEach(storageService::deleteByPublicUrl); // 스토리지 파일 정리(best-effort)
    }

    // ── 내부 ──────────────────────────────────────────
    private Review loadOwnedReview(Long reviewId, String userId) {
        Review review = reviewRepository.findById(reviewId)
                .orElseThrow(() -> new IllegalArgumentException("리뷰를 찾을 수 없습니다."));
        if (!review.getMember().getUserId().equals(userId)) {
            throw new IllegalArgumentException("본인이 작성한 리뷰만 관리할 수 있습니다.");
        }
        return review;
    }

    /** 첨부 이미지를 Storage 에 올려 리뷰에 붙인다. 빈 파일은 건너뛰고 최대 MAX_IMAGES 장까지. */
    private void addImages(Review review, List<MultipartFile> images) {
        if (images == null) return;
        int order = 0;
        for (MultipartFile file : images) {
            if (file == null || file.isEmpty()) continue;
            if (order >= MAX_IMAGES) break;
            String url = storageService.upload(file, "review");
            review.getImages().add(ReviewImage.builder()
                    .review(review)
                    .imageUrl(url)
                    .sortOrder(order++)
                    .build());
        }
    }

    private void validateRating(int rating) {
        if (rating < 1 || rating > 5) {
            throw new IllegalArgumentException("별점은 1~5점 사이여야 합니다.");
        }
    }
}
