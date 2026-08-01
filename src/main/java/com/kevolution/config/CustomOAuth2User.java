package com.kevolution.config;

import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.oauth2.core.user.OAuth2User;

import java.util.Collection;
import java.util.List;
import java.util.Map;

/**
 * 소셜 로그인 사용자 principal.
 *
 * OAuth2User(oauth2Login 처리용) 이면서 동시에 UserDetails 를 구현한다.
 * 덕분에 기존 컨트롤러들의 {@code @AuthenticationPrincipal UserDetails} + {@code getUsername()} 코드가
 * 소셜 로그인 세션에서도 그대로 동작한다. getUsername()/getName() 모두 회원의 userId 를 돌려준다.
 */
public class CustomOAuth2User implements OAuth2User, UserDetails {

    private final String userId;                 // 회원의 로그인 아이디 (내부 식별자)
    private final String role;                   // 예: ROLE_USER
    private final boolean enabled;
    private final Map<String, Object> attributes;

    public CustomOAuth2User(String userId, String role, boolean enabled, Map<String, Object> attributes) {
        this.userId = userId;
        this.role = role;
        this.enabled = enabled;
        this.attributes = attributes;
    }

    // ── OAuth2User ──────────────────────────────
    @Override public Map<String, Object> getAttributes() { return attributes; }
    @Override public String getName() { return userId; }

    // ── 공통 authorities ────────────────────────
    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        return List.of(new SimpleGrantedAuthority(role));
    }

    // ── UserDetails ─────────────────────────────
    @Override public String getUsername() { return userId; }
    @Override public String getPassword() { return null; }   // 소셜 로그인은 비밀번호 미사용
    @Override public boolean isAccountNonExpired() { return true; }
    @Override public boolean isAccountNonLocked() { return true; }
    @Override public boolean isCredentialsNonExpired() { return true; }
    @Override public boolean isEnabled() { return enabled; }
}
