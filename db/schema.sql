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
DROP TABLE IF EXISTS terms;
DROP TABLE IF EXISTS return_request;
DROP TABLE IF EXISTS point_history;
DROP TABLE IF EXISTS notice;
DROP TABLE IF EXISTS qna;
DROP TABLE IF EXISTS wishlist;
DROP TABLE IF EXISTS banner;
DROP TABLE IF EXISTS delivery;
DROP TABLE IF EXISTS member_address;
DROP TABLE IF EXISTS review_image;
DROP TABLE IF EXISTS review;
DROP TABLE IF EXISTS product_option;
DROP TABLE IF EXISTS product_image;
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
    member_id   CHAR(36)        NOT NULL                COMMENT 'PK · UUID (비순차/비추측)',
    user_id     VARCHAR(50)     NOT NULL                COMMENT '로그인 아이디',
    password    VARCHAR(255)    NOT NULL                COMMENT '암호화된 비밀번호(BCrypt)',
    ci          VARCHAR(500)    NULL                    COMMENT '휴대폰 본인인증 고유번호(CI) AES-256',
    role        ENUM('USER','ADMIN')        NOT NULL    COMMENT '권한',
    status      ENUM('ACTIVE','WITHDRAWN')  NOT NULL    COMMENT '계정 상태(soft-delete)',
    name        VARCHAR(50)     NOT NULL                COMMENT '회원명',
    phone       VARCHAR(100)    NULL                    COMMENT '전화번호 AES-256',
    address     VARCHAR(500)    NULL                    COMMENT '기본 배송지 AES-256',
    created_at  DATETIME        NOT NULL                COMMENT '가입일시',
    updated_at  DATETIME        NOT NULL                COMMENT '수정일시',
    PRIMARY KEY (member_id),
    UNIQUE KEY uk_member_user_id (user_id),
    UNIQUE KEY uk_member_ci (ci)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='회원';

