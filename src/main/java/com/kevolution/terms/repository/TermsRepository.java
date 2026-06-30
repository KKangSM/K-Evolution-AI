package com.kevolution.terms.repository;

import com.kevolution.terms.entity.Terms;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import java.util.List;

public interface TermsRepository extends JpaRepository<Terms, Long> {
    List<Terms> findAllByActiveTrueOrderByTypeAsc();

    // 검색: 제목 + 필터
    @Query("SELECT t FROM Terms t WHERE " +
           "(:keyword IS NULL OR t.title LIKE %:keyword%) AND " +
           "(:type IS NULL OR t.type = :type) AND " +
           "(:contentType IS NULL OR t.contentType = :contentType) AND " +
           "(:required IS NULL OR t.required = :required) AND " +
           "(:active IS NULL OR t.active = :active) " +
           "ORDER BY t.createdAt DESC")
    Page<Terms> searchTerms(
        @Param("keyword") String keyword,
        @Param("type") Terms.Type type,
        @Param("contentType") String contentType,
        @Param("required") Boolean required,
        @Param("active") Boolean active,
        Pageable pageable
    );
}
