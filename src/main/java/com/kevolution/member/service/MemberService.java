package com.kevolution.member.service;

import com.kevolution.member.entity.Address;
import com.kevolution.member.entity.Member;
import com.kevolution.member.entity.TermsAgreement;
import com.kevolution.member.repository.AddressRepository;
import com.kevolution.member.repository.MemberRepository;
import com.kevolution.member.repository.TermsAgreementRepository;
import com.kevolution.terms.entity.Terms;
import com.kevolution.terms.service.TermsService;

import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class MemberService {

    private final MemberRepository memberRepository;
    private final AddressRepository addressRepository;
    private final TermsAgreementRepository termsAgreementRepository;
    private final TermsService termsService;
    private final BCryptPasswordEncoder passwordEncoder;

    public boolean isUserIdDuplicated(String userId) {
        return memberRepository.existsByUserId(userId);
    }

    @Transactional
    public void signup(String userId, String password, String name,
                       String phone, String zipcode, String address, String addressDetail,
                       List<Long> termIds) {
        if (memberRepository.existsByUserId(userId)) {
            throw new IllegalArgumentException("이미 사용 중인 아이디입니다.");
        }

        List<Long> agreedIds = termIds != null ? termIds : List.of();
        List<Terms> activeTerms = termsService.getActiveTerms();

        // 서버측 필수 약관 동의 검증 (클라이언트 우회 방지)
        boolean allRequiredAgreed = activeTerms.stream()
                .filter(Terms::isRequired)
                .allMatch(t -> agreedIds.contains(t.getTermId()));
        if (!allRequiredAgreed) {
            throw new IllegalArgumentException("필수 약관에 모두 동의해야 합니다.");
        }

        Member member = memberRepository.save(
            Member.builder()
                .userId(userId)
                .password(passwordEncoder.encode(password))
                .name(name)
                .phone(phone)
                .address(address)
                .build()
        );

        // 가입 시 받은 주소를 기본 배송지로 자동 등록 (주문 시 재입력 불필요)
        addressRepository.save(
            Address.builder()
                .member(member)
                .recipient(name)
                .phone(phone)
                .zipcode(zipcode)
                .address(address)
                .addressDetail(addressDetail)
                .defaultAddress(true)
                .build()
        );

        // 동의 이력 저장 (활성 약관 중 실제로 동의한 것만)
        activeTerms.stream()
                .filter(t -> agreedIds.contains(t.getTermId()))
                .forEach(t -> termsAgreementRepository.save(
                        TermsAgreement.builder().member(member).terms(t).build()));
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
