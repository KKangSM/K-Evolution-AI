package com.kevolution.order.client;

import com.kevolution.order.dto.TossConfirmResponse;
import com.kevolution.order.dto.TossErrorResponse;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClient;

import java.nio.charset.StandardCharsets;
import java.util.Base64;
import java.util.Map;

/**
 * 토스페이먼츠 결제 API 호출 담당.
 * 시크릿 키를 Basic 인증(키 + ":" 를 Base64)으로 넘겨 결제 승인을 요청한다.
 */
@Component
public class TossPaymentClient {

    private static final String BASE_URL = "https://api.tosspayments.com";

    private final RestClient restClient;

    public TossPaymentClient(@Value("${toss.secret-key}") String secretKey) {
        String encoded = Base64.getEncoder()
            .encodeToString((secretKey + ":").getBytes(StandardCharsets.UTF_8));
        this.restClient = RestClient.builder()
            .baseUrl(BASE_URL)
            .defaultHeader(HttpHeaders.AUTHORIZATION, "Basic " + encoded)
            .build();
    }

    /**
     * 결제 승인. 성공 시 승인 정보를 반환하고, 실패 시 토스가 준 오류 메시지로 예외를 던진다.
     */
    public TossConfirmResponse confirm(String paymentKey, String orderId, int amount) {
        return restClient.post()
            .uri("/v1/payments/confirm")
            .contentType(MediaType.APPLICATION_JSON)
            .body(Map.of("paymentKey", paymentKey, "orderId", orderId, "amount", amount))
            .exchange((request, response) -> {
                if (response.getStatusCode().is2xxSuccessful()) {
                    return response.bodyTo(TossConfirmResponse.class);
                }
                TossErrorResponse error = response.bodyTo(TossErrorResponse.class);
                String message = (error != null && error.message() != null)
                    ? error.message() : "결제 승인에 실패했습니다.";
                throw new IllegalStateException(message);
            });
    }
}
