package com.kevolution.config;

import com.kevolution.member.entity.Member;
import com.kevolution.member.repository.MemberRepository;

import lombok.RequiredArgsConstructor;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.*;
import org.springframework.stereotype.Service;
import java.util.List;

@Service
@RequiredArgsConstructor
public class CustomUserDetailsService implements UserDetailsService {

    private final MemberRepository memberRepository;

    @Override
    public UserDetails loadUserByUsername(String userId) throws UsernameNotFoundException {
        Member member = memberRepository.findByUserId(userId)
            .orElseThrow(() -> new UsernameNotFoundException("User not found: " + userId));

        boolean enabled = member.getStatus() == Member.Status.ACTIVE; // 탈퇴 계정은 로그인 차단

        return User.builder()
            .username(member.getUserId())
            .password(member.getPassword())
            .disabled(!enabled)
            .authorities(new SimpleGrantedAuthority("ROLE_" + member.getRole().name()))
            .build();
    }
}
