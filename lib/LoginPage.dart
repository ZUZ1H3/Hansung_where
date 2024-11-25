import 'package:flutter/material.dart';
import 'package:hansung_where/theme/colors.dart';
import 'DbConn.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'MyCookieJar.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _studentIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String infoMessage = "학번/비밀번호로 로그인이 가능합니다.";
  final String logTag = "Login"; // Logcat 필터 태그
  bool _isLoginChecked = false; // 체크 상태를 저장하는 변수

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _studentIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login(String studentId, String password) async {
    final cookieJar = MyCookieJar();
    try {
      final initialResponse = await http.get(Uri.parse("https://learn.hansung.ac.kr/login/index.php"));
      final initialCookies = initialResponse.headers['set-cookie']?.split(', ') ?? [];
      cookieJar.saveFromResponse(Uri.parse("https://learn.hansung.ac.kr"), initialCookies);

      print('Initial cookies: $initialCookies');

      final response = await http.post(
        Uri.parse("https://learn.hansung.ac.kr/login/index.php"),
        body: {
          'username': studentId,
          'password': password,
        },
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          ...cookieJar.loadForRequest(Uri.parse("https://learn.hansung.ac.kr")),
        },
      );

      if (response.statusCode == 200) {
        // HTML 응답 파싱
        final document = parse(response.body);
        final bodyText = document.body?.text ?? "";

        // 로그인 성공 여부 판단
        if (!bodyText.contains("잘못 입력")) { // 성공 조건
          _showToast("로그인 성공!");

          // 로그인 후 받은 쿠키 저장
          final loginCookies = response.headers['set-cookie']?.split(', ') ?? [];
          cookieJar.saveFromResponse(Uri.parse("https://learn.hansung.ac.kr"), loginCookies);

          // 사용자 정보를 DB에 저장
          await DbConn.saveUser(studentId); // DbConn의 saveUser 호출

          // 자동 로그인 상태 저장 (SharedPreferences 사용 예시)
          if (_isLoginChecked) {
            final prefs = await SharedPreferences.getInstance();
            prefs.setString('studentId', studentId);
            prefs.setBool('isLoggedIn', true);
          }
        } else {
          infoMessage = "아이디 또는 비밀번호가 잘못되었습니다.";
        }
      } else { // 서버 응답이 200이 아닌 경우
        _showToast("서버 오류: ${response.statusCode}");
      }
    } catch (e) { // 네트워크 오류 처리
      _showToast("서버와 연결할 수 없습니다. 다시 시도해 주세요.");
      print('Error: $e');
    }
  }

  // Toast 메시지 표시 함수
  void _showToast(String message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: ColorStyles.mainBlue,
        textColor: Colors.white,
        fontSize: 16
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 25),
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    // 뒤로 가기
                  },
                  child: const ImageIcon(
                    AssetImage('assets/icons/ic_back.png'),
                  ),
                ),
                const SizedBox(width: 112),
                const Text(
                  '로그인',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 82),
            Row(
              mainAxisAlignment: MainAxisAlignment.center, // 중앙 배치
              children: const [
                ImageIcon(
                  AssetImage('assets/icons/ic_pin.png'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center, // 중앙 배치
              children: const [
                Text(
                  '찾아부기',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 57),
            Row(
              children: [
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    infoMessage, // 동적으로 설정된 문자열
                    style: const TextStyle(
                      fontSize: 12,
                      color: ColorStyles.navGrey,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: 316,
              height: 42,
              child: TextField(
                controller: _studentIdController,
                decoration: InputDecoration(
                  hintText: '학번 입력',
                  hintStyle:
                  TextStyle(fontSize: 14, color: ColorStyles.editGrey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  enabledBorder: OutlineInputBorder(
                    borderSide:
                    BorderSide(color: ColorStyles.borderGrey),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                    BorderSide(color: ColorStyles.mainBlue),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: 316,
              height: 42,
              child: TextField(
                obscureText: true,
                controller: _passwordController,
                decoration: InputDecoration(
                  hintText: '비밀번호 입력',
                  hintStyle:
                  TextStyle(fontSize: 14, color: ColorStyles.editGrey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  enabledBorder: OutlineInputBorder(
                    borderSide:
                    BorderSide(color: ColorStyles.borderGrey),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                    BorderSide(color: ColorStyles.mainBlue),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Checkbox(
                  value: _isLoginChecked,
                  onChanged: (bool? newValue) {
                    setState(() {
                      _isLoginChecked = newValue ?? false;
                    });
                  },
                ),
                const Text(
                  '자동 로그인',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                final studentId = _studentIdController.text;
                final password = _passwordController.text;
                if (studentId.isEmpty || password.isEmpty) {
                  _showToast("아이디와 비밀번호를 입력해 주세요.");
                } else {
                  _login(studentId, password);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorStyles.mainBlue,
                fixedSize: const Size(316, 48),
              ),
              child: const Text('로그인'),
            ),
          ],
        ),
      ),
    );
  }
}
