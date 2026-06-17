package com.kevolution.service;

import com.kevolution.entity.Member;
import com.kevolution.repository.MemberRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class MemberService {

    private final MemberRepository memberRepository;
    private final BCryptPasswordEncoder passwordEncoder;

    public boolean isUserIdDuplicated(String userId) {
        return memberRepository.existsByUserId(userId);
    }

    @Transactional
    public void signup(String userId, String password, String name) {
        if (memberRepository.existsByUserId(userId)) {
            throw new IllegalArgumentException("이미 사용 중인 아이디입니다.");
        }
        memberRepository.save(
            Member.builder()
                .userId(userId)
                .password(passwordEncoder.encode(password))
                .name(name)
                .build()
        );
    }
}
