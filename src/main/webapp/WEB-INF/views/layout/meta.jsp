<%@ page contentType="text/html; charset=UTF-8" %>
<%-- 공통 <head> 리소스(meta·웹폰트·Bootstrap·테마 CSS). 각 페이지의 <title> 아래에서 include 한다. --%>
<meta name="viewport" content="width=device-width, initial-scale=1">
<%-- Pretendard: 한글 화면을 가장 깔끔하게 만들어 주는 가변 웹폰트 --%>
<link rel="stylesheet" as="style" crossorigin
      href="https://cdn.jsdelivr.net/gh/orioncactus/pretendard@v1.3.9/dist/web/variable/pretendardvariable.min.css">
<%-- Bootstrap 5.3 --%>
<link rel="stylesheet"
      href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
<%-- Bootstrap Icons --%>
<link rel="stylesheet"
      href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
<%-- 전역 테마 (Bootstrap 다음에 로드) --%>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/theme.css">
