package com.kevolution.repository;

import com.kevolution.entity.Member;
import com.kevolution.entity.Product;
import com.kevolution.entity.Qna;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface QnaRepository extends JpaRepository<Qna, Long> {
    Page<Qna> findByProductOrderByCreatedAtDesc(Product product, Pageable pageable);
    List<Qna> findByMemberOrderByCreatedAtDesc(Member member);
    Page<Qna> findAllByOrderByCreatedAtDesc(Pageable pageable);
    Page<Qna> findByMemberOrderByCreatedAtDesc(Member member, Pageable pageable);

    // 대시보드: 미답변 문의 수
    long countByAnswerIsNull();
}
