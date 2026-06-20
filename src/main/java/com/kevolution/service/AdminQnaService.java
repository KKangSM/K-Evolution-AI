package com.kevolution.service;

import com.kevolution.entity.Qna;
import com.kevolution.repository.QnaRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class AdminQnaService {

    private final QnaRepository qnaRepository;

    public Page<Qna> getQnaList(Pageable pageable) {
        return qnaRepository.findAllByOrderByCreatedAtDesc(pageable);
    }

    public Qna getQna(Long qnaId) {
        return qnaRepository.findById(qnaId)
                .orElseThrow(() -> new IllegalArgumentException("문의를 찾을 수 없습니다."));
    }

    @Transactional
    public void answer(Long qnaId, String answer) {
        Qna qna = getQna(qnaId);
        qna.answer(answer);
    }

    public void delete(Long qnaId) {
        qnaRepository.deleteById(qnaId);
    }
}
