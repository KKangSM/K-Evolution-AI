package com.kevolution.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * 크롬 개발자도구가 자동으로 보내는 워크스페이스 탐색 요청을 조용히 처리한다.
 * 기능과 무관하며, 404 화이트라벨/로그 노이즈를 없애기 위한 용도다.
 */
@RestController
public class WellKnownController {

    @GetMapping("/.well-known/appspecific/com.chrome.devtools.json")
    public ResponseEntity<Void> chromeDevtoolsProbe() {
        return ResponseEntity.noContent().build(); // 204 No Content
    }
}