-- ---------------------------------------------------------------------
-- category (카테고리)
-- ---------------------------------------------------------------------
CREATE TABLE category (
    category_id BIGINT      NOT NULL AUTO_INCREMENT COMMENT '카테고리 ID',
    parent_id   BIGINT      NULL                    COMMENT '상위 카테고리 ID (대분류면 NULL)',
    name        VARCHAR(50) NOT NULL                COMMENT '카테고리명',
    PRIMARY KEY (category_id),
    KEY idx_category_parent (parent_id),
    CONSTRAINT fk_category_parent FOREIGN KEY (parent_id) REFERENCES category (category_id)
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
    cart_id     BIGINT   NOT NULL AUTO_INCREMENT COMMENT '장바구니 ID',
    member_id   CHAR(36) NOT NULL                COMMENT '회원 ID (FK, UNIQUE)',
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
    member_coupon_id BIGINT   NOT NULL AUTO_INCREMENT COMMENT '회원 쿠폰 ID',
    member_id        CHAR(36) NOT NULL                COMMENT '회원 ID (FK)',
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
    member_id        CHAR(36)     NOT NULL                COMMENT '회원 ID (FK)',
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

-- =====================================================================
-- 확장 테이블 (리뷰/이미지/옵션/배송/배송지/배너/찜/문의/공지/적립금/반품)
-- =====================================================================

-- ---------------------------------------------------------------------
-- product_image (상품 이미지 - 상품당 여러 장)
-- ---------------------------------------------------------------------
CREATE TABLE product_image (
    image_id     BIGINT       NOT NULL AUTO_INCREMENT COMMENT '이미지 ID',
    product_id   BIGINT       NOT NULL                COMMENT '상품 ID (FK)',
    image_url    VARCHAR(500) NOT NULL                COMMENT '이미지 URL',
    sort_order   INT          NOT NULL DEFAULT 0      COMMENT '노출 순서',
    is_thumbnail BOOLEAN      NOT NULL DEFAULT FALSE  COMMENT '대표(썸네일) 여부',
    PRIMARY KEY (image_id),
    KEY idx_product_image_product (product_id),
    CONSTRAINT fk_product_image_product FOREIGN KEY (product_id) REFERENCES product (product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='상품 이미지';

-- ---------------------------------------------------------------------
-- product_option (상품 옵션 + 옵션별 재고)
-- ---------------------------------------------------------------------
CREATE TABLE product_option (
    option_id    BIGINT      NOT NULL AUTO_INCREMENT COMMENT '옵션 ID',
    product_id   BIGINT      NOT NULL                COMMENT '상품 ID (FK)',
    option_name  VARCHAR(50) NOT NULL                COMMENT '옵션 종류명 (예: 색상)',
    option_value VARCHAR(50) NOT NULL                COMMENT '옵션 값 (예: 블랙)',
    extra_price  INT         NOT NULL DEFAULT 0      COMMENT '옵션 추가금',
    stock        INT         NOT NULL DEFAULT 0      COMMENT '옵션별 재고',
    PRIMARY KEY (option_id),
    KEY idx_product_option_product (product_id),
    CONSTRAINT fk_product_option_product FOREIGN KEY (product_id) REFERENCES product (product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='상품 옵션';

-- ---------------------------------------------------------------------
-- review (상품 리뷰)
-- ---------------------------------------------------------------------
CREATE TABLE review (
    review_id     BIGINT   NOT NULL AUTO_INCREMENT COMMENT '리뷰 ID',
    product_id    BIGINT   NOT NULL                COMMENT '상품 ID (FK)',
    member_id     CHAR(36) NOT NULL                COMMENT '작성 회원 ID (FK)',
    order_item_id BIGINT   NULL                    COMMENT '구매 주문 상품 ID (FK, 구매 검증용)',
    rating        INT      NOT NULL                COMMENT '별점 1~5',
    content       TEXT     NULL                    COMMENT '리뷰 내용',
    created_at    DATETIME NOT NULL                COMMENT '작성일시',
    PRIMARY KEY (review_id),
    KEY idx_review_product (product_id),
    KEY idx_review_member (member_id),
    KEY idx_review_order_item (order_item_id),
    CONSTRAINT fk_review_product    FOREIGN KEY (product_id)    REFERENCES product (product_id),
    CONSTRAINT fk_review_member     FOREIGN KEY (member_id)     REFERENCES member (member_id),
    CONSTRAINT fk_review_order_item FOREIGN KEY (order_item_id) REFERENCES order_item (order_item_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='상품 리뷰';

-- ---------------------------------------------------------------------
-- review_image (리뷰 첨부 이미지)
-- ---------------------------------------------------------------------
CREATE TABLE review_image (
    image_id   BIGINT       NOT NULL AUTO_INCREMENT COMMENT '이미지 ID',
    review_id  BIGINT       NOT NULL                COMMENT '리뷰 ID (FK)',
    image_url  VARCHAR(500) NOT NULL                COMMENT '이미지 URL',
    sort_order INT          NOT NULL DEFAULT 0      COMMENT '노출 순서',
    PRIMARY KEY (image_id),
    KEY idx_review_image_review (review_id),
    CONSTRAINT fk_review_image_review FOREIGN KEY (review_id) REFERENCES review (review_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='리뷰 이미지';

-- ---------------------------------------------------------------------
-- member_address (회원 배송지 주소록) - 개인정보 AES-256 암호화 저장
-- ---------------------------------------------------------------------
CREATE TABLE member_address (
    address_id     BIGINT       NOT NULL AUTO_INCREMENT COMMENT '배송지 ID',
    member_id      CHAR(36)     NOT NULL                COMMENT '회원 ID (FK)',
    recipient      VARCHAR(50)  NOT NULL                COMMENT '받는 사람',
    phone          VARCHAR(100) NULL                    COMMENT '연락처(암호화)',
    zipcode        VARCHAR(20)  NULL                    COMMENT '우편번호',
    address        VARCHAR(500) NULL                    COMMENT '주소(암호화)',
    address_detail VARCHAR(500) NULL                    COMMENT '상세주소(암호화)',
    default_address BOOLEAN     NOT NULL DEFAULT FALSE  COMMENT '기본 배송지 여부',
    PRIMARY KEY (address_id),
    KEY idx_member_address_member (member_id),
    CONSTRAINT fk_member_address_member FOREIGN KEY (member_id) REFERENCES member (member_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='회원 배송지';

-- ---------------------------------------------------------------------
-- delivery (배송 정보) - 주문당 1건
-- ---------------------------------------------------------------------
CREATE TABLE delivery (
    delivery_id  BIGINT       NOT NULL AUTO_INCREMENT COMMENT '배송 ID',
    order_id     BIGINT       NOT NULL                COMMENT '주문 ID (FK, UNIQUE)',
    courier      VARCHAR(50)  NULL                    COMMENT '택배사',
    tracking_no  VARCHAR(100) NULL                    COMMENT '송장번호',
    status       ENUM('READY','SHIPPED','IN_TRANSIT','DELIVERED') NOT NULL COMMENT '배송 상태',
    recipient    VARCHAR(50)  NULL                    COMMENT '받는 사람',
    address      VARCHAR(255) NULL                    COMMENT '배송지',
    delivered_at DATETIME     NULL                    COMMENT '배송 완료일시',
    PRIMARY KEY (delivery_id),
    UNIQUE KEY uk_delivery_order (order_id),
    CONSTRAINT fk_delivery_order FOREIGN KEY (order_id) REFERENCES orders (order_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='배송';

-- ---------------------------------------------------------------------
-- banner (메인 캐러셀/이벤트 배너)
-- ---------------------------------------------------------------------
CREATE TABLE banner (
    banner_id  BIGINT       NOT NULL AUTO_INCREMENT COMMENT '배너 ID',
    image_url  VARCHAR(500) NOT NULL                COMMENT '배너 이미지 URL',
    link_url   VARCHAR(500) NULL                    COMMENT '클릭 이동 URL',
    title      VARCHAR(100) NULL                    COMMENT '배너 제목',
    sort_order INT          NOT NULL DEFAULT 0      COMMENT '노출 순서',
    is_active  BOOLEAN      NOT NULL DEFAULT TRUE   COMMENT '노출 여부',
    start_at   DATETIME     NULL                    COMMENT '노출 시작',
    end_at     DATETIME     NULL                    COMMENT '노출 종료',
    PRIMARY KEY (banner_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='배너';

-- ---------------------------------------------------------------------
-- wishlist (찜) - 회원+상품 유일
-- ---------------------------------------------------------------------
CREATE TABLE wishlist (
    wishlist_id BIGINT   NOT NULL AUTO_INCREMENT COMMENT '찜 ID',
    member_id   CHAR(36) NOT NULL                COMMENT '회원 ID (FK)',
    product_id  BIGINT   NOT NULL                COMMENT '상품 ID (FK)',
    created_at  DATETIME NOT NULL                COMMENT '찜한 일시',
    PRIMARY KEY (wishlist_id),
    UNIQUE KEY uk_wishlist_member_product (member_id, product_id),
    KEY idx_wishlist_product (product_id),
    CONSTRAINT fk_wishlist_member  FOREIGN KEY (member_id)  REFERENCES member (member_id),
    CONSTRAINT fk_wishlist_product FOREIGN KEY (product_id) REFERENCES product (product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='찜';

-- ---------------------------------------------------------------------
-- qna (상품 문의 / 1:1 문의) - product_id NULL이면 일반 문의
-- ---------------------------------------------------------------------
CREATE TABLE qna (
    qna_id      BIGINT       NOT NULL AUTO_INCREMENT COMMENT '문의 ID',
    member_id   CHAR(36)     NOT NULL                COMMENT '작성 회원 ID (FK)',
    product_id  BIGINT       NULL                    COMMENT '상품 ID (FK, 상품문의면)',
    title       VARCHAR(200) NOT NULL                COMMENT '제목',
    content     TEXT         NOT NULL                COMMENT '내용',
    answer      TEXT         NULL                    COMMENT '답변',
    answered_at DATETIME     NULL                    COMMENT '답변일시',
    is_secret   BOOLEAN      NOT NULL DEFAULT FALSE  COMMENT '비밀글 여부',
    created_at  DATETIME     NOT NULL                COMMENT '작성일시',
    PRIMARY KEY (qna_id),
    KEY idx_qna_member (member_id),
    KEY idx_qna_product (product_id),
    CONSTRAINT fk_qna_member  FOREIGN KEY (member_id)  REFERENCES member (member_id),
    CONSTRAINT fk_qna_product FOREIGN KEY (product_id) REFERENCES product (product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='문의';

-- ---------------------------------------------------------------------
-- notice (공지사항)
-- ---------------------------------------------------------------------
CREATE TABLE notice (
    notice_id  BIGINT       NOT NULL AUTO_INCREMENT COMMENT '공지 ID',
    title      VARCHAR(200) NOT NULL                COMMENT '제목',
    content    TEXT         NOT NULL                COMMENT '내용',
    is_pinned  BOOLEAN      NOT NULL DEFAULT FALSE  COMMENT '상단 고정 여부',
    view_count INT          NOT NULL DEFAULT 0      COMMENT '조회수',
    created_at DATETIME     NOT NULL                COMMENT '작성일시',
    updated_at DATETIME     NOT NULL                COMMENT '수정일시',
    PRIMARY KEY (notice_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='공지사항';

-- ---------------------------------------------------------------------
-- point_history (적립금 내역)
-- ---------------------------------------------------------------------
CREATE TABLE point_history (
    point_history_id BIGINT       NOT NULL AUTO_INCREMENT COMMENT '적립금 내역 ID',
    member_id        CHAR(36)     NOT NULL                COMMENT '회원 ID (FK)',
    amount           INT          NOT NULL                COMMENT '변동 금액(적립+/사용-)',
    balance          INT          NOT NULL                COMMENT '변동 후 잔액',
    type             ENUM('EARN','USE','EXPIRE','CANCEL') NOT NULL COMMENT '유형',
    description      VARCHAR(200) NULL                    COMMENT '설명',
    created_at       DATETIME     NOT NULL                COMMENT '발생일시',
    PRIMARY KEY (point_history_id),
    KEY idx_point_history_member (member_id),
    CONSTRAINT fk_point_history_member FOREIGN KEY (member_id) REFERENCES member (member_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='적립금 내역';

-- ---------------------------------------------------------------------
-- terms (약관)
-- ---------------------------------------------------------------------
CREATE TABLE terms (
    term_id     BIGINT       NOT NULL AUTO_INCREMENT COMMENT '약관 ID',
    type        ENUM('SERVICE','PRIVACY') NOT NULL   COMMENT '약관 유형 (SERVICE:이용약관 / PRIVACY:개인정보처리방침)',
    title       VARCHAR(100) NOT NULL                COMMENT '약관 제목',
    content     LONGTEXT     NOT NULL                COMMENT '약관 HTML 내용',
    is_required BOOLEAN      NOT NULL DEFAULT TRUE   COMMENT '필수 동의 여부',
    is_active   BOOLEAN      NOT NULL DEFAULT TRUE   COMMENT '활성 여부 (회원가입 화면 노출)',
    created_at  DATETIME     NOT NULL                COMMENT '등록일시',
    PRIMARY KEY (term_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='약관';

-- ---------------------------------------------------------------------
-- return_request (반품/교환 요청) - order_item 단위
-- ---------------------------------------------------------------------
CREATE TABLE return_request (
    return_id     BIGINT   NOT NULL AUTO_INCREMENT COMMENT '반품/교환 ID',
    order_item_id BIGINT   NOT NULL                COMMENT '주문 상품 ID (FK)',
    member_id     CHAR(36) NOT NULL                COMMENT '회원 ID (FK)',
    type          ENUM('RETURN','EXCHANGE') NOT NULL COMMENT '반품/교환 구분',
    reason        TEXT     NULL                    COMMENT '사유',
    status        ENUM('REQUESTED','APPROVED','REJECTED','COMPLETED') NOT NULL COMMENT '처리 상태',
    created_at    DATETIME NOT NULL                COMMENT '신청일시',
    processed_at  DATETIME NULL                    COMMENT '처리일시',
    PRIMARY KEY (return_id),
    KEY idx_return_order_item (order_item_id),
    KEY idx_return_member (member_id),
    CONSTRAINT fk_return_order_item FOREIGN KEY (order_item_id) REFERENCES order_item (order_item_id),
    CONSTRAINT fk_return_member     FOREIGN KEY (member_id)     REFERENCES member (member_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='반품/교환 요청';
