package com.kevolution.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "member_coupon")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class MemberCoupon {
  1. member 테이블 DDL

  CREATE TABLE member (
      member_id   CHAR(36)                    NOT NULL COMMENT 'PK · UUID (비순차/비추측)',
      user_id     VARCHAR(50)                 NOT NULL COMMENT '로그인 아이디',
      password    VARCHAR(255)                NOT NULL COMMENT '비밀번호 (BCrypt 해시)',
      ci          VARCHAR(255)                NULL     COMMENT '휴대폰 본인인증 고유번호(CI)',
      role        ENUM('USER','ADMIN')        NOT NULL COMMENT '권한',
      status      ENUM('ACTIVE','WITHDRAWN')  NOT NULL COMMENT '계정 상태(soft-delete)',
      name        VARCHAR(50)                 NOT NULL COMMENT '회원명',
      phone       VARCHAR(20)                 NULL     COMMENT '전화번호',
      address     VARCHAR(255)                NULL     COMMENT '기본 배송지',
      created_at  DATETIME                    NOT NULL COMMENT '가입일시',
      updated_at  DATETIME                    NOT NULL COMMENT '수정일시',
      PRIMARY KEY (member_id),
      UNIQUE KEY uk_member_user_id (user_id),
      UNIQUE KEY uk_member_ci (ci)
  ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='회원';
  
  
  
    INSERT INTO member (member_id, user_id, password, role, status, name, created_at, updated_at)
  VALUES (UUID(), 'system', '$2a$10$mIGbihg0FRMcKdw6lq1/tuST.xSPR.BMhpFj3iCKkY83tXT4eleMS',
          'ADMIN', 'ACTIVE', '시스템관리자', NOW(), NOW());
          
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long memberCouponId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "member_id", nullable = false)
    private Member member;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "coupon_id", nullable = false)
    private Coupon coupon;

    @Column(name = "is_used", nullable = false)
    private boolean used;

    private LocalDateTime usedAt;

    @Builder
    public MemberCoupon(Member member, Coupon coupon) {
        this.member = member;
        this.coupon = coupon;
        this.used = false;
    }

    public void use() {
        this.used = true;
        this.usedAt = LocalDateTime.now();
    }
}
