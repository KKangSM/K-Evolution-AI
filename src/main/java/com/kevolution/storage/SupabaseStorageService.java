package com.kevolution.storage;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;
import org.springframework.web.client.RestClient;
import org.springframework.web.client.RestClientResponseException;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.io.UncheckedIOException;
import java.net.URLDecoder;
import java.nio.charset.StandardCharsets;
import java.util.UUID;

/**
 * Supabase Storage 업로드/삭제 클라이언트.
 *
 * Storage REST API 를 secret(service_role) 키로 직접 호출한다.
 * 업로드가 성공하면 SUPABASE_URL / SUPABASE_SECRET_KEY 설정이 정상임이 함께 검증된다.
 * (버킷 이름은 supabase.storage.bucket 으로 지정, 기본값 banner)
 *
 * 주의: 반환하는 공개 URL 로 이미지가 바로 보이려면 버킷이 Public 이어야 한다.
 *      Private 버킷이면 별도의 서명 URL 발급이 필요하다.
 */
@Service
public class SupabaseStorageService {

    private final String supabaseUrl;
    private final String secretKey;
    private final String bucket;
    private final RestClient restClient = RestClient.create();

    public SupabaseStorageService(
        @Value("${SUPABASE_URL}") String supabaseUrl,
        @Value("${SUPABASE_SECRET_KEY}") String secretKey,
        @Value("${supabase.storage.bucket:banner}") String bucket
    ) {
        this.supabaseUrl = supabaseUrl.replaceAll("/+$", ""); // 끝 슬래시 제거
        this.secretKey = secretKey;
        this.bucket = bucket;
    }

    /** 파일을 버킷 루트에 올리고 공개 URL 을 반환한다. */
    public String upload(MultipartFile file) {
        return upload(file, null);
    }

    /** 파일을 버킷의 {folder}/ 아래에 올리고 공개 URL 을 반환한다. (folder 가 null/blank 면 루트) */
    public String upload(MultipartFile file, String folder) {
        if (file == null || file.isEmpty()) {
            throw new IllegalArgumentException("업로드할 이미지가 없습니다.");
        }
        String ext = StringUtils.getFilenameExtension(file.getOriginalFilename());
        String prefix = (folder != null && !folder.isBlank()) ? folder + "/" : "";
        String objectName = prefix + UUID.randomUUID()
            + (ext != null && !ext.isBlank() ? "." + ext.toLowerCase() : "");
        String contentType = file.getContentType() != null
            ? file.getContentType() : MediaType.APPLICATION_OCTET_STREAM_VALUE;

        try {
            restClient.post()
                .uri(supabaseUrl + "/storage/v1/object/" + bucket + "/" + objectName)
                .header("apikey", secretKey)
                .header("Authorization", "Bearer " + secretKey)
                .header("x-upsert", "true")
                .contentType(MediaType.parseMediaType(contentType))
                .body(file.getBytes())
                .retrieve()
                .toBodilessEntity();
        } catch (IOException e) {
            throw new UncheckedIOException("이미지 읽기에 실패했습니다.", e);
        } catch (RestClientResponseException e) {
            throw new IllegalStateException(
                "Supabase 업로드 실패 (" + e.getStatusCode() + "): " + e.getResponseBodyAsString(), e);
        }
        return publicUrl(objectName);
    }

    /** 공개 URL 로 저장된 객체를 삭제한다. 파일이 이미 없거나 권한 문제여도 흐름을 막지 않는다(best-effort). */
    public void deleteByPublicUrl(String publicUrl) {
        String objectName = extractObjectName(publicUrl);
        if (objectName == null) return;
        try {
            restClient.delete()
                .uri(supabaseUrl + "/storage/v1/object/" + bucket + "/" + objectName)
                .header("apikey", secretKey)
                .header("Authorization", "Bearer " + secretKey)
                .retrieve()
                .toBodilessEntity();
        } catch (RestClientResponseException ignored) {
            // 배너 삭제 자체는 계속 진행한다.
        }
    }

    private String publicUrl(String objectName) {
        return supabaseUrl + "/storage/v1/object/public/" + bucket + "/" + objectName;
    }

    /** ".../object/public/{bucket}/{objectName}" 에서 objectName 만 추출한다. */
    private String extractObjectName(String publicUrl) {
        if (publicUrl == null) return null;
        String marker = "/object/public/" + bucket + "/";
        int idx = publicUrl.indexOf(marker);
        if (idx < 0) return null;
        return URLDecoder.decode(publicUrl.substring(idx + marker.length()), StandardCharsets.UTF_8);
    }
}
