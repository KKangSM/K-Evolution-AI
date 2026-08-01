package com.kevolution.config;

import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

import java.nio.file.Paths;

@Configuration
@RequiredArgsConstructor
public class WebConfig implements WebMvcConfigurer {

    @Value("${app.upload.dir:uploads}")
    private String uploadDir;

    private final ProfileCompletionInterceptor profileCompletionInterceptor;

    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        String absolutePath = Paths.get(uploadDir).toAbsolutePath().toString();
        registry.addResourceHandler("/uploads/**")
                .addResourceLocations("file:" + absolutePath + "/");
    }

    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        // 소셜 회원 추가정보 미입력자 유도. 완성 페이지·인증·정적 리소스 등은 제외해 리다이렉트 루프 방지.
        registry.addInterceptor(profileCompletionInterceptor)
                .addPathPatterns("/**")
                .excludePathPatterns(
                        "/auth/complete-profile", "/auth/logout", "/auth/login",
                        "/oauth2/**", "/login/oauth2/**",
                        "/css/**", "/js/**", "/images/**", "/uploads/**",
                        "/error", "/.well-known/**", "/favicon.ico");
    }
}
