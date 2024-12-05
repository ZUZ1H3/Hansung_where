import 'package:http/http.dart' as http;

class MyCookieJar {
  final Map<Uri, List<String>> _cookies = {};

  // 쿠키 저장
  void saveFromResponse(Uri uri, List<String> rawCookies) {
    final cookies = <String>[];

    for (var rawCookie in rawCookies) {
      // ';' 이전의 실제 쿠키 값만 저장
      final cookie = rawCookie.split(';').first.trim();
      cookies.add(cookie);
    }

    _cookies[uri] = cookies;
    print('Saved cookies for $uri: ${_cookies[uri]}');
  }

  // 요청 시 쿠키 로드
  Map<String, String> loadForRequest(Uri uri) {
    final cookies = <String>[];

    // 도메인 호환 쿠키 병합
    _cookies.forEach((savedUri, savedCookies) {
      if (uri.host.endsWith(savedUri.host)) {
        cookies.addAll(savedCookies);
      }
    });

    print('Loaded cookies for $uri: $cookies');
    return {
      'Cookie': cookies.join('; '),
    };
  }
}
