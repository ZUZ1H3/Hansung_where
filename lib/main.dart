import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:hansung_where/screens/NotificationPage.dart';
import 'package:hansung_where/theme/colors.dart';
import 'mainPages/ChatPage.dart';
import 'mainPages/HomePage.dart';
import 'mainPages/MapPage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'LoginPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'local_push_notification.dart';
import 'message_page.dart';
import 'package:hansung_where/DbConn.dart';
import 'dart:async';

final navagatorKey = GlobalKey<NavigatorState>();
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Flutter 엔진 초기화
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ); // Firebase 초기화

  // 학교 SSL 인증서 로드
  final data = await rootBundle.load('assets/certificates/school_certificate.pem');
  SecurityContext.defaultContext.setTrustedCertificatesBytes(data.buffer.asUint8List());

  //로컬 푸시 알림 초기화
  await LocalPushNotifications.init();

  //앱이 종료된 상태에서 푸시 알림을 탭할 때
  final NotificationAppLaunchDetails? notificationAppLaunchDetails = await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
  if(notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
    Future.delayed(const Duration(seconds: 1), () {
      navagatorKey.currentState!.pushNamed('/notification', arguments: notificationAppLaunchDetails?.notificationResponse?.payload);
    });
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navagatorKey,
      debugShowCheckedModeBanner: false, // DEBUG 제거
      theme: ThemeData(
        fontFamily: 'Neo',
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        scaffoldBackgroundColor: ColorStyles.seedColor,
        useMaterial3: true,
      ),
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _opacity = 1.0; // 초기 투명도

  @override
  void initState() {
    super.initState();

    // 1초 후 투명도를 0으로 변경
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _opacity = 0.0; // 투명도를 0으로 설정
      });

      // 애니메이션이 끝난 후 메인 화면으로 이동
      Future.delayed(const Duration(seconds: 1), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MyHomePage()),
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 배경색
      body: Center(
        child: AnimatedOpacity(
          duration: const Duration(seconds: 1), // 애니메이션 지속 시간
          curve: Curves.easeInOut, // 부드러운 애니메이션
          opacity: _opacity, // 투명도
          child: Image.asset(
            'assets/mainLogo.png', // SplashScreen 이미지
            width: 152,
            height: 98,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
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

  @override
  void dispose() {
    super.dispose();
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
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: ColorStyles.mainBlue,
        // 하단 바 배경 색상
        selectedItemColor: Colors.white,
        // 선택된 아이템 색상
        unselectedItemColor: ColorStyles.navGrey,
        currentIndex: _selectedIndex,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        onTap: (int index) async {
          if (index == 2) {
            // 채팅 메뉴 클릭 시
            await _moveChat(); // 로그인 여부에 따라 페이지 이동
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
