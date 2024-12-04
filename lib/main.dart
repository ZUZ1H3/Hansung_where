import 'package:flutter/material.dart';
import 'package:hansung_where/theme/colors.dart';
import 'mainPages/ChatPage.dart';
import 'mainPages/HomePage.dart';
import 'mainPages/MapPage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'screens/PostPage.dart';
import 'LoginPage.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 백그라운드 메시지 처리 핸들러
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); //Flutter 엔진 초기화
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ); //Firebase 초기화

  //백그라운드 메시지 처리 등록
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

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
      //home: PostPage(1, 'lost'),
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

  late FirebaseMessaging messaging;

  @override
  void initState() {
    super.initState();

    messaging = FirebaseMessaging.instance;

    // 알림 권한 요청 (Android 13 이상)
    FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    ).then((settings) {
      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('알림 권한 허용됨');
      } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
        print('임시 알림 권한 허용됨');
      } else {
        print('알림 권한 거부됨');
      }
    });

    // FCM 토큰 확인
    messaging.getToken().then((token) {
      print("FCM Token: $token");
    });

    // 앱이 포그라운드 상태일 때 알림 수신
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Foreground message received: ${message.notification?.title}");
      // 앱 내에서 알림을 표시하거나 처리하는 로직 추가
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(message.notification?.title ?? "알림"),
          content: Text(message.notification?.body ?? ""),
        ),
      );
    });

    // 앱이 백그라운드에서 실행 중일 때 알림 클릭 처리
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("Notification clicked!");
      // 알림 클릭 시 화면 전환이나 다른 작업 추가
    });

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

    if (isLogIn) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ChatPage()),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
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
        onTap: (int index) {
          setState(() {
            _selectedIndex = index; // 페이지 전환
          });
        },
        items: bottomItems,
      ),
    );
  }
}
