package com.kevolution.mypage.service;

import com.kevolution.member.entity.Address;
import com.kevolution.member.entity.Member;
import com.kevolution.member.repository.AddressRepository;
import com.kevolution.member.repository.MemberRepository;
import com.kevolution.config.PasswordPolicy;

import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class MypageService {

    private final MemberRepository memberRepository;
    private final AddressRepository addressRepository;
    private final BCryptPasswordEncoder passwordEncoder;

    public Member getMember(String userId) {
        return memberRepository.findByUserId(userId)
                .orElseThrow(() -> new IllegalArgumentException("회원을 찾을 수 없습니다."));
    }

    @Transactional
    public void updateInfo(String userId, String name, String phone) {
        getMember(userId).updateInfo(name, phone);
    }

    @Transactional
    public void changePassword(String userId, String currentPassword, String newPassword) {
        Member member = getMember(userId);
        if (!passwordEncoder.matches(currentPassword, member.getPassword())) {
            throw new IllegalArgumentException("현재 비밀번호가 일치하지 않습니다.");
        }
        PasswordPolicy.validate(newPassword);
        member.changePassword(passwordEncoder.encode(newPassword));
    }

    @Transactional
    public void withdraw(String userId, String password) {
        Member member = getMember(userId);
        if (!passwordEncoder.matches(password, member.getPassword())) {
            throw new IllegalArgumentException("비밀번호가 일치하지 않습니다.");
        }
        member.withdraw();
    }

    // 배송지
    public List<Address> getAddresses(String userId) {
        return addressRepository.findByMember(getMember(userId));
    }

    @Transactional
    public void addAddress(String userId, String recipient, String phone,
                           String zipcode, String address, String addressDetail, boolean isDefault) {
        Member member = getMember(userId);
        if (isDefault) {
            addressRepository.findByMemberAndDefaultAddressTrue(member)
                    .ifPresent(a -> a.setAsDefault(false));
        }
        addressRepository.save(Address.builder()
                .member(member)
                .recipient(recipient)
                .phone(phone)
                .zipcode(zipcode)
                .address(address)
                .addressDetail(addressDetail)
                .defaultAddress(isDefault)
                .build());
    }

    @Transactional
    public void deleteAddress(String userId, Long addressId) {
        Address addr = addressRepository.findById(addressId)
                .orElseThrow(() -> new IllegalArgumentException("배송지를 찾을 수 없습니다."));
        if (!addr.getMember().getUserId().equals(userId)) {
            throw new IllegalArgumentException("본인의 배송지만 삭제할 수 있습니다.");
        }
        addressRepository.delete(addr);
    }

    @Transactional
    public void setDefaultAddress(String userId, Long addressId) {
        Member member = getMember(userId);
        addressRepository.findByMemberAndDefaultAddressTrue(member)
                .ifPresent(a -> a.setAsDefault(false));
        Address addr = addressRepository.findById(addressId)
                .orElseThrow(() -> new IllegalArgumentException("배송지를 찾을 수 없습니다."));
        addr.setAsDefault(true);
    }
}
