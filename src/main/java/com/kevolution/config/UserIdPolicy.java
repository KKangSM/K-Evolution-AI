package com.kevolution.config;

import java.util.regex.Pattern;

/**
 * 아이디 정책 검증.
 * 영문 소문자로 시작하고, 영문 소문자·숫자만으로 4~20자.
 * (숫자만으로 된 아이디 방지 — 반드시 첫 글자가 영문)
 */
public final class UserIdPolicy {

    private static final Pattern PATTERN = Pattern.compile("^[a-z][a-z0-9]{3,19}$");

    private UserIdPolicy() {}

    public static void validate(String userId) {
        if (userId == null || !PATTERN.matcher(userId).matches()) {
            throw new IllegalArgumentException(
                    "아이디는 영문 소문자로 시작하고 영문 소문자·숫자 4~20자여야 합니다.");
        }
    }
}
