package com.kevolution.entity;

import com.kevolution.config.AesAttributeConverter;
import jakarta.persistence.*;
import lombok.*;

/** 회원 배송지 주소록 (회원당 여러 개, 기본 배송지 1개). 개인정보는 AES-256 암호화 저장. */
@Entity
@Table(name = "member_address")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class MemberAddress {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long addressId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "member_id", nullable = false)
    private Member member;

    /** 받는 사람 이름 */
    @Column(nullable = false, length = 50)
    private String recipient;

    @Convert(converter = AesAttributeConverter.class)
    @Column(length = 100)
    private String phone;

    @Column(length = 20)
    private String zipcode;

    @Convert(converter = AesAttributeConverter.class)
    @Column(length = 500)
    private String address;

    @Convert(converter = AesAttributeConverter.class)
    @Column(length = 500)
    private String addressDetail;

    /** 기본 배송지 여부 */
    @Column(nullable = false)
    private boolean defaultAddress;

    @Builder
    public MemberAddress(Member member, String recipient, String phone, String zipcode,
                         String address, String addressDetail, boolean defaultAddress) {
        this.member = member;
        this.recipient = recipient;
        this.phone = phone;
        this.zipcode = zipcode;
        this.address = address;
        this.addressDetail = addressDetail;
        this.defaultAddress = defaultAddress;
    }

    public void setAsDefault(boolean value) {
        this.defaultAddress = value;
    }
}
