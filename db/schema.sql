-- =====================================================================
-- K-Evolution 쇼핑몰 스키마 (MySQL 8.x)
-- 설계서 7장 테이블 명세 + JPA 엔티티 기준
--
-- 사용법:
--   mysql -u root -p < db/schema.sql
-- 또는 MySQL 클라이언트에서 이 파일 전체 실행
--
-- 참고:
--  - DB명은 application.properties 기준 `k-evolution` (하이픈 → 백틱 필요)
--  - 엔진 InnoDB / 문자셋 utf8mb4
--  - ENUM 컬럼은 JPA @Enumerated(STRING) 매핑. Hibernate ddl-auto=update는
--    enum을 VARCHAR+check로 보므로, update 모드 충돌이 싫으면 ENUM(...) 대신
--    VARCHAR(20)으로 바꿔도 무방.
-- =====================================================================

CREATE DATABASE IF NOT EXISTS `k-evolution`
    DEFAULT CHARACTER SET utf8mb4
    DEFAULT COLLATE utf8mb4_unicode_ci;

USE `k-evolution`;

-- 재실행 대비: 자식 → 부모 역순으로 제거
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS payment;
DROP TABLE IF EXISTS order_item;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS member_coupon;
DROP TABLE IF EXISTS coupon;
DROP TABLE IF EXISTS cart_item;
DROP TABLE IF EXISTS cart;
DROP TABLE IF EXISTS product;
DROP TABLE IF EXISTS category;
DROP TABLE IF EXISTS member;
SET FOREIGN_KEY_CHECKS = 1;

