package com.kevolution.service;

import com.kevolution.entity.Member;
import com.kevolution.repository.MemberRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
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

    // ── 회원 관리 (/admin/members) ──────────────────
    public Page<Member> getMembers(Pageable pageable) {
        return memberRepository.findAll(pageable);
    }

    @Transactional
    public void changeRole(String targetMemberId, String requesterUserId, Member.Role newRole) {
        Member member = memberRepository.findById(targetMemberId)
                .orElseThrow(() -> new UsernameNotFoundException("회원을 찾을 수 없습니다."));
        if (member.getUserId().equals(requesterUserId)) {
            throw new IllegalArgumentException("자기 자신의 권한은 변경할 수 없습니다.");
        }
        member.changeRole(newRole);
    }

    @Transactional
    public void deleteMember(String targetMemberId, String requesterUserId) {
        Member member = memberRepository.findById(targetMemberId)
                .orElseThrow(() -> new UsernameNotFoundException("회원을 찾을 수 없습니다."));
        if (member.getUserId().equals(requesterUserId)) {
            throw new IllegalArgumentException("자기 자신은 삭제할 수 없습니다.");
        }
        member.withdraw();
    }
}
