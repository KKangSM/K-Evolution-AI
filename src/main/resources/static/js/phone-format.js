// 휴대폰 번호 자동 하이픈
// data-phone-format 속성이 붙은 입력칸은 숫자만 입력해도 010-1234-5678 형태로 표시된다.
(function () {
    function format(value) {
        return value.replace(/\D/g, '').slice(0, 11)
            .replace(/^(\d{0,3})(\d{0,4})(\d{0,4})$/,
                (m, a, b, c) => [a, b, c].filter(Boolean).join('-'));
    }

    document.addEventListener('DOMContentLoaded', function () {
        document.querySelectorAll('input[data-phone-format]').forEach(function (input) {
            input.addEventListener('input', function () {
                input.value = format(input.value);
            });
        });
    });
})();
