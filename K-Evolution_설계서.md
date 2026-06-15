# K-Evolution 쇼핑몰 프로젝트 설계서

## 1. 문서 목적

1. 프로젝트 설계를 문서화하여 프로젝트의 목적, 설계를 보다 쉽게 설명하기 위해
2. 기능 및 요구사항을 정의하기 위해
3. 프로젝트의 전체적인 구조와 흐름을 설명하기 위해
4. 개발 과정에서 원활한 의사소통을 위해

---

## 2. 프로젝트 개요

1. 사용자가 상품을 조회하고 구매할 수 있는 쇼핑몰 웹 서비스를 구현한다.
2. 바이브 코딩으로 실제 작동하는 쇼핑몰을 만든다.

### 2.1 프로젝트명

**K-Evolution**

### 2.2 목표

1. 쇼핑몰의 기본적인 기능과 작업 환경 및 작업 과정을 이해하는 것이 목표이다.
2. K-Evolution은 상품 조회, 장바구니, 주문 기능을 제공하는 쇼핑몰 웹 서비스를 구현하는 것을 목표로 한다.
3. 사용자는 상품 목록과 상세 정보를 확인하고, 원하는 상품을 장바구니에 담아 주문할 수 있다.
4. 관리자는 상품 정보를 등록, 수정, 삭제할 수 있도록 한다.

### 2.3 핵심 사용자 흐름

1. 상품 조회
2. 상품 검색 및 탐색
3. 상품 상세 정보 확인
4. 장바구니 담기
5. 장바구니 관리
6. 주문 정보 확인
7. 결제 진행
8. 결제 결과 확인
9. 주문 완료

---

## 3. 개발 범위

### 3.1 포함 범위

| 구분 | 내용 |
|------|------|
| 상품 | 목록 조회, 상세 조회, 검색 |
| 장바구니 | 담기, 수정, 삭제 |
| 주문 | 주문서 작성, 주문 정보 확인 |
| 쿠폰 | 쿠폰 적용 |
| 결제 | 토스페이먼츠 결제 테스트 |
| 주문 내역 | 내역 조회 |
| 관리자 | 상품 등록, 수정, 삭제 기능 |

1. 상품 목록 조회 기능
2. 상품 상세 정보 조회 기능
3. 상품 검색 및 카테고리 필터 기능
4. 장바구니 담기, 수정, 삭제 기능
5. 주문서 작성 및 주문 정보 확인 기능
6. 쿠폰 적용 기능
7. 토스페이먼츠 테스트 결제 기능
8. 결제 결과 처리 기능
9. 주문 내역 조회 기능
10. 관리자 상품 등록, 수정, 삭제 기능

### 3.2 제외 범위

| 구분 | 내용 |
|------|------|
| 실제 결제 | 운영 결제 키 사용 및 실제 돈 거래 |
| 배송 추적 | 택배사 연동, 배송 상태 자동 갱신 |
| 회원 고도화 | 소셜 로그인, 비밀번호 찾기, 권한 세분화 |
| 정산 | 매출 정산, PG 수수료 정산 |

---

## 4. 화면 설계

### 4.1 화면 목록

| 번호 | 화면명 |
|------|--------|
| 1 | 메인 화면 |
| 2 | 상품 목록 화면 |
| 3 | 상품 상세 화면 |
| 4 | 로그인 화면 |
| 5 | 회원가입 화면 |
| 6 | 장바구니 화면 |
| 7 | 주문 확인 화면 |
| 8 | 결제 화면 |
| 9 | 결제 결과 화면 |
| 10 | 주문 내역 화면 |
| 11 | 관리자 상품 관리 화면 |

### 4.2 상품 목록 화면

#### 주요 요소

| 번호 | 요소 |
|------|------|
| 1 | 상품 목록 |
| 2 | 상품 이미지 |
| 3 | 상품명 |
| 4 | 상품 가격 |
| 5 | 상품 검색창 |
| 6 | 카테고리 선택 |
| 7 | 상품 상세보기 버튼 |
| 8 | 로그인 버튼 |
| 9 | 장바구니 버튼 |
| 10 | 관리자 메뉴 (관리자 계정 로그인 시) |

#### 동작

