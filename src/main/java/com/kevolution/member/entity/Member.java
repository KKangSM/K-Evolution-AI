package com.kevolution.member.entity;

import com.kevolution.config.AesAttributeConverter;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.UuidGenerator;
import java.time.LocalDateTime;

@Entity
@Table(name = "member")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class Member {

    /** PK · UUID 자동생성 (비순차/비추측). 외부 식별자로 안전. */
    @Id
    @UuidGenerator
    @Column(name = "member_id", columnDefinition = "CHAR(36)", nullable = false, updatable = false)
    private String memberId;

    /** 로그인 아이디 */
    @Column(name = "user_id", nullable = false, unique = true, length = 50)
    private String userId;

    /** 비밀번호 (BCrypt 해시) */
    @Column(nullable = false)
    private String password;

    /** 휴대폰 본인인증 고유번호(CI). 인증 전이면 NULL 가능. AES-256 암호화 저장 */
    @Convert(converter = AesAttributeConverter.class)
    @Column(name = "ci", unique = true, length = 500)
    private String ci;

    @Column(nullable = false, length = 50)
    private String name;

    @Convert(converter = AesAttributeConverter.class)
    @Column(length = 100)
    private String phone;

    @Convert(converter = AesAttributeConverter.class)
    @Column(length = 500)
    private String address;

    /** 소셜 로그인 제공자 (예: GOOGLE). 일반(폼) 회원은 NULL */
    @Column(length = 20)
    private String provider;

    /** 소셜 제공자의 고유 사용자 ID (예: 구글 sub). 일반 회원은 NULL */
    @Column(name = "provider_id", length = 100)
    private String providerId;

    /** 이메일 (소셜 로그인 시 제공자에서 수집). 일반 회원은 NULL 가능 */
    @Column(length = 200)
    private String email;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 10)
    private Role role;

    /** 계정 상태 (soft-delete: 탈퇴해도 row 유지) */
    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 10)
    private Status status;

    @Column(nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @Column(nullable = false)
    private LocalDateTime updatedAt;

    /** 권한 3단 계층: SYSTEM(최고운영자) > ADMIN(관리자) > USER(일반회원) */
    public enum Role { SYSTEM, ADMIN, USER }
    public enum Status { ACTIVE, WITHDRAWN }

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
        if (role == null) role = Role.USER;
        if (status == null) status = Status.ACTIVE;
    }

    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }

    public void changeRole(Role role) {
        this.role = role;
    }

    public void withdraw() {
        this.status = Status.WITHDRAWN;
    }

    public void changeStatus(Status status) {
        this.status = status;
    }

    public void updateInfo(String name, String phone) {
        this.name = name;
        this.phone = phone;
    }

    /** 소셜(OAuth2) 회원 추가정보 입력 완료 — 휴대폰 등록. (phone 이 채워지면 가입 완료로 간주) */
    public void completeProfile(String phone) {
        this.phone = phone;
    }

    public void changePassword(String encodedPassword) {
        this.password = encodedPassword;
    }

    @Builder
    public Member(String userId, String password, String ci, String name,
                  String phone, String address, Role role, Status status) {
        this.userId = userId;
        this.password = password;
        this.ci = ci;
        this.name = name;
        this.phone = phone;
        this.address = address;
        this.role = role != null ? role : Role.USER;
        this.status = status != null ? status : Status.ACTIVE;
    }

    /**
     * 소셜(OAuth2) 회원 생성.
     * password 는 로그인에 쓰이지 않는 랜덤 해시로 채우고, provider/providerId 로 계정을 식별한다.
     */
    public static Member ofOAuth(String userId, String encodedRandomPassword, String name,
                                 String email, String provider, String providerId) {
        Member m = new Member();
        m.userId = userId;
        m.password = encodedRandomPassword;
        m.name = name;
        m.email = email;
        m.provider = provider;
        m.providerId = providerId;
        m.role = Role.USER;
        m.status = Status.ACTIVE;
        return m;
    }
}
