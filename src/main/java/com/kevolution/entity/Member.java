package com.kevolution.entity;

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

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 10)
    private Role role;

    /** 계정 상태 (soft-delete: 탈퇴해도 row 유지) */
    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 10)
    private Status status;

    @Column(nullable = false, length = 50)
    private String name;

    @Convert(converter = AesAttributeConverter.class)
    @Column(length = 100)
    private String phone;

    @Convert(converter = AesAttributeConverter.class)
    @Column(length = 500)
    private String address;

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
}
