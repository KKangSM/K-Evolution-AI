package com.kevolution.terms.service;

import com.kevolution.terms.entity.Terms;
import com.kevolution.terms.repository.TermsRepository;
import com.kevolution.storage.SupabaseStorageService;

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

    private static final String TERMS_FOLDER = "terms";

    private final TermsRepository termsRepository;
    private final SupabaseStorageService storageService;

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
    public void upload(Terms.Type type, String title, boolean required, boolean active, MultipartFile file, String content) throws IOException {
        if ((file == null || file.isEmpty()) && (content == null || content.isBlank())) {
            throw new IllegalArgumentException("HTML 파일 또는 내용을 입력해주세요.");
        }

        String contentValue;
        String contentType;
        if (file != null && !file.isEmpty()) {
            contentValue = storageService.upload(file, TERMS_FOLDER);
            contentType = "FILE";
        } else {
            contentValue = plainTextToHtml(content);
            contentType = "TEXT";
        }

        Terms terms = Terms.builder()
                .type(type)
                .title(title)
                .content(contentValue)
                .contentType(contentType)
                .required(required)
                .active(active)
                .build();
        termsRepository.save(terms);
    }

    @Transactional
    public void update(Long termId, String title, boolean required, boolean active, MultipartFile file, String content) throws IOException {
        Terms terms = getTerms(termId);

        String contentValue = terms.getContent();
        String contentType = terms.getContentType();

        if (file != null && !file.isEmpty()) {
            contentValue = storageService.upload(file, TERMS_FOLDER);
            contentType = "FILE";
        } else if (content != null && !content.isBlank()) {
            contentValue = plainTextToHtml(content);
            contentType = "TEXT";
        }

        terms.update(title, contentValue, contentType, required, active);
    }

    @Transactional
    public void delete(Long termId) {
        termsRepository.deleteById(termId);
    }

    private String plainTextToHtml(String plainText) {
        if (plainText == null || plainText.isBlank()) return "";
        return plainText
            .replaceAll("&", "&amp;")
            .replaceAll("<", "&lt;")
            .replaceAll(">", "&gt;")
            .replaceAll("\"", "&quot;")
            .replaceAll("'", "&#39;")
            .replaceAll("\r\n", "<br>")
            .replaceAll("\n", "<br>");
    }

    public String htmlToPlainText(String html) {
        if (html == null || html.isBlank()) return "";
        return html
            .replaceAll("<br>", "\n")
            .replaceAll("&quot;", "\"")
            .replaceAll("&#39;", "'")
            .replaceAll("&lt;", "<")
            .replaceAll("&gt;", ">")
            .replaceAll("&amp;", "&");
    }
}
