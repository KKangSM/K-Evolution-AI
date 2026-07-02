package com.kevolution.product.entity;

/**
 * 상품 카테고리 — 고정 세트.
 * 개인몰 규모라 DB 관리 대신 enum 으로 관리한다. 칸을 추가/수정하려면 여기만 고치면
 * 헤더·메인·상품 필터·관리자 폼에 모두 반영된다. (노출 순서 = 선언 순서)
 */
public enum Category {

    CLOTHING("의류", "clothing"),
    SHOES("신발", "shoes"),
    BAG("가방", "bag"),
    ACCESSORY("액세서리", "accessory"),
    BEAUTY("뷰티", "beauty"),
    DIGITAL("디지털", "digital"),
    LIVING("리빙", "living"),
    FOOD("식품", "food");

    /** 화면 표시명 */
    private final String label;

    /** 메인 아이콘 파일명 (static/images/category/{icon}.svg) */
    private final String icon;

    Category(String label, String icon) {
        this.label = label;
        this.icon = icon;
    }

    public String getLabel() {
        return label;
    }

    public String getIcon() {
        return icon;
    }

    /** 요청 파라미터 → enum. 없거나 잘못된 값이면 null (= 카테고리 없음/전체) */
    public static Category fromNameOrNull(String name) {
        if (name == null || name.isBlank()) return null;
        try {
            return valueOf(name);
        } catch (IllegalArgumentException e) {
            return null;
        }
    }
}
