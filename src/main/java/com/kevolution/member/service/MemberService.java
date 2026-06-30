package com.kevolution.member.service;

import com.kevolution.member.entity.Address;
import com.kevolution.member.entity.Member;
import com.kevolution.member.entity.TermsAgreement;
import com.kevolution.member.repository.AddressRepository;
import com.kevolution.member.repository.MemberRepository;
import com.kevolution.member.repository.TermsAgreementRepository;
import com.kevolution.config.PasswordPolicy;
import com.kevolution.config.UserIdPolicy;
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

    public Member findByUserId(String userId) {
        return memberRepository.findByUserId(userId)
                .orElseThrow(() -> new UsernameNotFoundException("회원을 찾을 수 없습니다."));
    }

    @Transactional
    public void signup(String userId, String password, String name,
                       String phone, String zipcode, String address, String addressDetail,
                       List<Long> termIds) {
        UserIdPolicy.validate(userId);
        if (memberRepository.existsByUserId(userId)) {
            throw new IllegalArgumentException("이미 사용 중인 아이디입니다.");
        }
        PasswordPolicy.validate(password);

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
    public Page<Member> getMembers(Pageable pageable, Member.Role requesterRole) {
        // Admin은 SYSTEM 계정을 조회할 수 없음
        if (requesterRole == Member.Role.ADMIN) {
            return memberRepository.findByRoleNot(Member.Role.SYSTEM, pageable);
        }

        return memberRepository.findAll(pageable);
    }

    @Transactional
    public void changeRole(String targetMemberId, String requesterUserId, Member.Role newRole) {
        Member requester = memberRepository.findByUserId(requesterUserId)
                .orElseThrow(() -> new UsernameNotFoundException("요청자를 찾을 수 없습니다."));
        Member target = memberRepository.findById(targetMemberId)
                .orElseThrow(() -> new UsernameNotFoundException("회원을 찾을 수 없습니다."));

        if (target.getUserId().equals(requesterUserId)) {
            throw new IllegalArgumentException("자기 자신의 권한은 변경할 수 없습니다.");
        }

        // Admin은 SYSTEM 권한 부여 불가
        if (requester.getRole() == Member.Role.ADMIN && newRole == Member.Role.SYSTEM) {
            throw new IllegalArgumentException("SYSTEM 권한은 SYSTEM 계정만 부여할 수 있습니다.");
        }

        // Admin은 SYSTEM 계정을 관리할 수 없음
        if (requester.getRole() == Member.Role.ADMIN && target.getRole() == Member.Role.SYSTEM) {
            throw new IllegalArgumentException("SYSTEM 계정은 관리할 수 없습니다.");
        }

        target.changeRole(newRole);
    }

    @Transactional
    public void deleteMember(String targetMemberId, String requesterUserId) {
        Member requester = memberRepository.findByUserId(requesterUserId)
                .orElseThrow(() -> new UsernameNotFoundException("요청자를 찾을 수 없습니다."));
        Member member = memberRepository.findById(targetMemberId)
                .orElseThrow(() -> new UsernameNotFoundException("회원을 찾을 수 없습니다."));

        if (member.getUserId().equals(requesterUserId)) {
            throw new IllegalArgumentException("자기 자신은 삭제할 수 없습니다.");
        }

        // SYSTEM만 삭제 가능
        if (requester.getRole() != Member.Role.SYSTEM) {
            throw new IllegalArgumentException("회원 삭제는 SYSTEM 계정만 가능합니다.");
        }

        memberRepository.delete(member);
    }

    @Transactional
    public void updateMemberInfo(String memberId, String name, String phone,
                                  Member.Role role, Member.Status status,
                                  String requesterUserId) {
        Member requester = memberRepository.findByUserId(requesterUserId)
                .orElseThrow(() -> new UsernameNotFoundException("요청자를 찾을 수 없습니다."));
        Member member = memberRepository.findById(memberId)
                .orElseThrow(() -> new UsernameNotFoundException("회원을 찾을 수 없습니다."));

        if (member.getUserId().equals(requesterUserId)) {
            throw new IllegalArgumentException("자기 자신의 정보는 수정할 수 없습니다.");
        }

        if (requester.getRole() == Member.Role.ADMIN && member.getRole() == Member.Role.SYSTEM) {
            throw new IllegalArgumentException("SYSTEM 계정은 수정할 수 없습니다.");
        }

        if (requester.getRole() == Member.Role.ADMIN && role == Member.Role.SYSTEM) {
            throw new IllegalArgumentException("SYSTEM 권한은 SYSTEM 계정만 부여할 수 있습니다.");
        }

        member.updateInfo(name, phone);
        member.changeRole(role);
        member.changeStatus(status);
    }
}
