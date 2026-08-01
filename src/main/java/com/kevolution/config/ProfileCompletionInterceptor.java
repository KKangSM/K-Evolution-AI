package com.kevolution.config;

import com.kevolution.member.entity.Member;
import com.kevolution.member.repository.MemberRepository;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;

/**
 * 소셜(OAuth2) 로그인으로 방금 가입했지만 추가정보(휴대폰·약관동의)를 아직 안 넣은 회원을
 * /auth/complete-profile 로 강제 유도한다.
 *
 * - 폼 로그인 회원(principal 이 CustomOAuth2User 가 아님)은 검사 자체를 건너뛴다 → DB 조회는 소셜 세션에서만 발생.
 * - 판별 기준: provider 가 있고(소셜) phone 이 비어 있으면(추가정보 미입력) 미완성으로 본다.
 */
@Component
@RequiredArgsConstructor
public class ProfileCompletionInterceptor implements HandlerInterceptor {

    private final MemberRepository memberRepository;

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth == null || !(auth.getPrincipal() instanceof CustomOAuth2User principal)) {
            return true; // 미인증 또는 폼 로그인 → 통과
        }

        Member member = memberRepository.findByUserId(principal.getUsername()).orElse(null);
        if (member != null && member.getProvider() != null && member.getPhone() == null) {
            response.sendRedirect(request.getContextPath() + "/auth/complete-profile");
            return false;
        }
        return true;
    }
}
