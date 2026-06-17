package com.kevolution.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class AuthController {

    // GET: 로그인 폼 표시
    // POST(/auth/login) 처리는 Spring Security 필터가 담당하므로 여기서 매핑하지 않는다.
    @GetMapping("/auth/login")
    public String loginForm() {
        return "auth/login";
    }
}