-- ---------------------------------------------------------------------
-- member (회원)
-- ---------------------------------------------------------------------
CREATE TABLE member (
    member_id   BIGINT          NOT NULL AUTO_INCREMENT COMMENT '회원 ID',
    email       VARCHAR(100)    NOT NULL                COMMENT '이메일 (로그인 ID)',
    password    VARCHAR(255)    NOT NULL                COMMENT '암호화된 비밀번호(BCrypt)',
    name        VARCHAR(50)     NOT NULL                COMMENT '회원명',
    phone       VARCHAR(20)     NULL                    COMMENT '전화번호',
    address     VARCHAR(255)    NULL                    COMMENT '기본 배송지',
    role        ENUM('USER','ADMIN') NOT NULL           COMMENT '권한',
    created_at  DATETIME        NOT NULL                COMMENT '가입일시',
    updated_at  DATETIME        NOT NULL                COMMENT '수정일시',
    PRIMARY KEY (member_id),
    UNIQUE KEY uk_member_email (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='회원';

-- ---------------------------------------------------------------------
-- category (카테고리)
-- ---------------------------------------------------------------------
CREATE TABLE category (
    category_id BIGINT      NOT NULL AUTO_INCREMENT COMMENT '카테고리 ID',
    name        VARCHAR(50) NOT NULL                COMMENT '카테고리명',
    PRIMARY KEY (category_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='상품 카테고리';

-- ---------------------------------------------------------------------
-- product (상품)
-- ---------------------------------------------------------------------
CREATE TABLE product (
    product_id  BIGINT          NOT NULL AUTO_INCREMENT COMMENT '상품 ID',
    category_id BIGINT          NULL                    COMMENT '카테고리 ID (FK)',
    name        VARCHAR(200)    NOT NULL                COMMENT '상품명',
    price       INT             NOT NULL                COMMENT '판매가',
    stock       INT             NOT NULL                COMMENT '재고 수량',
    description TEXT            NULL                    COMMENT '상품 설명',
    image_url   VARCHAR(500)    NULL                    COMMENT '상품 이미지 URL',
    created_at  DATETIME        NOT NULL                COMMENT '등록일시',
    updated_at  DATETIME        NOT NULL                COMMENT '수정일시',
    PRIMARY KEY (product_id),
    KEY idx_product_category (category_id),
    CONSTRAINT fk_product_category FOREIGN KEY (category_id) REFERENCES category (category_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='상품';

-- ---------------------------------------------------------------------
-- cart (장바구니) - 회원당 1개
-- ---------------------------------------------------------------------
CREATE TABLE cart (
    cart_id     BIGINT  NOT NULL AUTO_INCREMENT COMMENT '장바구니 ID',
    member_id   BIGINT  NOT NULL                COMMENT '회원 ID (FK, UNIQUE)',
    PRIMARY KEY (cart_id),
    UNIQUE KEY uk_cart_member (member_id),
    CONSTRAINT fk_cart_member FOREIGN KEY (member_id) REFERENCES member (member_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='장바구니';

-- ---------------------------------------------------------------------
-- cart_item (장바구니 상품)
-- ---------------------------------------------------------------------
CREATE TABLE cart_item (
    cart_item_id BIGINT NOT NULL AUTO_INCREMENT COMMENT '장바구니 상품 ID',
    cart_id      BIGINT NOT NULL                COMMENT '장바구니 ID (FK)',
    product_id   BIGINT NOT NULL                COMMENT '상품 ID (FK)',
    quantity     INT    NOT NULL                COMMENT '수량',
    PRIMARY KEY (cart_item_id),
    KEY idx_cart_item_cart (cart_id),
    KEY idx_cart_item_product (product_id),
    CONSTRAINT fk_cart_item_cart    FOREIGN KEY (cart_id)    REFERENCES cart (cart_id),
    CONSTRAINT fk_cart_item_product FOREIGN KEY (product_id) REFERENCES product (product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='장바구니 상품';

-- ---------------------------------------------------------------------
-- coupon (쿠폰)
-- ---------------------------------------------------------------------
CREATE TABLE coupon (
    coupon_id        BIGINT       NOT NULL AUTO_INCREMENT COMMENT '쿠폰 ID',
    name             VARCHAR(100) NOT NULL                COMMENT '쿠폰명',
    discount_type    ENUM('FIXED','PERCENT') NOT NULL     COMMENT '할인 방식(정액/정률)',
    discount_value   INT          NOT NULL                COMMENT '할인 금액 또는 할인율',
    min_order_amount INT          NULL                    COMMENT '최소 주문 금액',
    expired_at       DATETIME     NULL                    COMMENT '만료일시',
    PRIMARY KEY (coupon_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='쿠폰';

-- ---------------------------------------------------------------------
-- member_coupon (회원 보유 쿠폰)
-- ---------------------------------------------------------------------
CREATE TABLE member_coupon (
    member_coupon_id BIGINT  NOT NULL AUTO_INCREMENT COMMENT '회원 쿠폰 ID',
    member_id        BIGINT  NOT NULL                COMMENT '회원 ID (FK)',
    coupon_id        BIGINT  NOT NULL                COMMENT '쿠폰 ID (FK)',
    is_used          BOOLEAN NOT NULL DEFAULT FALSE  COMMENT '사용 여부',
    used_at          DATETIME NULL                   COMMENT '사용일시',
    PRIMARY KEY (member_coupon_id),
    KEY idx_member_coupon_member (member_id),
    KEY idx_member_coupon_coupon (coupon_id),
    CONSTRAINT fk_member_coupon_member FOREIGN KEY (member_id) REFERENCES member (member_id),
    CONSTRAINT fk_member_coupon_coupon FOREIGN KEY (coupon_id) REFERENCES coupon (coupon_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='회원 보유 쿠폰';

-- ---------------------------------------------------------------------
-- orders (주문)  ※ order는 SQL 예약어라 orders
-- ---------------------------------------------------------------------
CREATE TABLE orders (
    order_id         BIGINT       NOT NULL AUTO_INCREMENT COMMENT '주문 ID',
    member_id        BIGINT       NOT NULL                COMMENT '회원 ID (FK)',
    member_coupon_id BIGINT       NULL                    COMMENT '적용 쿠폰 ID (FK, nullable)',
    receiver_name    VARCHAR(50)  NOT NULL                COMMENT '수령인 이름',
    receiver_phone   VARCHAR(20)  NOT NULL                COMMENT '수령인 전화번호',
    address          VARCHAR(255) NOT NULL                COMMENT '배송지',
    total_price      INT          NOT NULL                COMMENT '주문 상품 합계',
    discount_amount  INT          NOT NULL DEFAULT 0      COMMENT '쿠폰 할인 금액',
    final_price      INT          NOT NULL                COMMENT '최종 결제 금액',
    status           ENUM('PENDING','PAID','CANCELLED') NOT NULL COMMENT '주문 상태',
    created_at       DATETIME     NOT NULL                COMMENT '주문일시',
    PRIMARY KEY (order_id),
    KEY idx_orders_member (member_id),
    KEY idx_orders_member_coupon (member_coupon_id),
    CONSTRAINT fk_orders_member        FOREIGN KEY (member_id)        REFERENCES member (member_id),
    CONSTRAINT fk_orders_member_coupon FOREIGN KEY (member_coupon_id) REFERENCES member_coupon (member_coupon_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='주문';

-- ---------------------------------------------------------------------
-- order_item (주문 상품) - 주문 시점 스냅샷 포함
-- ---------------------------------------------------------------------
CREATE TABLE order_item (
    order_item_id BIGINT       NOT NULL AUTO_INCREMENT COMMENT '주문 상품 ID',
    order_id      BIGINT       NOT NULL                COMMENT '주문 ID (FK)',
    product_id    BIGINT       NOT NULL                COMMENT '상품 ID (FK)',
    product_name  VARCHAR(200) NOT NULL                COMMENT '주문 시점 상품명(스냅샷)',
    price         INT          NOT NULL                COMMENT '주문 시점 가격(스냅샷)',
    quantity      INT          NOT NULL                COMMENT '수량',
    PRIMARY KEY (order_item_id),
    KEY idx_order_item_order (order_id),
    KEY idx_order_item_product (product_id),
    CONSTRAINT fk_order_item_order   FOREIGN KEY (order_id)   REFERENCES orders (order_id),
    CONSTRAINT fk_order_item_product FOREIGN KEY (product_id) REFERENCES product (product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='주문 상품';

-- ---------------------------------------------------------------------
-- payment (결제) - 주문당 1건
-- ---------------------------------------------------------------------
CREATE TABLE payment (
    payment_id  BIGINT       NOT NULL AUTO_INCREMENT COMMENT '결제 ID',
    order_id    BIGINT       NOT NULL                COMMENT '주문 ID (FK, UNIQUE)',
    payment_key VARCHAR(200) NULL                    COMMENT '토스페이먼츠 결제 키',
    method      VARCHAR(50)  NULL                    COMMENT '결제 수단',
    amount      INT          NOT NULL                COMMENT '결제 금액',
    status      ENUM('SUCCESS','FAIL') NOT NULL       COMMENT '결제 상태',
    approved_at DATETIME     NULL                    COMMENT '결제 승인일시',
    PRIMARY KEY (payment_id),
    UNIQUE KEY uk_payment_order (order_id),
    CONSTRAINT fk_payment_order FOREIGN KEY (order_id) REFERENCES orders (order_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='결제';
