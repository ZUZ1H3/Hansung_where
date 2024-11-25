import 'package:http/http.dart' as http;

class MyCookieJar {
  final Map<Uri, List<String>> _cookies = {};

  // 쿠키 저장
  void saveFromResponse(Uri uri, List<String> cookies) {
    _cookies[uri] = cookies;
  }

  // 요청 시 쿠키 로드
  Map<String, String> loadForRequest(Uri uri) {
    final cookies = _cookies[uri] ?? [];
    return {
      'Cookie': cookies.join('; '),
    };
  }
}
