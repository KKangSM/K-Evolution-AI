package com.kevolution.config;

import com.kevolution.member.entity.Member;
import com.kevolution.member.repository.MemberRepository;

import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.oauth2.client.userinfo.DefaultOAuth2UserService;
import org.springframework.security.oauth2.client.userinfo.OAuth2UserRequest;
import org.springframework.security.oauth2.core.OAuth2AuthenticationException;
import org.springframework.security.oauth2.core.OAuth2Error;
import org.springframework.security.oauth2.core.user.OAuth2User;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Map;
import java.util.UUID;

/**
 * 소셜 로그인 시 제공자(구글)의 사용자 정보를 받아 회원을 find-or-create 하고,
 * 기존 컨트롤러와 호환되는 {@link CustomOAuth2User}(= UserDetails) 로 감싸 반환한다.
 */
@Service
@RequiredArgsConstructor
public class CustomOAuth2UserService extends DefaultOAuth2UserService {

    private final MemberRepository memberRepository;
    private final BCryptPasswordEncoder passwordEncoder;

    @Override
    @Transactional
    public OAuth2User loadUser(OAuth2UserRequest req) throws OAuth2AuthenticationException {
        OAuth2User oAuth2User = super.loadUser(req);
        Map<String, Object> attributes = oAuth2User.getAttributes();

        String provider   = req.getClientRegistration().getRegistrationId().toUpperCase(); // "GOOGLE"
        String providerId = oAuth2User.getName();                       // 구글 sub (제공자 고유 ID)
        String email      = (String) attributes.get("email");
        String name       = (String) attributes.getOrDefault("name", "회원");

        Member member = memberRepository.findByProviderAndProviderId(provider, providerId)
            .orElseGet(() -> memberRepository.save(
                Member.ofOAuth(
                    provider.toLowerCase() + "_" + providerId,            // 내부 로그인 아이디 (unique)
                    passwordEncoder.encode(UUID.randomUUID().toString()), // 로그인에 쓰이지 않는 랜덤 비밀번호
                    name, email, provider, providerId
                )
            ));

        // 탈퇴 계정은 소셜 로그인도 차단 (실패 URL 로 리다이렉트됨)
        if (member.getStatus() != Member.Status.ACTIVE) {
            throw new OAuth2AuthenticationException(
                new OAuth2Error("account_withdrawn"), "탈퇴한 계정입니다.");
        }

        return new CustomOAuth2User(
            member.getUserId(),
            "ROLE_" + member.getRole().name(),
            true,
            attributes
        );
    }
}
