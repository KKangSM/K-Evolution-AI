package com.kevolution.config;

import java.util.regex.Pattern;

/**
 * 비밀번호 정책 검증 (회원가입·비밀번호 변경 공통).
 * 영문·숫자·특수문자를 각 1자 이상 포함하고 공백 없이 8~64자.
 * (상한 64자는 BCrypt의 72바이트 절단 이슈를 피하기 위한 여유 한도)
 */
public final class PasswordPolicy {

    private static final Pattern PATTERN = Pattern.compile(
            "^(?=.*[A-Za-z])(?=.*\\d)(?=.*[^A-Za-z0-9\\s])\\S{8,64}$");

    private PasswordPolicy() {}

    public static void validate(String password) {
        if (password == null || !PATTERN.matcher(password).matches()) {
            throw new IllegalArgumentException(
                    "비밀번호는 영문·숫자·특수문자를 모두 포함해 8자 이상(공백 불가)이어야 합니다.");
        }
    }
}
