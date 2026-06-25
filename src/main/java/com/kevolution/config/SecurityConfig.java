package com.kevolution.config;

import jakarta.servlet.DispatcherType;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.*;
import org.springframework.security.access.hierarchicalroles.RoleHierarchy;
import org.springframework.security.access.hierarchicalroles.RoleHierarchyImpl;
import org.springframework.security.authentication.dao.DaoAuthenticationProvider;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.core.Authentication;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.access.expression.WebExpressionAuthorizationManager;
import org.springframework.security.web.authentication.AuthenticationSuccessHandler;
import org.springframework.security.web.authentication.SavedRequestAwareAuthenticationSuccessHandler;

import java.io.IOException;

@Configuration
@EnableWebSecurity
@RequiredArgsConstructor
public class SecurityConfig {

    private final CustomUserDetailsService userDetailsService;

    @Bean
    public BCryptPasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    /**
     * 권한 계층: SYSTEM > ADMIN > USER.
     * 상위 권한이 하위 권한의 접근을 자동으로 포함하므로,
     * 예) /admin/** 에 hasRole("ADMIN") 만 걸어도 SYSTEM 계정이 함께 통과한다.
     */
    @Bean
    public RoleHierarchy roleHierarchy() {
        return RoleHierarchyImpl.withDefaultRolePrefix()
            .role("SYSTEM").implies("ADMIN")
            .role("ADMIN").implies("USER")
            .build();
    }

    /**
     * 로그인 성공 후 분기:
     *  - ADMIN/SYSTEM → 관리자 대시보드(/admin)
     *  - 그 외(일반 회원) → 원래 가려던 페이지(saved request) 또는 기본 "/"
     */
    @Bean
    public AuthenticationSuccessHandler authenticationSuccessHandler() {
        return new SavedRequestAwareAuthenticationSuccessHandler() {
            {
                setDefaultTargetUrl("/");
            }
            @Override
            public void onAuthenticationSuccess(HttpServletRequest request, HttpServletResponse response,
                                                Authentication authentication)
                    throws IOException, ServletException {
                boolean isAdmin = authentication.getAuthorities().stream()
                    .anyMatch(a -> a.getAuthority().equals("ROLE_ADMIN")
                                || a.getAuthority().equals("ROLE_SYSTEM"));
                if (isAdmin) {
                    getRedirectStrategy().sendRedirect(request, response, "/admin");
                } else {
                    super.onAuthenticationSuccess(request, response, authentication);
                }
            }
        };
    }

    @Bean
    public DaoAuthenticationProvider authenticationProvider() {
        DaoAuthenticationProvider provider = new DaoAuthenticationProvider();
        provider.setUserDetailsService(userDetailsService);
        provider.setPasswordEncoder(passwordEncoder());
        return provider;
    }

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            .authenticationProvider(authenticationProvider())
            .authorizeHttpRequests(auth -> auth
                .dispatcherTypeMatchers(DispatcherType.FORWARD, DispatcherType.ERROR).permitAll()
                .requestMatchers("/auth/**", "/products/**", "/", "/css/**", "/js/**", "/images/**", "/uploads/**", "/.well-known/**").permitAll()
                .requestMatchers("/support", "/support/notices", "/support/notices/**").permitAll()
                .requestMatchers("/admin/**").hasRole("ADMIN")
                // 일반 회원 전용 — ADMIN 은 URL 접근까지 차단.
                // 단 SYSTEM 은 마스터키이므로 모두 통과시킨다.
                // (SYSTEM 이거나, 또는 USER 이면서 ADMIN 이 아닌 계정만 통과)
                .requestMatchers("/support/qna/**", "/mypage/**", "/cart/**")
                    .access(new WebExpressionAuthorizationManager(
                        "hasRole('SYSTEM') or (hasRole('USER') and !hasRole('ADMIN'))"))
                .anyRequest().authenticated()
            )
            .formLogin(form -> form
                .loginPage("/auth/login")
                .loginProcessingUrl("/auth/login")
                .successHandler(authenticationSuccessHandler())
                .failureUrl("/auth/login?error=true")
                .usernameParameter("id")
                .passwordParameter("password")
                .permitAll()
            )
            .logout(logout -> logout
                .logoutUrl("/auth/logout")
                .logoutSuccessUrl("/?logout")   // 메인으로 이동 + "로그아웃되었습니다" 토스트 표시
                .invalidateHttpSession(true)
                .deleteCookies("JSESSIONID")
            );

        return http.build();
    }
}
