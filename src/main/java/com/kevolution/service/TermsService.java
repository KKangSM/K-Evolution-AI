package com.kevolution.service;

import com.kevolution.entity.Terms;
import com.kevolution.repository.TermsRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.util.List;

@Service
@RequiredArgsConstructor
public class TermsService {

    private final TermsRepository termsRepository;

    public List<Terms> getActiveTerms() {
        return termsRepository.findAllByActiveTrueOrderByTypeAsc();
    }

    public List<Terms> getAllTerms() {
        return termsRepository.findAll();
    }

    public Terms getTerms(Long termId) {
        return termsRepository.findById(termId)
                .orElseThrow(() -> new IllegalArgumentException("약관을 찾을 수 없습니다."));
    }

    @Transactional
    public void upload(Terms.Type type, String title, boolean required, boolean active, MultipartFile file) throws IOException {
        String content = new String(file.getBytes(), StandardCharsets.UTF_8);
        Terms terms = Terms.builder()
                .type(type)
                .title(title)
                .content(content)
                .required(required)
                .active(active)
                .build();
        termsRepository.save(terms);
    }

    @Transactional
    public void update(Long termId, String title, boolean required, boolean active, MultipartFile file) throws IOException {
        Terms terms = getTerms(termId);
        String content = file != null && !file.isEmpty()
                ? new String(file.getBytes(), StandardCharsets.UTF_8)
                : terms.getContent();
        terms.update(title, content, required, active);
    }

    @Transactional
    public void delete(Long termId) {
        termsRepository.deleteById(termId);
    }
}
