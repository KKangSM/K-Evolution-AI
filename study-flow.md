# K-Evolution 프로젝트 학습 흐름 정리

---

## 1. 전체 아키텍처 흐름

```
브라우저 요청
    ↓
Spring Security (인증/권한 체크)
    ↓
Controller (요청 받아서 Service 호출)
    ↓
Service (비즈니스 로직 처리)
    ↓
Repository (DB 쿼리 실행)
    ↓
MySQL DB
    ↓
Entity 객체로 반환
    ↓
Controller → Model에 데이터 담아서
    ↓
Thymeleaf 템플릿 (HTML 렌더링)
    ↓
브라우저에 HTML 응답
```

---

## 2. DB 연결 (application.properties)

```properties
spring.datasource.url=jdbc:mysql://127.0.0.1:3306/k-evolution?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=Asia/Seoul&characterEncoding=UTF-8
spring.datasource.username=root
spring.datasource.password=1234
spring.datasource.driver-class-name=com.mysql.cj.jdbc.Driver

spring.jpa.hibernate.ddl-auto=update   # 앱 실행 시 엔티티 기반으로 테이블 자동 생성/수정
spring.jpa.show-sql=true               # 실행되는 SQL을 콘솔에 출력 (개발 시 확인용)
```

### 핵심 포인트
- `localhost` 대신 `127.0.0.1` 사용 → Windows에서 MySQL 드라이버가 localhost를 호스트명으로 오인하는 문제 방지
- `allowPublicKeyRetrieval=true` → MySQL 8.0에서 인증 방식(caching_sha2_password) 때문에 필요
- `ddl-auto=update` → 개발 중에 사용. 운영 환경에서는 `validate` 또는 `none`으로 변경해야 함

---

## 3. Entity (JPA 엔티티)

엔티티는 DB 테이블과 1:1로 매핑되는 Java 클래스다.

### Member.java 핵심 구조

```java
@Entity               // 이 클래스가 DB 테이블과 매핑된다고 선언
@Table(name = "member") // 매핑할 테이블 이름
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED) // JPA는 기본 생성자가 필요. protected로 외부 직접 생성 막음
public class Member {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY) // AUTO_INCREMENT
    private Long memberId;

    @Column(nullable = false, unique = true, length = 100)
    private String email;

    @Enumerated(EnumType.STRING) // Enum을 문자열로 DB에 저장 (USER, ADMIN)
    private Role role;

    @PrePersist  // INSERT 직전 자동 실행
    protected void onCreate() { createdAt = LocalDateTime.now(); }

    @Builder     // 객체 생성 시 빌더 패턴 사용 가능
    public Member(String email, ...) { ... }
}
```

### Product.java 핵심 구조

```java
@ManyToOne(fetch = FetchType.LAZY)  // 카테고리와 N:1 관계. LAZY = 실제 사용할 때만 DB 조회
@JoinColumn(name = "category_id")   // FK 컬럼명
private Category category;

// 도메인 메서드 - 비즈니스 로직을 엔티티 안에 캡슐화
public void decreaseStock(int quantity) {
    if (this.stock < quantity) throw new IllegalStateException("재고가 부족합니다.");
    this.stock -= quantity;
}
```

### 생성된 테이블 10개
```
member, category, product, cart, cart_item,
coupon, member_coupon, orders, order_item, payment
```

---

## 4. Repository (데이터 접근)

Spring Data JPA가 인터페이스만 선언하면 구현체를 자동 생성해준다.

```java
public interface ProductRepository extends JpaRepository<Product, Long> {
    // 메서드 이름만으로 쿼리 자동 생성
    Page<Product> findByNameContainingIgnoreCase(String keyword, Pageable pageable);
    // → SELECT * FROM product WHERE LOWER(name) LIKE LOWER('%keyword%') LIMIT ...

    Page<Product> findByCategory(Category category, Pageable pageable);
    Page<Product> findByCategoryAndNameContainingIgnoreCase(Category category, String keyword, Pageable pageable);
}
```

### JpaRepository 제공 기본 메서드
- `findById(id)` → SELECT 단건
- `findAll()` → SELECT 전체
- `save(entity)` → INSERT or UPDATE
- `delete(entity)` → DELETE

---

## 5. Service (비즈니스 로직)

```java
@Service
@RequiredArgsConstructor        // final 필드를 생성자 주입으로 자동 처리 (Lombok)
@Transactional(readOnly = true) // 조회 전용 트랜잭션 (성능 최적화)
public class ProductService {

    private final ProductRepository productRepository;
    private final CategoryRepository categoryRepository;

    public Page<Product> getProducts(String keyword, Long categoryId, Pageable pageable) {
        // 조건 조합 로직: 카테고리 있음 + 검색어 있음 / 카테고리만 / 검색어만 / 전체
        if (categoryId != null) {
            Category category = categoryRepository.findById(categoryId).orElse(null);
            if (category != null) {
                if (keyword != null && !keyword.isBlank()) {
                    return productRepository.findByCategoryAndNameContainingIgnoreCase(category, keyword, pageable);
                }
                return productRepository.findByCategory(category, pageable);
            }
        }
        if (keyword != null && !keyword.isBlank()) {
            return productRepository.findByNameContainingIgnoreCase(keyword, pageable);
        }
        return productRepository.findAll(pageable);
    }
}
```

### 핵심 포인트
- Controller가 직접 Repository를 쓰지 않고 Service를 거침 → 비즈니스 로직 분리
- `@Transactional` → DB 작업 중 오류 시 자동 롤백 보장
- `readOnly = true` → 쓰기 없는 조회 메서드에 붙이면 성능 향상

---

## 6. Controller (요청 처리)

