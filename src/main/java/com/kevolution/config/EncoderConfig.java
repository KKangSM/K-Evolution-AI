package com.kevolution.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

/**
 * 비밀번호 인코더 빈을 SecurityConfig 에서 분리한 설정.
 * SecurityConfig 가 소셜 로그인 서비스(CustomOAuth2UserService)를 주입받고,
 * 그 서비스가 passwordEncoder 를 다시 필요로 하면서 생기는 순환 참조를 끊기 위함.
 */
@Configuration
public class EncoderConfig {

    @Bean
    public BCryptPasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }
}