1. 사용자 접속 → 상품 목록 조회
2. 상품 목록 조회 → 상품 이미지, 상품명, 가격 정보 출력
3. 상품 검색어 입력 → 검색 결과 출력
4. 카테고리 선택 → 해당 카테고리 상품 목록 출력
5. 상품 선택 → 상품 상세 화면 이동
6. 로그인 버튼 클릭 → 로그인 화면 이동
7. 장바구니 버튼 클릭 → 장바구니 화면 이동
8. 관리자 로그인 → 관리자 메뉴 표시

### 4.3 상품 상세 화면

#### 주요 요소

| 번호 | 요소 |
|------|------|
| 1 | 상품 이미지 |
| 2 | 상품명 |
| 3 | 상품 가격 |
| 4 | 상품 설명 |
| 5 | 상품 재고 정보 |
| 6 | 수량 선택 |
| 7 | 장바구니 담기 버튼 |
| 8 | 구매하기 버튼 |

#### 동작

1. 상품 목록 화면에서 상품 선택 → 상품 상세 정보 조회
2. 상품 정보 조회 → 상품 이미지, 상품명, 가격, 설명, 재고 정보 출력
3. 비회원 상태에서 장바구니 담기 또는 구매하기 클릭 → 로그인 화면 이동
4. 회원 로그인 → 상품 수량 선택
5. 장바구니 담기 클릭 → 장바구니 상품 등록
6. 장바구니 등록 완료 → 장바구니 화면 이동 또는 등록 완료 메시지 출력
7. 구매하기 클릭 → 주문 정보 생성
8. 주문 정보 생성 완료 → 주문 확인 화면 이동

### 4.4 장바구니 화면

#### 주요 요소

| 번호 | 요소 |
|------|------|
| 1 | 장바구니 상품 목록 |
| 2 | 상품명 |
| 3 | 상품 가격 |
| 4 | 상품 수량 |
| 5 | 총 주문 금액 |
| 6 | 수량 변경 버튼 |
| 7 | 상품 삭제 버튼 |
| 8 | 주문하기 버튼 |

#### 동작

1. 비회원 → 장바구니 화면 접근 → 로그인 화면 이동
2. 회원 → 장바구니 상품 목록 조회 → 화면 출력
3. 수량 변경 → 장바구니 상품 수량 수정 → 총 주문 금액 재계산
4. 상품 삭제 클릭 → 장바구니 상품 삭제 → 장바구니 목록 갱신
5. 주문하기 클릭 → 주문 정보 생성 → 주문 확인 화면 이동

### 4.5 주문 확인 화면

#### 주요 요소

| 번호 | 요소 |
|------|------|
| 1 | 주문 상품 정보 |
| 2 | 주문자 정보 |
| 3 | 배송 정보 |
| 4 | 쿠폰 선택 |
| 5 | 할인 금액 |
| 6 | 최종 결제 금액 |
| 7 | 결제하기 버튼 |

#### 동작

1. 장바구니 화면 → 주문하기 클릭 → 주문 확인 화면 이동
2. 주문 상품 정보 조회 → 주문 정보 출력
3. 배송 정보 입력 → 주문 정보 저장
4. 쿠폰 선택 → 할인 금액 적용
5. 최종 결제 금액 계산 → 화면 출력
6. 결제하기 클릭 → 결제 화면 이동

### 4.6 결제 결과 화면

#### 결제 성공 화면

1. 결제 승인 완료 → 결제 정보 저장
2. 주문 상태 변경 → 주문 완료 처리
3. 주문 완료 정보 출력
4. 주문 내역 조회 화면 이동 가능

#### 결제 실패 화면

1. 결제 승인 실패 → 실패 사유 확인
2. 결제 실패 정보 출력
3. 주문 확인 화면 이동 가능
4. 결제 재시도 가능

---

## 5. 기능 설계

### 5.1 회원 (Auth)

#### 회원가입
1. 이메일, 비밀번호, 이름, 전화번호 입력
2. 이메일 중복 확인
3. 비밀번호 암호화 후 저장 (BCrypt)
4. 가입 완료 → 로그인 페이지 이동

| 유효성 검사 | 조건 |
|-------------|------|
| 이메일 | 형식 검사, 중복 불가 |
| 비밀번호 | 8자 이상 |
| 이름 | 필수 입력 |
| 전화번호 | 필수 입력 |

