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
  bool _isLoginChecked = false; // 자동 로그인 체크 상태를 저장
  SharedPreferences? prefs;
  bool isLogIn = false;
  bool autoLogin = false;

  @override
  void initState() {
    super.initState();
    _initPref();
  }

  @override
  void dispose() {
    _studentIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
  Future<void> _initPref() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      isLogIn = prefs?.getBool('isLogIn') ?? false;
      autoLogin = prefs?.getBool('autoLogin') ?? false;
    });
  }

  Future<void> _login() async {
    final studentId = _studentIdController.text.trim();
    final password = _passwordController.text.trim();

    if (studentId.isEmpty || password.isEmpty) {
      setState(() {
        infoMessage = "아이디와 비밀번호를 입력해 주세요.";
      });
      return;
    }

    try {
      final cookieJar = MyCookieJar();
      final initialResponse = await http.get(Uri.parse("https://learn.hansung.ac.kr/login/index.php"));
      final initialCookies = initialResponse.headers['set-cookie']?.split(', ') ?? [];
      cookieJar.saveFromResponse(Uri.parse("https://learn.hansung.ac.kr"), initialCookies);

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

          // 사용자 정보를 DB에 저장
          await DbConn.saveUser(studentId); // DbConn의 saveUser 호출
          prefs?.setString('studentId', studentId);
          prefs?.setBool('isLogIn', true);

          // 자동 로그인 상태 저장
          if (_isLoginChecked) {
            prefs?.setBool('autoLogin', true);
          } prefs?.setBool('autoLogin', false);

          Navigator.pop(context); // 이전 화면으로 이동
        } else {
          infoMessage = "아이디 또는 비밀번호가 잘못되었습니다.";
        }
      } else { // 서버 응답이 200이 아닌 경우
        print("서버 오류: ${response.statusCode}");
      }
    } catch (e) { // 네트워크 오류 처리
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
                  onTap: () => Navigator.pop(context),
                  child: const ImageIcon(AssetImage('assets/icons/ic_back.png')),
                ),
                const SizedBox(width: 108),
                const Text(
                  '로그인',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 82),
            Center(
              child: Column(
                children: [
                  Image.asset('assets/icons/ic_pin.png', width: 20, height: 32),
                  const SizedBox(height: 8),
                  const Text(
                    '찾아부기',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 57),
            Row(
              children: [
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    infoMessage, // infoMessage를 UI에 표시
                    style: const TextStyle(
                      fontSize: 12,
                      color: ColorStyles.darkGrey,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildTextField(_studentIdController, '학번 입력'),
            const SizedBox(height: 8),
            _buildTextField(_passwordController, '비밀번호 입력', obscureText: true),
            const SizedBox(height: 13),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => setState(() => _isLoginChecked = !_isLoginChecked),
                    child: Image.asset(
                      _isLoginChecked
                          ? 'assets/icons/ic_checked.png'
                          : 'assets/icons/ic_unchecked.png',
                      width: 14,
                      height: 14,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    '자동 로그인',
                    style: TextStyle(fontSize: 12, color: ColorStyles.darkGrey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: _login, // _login 함수 호출
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorStyles.mainBlue,
                fixedSize: const Size(316, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                '로그인',
                style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hintText, {bool obscureText = false}) {
    return SizedBox(
      width: 316,
      height: 42,
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(fontSize: 14, color: ColorStyles.editGrey),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: ColorStyles.borderGrey),
            borderRadius: BorderRadius.circular(8.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: ColorStyles.mainBlue),
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
      ),
    );
  }
}