package com.kevolution.qna.repository;

import com.kevolution.member.entity.Member;
import com.kevolution.product.entity.Product;
import com.kevolution.qna.entity.Qna;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface QnaRepository extends JpaRepository<Qna, Long> {
    Page<Qna> findByProductOrderByCreatedAtDesc(Product product, Pageable pageable);
    List<Qna> findByMemberOrderByCreatedAtDesc(Member member);
    Page<Qna> findAllByOrderByCreatedAtDesc(Pageable pageable);
    Page<Qna> findByMemberOrderByCreatedAtDesc(Member member, Pageable pageable);

    // 대시보드: 미답변 문의 수
    long countByAnswerIsNull();

    // 검색: 제목/내용 + 필터 (관리자용)
    // answerRead: 답변이 등록된 문의 중 고객 열람 여부. true=확인함, false=답변완료·미열람
    @Query("SELECT q FROM Qna q WHERE " +
           "(:keyword IS NULL OR q.title LIKE %:keyword% OR q.content LIKE %:keyword%) AND " +
           "(:hasAnswer IS NULL " +
           "  OR (:hasAnswer = true AND q.answer IS NOT NULL) " +
           "  OR (:hasAnswer = false AND q.answer IS NULL)) AND " +
           "(:answerRead IS NULL " +
           "  OR (:answerRead = true AND q.answerReadAt IS NOT NULL) " +
           "  OR (:answerRead = false AND q.answer IS NOT NULL AND q.answerReadAt IS NULL)) AND " +
           "(:productOnly IS NULL " +
           "  OR (:productOnly = true AND q.product IS NOT NULL) " +
           "  OR (:productOnly = false AND q.product IS NULL)) " +
           "ORDER BY q.createdAt DESC")
    Page<Qna> searchQna(
        @Param("keyword") String keyword,
        @Param("hasAnswer") Boolean hasAnswer,
        @Param("answerRead") Boolean answerRead,
        @Param("productOnly") Boolean productOnly,
        Pageable pageable
    );
}