#### 로그인
1. 이메일, 비밀번호 입력
2. Spring Security 인증 처리
3. 인증 성공 → 세션 생성 → 메인 페이지 이동
4. 인증 실패 → 로그인 페이지 오류 메시지 출력

#### 로그아웃
1. 세션 무효화
2. 메인 페이지 이동

---

### 5.2 상품 (Product)

#### 상품 목록 조회
1. 전체 상품 목록 조회 (기본)
2. 검색어 입력 시 상품명 기준 필터링
3. 카테고리 선택 시 해당 카테고리 상품만 조회
4. 페이지네이션 적용

#### 상품 상세 조회
1. 상품 ID로 상품 정보 조회
2. 상품명, 가격, 설명, 재고, 이미지 출력
3. 재고 0인 경우 품절 표시, 장바구니/구매 버튼 비활성화

---

### 5.3 장바구니 (Cart)

#### 장바구니 담기
1. 비회원 → 로그인 페이지 이동
2. 회원 → 수량 선택 후 담기
3. 이미 담긴 상품이면 수량 합산
4. 재고 초과 수량 담기 불가

#### 장바구니 수량 수정
1. 수량 변경 → 즉시 총 주문 금액 재계산
2. 수량 1 미만 입력 불가
3. 재고 초과 수량 입력 불가

#### 장바구니 상품 삭제
1. 삭제 버튼 클릭 → 해당 상품 장바구니에서 제거
2. 장바구니 목록 갱신

---

### 5.4 주문 (Order)

#### 주문 생성
1. 장바구니 → 주문하기 클릭
2. 주문 확인 화면에서 배송 정보 입력 (수령인, 전화번호, 주소)
3. 쿠폰 선택 → 할인 금액 적용
4. 최종 결제 금액 계산 및 확인
5. 결제하기 클릭 → 토스페이먼츠 결제 위젯 호출
6. 주문 생성 시 재고 차감

| 유효성 검사 | 조건 |
|-------------|------|
| 배송 정보 | 수령인, 전화번호, 주소 필수 입력 |
| 재고 | 주문 수량 ≤ 재고 수량 |
| 장바구니 | 비어있으면 주문 불가 |

#### 주문 내역 조회
1. 로그인한 회원의 주문 목록 조회
2. 주문일시 내림차순 정렬
3. 주문 상태(PENDING / PAID / CANCELLED) 표시
4. 주문 상세 클릭 → 상세 화면 이동

---

### 5.5 쿠폰 (Coupon)

#### 쿠폰 적용
1. 주문 확인 화면에서 보유 쿠폰 목록 조회
2. 쿠폰 선택 → 할인 금액 계산
   - FIXED: 정액 할인 (예: 3,000원 할인)
   - PERCENT: 정률 할인 (예: 10% 할인)
3. 최소 주문 금액 미달 시 쿠폰 선택 불가
4. 만료된 쿠폰 선택 불가
5. 결제 완료 후 쿠폰 사용 처리 (is_used = true)

---

### 5.6 결제 (Payment)

#### 결제 진행 (토스페이먼츠)
1. 주문 확인 화면 → 결제하기 클릭
2. 토스페이먼츠 결제 위젯 호출
3. 결제 수단 선택 및 결제 진행
4. 결제 완료 → 토스페이먼츠가 `/payments/success` 또는 `/payments/fail`로 리다이렉트

#### 결제 성공 처리
1. 토스페이먼츠 서버에 결제 승인 요청 (`POST /payments/confirm`)
2. 승인 성공 → 결제 정보 저장
3. 주문 상태 변경 (PENDING → PAID)
4. 결제 성공 화면 출력

#### 결제 실패 처리
1. 실패 코드 및 메시지 확인
2. 주문 상태 유지 (PENDING)
3. 차감했던 재고 복구
4. 결제 실패 화면 출력
5. 주문 확인 화면으로 돌아가기 또는 재시도 가능

---

### 5.7 관리자 (Admin)

#### 상품 등록
1. 카테고리, 상품명, 가격, 재고, 설명, 이미지 URL 입력
2. 필수 항목 유효성 검사
3. 등록 완료 → 관리자 상품 목록 이동

#### 상품 수정
1. 상품 목록에서 수정할 상품 선택
2. 기존 정보 불러오기
3. 수정 후 저장 → 관리자 상품 목록 이동

