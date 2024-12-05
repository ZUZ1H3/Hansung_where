import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:hansung_where/theme/colors.dart';
import 'mainPages/ChatPage.dart';
import 'mainPages/HomePage.dart';
import 'mainPages/MapPage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'LoginPage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Flutter 엔진 초기화
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ); // Firebase 초기화

  // 학교 SSL 인증서 로드
  final data = await rootBundle.load('assets/certificates/school_certificate.pem');
  SecurityContext.defaultContext.setTrustedCertificatesBytes(data.buffer.asUint8List());

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // DEBUG 제거
      theme: ThemeData(
        fontFamily: 'Neo',
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        scaffoldBackgroundColor: ColorStyles.seedColor,
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 1;
  SharedPreferences? prefs;
  final List<Widget> _pages = [
    MapPage(),
    HomePage(),
    ChatPage(),
  ];

  List<BottomNavigationBarItem> bottomItems = [
    const BottomNavigationBarItem(
      label: '지도',
      icon: ImageIcon(AssetImage('assets/pin.png'), size: 32),
    ),
    const BottomNavigationBarItem(
      label: '홈',
      icon: ImageIcon(AssetImage('assets/home.png'), size: 32),
    ),
    const BottomNavigationBarItem(
      label: '채팅',
      icon: ImageIcon(AssetImage('assets/chat.png'), size: 32),
    ),
  ];

  @override
  void initState() {
    super.initState();

    _initPrefs(); // SharedPreferences 초기화
  }

  Future<void> _initPrefs() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {}); // 상태 갱신
  }

  Future<void> _moveChat() async {
    if (prefs == null) {
      await _initPrefs(); // SharedPreferences 초기화 완료 대기
    }
    final isLogIn = prefs!.getBool('isLogIn') ?? false;

    if (!isLogIn) {
      // 로그인 화면으로 이동
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } else {
      // 로그인 상태일 경우, 채팅 화면으로 이동
      setState(() {
        _selectedIndex = 2; // 채팅 화면을 표시
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = prefs?.getBool('isLogIn') ?? false;

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          MapPage(),
          isLoggedIn ? HomePage() : LoginPage(), // 로그인 상태에 따라 화면 변경
          isLoggedIn ? ChatPage() : LoginPage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: ColorStyles.mainBlue,
        selectedItemColor: Colors.white,
        unselectedItemColor: ColorStyles.navGrey,
        currentIndex: _selectedIndex,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        onTap: (int index) async {
          if (index == 2 && !isLoggedIn) {
            // 로그인 상태가 아니면 로그인 화면으로 이동
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LoginPage()),
            );
          } else {
            setState(() {
              _selectedIndex = index;
            });
          }
        },
        items: bottomItems,
      ),
    );
  }
}