```java
@Controller              // View(HTML)를 반환하는 컨트롤러
@RequiredArgsConstructor
public class ProductController {

    @GetMapping("/products")
    public String list(
        @RequestParam(required = false) String keyword,   // 없어도 됨 (null 허용)
        @RequestParam(required = false) Long categoryId,
        @RequestParam(defaultValue = "0") int page,      // 없으면 기본값 0
        Model model                                        // 템플릿에 데이터 전달용
    ) {
        Page<Product> products = productService.getProducts(keyword, categoryId, PageRequest.of(page, 12));
        // PageRequest.of(page, 12) → page번째 페이지, 한 페이지 12개

        model.addAttribute("products", products);   // 템플릿에서 ${products}로 접근
        model.addAttribute("categories", categories);
        return "products/list";  // → templates/products/list.html 렌더링
    }

    @GetMapping("/products/{productId}")
    public String detail(@PathVariable Long productId, Model model) {
        // @PathVariable → URL 경로의 {productId} 값을 파라미터로 받음
        model.addAttribute("product", productService.getProduct(productId));
        return "products/detail";
    }
}
```

---

## 7. Spring Security 설정

### SecurityConfig.java

```java
@Bean
public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
    http
        .authorizeHttpRequests(auth -> auth
            .requestMatchers("/auth/**", "/products/**", "/").permitAll()  // 누구나 접근 가능
            .requestMatchers("/admin/**").hasRole("ADMIN")                  // ADMIN만 접근
            .anyRequest().authenticated()                                   // 나머지는 로그인 필요
        )
        .formLogin(form -> form
            .loginPage("/auth/login")           // 로그인 페이지 URL
            .loginProcessingUrl("/auth/login")  // 폼 submit 처리 URL
            .defaultSuccessUrl("/products")     // 로그인 성공 후 이동
            .usernameParameter("email")         // id 필드가 email임을 명시
        )
        .logout(logout -> logout
            .logoutUrl("/auth/logout")
            .invalidateHttpSession(true)        // 세션 삭제
            .deleteCookies("JSESSIONID")        // 쿠키 삭제
        );
}
```

### CustomUserDetailsService.java

Spring Security가 로그인 시 이메일로 사용자를 조회하는 방식을 정의한다.

```java
@Override
public UserDetails loadUserByUsername(String email) throws UsernameNotFoundException {
    Member member = memberRepository.findByEmail(email)
        .orElseThrow(() -> new UsernameNotFoundException("User not found: " + email));

    return new User(
        member.getEmail(),
        member.getPassword(),                                          // BCrypt 암호화된 비밀번호
        List.of(new SimpleGrantedAuthority("ROLE_" + member.getRole().name())) // ROLE_USER or ROLE_ADMIN
    );
}
```

### 인증 흐름
```
로그인 폼 submit (email + password)
    ↓
Spring Security가 CustomUserDetailsService.loadUserByUsername(email) 호출
    ↓
DB에서 Member 조회
    ↓
BCrypt로 비밀번호 비교
    ↓
성공 → 세션에 인증 정보 저장 → /products 이동
실패 → /auth/login?error=true 이동
```

---

## 8. Thymeleaf 템플릿

Thymeleaf는 HTML 안에 `th:` 속성으로 Java 데이터를 표현하는 서버사이드 템플릿 엔진이다.

```html
<!-- 반복 -->
<div th:each="product : ${products.content}">
    <h6 th:text="${product.name}"></h6>
</div>

<!-- 조건 -->
<span th:if="${product.stock == 0}">품절</span>

<!-- URL 생성 (파라미터 포함) -->
<a th:href="@{/products(keyword=${keyword}, page=${i})}">2</a>

<!-- 숫자 포맷 (1000 → 1,000) -->
<span th:text="${#numbers.formatInteger(product.price, 3, 'COMMA') + '원'}"></span>

<!-- 조각 삽입 (header 공통 컴포넌트) -->
<div th:replace="~{fragments/header :: header}"></div>
```

### Page 객체 (페이지네이션)
```java
// Controller에서 PageRequest.of(page, 12) 로 요청하면
// Service가 Page<Product> 반환
products.content       // 현재 페이지 상품 목록
products.totalElements // 전체 상품 수
products.totalPages    // 전체 페이지 수
products.isEmpty()     // 결과가 없으면 true
```

---

## 9. 전체 요청 흐름 예시 — "상품 목록 검색"

```
GET /products?keyword=나이키&categoryId=1&page=0
    ↓
SecurityConfig → permitAll() → 통과
    ↓
ProductController.list(keyword="나이키", categoryId=1, page=0)
    ↓
ProductService.getProducts("나이키", 1L, PageRequest.of(0, 12))
    ↓
categoryRepository.findById(1L) → Category 조회
    ↓
productRepository.findByCategoryAndNameContainingIgnoreCase(category, "나이키", pageable)
    ↓
SELECT * FROM product WHERE category_id=1 AND LOWER(name) LIKE '%나이키%' LIMIT 12
    ↓
Page<Product> 반환
    ↓
model.addAttribute("products", products)
    ↓
templates/products/list.html 렌더링
    ↓
브라우저에 HTML 응답
```

---

## 10. 기술 스택 한 줄 정리

| 기술 | 역할 |
|---|---|
| Spring Boot | 설정 자동화, 내장 톰캣으로 서버 실행 |
| Spring Data JPA | 인터페이스 선언만으로 DB CRUD 자동 구현 |
| Hibernate | JPA 구현체. SQL 자동 생성 및 실행 |
| MySQL | 실제 데이터 저장 |
| Spring Security | 로그인/로그아웃/접근 제어 |
| Thymeleaf | 서버에서 HTML 생성 (서버사이드 렌더링) |
| Lombok | @Getter, @Builder 등 반복 코드 자동 생성 |
| BCrypt | 비밀번호 단방향 암호화 |