#### 상품 삭제
1. 상품 목록에서 삭제할 상품 선택
2. 삭제 확인
3. 삭제 완료 → 관리자 상품 목록 갱신

---

## 6. 기술 스택

| 구분 | 기술 |
|------|------|
| Backend | Java 17, Spring Boot 3.x |
| Frontend | Thymeleaf, HTML/CSS, JavaScript |
| Database | MySQL 8.x |
| ORM | Spring Data JPA, Hibernate |
| Security | Spring Security |
| Build | Gradle |
| 결제 | 토스페이먼츠 SDK |
| 기타 | Lombok |

---

## 7. DB 설계

### 7.1 테이블 목록

| 테이블명 | 설명 |
|----------|------|
| member | 회원 |
| category | 상품 카테고리 |
| product | 상품 |
| cart | 장바구니 |
| cart_item | 장바구니 상품 |
| coupon | 쿠폰 |
| member_coupon | 회원 보유 쿠폰 |
| orders | 주문 |
| order_item | 주문 상품 |
| payment | 결제 |

---

### 7.2 테이블 상세

#### member (회원)

| 컬럼명 | 타입 | 제약 | 설명 |
|--------|------|------|------|
| member_id | BIGINT | PK, AUTO_INCREMENT | 회원 ID |
| email | VARCHAR(100) | UNIQUE, NOT NULL | 이메일 (로그인 ID) |
| password | VARCHAR(255) | NOT NULL | 암호화된 비밀번호 |
| name | VARCHAR(50) | NOT NULL | 회원명 |
| phone | VARCHAR(20) | | 전화번호 |
| address | VARCHAR(255) | | 기본 배송지 |
| role | ENUM | NOT NULL | USER / ADMIN |
| created_at | DATETIME | NOT NULL | 가입일시 |
| updated_at | DATETIME | NOT NULL | 수정일시 |

---

#### category (카테고리)

| 컬럼명 | 타입 | 제약 | 설명 |
|--------|------|------|------|
| category_id | BIGINT | PK, AUTO_INCREMENT | 카테고리 ID |
| name | VARCHAR(50) | NOT NULL | 카테고리명 |

---

#### product (상품)

| 컬럼명 | 타입 | 제약 | 설명 |
|--------|------|------|------|
| product_id | BIGINT | PK, AUTO_INCREMENT | 상품 ID |
| category_id | BIGINT | FK(category) | 카테고리 ID |
| name | VARCHAR(200) | NOT NULL | 상품명 |
| price | INT | NOT NULL | 판매가 |
| stock | INT | NOT NULL | 재고 수량 |
| description | TEXT | | 상품 설명 |
| image_url | VARCHAR(500) | | 상품 이미지 URL |
| created_at | DATETIME | NOT NULL | 등록일시 |
| updated_at | DATETIME | NOT NULL | 수정일시 |

---

#### cart (장바구니)

| 컬럼명 | 타입 | 제약 | 설명 |
|--------|------|------|------|
| cart_id | BIGINT | PK, AUTO_INCREMENT | 장바구니 ID |
| member_id | BIGINT | FK(member), UNIQUE | 회원 ID |

---

#### cart_item (장바구니 상품)

| 컬럼명 | 타입 | 제약 | 설명 |
|--------|------|------|------|
| cart_item_id | BIGINT | PK, AUTO_INCREMENT | 장바구니 상품 ID |
| cart_id | BIGINT | FK(cart), NOT NULL | 장바구니 ID |
| product_id | BIGINT | FK(product), NOT NULL | 상품 ID |
| quantity | INT | NOT NULL | 수량 |

---

#### coupon (쿠폰)

| 컬럼명 | 타입 | 제약 | 설명 |
|--------|------|------|------|
| coupon_id | BIGINT | PK, AUTO_INCREMENT | 쿠폰 ID |
| name | VARCHAR(100) | NOT NULL | 쿠폰명 |
| discount_type | ENUM | NOT NULL | FIXED(정액) / PERCENT(정률) |
| discount_value | INT | NOT NULL | 할인 금액 또는 할인율 |
| min_order_amount | INT | | 최소 주문 금액 |
| expired_at | DATETIME | | 만료일시 |

---

