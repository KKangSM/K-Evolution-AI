package com.kevolution.config;

import org.springframework.util.StringUtils;

/**
 * 입력값 공통 검증 유틸. 컨트롤러마다 흩어지던 빈값 체크를 한 곳에서 관리한다.
 * 내부적으로 Spring 의 StringUtils.hasText 를 사용한다.
 */
public final class ValidationUtils {

    private ValidationUtils() {}

    /** null 이거나 공백만으로 이루어졌으면 true */
    public static boolean isBlank(String s) {
        return !StringUtils.hasText(s);
    }

    /** 주어진 값 중 하나라도 비어있으면(null/공백) true */
    public static boolean isAnyBlank(String... values) {
        for (String v : values) {
            if (isBlank(v)) return true;
        }
        return false;
    }
}