#### member_coupon (회원 보유 쿠폰)

| 컬럼명 | 타입 | 제약 | 설명 |
|--------|------|------|------|
| member_coupon_id | BIGINT | PK, AUTO_INCREMENT | 회원 쿠폰 ID |
| member_id | BIGINT | FK(member), NOT NULL | 회원 ID |
| coupon_id | BIGINT | FK(coupon), NOT NULL | 쿠폰 ID |
| is_used | BOOLEAN | DEFAULT FALSE | 사용 여부 |
| used_at | DATETIME | | 사용일시 |

---

#### orders (주문)

| 컬럼명 | 타입 | 제약 | 설명 |
|--------|------|------|------|
| order_id | BIGINT | PK, AUTO_INCREMENT | 주문 ID |
| member_id | BIGINT | FK(member), NOT NULL | 회원 ID |
| member_coupon_id | BIGINT | FK(member_coupon) | 적용 쿠폰 ID (nullable) |
| receiver_name | VARCHAR(50) | NOT NULL | 수령인 이름 |
| receiver_phone | VARCHAR(20) | NOT NULL | 수령인 전화번호 |
| address | VARCHAR(255) | NOT NULL | 배송지 |
| total_price | INT | NOT NULL | 주문 상품 합계 금액 |
| discount_amount | INT | DEFAULT 0 | 쿠폰 할인 금액 |
| final_price | INT | NOT NULL | 최종 결제 금액 |
| status | ENUM | NOT NULL | PENDING / PAID / CANCELLED |
| created_at | DATETIME | NOT NULL | 주문일시 |

---

#### order_item (주문 상품)

| 컬럼명 | 타입 | 제약 | 설명 |
|--------|------|------|------|
| order_item_id | BIGINT | PK, AUTO_INCREMENT | 주문 상품 ID |
| order_id | BIGINT | FK(orders), NOT NULL | 주문 ID |
| product_id | BIGINT | FK(product), NOT NULL | 상품 ID |
| product_name | VARCHAR(200) | NOT NULL | 주문 시점 상품명 (스냅샷) |
| price | INT | NOT NULL | 주문 시점 가격 (스냅샷) |
| quantity | INT | NOT NULL | 수량 |

---

#### payment (결제)

| 컬럼명 | 타입 | 제약 | 설명 |
|--------|------|------|------|
| payment_id | BIGINT | PK, AUTO_INCREMENT | 결제 ID |
| order_id | BIGINT | FK(orders), UNIQUE | 주문 ID |
| payment_key | VARCHAR(200) | | 토스페이먼츠 결제 키 |
| method | VARCHAR(50) | | 결제 수단 |
| amount | INT | NOT NULL | 결제 금액 |
| status | ENUM | NOT NULL | SUCCESS / FAIL |
| approved_at | DATETIME | | 결제 승인일시 |

---

### 7.3 테이블 관계도

```
member (1) ─── (1) cart (1) ─── (N) cart_item (N) ─── (1) product
  │                                                          │
  │ (1)                                                      │ (N)
  │                                                       category (1)
  ├── (N) member_coupon (N) ─── (1) coupon
  │          │
  └── (N) orders (1) ──────────┘
             │
             └── (N) order_item (N) ─── (1) product
             └── (1) payment
```

---

## 8. API 설계

### 8.1 공통 규칙

- Base URL: `/`
- 인증 방식: Spring Security 세션
- 권한 구분: 비회원 / USER / ADMIN

| 권한 | 설명 |
|------|------|
| 비회원 | 로그인 없이 접근 가능 |
| USER | 로그인한 일반 회원 |
| ADMIN | 관리자 계정 (`/admin/**` 전용) |

---

### 8.2 비회원 공개 API

누구나 접근 가능한 경로입니다.

#### 회원가입 / 로그인

| 메서드 | URL | 설명 |
|--------|-----|------|
| GET | `/auth/signup` | 회원가입 페이지 |
| POST | `/auth/signup` | 회원가입 처리 |
| GET | `/auth/login` | 로그인 페이지 |
| POST | `/auth/login` | 로그인 처리 |

#### 상품 조회

| 메서드 | URL | 설명 |
|--------|-----|------|
| GET | `/products` | 상품 목록 조회 |
| GET | `/products/{productId}` | 상품 상세 조회 |

**Query Parameter (`GET /products`)**

| 파라미터 | 타입 | 설명 |
|----------|------|------|
| keyword | String | 검색어 |
| categoryId | Long | 카테고리 ID |
| page | int | 페이지 번호 (기본값 0) |

---

### 8.3 USER 전용 API

로그인한 일반 회원만 접근 가능합니다. 비회원 접근 시 로그인 페이지로 리다이렉트됩니다.

#### 로그아웃

| 메서드 | URL | 설명 |
|--------|-----|------|
| POST | `/auth/logout` | 로그아웃 처리 |

#### 장바구니

| 메서드 | URL | 설명 |
|--------|-----|------|
| GET | `/cart` | 장바구니 조회 |
| POST | `/cart/items` | 장바구니 상품 추가 |
| PATCH | `/cart/items/{cartItemId}` | 장바구니 수량 수정 |
| DELETE | `/cart/items/{cartItemId}` | 장바구니 상품 삭제 |

**Request Body (`POST /cart/items`)**

| 필드 | 타입 | 설명 |
|------|------|------|
| productId | Long | 상품 ID |
| quantity | int | 수량 |

**Request Body (`PATCH /cart/items/{cartItemId}`)**

| 필드 | 타입 | 설명 |
|------|------|------|
| quantity | int | 변경할 수량 |

#### 쿠폰

| 메서드 | URL | 설명 |
|--------|-----|------|
| GET | `/coupons` | 보유 쿠폰 목록 조회 |

#### 주문

| 메서드 | URL | 설명 |
|--------|-----|------|
| GET | `/orders/confirm` | 주문 확인 페이지 |
| POST | `/orders` | 주문 생성 |
| GET | `/orders` | 주문 내역 목록 조회 |
| GET | `/orders/{orderId}` | 주문 상세 조회 |

**Request Body (`POST /orders`)**

| 필드 | 타입 | 설명 |
|------|------|------|
| receiverName | String | 수령인 이름 |
| receiverPhone | String | 수령인 전화번호 |
| address | String | 배송지 |
| memberCouponId | Long | 적용 쿠폰 ID (nullable) |

#### 결제

| 메서드 | URL | 설명 |
|--------|-----|------|
| POST | `/payments/confirm` | 토스페이먼츠 결제 승인 요청 |
| GET | `/payments/success` | 결제 성공 처리 및 결과 페이지 |
| GET | `/payments/fail` | 결제 실패 처리 및 결과 페이지 |

**Request Body (`POST /payments/confirm`)**

| 필드 | 타입 | 설명 |
|------|------|------|
| paymentKey | String | 토스페이먼츠 결제 키 |
| orderId | Long | 주문 ID |
| amount | int | 결제 금액 |

**Query Parameter (`GET /payments/success`)**

| 파라미터 | 타입 | 설명 |
|----------|------|------|
| paymentKey | String | 토스페이먼츠 결제 키 |
| orderId | Long | 주문 ID |
| amount | int | 결제 금액 |

**Query Parameter (`GET /payments/fail`)**

| 파라미터 | 타입 | 설명 |
|----------|------|------|
| code | String | 실패 코드 |
| message | String | 실패 메시지 |
| orderId | Long | 주문 ID |

---

### 8.4 ADMIN 전용 API

관리자 계정만 접근 가능합니다. (`/admin/**`) 비관리자 접근 시 403 반환.

#### 상품 관리

| 메서드 | URL | 설명 |
|--------|-----|------|
| GET | `/admin/products` | 상품 목록 조회 |
| GET | `/admin/products/new` | 상품 등록 페이지 |
| POST | `/admin/products` | 상품 등록 처리 |
| GET | `/admin/products/{productId}/edit` | 상품 수정 페이지 |
| PUT | `/admin/products/{productId}` | 상품 수정 처리 |
| DELETE | `/admin/products/{productId}` | 상품 삭제 |

**Request Body (`POST /admin/products`, `PUT /admin/products/{productId}`)**

| 필드 | 타입 | 설명 |
|------|------|------|
| categoryId | Long | 카테고리 ID |
| name | String | 상품명 |
| price | int | 판매가 |
| stock | int | 재고 수량 |
| description | String | 상품 설명 |
| imageUrl | String | 이미지 URL |
